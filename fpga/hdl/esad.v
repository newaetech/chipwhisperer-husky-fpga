`include "includes.v"
`timescale 1 ns / 1 ps
`default_nettype none

/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more
details, or the codebase at http://www.chipwhisperer.com

Copyright (c) 2024, NewAE Technology Inc. All rights reserved.
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

Implementation notes:
=====================
Compared to sad.v, we add pNUM_COUNTERS and use that to size relevant
components (instead of using pREF_SAMPLES as the number of reference samples
*and* the number of counters).

We add an "extended_mode" bit flag to each counter; when set, it means that
the associated counter is working on the extended set (second half) of
reference samples.

Each counter starts with extended_mode clear; at the halfway point,
a decision is made to either restart from ref sample 0 (if SAD is too high),
or keep going with the second half of the ref samples (and set
extended_mode to show that we're doing this).

Then, we use extended_mode to manage nextrefsample indexing.

Note extended_mode needs to be set a few cycles before the halfway point, due
to the latency in our SAD computations (i.e. if we wait until we have the
halfway point SAD result, it's too late because we've already started using
potentially wrong samples in our SAD pipeline).

*************************************************************************/

module esad #(
    // Note: pREF_SAMPLES * pBITS_PER_SAMPLE / 8 must not exceed 2**pBYTECNT_SIZE
    // FIFO allows up to 1024 pREF_SAMPLES and 12 pBITS_PER_SAMPLE; if either is
    // exceeded, the FIFO must be updated in Vivado.
    parameter pBYTECNT_SIZE = 7,
    parameter pREF_SAMPLES = 32, 
    parameter pBITS_PER_SAMPLE = 8,
    parameter pSAD_COUNTER_WIDTH = 16
)(
    input wire          reset,
    input wire          xadc_error,

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

    localparam pNUM_COUNTERS = pREF_SAMPLES/2;
    localparam pMASTER_COUNTER_WIDTH = (pREF_SAMPLES <= 32)?  5 :
                                       (pREF_SAMPLES <= 64)?  6 :
                                       (pREF_SAMPLES <= 128)? 7 :
                                       (pREF_SAMPLES <= 256)? 8 :
                                       (pREF_SAMPLES <= 512)? 9 :
                                       (pREF_SAMPLES <= 1024)? 10 : 11;

    reg  triggered;
    reg [15:0] num_triggers;
    reg clear_status;
    reg clear_status_r;
    wire clear_status_adc;

    reg multiple_triggers;
    reg [pREF_SAMPLES*pBITS_PER_SAMPLE-1:0] refsamples;
    reg [pREF_SAMPLES-1:0] refen = {pREF_SAMPLES{1'b1}}; // all samples enabled by default
    reg [pNUM_COUNTERS-1:0] compare_en, compare_en_short, compare_en_extended, compare_en_r;
    reg [pSAD_COUNTER_WIDTH-1:0] threshold;
    wire [pSAD_COUNTER_WIDTH-2:0] half_threshold = threshold[pSAD_COUNTER_WIDTH-1:1];
    reg [pMASTER_COUNTER_WIDTH-1:0] master_counter;
    wire [pMASTER_COUNTER_WIDTH-2:0] master_counter_short = master_counter[pMASTER_COUNTER_WIDTH-2:0];
    reg [pNUM_COUNTERS-1:0] resetter;
    reg [pNUM_COUNTERS-1:0] halfpoint;
    reg [pNUM_COUNTERS-1:0] trigger_possible;
    reg [pNUM_COUNTERS-1:0] extended_mode = {pNUM_COUNTERS{1'b0}};

    reg individual_trigger [0:pREF_SAMPLES-1];
    reg [pSAD_COUNTER_WIDTH-1:0] sad_counter [0:pNUM_COUNTERS-1];
    reg [pBITS_PER_SAMPLE-1:0] counter_incr [0:pNUM_COUNTERS-1];

    wire armed_and_ready_adc;
    wire armed_and_ready_adc_r;

    reg ready2trigger0;
    reg [pNUM_COUNTERS-1:1] ready2trigger_1andup;
    wire [pNUM_COUNTERS-1:0] ready2trigger_all = {ready2trigger_1andup, ready2trigger0};
    //reg ready2trigger_pre;
    //reg ready2trigger;

    reg  decision [0:pNUM_COUNTERS-1];
    reg [pBITS_PER_SAMPLE-1:0]  nextrefsample [0:pNUM_COUNTERS-1];
    reg [pBITS_PER_SAMPLE-1:0]  nextrefsample_short [0:pNUM_COUNTERS-1];
    reg [pBITS_PER_SAMPLE-1:0]  nextrefsample_extended [0:pNUM_COUNTERS-1];
    reg [pBITS_PER_SAMPLE-1:0]  nextrefsample_r [0:pNUM_COUNTERS-1];
    wire [pBITS_PER_SAMPLE-1:0]  refsample [0:pREF_SAMPLES-1];
    reg [pBITS_PER_SAMPLE-1:0] adc_datain_rpr, adc_datain_rmr; // sign extend
    reg [pBITS_PER_SAMPLE-1:0] adc_datain_r;

`ifdef HIPERF
    wire [23:0] status_reg = 24'b0;
