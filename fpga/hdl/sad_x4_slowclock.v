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

module sad_x4_slowclock #(
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
    input wire          slow_clk1,
    input wire          slow_clk2,
    input wire          slow_clk3,
    input wire          slow_clk4,
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
    output wire         trigger
);

    localparam pSADS_PER_CYCLE = 4;
    localparam pMASTER_COUNTER_WIDTH = (pREF_SAMPLES <= 32)?  5 :
                                       (pREF_SAMPLES <= 64)?  6 :
                                       (pREF_SAMPLES <= 128)? 7 :
                                       (pREF_SAMPLES <= 256)? 8 :
                                       (pREF_SAMPLES <= 512)? 9 :
                                       (pREF_SAMPLES <= 1024)? 10 : 11;

    reg  triggered;
    reg  trigger1;
    reg  trigger2;
    reg  trigger3;
    reg  trigger4;
    reg [15:0] num_triggers;
    reg clear_status;
    reg clear_status_r;
    wire clear_status_adc;

    reg always_armed;
    reg multiple_triggers;
    reg [pREF_SAMPLES*pBITS_PER_SAMPLE-1:0] refsamples;
    reg [pREF_SAMPLES-1:0] refen = {pREF_SAMPLES{1'b1}}; // all samples enabled by default
    reg [pREF_SAMPLES-1:0] compare_en_a;
    reg [pREF_SAMPLES-1:0] compare_en_b;
    reg [pREF_SAMPLES-1:0] compare_en_c;
    reg [pREF_SAMPLES-1:0] compare_en_d;
    reg [pSAD_COUNTER_WIDTH-1:0] threshold;
    reg [pMASTER_COUNTER_WIDTH-1:0] master_counter1;
    reg [pMASTER_COUNTER_WIDTH-1:0] master_counter2;
    reg [pMASTER_COUNTER_WIDTH-1:0] master_counter3;
    reg [pMASTER_COUNTER_WIDTH-1:0] master_counter4;
    reg resetter1 [0:pREF_SAMPLES-1];
    reg resetter2 [0:pREF_SAMPLES-1];
    reg resetter3 [0:pREF_SAMPLES-1];
    reg resetter4 [0:pREF_SAMPLES-1];

    reg individual_trigger [0:pREF_SAMPLES-1];
    reg [pSAD_COUNTER_WIDTH-1:0] sad_counter [0:pREF_SAMPLES-1];
    reg [pBITS_PER_SAMPLE-1:0] counter_incr_a [0:pREF_SAMPLES-1];
    reg [pBITS_PER_SAMPLE-1:0] counter_incr_b [0:pREF_SAMPLES-1];
    reg [pBITS_PER_SAMPLE-1:0] counter_incr_c [0:pREF_SAMPLES-1];
    reg [pBITS_PER_SAMPLE-1:0] counter_incr_d [0:pREF_SAMPLES-1];

    wire armed_and_ready_adc;
    wire armed_and_ready_adc_r;
    wire armed_and_ready_adc1;
    wire armed_and_ready_adc2;
    wire armed_and_ready_adc3;
    wire armed_and_ready_adc4;

    wire active_adc1;
    wire active_adc2;
    wire active_adc3;
    wire active_adc4;

    reg ready2trigger1 [0:pREF_SAMPLES-1];
    reg ready2trigger2 [0:pREF_SAMPLES-1];
    reg ready2trigger3 [0:pREF_SAMPLES-1];
    reg ready2trigger4 [0:pREF_SAMPLES-1];
    //reg ready2trigger_pre;
    //reg ready2trigger;

    reg [pBITS_PER_SAMPLE-1:0]  nextrefsample_a [0:pREF_SAMPLES-1];
    reg [pBITS_PER_SAMPLE-1:0]  nextrefsample_b [0:pREF_SAMPLES-1];
    reg [pBITS_PER_SAMPLE-1:0]  nextrefsample_c [0:pREF_SAMPLES-1];
    reg [pBITS_PER_SAMPLE-1:0]  nextrefsample_d [0:pREF_SAMPLES-1];

    wire [pBITS_PER_SAMPLE-1:0]  refsample [0:pREF_SAMPLES-1];
    reg [pBITS_PER_SAMPLE-1:0] adc_datain_r, adc_datain_r2, adc_datain_r3, adc_datain_r4;

    reg [pBITS_PER_SAMPLE-1:0] adc_datain1_r;
    reg [pBITS_PER_SAMPLE-1:0] adc_datain1_r2;
    reg [pBITS_PER_SAMPLE-1:0] adc_datain1_r3;
    reg [pBITS_PER_SAMPLE-1:0] adc_datain1_r4;

    reg [pBITS_PER_SAMPLE-1:0] adc_datain2_r;
    reg [pBITS_PER_SAMPLE-1:0] adc_datain2_r2;
    reg [pBITS_PER_SAMPLE-1:0] adc_datain2_r3;
    reg [pBITS_PER_SAMPLE-1:0] adc_datain2_r4;

    reg [pBITS_PER_SAMPLE-1:0] adc_datain3_r;
    reg [pBITS_PER_SAMPLE-1:0] adc_datain3_r2;
    reg [pBITS_PER_SAMPLE-1:0] adc_datain3_r3;
    reg [pBITS_PER_SAMPLE-1:0] adc_datain3_r4;

    reg [pBITS_PER_SAMPLE-1:0] adc_datain4_r;
    reg [pBITS_PER_SAMPLE-1:0] adc_datain4_r2;
    reg [pBITS_PER_SAMPLE-1:0] adc_datain4_r3;
    reg [pBITS_PER_SAMPLE-1:0] adc_datain4_r4;


    // sign extension:
    wire [pBITS_PER_SAMPLE-1:0] wadc_datain1_rpr  =  adc_datain1_r;
    wire [pBITS_PER_SAMPLE-1:0] wadc_datain1_rmr  = -adc_datain1_r;
    wire [pBITS_PER_SAMPLE-1:0] wadc_datain1_rpr2 =  adc_datain1_r2;
    wire [pBITS_PER_SAMPLE-1:0] wadc_datain1_rmr2 = -adc_datain1_r2;
    wire [pBITS_PER_SAMPLE-1:0] wadc_datain1_rpr3 =  adc_datain1_r3;
    wire [pBITS_PER_SAMPLE-1:0] wadc_datain1_rmr3 = -adc_datain1_r3;
    wire [pBITS_PER_SAMPLE-1:0] wadc_datain1_rpr4 =  adc_datain1_r4;
    wire [pBITS_PER_SAMPLE-1:0] wadc_datain1_rmr4 = -adc_datain1_r4;

    wire [pBITS_PER_SAMPLE-1:0] wadc_datain2_rpr  =  adc_datain2_r;
    wire [pBITS_PER_SAMPLE-1:0] wadc_datain2_rmr  = -adc_datain2_r;
    wire [pBITS_PER_SAMPLE-1:0] wadc_datain2_rpr2 =  adc_datain2_r2;
    wire [pBITS_PER_SAMPLE-1:0] wadc_datain2_rmr2 = -adc_datain2_r2;
    wire [pBITS_PER_SAMPLE-1:0] wadc_datain2_rpr3 =  adc_datain2_r3;
    wire [pBITS_PER_SAMPLE-1:0] wadc_datain2_rmr3 = -adc_datain2_r3;
    wire [pBITS_PER_SAMPLE-1:0] wadc_datain2_rpr4 =  adc_datain2_r4;
    wire [pBITS_PER_SAMPLE-1:0] wadc_datain2_rmr4 = -adc_datain2_r4;

    wire [pBITS_PER_SAMPLE-1:0] wadc_datain3_rpr  =  adc_datain3_r;
    wire [pBITS_PER_SAMPLE-1:0] wadc_datain3_rmr  = -adc_datain3_r;
    wire [pBITS_PER_SAMPLE-1:0] wadc_datain3_rpr2 =  adc_datain3_r2;
    wire [pBITS_PER_SAMPLE-1:0] wadc_datain3_rmr2 = -adc_datain3_r2;
    wire [pBITS_PER_SAMPLE-1:0] wadc_datain3_rpr3 =  adc_datain3_r3;
    wire [pBITS_PER_SAMPLE-1:0] wadc_datain3_rmr3 = -adc_datain3_r3;
    wire [pBITS_PER_SAMPLE-1:0] wadc_datain3_rpr4 =  adc_datain3_r4;
    wire [pBITS_PER_SAMPLE-1:0] wadc_datain3_rmr4 = -adc_datain3_r4;

    wire [pBITS_PER_SAMPLE-1:0] wadc_datain4_rpr  =  adc_datain4_r;
    wire [pBITS_PER_SAMPLE-1:0] wadc_datain4_rmr  = -adc_datain4_r;
    wire [pBITS_PER_SAMPLE-1:0] wadc_datain4_rpr2 =  adc_datain4_r2;
    wire [pBITS_PER_SAMPLE-1:0] wadc_datain4_rmr2 = -adc_datain4_r2;
    wire [pBITS_PER_SAMPLE-1:0] wadc_datain4_rpr3 =  adc_datain4_r3;
    wire [pBITS_PER_SAMPLE-1:0] wadc_datain4_rmr3 = -adc_datain4_r3;
    wire [pBITS_PER_SAMPLE-1:0] wadc_datain4_rpr4 =  adc_datain4_r4;
    wire [pBITS_PER_SAMPLE-1:0] wadc_datain4_rmr4 = -adc_datain4_r4;


`ifdef HIPERF
    wire [23:0] status_reg = 24'b0;
`else
    wire [23:0] status_reg = {num_triggers, 7'b0, triggered};
`endif
    wire [31:0] wide_threshold_reg = {{(32-pSAD_COUNTER_WIDTH){1'b0}}, threshold}; // having a variable-width register isn't very convenient for Python
    reg [7:0] refbase;

    // These are a property of this module; used here to make sure Python
    // knows what it's talking to, in case there may be different SAD modules
    // used in different targets or builds.
    // Format: 2 MSB = version code (00: sad.v, 01: sad_x2_slowclock.v, 10: sad_x4_slowclock.v)
    //         6 LSB = trigger latency
    wire [7:0] version_bits = {2'b10, 6'd18}; // NOTE: latency not verified on-target (yet)
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
                `SAD_ALWAYS_ARMED: reg_datao = {7'b0, always_armed};
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
                `ifndef HIPERF
                    `SAD_MULTIPLE_TRIGGERS: multiple_triggers <= reg_datai[0];
                `endif
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

    integer c, d, e, f;

    always @(posedge slow_clk1) begin
        trigger1 <= 1'b0;
        for (c = 0; c < pREF_SAMPLES; c = c + pSADS_PER_CYCLE) begin
            if (individual_trigger[c])
                trigger1 <= 1'b1;
        end
    end

    always @(posedge slow_clk2) begin
        trigger2 <= 1'b0;
        for (d = 1; d < pREF_SAMPLES; d = d + pSADS_PER_CYCLE) begin
            if (individual_trigger[d])
                trigger2 <= 1'b1;
        end
    end

    always @(posedge slow_clk3) begin
        trigger3 <= 1'b0;
        for (e = 2; e < pREF_SAMPLES; e = e + pSADS_PER_CYCLE) begin
            if (individual_trigger[e])
                trigger3 <= 1'b1;
        end
    end

    always @(posedge slow_clk4) begin
        trigger4 <= 1'b0;
        for (f = 3; f < pREF_SAMPLES; f = f + pSADS_PER_CYCLE) begin
            if (individual_trigger[f])
                trigger4 <= 1'b1;
        end
    end


    assign trigger = trigger1 || trigger2 || trigger3 || trigger4;


    cdc_simple U_armed_and_ready_cdc (
        .reset          (reset),
        .clk            (adc_sampleclk),
        .data_in        (armed_and_ready),
        .data_out       (armed_and_ready_adc),
        .data_out_r     (armed_and_ready_adc_r)
    );

    cdc_simple U_armed_and_ready_cdc1 (
        .reset          (reset),
        .clk            (slow_clk1),
        .data_in        (armed_and_ready),
        .data_out       (armed_and_ready_adc1),
        .data_out_r     ()
    );

    cdc_simple U_armed_and_ready_cdc2 (
        .reset          (reset),
        .clk            (slow_clk2),
        .data_in        (armed_and_ready),
        .data_out       (armed_and_ready_adc2),
        .data_out_r     ()
    );

    cdc_simple U_armed_and_ready_cdc3 (
        .reset          (reset),
        .clk            (slow_clk3),
        .data_in        (armed_and_ready),
        .data_out       (armed_and_ready_adc3),
        .data_out_r     ()
    );

    cdc_simple U_armed_and_ready_cdc4 (
        .reset          (reset),
        .clk            (slow_clk4),
        .data_in        (armed_and_ready),
        .data_out       (armed_and_ready_adc4),
        .data_out_r     ()
    );



    cdc_simple U_active_cdc1 (
        .reset          (reset),
        .clk            (slow_clk1),
        .data_in        (active),
        .data_out       (active_adc1),
        .data_out_r     ()
    );

    cdc_simple U_active_cdc2 (
        .reset          (reset),
        .clk            (slow_clk2),
        .data_in        (active),
        .data_out       (active_adc2),
        .data_out_r     ()
    );

    cdc_simple U_active_cdc3 (
        .reset          (reset),
        .clk            (slow_clk3),
        .data_in        (active),
        .data_out       (active_adc3),
        .data_out_r     ()
    );

    cdc_simple U_active_cdc4 (
        .reset          (reset),
        .clk            (slow_clk4),
        .data_in        (active),
        .data_out       (active_adc4),
        .data_out_r     ()
    );


    wire [pMASTER_COUNTER_WIDTH-1:0] master_counter_top = pREF_SAMPLES-pSADS_PER_CYCLE;


    always @(posedge adc_sampleclk) begin
        adc_datain_r    <= adc_datain;
        adc_datain_r2   <= adc_datain_r;
        adc_datain_r3   <= adc_datain_r2;
        adc_datain_r4   <= adc_datain_r3;
    end

    always @(posedge slow_clk1) begin
        adc_datain1_r    <= adc_datain_r;
        adc_datain1_r2   <= adc_datain_r2;
        adc_datain1_r3   <= adc_datain_r3;
        adc_datain1_r4   <= adc_datain_r4;
    end

    always @(posedge slow_clk2) begin
        adc_datain2_r    <= adc_datain_r;
        adc_datain2_r2   <= adc_datain_r2;
        adc_datain2_r3   <= adc_datain_r3;
        adc_datain2_r4   <= adc_datain_r4;
    end

    always @(posedge slow_clk3) begin
        adc_datain3_r    <= adc_datain_r;
        adc_datain3_r2   <= adc_datain_r2;
        adc_datain3_r3   <= adc_datain_r3;
        adc_datain3_r4   <= adc_datain_r4;
    end

    always @(posedge slow_clk4) begin
        adc_datain4_r    <= adc_datain_r;
        adc_datain4_r2   <= adc_datain_r2;
        adc_datain4_r3   <= adc_datain_r3;
        adc_datain4_r4   <= adc_datain_r4;
    end


    // instantiate counters and do most of the heavy lifting...
    // First quarter of counters:
    genvar i;
    integer block1start = 0;
    generate 
        // NOTE: can't use block1start in for loop!
        for (i = 0; i < pREF_SAMPLES; i = i + pSADS_PER_CYCLE) begin: gen_sad_counters1
            assign refsample[i] = refsamples[i*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE];
            always @(posedge slow_clk1) begin
                if ((armed_and_ready_adc1 || always_armed) && active_adc1 && ~xadc_error) begin
                    if (i > block1start) ready2trigger1[i] <= ready2trigger1[i-pSADS_PER_CYCLE];
                    else if (master_counter1 == master_counter_top) ready2trigger1[0] <= 1;
                    if (i == block1start) resetter1[i] <= resetter1[pREF_SAMPLES-pSADS_PER_CYCLE];
                    else resetter1[i] <= resetter1[i-pSADS_PER_CYCLE];
                    if (i == 0) begin
                        if (master_counter1 == master_counter_top)
                            master_counter1 <= 0;
                        else 
                            master_counter1 <= master_counter1 + pSADS_PER_CYCLE;
                    end
                end
                else begin
                    if (i == block1start) master_counter1 <= 0;
                    ready2trigger1[i] <= 0;
                    // TODO-note: there seems to be an issue when pREF_SAMPLES isn't a power of 2
                    if (i == pREF_SAMPLES - (pSADS_PER_CYCLE*2 - block1start)) resetter1[i] <= 1'b1;
                    else resetter1[i] <= 1'b0;
                end

                if (i == block1start) begin
                    nextrefsample_a[block1start] <= refsample[master_counter1+3]; // don't need to worry about wrap-around (I think!)
                    nextrefsample_b[block1start] <= refsample[master_counter1+2];
                    nextrefsample_c[block1start] <= refsample[master_counter1+1];
                    nextrefsample_d[block1start] <= refsample[master_counter1];
                    compare_en_a[block1start] <= refen[master_counter1+3];
                    compare_en_b[block1start] <= refen[master_counter1+2];
                    compare_en_c[block1start] <= refen[master_counter1+1];
                    compare_en_d[block1start] <= refen[master_counter1];
                end
                else begin
                    nextrefsample_a[i] <= nextrefsample_a[i-pSADS_PER_CYCLE];
                    nextrefsample_b[i] <= nextrefsample_b[i-pSADS_PER_CYCLE];
                    nextrefsample_c[i] <= nextrefsample_c[i-pSADS_PER_CYCLE];
                    nextrefsample_d[i] <= nextrefsample_d[i-pSADS_PER_CYCLE];
                    compare_en_a[i] <= compare_en_a[i-pSADS_PER_CYCLE];
                    compare_en_b[i] <= compare_en_b[i-pSADS_PER_CYCLE];
                    compare_en_c[i] <= compare_en_c[i-pSADS_PER_CYCLE];
                    compare_en_d[i] <= compare_en_d[i-pSADS_PER_CYCLE];
                end

                if (compare_en_d[i] == 0)
                    counter_incr_d[i] <= 0;
                else if (adc_datain1_r4 > nextrefsample_d[i])
                    counter_incr_d[i] <= wadc_datain1_rpr4 - nextrefsample_d[i];
                else
                    counter_incr_d[i] <= wadc_datain1_rmr4 + nextrefsample_d[i];

                if (compare_en_c[i] == 0)
                    counter_incr_c[i] <= 0;
                else if (adc_datain1_r3 > nextrefsample_c[i])
                    counter_incr_c[i] <= wadc_datain1_rpr3 - nextrefsample_c[i];
                else
                    counter_incr_c[i] <= wadc_datain1_rmr3 + nextrefsample_c[i];

                if (compare_en_b[i] == 0)
                    counter_incr_b[i] <= 0;
                else if (adc_datain1_r2 > nextrefsample_b[i])
                    counter_incr_b[i] <= wadc_datain1_rpr2 - nextrefsample_b[i];
                else
                    counter_incr_b[i] <= wadc_datain1_rmr2 + nextrefsample_b[i];

                if (compare_en_a[i] == 0)
                    counter_incr_a[i] <= 0;
                else if (adc_datain1_r > nextrefsample_a[i])
                    counter_incr_a[i] <= wadc_datain1_rpr - nextrefsample_a[i];
                else
                    counter_incr_a[i] <= wadc_datain1_rmr + nextrefsample_a[i];


                // finally we get to the actual SAD counters:
                if (resetter1[i])
                    sad_counter[i] <= counter_incr_a[i] + counter_incr_b[i] + counter_incr_c[i] + counter_incr_d[i];
                else if (~sad_counter[i][pSAD_COUNTER_WIDTH-1]) // MSB of counter is used to indicate saturation
                    sad_counter[i] <= sad_counter[i] + counter_incr_a[i] + counter_incr_b[i] + counter_incr_c[i] + counter_incr_d[i];

                // and the triggers:
                if ((sad_counter[i] <= threshold) && resetter1[i] && ready2trigger1[i] && ~(triggered && ~multiple_triggers))
                    individual_trigger[i] <= 1'b1;
                else
                    individual_trigger[i] <= 1'b0;

            end

        end
    endgenerate


    // instantiate counters and do most of the heavy lifting...
    // Second quarter of counters:
    genvar j;
    integer block2start = 1;
    generate 
        for (j = 1; j < pREF_SAMPLES; j = j + pSADS_PER_CYCLE) begin: gen_sad_counters2
            assign refsample[j] = refsamples[j*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE];
            always @(posedge slow_clk2) begin
                if ((armed_and_ready_adc2 || always_armed) && active_adc2 && ~xadc_error) begin
                    if (j > block2start) ready2trigger2[j] <= ready2trigger2[j-pSADS_PER_CYCLE];
                    else if (master_counter2 == master_counter_top) ready2trigger2[block2start] <= 1;
                    if (j == block2start) resetter2[j] <= resetter2[pREF_SAMPLES-3];
                    else resetter2[j] <= resetter2[j-pSADS_PER_CYCLE];
                    if (j == block2start) begin
                        if (master_counter2 == master_counter_top)
                            master_counter2 <= 0;
                        else 
                            master_counter2 <= master_counter2 + pSADS_PER_CYCLE;
                    end
                end
                else begin
                    if (j == block2start) master_counter2 <= 0;
                    ready2trigger2[j] <= 0;
                    // TODO-note: there seems to be an issue when pREF_SAMPLES isn't a power of 2
                    if (j == pREF_SAMPLES - (pSADS_PER_CYCLE*2 - block2start)) resetter2[j] <= 1'b1;
                    else resetter2[j] <= 1'b0;
                end

                if (j == block2start) begin
                    nextrefsample_a[block2start] <= refsample[master_counter2+3]; // don't need to worry about wrap-around (I think!)
                    nextrefsample_b[block2start] <= refsample[master_counter2+2];
                    nextrefsample_c[block2start] <= refsample[master_counter2+1];
                    nextrefsample_d[block2start] <= refsample[master_counter2];
                    compare_en_a[block2start] <= refen[master_counter2+3];
                    compare_en_b[block2start] <= refen[master_counter2+2];
                    compare_en_c[block2start] <= refen[master_counter2+1];
                    compare_en_d[block2start] <= refen[master_counter2];
                end
                else begin
                    nextrefsample_a[j] <= nextrefsample_a[j-pSADS_PER_CYCLE];
                    nextrefsample_b[j] <= nextrefsample_b[j-pSADS_PER_CYCLE];
                    nextrefsample_c[j] <= nextrefsample_c[j-pSADS_PER_CYCLE];
                    nextrefsample_d[j] <= nextrefsample_d[j-pSADS_PER_CYCLE];
                    compare_en_a[j] <= compare_en_a[j-pSADS_PER_CYCLE];
                    compare_en_b[j] <= compare_en_b[j-pSADS_PER_CYCLE];
                    compare_en_c[j] <= compare_en_c[j-pSADS_PER_CYCLE];
                    compare_en_d[j] <= compare_en_d[j-pSADS_PER_CYCLE];
                end

                if (compare_en_d[j] == 0)
                    counter_incr_d[j] <= 0;
                else if (adc_datain2_r4 > nextrefsample_d[j])
                    counter_incr_d[j] <= wadc_datain2_rpr4 - nextrefsample_d[j];
                else
                    counter_incr_d[j] <= wadc_datain2_rmr4 + nextrefsample_d[j];

                if (compare_en_c[j] == 0)
                    counter_incr_c[j] <= 0;
                else if (adc_datain2_r3 > nextrefsample_c[j])
                    counter_incr_c[j] <= wadc_datain2_rpr3 - nextrefsample_c[j];
                else
                    counter_incr_c[j] <= wadc_datain2_rmr3 + nextrefsample_c[j];

                if (compare_en_b[j] == 0)
                    counter_incr_b[j] <= 0;
                else if (adc_datain2_r2 > nextrefsample_b[j])
                    counter_incr_b[j] <= wadc_datain2_rpr2 - nextrefsample_b[j];
                else
                    counter_incr_b[j] <= wadc_datain2_rmr2 + nextrefsample_b[j];

                if (compare_en_a[j] == 0)
                    counter_incr_a[j] <= 0;
                else if (adc_datain2_r > nextrefsample_a[j])
                    counter_incr_a[j] <= wadc_datain2_rpr - nextrefsample_a[j];
                else
                    counter_incr_a[j] <= wadc_datain2_rmr + nextrefsample_a[j];


                // finally we get to the actual SAD counters:
                if (resetter2[j])
                    sad_counter[j] <= counter_incr_a[j] + counter_incr_b[j] + counter_incr_c[j] + counter_incr_d[j];
                else if (~sad_counter[j][pSAD_COUNTER_WIDTH-1]) // MSB of counter is used to indicate saturation
                    sad_counter[j] <= sad_counter[j] + counter_incr_a[j] + counter_incr_b[j] + counter_incr_c[j] + counter_incr_d[j];

                // and the triggers:
                if ((sad_counter[j] <= threshold) && resetter2[j] && ready2trigger2[j] && ~(triggered && ~multiple_triggers))
                    individual_trigger[j] <= 1'b1;
                else
                    individual_trigger[j] <= 1'b0;

            end

        end
    endgenerate


    // instantiate counters and do most of the heavy lifting...
    // Third quarter of counters:
    genvar k;
    integer block3start = 2;
    generate 
        for (k = 2; k < pREF_SAMPLES; k = k + pSADS_PER_CYCLE) begin: gen_sad_counters3
            assign refsample[k] = refsamples[k*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE];
            always @(posedge slow_clk3) begin
                if ((armed_and_ready_adc3 || always_armed) && active_adc3 && ~xadc_error) begin
                    if (k > block3start) ready2trigger3[k] <= ready2trigger3[k-pSADS_PER_CYCLE];
                    else if (master_counter3 == master_counter_top) ready2trigger3[block3start] <= 1;
                    if (k == block3start) resetter3[k] <= resetter3[pREF_SAMPLES-2];
                    else resetter3[k] <= resetter3[k-pSADS_PER_CYCLE];
                    if (k == block3start) begin
                        if (master_counter3 == master_counter_top)
                            master_counter3 <= 0;
                        else 
                            master_counter3 <= master_counter3 + pSADS_PER_CYCLE;
                    end
                end
                else begin
                    if (k == block3start) master_counter3 <= 0;
                    ready2trigger3[k] <= 0;
                    // TODO-note: there seems to be an issue when pREF_SAMPLES isn't a power of 2
                    if (k == pREF_SAMPLES - (pSADS_PER_CYCLE*2 - block3start)) resetter3[k] <= 1'b1;
                    else resetter3[k] <= 1'b0;
                end

                if (k == block3start) begin
                    nextrefsample_a[block3start] <= refsample[master_counter3+3]; // don't need to worry about wrap-around (I think!)
                    nextrefsample_b[block3start] <= refsample[master_counter3+2];
                    nextrefsample_c[block3start] <= refsample[master_counter3+1];
                    nextrefsample_d[block3start] <= refsample[master_counter3];
                    compare_en_a[block3start] <= refen[master_counter3+3];
                    compare_en_b[block3start] <= refen[master_counter3+2];
                    compare_en_c[block3start] <= refen[master_counter3+1];
                    compare_en_d[block3start] <= refen[master_counter3];
                end
                else begin
                    nextrefsample_a[k] <= nextrefsample_a[k-pSADS_PER_CYCLE];
                    nextrefsample_b[k] <= nextrefsample_b[k-pSADS_PER_CYCLE];
                    nextrefsample_c[k] <= nextrefsample_c[k-pSADS_PER_CYCLE];
                    nextrefsample_d[k] <= nextrefsample_d[k-pSADS_PER_CYCLE];
                    compare_en_a[k] <= compare_en_a[k-pSADS_PER_CYCLE];
                    compare_en_b[k] <= compare_en_b[k-pSADS_PER_CYCLE];
                    compare_en_c[k] <= compare_en_c[k-pSADS_PER_CYCLE];
                    compare_en_d[k] <= compare_en_d[k-pSADS_PER_CYCLE];
                end

                if (compare_en_d[k] == 0)
                    counter_incr_d[k] <= 0;
                else if (adc_datain3_r4 > nextrefsample_d[k])
                    counter_incr_d[k] <= wadc_datain3_rpr4 - nextrefsample_d[k];
                else
                    counter_incr_d[k] <= wadc_datain3_rmr4 + nextrefsample_d[k];

                if (compare_en_c[k] == 0)
                    counter_incr_c[k] <= 0;
                else if (adc_datain3_r3 > nextrefsample_c[k])
                    counter_incr_c[k] <= wadc_datain3_rpr3 - nextrefsample_c[k];
                else
                    counter_incr_c[k] <= wadc_datain3_rmr3 + nextrefsample_c[k];

                if (compare_en_b[k] == 0)
                    counter_incr_b[k] <= 0;
                else if (adc_datain3_r2 > nextrefsample_b[k])
                    counter_incr_b[k] <= wadc_datain3_rpr2 - nextrefsample_b[k];
                else
                    counter_incr_b[k] <= wadc_datain3_rmr2 + nextrefsample_b[k];

                if (compare_en_a[k] == 0)
                    counter_incr_a[k] <= 0;
                else if (adc_datain3_r > nextrefsample_a[k])
                    counter_incr_a[k] <= wadc_datain3_rpr - nextrefsample_a[k];
                else
                    counter_incr_a[k] <= wadc_datain3_rmr + nextrefsample_a[k];


                // finally we get to the actual SAD counters:
                if (resetter3[k])
                    sad_counter[k] <= counter_incr_a[k] + counter_incr_b[k] + counter_incr_c[k] + counter_incr_d[k];
                else if (~sad_counter[k][pSAD_COUNTER_WIDTH-1]) // MSB of counter is used to indicate saturation
                    sad_counter[k] <= sad_counter[k] + counter_incr_a[k] + counter_incr_b[k] + counter_incr_c[k] + counter_incr_d[k];

                // and the triggers:
                if ((sad_counter[k] <= threshold) && resetter3[k] && ready2trigger3[k] && ~(triggered && ~multiple_triggers))
                    individual_trigger[k] <= 1'b1;
                else
                    individual_trigger[k] <= 1'b0;

            end

        end
    endgenerate



    // instantiate counters and do most of the heavy lifting...
    // Fourth quarter of counters:
    genvar l;
    integer block4start = 3;
    generate 
        for (l = 3; l < pREF_SAMPLES; l = l + pSADS_PER_CYCLE) begin: gen_sad_counters4
            assign refsample[l] = refsamples[l*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE];
            always @(posedge slow_clk4) begin
                if ((armed_and_ready_adc4 || always_armed) && active_adc4 && ~xadc_error) begin
                    if (l > block4start) ready2trigger4[l] <= ready2trigger4[l-pSADS_PER_CYCLE];
                    else if (master_counter4 == master_counter_top) ready2trigger4[block4start] <= 1;
                    if (l == block4start) resetter4[l] <= resetter4[pREF_SAMPLES-1];
                    else resetter4[l] <= resetter4[l-pSADS_PER_CYCLE];
                    if (l == block4start) begin
                        if (master_counter4 == master_counter_top)
                            master_counter4 <= 0;
                        else 
                            master_counter4 <= master_counter4 + pSADS_PER_CYCLE;
                    end
                end
                else begin
                    if (l == block4start) master_counter4 <= 0;
                    ready2trigger4[l] <= 0;
                    // TODO-note: there seems to be an issue when pREF_SAMPLES isn't a power of 2
                    if (l == pREF_SAMPLES - (pSADS_PER_CYCLE*2 - block4start)) resetter4[l] <= 1'b1;
                    else resetter4[l] <= 1'b0;
                end

                if (l == block4start) begin
                    nextrefsample_a[block4start] <= refsample[master_counter4+3]; // don't need to worry about wrap-around (I think!)
                    nextrefsample_b[block4start] <= refsample[master_counter4+2];
                    nextrefsample_c[block4start] <= refsample[master_counter4+1];
                    nextrefsample_d[block4start] <= refsample[master_counter4];
                    compare_en_a[block4start] <= refen[master_counter4+3];
                    compare_en_b[block4start] <= refen[master_counter4+2];
                    compare_en_c[block4start] <= refen[master_counter4+1];
                    compare_en_d[block4start] <= refen[master_counter4];
                end
                else begin
                    nextrefsample_a[l] <= nextrefsample_a[l-pSADS_PER_CYCLE];
                    nextrefsample_b[l] <= nextrefsample_b[l-pSADS_PER_CYCLE];
                    nextrefsample_c[l] <= nextrefsample_c[l-pSADS_PER_CYCLE];
                    nextrefsample_d[l] <= nextrefsample_d[l-pSADS_PER_CYCLE];
                    compare_en_a[l] <= compare_en_a[l-pSADS_PER_CYCLE];
                    compare_en_b[l] <= compare_en_b[l-pSADS_PER_CYCLE];
                    compare_en_c[l] <= compare_en_c[l-pSADS_PER_CYCLE];
                    compare_en_d[l] <= compare_en_d[l-pSADS_PER_CYCLE];
                end

                if (compare_en_d[l] == 0)
                    counter_incr_d[l] <= 0;
                else if (adc_datain4_r4 > nextrefsample_d[l])
                    counter_incr_d[l] <= wadc_datain4_rpr4 - nextrefsample_d[l];
                else
                    counter_incr_d[l] <= wadc_datain4_rmr4 + nextrefsample_d[l];

                if (compare_en_c[l] == 0)
                    counter_incr_c[l] <= 0;
                else if (adc_datain4_r3 > nextrefsample_c[l])
                    counter_incr_c[l] <= wadc_datain4_rpr3 - nextrefsample_c[l];
                else
                    counter_incr_c[l] <= wadc_datain4_rmr3 + nextrefsample_c[l];

                if (compare_en_b[l] == 0)
                    counter_incr_b[l] <= 0;
                else if (adc_datain4_r2 > nextrefsample_b[l])
                    counter_incr_b[l] <= wadc_datain4_rpr2 - nextrefsample_b[l];
                else
                    counter_incr_b[l] <= wadc_datain4_rmr2 + nextrefsample_b[l];

                if (compare_en_a[l] == 0)
                    counter_incr_a[l] <= 0;
                else if (adc_datain4_r > nextrefsample_a[l])
                    counter_incr_a[l] <= wadc_datain4_rpr - nextrefsample_a[l];
                else
                    counter_incr_a[l] <= wadc_datain4_rmr + nextrefsample_a[l];


                // finally we get to the actual SAD counters:
                if (resetter4[l])
                    sad_counter[l] <= counter_incr_a[l] + counter_incr_b[l] + counter_incr_c[l] + counter_incr_d[l];
                else if (~sad_counter[l][pSAD_COUNTER_WIDTH-1]) // MSB of counter is used to indicate saturation
                    sad_counter[l] <= sad_counter[l] + counter_incr_a[l] + counter_incr_b[l] + counter_incr_c[l] + counter_incr_d[l];

                // and the triggers:
                if ((sad_counter[l] <= threshold) && resetter4[l] && ready2trigger4[l] && ~(triggered && ~multiple_triggers))
                    individual_trigger[l] <= 1'b1;
                else
                    individual_trigger[l] <= 1'b0;

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
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_a26 = nextrefsample_a[26];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_a27 = nextrefsample_a[27];

    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_b0 = nextrefsample_b[0];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_b1 = nextrefsample_b[1];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_b2 = nextrefsample_b[2];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_b3 = nextrefsample_b[3];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_b4 = nextrefsample_b[4];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_b5 = nextrefsample_b[5];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_b6 = nextrefsample_b[6];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_b7 = nextrefsample_b[7];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_b26 = nextrefsample_b[26];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_b27 = nextrefsample_b[27];

    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_c0 = nextrefsample_c[0];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_c1 = nextrefsample_c[1];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_c2 = nextrefsample_c[2];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_c3 = nextrefsample_c[3];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_c4 = nextrefsample_c[4];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_c5 = nextrefsample_c[5];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_c6 = nextrefsample_c[6];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_c7 = nextrefsample_c[7];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_c26 = nextrefsample_c[26];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_c27 = nextrefsample_c[27];

    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_d0 = nextrefsample_d[0];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_d1 = nextrefsample_d[1];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_d2 = nextrefsample_d[2];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_d3 = nextrefsample_d[3];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_d4 = nextrefsample_d[4];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_d5 = nextrefsample_d[5];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_d6 = nextrefsample_d[6];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_d7 = nextrefsample_d[7];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_d26 = nextrefsample_d[26];
    wire [pBITS_PER_SAMPLE-1:0] nextrefsample_d27 = nextrefsample_d[27];


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
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_a26 = counter_incr_a[26];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_a27 = counter_incr_a[27];

    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_b0 = counter_incr_b[0];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_b1 = counter_incr_b[1];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_b2 = counter_incr_b[2];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_b3 = counter_incr_b[3];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_b4 = counter_incr_b[4];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_b5 = counter_incr_b[5];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_b6 = counter_incr_b[6];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_b7 = counter_incr_b[7];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_b26 = counter_incr_b[26];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_b27 = counter_incr_b[27];

    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_c0 = counter_incr_c[0];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_c1 = counter_incr_c[1];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_c2 = counter_incr_c[2];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_c3 = counter_incr_c[3];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_c4 = counter_incr_c[4];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_c5 = counter_incr_c[5];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_c6 = counter_incr_c[6];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_c7 = counter_incr_c[7];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_c26 = counter_incr_c[26];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_c27 = counter_incr_c[27];

    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_d0 = counter_incr_d[0];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_d1 = counter_incr_d[1];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_d2 = counter_incr_d[2];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_d3 = counter_incr_d[3];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_d4 = counter_incr_d[4];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_d5 = counter_incr_d[5];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_d6 = counter_incr_d[6];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_d7 = counter_incr_d[7];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_d26 = counter_incr_d[26];
    wire [pSAD_COUNTER_WIDTH-1:0] counter_incr_d27 = counter_incr_d[27];

    wire resetter3_26 = resetter3[26];
    wire resetter4_27 = resetter4[27];



    wire ready2trigger1_debug = ready2trigger1[pREF_SAMPLES-2];

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


    wire [7:0] resetter2_debug = {resetter2[29],
                                  resetter2[25],
                                  resetter2[21],
                                  resetter2[17],
                                  resetter2[13],
                                  resetter2[9],
                                  resetter2[5],
                                  resetter2[1]};

    wire [7:0] ready2trigger2_debug = {ready2trigger2[29],
                                       ready2trigger2[25],
                                       ready2trigger2[21],
                                       ready2trigger2[17],
                                       ready2trigger2[13],
                                       ready2trigger2[9],
                                       ready2trigger2[5],
                                       ready2trigger2[1]};


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
