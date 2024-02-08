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
*************************************************************************/

module sad_x2 #(
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

    localparam pSADS_PER_CYCLE = 2;
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

    reg always_armed;
    reg multiple_triggers;
    reg [pREF_SAMPLES*pBITS_PER_SAMPLE-1:0] refsamples;
    reg [pREF_SAMPLES-1:0] refen = {pREF_SAMPLES{1'b1}}; // all samples enabled by default
    reg [pREF_SAMPLES-1:0] compare_en_a, compare_en_b;
    reg [pREF_SAMPLES-1:0] compare_en_ar, compare_en_br;
    reg [pSAD_COUNTER_WIDTH-1:0] threshold;
    wire [pMASTER_COUNTER_WIDTH-1:0] master_counter;
    reg [pMASTER_COUNTER_WIDTH-1:0] master_counter_full;
    wire tick_tock;
    reg resetter [0:pREF_SAMPLES-1];

    reg individual_trigger [0:pREF_SAMPLES-1];
    reg [pSAD_COUNTER_WIDTH-1:0] sad_counter [0:pREF_SAMPLES-1];
    reg [pSAD_COUNTER_WIDTH-1:0] counter_incr [0:pREF_SAMPLES-1];

    wire armed_and_ready_adc;
    wire armed_and_ready_adc_r;
    wire active_adc;

    reg ready2trigger [0:pREF_SAMPLES-1];

    reg decision_a [0:pREF_SAMPLES-1];
    reg decision_b [0:pREF_SAMPLES-1];
    reg [pBITS_PER_SAMPLE-1:0]  nextrefsample_a [0:pREF_SAMPLES-1];
    reg [pBITS_PER_SAMPLE-1:0]  nextrefsample_b [0:pREF_SAMPLES-1];
    reg [pBITS_PER_SAMPLE-1:0]  nextrefsample_ar [0:pREF_SAMPLES-1];
    reg [pBITS_PER_SAMPLE-1:0]  nextrefsample_br [0:pREF_SAMPLES-1];
    wire [pBITS_PER_SAMPLE-1:0]  refsample [0:pREF_SAMPLES-1];
    reg [pBITS_PER_SAMPLE-1:0] adc_datain_r;
    reg [pBITS_PER_SAMPLE-1:0] datain_a;
    reg [pBITS_PER_SAMPLE-1:0] datain_b;

    // sign extension:
    reg [pSAD_COUNTER_WIDTH-1:0] datain_a_rpr;
    reg [pSAD_COUNTER_WIDTH-1:0] datain_a_rmr;
    reg [pSAD_COUNTER_WIDTH-1:0] datain_b_rpr;
    reg [pSAD_COUNTER_WIDTH-1:0] datain_b_rmr;


    wire [23:0] status_reg = {num_triggers, 7'b0, triggered};
    wire [31:0] wide_threshold_reg = {{(32-pSAD_COUNTER_WIDTH){1'b0}}, threshold}; // having a variable-width register isn't very convenient for Python
    reg [7:0] refbase;

    // These are a property of this module; used here to make sure Python
    // knows what it's talking to, in case there may be different SAD modules
    // used in different targets or builds.
    // Format: 2 MSB = version code (00: sad.v, 01: sad_x2_slowclock.v, 10: sad_x4_slowclock.v, 11: sad_x2.v
    //         6 LSB = trigger latency
    wire [7:0] version_bits = {2'b11, 6'd10};
    wire [15:0] ref_samples = pREF_SAMPLES;

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
                `SAD_ALWAYS_ARMED: reg_datao <= {7'b0, always_armed};
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
            always_armed <= 0;
            refen <= {pREF_SAMPLES{1'b1}}; // all samples enabled by default
        end 
        else begin
            clear_status_r <= clear_status;
            if (reg_write) begin
                case (reg_address)
                    `SAD_REFERENCE: refsamples[{refbase, reg_bytecnt}*8 +: 8] <= reg_datai;
                    `SAD_REFEN: refen[reg_bytecnt*8 +: 8] <= reg_datai;
                    `SAD_THRESHOLD: threshold[reg_bytecnt*8 +: 8] <= reg_datai;
                    `SAD_MULTIPLE_TRIGGERS: multiple_triggers <= reg_datai[0];
                    `SAD_REFERENCE_BASE: refbase <= reg_datai;
                    `SAD_ALWAYS_ARMED: always_armed <= reg_datai[0];
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


    integer c;
    reg trigger_r;
    always @(posedge adc_sampleclk) begin
        if (clear_status_adc || (armed_and_ready_adc && ~armed_and_ready_adc_r)) begin
            triggered <= 1'b0;
            num_triggers <= 0;
        end
        else if (trigger && ~trigger_r) begin
            triggered <= 1'b1;
            num_triggers <= num_triggers + 1;
        end

        // TODO: active check? would it be redundant?
        trigger <= 1'b0;
        trigger_r <= trigger;
        for (c = 0; c < pREF_SAMPLES; c = c + 1) begin
            if (individual_trigger[c] && ~(triggered && ~multiple_triggers)) 
                trigger <= 1'b1;
        end
    end


    cdc_simple U_armed_and_ready_cdc (
        .reset          (reset),
        .clk            (adc_sampleclk),
        .data_in        (armed_and_ready),
        .data_out       (armed_and_ready_adc),
        .data_out_r     (armed_and_ready_adc_r)
    );

    cdc_simple U_active_cdc (
        .reset          (reset),
        .clk            (adc_sampleclk),
        .data_in        (active),
        .data_out       (active_adc),
        .data_out_r     ()
    );


    wire [pMASTER_COUNTER_WIDTH-1:0] master_counter_top = pREF_SAMPLES-pSADS_PER_CYCLE;


    always @(posedge adc_sampleclk) begin
        adc_datain_r  <= adc_datain;
        datain_b      <= adc_datain;
        datain_a      <= adc_datain_r;
        datain_b_rpr  <=  {{(pSAD_COUNTER_WIDTH-pBITS_PER_SAMPLE){1'b0}}, datain_b};
        datain_b_rmr  <= -{{(pSAD_COUNTER_WIDTH-pBITS_PER_SAMPLE){1'b0}}, datain_b};
        datain_a_rpr  <=  {{(pSAD_COUNTER_WIDTH-pBITS_PER_SAMPLE){1'b0}}, datain_a};
        datain_a_rmr  <= -{{(pSAD_COUNTER_WIDTH-pBITS_PER_SAMPLE){1'b0}}, datain_a};
    end

    always @(posedge adc_sampleclk) begin
        // TODO: this condition is being used in several places, should declare a meaningful wire instead
        if ((armed_and_ready_adc || always_armed) && active_adc && ~xadc_error)
            if (master_counter_full == pREF_SAMPLES-1)
                master_counter_full <= 0;
            else
                master_counter_full <= master_counter_full + 1;
        else
            master_counter_full <= 0;
    end

    assign master_counter = {master_counter_full[pMASTER_COUNTER_WIDTH-1:1], 1'b0};
    assign tick_tock = master_counter_full[0];


    // heavy lifting part 1: per-**reference-sample** generated logic:
    genvar j;
    generate
        for (j = 0; j < pREF_SAMPLES; j = j + 1) begin: gen_per_refsample
            assign refsample[j] = refsamples[j*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE];

            always @(posedge adc_sampleclk) begin
                if ((armed_and_ready_adc || always_armed) && active_adc && ~xadc_error) begin
                    if (j > 0) ready2trigger[j] <= ready2trigger[j-1];
                    else if (master_counter == master_counter_top) ready2trigger[0] <= 1;

                    if (j == 0) resetter[j] <= resetter[pREF_SAMPLES-1];
                    else resetter[j] <= resetter[j-1];

                end

                else begin
                    ready2trigger[j] <= 0;
                    if (j == pREF_SAMPLES - pSADS_PER_CYCLE - 1) resetter[j] <= 1'b1;
                    else resetter[j] <= 1'b0;
                end

                if (j%2) begin
                    if (resetter[j])
                        sad_counter[j] <= counter_incr[j-1];
                    // TODO: this is not guaranteed to avoid overflow! need a better counter saturation scheme
                    else if (~tick_tock && ~sad_counter[j][pSAD_COUNTER_WIDTH-1]) // MSB of counter is used to indicate saturation
                        sad_counter[j] <= sad_counter[j] + counter_incr[j-1];
                end
                else begin
                    if (resetter[j])
                        sad_counter[j] <= counter_incr[j];
                    else if (tick_tock && ~sad_counter[j][pSAD_COUNTER_WIDTH-1]) // MSB of counter is used to indicate saturation
                        sad_counter[j] <= sad_counter[j] + counter_incr[j];
                end


                // and the triggers:
                if ((sad_counter[j] <= threshold) && resetter[j] && ready2trigger[j])
                    individual_trigger[j] <= 1'b1;
                else
                    individual_trigger[j] <= 1'b0;

            end
        end

    endgenerate


    // heavy lifting part 2: per-every-other-sample generated logic: (this is where we save logic c.f. sad.v)
    genvar i;
    generate 
        for (i = 0; i < pREF_SAMPLES; i = i + pSADS_PER_CYCLE) begin: gen_sad_counters
            always @(posedge adc_sampleclk) begin


                if (i == 0) begin
                    nextrefsample_a[i] <= refsample[master_counter];
                    nextrefsample_b[i] <= refsample[master_counter+1];
                    compare_en_a[i] <= refen[master_counter];
                    compare_en_b[i] <= refen[master_counter+1];
                end
                else begin
                    if (~tick_tock) begin
                        nextrefsample_a[i] <= nextrefsample_a[i-pSADS_PER_CYCLE];
                        nextrefsample_b[i] <= nextrefsample_b[i-pSADS_PER_CYCLE];
                        compare_en_a[i] <= compare_en_a[i-pSADS_PER_CYCLE];
                        compare_en_b[i] <= compare_en_b[i-pSADS_PER_CYCLE];
                    end
                end

                nextrefsample_ar[i] <= nextrefsample_a[i];
                nextrefsample_br[i] <= nextrefsample_b[i];
                compare_en_ar[i] <= compare_en_a[i];
                compare_en_br[i] <= compare_en_b[i];

                if (datain_b > nextrefsample_b[i])
                    decision_b[i] <= 1'b1;
                else
                    decision_b[i] <= 1'b0;

                if (datain_a > nextrefsample_a[i])
                    decision_a[i] <= 1'b1;
                else
                    decision_a[i] <= 1'b0;

                // Here is where the logic savings are (c.f. sad.v) since we have half the number of counter_incr registers:
                case ({decision_b[i], decision_a[i]})
                    2'b00: counter_incr[i] <= (compare_en_br[i]? (datain_b_rmr + nextrefsample_br[i]) : 0) + (compare_en_ar[i]? (datain_a_rmr + nextrefsample_ar[i]) : 0);
                    2'b01: counter_incr[i] <= (compare_en_br[i]? (datain_b_rmr + nextrefsample_br[i]) : 0) + (compare_en_ar[i]? (datain_a_rpr - nextrefsample_ar[i]) : 0);
                    2'b10: counter_incr[i] <= (compare_en_br[i]? (datain_b_rpr - nextrefsample_br[i]) : 0) + (compare_en_ar[i]? (datain_a_rmr + nextrefsample_ar[i]) : 0);
                    2'b11: counter_incr[i] <= (compare_en_br[i]? (datain_b_rpr - nextrefsample_br[i]) : 0) + (compare_en_ar[i]? (datain_a_rpr - nextrefsample_ar[i]) : 0);
                endcase

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

    wire decision_a4 = decision_a[4];
    wire decision_a28 = decision_a[28];
    wire decision_b28 = decision_b[28];

    wire ready2trigger10 = ready2trigger[10];
    wire ready2trigger11 = ready2trigger[11];
    wire ready2trigger12 = ready2trigger[12];
    wire ready2trigger31 = ready2trigger[31];
    wire resetter31 = resetter[31];
    wire individual_trigger31 = individual_trigger[31];

    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_a0 = nextrefsample_a[0];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_a2 = nextrefsample_a[2];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_a4 = nextrefsample_a[4];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_a6 = nextrefsample_a[6];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_a10 = nextrefsample_a[10];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_a20 = nextrefsample_a[20];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_a28 = nextrefsample_a[28];

    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_b0 = nextrefsample_b[0];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_b2 = nextrefsample_b[2];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_b4 = nextrefsample_b[4];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_b6 = nextrefsample_b[6];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_b10 = nextrefsample_b[10];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_b20 = nextrefsample_b[20];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_b28 = nextrefsample_b[28];

    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_ar0 = nextrefsample_ar[0];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_ar2 = nextrefsample_ar[2];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_ar4 = nextrefsample_ar[4];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_ar28 = nextrefsample_ar[28];

    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_br0 = nextrefsample_br[0];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_br2 = nextrefsample_br[2];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_br4 = nextrefsample_br[4];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_br28 = nextrefsample_br[28];

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

    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_0  = counter_incr[0];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_2  = counter_incr[2];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_4  = counter_incr[4];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_6  = counter_incr[6];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_8  = counter_incr[8];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_10 = counter_incr[10];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_20 = counter_incr[20];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_22 = counter_incr[22];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_28 = counter_incr[28];

    wire ready2trigger_debug = ready2trigger[pREF_SAMPLES-2];

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

    wire [31:0] resetter_debug = {resetter[31],
                                  resetter[30],
                                  resetter[29],
                                  resetter[28],
                                  resetter[27],
                                  resetter[26],
                                  resetter[25],
                                  resetter[24],
                                  resetter[23],
                                  resetter[22],
                                  resetter[21],
                                  resetter[20],
                                  resetter[19],
                                  resetter[18],
                                  resetter[17],
                                  resetter[16],
                                  resetter[15],
                                  resetter[14],
                                  resetter[13],
                                  resetter[12],
                                  resetter[11],
                                  resetter[10],
                                  resetter[9],
                                  resetter[8],
                                  resetter[7],
                                  resetter[6],
                                  resetter[5],
                                  resetter[4],
                                  resetter[3],
                                  resetter[2],
                                  resetter[1],
                                  resetter[0]};



    // verilator lint_on UNUSED
    // verilator lint_on WIDTH

   `ifdef ILA_SAD_X2
       ila_sad_x2 U_ila_sad (
          .clk            (adc_sampleclk),
          .probe0         (slow_clk_even),              // 1
          .probe1         (slow_clk_odd),               // 1
          .probe2         (trigger),                    // 1
          .probe3         (triggered),                  // 1
          .probe4         (individual_trigger_debug),   // 32
          .probe5         (sad_counter0),               // 8
          .probe6         (sad_counter1),               // 8
          .probe7         (sad_counter2),               // 8
          .probe8         (sad_counter3),               // 8
          .probe9         (sad_counter4),               // 8
          .probe10        (sad_counter5),               // 8
          .probe11        (sad_counter6),               // 8
          .probe12        (sad_counter7),               // 8
          .probe13        (counter_incr_a0),            // 8
          .probe14        (counter_incr_a1),            // 8
          .probe15        (counter_incr_a2),            // 8
          .probe16        (counter_incr_a3),            // 8
          .probe17        (counter_incr_b0),            // 8
          .probe18        (counter_incr_b1),            // 8
          .probe19        (counter_incr_b2),            // 8
          .probe20        (counter_incr_b3),            // 8
          .probe21        (adc_datain),                 // 8
          .probe22        (adc_datain_r),               // 8
          .probe23        (adc_datain_r2),              // 8
          .probe24        (adc_datain_even_r),          // 8
          .probe25        (adc_datain_even_r2),         // 8
          .probe26        (adc_datain_odd_r),           // 8
          .probe27        (adc_datain_odd_r2)           // 8
      );

       ila_sad_x2_slowclk U_ila_sad_even (
          .clk            (slow_clk_even),              // 1
          .probe0         (trigger),                    // 1
          .probe1         (triggered),                  // 1
          .probe2         (individual_trigger_debug),   // 32
          .probe3         (sad_counter0),               // 8
          .probe4         (sad_counter2),               // 8
          .probe5         (sad_counter4),               // 8
          .probe6         (sad_counter6),               // 8
          .probe7         (counter_incr_a0),            // 8
          .probe8         (counter_incr_a2),            // 8
          .probe9         (counter_incr_b0),            // 8
          .probe10        (counter_incr_b2),            // 8
          .probe11        (adc_datain_even_r),          // 8
          .probe12        (adc_datain_even_r2)          // 8
      );

       ila_sad_x2_slowclk U_ila_sad_odd (
          .clk            (slow_clk_odd),               // 1
          .probe0         (trigger),                    // 1
          .probe1         (triggered),                  // 1
          .probe2         (individual_trigger_debug),   // 32
          .probe3         (sad_counter0),               // 8
          .probe4         (sad_counter2),               // 8
          .probe5         (sad_counter4),               // 8
          .probe6         (sad_counter6),               // 8
          .probe7         (counter_incr_a0),            // 8
          .probe8         (counter_incr_a2),            // 8
          .probe9         (counter_incr_b0),            // 8
          .probe10        (counter_incr_b2),            // 8
          .probe11        (adc_datain_odd_r),           // 8
          .probe12        (adc_datain_odd_r2)           // 8
      );


   `endif

endmodule
`default_nettype wire