`else
    wire [23:0] status_reg = {num_triggers, 7'b0, triggered};
`endif

    wire [31:0] wide_threshold_reg = {{(32-pSAD_COUNTER_WIDTH){1'b0}}, threshold}; // having a variable-width register isn't very convenient for Python
    reg [7:0] refbase;
    wire [15:0] ref_samples = pREF_SAMPLES;

    // These are a property of this module; used here to make sure Python
    // knows what it's talking to, in case there may be different SAD modules
    // used in different targets or builds.
    // Format: 2 MSB = version code (00: sad.v, 01: sad_x2_slowclock.v)
    //         6 LSB = trigger latency
    wire [7:0] version_bits = {2'b00, 6'd09}; // TODO: adjust

    // register reads:
    always @(*) begin
        if (reg_read) begin
            case (reg_address)
                `SAD_REFERENCE: reg_datao = refsamples[{refbase, reg_bytecnt}*8 +: 8];
                `SAD_REFEN: reg_datao = refen[reg_bytecnt*8 +: 8];
                `SAD_THRESHOLD: reg_datao = wide_threshold_reg[reg_bytecnt*8 +: 8];
                `SAD_STATUS: reg_datao = status_reg[reg_bytecnt*8 +: 8];
                `SAD_BITS_PER_SAMPLE: reg_datao = pBITS_PER_SAMPLE;
                `SAD_REF_SAMPLES: reg_datao = ref_samples[reg_bytecnt*8 +: 8];
                `SAD_COUNTER_WIDTH: reg_datao = pSAD_COUNTER_WIDTH;
                `SAD_MULTIPLE_TRIGGERS: reg_datao = {7'b0, multiple_triggers};
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
            refbase <= 0;
            refen <= {pREF_SAMPLES{1'b1}}; // all samples enabled by default
        end 
        else begin
            clear_status_r <= clear_status;
            if (reg_write) begin
                case (reg_address)
                    `SAD_REFERENCE: refsamples[{refbase, reg_bytecnt}*8 +: 8] <= reg_datai;
                    `SAD_REFEN: refen[reg_bytecnt*8 +: 8] <= reg_datai;
                    `SAD_THRESHOLD: threshold[reg_bytecnt*8 +: 8] <= reg_datai;
                `ifndef HIPERF
                    `SAD_MULTIPLE_TRIGGERS: multiple_triggers <= reg_datai[0];
                `endif
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

    wire [pMASTER_COUNTER_WIDTH-1:0] master_counter_top = pREF_SAMPLES-1;

    always @(posedge adc_sampleclk) begin
        if (armed_and_ready_adc && active && ~xadc_error) begin
            ready2trigger_1andup <= {ready2trigger_1andup[pNUM_COUNTERS-2:1], ready2trigger0};
            resetter <= {resetter[pNUM_COUNTERS-2:0], resetter[pNUM_COUNTERS-1]};
            halfpoint <= {halfpoint[pNUM_COUNTERS-2:0], halfpoint[pNUM_COUNTERS-1]};
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
            resetter <= {2'b0, 1'b1, {(pNUM_COUNTERS-3){1'b0}}};
            halfpoint <= {{(pNUM_COUNTERS-2){1'b0}}, 1'b1, 1'b0};
        end
    end

    integer c;
    always @(posedge adc_sampleclk) begin
        if (~active || ~armed_and_ready_adc)
            trigger <= 1'b0;
        else begin
            trigger <= 1'b0;
            for (c = 0; c < pNUM_COUNTERS; c = c + 1) begin
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
        adc_datain_rpr <= adc_datain_r;
        adc_datain_rmr <= -adc_datain_r;
    end

    genvar j;
    generate 
        for (j = 0; j < pREF_SAMPLES; j = j + 1) begin: gen_refsamples
            assign refsample[j] =  refsamples[j*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE];
        end
    endgenerate 


    // instantiate counters and do most of the heavy lifting:
    genvar i;
    generate 
        for (i = 0; i < pNUM_COUNTERS; i = i + 1) begin: gen_sad_counters

            always @(posedge adc_sampleclk) begin
                if (i == 0) begin
                    nextrefsample_short[0] <= refsample[master_counter_short];
                    nextrefsample_extended[0] <= refsample[master_counter];
                    compare_en_short[0] <= refen[master_counter_short];
                    compare_en_extended[0] <= refen[master_counter];
                    if (extended_mode[0]) begin
                        //nextrefsample[0] <= refsample[master_counter];
                        nextrefsample[0] <= nextrefsample_extended[0]; // NON-FUNCTIONAL EXPERIMENT!
                        compare_en[0] <= refen[master_counter];
                    end
                    else begin
                        //nextrefsample[0] <= refsample[master_counter_short];
                        nextrefsample[0] <= nextrefsample_short[0]; // NON-FUNCTIONAL EXPERIMENT!
                        compare_en[0] <= refen[master_counter_short];
                    end
                end

                else begin
                    nextrefsample_short[i] <= nextrefsample_short[i-1];
                    nextrefsample_extended[i] <= nextrefsample_extended[i-1];
                    compare_en_short[i] <= compare_en_short[i-1];
                    compare_en_extended[i] <= compare_en_extended[i-1];
                    if (extended_mode[i]) begin
                        nextrefsample[i] <= nextrefsample_extended[i-1];
                        compare_en[i] <= compare_en_extended[i-1];
                    end
                    else begin
                        nextrefsample[i] <= nextrefsample_short[i-1];
                        compare_en[i] <= compare_en_short[i-1];
                    end
                end

                nextrefsample_r[i] <= nextrefsample[i];
                compare_en_r[i] <= compare_en[i];

                if (adc_datain_r > nextrefsample[i])
                    decision[i] <= 1'b1;
                else
                    decision[i] <= 1'b0;

                if (compare_en_r[i] == 0)
                    counter_incr[i] <= 0;
                else if (decision[i])
                    counter_incr[i] <= adc_datain_rpr - nextrefsample_r[i];
                else
                    counter_incr[i] <= adc_datain_rmr + nextrefsample_r[i];


                if (~(armed_and_ready_adc && active && ~xadc_error)) begin
                    // important to reset this! However, it's not necessary to reset sad_counter - they will take care of themselves
                    extended_mode[i] <= {pNUM_COUNTERS{1'b0}}; 
                    trigger_possible[i] <= {pNUM_COUNTERS{1'b0}}; // this is the culprit which somehow makes Vivado eliminate adc_sampleclk!
                end
                else if (halfpoint[i]) begin
                    if (extended_mode[i]) begin
                        extended_mode[i] <= 1'b0;
                        trigger_possible[i] <= 1'b1;
                    end
                    else if (sad_counter[i] < half_threshold) begin
                        extended_mode[i] <= 1'b1;
                        trigger_possible[i] <= 1'b0;
                    end
                    else begin
                        extended_mode[i] <= 1'b0;
                        trigger_possible[i] <= 1'b0;
                    end
                end

                if (resetter[i] && ~extended_mode[i])
                    sad_counter[i] <= counter_incr[i];
                else if (~sad_counter[i][pSAD_COUNTER_WIDTH-1]) // MSB of counter is used to indicate saturation
                    sad_counter[i] <= sad_counter[i] + counter_incr[i];

            end

            always @ (posedge adc_sampleclk) begin
                if ((sad_counter[i] <= threshold) && resetter[i] && trigger_possible[i] && ready2trigger_all[i])
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
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample12 = nextrefsample[12];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample12r = nextrefsample_r[12];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample24 = nextrefsample[24];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample24r = nextrefsample_r[24];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample28 = nextrefsample[28];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample28r = nextrefsample_r[28];

    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_short0 = nextrefsample_short[0];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_short1 = nextrefsample_short[1];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_short12 = nextrefsample_short[12];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_short27 = nextrefsample_short[27];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_short28 = nextrefsample_short[28];

    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_extended0  = nextrefsample_extended[0];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_extended1  = nextrefsample_extended[1];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_extended12 = nextrefsample_extended[12];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_extended27 = nextrefsample_extended[27];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_extended28 = nextrefsample_extended[28];

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
