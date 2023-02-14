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
    parameter pBITS_PER_SAMPLE = 8
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

    input  wire         ext_trigger,  // debug only
    input  wire         io4,  // debug only
    output reg          trigger
);

    reg  triggered;
    reg clear_status;
    reg clear_status_r;
    wire clear_status_adc;

    reg multiple_triggers;
    reg [pBITS_PER_SAMPLE-1:0] maxdev;
    reg [pREF_SAMPLES*pBITS_PER_SAMPLE-1:0] refsamples;
    reg [31:0] threshold; // must be wide enough so it doesn't overflow (must hold addition of pREF_SAMPLES numbers that are each pBITS_PER_SAMPLE bits wide)
    reg [7:0] master_counter; // must be wide enough to count to pREF_SAMPLES-1

    // register reads:
    always @(*) begin
        if (reg_read) begin
            case (reg_address)
                `SAD_REFERENCE: reg_datao = refsamples[reg_bytecnt*8 +: 8];
                `SAD_THRESHOLD: reg_datao = threshold[reg_bytecnt*8 +: 8];
                `SAD_STATUS: reg_datao = {7'b0, triggered};
                `SAD_BITS_PER_SAMPLE: reg_datao = pBITS_PER_SAMPLE;
                `SAD_REF_SAMPLES: reg_datao = pREF_SAMPLES;
                `SAD_MAX_DEV: reg_datao = maxdev[reg_bytecnt*8 +: 8];
                `SAD_MULTIPLE_TRIGGERS: reg_datao = {7'b0, multiple_triggers};
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
            maxdev <= 0;
        end 
        else begin
            clear_status_r <= clear_status;
            if (reg_write) begin
                case (reg_address)
                    `SAD_REFERENCE: refsamples[reg_bytecnt*8 +: 8] <= reg_datai;
                    `SAD_THRESHOLD: threshold[reg_bytecnt*8 +: 8] <= reg_datai;
                    `SAD_MAX_DEV: maxdev[reg_bytecnt*8 +: 8] <= reg_datai;
                    `SAD_MULTIPLE_TRIGGERS: multiple_triggers <= reg_datai[0];
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
        if (reset)
            triggered <= 1'b0;
        else begin
            if (clear_status_adc)
                triggered <= 1'b0;
            else if (trigger)
                triggered <= 1'b1;
        end
    end

    reg individual_trigger [0:pREF_SAMPLES-1];
    // TODO: these need to be wider than pBITS_PER_SAMPLE since we're adding many pBITS_PER_SAMPLE-wide numbers... hard-coded here for pBITS_PER_SAMPLE=8, pREF_SAMPLES=128
    reg [15:0] sad_counter [0:pREF_SAMPLES-1];
    reg [15:0] counter_incr [0:pREF_SAMPLES-1];

    integer c;

    wire armed_and_ready_adc;
    cdc_simple U_armed_and_ready_cdc (
        .reset          (reset),
        .clk            (adc_sampleclk),
        .data_in        (armed_and_ready),
        .data_out       (armed_and_ready_adc),
        .data_out_r     ()
    );

    reg ready2trigger0;
    reg [pREF_SAMPLES-1:1] ready2trigger_1andup;
    wire [pREF_SAMPLES-1:0] ready2trigger_all = {ready2trigger_1andup, ready2trigger0};

    always @(posedge adc_sampleclk) begin
        if (reset) begin
            master_counter <= 0;
            ready2trigger0 <= 0;
            ready2trigger_1andup <= 0;
        end
        else begin
            ready2trigger_1andup <= {ready2trigger_1andup[pREF_SAMPLES-2:1], ready2trigger0};
            if (armed_and_ready_adc && active) begin
                if (master_counter == pREF_SAMPLES-1) begin
                    ready2trigger0 <= 1;
                    master_counter <= 0;
                end
                else
                    master_counter <= master_counter + 1;
            end
            else begin
                master_counter <= 0;
                ready2trigger0 <= 0;
            end
        end
    end

    always @(posedge adc_sampleclk) begin
        if (~active || ~armed_and_ready_adc)
            trigger <= 1'b0;
        else begin
            trigger <= 1'b0;
            for (c = 0; c < pREF_SAMPLES; c = c + 1) begin
                if (individual_trigger[c] && ready2trigger_all[c]) trigger <= 1'b1;
            end
        end
    end

    // TODO: multiple triggers

    reg [pBITS_PER_SAMPLE-1:0]  nextrefsample [0:pREF_SAMPLES-1];
    wire [pBITS_PER_SAMPLE-1:0]  refsample [0:pREF_SAMPLES-1];
    reg [pBITS_PER_SAMPLE-1:0] adc_datain_r;
    always @(posedge adc_sampleclk) adc_datain_r <= adc_datain;

    // instantiate counters and do most of the heavy lifting:
    genvar i;
    generate 
        for (i = 0; i < pREF_SAMPLES; i = i + 1) begin: gen_sad_counters
            assign refsample[i] =  refsamples[i*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE];

            always @(posedge adc_sampleclk) begin
                nextrefsample[i] <=  refsample[(master_counter+pREF_SAMPLES-i)%pREF_SAMPLES];

                if (adc_datain_r > nextrefsample[i])
                    counter_incr[i] <= adc_datain_r - nextrefsample[i];
                else
                    counter_incr[i] <= nextrefsample[i] - adc_datain_r;

                if (~armed_and_ready_adc) // TODO: appropriate?
                    sad_counter[i] <= 0;
                else if ((master_counter + pREF_SAMPLES - 2) % pREF_SAMPLES == i)
                    sad_counter[i] <= counter_incr[i];
                else
                    sad_counter[i] <= sad_counter[i] + counter_incr[i];
            end

            always @ (posedge adc_sampleclk) begin
                if ((sad_counter[i] <= threshold) && (master_counter == (i + 1)%pREF_SAMPLES))
                    individual_trigger[i] <= 1'b1;
                else
                    individual_trigger[i] <= 1'b0;
            end

        end
    endgenerate

    // for debug; constant width so it doesn't disappear from gtkwave when changing pBITS_PER_SAMPLE:
    wire [11:0] refsample0 = refsamples[0*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE];
    wire [11:0] refsample1 = refsamples[1*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE];
    wire [11:0] refsample2 = refsamples[2*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE];
    wire [11:0] refsample3 = refsamples[3*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE];

    wire [11:0] nextrefsample0 = nextrefsample[0];
    wire [11:0] nextrefsample1 = nextrefsample[1];
    wire [11:0] nextrefsample2 = nextrefsample[2];
    wire [11:0] nextrefsample3 = nextrefsample[3];
    wire [11:0] nextrefsample8 = nextrefsample[8];
    wire [11:0] nextrefsample9 = nextrefsample[9];
    wire [11:0] nextrefsample10 = nextrefsample[10];
    wire [11:0] nextrefsample18 = nextrefsample[18];

    wire [15:0] sad_counter0  = sad_counter[0 ];
    wire [15:0] sad_counter1  = sad_counter[1 ];
    wire [15:0] sad_counter2  = sad_counter[2 ];
    wire [15:0] sad_counter3  = sad_counter[3 ];
    wire [15:0] sad_counter4  = sad_counter[4 ];
    wire [15:0] sad_counter5  = sad_counter[5 ];
    wire [15:0] sad_counter6  = sad_counter[6 ];
    wire [15:0] sad_counter7  = sad_counter[7 ];
    wire [15:0] sad_counter8  = sad_counter[8 ];
    wire [15:0] sad_counter9  = sad_counter[9 ];
    wire [15:0] sad_counter10 = sad_counter[10];
    wire [15:0] sad_counter11 = sad_counter[11];
    wire [15:0] sad_counter12 = sad_counter[12];
    wire [15:0] sad_counter13 = sad_counter[13];
    wire [15:0] sad_counter14 = sad_counter[14];
    wire [15:0] sad_counter15 = sad_counter[15];
    wire [15:0] sad_counter16 = sad_counter[16];
    wire [15:0] sad_counter17 = sad_counter[17];
    wire [15:0] sad_counter18 = sad_counter[18];
    wire [15:0] sad_counter19 = sad_counter[19];
    wire [15:0] sad_counter20 = sad_counter[20];
    wire [15:0] sad_counter21 = sad_counter[21];
    wire [15:0] sad_counter22 = sad_counter[22];
    wire [15:0] sad_counter23 = sad_counter[23];
    wire [15:0] sad_counter24 = sad_counter[24];
    wire [15:0] sad_counter25 = sad_counter[25];
    wire [15:0] sad_counter26 = sad_counter[26];
    wire [15:0] sad_counter27 = sad_counter[27];
    wire [15:0] sad_counter28 = sad_counter[28];
    wire [15:0] sad_counter29 = sad_counter[29];
    wire [15:0] sad_counter30 = sad_counter[30];
    wire [15:0] sad_counter31 = sad_counter[31];

    wire [15:0] counter_incr0 = counter_incr[0];
    wire [15:0] counter_incr8 = counter_incr[8];
    wire [15:0] counter_incr9 = counter_incr[9];
    wire [15:0] counter_incr10 = counter_incr[10];
    wire [15:0] counter_incr18 = counter_incr[18];

    /*
    wire [31:0] potential_trigger_debug =   {potential_trigger[31],
                                             potential_trigger[30],
                                             potential_trigger[29],
                                             potential_trigger[28],
                                             potential_trigger[27],
                                             potential_trigger[26],
                                             potential_trigger[25],
                                             potential_trigger[24],
                                             potential_trigger[23],
                                             potential_trigger[22],
                                             potential_trigger[21],
                                             potential_trigger[20],
                                             potential_trigger[19],
                                             potential_trigger[18],
                                             potential_trigger[17],
                                             potential_trigger[16],
                                             potential_trigger[15],
                                             potential_trigger[14],
                                             potential_trigger[13],
                                             potential_trigger[12],
                                             potential_trigger[11],
                                             potential_trigger[10],
                                             potential_trigger[9],
                                             potential_trigger[8],
                                             potential_trigger[7],
                                             potential_trigger[6],
                                             potential_trigger[5],
                                             potential_trigger[4],
                                             potential_trigger[3],
                                             potential_trigger[2],
                                             potential_trigger[1],
                                             potential_trigger[0]};
    */


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
