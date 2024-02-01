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

module sad_x2_slowclock #(
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
    input wire          slow_clk_even,
    input wire          slow_clk_odd,
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

    reg  trigger_even;
    reg  trigger_odd;
    reg  triggered;
    reg  triggered_even;
    reg  triggered_odd;
    reg [15:0] num_triggers;
    reg clear_status;
    reg clear_status_r;
    wire clear_status_adc;
    wire clear_status_adc_even;
    wire clear_status_adc_odd;

    reg always_armed;
    reg multiple_triggers;
    reg [pREF_SAMPLES*pBITS_PER_SAMPLE-1:0] refsamples;
    reg [pREF_SAMPLES-1:0] refen = {pREF_SAMPLES{1'b1}}; // all samples enabled by default
    reg [pREF_SAMPLES-1:0] compare_en_a, compare_en_b;
    reg [pSAD_COUNTER_WIDTH-1:0] threshold;
    reg [pMASTER_COUNTER_WIDTH-1:0] master_counter_even, master_counter_odd;
    reg resetter_even [0:pREF_SAMPLES-1];
    reg resetter_odd  [0:pREF_SAMPLES-1];

    reg individual_trigger [0:pREF_SAMPLES-1];
    reg [pSAD_COUNTER_WIDTH-1:0] sad_counter [0:pREF_SAMPLES-1];
    reg [pSAD_COUNTER_WIDTH-1:0] counter_incr_a [0:pREF_SAMPLES-1];
    reg [pSAD_COUNTER_WIDTH-1:0] counter_incr_b [0:pREF_SAMPLES-1];

    wire armed_and_ready_adc;
    wire armed_and_ready_adc_r;
    wire armed_and_ready_adc_even;
    wire armed_and_ready_adc_even_r;
    wire armed_and_ready_adc_odd;
    wire armed_and_ready_adc_odd_r;

    wire active_adc_even;
    wire active_adc_odd;

    reg ready2trigger_even [0:pREF_SAMPLES-1];
    reg ready2trigger_odd  [0:pREF_SAMPLES-1];
    //reg ready2trigger_pre;
    //reg ready2trigger;

    reg decision_a [0:pREF_SAMPLES-1];
    reg decision_b [0:pREF_SAMPLES-1];
    reg [pBITS_PER_SAMPLE-1:0]  nextrefsample_a [0:pREF_SAMPLES-1];
    reg [pBITS_PER_SAMPLE-1:0]  nextrefsample_b [0:pREF_SAMPLES-1];
    reg [pBITS_PER_SAMPLE-1:0]  nextrefsample_r_a [0:pREF_SAMPLES-1];
    reg [pBITS_PER_SAMPLE-1:0]  nextrefsample_r_b [0:pREF_SAMPLES-1];
    wire [pBITS_PER_SAMPLE-1:0]  refsample [0:pREF_SAMPLES-1];
    reg [pBITS_PER_SAMPLE-1:0] adc_datain_r, adc_datain_r2;

    reg [pBITS_PER_SAMPLE-1:0] adc_datain_even_r;
    reg [pBITS_PER_SAMPLE-1:0] adc_datain_even_r2;

    reg [pBITS_PER_SAMPLE-1:0] adc_datain_odd_r;
    reg [pBITS_PER_SAMPLE-1:0] adc_datain_odd_r2;

    // sign extension:
    wire [pSAD_COUNTER_WIDTH-1:0] wadc_datain_even_rpr  =  {{(pSAD_COUNTER_WIDTH-pBITS_PER_SAMPLE){1'b0}}, adc_datain_even_r};
    wire [pSAD_COUNTER_WIDTH-1:0] wadc_datain_even_rmr  = -{{(pSAD_COUNTER_WIDTH-pBITS_PER_SAMPLE){1'b0}}, adc_datain_even_r};
    wire [pSAD_COUNTER_WIDTH-1:0] wadc_datain_even_rpr2 =  {{(pSAD_COUNTER_WIDTH-pBITS_PER_SAMPLE){1'b0}}, adc_datain_even_r2};
    wire [pSAD_COUNTER_WIDTH-1:0] wadc_datain_even_rmr2 = -{{(pSAD_COUNTER_WIDTH-pBITS_PER_SAMPLE){1'b0}}, adc_datain_even_r2};

    wire [pSAD_COUNTER_WIDTH-1:0] wadc_datain_odd_rpr  =  {{(pSAD_COUNTER_WIDTH-pBITS_PER_SAMPLE){1'b0}}, adc_datain_odd_r};
    wire [pSAD_COUNTER_WIDTH-1:0] wadc_datain_odd_rmr  = -{{(pSAD_COUNTER_WIDTH-pBITS_PER_SAMPLE){1'b0}}, adc_datain_odd_r};
    wire [pSAD_COUNTER_WIDTH-1:0] wadc_datain_odd_rpr2 =  {{(pSAD_COUNTER_WIDTH-pBITS_PER_SAMPLE){1'b0}}, adc_datain_odd_r2};
    wire [pSAD_COUNTER_WIDTH-1:0] wadc_datain_odd_rmr2 = -{{(pSAD_COUNTER_WIDTH-pBITS_PER_SAMPLE){1'b0}}, adc_datain_odd_r2};



    wire [23:0] status_reg = {num_triggers, 7'b0, triggered};
    reg sad_short;
    wire [31:0] wide_threshold_reg = {{(32-pSAD_COUNTER_WIDTH){1'b0}}, threshold}; // having a variable-width register isn't very convenient for Python
    reg [7:0] refbase;

    // These are a property of this module; used here to make sure Python
    // knows what it's talking to, in case there may be different SAD modules
    // used in different targets or builds.
    // Format: 2 MSB = version code (00: sad.v, 01: sad_x2_slowclock.v)
    //         6 LSB = trigger latency
    wire [7:0] version_bits = {2'b01, 6'd12};
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
                `SAD_SHORT: reg_datao = {7'b0, sad_short};
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
            sad_short <= 0;
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
                    `SAD_SHORT: sad_short <= reg_datai[0];
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

   cdc_pulse U_clear_status_cdc_even (
      .reset_i       (reset),
      .src_clk       (clk_usb),
      .src_pulse     (clear_status && ~clear_status_r),
      .dst_clk       (slow_clk_even),
      .dst_pulse     (clear_status_adc_even)
   );

   cdc_pulse U_clear_status_cdc_odd (
      .reset_i       (reset),
      .src_clk       (clk_usb),
      .src_pulse     (clear_status && ~clear_status_r),
      .dst_clk       (slow_clk_odd),
      .dst_pulse     (clear_status_adc_odd)
   );

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

    cdc_simple U_armed_and_ready_cdc_even (
        .reset          (reset),
        .clk            (slow_clk_even),
        .data_in        (armed_and_ready),
        .data_out       (armed_and_ready_adc_even),
        .data_out_r     (armed_and_ready_adc_even_r)
    );

    cdc_simple U_armed_and_ready_cdc_odd (
        .reset          (reset),
        .clk            (slow_clk_odd),
        .data_in        (armed_and_ready),
        .data_out       (armed_and_ready_adc_odd),
        .data_out_r     (armed_and_ready_adc_odd_r)
    );

    cdc_simple U_active_cdc_even (
        .reset          (reset),
        .clk            (slow_clk_even),
        .data_in        (active),
        .data_out       (active_adc_even),
        .data_out_r     ()
    );

    cdc_simple U_active_cdc_odd (
        .reset          (reset),
        .clk            (slow_clk_odd),
        .data_in        (active),
        .data_out       (active_adc_odd),
        .data_out_r     ()
    );


    wire [pMASTER_COUNTER_WIDTH-1:0] master_counter_top = (sad_short)? pREF_SAMPLES/2-pSADS_PER_CYCLE : pREF_SAMPLES-pSADS_PER_CYCLE;


    always @(posedge adc_sampleclk) begin
        adc_datain_r    <= adc_datain;
        adc_datain_r2   <= adc_datain_r;
    end

    always @(posedge slow_clk_even) begin
        adc_datain_even_r    <= adc_datain_r;
        adc_datain_even_r2   <= adc_datain_r2;
    end

    always @(posedge slow_clk_odd) begin
        adc_datain_odd_r    <= adc_datain_r;
        adc_datain_odd_r2   <= adc_datain_r2;
    end


    // instantiate counters and do most of the heavy lifting...
    // First half of counters, on even clock:
    genvar i;
    generate 
        for (i = 0; i < pREF_SAMPLES; i = i + pSADS_PER_CYCLE) begin: gen_sad_even_counters
            assign refsample[i] = refsamples[i*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE];
            always @(posedge slow_clk_even) begin
                if ((armed_and_ready_adc_even || always_armed) && active_adc_even && ~xadc_error) begin
                    if (i > 0) ready2trigger_even[i] <= ready2trigger_even[i-pSADS_PER_CYCLE];
                    else if (master_counter_even == master_counter_top) ready2trigger_even[0] <= 1;
                    if (i == 0) resetter_even[i] <= resetter_even[pREF_SAMPLES-pSADS_PER_CYCLE];
                    else resetter_even[i] <= resetter_even[i-pSADS_PER_CYCLE];
                    if (i == 0) begin
                        if (master_counter_even == master_counter_top)
                            master_counter_even <= 0;
                        else 
                            master_counter_even <= master_counter_even + pSADS_PER_CYCLE;
                    end
                end
                else begin
                    if (i == 0) master_counter_even <= 0;
                    ready2trigger_even[i] <= 0;
                    if (sad_short) begin
                        // TODO-note: this seems to work for pREF_SAMPLES >= 32;
                        if ((i == pREF_SAMPLES-(pSADS_PER_CYCLE*2)) ||
                            (i == pREF_SAMPLES/2-(pSADS_PER_CYCLE*2))) resetter_even[i] <= 1'b1;
                        else resetter_even[i] <= 1'b0;
                    end
                    else begin
                        // TODO-note: there seems to be an issue when pREF_SAMPLES isn't a power of 2
                        if (i == pREF_SAMPLES - (pSADS_PER_CYCLE*2)) resetter_even[i] <= 1'b1;
                        else resetter_even[i] <= 1'b0;
                    end

                end

                if (i == 0) begin
                    nextrefsample_a[i] <= refsample[master_counter_even+1]; // don't need to worry about wrap-around (I think!)
                    nextrefsample_b[i] <= refsample[master_counter_even];
                    compare_en_a[i] <= refen[master_counter_even+1];
                    compare_en_b[i] <= refen[master_counter_even];
                end
                else begin
                    nextrefsample_a[i] <= nextrefsample_a[i-pSADS_PER_CYCLE];
                    nextrefsample_b[i] <= nextrefsample_b[i-pSADS_PER_CYCLE];
                    compare_en_a[i] <= compare_en_a[i-pSADS_PER_CYCLE];
                    compare_en_b[i] <= compare_en_b[i-pSADS_PER_CYCLE];
                end

                nextrefsample_r_a[i] <= nextrefsample_a[i];
                nextrefsample_r_b[i] <= nextrefsample_b[i];


                if (compare_en_b[i] == 0) // NOTE: yep, _a / _b are a bit mixed up here! TODO-fixit
                    counter_incr_a[i] <= 0;
                else if (adc_datain_even_r2 > nextrefsample_b[i])
                    counter_incr_a[i] <= wadc_datain_even_rpr2 - nextrefsample_b[i];
                else
                    counter_incr_a[i] <= wadc_datain_even_rmr2 + nextrefsample_b[i];

                if (compare_en_a[i] == 0)
                    counter_incr_b[i] <= 0;
                else if (adc_datain_even_r > nextrefsample_a[i])
                    counter_incr_b[i] <= wadc_datain_even_rpr - nextrefsample_a[i];
                else
                    counter_incr_b[i] <= wadc_datain_even_rmr + nextrefsample_a[i];


                // finally we get to the actual SAD counters:
                if (resetter_even[i])
                    sad_counter[i] <= counter_incr_a[i] + counter_incr_b[i];
                else if (~sad_counter[i][pSAD_COUNTER_WIDTH-1]) // MSB of counter is used to indicate saturation
                    sad_counter[i] <= sad_counter[i] + counter_incr_a[i] + counter_incr_b[i];

                // and the triggers:
                if ((sad_counter[i] <= threshold) && resetter_even[i] && ready2trigger_even[i])
                    individual_trigger[i] <= 1'b1;
                else
                    individual_trigger[i] <= 1'b0;

            end

        end
    endgenerate

    // Second half of counters, on odd clock:
    genvar j;
    generate 
        for (j = 1; j < pREF_SAMPLES-0; j = j + pSADS_PER_CYCLE) begin: gen_sad_odd_counters
            assign refsample[j] = refsamples[j*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE];
            always @(posedge slow_clk_odd) begin
                if ((armed_and_ready_adc_odd || always_armed) && active_adc_odd && ~xadc_error) begin
                    if (j > 1) ready2trigger_odd[j] <= ready2trigger_odd[j-pSADS_PER_CYCLE];
                    else if (master_counter_odd >= master_counter_top) ready2trigger_odd[1] <= 1;

                    if (j == 1) resetter_odd[j] <= resetter_odd[pREF_SAMPLES-1];
                    else resetter_odd[j] <= resetter_odd[j-pSADS_PER_CYCLE];

                    if (j == 1) begin
                        if (master_counter_odd == master_counter_top)
                            master_counter_odd <= 0;
                        else 
                            master_counter_odd <= master_counter_odd + pSADS_PER_CYCLE;
                    end
                end
                else begin
                    if (j == 1) master_counter_odd <= 0;
                    ready2trigger_odd[j] <= 0;
                    // NOTE: see comments in corresponding "even" code block
                    if (sad_short) begin
                        if ((j == pREF_SAMPLES-(pSADS_PER_CYCLE*2 - 1)) || 
                            (j == pREF_SAMPLES/2-(pSADS_PER_CYCLE*2 - 1))) resetter_odd[j] <= 1'b1;
                        else resetter_odd[j] <= 1'b0;
                    end
                    else begin
                        if (j == pREF_SAMPLES - (pSADS_PER_CYCLE*2 - 1)) resetter_odd[j] <= 1'b1;
                        else resetter_odd[j] <= 1'b0;
                    end

                end

                if (j == 1) begin
                    nextrefsample_a[j] <= refsample[master_counter_odd+1]; // don't need to worry about wrap-around (I think!)
                    nextrefsample_b[j] <= refsample[master_counter_odd];
                    compare_en_a[j] <= refen[master_counter_odd+1];
                    compare_en_b[j] <= refen[master_counter_odd];
                end
                else begin
                    nextrefsample_a[j] <= nextrefsample_a[j-pSADS_PER_CYCLE];
                    nextrefsample_b[j] <= nextrefsample_b[j-pSADS_PER_CYCLE];
                    compare_en_a[j] <= compare_en_a[j-pSADS_PER_CYCLE];
                    compare_en_b[j] <= compare_en_b[j-pSADS_PER_CYCLE];
                end

                nextrefsample_r_a[j] <= nextrefsample_a[j];
                nextrefsample_r_b[j] <= nextrefsample_b[j];


                if (compare_en_b[j] == 0)
                    counter_incr_a[j] <= 0;
                else if (adc_datain_odd_r2 > nextrefsample_b[j])
                    counter_incr_a[j] <= wadc_datain_odd_rpr2 - nextrefsample_b[j];
                else
                    counter_incr_a[j] <= wadc_datain_odd_rmr2 + nextrefsample_b[j];

                if (compare_en_a[j] == 0)
                    counter_incr_b[j] <= 0;
                else if (adc_datain_odd_r > nextrefsample_a[j])
                    counter_incr_b[j] <= wadc_datain_odd_rpr - nextrefsample_a[j];
                else
                    counter_incr_b[j] <= wadc_datain_odd_rmr + nextrefsample_a[j];


                // finally we get to the actual SAD counters:
                if (resetter_odd[j])
                    sad_counter[j] <= counter_incr_a[j] + counter_incr_b[j];
                else if (~sad_counter[j][pSAD_COUNTER_WIDTH-1]) // MSB of counter is used to indicate saturation
                    sad_counter[j] <= sad_counter[j] + counter_incr_a[j] + counter_incr_b[j];

                // and the triggers:
                if ((sad_counter[j] <= threshold) && resetter_odd[j] && ready2trigger_odd[j])
                    individual_trigger[j] <= 1'b1;
                else
                    individual_trigger[j] <= 1'b0;

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

    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_a0 = nextrefsample_a[0];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_a1 = nextrefsample_a[1];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_a2 = nextrefsample_a[2];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_a3 = nextrefsample_a[3];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_a4 = nextrefsample_a[4];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_a5 = nextrefsample_a[5];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_a6 = nextrefsample_a[6];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_a7 = nextrefsample_a[7];

    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_b0 = nextrefsample_b[0];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_b1 = nextrefsample_b[1];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_b2 = nextrefsample_b[2];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_b3 = nextrefsample_b[3];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_b4 = nextrefsample_b[4];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_b5 = nextrefsample_b[5];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_b6 = nextrefsample_b[6];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_b7 = nextrefsample_b[7];

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

    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_a0 = counter_incr_a[0];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_a1 = counter_incr_a[1];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_a2 = counter_incr_a[2];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_a3 = counter_incr_a[3];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_a4 = counter_incr_a[4];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_a5 = counter_incr_a[5];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_a6 = counter_incr_a[6];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_a7 = counter_incr_a[7];

    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_b0 = counter_incr_b[0];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_b1 = counter_incr_b[1];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_b2 = counter_incr_b[2];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_b3 = counter_incr_b[3];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_b4 = counter_incr_b[4];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_b5 = counter_incr_b[5];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_b6 = counter_incr_b[6];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_b7 = counter_incr_b[7];

    wire ready2trigger_debug = ready2trigger_even[pREF_SAMPLES-2];

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
