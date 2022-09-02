`include "includes.v"
`timescale 1 ns / 1 ps
`default_nettype none

/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more
details, or the codebase at http://www.chipwhisperer.com

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
    output reg [8:0]    error_stat,
    output reg [8:0]    first_error_stat,
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
    output wire         slow_fifo_wr,
    output wire         slow_fifo_rd,
    output reg  [31:0]  fifo_read_count,
    output reg  [31:0]  fifo_read_count_error_freeze,
    output reg          fifo_rst,
    output wire [7:0]   debug

);

    parameter pFIFO_FULL_SIZE = `MAX_SAMPLES;
    parameter pMAX_UNDERFLOWS = 3;

    wire                fast_fifo_wr;
    reg                 fast_fifo_presample_drain = 1'b0;
    reg                 fast_fifo_rd_en = 1'b0;
    wire                fast_fifo_rd;
    wire [11:0]         fast_fifo_dout;
    wire                fast_fifo_full;
    wire                fast_fifo_empty;
    wire                fast_fifo_overflow;
    wire                fast_fifo_underflow;

    reg  [35:0]         slow_fifo_din;
    reg                 slow_fifo_prewr = 1'b0;
    reg                 slow_fifo_rd_slow;
    wire                slow_fifo_rd_fast;
    wire [35:0]         slow_fifo_dout;
    reg  [3:0]          slow_fifo_dout_r;
    wire                slow_fifo_full;
    wire                slow_fifo_empty;
    wire                slow_fifo_overflow;
    wire                slow_fifo_underflow;

    reg                 fast_fifo_overflow_reg;
    reg                 slow_fifo_overflow_reg;
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

    reg [1:0]           fast_read_count;
    reg [2:0]           fast_write_count;
    reg [2:0]           fast_write_count_init;
    reg                 filling_out_to_done;
    reg                 slow_fifo_underflow_sticky;
    reg [1:0]           slow_fifo_underflow_count;
    reg                 slow_fifo_underflow_masked;

    reg  [3:0]          done_wait_count;
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
    wire                app_sr_req;
    wire                app_ref_req;
    wire                app_zq_req;
    wire [3:0]          app_wdf_mask;
    wire                app_sr_active;
    wire                app_ref_ack;
    wire                app_zq_ack;
    wire                ui_clk;
    wire                ui_clk_sync_rst;
    wire [31:0]         app_rd_data;
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

    assign fifo_overflow = fast_fifo_overflow_reg || slow_fifo_overflow_reg;

    // make overflow sticky:
    always @(posedge adc_sampleclk) begin
       if (fifo_rst) begin
          fast_fifo_overflow_reg <= 1'b0;
          slow_fifo_overflow_reg <= 1'b0;
       end
       else begin
          if (fast_fifo_overflow)
             fast_fifo_overflow_reg <= 1'b1;
          if (slow_fifo_overflow)
             slow_fifo_overflow_reg <= 1'b1;
       end
    end

    always @(posedge adc_sampleclk) begin
       if (fifo_rst)
          fast_fifo_overflow_reg <= 1'b0;
       else if (fast_fifo_overflow)
          fast_fifo_overflow_reg <= 1'b1;
    end


    assign fifo_read_fifoempty = slow_fifo_empty;

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
            else if (slow_fifo_wr && ( (slow_fifo_din[11:0]  == {12{1'b1}} || slow_fifo_din[11:0]  == {12{1'b0}}) ||
                                       (slow_fifo_din[23:12] == {12{1'b1}} || slow_fifo_din[23:12] == {12{1'b0}}) ||
                                       (slow_fifo_din[35:24] == {12{1'b1}} || slow_fifo_din[35:24] == {12{1'b0}}) ) )
                clip_error <= 1'b1;
            else if (clip_test)
                clip_error <= adc_datain == {12{1'b1}} || adc_datain == {12{1'b0}};

            if (no_gain_errors || clear_fifo_errors_adc)
                gain_too_low <= 1'b0;
            else if (capture_go)
                gain_too_low <= 1'b1;
            else if (slow_fifo_wr && ( (slow_fifo_din[11]? slow_fifo_din[10:9]  != 2'b00 : slow_fifo_din[10:8]  != 3'b111) ||
                                       (slow_fifo_din[23]? slow_fifo_din[22:21] != 2'b00 : slow_fifo_din[22:20] != 3'b111) ||
                                       (slow_fifo_din[35]? slow_fifo_din[34:33] != 2'b00 : slow_fifo_din[34:32] != 3'b111) ) )
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
          filling_out_to_done <= 0;
          downsample_error <= 1'b0;
          segment_error <= 1'b0;
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
                filling_out_to_done <= 0;
                segment_error <= 1'b0;
                fsm_fast_wr_en <= 1'b0;

                if ((downsample_i > 0) && ((presample_i > 0) || (num_segments > 1)))
                   downsample_error <= 1'b1;
                else
                   downsample_error <= 1'b0;

                if (armed_and_ready && ~adc_capture_stop) begin
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

                if (stop_capture_conditions || (last_sample && fast_fifo_wr && last_segment) || (filling_out_to_done && fast_fifo_wr)) begin
                   if (fast_write_count == 2) begin
                      adc_capture_stop <= 1'b1;
                      done_wait_count <= 10;  // established by trial/error to account for the latency in the Xilinx FIFO updating its empty flag
                      fsm_fast_wr_en <= 1'b0;
                      state <= pS_DONE;
                   end
                   else
                      filling_out_to_done <= 1'b1;
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
                // serves two purposes:
                // 1. wait for fast FIFO to empty;
                // 2. wait state so that we don't get back out of idle right away
                if ((fast_fifo_empty && (done_wait_count == 0)) || arm_i) begin
                   fast_fifo_rd_en <= 1'b0;
                   state <= pS_IDLE;
                end
                else
                   done_wait_count <= done_wait_count - 1;
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
    assign slow_fifo_wr = slow_fifo_prewr & reset_done & !fifo_rst_pre;

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
          slow_fifo_underflow_masked = slow_fifo_underflow && (read_count < max_samples_i) && ~no_underflow_errors;
       else
          slow_fifo_underflow_masked = slow_fifo_underflow && ~no_underflow_errors && (slow_fifo_underflow_count == pMAX_UNDERFLOWS);
    end

    function [8:0] error_bits (input [8:0] current_error);
       begin
          error_bits = current_error;
          if (gain_error)                    error_bits[8] = 1'b1;
          if (segment_error)                 error_bits[7] = 1'b1;
          if (downsample_error)              error_bits[6] = 1'b1;
          if (clip_error)                    error_bits[5] = 1'b1;
          if (presamp_error)                 error_bits[4] = 1'b1;
          if (fast_fifo_overflow)            error_bits[3] = 1'b1;
          if (fast_fifo_underflow)           error_bits[2] = 1'b1;
          if (slow_fifo_overflow)            error_bits[1] = 1'b1;
          if (slow_fifo_underflow_masked)    error_bits[0] = 1'b1;
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
                 fast_fifo_overflow || fast_fifo_underflow || slow_fifo_overflow || slow_fifo_underflow_masked) begin
                error_flag <= 1;
                if (!error_flag) begin
                   first_error_stat <= error_bits(first_error_stat);
                   first_error_state <= state_r;
                end
             end

             error_stat <= error_bits(error_stat);

             if (slow_fifo_underflow_masked && (underflow_count != 8'hFF))
                underflow_count <= underflow_count + 1;
          end
       end
    end

    always @(posedge clk_usb) begin
       if (reset) begin
          slow_fifo_underflow_sticky <= 0;
          slow_fifo_underflow_count <= 0;
       end
       else begin
          // Xilinx FIFO asserts "underflow" for a single cycle only:
          if (fifo_rst_start_r)
             slow_fifo_underflow_sticky <= 0;
          else if (slow_fifo_underflow)
             slow_fifo_underflow_sticky <= 1;

          // SAM3U likes to read multiples of 4 bytes, so we don't flag an
          // underflow unless we observe at least 3 underflow reads
          if (fifo_rst_start_r)
             slow_fifo_underflow_count <= 0;
          else if (slow_fifo_underflow && slow_fifo_underflow_count < pMAX_UNDERFLOWS)
             slow_fifo_underflow_count <= slow_fifo_underflow_count + 1;

       end
    end



    // Track fast FIFO writes to ensure they're a multiple of 3 by the end of the capture:
    always @(posedge adc_sampleclk) begin
       if (reset) begin
          fast_write_count <= 0;
       end
       else begin
          fast_write_count_init <= presample_i % 3; // alternatively, this could be precomputed in Python
          if (state == pS_IDLE)
             fast_write_count <= fast_write_count_init;
          else if (fast_fifo_wr && (state == pS_TRIGGERED))
             if (fast_write_count < 2)
                fast_write_count <= fast_write_count + 1;
             else
                fast_write_count <= 0;
       end
    end


    // Write slow FIFO:
    always @(posedge adc_sampleclk) begin
       if (reset) begin
          fast_read_count <= 0;
          slow_fifo_prewr <= 1'b0;
       end

       else begin
          if (fifo_rst_pre || ~reset_done || ((state == pS_SEGMENT_DONE) && fast_fifo_empty)) begin
             slow_fifo_prewr <= 0;
             if (fifo_rst_pre || ~reset_done)
                fast_read_count <= 0;
          end

          else if ((state == pS_TRIGGERED) || (state == pS_DONE) || (state == pS_SEGMENT_DONE)) begin
             if (!fast_fifo_empty && !slow_fifo_full) begin
                if (fast_read_count < 2) begin
                   fast_read_count <= fast_read_count + 1;
                   slow_fifo_prewr <= 1'b0;
                end
                else begin
                   fast_read_count <= 0;
                   slow_fifo_prewr <= 1'b1;
                end

             end
             else begin
                slow_fifo_prewr <= 1'b0;
             end
          end

          else
             slow_fifo_prewr <= 1'b0;

          if (fast_fifo_rd)
             slow_fifo_din <= {slow_fifo_din[23:0], fast_fifo_dout};

       end
    end

    reg [3:0] slow_read_count;

    // Read slow FIFO:
    always @(posedge clk_usb) begin
       if (reset || ~reset_done) begin
          slow_read_count <= 0;
          slow_fifo_rd_slow <= 1'b0;
          slow_fifo_dout_r <= 0;
       end

       else if (fifo_read_fifoen || first_read) begin
          if (low_res) begin // return 8 bits per sample
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
             if (slow_read_count < 8)
                slow_read_count <= slow_read_count + 1;
             else
                slow_read_count <= 0;
             if ((slow_read_count == 8) || (slow_read_count == 3)) begin
                slow_fifo_rd_slow <= 1;
                slow_fifo_dout_r <= slow_fifo_dout[3:0];
             end
             else
                slow_fifo_rd_slow <= 0;
          end

       end
       else
          slow_fifo_rd_slow <= 1'b0;
    end

    assign slow_fifo_rd_fast = fifo_read_fifoen && (low_res? (slow_read_count == 2) : ((slow_read_count == 3) || (slow_read_count == 8)));
    assign slow_fifo_rd = fast_fifo_read_mode? slow_fifo_rd_fast : slow_fifo_rd_slow;

    reg [7:0] fifo_read_data_pre;
    always @(*) begin
       if (slow_fifo_underflow_sticky)
          fifo_read_data_pre = 0;
       else if (low_res) begin
          if (low_res_lsb)
             fifo_read_data_pre = slow_fifo_dout[(2-slow_read_count)*12 +: 8];
          else
             fifo_read_data_pre = slow_fifo_dout[(2-slow_read_count)*12 + 4 +: 8];
       end
       else begin
          case (slow_read_count)
             0: fifo_read_data_pre = slow_fifo_dout[35:28];
             1: fifo_read_data_pre = slow_fifo_dout[27:20];
             2: fifo_read_data_pre = slow_fifo_dout[19:12];
             3: fifo_read_data_pre = slow_fifo_dout[11:4];
             4: fifo_read_data_pre = {slow_fifo_dout_r, slow_fifo_dout[35:32]};
             5: fifo_read_data_pre = slow_fifo_dout[31:24];
             6: fifo_read_data_pre = slow_fifo_dout[23:16];
             7: fifo_read_data_pre = slow_fifo_dout[15:8];
             8: fifo_read_data_pre = slow_fifo_dout[7:0];
             default: fifo_read_data_pre = 8'h00;
          endcase
       end
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
        else if (!slow_fifo_empty && !first_read_done) begin
            first_read <= 1'b1;
        end

        if (fifo_read_fifoen || first_read) fifo_read_data <= fifo_read_data_pre;

    end

    assign fast_fifo_rd = fast_fifo_presample_drain || (fast_fifo_rd_en && !slow_fifo_full && !fast_fifo_empty);

    `ifdef NOFIFO
       //for clean iverilog compilation

    `elsif TINYFIFO
       //for faster corner case simulation- TODO: update for CW310 case
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
       // TODO: change to 3 FIFOs:
       //adc_fast_fifo_pro U_adc_fast_fifo
       //pre_ddr_slow_fifo U_pre_ddr_slow_fifo
       //post_ddr_slow_fifo U_post_ddr_slow_fifo

       adc_fast_fifo U_adc_fast_fifo(
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

       usb_slow_fifo U_usb_slow_fifo(
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
       .app_sr_active                  (app_sr_active),
       .app_ref_ack                    (app_ref_ack),
       .app_zq_ack                     (app_zq_ack),
       .ui_clk                         (ui_clk),
       .ui_clk_sync_rst                (ui_clk_sync_rst),
       .app_wdf_mask                   (app_wdf_mask),
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
      .ddrtest_incr                        (8'd8                ),
      .ddrtest_stop                        (32'h1FFF_FFF8       ),

      .ddr_read_read                       (ddr3_read_read       ),
      .ddr_read_idle                       (ddr3_read_idle       ),
      .ddr_write_write                     (ddr3_write_write     ),
      .ddr_write_idle                      (ddr3_write_idle      ),
      .ddr_max_read_stall_count            (ddr3_max_read_stall_count ),
      .ddr_max_write_stall_count           (ddr3_max_write_stall_count),

      .app_addr                            (app_addr            ),
      .app_cmd                             (app_cmd             ),
      .app_en                              (app_en              ),
      .app_wdf_data                        (app_wdf_data        ),
      .app_wdf_end                         (app_wdf_end         ),
      .app_wdf_wren                        (app_wdf_wren        ),
      .app_sr_req                          (app_sr_req          ),
      .app_ref_req                         (app_ref_req         ),
      .app_zq_req                          (app_zq_req          ),
      .app_wdf_mask                        (app_wdf_mask        ),

      .app_sr_active                       (app_sr_active       ),
      .app_ref_ack                         (app_ref_ack         ),
      .app_zq_ack                          (app_zq_ack          ),
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
   always @(posedge adc_sampleclk) begin
      if (fifo_rst) begin
         write_count <= 0;
         write_count_to_usb <= 0;
         read_update <= 1'b0;
      end
      else begin
         write_cycle_count <= write_cycle_count + 1;
         if (slow_fifo_wr)
            write_count <= write_count + 3;
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
         if (slow_fifo_rd)
            read_count <= read_count + 3;
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
      else if (slow_fifo_rd) begin
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
    .probe10        (app_ref_ack        ),      // input wire [0:0]  probe10 
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


endmodule
`default_nettype wire
