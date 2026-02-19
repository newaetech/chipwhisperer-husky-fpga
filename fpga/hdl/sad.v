`include "includes.v"
`timescale 1 ns / 1 ps
`default_nettype none

/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more
details, or the codebase at http://www.chipwhisperer.com

Copyright (c) 2022-2024, NewAE Technology Inc. All rights reserved.
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


Notes on instantiation parameters:
==================================
pREF_SAMPLES is the length of the SAD pattern; it can be adjusted to control
the size of the implementation. It must be a multiple of 2.

pSAD_COUNTER_WIDTH has no effect unless `INTERVAL_MATCHING is not set.
Otherwise, it controls the width of the SAD counters, and therefore limits the
maximum SAD that can be computed; it has a significant effect on size.

pNUM_GROUPS must divide pREF_SAMPLES evenly. It has no bearing on
functionality but it can affect implementation results.

pBITS_PER_SAMPLE is the ADC sample size that is used for the SAD computation.
In theory this could be anything; in practice values != 8 have not been tested.

Other paramaters should not be touched.

*************************************************************************/

module sad #(
    parameter pBYTECNT_SIZE = 7,
    parameter pREF_SAMPLES = 32, 
    parameter pBITS_PER_SAMPLE = 8,
    parameter pSAD_COUNTER_WIDTH = 16,
    parameter pNUM_GROUPS = 4
)(
    input wire          reset,
    input wire          xadc_error,

    //ADC Sample Input
    input wire [pBITS_PER_SAMPLE-1:0] adc_datain,
    input wire          adc_sampleclk,
    input wire          armed_and_ready,
    input wire          active,
    input wire          trigger_allowed,

    //USB register interface
    input wire          clk_usb,
    input  wire [7:0]   reg_address,  // Address of register
    input  wire [pBYTECNT_SIZE-1:0]  reg_bytecnt,  // Current byte count
    input  wire [7:0]   reg_datai,    // Data to write
    output reg  [7:0]   reg_datao,    // Data to read
    input  wire         reg_read,     // Read flag
    input  wire         reg_write,    // Write flag

    output wire [7:0]   sad_debug,

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
                                       (pREF_SAMPLES <= 512)? 9 :
                                       (pREF_SAMPLES <= 1024)? 10 : 11;

    localparam pACTUAL_SAD_COUNTER_WIDTH = (`INTERVAL_MATCHING == 1)? (pMASTER_COUNTER_WIDTH-2) : pSAD_COUNTER_WIDTH;

    reg  triggered = 1'b0;
    reg [15:0] num_triggers;
    reg clear_status;
    reg clear_status_r;
    wire clear_status_adc;

    reg refsamples_wr = 1'b0;
    wire refsamples_overflow_error;
    wire refsamples_underflow_error;
    wire refsamples_empty;
    wire refsamples_rd;
    wire [pBITS_PER_SAMPLE-1:0] refsamples_dout;

    reg refen_wr = 1'b0;
    wire refen_overflow_error;
    wire refen_underflow_error;
    wire refen_empty;
    wire refen_rd;
    wire [7:0] refen_dout;


    reg always_armed;
    reg multiple_triggers;
    reg emode;
    reg [pREF_SAMPLES*pBITS_PER_SAMPLE-1:0] refsamples;
    reg [pREF_SAMPLES-1:0] refen = {pREF_SAMPLES{1'b0}}; // all samples enabled by default
    reg [pREF_SAMPLES-1:0] compare_en, compare_en_r;
    reg [pACTUAL_SAD_COUNTER_WIDTH-1:0] threshold;
    reg [pBITS_PER_SAMPLE-1:0] interval_threshold;      // NOTE: pBITS_PER_SAMPLE is assumed to be <= 8
    reg [pMASTER_COUNTER_WIDTH-1:0] master_counter;
    reg [pMASTER_COUNTER_WIDTH-1:0] refsample_shift_count = 0;
    reg [pREF_SAMPLES-1:0] resetter;
    reg [pREF_SAMPLES-1:0] triggerer;

    // default to normal triggering at end of full pattern;
    // general formula: set triggerer_init to (pREF_SAMPLES - 3 + (cycles early)) % pREF_SAMPLES
    reg [pMASTER_COUNTER_WIDTH-1:0] triggerer_init = pREF_SAMPLES-3; 

    reg individual_trigger [0:pREF_SAMPLES-1];
    reg individual_trigger_r [0:pREF_SAMPLES-1];
    reg [pACTUAL_SAD_COUNTER_WIDTH-1:0] sad_counter [0:pREF_SAMPLES-1];
    reg [pBITS_PER_SAMPLE-1:0] counter_incr [0:pREF_SAMPLES-1];

    reg  armed_and_ready_r;
    reg  armed_and_ready_sad;
    reg  sad_control_write;
    wire sad_control_write_adc;

    reg ready2trigger0;
    reg [pREF_SAMPLES-1:1] ready2trigger_1andup;
    wire [pREF_SAMPLES-1:0] ready2trigger_all = {ready2trigger_1andup, ready2trigger0};

    reg  decision [0:pREF_SAMPLES-1];
    reg [pBITS_PER_SAMPLE-1:0]  nextrefsample [0:pREF_SAMPLES-1];
    reg [pBITS_PER_SAMPLE-1:0]  nextrefsample_r [0:pREF_SAMPLES-1];
    wire [pBITS_PER_SAMPLE-1:0]  refsample [0:pREF_SAMPLES-1];
    reg [pBITS_PER_SAMPLE-1:0] adc_datain_rpr, adc_datain_rmr; // sign extend
    reg [pBITS_PER_SAMPLE-1:0] adc_datain_r;

`ifdef HIPERF
    wire [23:0] status_reg = 24'b0;
`else
    wire [23:0] status_reg = {num_triggers, refen_overflow_error, refen_underflow_error, refsamples_overflow_error, refsamples_underflow_error, 2'b0, shifter_active, triggered};
`endif

    wire [31:0] wide_threshold_reg = {{(32-pACTUAL_SAD_COUNTER_WIDTH){1'b0}}, threshold}; // having a variable-width register isn't very convenient for Python
    wire [15:0] ref_samples = pREF_SAMPLES;

    // These are a property of this module; used here to make sure Python
    // knows what it's talking to, in case there may be different SAD modules
    // used in different targets or builds.
    // Format: 
    //          11: advanced trigger time support
    //          10: max threshold type
    //                  0: 2^(SAD_COUNTER_WIDTH-1)-1
    //                  1: 2^SAD_COUNTER_WIDTH-1
    //          9: eSAD mode support
    //          8: interval mode support
    //          7:5: version code
    //                  000: sad.v
    //                  001: (unused)
    //                  010: sad_x2_slowclock.v
    //                  100: sad_x4_slowclock.v
    //                  110: esad.v
    //                  101: sad_x2.v
    //                  111: sad_single_counter.v
    //          4:0: trigger latency
    wire advanced_trigger_time_support = 1'b1;
    wire max_threshold = (`INTERVAL_MATCHING == 1)? 1'b1 : 1'b0;
    wire esad_support = 1'b0;
    wire im_support = 1'b1;
    wire [2:0] version = 3'b000;
    wire [4:0] latency = 5'd10;
    wire [11:0] version_bits = {advanced_trigger_time_support, max_threshold, esad_support, im_support, version, latency};


    // register reads:
    always @(*) begin
        if (reg_read) begin
            case (reg_address)
                `SAD_TRIGGER_TIME: reg_datao = triggerer_init[reg_bytecnt*8 +: 8];
                `SAD_THRESHOLD: reg_datao = wide_threshold_reg[reg_bytecnt*8 +: 8];
                `SAD_INTERVAL_THRESHOLD: reg_datao = interval_threshold;
                `SAD_STATUS: reg_datao = status_reg[reg_bytecnt*8 +: 8];
                `SAD_BITS_PER_SAMPLE: reg_datao = pBITS_PER_SAMPLE;
                `SAD_REF_SAMPLES: reg_datao = ref_samples[reg_bytecnt*8 +: 8];
                `SAD_COUNTER_WIDTH: reg_datao = pACTUAL_SAD_COUNTER_WIDTH;
                `SAD_CONTROL: reg_datao = {5'b0, emode, multiple_triggers, always_armed};
                `SAD_VERSION: reg_datao = version_bits[reg_bytecnt*8 +: 8];
                default: reg_datao = 0;
            endcase
        end
        else
            reg_datao = 0;
    end

    // register writes:
    always @(posedge clk_usb) begin
        if (reset) begin
            threshold <= 0;
            clear_status_r <= 0;
            multiple_triggers <= 0;
            always_armed <= 0;
            interval_threshold <= 1;
        end 
        else begin
            clear_status_r <= clear_status;
            if (reg_write) begin
                case (reg_address)
                    //`SAD_REFEN: refen_usb[reg_bytecnt*8 +: 8] <= reg_datai;
                    `SAD_TRIGGER_TIME: triggerer_init[reg_bytecnt*8 +: 8] <= reg_datai;
                    `SAD_THRESHOLD: threshold[reg_bytecnt*8 +: 8] <= reg_datai;
                    `SAD_INTERVAL_THRESHOLD: interval_threshold <= reg_datai;
                    `SAD_CONTROL: begin
                        emode <= reg_datai[2];
                    `ifndef HIPERF
                        multiple_triggers <= reg_datai[1];
                    `endif
                        always_armed <= reg_datai[0];
                    end
                    default: ;
                endcase
                if (reg_address == `SAD_STATUS)
                    clear_status <= 1'b1;
                else
                    clear_status <= 1'b0;
            end

            if (reg_write && (reg_address == `SAD_REFERENCE) && ~refsamples_wr)
                refsamples_wr <= 1'b1;
            else
                refsamples_wr <= 1'b0;

            if (reg_write && (reg_address == `SAD_REFEN) && ~refen_wr)
                refen_wr <= 1'b1;
            else
                refen_wr <= 1'b0;

            if (reg_write && (reg_address == `SAD_CONTROL) && ~sad_control_write)
                sad_control_write <= 1'b1;
            else
                sad_control_write <= 1'b0;

        end
    end

   cdc_pulse U_clear_status_cdc (
      .reset_i       (reset),
      .src_clk       (clk_usb),
      .src_pulse     (clear_status && ~clear_status_r),
      .dst_clk       (adc_sampleclk),
      .dst_pulse     (clear_status_adc)
   );

   cdc_pulse U_sad_control_cdc (
      .reset_i       (reset),
      .src_clk       (clk_usb),
      .src_pulse     (sad_control_write),
      .dst_clk       (adc_sampleclk),
      .dst_pulse     (sad_control_write_adc)
   );


    // armed_and_ready needs to be handled with care because it stays high if
    // a capture fails (i.e. even after it times out). In the capture logic
    // this is fine because it will get cleared when the next capture is
    // initiated. With this SAD implementation, that's a problem because we
    // can't write SAD_REFERENCE or SAD_REFEN when armed_and_ready is high. So
    // we use an explicit write to SAD_CONTROL to clear it.
    always @(posedge adc_sampleclk) begin
        armed_and_ready_r <= armed_and_ready;
        if (~armed_and_ready || sad_control_write_adc)
            armed_and_ready_sad <= 1'b0;
        else if (armed_and_ready && ~armed_and_ready_r)
            armed_and_ready_sad <= 1'b1;
    end


    always @(posedge adc_sampleclk) begin
        if (clear_status_adc || (armed_and_ready && ~armed_and_ready_r)) begin
            triggered <= 1'b0;
            num_triggers <= 0;
        end
        else if (trigger) begin
            triggered <= 1'b1;
            num_triggers <= num_triggers + 1;
        end
    end

    wire [pMASTER_COUNTER_WIDTH-1:0] master_counter_top = pREF_SAMPLES-1;

    always @(posedge adc_sampleclk) begin
        if ((armed_and_ready_sad || always_armed) && active && ~xadc_error) begin
            ready2trigger_1andup <= {ready2trigger_1andup[pREF_SAMPLES-2:1], ready2trigger0};
            resetter <= {resetter[pREF_SAMPLES-2:0], resetter[pREF_SAMPLES-1]};
            triggerer <= {triggerer[pREF_SAMPLES-2:0], triggerer[pREF_SAMPLES-1]};
            if (master_counter == master_counter_top) begin
                ready2trigger0 <= 1;
                master_counter <= 0;
            end
            else
                master_counter <= master_counter + 1;
        end
        else begin
            master_counter <= 0;
            ready2trigger0 <= 0;
            ready2trigger_1andup <= 0;
            resetter <= {2'b0, 1'b1, {(pREF_SAMPLES-3){1'b0}}};
            triggerer <= 1<<triggerer_init;
        end
    end

    // NOTE: this is where we combine each counter's trigger into the single
    // actual trigger. This used to be a single, simple block of logic with
    // a generate statement; however for large pNUM_COUNTERS, timing could be
    // difficult. We get better implementation results by processing subgroups
    // of individual_triggers together, instead of all at once. Unfortunately
    // Verilog makes this very hard to write! You would need nested generated
    // loops (which isn't allowed). This is best solution I could find.  
    //
    // Another advantage of doing this is that pNUM_GROUPS is a parameter that
    // we can adjust, without any changes in functionality, until we get an
    // implementation that meets timing.

    wire [pREF_SAMPLES-1:0] it;
    genvar k;
    generate
        for (k = 0; k < pREF_SAMPLES; k = k + 1)
            assign it[k] = individual_trigger[k];
    endgenerate

    localparam pGROUP_SIZE = pREF_SAMPLES/pNUM_GROUPS;

    wire [pNUM_GROUPS-1:0] group_trigger;
    genvar group;

    generate
        for (group = 0; group < pREF_SAMPLES; group = group + pGROUP_SIZE) begin
            sad_group_trigger #(
                .pGROUP_SIZE    (pGROUP_SIZE)
            ) U_group_trigger (
                .clock          (adc_sampleclk),
                .trigger_inputs (it[group+pGROUP_SIZE-1:group]),
                .trigger_output (group_trigger[group/pGROUP_SIZE])
            );
        end
    endgenerate

    always @(posedge adc_sampleclk) begin
        if (~active || (~armed_and_ready_sad && ~always_armed) || ~trigger_allowed)
            trigger <= 1'b0;
        else begin
            if (~(triggered && ~multiple_triggers)) 
                trigger <= |group_trigger;
            else
                trigger <= 1'b0;
        end
    end


    always @(posedge adc_sampleclk) begin
        adc_datain_r <= adc_datain;
        adc_datain_rpr <= adc_datain_r;
        adc_datain_rmr <= -adc_datain_r;
    end

    fifo_async #(
        .pDATA_WIDTH    (pBITS_PER_SAMPLE),
        .pDEPTH         (8),
        .pFALLTHROUGH   (1),
        .pFLOPS         (1),
        .pDISTRIBUTED   (0),
        .pBRAM          (0)
    ) U_refsamples_cdc_fifo (
        .wclk                   (clk_usb),
        .rclk                   (adc_sampleclk),
        .wrst_n                 (~reset),
        .rrst_n                 (~reset),
        .wfull_threshold_value  (0),
        .rempty_threshold_value (0),
        .wen                    (refsamples_wr),
        .wdata                  (reg_datai),
        .wfull                  (),
        .walmost_full           (),
        .woverflow              (refsamples_overflow_error),
        .wfull_threshold        (),
        .ren                    (refsamples_rd),
        .rdata                  (refsamples_dout),
        .rempty                 (refsamples_empty),
        .ralmost_empty          (),
        .rempty_threshold       (),
        .runderflow             (refsamples_underflow_error)
    );

    fifo_async #(
        .pDATA_WIDTH    (8),
        .pDEPTH         (8),
        .pFALLTHROUGH   (1),
        .pFLOPS         (1),
        .pDISTRIBUTED   (0),
        .pBRAM          (0)
    ) U_refen_cdc_fifo (
        .wclk                   (clk_usb),
        .rclk                   (adc_sampleclk),
        .wrst_n                 (~reset),
        .rrst_n                 (~reset),
        .wfull_threshold_value  (0),
        .rempty_threshold_value (0),
        .wen                    (refen_wr),
        .wdata                  (reg_datai),
        .wfull                  (),
        .walmost_full           (),
        .woverflow              (refen_overflow_error),
        .wfull_threshold        (),
        .ren                    (refen_rd),
        .rdata                  (refen_dout),
        .rempty                 (refen_empty),
        .ralmost_empty          (),
        .rempty_threshold       (),
        .runderflow             (refen_underflow_error)
    );


    assign refsamples_rd = ~refsamples_empty;
    assign refen_rd = ~refen_empty;

    wire shifter_active = (armed_and_ready_sad || always_armed || (refsample_shift_count != 0));

    assign sad_debug = {trigger, armed_and_ready_sad, always_armed, (refsample_shift_count == 0), armed_and_ready, armed_and_ready_r, sad_control_write_adc, shifter_active};


    integer d;
    always @(posedge adc_sampleclk) begin
        if (shifter_active || ~refsamples_empty || ~refen_empty) begin
            if (shifter_active)
                if (refsample_shift_count < pREF_SAMPLES-1)
                    refsample_shift_count <= refsample_shift_count + 1;
                else
                    refsample_shift_count <= 0;
            for (d = 0; d < pREF_SAMPLES; d = d + 1) begin
                if (shifter_active || ~refsamples_empty) begin
                    if (d == pREF_SAMPLES-1)
                        if (refsamples_empty)
                            refsamples[d*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE] <= refsamples[0 +: pBITS_PER_SAMPLE];
                        else
                            refsamples[d*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE] <= refsamples_dout;
                    else
                        refsamples[d*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE] <= refsamples[(d+1)*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE];
                end

            end
            if (shifter_active)
                refen <= {refen[0], refen[pREF_SAMPLES-1:1]};
            else if (~refen_empty)
                refen <= {refen_dout, refen[pREF_SAMPLES-1:8]};
        end
    end

    wire [pBITS_PER_SAMPLE-1:0] ref_sample0 = refsamples[0 +: pBITS_PER_SAMPLE];
    wire refen_sample0 = refen[0];


    // instantiate counters and do most of the heavy lifting:
    genvar i;
    generate 
        for (i = 0; i < pREF_SAMPLES; i = i + 1) begin: gen_sad_counters
            assign refsample[i] =  refsamples[i*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE];

            always @(posedge adc_sampleclk) begin
                if (i == 0) begin
                    nextrefsample[i] <=  ref_sample0;
                    compare_en[i] <= refen_sample0;
                end
                else begin
                    nextrefsample[i] <=  nextrefsample[i-1];
                    compare_en[i] <= compare_en[i-1];
                end
                nextrefsample_r[i] <=  nextrefsample[i];
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


                if (`INTERVAL_MATCHING == 1) begin
                    if (resetter[i])
                        sad_counter[i] <= ((counter_incr[i] <= interval_threshold)? 0 : 1);
                    else if (~(&(sad_counter[i]))) // don't overflow
                        sad_counter[i] <= sad_counter[i] + ((counter_incr[i] <= interval_threshold)? 0 : 1);
                end
                else begin
                    if (resetter[i])
                        sad_counter[i] <= counter_incr[i];
                    else if (~sad_counter[i][pACTUAL_SAD_COUNTER_WIDTH-1]) // MSB of counter is used to indicate saturation
                        sad_counter[i] <= sad_counter[i] + counter_incr[i];
                end

            end

            always @ (posedge adc_sampleclk) begin
                if ((sad_counter[i] <= threshold) && triggerer[i] && ready2trigger_all[i] && ~(triggered && ~multiple_triggers))
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

    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] sad_counter0  = sad_counter[0 ];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] sad_counter1  = sad_counter[1 ];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] sad_counter2  = sad_counter[2 ];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] sad_counter3  = sad_counter[3 ];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] sad_counter4  = sad_counter[4 ];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] sad_counter5  = sad_counter[5 ];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] sad_counter6  = sad_counter[6 ];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] sad_counter7  = sad_counter[7 ];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] sad_counter8  = sad_counter[8 ];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] sad_counter9  = sad_counter[9 ];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] sad_counter10 = sad_counter[10];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] sad_counter11 = sad_counter[11];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] sad_counter12 = sad_counter[12];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] sad_counter13 = sad_counter[13];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] sad_counter14 = sad_counter[14];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] sad_counter15 = sad_counter[15];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] sad_counter16 = sad_counter[16];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] sad_counter17 = sad_counter[17];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] sad_counter18 = sad_counter[18];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] sad_counter19 = sad_counter[19];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] sad_counter20 = sad_counter[20];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] sad_counter21 = sad_counter[21];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] sad_counter22 = sad_counter[22];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] sad_counter23 = sad_counter[23];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] sad_counter24 = sad_counter[24];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] sad_counter25 = sad_counter[25];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] sad_counter26 = sad_counter[26];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] sad_counter27 = sad_counter[27];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] sad_counter28 = sad_counter[28];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] sad_counter29 = sad_counter[29];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] sad_counter30 = sad_counter[30];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] sad_counter31 = sad_counter[31];

    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] counter_incr0  = counter_incr[0 ];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] counter_incr1  = counter_incr[1 ];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] counter_incr2  = counter_incr[2 ];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] counter_incr3  = counter_incr[3 ];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] counter_incr4  = counter_incr[4 ];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] counter_incr5  = counter_incr[5 ];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] counter_incr6  = counter_incr[6 ];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] counter_incr7  = counter_incr[7 ];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] counter_incr8  = counter_incr[8 ];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] counter_incr9  = counter_incr[9 ];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] counter_incr10 = counter_incr[10];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] counter_incr11 = counter_incr[11];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] counter_incr12 = counter_incr[12];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] counter_incr13 = counter_incr[13];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] counter_incr14 = counter_incr[14];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] counter_incr15 = counter_incr[15];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] counter_incr16 = counter_incr[16];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] counter_incr17 = counter_incr[17];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] counter_incr18 = counter_incr[18];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] counter_incr19 = counter_incr[19];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] counter_incr20 = counter_incr[20];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] counter_incr21 = counter_incr[21];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] counter_incr22 = counter_incr[22];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] counter_incr23 = counter_incr[23];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] counter_incr24 = counter_incr[24];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] counter_incr25 = counter_incr[25];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] counter_incr26 = counter_incr[26];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] counter_incr27 = counter_incr[27];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] counter_incr28 = counter_incr[28];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] counter_incr29 = counter_incr[29];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] counter_incr30 = counter_incr[30];
    wire [pACTUAL_SAD_COUNTER_WIDTH-1:0] counter_incr31 = counter_incr[31];


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
