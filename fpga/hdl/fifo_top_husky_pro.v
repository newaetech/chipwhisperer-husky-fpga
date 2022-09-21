`include "includes.v"
`timescale 1 ns / 1 ps
`default_nettype none

/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more
details, or the codebase at http://www.chipwhisperer.com
Built from fifo_top_husky.v and modified for Pro.

Copyright (c) 2021-2022, NewAE Technology Inc. All rights reserved.
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

module fifo_top_husky_pro (
    input wire    reset,

    //ADC Sample Input
    input wire [11:0]   adc_datain,
    input wire          adc_sampleclk,
    input wire          capture_active, //for debug only
    input wire          capture_go,
    output reg          adc_capture_stop,
    input wire          arm_i,
    input wire          arm_usb,
    input wire [15:0]   num_segments,
    input wire [19:0]   segment_cycles,
    input wire          segment_cycle_counter_en,

    //FIFO to USB Read Interface
    input wire          clk_usb,
    input wire          low_res,        // if set, return just 8 bits per sample; if clear return all 12 bits per sample
    input wire          low_res_lsb,    // useless except for testing: if set, return the 8 LSB bits when in low_res mode
    input wire [16:0]   stream_segment_threshold,
    input wire          fifo_read_fifoen,
    output wire         fifo_read_fifoempty,
    output reg  [7:0]   fifo_read_data,
    input  wire         fast_fifo_read_mode, // not to be confused with the ADC fast FIFO, this denote fast reading of the *slow* FIFO

    input wire  [14:0]  presample_i,
    input wire  [31:0]  max_samples_i,
    output wire [31:0]  max_samples_o,
    input wire  [12:0]  downsample_i, //Ignores this many samples inbetween captured measurements

    output wire         fifo_overflow, //If overflow happens (bad during stream mode)
    input  wire         stream_mode, //1=Enable stream mode, 0=Normal
    output reg          error_flag,
    output reg [10:0]   error_stat,
    output reg [10:0]   first_error_stat,
    output reg [2:0]    first_error_state,
    input  wire         clear_fifo_errors,
    output reg          stream_segment_available,
    input  wire         no_clip_errors,
    input  wire         no_gain_errors,
    input  wire         clip_test,
    output reg [7:0]    underflow_count,
    input  wire         no_underflow_errors,  // disables flagging of *slow* FIFO underflow errors only
    output reg          capture_done,
    output reg          armed_and_ready,
    output reg [2:0]    state,

    // DDR
    output wire [15:0]  ddr3_addr,
    output wire [2:0]   ddr3_ba,
    output wire         ddr3_cas_n,
    output wire         ddr3_ck_n,
    output wire         ddr3_ck_p,
    output wire         ddr3_cke,
    output wire         ddr3_ras_n,
    output wire         ddr3_reset_n,
    output wire         ddr3_we_n,
    inout  wire [7:0]   ddr3_dq,
    inout  wire         ddr3_dqs_n,
    inout  wire         ddr3_dqs_p,
    output wire         ddr3_dm,
    output wire         ddr3_cs_n,
    output wire         ddr3_odt,
    output wire [6:0]   ddr3_stat,
    output wire         ddr3_test_pass,
    output wire         ddr3_test_fail,
    input  wire         ddr3_test_clear_fail,
    input  wire         ddr3_rwtest_en,
    input  wire         use_ddr,           
    output wire [15:0]  ddr3_test_iteration,
    output wire [7:0]   ddr3_test_errors,
    output wire [31:0]  ddr3_read_read,
    output wire [31:0]  ddr3_read_idle,
    output wire [31:0]  ddr3_write_write,
    output wire [31:0]  ddr3_write_idle,
    output wire [15:0]  ddr3_max_read_stall_count,
    output wire [15:0]  ddr3_max_write_stall_count,
    input  wire [11:0]  temp_out,

    // CW310-specific:
    input wire          ADC_clk_fbp,
    input wire          ADC_clk_fbn,


    // for debug only:
    output reg          preddr_fifo_wr,
    output wire         postddr_fifo_rd,
    output reg  [31:0]  fifo_read_count,
    output reg  [31:0]  fifo_read_count_error_freeze,
    output reg          fifo_rst,
    output wire [7:0]   debug

);

    parameter pFIFO_FULL_SIZE = `MAX_SAMPLES;
    parameter pMAX_UNDERFLOWS = 3;
    parameter pDDR_INC_ADDR = 8'd8;
    parameter pDDR_MAX_ADDR = 30'h1FFF_FFF8;

    localparam CMD_WRITE = 3'b000;
    localparam CMD_READ  = 3'b001;

    wire                fast_fifo_wr;
    reg                 fast_fifo_presample_drain = 1'b0;
    reg                 fast_fifo_rd_en = 1'b0;
    wire                fast_fifo_rd;
    wire [11:0]         fast_fifo_dout;
    wire                fast_fifo_full;
    wire                fast_fifo_empty;
    wire                fast_fifo_overflow;
    wire                fast_fifo_underflow;

    reg                 slow_fifo_rd_slow;
    wire                slow_fifo_rd_fast;

    reg                 preddr_fifo_rd_slow;
    wire                preddr_fifo_rd_fast;
    reg  [63:0]         preddr_fifo_din;
    wire [63:0]         preddr_fifo_dout;
    wire                preddr_fifo_full;
    wire                preddr_fifo_empty;
    wire                preddr_fifo_overflow;
    wire                preddr_fifo_underflow;

    reg  [63:0]         postddr_fifo_din;
    reg                 postddr_fifo_prewr = 1'b0;
    reg                 postddr_fifo_rd_slow;
    wire                postddr_fifo_rd_fast;
    wire [63:0]         postddr_fifo_dout;
    wire                postddr_fifo_full;
    wire                postddr_fifo_prog_full;
    wire                postddr_fifo_empty;
    wire                postddr_fifo_overflow;
    wire                postddr_fifo_underflow;

    reg                 preddr_fifo_rd;
    reg                 preddr_fifo_rd_r;
    reg                 postddr_fifo_wr;

    reg                 fast_fifo_overflow_reg;
    reg                 preddr_fifo_overflow_reg;
    reg                 postddr_fifo_overflow_reg;
    reg  [14:0]         presample_counter;
    reg  [31:0]         sample_counter;
    reg  [15:0]         segment_counter;
    reg  [19:0]         segment_cycle_counter;

    reg                 arm_r;
    reg                 arm_fifo_rst_adc;
    wire                arm_fifo_rst_usb;
    reg                 arming;
    reg                 capture_go_r;
    reg                 capture_go_r2;
    wire                capture_go_ui;

    reg                 postddr_fifo_underflow_sticky;
    reg [1:0]           postddr_fifo_underflow_count;
    reg                 postddr_fifo_underflow_masked;

    reg  [4:0]          done_wait_count;
    reg                 gain_error;
    reg                 segment_error;
    reg                 clip_error;
    reg                 gain_too_low;
    reg                 downsample_error;
    wire                clear_fifo_errors_adc;

    reg                 fifo_rst_pre;
    reg                 reset_done;
    reg [31:0]          read_count;
    reg                 first_read;
    reg                 first_read_done;

    // application interface to DDR3:
    wire [29:0]         app_addr;
    wire [2:0]          app_cmd;
    wire                app_en;
    wire [31:0]         app_wdf_data;
    wire                app_wdf_end;
    wire                app_wdf_wren;

    wire [29:0]         rwtest_app_addr;
    wire [2:0]          rwtest_app_cmd;
    wire                rwtest_app_en;
    wire [31:0]         rwtest_app_wdf_data;
    wire                rwtest_app_wdf_end;
    wire                rwtest_app_wdf_wren;

    reg  [29:0]         adc_app_addr;
    wire [2:0]          adc_app_cmd;
    reg                 adc_app_en;
    wire [31:0]         adc_app_wdf_data;
    reg                 adc_app_wdf_end;
    reg                 adc_app_wdf_wren;

    wire                ui_clk;
    wire                ui_clk_sync_rst; // TODO: do we need this output?
    wire [31:0]         app_rd_data;
    reg  [31:0]         app_rd_data_r;
    wire                app_rd_data_end;
    wire                app_rd_data_valid;
    wire                app_rdy;
    wire                app_wdf_rdy;

    wire [255:0]        ddr3_ila_basic_w;

    wire  dbg_pi_phaselock_err;
    wire  dbg_pi_dqsfound_err;
    wire  dbg_wrlvl_err;
    wire [1:0] dbg_rdlvl_err;
    wire  dbg_wrcal_err;
    wire  init_calib_complete;

    wire [3:0] ddr3_test_state;
    wire ddr3_test_comp_error;
    wire ddr3_test_comp_good;
    wire [31:0] ddr3_test_expected_data;
    wire [29:0] ddr3_test_verify_addr;
    wire [31:0] ddr3_test_lfsr;

    assign dbg_pi_phaselock_err = ddr3_ila_basic_w[6];
    assign dbg_pi_dqsfound_err  = ddr3_ila_basic_w[9];
    assign dbg_wrlvl_err        = ddr3_ila_basic_w[3];
    assign dbg_rdlvl_err        = ddr3_ila_basic_w[15:14];
    assign dbg_wrcal_err        = ddr3_ila_basic_w[21];

    assign ddr3_stat = {dbg_pi_phaselock_err,
                        dbg_pi_dqsfound_err,
                        dbg_wrlvl_err,
                        dbg_rdlvl_err,
                        dbg_wrcal_err,
                        init_calib_complete
                       };

    assign fifo_overflow = fast_fifo_overflow_reg || preddr_fifo_overflow_reg || postddr_fifo_overflow_reg;

    // make overflow sticky:
    always @(posedge adc_sampleclk) begin
       if (fifo_rst) begin
          fast_fifo_overflow_reg <= 1'b0;
          preddr_fifo_overflow_reg <= 1'b0;
       end
       else begin
          if (fast_fifo_overflow)
             fast_fifo_overflow_reg <= 1'b1;
          if (preddr_fifo_overflow)
             preddr_fifo_overflow_reg <= 1'b1;
       end
    end

    always @(posedge ui_clk) begin
       if (fifo_rst)
          postddr_fifo_overflow_reg <= 1'b0;
       else if (postddr_fifo_overflow)
          postddr_fifo_overflow_reg <= 1'b1;
    end


    assign fifo_read_fifoempty = postddr_fifo_empty;

    //Counter for downsampling (NOT proper decimation)
    reg [12:0] downsample_ctr;
    wire downsample_max;
    reg downsample_wr_en;

    assign downsample_max = (downsample_ctr == downsample_i) ? 1'b1 : 'b0;

    always @(posedge adc_sampleclk) begin
       if (arm_fifo_rst_adc == 1'b1) begin
          downsample_ctr <= 13'd0;
          downsample_wr_en <= 1'b0;
       end 
       else begin
          // NOTE: capture_go_r* condition is to align downsample captures on
          // the trigger event. If downsample+presample support gets added,
          // this condition makes it possible to have two successive writes
          // that are very close together.
          if (downsample_max || (capture_go_r && ~capture_go_r2)) begin
             downsample_ctr <= 13'd0;
             downsample_wr_en <= 1'b1;
          end
          else begin
             downsample_ctr <= downsample_ctr + 13'd1;
             downsample_wr_en <= 1'b0;
          end
       end
    end

    assign max_samples_o = pFIFO_FULL_SIZE;


    // Presample logic: when armed, we always write to the fast FIFO. When
    // we reach the requested number of presamples, we start to also read
    // and discard, so as to keep exactly the requested number of presamples
    // in the fast FIFO. During this time, no data is sent to the slow FIFO.
    // When the trigger is received, the fast FIFO read data is then written
    // to the slow FIFO.

    localparam pS_IDLE = 0;
    localparam pS_PRESAMP_FILLING = 1;
    localparam pS_PRESAMP_FULL = 2;
    localparam pS_TRIGGERED = 3;
    localparam pS_SEGMENT_DONE = 4;
    localparam pS_DONE = 5;
    reg [2:0] state_r;

    // strictly for easier debugging:
    wire state_idle = (state == pS_IDLE);
    wire state_presamp_filling = (state == pS_PRESAMP_FILLING);
    wire state_presamp_full = (state == pS_PRESAMP_FULL);
    wire state_triggered = (state == pS_TRIGGERED);
    wire state_segment_done = (state == pS_SEGMENT_DONE);
    wire state_done = (state == pS_DONE);

    wire stop_capture_conditions;
    reg fsm_fast_wr_en;
    reg [19:0] segment_cycles_adjusted;

    assign stop_capture_conditions = fifo_rst_pre || adc_capture_stop;

    reg  presamp_done1_r;
    wire presamp_done1 = (capture_go && (segment_counter == 0));
    wire next_segment_go_pre = segment_cycle_counter_en?  ((segment_cycle_counter == segment_cycles_adjusted) && (segment_cycles > 0)) :
                                                          (capture_go && ~capture_go_r);

    wire presamp_done = presamp_done1_r || next_segment_go;
    wire presamp_error = presamp_done && (state == pS_PRESAMP_FILLING);

    reg next_segment_go;
    reg last_segment;
    reg last_sample;
    reg filler_read;
    // We're storing 12-bit samples into 64-bit words. If the number of samples is not a multiple of 
    // 16 (because 16 is the smallest number x such that x*12 is a number that can be divided by 64), 
    // then we need to execute dummy/filler ADC reads to fill out the last incomplete 64-bit word.
    wire filler_read_needed = (max_samples_i[3:0] != 4'b0000);

    always @(posedge adc_sampleclk) begin
        if (segment_cycles > 1) // alternatively, could do this in Python instead  (but why- everything works now)
            segment_cycles_adjusted <= segment_cycles - 2;
        else
            segment_cycles_adjusted <= segment_cycles;
        next_segment_go <= next_segment_go_pre; // this would add a cycle of latency but we've compensate by registering the ADC input in openadc_interface.v
        last_segment <= (segment_counter == (num_segments-1));
        if (downsample_i > 0)
            last_sample <= (sample_counter == (max_samples_i-1));
        else
            last_sample <= (sample_counter == (max_samples_i-2));
        presamp_done1_r <= presamp_done1;
    end

    always @ (posedge adc_sampleclk) begin
        if (reset) begin
            clip_error <= 1'b0;
            gain_too_low <= 1'b0;
            gain_error <= 1'b0;
        end
        else begin
            if (no_clip_errors || clear_fifo_errors_adc)
                clip_error <= 1'b0;
            //  TODO: just condition on "ADC fifo out when triggered" sort of thing
            else if (preddr_fifo_wr && (fast_fifo_dout[11:0]  == {12{1'b1}} || fast_fifo_dout[11:0]  == {12{1'b0}}) )
                clip_error <= 1'b1;
            else if (clip_test)
                clip_error <= adc_datain == {12{1'b1}} || adc_datain == {12{1'b0}};

            if (no_gain_errors || clear_fifo_errors_adc)
                gain_too_low <= 1'b0;
            else if (capture_go)
                gain_too_low <= 1'b1;
            else if (preddr_fifo_wr && (fast_fifo_dout[11]? fast_fifo_dout[10:9]  != 2'b00 : fast_fifo_dout[10:8]  != 3'b111) )
                gain_too_low <= 1'b0;

            if (no_gain_errors || clear_fifo_errors_adc)
                gain_error <= 1'b0;
            else if ((state == pS_IDLE) && (state_r == pS_DONE) && gain_too_low)
                gain_error <= 1'b1;
        end
    end

    always @ (posedge adc_sampleclk) begin
       if (reset) begin
          state <= pS_IDLE;
          presample_counter <= 0;
          sample_counter <= 0;
          fast_fifo_presample_drain <= 1'b0;
          adc_capture_stop <= 1'b0;
          fast_fifo_rd_en <= 1'b0;
          segment_counter <= 0;
          segment_cycle_counter <= 0;
          downsample_error <= 1'b0;
          segment_error <= 1'b0;
          filler_read <= 1'b0;
       end

       else begin
          state_r <= state;
          case (state)

             pS_IDLE: begin
                presample_counter <= 0;
                sample_counter <= 0;
                fast_fifo_presample_drain <= 1'b0;
                adc_capture_stop <= 1'b0;
                fast_fifo_rd_en <= 1'b0;
                segment_counter <= 0;
                segment_cycle_counter <= 0;
                segment_error <= 1'b0;
                fsm_fast_wr_en <= 1'b0;
                filler_read <= 1'b0;
                done_wait_count <= 0;

                if ((downsample_i > 0) && ((presample_i > 0) || (num_segments > 1)))
                   downsample_error <= 1'b1;
                else
                   downsample_error <= 1'b0;

                if (armed_and_ready && ~adc_capture_stop && ~ddr3_rwtest_en) begin
                   if (presample_i > 0) begin
                      fsm_fast_wr_en <= 1'b1;
                      state <= pS_PRESAMP_FILLING;
                   end
                   else if (capture_go_r) begin
                      fsm_fast_wr_en <= 1'b1;
                      state <= pS_TRIGGERED;
                   end
                end
             end

             pS_PRESAMP_FILLING: begin
                fast_fifo_presample_drain <= 1'b0;
                if (next_segment_go && (state_r == pS_PRESAMP_FILLING))
                   segment_error <= 1'b1;
                if (segment_counter > 0)
                   segment_cycle_counter <= segment_cycle_counter + 1;
                if (stop_capture_conditions) begin
                   fsm_fast_wr_en <= 1'b0;
                   state <= pS_DONE;
                end
                else if (presamp_done) begin
                   state <= pS_TRIGGERED;
                end
                else if (presample_counter == (presample_i-2)) begin
                   state <= pS_PRESAMP_FULL;
                end
                else if (fast_fifo_wr) begin
                   presample_counter <= presample_counter + 1;
                end
             end

             pS_PRESAMP_FULL: begin
                if (segment_counter > 0)
                   segment_cycle_counter <= segment_cycle_counter + 1;
                if (stop_capture_conditions) begin
                   fsm_fast_wr_en <= 1'b0;
                   state <= pS_DONE;
                end
                else if (presamp_done) begin
                   segment_cycle_counter <= 0;
                   sample_counter <= presample_i;
                   state <= pS_TRIGGERED;
                end
                if (fast_fifo_wr)
                   fast_fifo_presample_drain <= 1'b1;
                else
                   fast_fifo_presample_drain <= 1'b0;
             end

             pS_TRIGGERED: begin
                if (next_segment_go && (state_r == pS_TRIGGERED))
                   segment_error <= 1'b1;
                fast_fifo_presample_drain <= 1'b0;
                fast_fifo_rd_en <= 1'b1;
                segment_cycle_counter <= segment_cycle_counter + 1;

                if (stop_capture_conditions || (last_sample && fast_fifo_wr && last_segment)) begin
                   adc_capture_stop <= 1'b1;
                   done_wait_count <= 20;  // established by trial/error to account for the latency in the Xilinx FIFO updating its empty flag
                                           // plus extra cycles to execute filler_read (to generate the last 64-bit word)
                                           // TODO: update to 20 for Pro needs to be more carefully checked; it was chosen because it looked like
                                           // it should work.
                   fsm_fast_wr_en <= 1'b0;
                   state <= pS_DONE;
                end

                else if (last_sample && ~last_segment && fast_fifo_wr) begin
                   fsm_fast_wr_en <= 1'b0;
                   state <= pS_SEGMENT_DONE;
                end

                if (fast_fifo_wr) begin
                   sample_counter <= sample_counter + 1;
                end
             end

             pS_SEGMENT_DONE: begin
                segment_cycle_counter <= segment_cycle_counter + 1;
                if (fast_fifo_empty) begin
                   fast_fifo_rd_en <= 1'b0;
                   if (presample_i > 0) begin
                      segment_counter <= segment_counter + 1;
                      sample_counter <= 0;
                      presample_counter <= 0;
                      fsm_fast_wr_en <= 1'b1;
                      state <= pS_PRESAMP_FILLING;
                   end
                   else if (next_segment_go) begin
                      segment_counter <= segment_counter + 1;
                      segment_cycle_counter <= 0;
                      sample_counter <= 0;
                      fsm_fast_wr_en <= 1'b1;
                      state <= pS_TRIGGERED;
                   end
                end
                else if (next_segment_go) begin
                   segment_error <= 1'b1;
                   state <= pS_IDLE;
                end
             end

             pS_DONE: begin
                // serves three purposes:
                // 1. wait for fast FIFO to empty;
                // 2. generate "filler reads" so that the last full 64-bit word of ADC samples can be formed
                // 3. wait state so that we don't get back out of idle right away
                // TODO: need extra conditions for DDR?
                // TODO: this is assuming that fast FIFO is empty when we get here!
                if ((fast_fifo_empty && (done_wait_count == 0)) || arm_i) begin
                   fast_fifo_rd_en <= 1'b0;
                   state <= pS_IDLE;
                end
                else
                   done_wait_count <= done_wait_count - 1;
                if (filler_read_needed && (done_wait_count < 6)) // TODO: "5" is just a placeholder; need to calculate correct value here!
                   filler_read <= 1'b1;
             end

          endcase
       end
    end

    always @(posedge adc_sampleclk) begin
       if (arm_fifo_rst_adc)
          capture_done <= 1'b0;
       else if (state == pS_DONE)
          capture_done <= 1'b1;
    end


   (* ASYNC_REG = "TRUE" *) reg[1:0] reset_done_pipe;
   reg reset_done_r;
   reg reset_done_r2;

   (* ASYNC_REG = "TRUE" *) reg[1:0] clear_fifo_errors_pipe;
   reg clear_fifo_errors_r;
   reg clear_fifo_errors_r2;
   assign clear_fifo_errors_adc = clear_fifo_errors_r2;


    always @(posedge adc_sampleclk) begin
       if (reset) begin
          reset_done_pipe <= 0;
          reset_done_r <= 1'b0;
          reset_done_r2 <= 1'b0;
          clear_fifo_errors_pipe <= 0;
          clear_fifo_errors_r <= 1'b0;
          clear_fifo_errors_r2 <= 1'b0;
          arming <= 1'b0;
          armed_and_ready <= 1'b0;
          capture_go_r <= 1'b0;
          capture_go_r2 <= 1'b0;
       end
       else begin
          capture_go_r <= capture_go;
          capture_go_r2 <= capture_go_r;
          {reset_done_r2, reset_done_r, reset_done_pipe} <= {reset_done_r, reset_done_pipe, reset_done};
          {clear_fifo_errors_r2, clear_fifo_errors_r, clear_fifo_errors_pipe} <= {clear_fifo_errors_r, clear_fifo_errors_pipe, clear_fifo_errors};
          arm_r <= arm_i;
          arm_fifo_rst_adc <= ~arm_r & arm_i;
          if (arm_i && ~arm_r && ~arming) begin
             arming <= 1'b1;
             armed_and_ready <= 1'b0;
          end
          else if (arming && ~reset_done_r2 && reset_done_r) begin
             arming <= 1'b0;
             armed_and_ready <= 1'b1;
          end
          else if (adc_capture_stop)
             armed_and_ready <= 1'b0;
       end
    end

    assign fast_fifo_wr = downsample_wr_en & fsm_fast_wr_en & reset_done & !fifo_rst_pre;

    // Xilinx FIFO is very particular about its reset: it must be wide enough
    // and the FIFO shouldn't be accessed for some time after reset has been
    // released. USB (slow) clock is 96 MHz, ADC (fast) clock is anywhere from
    // 5 to 200 MHz.  So we make the FIFO reset four 5 MHz cycles long = 76 USB
    // clocks, and prevent FIFO access for thirty 5 MHz cycles = 570 USB clocks
    // after reset. (Ref: Xilinx PG057 v13.2, p.129).
    // FIFO reset is initiated by arm_fifo_rst_usb, which comes from arming.

    assign arm_fifo_rst_usb = arm_usb && ~arm_usb_r;

    wire fifo_rst_start = arm_fifo_rst_usb || reset;
    reg fifo_rst_start_r;

    reg [6:0] reset_hi_count;
    reg [9:0] reset_lo_count;
    reg arm_usb_r;
    always @(posedge clk_usb) begin
       fifo_rst <= fifo_rst_pre;
       fifo_rst_start_r <= fifo_rst_start;
       arm_usb_r <= arm_usb;
       if (fifo_rst_start_r) begin
          fifo_rst_pre <= 1'b1;
          reset_hi_count <= 1;
          reset_lo_count <= 1;
          reset_done <= 1'b0;
       end
       else if (reset_hi_count > 0) begin
          if (reset_hi_count < 76)
             reset_hi_count <= reset_hi_count + 1;
          else begin
             reset_hi_count <= 0;
             fifo_rst_pre <= 0;
          end
       end
       else if (reset_lo_count > 0) begin
          if (reset_lo_count < 576)
             reset_lo_count <= reset_lo_count + 1;
          else begin
             reset_hi_count <= 0;
             reset_lo_count <= 0;
             reset_done <= 1'b1;
          end
       end
    end


    always @(*) begin
       if (stream_mode)
          postddr_fifo_underflow_masked = postddr_fifo_underflow && (read_count < max_samples_i) && ~no_underflow_errors;
       else
          postddr_fifo_underflow_masked = postddr_fifo_underflow && ~no_underflow_errors && (postddr_fifo_underflow_count == pMAX_UNDERFLOWS);
    end

    function [10:0] error_bits (input [10:0] current_error);
       begin
          error_bits = current_error;
          if (preddr_fifo_overflow)          error_bits[10] = 1'b1;
          if (preddr_fifo_underflow)         error_bits[9]  = 1'b1;
          if (gain_error)                    error_bits[8]  = 1'b1;
          if (segment_error)                 error_bits[7]  = 1'b1;
          if (downsample_error)              error_bits[6]  = 1'b1;
          if (clip_error)                    error_bits[5]  = 1'b1;
          if (presamp_error)                 error_bits[4]  = 1'b1;
          if (fast_fifo_overflow)            error_bits[3]  = 1'b1;
          if (fast_fifo_underflow)           error_bits[2]  = 1'b1;
          if (postddr_fifo_overflow)         error_bits[1]  = 1'b1;
          if (postddr_fifo_underflow_masked) error_bits[0]  = 1'b1;
       end
    endfunction

    always @(posedge clk_usb) begin
       if (reset) begin
          error_flag <= 0;
          error_stat <= 0;
          first_error_stat <= 0;
          underflow_count <= 0;
          first_error_state <= pS_IDLE;
       end
       else begin
          if (fifo_rst_start_r || clear_fifo_errors) begin
             error_stat <= 0;
             first_error_stat <= 0;
             error_flag <= 0;
             underflow_count <= 0;
             first_error_state <= pS_IDLE;
          end
          else begin
             if (gain_error || segment_error || downsample_error || clip_error || presamp_error || 
                 fast_fifo_overflow || fast_fifo_underflow || postddr_fifo_overflow || postddr_fifo_underflow_masked || 
                 preddr_fifo_overflow || preddr_fifo_underflow) begin
                error_flag <= 1;
                if (!error_flag) begin
                   first_error_stat <= error_bits(first_error_stat);
                   first_error_state <= state_r;
                end
             end

             error_stat <= error_bits(error_stat);

             if (postddr_fifo_underflow_masked && (underflow_count != 8'hFF))
                underflow_count <= underflow_count + 1;
          end
       end
    end

    always @(posedge clk_usb) begin
       if (reset) begin
          postddr_fifo_underflow_sticky <= 0;
          postddr_fifo_underflow_count <= 0;
       end
       else begin
          // Xilinx FIFO asserts "underflow" for a single cycle only:
          if (fifo_rst_start_r)
             postddr_fifo_underflow_sticky <= 0;
          else if (postddr_fifo_underflow)
             postddr_fifo_underflow_sticky <= 1;

          // SAM3U likes to read multiples of 4 bytes, so we don't flag an
          // underflow unless we observe at least 3 underflow reads
          if (fifo_rst_start_r)
             postddr_fifo_underflow_count <= 0;
          else if (postddr_fifo_underflow && postddr_fifo_underflow_count < pMAX_UNDERFLOWS)
             postddr_fifo_underflow_count <= postddr_fifo_underflow_count + 1;

       end
    end


    // Assemble 64-bit words from 12-bit samples to feed DDR.
    // Ideally we'd handle this with an asymetric+asynchronous FIFO, but Xilinx's simulation
    // model for such FIFOs doesn't simulate with iVerilog :-(
    // So this is the width conversion stage, which is followed by an asynchronous FIFO.
    // *must* be able to push one sample per cycle, to keep up.
    // But if decimation is used, then data will come in slower; must accomodate that too.
    // Word 1: 6 sample reads; 5x12, 4
    // Word 2: 5 sample reads; 8, 4x12, 8
    // Word 3: 5 sample reads; 4, 5x12
    // then start over...
    reg [1:0] wide_word_count;
    reg wide_word_valid;
    reg [71:0] wide_word_shifter;
    reg [3:0] adc_sample_counter;

    always @(posedge adc_sampleclk) begin
        if (reset) begin
            wide_word_count <= 0;
            wide_word_valid <= 0;
            wide_word_shifter <= 0;
            adc_sample_counter <= 0;
            preddr_fifo_din <= 0;
            preddr_fifo_wr <= 0;
            filler_write <= 0;
        end
        else begin
            preddr_fifo_wr <= wide_word_valid;
            filler_write <= wide_word_valid && filler_read;
            if (state == pS_IDLE) begin
                wide_word_count <= 0;
                wide_word_valid <= 0;
                wide_word_shifter <= 0;
                adc_sample_counter <= 0;
            end
            else if ((fast_fifo_rd || filler_read) && (state != pS_PRESAMP_FILLING) && (state != pS_PRESAMP_FULL)) begin
                wide_word_shifter <= {wide_word_shifter[63:0], fast_fifo_dout};
                if ( ((wide_word_count == 0) && (adc_sample_counter == 5)) ||
                     ((wide_word_count == 1) && (adc_sample_counter == 4)) ||
                     ((wide_word_count == 2) && (adc_sample_counter == 4)) ) begin
                    wide_word_valid <= 1'b1;
                    adc_sample_counter <= 0;
                    if (wide_word_count < 2)
                        wide_word_count <= wide_word_count + 1;
                    else
                        wide_word_count <= 0;
                end
                else begin
                    wide_word_valid <= 0;
                    adc_sample_counter <= adc_sample_counter + 1;
                end
            end
            else if (~filler_read)
                wide_word_valid <= 0;

            if (wide_word_valid)
                preddr_fifo_din <= (wide_word_count == 1)? wide_word_shifter[71:8] :
                                   (wide_word_count == 2)? wide_word_shifter[67:4] :
                                                           wide_word_shifter[63:0] ;
        end
    end

    assign app_addr     = (ddr3_rwtest_en)? rwtest_app_addr     : adc_app_addr;
    assign app_cmd      = (ddr3_rwtest_en)? rwtest_app_cmd      : adc_app_cmd;
    assign app_en       = (ddr3_rwtest_en)? rwtest_app_en       : adc_app_en;
    assign app_wdf_data = (ddr3_rwtest_en)? rwtest_app_wdf_data : adc_app_wdf_data;
    assign app_wdf_end  = (ddr3_rwtest_en)? rwtest_app_wdf_end  : adc_app_wdf_end;
    assign app_wdf_wren = (ddr3_rwtest_en)? rwtest_app_wdf_wren : adc_app_wdf_wren;

    localparam pS_DDR_IDLE            = 3'd0;
    localparam pS_DDR_WRITE1          = 3'd1;
    localparam pS_DDR_WRITE2          = 3'd2;
    localparam pS_DDR_WAIT_READ       = 3'd3;
    localparam pS_DDR_READ1           = 3'd4;
    localparam pS_DDR_READ2           = 3'd5;
    localparam pS_DDR_WAIT_WRITE      = 3'd6;
    localparam pS_DDR_BYPASS          = 3'd7;
    reg [2:0] ddr_state, next_ddr_state;

    reg ddr_full_error; // TODO: store this
    reg ddr_write_data_done;
    reg write_data_done_hold;
    reg filler_write;
    reg  write_done_adc;
    wire write_done_ui;
    wire ddr_read_data_done = (adc_top_app_addr == adc_app_addr);
    reg incr_app_address;

    reg reset_app_address;
    reg [29:0] adc_top_app_addr;

    always @ (*) begin
        if (filler_read_needed)
            write_done_adc = filler_write;
        else
            write_done_adc = (state == pS_IDLE) && (state_r == pS_DONE);
    end

    cdc_pulse U_write_done_cdc (
       .reset_i       (reset),
       .src_clk       (adc_sampleclk),
       .src_pulse     (write_done_adc),
       .dst_clk       (ui_clk),
       .dst_pulse     (write_done_ui)
    );

    cdc_pulse U_capture_go_cdc (
       .reset_i       (reset),
       .src_clk       (adc_sampleclk),
       .src_pulse     (capture_go_r && ~capture_go_r2),
       .dst_clk       (ui_clk),
       .dst_pulse     (capture_go_ui)
    );

    wire ddr_writing = (ddr_state == pS_DDR_WAIT_WRITE) ||
                       (ddr_state == pS_DDR_WRITE1) ||
                       (ddr_state == pS_DDR_WRITE2);
    wire ddr_reading = (ddr_state == pS_DDR_WAIT_READ) ||
                       (ddr_state == pS_DDR_READ1) ||
                       (ddr_state == pS_DDR_READ2);

    assign adc_app_cmd = (ddr_writing)? CMD_WRITE : CMD_READ;

    assign adc_app_wdf_data = (ddr_state == pS_DDR_WRITE1)? preddr_fifo_dout[31:0] : 
                              (ddr_state == pS_DDR_WRITE2)? preddr_fifo_dout[63:32] : 32'b0;

    // Read/Write DDR: derived from the simple_ddr3_rwtest FSM
    always @(*) begin
        // defaults:
        adc_app_en = 1'b0;
        adc_app_wdf_wren = 1'b0;
        adc_app_wdf_end = 1'b0;
        incr_app_address = 1'b0;
        reset_app_address = 1'b0;
        preddr_fifo_rd = 1'b0;
        next_ddr_state = pS_DDR_IDLE;

        case (ddr_state)
            pS_DDR_IDLE: begin
                if (capture_go_ui && ~ddr3_rwtest_en) begin
                    if (use_ddr && init_calib_complete) begin
                        reset_app_address = 1'b1;
                        next_ddr_state = pS_DDR_WAIT_WRITE;
                    end
                    else
                        next_ddr_state = pS_DDR_BYPASS;
                end
                else
                    next_ddr_state = pS_DDR_IDLE;
            end

            pS_DDR_BYPASS: begin
                if (use_ddr)
                    next_ddr_state = pS_DDR_IDLE;
                else begin
                    next_ddr_state = pS_DDR_BYPASS;
                    // extra checks here to throttle the reads and ensure we don't overflow the FIFO; 
                    // it's ok if we don't read back-to-back.
                    if (~preddr_fifo_empty && ~postddr_fifo_full && ~preddr_fifo_rd_r && ~postddr_fifo_wr)
                        preddr_fifo_rd = 1'b1;
                end
            end

            pS_DDR_WAIT_WRITE: begin
                // This is where we can transition from writing DDR to reading
                // it, to pre-fill the read FIFO so that data is waiting and
                // ready to be read ASAP. We want to switch to reading as fast
                // as possible (consider streaming), but we need to use care to
                // ensure we don't miss the last write. This is not
                // straightforward to the different clock domains and unknown
                // clock ratios (e.g. preddr write clock could be faster or
                // slower than read clock). We keep it simple by CDC'ing going
                // from pS_DONE to pS_IDLE, then waiting for the preddr FIFO to
                // go empty.
                if (capture_go_ui)
                    next_ddr_state = pS_DDR_IDLE;
                else if (ddr_write_data_done) begin
                    reset_app_address = 1'b1;
                    next_ddr_state = pS_DDR_WAIT_READ;
                end
                else if (app_rdy && app_wdf_rdy && ~preddr_fifo_empty) begin
                    preddr_fifo_rd = 1'b1;
                    next_ddr_state = pS_DDR_WRITE1;
                end
                else
                    next_ddr_state = pS_DDR_WAIT_WRITE;
            end

            pS_DDR_WRITE1: begin
                adc_app_en = 1'b1;
                adc_app_wdf_wren = 1'b1;
                adc_app_wdf_end = 1'b0;
                if (app_rdy && app_wdf_rdy)
                    next_ddr_state = pS_DDR_WRITE2;
                else
                    next_ddr_state = pS_DDR_WRITE1;
            end

            pS_DDR_WRITE2: begin
                adc_app_en = 1'b0;
                adc_app_wdf_wren = 1'b1;
                adc_app_wdf_end = 1'b1;
                if (app_wdf_rdy) begin
                    if (ddr_write_data_done) begin
                        reset_app_address = 1'b1;
                        next_ddr_state = pS_DDR_WAIT_READ;
                    end
                    else begin
                        incr_app_address = 1'b1;
                        if (app_rdy && ~preddr_fifo_empty) begin
                            preddr_fifo_rd = 1'b1;
                            next_ddr_state = pS_DDR_WRITE1;
                        end
                        else
                            next_ddr_state = pS_DDR_WAIT_WRITE;
                    end
                end
                else
                    next_ddr_state = pS_DDR_WRITE2;
            end

            pS_DDR_WAIT_READ: begin
                adc_app_en = 1'b0;
                if (ddr3_rwtest_en || capture_go_ui)
                    next_ddr_state = pS_DDR_IDLE;
                else if (app_rdy && ~postddr_fifo_prog_full)
                    next_ddr_state = pS_DDR_READ1;
                else
                    next_ddr_state = pS_DDR_WAIT_READ;
            end

            pS_DDR_READ1: begin
                adc_app_en = 1'b1;
                if (app_rdy) begin
                    incr_app_address = 1'b1;
                    next_ddr_state = pS_DDR_READ2;
                end
                else
                    next_ddr_state = pS_DDR_READ1;
            end

            pS_DDR_READ2: begin
                adc_app_en = 1'b0;
                if (ddr_read_data_done)
                    next_ddr_state = pS_DDR_IDLE;
                else if (app_rdy && ~postddr_fifo_prog_full)
                    next_ddr_state = pS_DDR_READ1;
                else
                    next_ddr_state = pS_DDR_WAIT_READ;
            end

            default: begin
                next_ddr_state = pS_DDR_IDLE;
            end

        endcase
    end

    // DDR FSM sequential control logic and slow FIFO writes:
    always @(posedge ui_clk) begin
        if (reset) begin
            ddr_state <= pS_DDR_IDLE;
            adc_app_addr <= 0;
            ddr_full_error <= 0;
            postddr_fifo_wr <= 0;
            ddr_write_data_done <= 0;
            write_data_done_hold <= 0;
            preddr_fifo_rd_r <= 0;
            adc_top_app_addr <= 0;
        end

        else begin
            ddr_state <= next_ddr_state;
            preddr_fifo_rd_r <= preddr_fifo_rd;
            // TODO (later): clear mechanism for ddr_full_error
            if (reset_app_address) begin
                adc_app_addr <= 0;
                if (ddr_state != pS_DDR_IDLE) begin
                    if (ddr_state == pS_DDR_WAIT_WRITE)
                        adc_top_app_addr <= adc_app_addr;
                    else
                        adc_top_app_addr <= adc_app_addr + pDDR_INC_ADDR;
                end
            end
            else if (incr_app_address) begin
                if (adc_app_addr == pDDR_MAX_ADDR)
                    ddr_full_error <= 1'b1;
                else
                    adc_app_addr <= adc_app_addr + pDDR_INC_ADDR;
            end

            if (ddr3_rwtest_en)
                postddr_fifo_wr <= 1'b0;

            else if (use_ddr && app_rd_data_valid) begin
                app_rd_data_r <= app_rd_data;
                if (app_rd_data_end) begin
                    postddr_fifo_wr <= 1'b1;
                    postddr_fifo_din <= {app_rd_data, app_rd_data_r};
                end
                else
                    postddr_fifo_wr <= 1'b0;
            end

            else if (~use_ddr) begin
                // in this case DDR is bypassed: data is read from preddr and
                // immediately written to postddr
                postddr_fifo_wr <= preddr_fifo_rd_r;
                postddr_fifo_din <= preddr_fifo_dout;
            end

            else
                postddr_fifo_wr <= 1'b0;

            if (ddr_state == pS_DDR_IDLE) begin
                write_data_done_hold <= 1'b0;
                ddr_write_data_done <= 1'b0;
            end
            else begin
                if (write_done_ui)
                    write_data_done_hold <= 1'b1;
                if (preddr_fifo_empty && write_data_done_hold)
                    ddr_write_data_done <= 1'b1;
            end

        end

    end



    // Read slow FIFO: TODO!
    reg [3:0] slow_read_count;
    always @(posedge clk_usb) begin
       if (reset || ~reset_done) begin
          slow_read_count <= 0;
          slow_fifo_rd_slow <= 1'b0;
       end

       else if (fifo_read_fifoen || first_read) begin
          if (low_res) begin // TODO (later) return 8 bits per sample
             if (slow_read_count < 2) begin
                slow_read_count <= slow_read_count + 1;
                slow_fifo_rd_slow <= 1'b0;
             end
             else begin
                slow_read_count <= 0;
                slow_fifo_rd_slow <= 1'b1;
             end
          end

          else begin // hi_res, return all 12 bits per sample
             if (slow_read_count < 7) begin
                slow_fifo_rd_slow <= 0;
                slow_read_count <= slow_read_count + 1;
             end
             else begin
                slow_fifo_rd_slow <= 1;
                slow_read_count <= 0;
             end
          end
       end
       else
          slow_fifo_rd_slow <= 1'b0;
    end

    assign slow_fifo_rd_fast = fifo_read_fifoen && (low_res? (slow_read_count == 2) : ((slow_read_count == 3) || (slow_read_count == 8))); // TODO!
    assign postddr_fifo_rd = (fast_fifo_read_mode)? slow_fifo_rd_fast : slow_fifo_rd_slow;

    reg [7:0] fifo_read_data_pre;
    always @(*) begin
       if (postddr_fifo_underflow_sticky)
          fifo_read_data_pre = 0;
       else if (low_res) begin // TODO (later)
          if (low_res_lsb)
             fifo_read_data_pre = postddr_fifo_dout[(2-slow_read_count)*12 +: 8];
          else
             fifo_read_data_pre = postddr_fifo_dout[(2-slow_read_count)*12 + 4 +: 8];
       end
       else
          fifo_read_data_pre = postddr_fifo_dout[(7-slow_read_count)*8 +: 8];
    end
    // register the FIFO output to help meet timing
    always @(posedge clk_usb) begin
        if (fifo_rst) begin
            first_read <= 1'b0;
            first_read_done <= 1'b0;
        end
        else if (first_read) begin
            first_read <= 1'b0;
            first_read_done <= 1'b1;
        end
        else if (!postddr_fifo_empty && !first_read_done) begin
            first_read <= 1'b1;
        end

        if (fifo_read_fifoen || first_read) fifo_read_data <= fifo_read_data_pre;

    end

    assign fast_fifo_rd = fast_fifo_presample_drain || (fast_fifo_rd_en && !preddr_fifo_full && !fast_fifo_empty);

    `ifdef NOFIFO
       //for clean iverilog compilation

    `elsif TINYFIFO
       //for faster corner case simulation- TODO: update for Pro
       tiny_adc_fast_fifo U_adc_fast_fifo(
          .clk          (adc_sampleclk),
          .rst          (fifo_rst),
          .din          (adc_datain),
          .wr_en        (fast_fifo_wr),
          .rd_en        (fast_fifo_rd),
          .dout         (fast_fifo_dout),
          .full         (fast_fifo_full),
          .empty        (fast_fifo_empty),
          .overflow     (fast_fifo_overflow),
          .underflow    (fast_fifo_underflow)
       );

       tiny_usb_slow_fifo U_usb_slow_fifo(
          .rst          (fifo_rst),
          .wr_clk       (adc_sampleclk),
          .rd_clk       (clk_usb),
          .din          (slow_fifo_din),
          .wr_en        (slow_fifo_wr),
          .rd_en        (slow_fifo_rd),
          .dout         (slow_fifo_dout),
          .full         (slow_fifo_full),
          .empty        (slow_fifo_empty),
          .overflow     (slow_fifo_overflow),
          .underflow    (slow_fifo_underflow)
       );


    `else
       //normal case
       adc_fast_fifo U_adc_fast_fifo (
          .clk          (adc_sampleclk),
          .rst          (fifo_rst),
          .din          (adc_datain),
          .wr_en        (fast_fifo_wr),
          .rd_en        (fast_fifo_rd),
          .dout         (fast_fifo_dout),
          .full         (fast_fifo_full),
          .empty        (fast_fifo_empty),
          .overflow     (fast_fifo_overflow),
          .underflow    (fast_fifo_underflow)
       );

       pre_ddr_slow_fifo U_pre_ddr_slow_fifo (
          .rst          (fifo_rst),
          .wr_clk       (adc_sampleclk),
          .rd_clk       (ui_clk),
          .din          (preddr_fifo_din),
          .wr_en        (preddr_fifo_wr),
          .rd_en        (preddr_fifo_rd),
          .dout         (preddr_fifo_dout),
          .full         (preddr_fifo_full),
          .empty        (preddr_fifo_empty),
          .overflow     (preddr_fifo_overflow),
          .underflow    (preddr_fifo_underflow)
       );

       post_ddr_slow_fifo U_post_ddr_slow_fifo (
          .rst          (fifo_rst),
          .wr_clk       (ui_clk),
          .rd_clk       (clk_usb),
          .din          (postddr_fifo_din),
          .wr_en        (postddr_fifo_wr),
          .rd_en        (postddr_fifo_rd),
          .dout         (postddr_fifo_dout),
          .full         (postddr_fifo_full),
          .prog_full    (postddr_fifo_prog_full),
          .empty        (postddr_fifo_empty),
          .overflow     (postddr_fifo_overflow),
          .underflow    (postddr_fifo_underflow)
       );

    `endif

`ifndef __ICARUS__

  mig_7series_nosysclock u_mig_7series_nosysclock
      (
// Memory interface ports
       .ddr3_addr                      (ddr3_addr),
       .ddr3_ba                        (ddr3_ba),
       .ddr3_cas_n                     (ddr3_cas_n),
       .ddr3_ck_n                      (ddr3_ck_n),
       .ddr3_ck_p                      (ddr3_ck_p),
       .ddr3_cke                       (ddr3_cke),
       .ddr3_ras_n                     (ddr3_ras_n),
       .ddr3_we_n                      (ddr3_we_n),
       .ddr3_dq                        (ddr3_dq),
       .ddr3_dqs_n                     (ddr3_dqs_n),
       .ddr3_dqs_p                     (ddr3_dqs_p),
       .ddr3_reset_n                   (ddr3_reset_n),
       .init_calib_complete            (init_calib_complete),
       .ddr3_cs_n                      (ddr3_cs_n),
       .ddr3_dm                        (ddr3_dm),
       .ddr3_odt                       (ddr3_odt),
// Application interface ports
       .app_addr                       (app_addr),
       .app_cmd                        (app_cmd),
       .app_en                         (app_en),
       .app_wdf_data                   (app_wdf_data),
       .app_wdf_end                    (app_wdf_end),
       .app_wdf_wren                   (app_wdf_wren),
       .app_rd_data                    (app_rd_data),
       .app_rd_data_end                (app_rd_data_end),
       .app_rd_data_valid              (app_rd_data_valid),
       .app_rdy                        (app_rdy),
       .app_wdf_rdy                    (app_wdf_rdy),
       .app_sr_req                     (1'b0),
       .app_ref_req                    (1'b0),
       .app_zq_req                     (1'b0),
       .app_sr_active                  (),                      // unused
       .app_ref_ack                    (),                      // unused
       .app_zq_ack                     (),                      // unused
       .ui_clk                         (ui_clk),
       .ui_clk_sync_rst                (ui_clk_sync_rst),
       .app_wdf_mask                   (4'b0),
// Debug Ports
// these can be omitted if you wish -- regenerate the MIG with debug disabled
       .ddr3_ila_basic                 (ddr3_ila_basic_w[119:0]),
       .ddr3_ila_wrpath                (),
       .ddr3_ila_rdpath                (),
       .dbg_pi_counter_read_val        (),
       .dbg_po_counter_read_val        (),
       .dbg_prbs_final_dqs_tap_cnt_r   (),
       .dbg_prbs_first_edge_taps       (),
       .dbg_prbs_second_edge_taps      (),
       // debug inputs, connect to rest of debug infrastructure if present:
       /*
       .dbg_pi_f_inc                   (dbg_pi_f_inc),
       .dbg_pi_f_dec                   (dbg_pi_f_dec),
       .dbg_po_f_inc                   (dbg_po_f_inc),
       .dbg_po_f_stg23_sel             (dbg_po_f_stg23_sel),
       .dbg_po_f_dec                   (dbg_po_f_dec),
       .ddr3_vio_sync_out              ({dbg_dqs,dbg_bit}),
       .dbg_sel_pi_incdec              (dbg_sel_pi_incdec),
       .dbg_sel_po_incdec              (dbg_sel_po_incdec),
       .dbg_byte_sel                   (dbg_byte_sel_r),
       */
       // otherwise:
       .dbg_pi_f_inc                   (1'b0),
       .dbg_pi_f_dec                   (1'b0),
       .dbg_po_f_inc                   (1'b0),
       .dbg_po_f_stg23_sel             (1'b0),
       .dbg_po_f_dec                   (1'b0),
       .ddr3_vio_sync_out              (14'b0),
       .dbg_sel_pi_incdec              (1'b0),
       .dbg_sel_po_incdec              (1'b0),
       .dbg_byte_sel                   (2'b0),

// System Clock Ports
       .sys_clk_p                      (ADC_clk_fbp),
       .sys_clk_n                      (ADC_clk_fbn),
       .device_temp_i                  (temp_out),
       `ifdef SKIP_CALIB
       .calib_tap_req                  (calib_tap_req),
       .calib_tap_load                 (calib_tap_load),
       .calib_tap_addr                 (calib_tap_addr),
       .calib_tap_val                  (calib_tap_val),
       .calib_tap_load_done            (calib_tap_load_done),
       `endif
       .sys_rst                        (~reset)
       );

`else
    // basic behavioural model for simulation testing
   assign ui_clk = clk_usb;
   ddr3_app_model #(
      .pDATA_WIDTH                         (32),
      .pADDR_WIDTH                         (30),
      .pMASK_WIDTH                         (4),
      .pMODEL_DEPTH                        (65536)
   ) U_ddr3_model (
      .clk                                 (clk_usb             ),
      .reset                               (reset               ),
      .init_calib_complete                 (init_calib_complete ),

      .app_addr                            (app_addr            ),
      .app_cmd                             (app_cmd             ),
      .app_en                              (app_en              ),
      .app_wdf_data                        (app_wdf_data        ),
      .app_wdf_end                         (app_wdf_end         ),
      .app_wdf_wren                        (app_wdf_wren        ),

      .app_rd_data                         (app_rd_data         ),
      .app_rd_data_end                     (app_rd_data_end     ),
      .app_rd_data_valid                   (app_rd_data_valid   ),
      .app_rdy                             (app_rdy             ),
      .app_wdf_rdy                         (app_wdf_rdy         )
   );


`endif

   simple_ddr3_rwtest #(
      .pDATA_WIDTH                         (32),
      .pADDR_WIDTH                         (30),
      .pMASK_WIDTH                         (4)
   ) U_simple_ddr3_rwtest (
      .clk                                 (ui_clk              ),
      .reset                               (reset               ),
      .active_usb                          (ddr3_rwtest_en      ),
      .init_calib_complete                 (init_calib_complete ),
      .pass                                (ddr3_test_pass      ),
      .fail                                (ddr3_test_fail      ),
      .clear_fail                          (ddr3_test_clear_fail),

      .iteration                           (ddr3_test_iteration ),
      .errors                              (ddr3_test_errors    ),
      .error_addr                          (                    ),
      .ddrtest_incr                        (pDDR_INC_ADDR       ),
      .ddrtest_stop                        (pDDR_MAX_ADDR       ),

      .ddr_read_read                       (ddr3_read_read       ),
      .ddr_read_idle                       (ddr3_read_idle       ),
      .ddr_write_write                     (ddr3_write_write     ),
      .ddr_write_idle                      (ddr3_write_idle      ),
      .ddr_max_read_stall_count            (ddr3_max_read_stall_count ),
      .ddr_max_write_stall_count           (ddr3_max_write_stall_count),

      .app_addr                            (rwtest_app_addr     ),
      .app_cmd                             (rwtest_app_cmd      ),
      .app_en                              (rwtest_app_en       ),
      .app_wdf_data                        (rwtest_app_wdf_data ),
      .app_wdf_end                         (rwtest_app_wdf_end  ),
      .app_wdf_wren                        (rwtest_app_wdf_wren ),

      .app_rd_data                         (app_rd_data         ),
      .app_rd_data_end                     (app_rd_data_end     ),
      .app_rd_data_valid                   (app_rd_data_valid   ),
      .app_rdy                             (app_rdy             ),
      .app_wdf_rdy                         (app_wdf_rdy         ),

      // debug only:
      .state                               (ddr3_test_state         ),
      .comp_error                          (ddr3_test_comp_error    ),
      .comp_good                           (ddr3_test_comp_good     ),
      .expected_payload                    (ddr3_test_expected_data ),
      .verify_addr                         (ddr3_test_verify_addr   ),
      .lfsr                                (ddr3_test_lfsr          )
   );


   reg read_update;
   wire read_update_usb;
   reg [31:0] write_count;
   (* ASYNC_REG = "TRUE" *) reg [31:0] write_count_to_usb;
   reg [5:0] write_cycle_count = 0;

   // track how many FIFO entries (roughly) are available to be read; tricky because of two clock domains!
   always @(posedge ui_clk) begin
      if (fifo_rst) begin
         write_count <= 0;
         write_count_to_usb <= 0;
         read_update <= 1'b0;
      end
      else begin
         write_cycle_count <= write_cycle_count + 1;
         if (postddr_fifo_wr)
            // TODO/NOTE: in Husky, write_count and read_count counted actual ADC samples; now they could 64-bit words
            // (i.e. 5.33 samples); this needs to be accounted for in Python 
            write_count <= write_count + 1;
         if (write_cycle_count == 0) begin
            read_update <= 1'b1;
            write_count_to_usb <= write_count;
         end
         else
            read_update <= 1'b0;
      end
   end

   always @(posedge clk_usb) begin
      if (fifo_rst) begin
         read_count <= 0;
         stream_segment_available <= 1'b0;
      end
      else begin
         if (postddr_fifo_rd)
            read_count <= read_count + 1;
         if (read_update_usb) begin
            if (write_count_to_usb > read_count)
               stream_segment_available <= ( (write_count_to_usb - read_count > stream_segment_threshold) || (write_count_to_usb >= max_samples_i) );
            else
               stream_segment_available <= 1'b0;
         end
      end
   end

   // for debug: count FIFO reads
   always @(posedge clk_usb) begin
      if (fifo_rst) begin
         fifo_read_count <= 0;
         fifo_read_count_error_freeze <= 0;
      end
      else if (postddr_fifo_rd) begin
         fifo_read_count <= fifo_read_count + 1;
         if (!error_flag)
            fifo_read_count_error_freeze <= fifo_read_count_error_freeze + 1;
      end
   end


   cdc_pulse U_read_update_cdc (
      .reset_i       (reset),
      .src_clk       (adc_sampleclk),
      .src_pulse     (read_update),
      .dst_clk       (clk_usb),
      .dst_pulse     (read_update_usb)
   );

   assign debug = {adc_capture_stop,
                   fifo_rst,
                   armed_and_ready,
                   arming,
                   capture_go,
                   state};

`ifdef ILA_DDR3
ila_ddr3 U_ila_ddr3 (
    .clk            (ui_clk             ),      // input wire clk
    .probe0         (ddr3_rwtest_en     ),      // input wire [0:0]  probe0  
    .probe1         (init_calib_complete),      // input wire [0:0]  probe1 
    .probe2         (ddr3_test_pass     ),      // input wire [0:0]  probe2 
    .probe3         (ddr3_test_fail     ),      // input wire [0:0]  probe3 
    .probe4         (app_addr           ),      // input wire [29:0] probe4 
    .probe5         (app_cmd            ),      // input wire [2:0]  probe5 
    .probe6         (app_en             ),      // input wire [0:0]  probe6 
    .probe7         (app_wdf_data       ),      // input wire [31:0] probe7 
    .probe8         (app_wdf_end        ),      // input wire [0:0]  probe8 
    .probe9         (app_wdf_wren       ),      // input wire [0:0]  probe9 
    .probe10        (1'b0               ),      // input wire [0:0]  probe10 
    .probe11        (app_rd_data        ),      // input wire [31:0] probe11 
    .probe12        (app_rd_data_end    ),      // input wire [0:0]  probe12 
    .probe13        (app_rd_data_valid  ),      // input wire [0:0]  probe13 
    .probe14        (app_rdy            ),      // input wire [0:0]  probe14 
    .probe15        (app_wdf_rdy        ),      // input wire [0:0]  probe15
    .probe16        (ddr3_test_state    ),      // input wire [3:0]  probe16
    .probe17        (ddr3_test_iteration),      // input wire [15:0] probe17
    .probe18        (ddr3_test_comp_error ),    // input wire [0:0]  probe18
    .probe19        (ddr3_test_comp_good  ),    // input wire [0:0]  probe19
    .probe20        (ddr3_test_expected_data),  // input wire [31:0] probe20
    .probe21        (ddr3_test_verify_addr),    // input wire [29:0] probe21 
    .probe22        (ddr3_test_lfsr     )       // input wire [31:0] probe22 
);
`endif

`ifdef ILA_HUSKY_FIFO
    ila_fast_fifo U_ila_fast_fifo (
        .clk            (adc_sampleclk),        // input wire clk
        .probe0         (reset),                // input wire [0:0]  probe0  
        .probe1         (fast_fifo_wr),         // input wire [0:0]  probe1 
        .probe2         (fast_fifo_rd),         // input wire [0:0]  probe2 
        .probe3         (fast_fifo_dout),       // input wire [11:0] probe3 
        .probe4         (fast_fifo_full),       // input wire [0:0]  probe4 
        .probe5         (fast_fifo_empty),      // input wire [0:0]  probe5 
        .probe6         (fast_fifo_overflow),   // input wire [0:0]  probe6 
        .probe7         (fast_fifo_underflow),  // input wire [0:0]  probe7 
        .probe8         (capture_active),       // input wire [0:0]  probe8 
        .probe9         (adc_capture_stop),     // input wire [0:0]  probe9 
        .probe10        (state),                // input wire [2:0]  probe10
        .probe11        (adc_datain),           // input wire [11:0] probe11
        .probe12        (preddr_fifo_wr),       // input wire [0:0]  probe12
        .probe13        (preddr_fifo_full),     // input wire [0:0]  probe13
        .probe14        (preddr_fifo_overflow), // input wire [0:0]  probe14
        .probe15        (error_stat),           // input wire [10:0] probe15
        .probe16        (error_flag),           // input wire [0:0]  probe16
        .probe17        (filler_read),          // input wire [0:0]  probe17
        .probe18        (filler_write),         // input wire [0:0]  probe18
        .probe19        (write_done_adc),       // input wire [0:0]  probe19
        .probe20        (adc_sample_counter),   // input wire [3:0]  probe20
        .probe21        (wide_word_valid),      // input wire [0:0]  probe21
        .probe22        (wide_word_shifter),    // input wire [71:0] probe22
        .probe23        (filler_read_needed),   // input wire [0:0]  probe23
        .probe24        (preddr_fifo_din)       // input wire [63:0] probe24
    );


    ila_ui_fifo U_ila_ui_fifo (
        .clk            (ui_clk),               // input wire clk
        .probe0         (preddr_fifo_rd),       // input wire [0:0]
        .probe1         (preddr_fifo_dout),     // input wire [63:0]
        .probe2         (preddr_fifo_empty),    // input wire [0:0]
        .probe3         (preddr_fifo_underflow),// input wire [0:0]
        .probe4         (postddr_fifo_wr),      // input wire [0:0]
        .probe5         (postddr_fifo_din),     // input wire [63:0]
        .probe6         (postddr_fifo_full),    // input wire [0:0]
        .probe7         (postddr_fifo_overflow),// input wire [0:0]
        .probe8         (app_addr),             // input wire [29:0]
        .probe9         (app_cmd),              // input wire [2:0]
        .probe10        (app_en),               // input wire [0:0]
        .probe11        (app_wdf_data),         // input wire [31:0]
        .probe12        (app_wdf_end),          // input wire [0:0]
        .probe13        (app_wdf_wren),         // input wire [0:0]
        .probe14        (app_rd_data),          // input wire [31:0]
        .probe15        (app_rd_data_end),      // input wire [0:0]
        .probe16        (app_rd_data_valid),    // input wire [0:0]
        .probe17        (app_rdy),              // input wire [0:0]
        .probe18        (app_wdf_rdy),          // input wire [0:0]
        .probe19        (ddr_state),            // input wire [2:0]
        .probe20        (ddr3_rwtest_en),       // input wire [0:0]
        .probe21        (reset_app_address),    // input wire [0:0]
        .probe22        (incr_app_address),     // input wire [0:0]
        .probe23        (ddr_write_data_done),  // input wire [0:0]
        .probe24        (ddr_read_data_done),   // input wire [0:0]
        .probe25        (ddr_full_error),       // input wire [0:0]
        .probe26        (ddr_writing),          // input wire [0:0]
        .probe27        (postddr_fifo_prog_full),// input wire [0:0]
        .probe28        (adc_top_app_addr),     // input wire [29:0]
        .probe29        (capture_go_ui),        // input wire [0:0]
        .probe30        (init_calib_complete),  // input wire [0:0]
        .probe31        (error_flag)            // input wire [0:0]
    );

    ila_slow_fifo U_ila_slow_fifo (
        .clk            (clk_usb),              // input wire clk
        .probe0         (reset),                // input wire [0:0]
        .probe1         (postddr_fifo_dout),    // input wire [63:0]
        .probe2         (postddr_fifo_rd),      // input wire [0:0]
        .probe3         (postddr_fifo_empty),   // input wire [0:0]
        .probe4         (postddr_fifo_underflow),// input wire [0:0]
        .probe5         (fifo_rst),             // input wire [0:0]
        .probe6         (reset_done),           // input wire [0:0]
        .probe7         (slow_fifo_rd_fast),    // input wire [0:0]
        .probe8         (fifo_read_fifoen),     // input wire [0:0]
        .probe9         (slow_read_count),      // input wire [3:0]
        .probe10        (stream_segment_available), // input wire [0:0]
        .probe11        (fast_fifo_read_mode),  // input wire [0:0]
        .probe12        (fifo_read_data),       // input wire [7:0]
        .probe13        (error_flag)            // input wire [0:0]
    );

`endif


endmodule
`default_nettype wire
