`include "includes.v"
`timescale 1 ns / 1 ps
`default_nettype none

/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more
details, or the codebase at http://www.chipwhisperer.com
Built from fifo_top_husky.v and modified for Pro.

Copyright (c) 2022, NewAE Technology Inc. All rights reserved.
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

module ddr (
    input wire          reset,

    output wire         postddr_fifo_empty,

    //FIFO to USB Read Interface
    input wire          clk_usb,
    input wire          low_res,        // if set, return just 8 bits per sample; if clear return all 12 bits per sample
    input wire          low_res_lsb,    // useless except for testing: if set, return the 8 LSB bits when in low_res mode
    input wire [16:0]   stream_segment_threshold,
    output reg          stream_segment_available,
    input wire          fifo_read_fifoen,
    output reg  [7:0]   fifo_read_data,
    input  wire         fast_fifo_read_mode, // not to be confused with the ADC fast FIFO, this denote fast reading of the *slow* FIFO
    input  wire         stream_mode, //1=Enable stream mode, 0=Normal
    input  wire         no_underflow_errors,  // disables flagging of *slow* FIFO underflow errors only
    input wire  [31:0]  max_samples_i,

    // ADC
    input  wire         capture_go_adc,
    input  wire         write_done_adc,
    output wire         preddr_adc_fifo_rd,
    input  wire [63:0]  preddr_adc_fifo_dout,
    input  wire         preddr_adc_fifo_empty,

    // LA
    input  wire         capture_go_la,
    input  wire         write_done_la,
    output wire         preddr_la_fifo_rd,
    input  wire [63:0]  preddr_la_fifo_dout,
    input  wire         preddr_la_fifo_empty,

    // trace
    input  wire         capture_go_trace,
    input  wire         write_done_trace,
    output wire         preddr_trace_fifo_rd,
    input  wire [63:0]  preddr_trace_fifo_dout,
    input  wire         preddr_trace_fifo_empty,

    input  wire         single_write,
    input  wire         single_read,
    input  wire [29:0]  single_address,
    input  wire [63:0]  single_write_data,
    output reg  [63:0]  single_read_data,
    output wire         ddr_read_data_done,
    output wire         ddr_single_done,
    output reg          ddr_write_data_done,

    input  wire [29:0]  ddr_la_start_address,
    input  wire [29:0]  ddr_trace_start_address,

    input  wire         ddr_start_la_read,
    input  wire         ddr_start_trace_read,
    input  wire         ddr_start_adc_read,

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
    output wire         ddr_test_pass,
    output wire         ddr_test_fail,
    input  wire         ddr_test_clear_fail,
    input  wire         ddr_rwtest_en,
    input  wire         use_ddr,           
    output wire [15:0]  ddr_test_iteration,
    output wire [7:0]   ddr_test_errors,
    output reg  [31:0]  ddr_read_read,
    output reg  [31:0]  ddr_read_idle,
    output reg  [31:0]  ddr_write_write,
    output reg  [31:0]  ddr_write_idle,
    output reg  [15:0]  ddr_max_read_stall_count,
    output reg  [15:0]  ddr_max_write_stall_count,
    input  wire [11:0]  temp_out,

    output reg  [2:0]   ddr_state,

    output reg          fifo_overflow_ddr,
    input  wire         arm_pulse_usb,
    output wire         postddr_fifo_overflow,
    output reg          postddr_fifo_underflow_masked,
    output reg          reading_too_soon_error,
    output reg          ddr_full_error,
    input  wire         flushing,       // TODO: this is adc_flushing; what about other sources?
    output wire         postddr_flush,

    // debug only:
    input  wire         preddr_adc_fifo_underflow,
    input  wire         error_flag,
    output reg  [31:0]  fifo_read_count,
    output reg  [31:0]  fifo_read_count_error_freeze,
    output wire         postddr_fifo_rd,

    // CW310-specific:
    input wire          ADC_clk_fbp,
    input wire          ADC_clk_fbn,
    output wire         ui_clk,
    input  wire         tb_ui_clk

);

    parameter pDDR_INC_ADDR = 30'd8;
    parameter pDDR_MAX_ADDR = 30'h1FFF_FFF8;
    parameter pMAX_UNDERFLOWS = 3;

    localparam CMD_WRITE = 3'b000;
    localparam CMD_READ  = 3'b001;

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

    wire [29:0]         main_app_addr;
    reg  [29:0]         adc_app_addr;
    reg  [29:0]         la_app_addr;
    reg  [29:0]         trace_app_addr;
    wire [2:0]          main_app_cmd;
    reg                 main_app_en;
    wire [31:0]         main_app_wdf_data;
    wire [63:0]         preddr_wdata;
    reg                 main_app_wdf_end;
    reg                 main_app_wdf_wren;

    wire [31:0]         single_app_wdf_data;

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

    wire [3:0] ddr_test_state;
    wire ddr_test_comp_error;
    wire ddr_test_comp_good;
    wire [31:0] ddr_test_expected_data;
    wire [29:0] ddr_test_verify_addr;
    wire [31:0] ddr_test_lfsr;

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

    assign app_addr     = (ddr_rwtest_en)? rwtest_app_addr     : main_app_addr;
    assign app_cmd      = (ddr_rwtest_en)? rwtest_app_cmd      : main_app_cmd;
    assign app_en       = (ddr_rwtest_en)? rwtest_app_en       : main_app_en;
    assign app_wdf_end  = (ddr_rwtest_en)? rwtest_app_wdf_end  : main_app_wdf_end;
    assign app_wdf_wren = (ddr_rwtest_en)? rwtest_app_wdf_wren : main_app_wdf_wren;
    assign app_wdf_data = (ddr_rwtest_en)? rwtest_app_wdf_data :
                          (single_write_ui)?single_app_wdf_data : main_app_wdf_data;

    assign main_app_addr  = (source_select == pADC_SOURCE)? adc_app_addr :
                            (source_select == pLA_SOURCE)?  la_app_addr :
                                                            trace_app_addr;

    localparam pS_DDR_IDLE            = 3'd0;
    localparam pS_DDR_WRITE1          = 3'd1;
    localparam pS_DDR_WRITE2          = 3'd2;
    localparam pS_DDR_WAIT_READ       = 3'd3;
    localparam pS_DDR_READ1           = 3'd4;
    localparam pS_DDR_READ2           = 3'd5;
    localparam pS_DDR_WAIT_WRITE      = 3'd6;
    localparam pS_DDR_ADC_BYPASS      = 3'd7;
    reg [2:0] next_ddr_state, ddr_state_r; // TODO-later: trim size

    // TODO: flag error if arm event occurs when we are not idle
    assign ddr_read_data_done = ddr_reading && ( (source_select == pADC_SOURCE)?   (adc_top_app_addr   == main_app_addr) :
                                                 (source_select == pLA_SOURCE)?    (la_top_app_addr    == main_app_addr) :
                                                 (source_select == pTRACE_SOURCE)? (trace_top_app_addr == main_app_addr) : 1'b0 );
    reg incr_app_address;

    reg reset_app_address;
    reg [29:0] adc_top_app_addr;
    reg [29:0] la_top_app_addr;
    reg [29:0] trace_top_app_addr;

    reg ddr_writing_r;
    wire ddr_writing = (ddr_state == pS_DDR_WAIT_WRITE) ||
                       (ddr_state == pS_DDR_WRITE1) ||
                       (ddr_state == pS_DDR_WRITE2);
    wire ddr_reading = (ddr_state == pS_DDR_WAIT_READ) ||
                       (ddr_state == pS_DDR_READ1) ||
                       (ddr_state == pS_DDR_READ2);

    assign main_app_cmd = (ddr_writing)? CMD_WRITE : CMD_READ;

    assign main_app_wdf_data = (ddr_state == pS_DDR_WRITE1)? preddr_wdata[31:0] : preddr_wdata[63:32];

    assign preddr_wdata = (source_select == pADC_SOURCE)? preddr_adc_fifo_dout :
                          (source_select == pLA_SOURCE)?  preddr_la_fifo_dout :
                                                          preddr_trace_fifo_dout;

    assign single_app_wdf_data = (ddr_state == pS_DDR_WRITE1)? single_write_data[31:0] : single_write_data[63:32];

    reg                 preddr_fifo_rd_r;

    (* ASYNC_REG = "TRUE" *) reg[1:0] single_write_pipe;
    (* ASYNC_REG = "TRUE" *) reg[1:0] single_read_pipe;
    reg single_write_ui;
    reg single_write_ui_r;
    reg single_read_ui;
    reg single_read_ui_r;
    
    reg single_write_done;
    reg single_read_done;
    assign ddr_single_done = single_write_done || single_read_done;

    assign postddr_flush = pre_read_flush_usb;

    reg read_started;
    reg pre_read_flush;
    reg arm_event;

    reg  [63:0]         postddr_fifo_din;
    wire                postddr_fifo_full;
    wire                postddr_fifo_prog_full;
    reg                 postddr_fifo_wr;
    reg                 postddr_fifo_rd_slow;
    wire                postddr_fifo_rd_fast;
    wire [63:0]         postddr_fifo_dout;
    wire                postddr_fifo_underflow;
    reg                 postddr_fifo_underflow_sticky;
    reg [1:0]           postddr_fifo_underflow_count;

    reg first_read;
    reg first_read_done;
    reg read_update;
    wire read_update_usb;
    reg [31:0] write_count;
    (* ASYNC_REG = "TRUE" *) reg [31:0] write_count_to_usb;
    reg [5:0] write_cycle_count = 0;
    reg [31:0] read_count;
    reg slow_fifo_rd_slow;
    wire slow_fifo_rd_fast;
    reg [3:0] slow_read_count;

    reg ddr_start_la_read_r;
    reg ddr_start_trace_read_r;
    reg ddr_start_adc_read_r;
    wire start_read_ui_pulse;
    wire start_adc_read_ui_pulse;
    wire start_la_read_ui_pulse;
    wire start_trace_read_ui_pulse;
    wire start_adc_read_usb_pulse;
    wire start_la_read_usb_pulse;
    wire start_trace_read_usb_pulse;

    wire arm_pulse_ui;
    wire first_read_pulse_ui;

    reg postddr_fifo_rd_r;
    reg postddr_effective_underflow;
    reg postddr_effective_underflow_charged;

    ////////////////////////////
    // Post-DDR FIFO read logic:
    ////////////////////////////

    wire fresh_start_usb = arm_pulse_usb || start_adc_read_usb_pulse || start_la_read_usb_pulse || start_trace_read_usb_pulse;
    wire fresh_start_ui;

    always @(*) begin
       if (stream_mode)
          // TODO: is this still relevant?
          postddr_fifo_underflow_masked = postddr_fifo_underflow && (read_count < max_samples_i) && ~no_underflow_errors;
       else
          // fifo_read_fifoen check catches a case where while postddr_fifo_underflow doesn't occur, the read is still too
          // soon in that slow_read_count will get messed up
          postddr_fifo_underflow_masked = ~no_underflow_errors && ( (postddr_fifo_underflow && (postddr_fifo_underflow_count == pMAX_UNDERFLOWS)) ||
                                                                    (fifo_read_fifoen && postddr_fifo_empty && ~first_read_done) ||
                                                                     postddr_effective_underflow );
    end

    always @(posedge clk_usb) begin
       if (reset) begin
          postddr_fifo_underflow_sticky <= 0;
          postddr_fifo_underflow_count <= 0;
       end
       else begin
          // Xilinx FIFO asserts "underflow" for a single cycle only:
          if (fresh_start_usb)
             postddr_fifo_underflow_sticky <= 0;
          else if (postddr_fifo_underflow || postddr_effective_underflow)
             postddr_fifo_underflow_sticky <= 1;

          // SAM3U likes to read multiples of 4 bytes, so we don't flag an
          // underflow unless we observe at least 3 underflow reads
          if (fresh_start_usb)
             postddr_fifo_underflow_count <= 0;
          else if (postddr_fifo_underflow && postddr_fifo_underflow_count < pMAX_UNDERFLOWS)
             postddr_fifo_underflow_count <= postddr_fifo_underflow_count + 1;

       end
    end

   // for debug: count FIFO reads
   always @(posedge clk_usb) begin
      if (fresh_start_usb) begin
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
      .src_clk       (ui_clk),
      .src_pulse     (read_update),
      .dst_clk       (clk_usb),
      .dst_pulse     (read_update_usb)
   );

   cdc_pulse U_arm_pulse_cdc (
      .reset_i       (reset),
      .src_clk       (clk_usb),
      .src_pulse     (arm_pulse_usb),
      .dst_clk       (ui_clk),
      .dst_pulse     (arm_pulse_ui)
   );

   cdc_pulse U_fresh_start_cdc (
      .reset_i       (reset),
      .src_clk       (clk_usb),
      .src_pulse     (fresh_start_usb),
      .dst_clk       (ui_clk),
      .dst_pulse     (fresh_start_ui)
   );


    (* ASYNC_REG = "TRUE" *) reg[1:0] postddr_fifo_empty_ui_pipe;
    reg postddr_fifo_empty_ui;
    always @(posedge ui_clk) begin
        if (reset) begin
            postddr_fifo_empty_ui <= 0;
            postddr_fifo_empty_ui_pipe <= 0;
        end
        else begin
            {postddr_fifo_empty_ui, postddr_fifo_empty_ui_pipe} <= {postddr_fifo_empty_ui_pipe, postddr_fifo_empty};
        end
    end

    (* ASYNC_REG = "TRUE" *) reg[1:0] pre_read_flush_usb_pipe;
    reg pre_read_flush_usb;
    reg pre_read_flush_usb_r;
    always @(posedge clk_usb) begin
        if (reset) begin
            pre_read_flush_usb <= 0;
            pre_read_flush_usb_r <= 0;
            pre_read_flush_usb_pipe <= 0;
        end
        else begin
            {pre_read_flush_usb_r, pre_read_flush_usb, pre_read_flush_usb_pipe} <= {pre_read_flush_usb, pre_read_flush_usb_pipe, pre_read_flush};
        end
    end

   // track how many FIFO entries (roughly) are available to be read; tricky because of two clock domains!
   always @(posedge ui_clk) begin
      if (fresh_start_ui) begin
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

   // TODO: still need this?
   always @(posedge clk_usb) begin
      if (arm_pulse_usb) begin
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

    // Read slow FIFO: TODO! (some parts haven't been updated yet)
    always @(posedge clk_usb) begin
       if (reset || fresh_start_usb) begin
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
    assign postddr_fifo_rd = ((flushing || pre_read_flush_usb) && ~postddr_fifo_empty) || 
                             ((fast_fifo_read_mode)? slow_fifo_rd_fast : slow_fifo_rd_slow);

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

    // Register the FIFO output to help meet timing.
    // FIFO is first-word-fall-through, so the intent of "first_read" is to
    // register the FIFO output as soon as it's available, prior to executing
    // a FIFO read.
    // Originally "first_read" was triggered by the FIFO being not empty, but
    // in some cases the FIFO isn't empty when the read command is issued (the
    // FIFO gets flushed in this case), so instead we explicitely look at
    // read_started

    (* ASYNC_REG = "TRUE" *) reg[1:0] read_started_usb_pipe;
    reg read_started_usb;
    always @(posedge clk_usb) begin
        if (reset) begin
            read_started_usb <= 0;
            read_started_usb_pipe <= 0;
        end
        else begin
            {read_started_usb, read_started_usb_pipe} <= {read_started_usb_pipe, read_started};
        end
    end

    always @(posedge clk_usb) begin
        // if ~postddr_fifo_empty when one of those events occur, we don't
        // want to clear first_read_done yet, because there are conditions
        // where we may falsely set first_read (too early); by waiting instead
        // for the postddr flush to be done, we avoid those scenarios.
        if ( (fresh_start_usb && postddr_fifo_empty) ||
             (pre_read_flush_usb_r && ~pre_read_flush_usb) ) begin
            first_read <= 1'b0;
            first_read_done <= 1'b0;
        end
        else if (first_read) begin
            first_read <= 1'b0;
            first_read_done <= 1'b1;
        end
        // Note that when bypassing DDR, we don't bother with the read_started logic; it's assumed that
        // FIFOs are already empty prior to starting a read when DDR is bypassed . This may or may not
        // hold, but that's ok since DDR bypass is just for debugging.
        else if (!postddr_fifo_empty && (read_started_usb || ~use_ddr) && !first_read_done) begin
            first_read <= 1'b1;
        end

        if (fifo_read_fifoen || first_read) fifo_read_data <= fifo_read_data_pre;
    end

    always @(posedge ui_clk) begin
        if (reset) begin
            single_write_pipe <= 0;
            single_read_pipe <= 0;
            single_write_ui <= 0;
            single_write_ui_r <= 0;
            single_read_ui <= 0;
            single_read_ui_r <= 0;
        end
        else begin
            {single_write_ui_r, single_write_ui, single_write_pipe} <= {single_write_ui, single_write_pipe, single_write};
            {single_read_ui_r, single_read_ui, single_read_pipe} <= {single_read_ui, single_read_pipe, single_read};
        end
    end

    wire single_write_go = single_write_ui && ~single_write_ui_r;
    wire single_read_go = single_read_ui && ~single_read_ui_r;

    assign start_read_ui_pulse = start_adc_read_ui_pulse || start_la_read_ui_pulse || start_trace_read_ui_pulse;

    cdc_pulse U_first_read_cdc (
        .reset_i       (reset),
        .src_clk       (clk_usb),
        .src_pulse     (first_read),
        .dst_clk       (ui_clk),
        .dst_pulse     (first_read_pulse_ui)
    );


    ////////////
    // DDR logic
    ////////////

    // DDR FSM:
    always @(*) begin
        // defaults:
        main_app_en = 1'b0;
        main_app_wdf_wren = 1'b0;
        main_app_wdf_end = 1'b0;
        incr_app_address = 1'b0;
        reset_app_address = 1'b0;
        preddr_fifo_rd = 1'b0;
        next_ddr_state = pS_DDR_IDLE;
        single_write_done = 1'b0;
        pre_read_flush = 1'b0;

        case (ddr_state)
            pS_DDR_IDLE: begin
                if ((capture_go_any || start_read_ui_pulse || single_write_go || single_read_go) && ~ddr_rwtest_en) begin
                    if (~use_ddr)
                        next_ddr_state = pS_DDR_ADC_BYPASS;
                    else if (init_calib_complete) begin
                        if (single_write_ui)
                            next_ddr_state = pS_DDR_WAIT_WRITE;
                        else if (single_read_ui)
                            next_ddr_state = pS_DDR_WAIT_READ;
                        else if (start_read_ui_pulse) begin
                            reset_app_address = 1'b1;
                            next_ddr_state = pS_DDR_WAIT_READ;
                        end
                        else begin // normal ADC write-to-read case
                            reset_app_address = 1'b1;
                            next_ddr_state = pS_DDR_WAIT_WRITE;
                        end
                    end
                end
                else
                    next_ddr_state = pS_DDR_IDLE;
            end

            pS_DDR_ADC_BYPASS: begin
                // TODO: re-word DDR bypass with all sources in mind, as per note in Husky/Pro
                if (use_ddr)
                    next_ddr_state = pS_DDR_IDLE;
                else begin
                    next_ddr_state = pS_DDR_ADC_BYPASS;
                    // extra checks here to throttle the reads and ensure we don't overflow the FIFO; 
                    // it's ok if we don't read back-to-back.
                    if (~preddr_adc_fifo_empty && ~postddr_fifo_full && ~preddr_fifo_rd_r && ~postddr_fifo_wr)
                        preddr_fifo_rd = 1'b1;
                end
            end

            pS_DDR_WAIT_WRITE: begin
                // This is where we arbitrate between the different preddr sources.
                if (arm_event)  // TODO- other sources? used to have capture_go_adc here but that's not right
                                // (consider multiple active sources all firing off close to each other)
                                // I don't think this condition belongs here at all!
                    next_ddr_state = pS_DDR_IDLE;
                // ddr_state_r check because ddr_write_data_done goes low one cycle after getting here:
                else if (ddr_write_data_done && ~single_write_ui && (ddr_state_r == pS_DDR_WAIT_WRITE)) begin 
                    reset_app_address = 1'b1;
                    next_ddr_state = pS_DDR_IDLE;
                end
                else if (app_rdy && app_wdf_rdy) begin
                    if (single_write_ui)
                        next_ddr_state = pS_DDR_WRITE1;
                    else if (~preddr_all_fifo_empty_r && (ddr_state_r == pS_DDR_WAIT_WRITE)) begin // wait extra cycle for selection mux to switch
                        preddr_fifo_rd = 1'b1;
                        next_ddr_state = pS_DDR_WRITE1;
                    end
                    else
                        next_ddr_state = pS_DDR_WAIT_WRITE;
                end
                else
                    next_ddr_state = pS_DDR_WAIT_WRITE;
            end

            pS_DDR_WRITE1: begin
                main_app_en = 1'b1;
                main_app_wdf_wren = 1'b1;
                main_app_wdf_end = 1'b0;
                if (app_rdy && app_wdf_rdy)
                    next_ddr_state = pS_DDR_WRITE2;
                else
                    next_ddr_state = pS_DDR_WRITE1;
            end

            pS_DDR_WRITE2: begin
                main_app_en = 1'b0;
                main_app_wdf_wren = 1'b1;
                main_app_wdf_end = 1'b1;
                if (app_wdf_rdy) begin
                    if (single_write_ui) begin
                        next_ddr_state = pS_DDR_IDLE;
                        single_write_done = 1'b1;
                    end
                    else if (ddr_write_data_done) begin
                        reset_app_address = 1'b1;
                        next_ddr_state = pS_DDR_IDLE;
                    end
                    else begin
                        incr_app_address = 1'b1;
                        if (app_rdy && ~preddr_chosen_fifo_empty) begin
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
                main_app_en = 1'b0;
                if (ddr_rwtest_en || capture_go_any || arm_event || ddr_read_change)
                    next_ddr_state = pS_DDR_IDLE;
                else if (~postddr_fifo_empty_ui && ~read_started && ~single_read_ui) begin
                    pre_read_flush = 1'b1;
                    next_ddr_state = pS_DDR_WAIT_READ;
                end
                else if (app_rdy && (~postddr_fifo_prog_full || single_read_ui))
                    next_ddr_state = pS_DDR_READ1;
                else
                    next_ddr_state = pS_DDR_WAIT_READ;
            end

            pS_DDR_READ1: begin
                main_app_en = 1'b1;
                if (app_rdy) begin
                    incr_app_address = 1'b1;
                    next_ddr_state = pS_DDR_READ2;
                end
                else
                    next_ddr_state = pS_DDR_READ1;
            end

            pS_DDR_READ2: begin
                main_app_en = 1'b0;
                if (ddr_read_data_done || single_read_ui || capture_go_any)
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

    // NEW:
    reg preddr_all_fifo_empty_r;
    reg [1:0] source_select;
    reg active_source_adc;
    reg active_source_la;
    reg active_source_trace;
    wire [2:0] active_sources = {active_source_trace, active_source_la, active_source_adc};
    localparam pADC_SOURCE = 2'b00;
    localparam pLA_SOURCE = 2'b01;
    localparam pTRACE_SOURCE = 2'b10;
    wire preddr_all_fifo_empty = preddr_adc_fifo_empty &&
                                 preddr_la_fifo_empty &&
                                 preddr_trace_fifo_empty; 
    wire preddr_chosen_fifo_empty = (source_select == pADC_SOURCE)? preddr_adc_fifo_empty :
                                    (source_select == pLA_SOURCE)?  preddr_la_fifo_empty :
                                                                    preddr_la_fifo_empty;
    reg preddr_fifo_rd;
    assign preddr_adc_fifo_rd   = preddr_fifo_rd && (source_select == pADC_SOURCE);
    assign preddr_la_fifo_rd    = preddr_fifo_rd && (source_select == pLA_SOURCE);
    assign preddr_trace_fifo_rd = preddr_fifo_rd && (source_select == pTRACE_SOURCE);
    wire [63:0] preddr_fifo_dout = (source_select == pADC_SOURCE)? preddr_adc_fifo_dout :
                                   (source_select == pLA_SOURCE)?  preddr_la_fifo_dout :
                                                                   preddr_la_fifo_dout;

    reg capture_go_any;

    wire [2:0] ddr_active_read = {ddr_start_trace_read_ui, ddr_start_la_read_ui, ddr_start_adc_read_ui};
    reg  [2:0] ddr_active_read_r;
    reg  ddr_read_change;

    reg ddr_start_adc_read_ui;
    reg ddr_start_la_read_ui;
    reg ddr_start_trace_read_ui;
    (* ASYNC_REG = "TRUE" *) reg[1:0] ddr_start_adc_read_ui_pipe;
    (* ASYNC_REG = "TRUE" *) reg[1:0] ddr_start_la_read_ui_pipe;
    (* ASYNC_REG = "TRUE" *) reg[1:0] ddr_start_trace_read_ui_pipe;

    always @(posedge ui_clk) begin
        if (reset) begin
            ddr_start_adc_read_ui <= 0;
            ddr_start_la_read_ui <= 0;
            ddr_start_trace_read_ui <= 0;
            ddr_start_adc_read_ui_pipe <= 0;
            ddr_start_la_read_ui_pipe <= 0;
            ddr_start_trace_read_ui_pipe <= 0;
            ddr_active_read_r <= 0;
        end
        else begin
            ddr_active_read_r <= ddr_active_read;
            {ddr_start_adc_read_ui, ddr_start_adc_read_ui_pipe} <= {ddr_start_adc_read_ui_pipe, ddr_start_adc_read};
            {ddr_start_la_read_ui, ddr_start_la_read_ui_pipe} <= {ddr_start_la_read_ui_pipe, ddr_start_la_read};
            {ddr_start_trace_read_ui, ddr_start_trace_read_ui_pipe} <= {ddr_start_trace_read_ui_pipe, ddr_start_trace_read};
            if (ddr_active_read != ddr_active_read_r)
                ddr_read_change <= 1'b1;
            else if (ddr_state == pS_DDR_IDLE)
                ddr_read_change <= 1'b0;
        end
    end

    // DDR FSM sequential control logic and slow FIFO writes:
    always @(posedge ui_clk) begin
        if (reset) begin
            ddr_state <= pS_DDR_IDLE;
            ddr_state_r <= pS_DDR_IDLE;
            adc_app_addr <= 0;
            la_app_addr <= 0;
            trace_app_addr <= 0;
            ddr_full_error <= 0;
            postddr_fifo_wr <= 0;
            preddr_fifo_rd_r <= 0;
            adc_top_app_addr <= 0;
            la_top_app_addr <= 0;
            trace_top_app_addr <= 0;
            single_read_done <= 0;
            preddr_all_fifo_empty_r <= 0;
            source_select <= pADC_SOURCE;
            active_source_adc <= 0;
            active_source_la <= 0;
            active_source_trace <= 0;
            ddr_write_data_done <= 0;
            ddr_writing_r <= 0;
            read_started <= 1'b0;
            arm_event <= 0;
            capture_go_any <= 0;
        end

        else begin
            ddr_state <= next_ddr_state;
            ddr_state_r <= ddr_state;
            preddr_fifo_rd_r <= preddr_fifo_rd;
            preddr_all_fifo_empty_r <= preddr_all_fifo_empty;
            ddr_writing_r <= ddr_writing;
            single_read_done <= 0;
            if (capture_go_any)
                ddr_full_error <= 1'b0;
            // Convention is trace start address > LA start address, and ADC start address is 0.
            else if ( (adc_app_addr >= ddr_la_start_address) ||
                      (la_app_addr  >= ddr_trace_start_address) ||
                      (incr_app_address && (main_app_addr >= pDDR_MAX_ADDR)) )
                ddr_full_error <= 1'b1;

            if (single_write_ui || single_read_ui)
                adc_app_addr <= single_address;
            else if (reset_app_address) begin
                adc_app_addr <= 0;
                la_app_addr <= ddr_la_start_address;
                trace_app_addr <= ddr_trace_start_address;
                /*
                if (ddr_state != pS_DDR_IDLE) begin
                    if (ddr_state == pS_DDR_WAIT_WRITE)
                        adc_top_app_addr <= adc_app_addr;
                    else
                        adc_top_app_addr <= adc_app_addr + pDDR_INC_ADDR;
                end
                */
            end
            else if (incr_app_address) begin
                if (source_select == pADC_SOURCE) 
                    adc_app_addr <= adc_app_addr + pDDR_INC_ADDR;
                else if (source_select == pLA_SOURCE) 
                    la_app_addr <= la_app_addr + pDDR_INC_ADDR;
                else
                    trace_app_addr <= trace_app_addr + pDDR_INC_ADDR;
            end

            if (write_done_adc)
                adc_top_app_addr <= adc_app_addr + pDDR_INC_ADDR;
            if (write_done_la)
                la_top_app_addr <= la_app_addr + pDDR_INC_ADDR;
            if (write_done_trace)
                trace_top_app_addr <= trace_app_addr + pDDR_INC_ADDR;

            if (single_read_ui && app_rd_data_valid) begin
                if (app_rd_data_end) begin
                    single_read_data[63:32] <= app_rd_data;
                    single_read_done <= 1;
                end
                else
                    single_read_data[31:0] <= app_rd_data;
            end

            if (ddr_rwtest_en || single_write_ui || single_read_ui)
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

            // arbitrate DDR writing between the 3 input sources:
            // (very simple arbitration: assume that all sources go idle at
            // some point, to allow others their turn)
            if (single_write_go || single_read_go)
                source_select <= pADC_SOURCE;
            else if ((ddr_state == pS_DDR_WAIT_WRITE) && ~preddr_all_fifo_empty && ~preddr_fifo_rd) begin
                if (~preddr_adc_fifo_empty)
                    source_select <= pADC_SOURCE;
                else if (~preddr_la_fifo_empty)
                    source_select <= pLA_SOURCE;
                else if (~preddr_trace_fifo_empty)
                    source_select <= pTRACE_SOURCE;
            end
            else if (ddr_state == pS_DDR_IDLE) begin
                if (start_adc_read_ui_pulse)
                    source_select <= pADC_SOURCE;
                else if (start_la_read_ui_pulse)
                    source_select <= pLA_SOURCE;
                else if (start_trace_read_ui_pulse)
                    source_select <= pTRACE_SOURCE;
            end

            // Track active sources, to know when DDR FSM is done writing.
            // write_done_* refers to whether the associated front-end has
            // finished writing to its input FIFO, whereas ddr_write_data_done
            // (below) refers to whether the data from all active front-ends
            // has been written to DDR.
            if (write_done_adc)
                active_source_adc <= 1'b0;
            else if (capture_go_adc)
                active_source_adc <= 1'b1;

            if (write_done_la)
                active_source_la <= 1'b0;
            else if (capture_go_la)
                active_source_la <= 1'b1;

            if (write_done_trace)
                active_source_trace <= 1'b0;
            else if (capture_go_trace)
                active_source_trace <= 1'b1;

            // This signal is tricky to get right. It's crucial that it not
            // remain stuck high after it's set. To be clear, the intent is:
            // 1. Clear when a write or read begins.
            // 2. Set when in a write state and there are no more active sources.
            if (~use_ddr)
                // would never go high when bypassing DDR, so in case this status bit gets polled in a blocking fashion, set it:
                ddr_write_data_done <= 1'b1;
            else if (start_read_ui_pulse || (ddr_writing && ~ddr_writing_r))
                ddr_write_data_done <= 1'b0;
            else if (ddr_writing && (active_sources == 3'b000))
                ddr_write_data_done <= 1'b1;

            //TODO: first_read_pulse_ui can cause failures if it results in
            //read_started going back low when FSM is in pS_DDR_WAIT_READ
            //state (it will trigger a flush). It also generally causes
            //read_started to pulse low a second time on every read cycle.
            //Need to figure out a better solution but reluctant to do so
            //without a simulation testbench which covers all the corners
            //here.
            if (start_read_ui_pulse || first_read_pulse_ui)
                read_started <= 1'b0;
            else if (ddr_state == pS_DDR_READ1)
                read_started <= 1'b1;

            // To catch arm pulse even if we're busy; this is used to abort an active DDR read or write activity
            // if the scope is re-armed prior to the DDR process's normal conclusion. This can arise if the user
            // does a long capture but doesn't read the full capture.
            if (arm_pulse_ui) // TODO: what about non-ADC sources?
                arm_event <= 1'b1;
            else if (ddr_state == pS_DDR_IDLE)
                arm_event <= 1'b0;

            if (capture_go_adc || capture_go_la || capture_go_trace)
                capture_go_any <= 1'b1;
            else if (ddr_state_r == pS_DDR_IDLE)        // capture_go_any may cause the FSM to go to idle; by clearing on ddr_state_r,
                capture_go_any <= 1'b0;                 // we ensure that the FSM has a chance to exit idle
        end

    end

    always @(posedge clk_usb) begin
        if (reset) begin
            ddr_start_la_read_r <= 1'b0;
            ddr_start_trace_read_r <= 1'b0;
            ddr_start_adc_read_r <= 1'b0;
        end
        else begin
            ddr_start_la_read_r    <= ddr_start_la_read;
            ddr_start_trace_read_r <= ddr_start_trace_read;
            ddr_start_adc_read_r   <= ddr_start_adc_read;
        end
    end
    assign start_adc_read_usb_pulse = ddr_start_adc_read && ~ddr_start_adc_read_r;
    assign start_la_read_usb_pulse = ddr_start_la_read && ~ddr_start_la_read_r;
    assign start_trace_read_usb_pulse = ddr_start_trace_read && ~ddr_start_trace_read_r;

    cdc_pulse U_start_adc_read_cdc (
        .reset_i       (reset),
        .src_clk       (clk_usb),
        .src_pulse     (start_adc_read_usb_pulse),
        .dst_clk       (ui_clk),
        .dst_pulse     (start_adc_read_ui_pulse)
    );
    cdc_pulse U_start_la_read_cdc (
        .reset_i       (reset),
        .src_clk       (clk_usb),
        .src_pulse     (start_la_read_usb_pulse),
        .dst_clk       (ui_clk),
        .dst_pulse     (start_la_read_ui_pulse)
    );
    cdc_pulse U_start_trace_read_cdc (
        .reset_i       (reset),
        .src_clk       (clk_usb),
        .src_pulse     (start_trace_read_usb_pulse),
        .dst_clk       (ui_clk),
        .dst_pulse     (start_trace_read_ui_pulse)
    );



    // make overflow sticky:
    always @(posedge ui_clk) begin
       if (fresh_start_ui)
          fifo_overflow_ddr <= 1'b0;
       else if (postddr_fifo_overflow)
          fifo_overflow_ddr <= 1'b1;
    end

    always @(posedge clk_usb) begin
       postddr_fifo_rd_r <= postddr_fifo_rd && !(flushing || pre_read_flush_usb);
       // detect "reading too soon" separately from general underflow errors;
       if (fresh_start_usb)
          reading_too_soon_error <= 1'b0;
       else if (fifo_read_fifoen && ((ddr_state == pS_DDR_WAIT_READ) && pre_read_flush_usb))
          reading_too_soon_error <= 1'b1;

       // Detect a read which results in an empty FIFO (outside of flushing)
       // -- it's equivalent to underflow; tricky bit is that *sometimes* this
       // can legitimately happen on the last read. Solution: "charge" the
       // error flag and fire the error only if another read happens before
       // a new capture read is initiated.
       if (fresh_start_usb) begin
           postddr_effective_underflow_charged <= 1'b0;
           postddr_effective_underflow <= 1'b0;
       end
       else if (postddr_effective_underflow_charged && postddr_fifo_rd)
           postddr_effective_underflow <= 1'b1;
       else if (postddr_fifo_rd_r && postddr_fifo_empty) // TODO-note: should this detection also be added to Husky?
           postddr_effective_underflow_charged <= 1'b1;
    end



reg [15:0] read_stall_count;
reg [15:0] write_stall_count;
wire rw_stat_reset;
wire rw_reading;
wire rw_writing;

wire stat_reading = (ddr_rwtest_en)? rw_reading : (ddr_reading && ~postddr_fifo_prog_full);
wire stat_writing = (ddr_rwtest_en)? rw_writing : (ddr_writing && ~preddr_chosen_fifo_empty);
wire stat_reset = (ddr_rwtest_en)? rw_stat_reset : capture_go_adc;


    // collect DDR R/W statistics:
    always @ (posedge ui_clk) begin
        if (reset) begin
            ddr_read_read <= 0;
            ddr_read_idle <= 0;
            ddr_write_write <= 0;
            ddr_write_idle <= 0;
            read_stall_count <= 0;
            write_stall_count <= 0;
            ddr_max_read_stall_count <= 0;
            ddr_max_write_stall_count <= 0;
        end

        else begin
            if (stat_reset) begin
                ddr_read_read <= 0;
                ddr_read_idle <= 0;
                ddr_write_write <= 0;
                ddr_write_idle <= 0;
                read_stall_count <= 0;
                write_stall_count <= 0;
                ddr_max_read_stall_count <= 0;
                ddr_max_write_stall_count <= 0;
            end
            else begin

                if (stat_reading) begin
                    // note that in "mission mode", if we get throttled at all by the postddr FIFO,
                    // every stop and restart of reading will lead to a lot of idle cycles due to the
                    // lag between the first read request and the first read response
                    if (app_rd_data_valid && (ddr_read_read < {32{1'b1}}))
                        ddr_read_read <= ddr_read_read + 1;
                    else if (ddr_read_idle < {32{1'b1}})
                        ddr_read_idle <= ddr_read_idle + 1;

                    if (app_rd_data_valid) begin
                        read_stall_count <= 0;
                        if (read_stall_count > ddr_max_read_stall_count)
                            ddr_max_read_stall_count <= read_stall_count;
                    end
                    else
                        read_stall_count <= read_stall_count + 1;

                end

                if (stat_writing) begin
                    if (app_rdy && (ddr_write_write < {32{1'b1}}))
                        ddr_write_write <= ddr_write_write + 1;
                    else if (ddr_write_idle < {32{1'b1}})
                        ddr_write_idle <= ddr_write_idle + 1;

                    if (app_rdy) begin
                        write_stall_count <= 0;
                        if (write_stall_count > ddr_max_write_stall_count)
                            ddr_max_write_stall_count <= write_stall_count;
                    end
                    else
                        write_stall_count <= write_stall_count + 1;

                end
            end

        end
    end


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
   assign ui_clk = tb_ui_clk;
   ddr3_app_model #(
      .pDATA_WIDTH                         (32),
      .pADDR_WIDTH                         (30),
      .pMASK_WIDTH                         (4)
   ) U_ddr3_model (
      .clk                                 (ui_clk              ),
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
      .active_usb                          (ddr_rwtest_en      ),
      .init_calib_complete                 (init_calib_complete ),
      .pass                                (ddr_test_pass      ),
      .fail                                (ddr_test_fail      ),
      .clear_fail                          (ddr_test_clear_fail),

      .iteration                           (ddr_test_iteration ),
      .errors                              (ddr_test_errors    ),
      .error_addr                          (                    ),
      .ddrtest_incr                        (pDDR_INC_ADDR       ),
      .ddrtest_stop                        (pDDR_MAX_ADDR       ),
      .stat_reset                          (rw_stat_reset       ),
      .reading                             (rw_reading          ),
      .writing                             (rw_writing          ),

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
      .state                               (ddr_test_state         ),
      .comp_error                          (ddr_test_comp_error    ),
      .comp_good                           (ddr_test_comp_good     ),
      .expected_payload                    (ddr_test_expected_data ),
      .verify_addr                         (ddr_test_verify_addr   ),
      .lfsr                                (ddr_test_lfsr          )
   );


    `ifdef NOFIFO
       //for clean iverilog compilation

    `elsif TINYFIFO
       //for faster corner case simulation
       tiny_post_ddr_slow_fifo U_post_ddr_slow_fifo (
          .rst          (reset),
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

    `else
       //normal case
       post_ddr_slow_fifo U_post_ddr_slow_fifo (
          .rst          (reset),
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


`ifdef ILA_DDR3
    ila_ddr3 U_ila_ddr3 (
        .clk            (ui_clk             ),      // input wire clk
        .probe0         (ddr_rwtest_en      ),      // input wire [0:0] 
        .probe1         (init_calib_complete),      // input wire [0:0] 
        .probe2         (ddr_test_pass      ),      // input wire [0:0] 
        .probe3         (ddr_test_fail      ),      // input wire [0:0] 
        .probe4         (app_addr           ),      // input wire [29:0]
        .probe5         (app_cmd            ),      // input wire [2:0] 
        .probe6         (app_en             ),      // input wire [0:0] 
        .probe7         (app_wdf_data       ),      // input wire [31:0]
        .probe8         (app_wdf_end        ),      // input wire [0:0] 
        .probe9         (app_wdf_wren       ),      // input wire [0:0] 
        .probe10        (1'b0               ),      // input wire [0:0] 
        .probe11        (app_rd_data        ),      // input wire [31:0]
        .probe12        (app_rd_data_end    ),      // input wire [0:0] 
        .probe13        (app_rd_data_valid  ),      // input wire [0:0] 
        .probe14        (app_rdy            ),      // input wire [0:0] 
        .probe15        (app_wdf_rdy        ),      // input wire [0:0] 
        .probe16        (ddr_test_state     ),      // input wire [3:0] 
        .probe17        (ddr_test_iteration ),      // input wire [15:0]
        .probe18        (ddr_test_comp_error ),     // input wire [0:0] 
        .probe19        (ddr_test_comp_good  ),     // input wire [0:0] 
        .probe20        (ddr_test_expected_data),   // input wire [31:0]
        .probe21        (ddr_test_verify_addr),     // input wire [29:0]
        .probe22        (ddr_test_lfsr     )        // input wire [31:0]
    );

    ila_ui_fifo U_ila_ui_fifo (
        .clk            (ui_clk),               // input wire clk
        .probe0         (preddr_adc_fifo_rd),   // input wire [0:0]
        .probe1         (preddr_adc_fifo_dout), // input wire [63:0]
        .probe2         (preddr_adc_fifo_empty),// input wire [0:0]
        .probe3         (preddr_adc_fifo_underflow),// input wire [0:0]
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
        .probe20        (ddr_rwtest_en),        // input wire [0:0]
        .probe21        (reset_app_address),    // input wire [0:0]
        .probe22        (incr_app_address),     // input wire [0:0]
        .probe23        (ddr_write_data_done),  // input wire [0:0]
        .probe24        (ddr_read_data_done),   // input wire [0:0]
        .probe25        (ddr_full_error),       // input wire [0:0]
        .probe26        (ddr_writing),          // input wire [0:0]
        .probe27        (postddr_fifo_prog_full),// input wire [0:0]
        .probe28        (adc_top_app_addr),     // input wire [29:0]
        .probe29        (capture_go_adc),       // input wire [0:0]
        .probe30        (init_calib_complete),  // input wire [0:0]
        .probe31        (error_flag),           // input wire [0:0]
        .probe32        (ddr_single_done),      // input wire [0:0]
        .probe33        (single_write),         // input wire [0:0]
        .probe34        (single_read),          // input wire [0:0]
        .probe35        (active_sources),       // input wire [2:0]
        .probe36        (preddr_all_fifo_empty),// input wire [0:0]
        .probe37        (write_done_adc),       // input wire [0:0]
        .probe38        (start_read_ui_pulse),  // input wire [0:0]
        .probe39        (write_done_la),        // input wire [0:0]
        .probe40        (capture_go_la),        // input wire [0:0]
        .probe41        (preddr_la_fifo_rd),    // input wire [0:0]
        .probe42        (write_done_trace),     // input wire [0:0]
        .probe43        (capture_go_trace),     // input wire [0:0]
        .probe44        (preddr_trace_fifo_rd), // input wire [0:0]
        .probe45        (postddr_fifo_underflow_sticky),
        .probe46        (postddr_fifo_empty_ui),           
        .probe47        (read_started),                    
        .probe48        (pre_read_flush)                   
    );

`endif

`ifdef ILA_DDR_STATS
    ila_ddr_stats U_ila_ddr_stats (
        .clk            (ui_clk),                       // input wire clk
        .probe0         (ddr_read_read),                // input wire [31:0]
        .probe1         (ddr_read_idle),                // input wire [31:0]
        .probe2         (ddr_write_write),              // input wire [31:0]
        .probe3         (ddr_write_idle),               // input wire [31:0]
        .probe4         (read_stall_count),             // input wire [15:0]
        .probe5         (write_stall_count),            // input wire [15:0]
        .probe6         (ddr_max_read_stall_count),     // input wire [15:0]
        .probe7         (ddr_max_write_stall_count),    // input wire [15:0]
        .probe8         (ddr_state),                    // input wire [2:0]
        .probe9         (stat_reading),                 // input wire [0:0]
        .probe10        (stat_writing),                 // input wire [0:0]
        .probe11        (app_rd_data_valid),            // input wire [0:0]
        .probe12        (app_rdy),                      // input wire [7:0]
        .probe13        (ddr_reading),                  // input wire [0:0]
        .probe14        (ddr_writing),                  // input wire [0:0]
        .probe15        (postddr_fifo_prog_full),       // input wire [0:0]
        .probe16        (preddr_adc_fifo_empty)         // input wire [0:0]
    );
`endif

`ifdef ILA_HUSKY_FIFO
    ila_slow_fifo U_ila_slow_fifo (
        .clk            (clk_usb),              // input wire clk
        .probe0         (reset),                // input wire [0:0]
        .probe1         (postddr_fifo_dout),    // input wire [63:0]
        .probe2         (postddr_fifo_rd),      // input wire [0:0]
        .probe3         (postddr_fifo_empty),   // input wire [0:0]
        .probe4         (postddr_fifo_underflow),// input wire [0:0]
        .probe5         (flushing),             // input wire [0:0]
        .probe6         (arm_pulse_usb),        // input wire [0:0]
        .probe7         (slow_fifo_rd_fast),    // input wire [0:0]
        .probe8         (fifo_read_fifoen),     // input wire [0:0]
        .probe9         (slow_read_count),      // input wire [3:0]
        .probe10        (stream_segment_available), // input wire [0:0]
        .probe11        (fast_fifo_read_mode),  // input wire [0:0]
        .probe12        (fifo_read_data),       // input wire [7:0]
        .probe13        (error_flag),           // input wire [0:0]
        .probe14        (pre_read_flush_usb),   // input wire [0:0]
        .probe15        (first_read),           // input wire [0:0]
        .probe16        (first_read_done),      // input wire [0:0]
        .probe17        (read_started_usb),     // input wire [0:0]
        .probe18        (fresh_start_usb)       // input wire [0:0]
    );
`endif


endmodule
`default_nettype wire
