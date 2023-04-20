`include "includes.v"
`timescale 1 ns / 1 ps
`default_nettype none

/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more
details, or the codebase at http://www.chipwhisperer.com

Copyright (c) 2022-2023, NewAE Technology Inc. All rights reserved.
Author: Jean-Pierre Thibault <jpthibault@newae.com>

  chipwhisperer is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  chipwhisperer is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU Lesser General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with chipwhisperer.  If not, see <http://www.gnu.org/licenses/>.
*************************************************************************/

module sad #(
    // Note: pREF_SAMPLES * pBITS_PER_SAMPLE / 8 must not exceed 2**pBYTECNT_SIZE
    // FIFO allows up to 1024 pREF_SAMPLES and 12 pBITS_PER_SAMPLE; if either is
    // exceeded, the FIFO must be updated in Vivado.
    parameter pBYTECNT_SIZE = 7,
    parameter pREF_SAMPLES = 32, 
    parameter pBITS_PER_SAMPLE = 8,
    parameter pSAD_COUNTER_WIDTH = 16
)(
    input wire          reset,

    //ADC Sample Input
    input wire [pBITS_PER_SAMPLE-1:0] adc_datain,
    input wire          adc_sampleclk,
    input wire          armed_and_ready,
    input wire          active,

    //USB register interface
    input wire          clk_usb,
    input  wire [7:0]   reg_address,  // Address of register
    input  wire [pBYTECNT_SIZE-1:0]  reg_bytecnt,  // Current byte count
    input  wire [7:0]   reg_datai,    // Data to write
    output reg  [7:0]   reg_datao,    // Data to read
    input  wire         reg_read,     // Read flag
    input  wire         reg_write,    // Write flag

    // verilator lint_off UNUSED
    input  wire         ext_trigger,  // debug only
    input  wire         io4,  // debug only
    // verilator lint_on UNUSED
    output reg          trigger
);

    localparam pMASTER_COUNTER_WIDTH = (pREF_SAMPLES <= 32)?  5 :
                                       (pREF_SAMPLES <= 64)?  6 :
                                       (pREF_SAMPLES <= 128)? 7 :
                                       (pREF_SAMPLES <= 256)? 8 :
                                       (pREF_SAMPLES <= 512)? 9 : 10;

    reg  triggered;
    reg [15:0] num_triggers;
    reg clear_status;
    reg clear_status_r;
    wire clear_status_adc;

    reg multiple_triggers;
    reg [pREF_SAMPLES*pBITS_PER_SAMPLE-1:0] refsamples;
    reg [pSAD_COUNTER_WIDTH-1:0] threshold;
    reg [pMASTER_COUNTER_WIDTH-1:0] master_counter;
    reg [pREF_SAMPLES-1:0] resetter;

    reg individual_trigger [0:pREF_SAMPLES-1];
    reg [pSAD_COUNTER_WIDTH-1:0] sad_counter [0:pREF_SAMPLES-1];
    reg [pSAD_COUNTER_WIDTH-1:0] counter_incr [0:pREF_SAMPLES-1];

    wire armed_and_ready_adc;
    wire armed_and_ready_adc_r;

    reg ready2trigger0;
    reg [pREF_SAMPLES-1:1] ready2trigger_1andup;
    wire [pREF_SAMPLES-1:0] ready2trigger_all = {ready2trigger_1andup, ready2trigger0};
    //reg ready2trigger_pre;
    //reg ready2trigger;

    reg  decision [0:pREF_SAMPLES-1];
    reg [pBITS_PER_SAMPLE-1:0]  nextrefsample [0:pREF_SAMPLES-1];
    reg [pBITS_PER_SAMPLE-1:0]  nextrefsample_r [0:pREF_SAMPLES-1];
    wire [pBITS_PER_SAMPLE-1:0]  refsample [0:pREF_SAMPLES-1];
    reg [pSAD_COUNTER_WIDTH-1:0] adc_datain_rpr, adc_datain_rmr; // sign extend
    reg [pBITS_PER_SAMPLE-1:0] adc_datain_r;
    wire [23:0] status_reg = {num_triggers, 7'b0, triggered};
    reg sad_short;
    wire [31:0] wide_threshold_reg = {{(32-pSAD_COUNTER_WIDTH){1'b0}}, threshold}; // having a variable-width register isn't very convenient for Python
    reg [7:0] refbase;
    wire [15:0] ref_samples = pREF_SAMPLES;

    // These are a property of this module; used here to make sure Python
    // knows what it's talking to, in case there may be different SAD modules
    // used in different targets or builds.
    // Format: 2 MSB = version code (00: sad.v, 01: sad_x2_slowclock.v)
    //         6 LSB = trigger latency
    wire [7:0] version_bits = {2'b00, 6'd09};

    // register reads:
    always @(*) begin
        if (reg_read) begin
            case (reg_address)
                `SAD_REFERENCE: reg_datao = refsamples[{refbase, reg_bytecnt}*8 +: 8];
                `SAD_THRESHOLD: reg_datao = wide_threshold_reg[reg_bytecnt*8 +: 8];
                `SAD_STATUS: reg_datao = status_reg[reg_bytecnt*8 +: 8];
                `SAD_BITS_PER_SAMPLE: reg_datao = pBITS_PER_SAMPLE;
                `SAD_REF_SAMPLES: reg_datao = ref_samples[reg_bytecnt*8 +: 8];
                `SAD_COUNTER_WIDTH: reg_datao = pSAD_COUNTER_WIDTH;
                `SAD_MULTIPLE_TRIGGERS: reg_datao = {7'b0, multiple_triggers};
                `SAD_SHORT: reg_datao = {7'b0, sad_short};
                `SAD_VERSION: reg_datao = version_bits;
                default: reg_datao = 0;
            endcase
        end
        else
            reg_datao = 0;
    end

    // register writes:
    always @(posedge clk_usb) begin
        if (reset) begin
            refsamples <= 0;
            threshold <= 0;
            clear_status_r <= 0;
            multiple_triggers <= 0;
            sad_short <= 0;
            refbase <= 0;
        end 
        else begin
            clear_status_r <= clear_status;
            if (reg_write) begin
                case (reg_address)
                    `SAD_REFERENCE: refsamples[{refbase, reg_bytecnt}*8 +: 8] <= reg_datai;
                    `SAD_THRESHOLD: threshold[reg_bytecnt*8 +: 8] <= reg_datai;
                    `SAD_MULTIPLE_TRIGGERS: multiple_triggers <= reg_datai[0];
                    `SAD_SHORT: sad_short <= reg_datai[0];
                    `SAD_REFERENCE_BASE: refbase <= reg_datai;
                    default: ;
                endcase
                if (reg_address == `SAD_STATUS)
                    clear_status <= 1'b1;
                else
                    clear_status <= 1'b0;
            end
        end
    end

   cdc_pulse U_clear_status_cdc (
      .reset_i       (reset),
      .src_clk       (clk_usb),
      .src_pulse     (clear_status && ~clear_status_r),
      .dst_clk       (adc_sampleclk),
      .dst_pulse     (clear_status_adc)
   );

    always @(posedge adc_sampleclk) begin
        if (clear_status_adc || (armed_and_ready_adc && ~armed_and_ready_adc_r)) begin
            triggered <= 1'b0;
            num_triggers <= 0;
        end
        else if (trigger) begin
            triggered <= 1'b1;
            num_triggers <= num_triggers + 1;
        end
    end

    cdc_simple U_armed_and_ready_cdc (
        .reset          (reset),
        .clk            (adc_sampleclk),
        .data_in        (armed_and_ready),
        .data_out       (armed_and_ready_adc),
        .data_out_r     (armed_and_ready_adc_r)
    );

    wire [pMASTER_COUNTER_WIDTH-1:0] master_counter_top = (sad_short)? pREF_SAMPLES/2-1 : pREF_SAMPLES-1;

    always @(posedge adc_sampleclk) begin
        if (armed_and_ready_adc && active) begin
            ready2trigger_1andup <= {ready2trigger_1andup[pREF_SAMPLES-2:1], ready2trigger0};
            resetter <= {resetter[pREF_SAMPLES-2:0], resetter[pREF_SAMPLES-1]};
            if (master_counter == master_counter_top) begin
                ready2trigger0 <= 1;
                master_counter <= 0;
                /* for better timing (see NOTE comment below on trigger assignment)
                if (ready2trigger_pre)
                    ready2trigger <= 1;
                else
                    ready2trigger_pre <= 1;
                */
            end
            else
                master_counter <= master_counter + 1;
        end
        else begin
            master_counter <= 0;
            ready2trigger0 <= 0;
            ready2trigger_1andup <= 0;
            /*
            ready2trigger_pre <= 0;
            ready2trigger <= 0;
            */
            if (sad_short)
                resetter <= {2{2'b0, 1'b1, {(pREF_SAMPLES/2-3){1'b0}}}};
            else
                resetter <= {2'b0, 1'b1, {(pREF_SAMPLES-3){1'b0}}};
        end
    end

    integer c;
    always @(posedge adc_sampleclk) begin
        if (~active || ~armed_and_ready_adc)
            trigger <= 1'b0;
        else begin
            trigger <= 1'b0;
            for (c = 0; c < pREF_SAMPLES; c = c + 1) begin
                if (individual_trigger[c] && ~(triggered && ~multiple_triggers)) trigger <= 1'b1;
                // NOTE: the alternative below results in better timing, but in the case of multiple triggers it
                // *can* result in missed triggers if they are too close together. If trying this, also remove
                // the ready2trigger_all condition onthe individual_trigger assignment (in a later block).
                //if (individual_trigger[c] && ready2trigger && ~(triggered && ~multiple_triggers)) trigger <= 1'b1;
            end
        end
    end

    always @(posedge adc_sampleclk) begin
        adc_datain_r <= adc_datain;
        adc_datain_rpr <= {{(pSAD_COUNTER_WIDTH-pBITS_PER_SAMPLE){1'b0}}, adc_datain_r};
        adc_datain_rmr <= -{{(pSAD_COUNTER_WIDTH-pBITS_PER_SAMPLE){1'b0}}, adc_datain_r};
    end

    // instantiate counters and do most of the heavy lifting:
    genvar i;
    generate 
        for (i = 0; i < pREF_SAMPLES; i = i + 1) begin: gen_sad_counters
            assign refsample[i] =  refsamples[i*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE];

            always @(posedge adc_sampleclk) begin
                if (i == 0)
                    nextrefsample[i] <=  refsample[master_counter];
                else
                    nextrefsample[i] <=  nextrefsample[i-1];
                nextrefsample_r[i] <=  nextrefsample[i];

                if (adc_datain_r > nextrefsample[i])
                    decision[i] <= 1'b1;
                else
                    decision[i] <= 1'b0;

                if (decision[i])
                    counter_incr[i] <= adc_datain_rpr - nextrefsample_r[i];
                else
                    counter_incr[i] <= adc_datain_rmr + nextrefsample_r[i];

                if (resetter[i])
                    sad_counter[i] <= counter_incr[i];
                else if (~sad_counter[i][pSAD_COUNTER_WIDTH-1]) // MSB of counter is used to indicate saturation
                    sad_counter[i] <= sad_counter[i] + counter_incr[i];
            end

            always @ (posedge adc_sampleclk) begin
                if ((sad_counter[i] <= threshold) && resetter[i] && ready2trigger_all[i])
                    individual_trigger[i] <= 1'b1;
                else
                    individual_trigger[i] <= 1'b0;
            end

        end
    endgenerate

    // for debug only:
    // verilator lint_off UNUSED
    // verilator lint_off WIDTH
    wire [pBITS_PER_SAMPLE-1:0] refsample0 = refsample[0];
    wire [pBITS_PER_SAMPLE-1:0] refsample1 = refsample[1];
    wire [pBITS_PER_SAMPLE-1:0] refsample2 = refsample[2];
    wire [pBITS_PER_SAMPLE-1:0] refsample3 = refsample[3];

    wire [pBITS_PER_SAMPLE-1:0] nextrefsample0 = nextrefsample[0];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample1 = nextrefsample[1];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample2 = nextrefsample[2];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample3 = nextrefsample[3];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample4 = nextrefsample[4];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample5 = nextrefsample[5];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample6 = nextrefsample[6];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample7 = nextrefsample[7];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample8 = nextrefsample[8];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample9 = nextrefsample[9];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample10 = nextrefsample[10];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample18 = nextrefsample[18];

    wire [pSAD_COUNTER_WIDTH-1:0] sad_counter0  = sad_counter[0 ];
    wire [pSAD_COUNTER_WIDTH-1:0] sad_counter1  = sad_counter[1 ];
    wire [pSAD_COUNTER_WIDTH-1:0] sad_counter2  = sad_counter[2 ];
    wire [pSAD_COUNTER_WIDTH-1:0] sad_counter3  = sad_counter[3 ];
    wire [pSAD_COUNTER_WIDTH-1:0] sad_counter4  = sad_counter[4 ];
    wire [pSAD_COUNTER_WIDTH-1:0] sad_counter5  = sad_counter[5 ];
    wire [pSAD_COUNTER_WIDTH-1:0] sad_counter6  = sad_counter[6 ];
    wire [pSAD_COUNTER_WIDTH-1:0] sad_counter7  = sad_counter[7 ];
    wire [pSAD_COUNTER_WIDTH-1:0] sad_counter8  = sad_counter[8 ];
    wire [pSAD_COUNTER_WIDTH-1:0] sad_counter9  = sad_counter[9 ];
    wire [pSAD_COUNTER_WIDTH-1:0] sad_counter10 = sad_counter[10];
    wire [pSAD_COUNTER_WIDTH-1:0] sad_counter11 = sad_counter[11];
    wire [pSAD_COUNTER_WIDTH-1:0] sad_counter12 = sad_counter[12];
    wire [pSAD_COUNTER_WIDTH-1:0] sad_counter13 = sad_counter[13];
    wire [pSAD_COUNTER_WIDTH-1:0] sad_counter14 = sad_counter[14];
    wire [pSAD_COUNTER_WIDTH-1:0] sad_counter15 = sad_counter[15];
    wire [pSAD_COUNTER_WIDTH-1:0] sad_counter16 = sad_counter[16];
    wire [pSAD_COUNTER_WIDTH-1:0] sad_counter17 = sad_counter[17];
    wire [pSAD_COUNTER_WIDTH-1:0] sad_counter18 = sad_counter[18];
    wire [pSAD_COUNTER_WIDTH-1:0] sad_counter19 = sad_counter[19];
    wire [pSAD_COUNTER_WIDTH-1:0] sad_counter20 = sad_counter[20];
    wire [pSAD_COUNTER_WIDTH-1:0] sad_counter21 = sad_counter[21];
    wire [pSAD_COUNTER_WIDTH-1:0] sad_counter22 = sad_counter[22];
    wire [pSAD_COUNTER_WIDTH-1:0] sad_counter23 = sad_counter[23];
    wire [pSAD_COUNTER_WIDTH-1:0] sad_counter24 = sad_counter[24];
    wire [pSAD_COUNTER_WIDTH-1:0] sad_counter25 = sad_counter[25];
    wire [pSAD_COUNTER_WIDTH-1:0] sad_counter26 = sad_counter[26];
    wire [pSAD_COUNTER_WIDTH-1:0] sad_counter27 = sad_counter[27];
    wire [pSAD_COUNTER_WIDTH-1:0] sad_counter28 = sad_counter[28];
    wire [pSAD_COUNTER_WIDTH-1:0] sad_counter29 = sad_counter[29];
    wire [pSAD_COUNTER_WIDTH-1:0] sad_counter30 = sad_counter[30];
    wire [pSAD_COUNTER_WIDTH-1:0] sad_counter31 = sad_counter[31];

    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr0 = counter_incr[0];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr1 = counter_incr[1];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr3 = counter_incr[3];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr7 = counter_incr[7];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr8 = counter_incr[8];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr9 = counter_incr[9];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr10 = counter_incr[10];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr18 = counter_incr[18];

    wire [31:0] individual_trigger_debug =  {individual_trigger[31],
                                             individual_trigger[30],
                                             individual_trigger[29],
                                             individual_trigger[28],
                                             individual_trigger[27],
                                             individual_trigger[26],
                                             individual_trigger[25],
                                             individual_trigger[24],
                                             individual_trigger[23],
                                             individual_trigger[22],
                                             individual_trigger[21],
                                             individual_trigger[20],
                                             individual_trigger[19],
                                             individual_trigger[18],
                                             individual_trigger[17],
                                             individual_trigger[16],
                                             individual_trigger[15],
                                             individual_trigger[14],
                                             individual_trigger[13],
                                             individual_trigger[12],
                                             individual_trigger[11],
                                             individual_trigger[10],
                                             individual_trigger[9],
                                             individual_trigger[8],
                                             individual_trigger[7],
                                             individual_trigger[6],
                                             individual_trigger[5],
                                             individual_trigger[4],
                                             individual_trigger[3],
                                             individual_trigger[2],
                                             individual_trigger[1],
                                             individual_trigger[0]};

    // verilator lint_on UNUSED
    // verilator lint_on WIDTH

   `ifdef ILA_SAD
       ila_sad U_ila_sad (
          .clk            (clk_usb),              // input wire clk
          .probe0         (adc_datain),           // input wire [7:0]  probe0 
          .probe1         (state),                // input wire [1:0]  probe1 
          .probe2         (individual_trigger_debug),// input wire [31:0]  probe2 
          .probe3         (trigger),              // input wire [0:0]  probe3 
          .probe4         (sad_counter0),         // input wire [15:0]  probe4 
          .probe5         (sad_counter1),         // input wire [15:0]  probe5 
          .probe6         (refsamples[31:0]),     // input wire [31:0]  probe6 
          .probe7         (counter_counter0),     // input wire [6:0]  probe7 
          .probe8         (arm_i),                // input wire [0:0]  probe8 
          .probe9         (ext_trigger)           // input wire [0:0]  probe9
       );
   `endif
   //


endmodule
`default_nettype wire
