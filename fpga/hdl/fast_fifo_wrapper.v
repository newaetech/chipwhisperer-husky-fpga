`timescale 1 ns / 1 ps
`default_nettype none

/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more
details, or the codebase at http://www.chipwhisperer.com

Copyright (c) 2026, NewAE Technology Inc. All rights reserved.
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

module fast_fifo_wrapper (
    input  wire                         wclk,
    input  wire                         rclk,
    input  wire                         rst_n,
    input  wire                         done_writing,
    input  wire                         flushing,
    input  wire                         reset_internal_count,
    input  wire                         low_res,
    input  wire                         low_res_lsb,
    input  wire                         fifo_wr,
    input  wire [11:0]                  adc_datain,
    output wire                         full,
    output wire                         overflow,
    input  wire                         fifo_rd,
    output wire [71:0]                  fifo_dout,
    output wire                         empty_usb,
    output wire                         empty_adc,
    output wire                         almost_empty,
    output wire                         underflow,
    output wire                         empty_stage1_usb
);

// Note: 512 is the minimum Xilinx built-in FIFO depth, but our simulation FIFOs can do 256
`ifdef PLUS
    `ifdef TINYFIFO
        localparam pDEPTH1 = 256;
        localparam pDEPTH2 = 256;
    `else
        localparam pDEPTH1 = 2048;
        localparam pDEPTH2 = 8192;
    `endif

`else
    `ifdef TINYFIFO
        localparam pDEPTH1 = 256;
        localparam pDEPTH2 = 256;
    `else
        localparam pDEPTH1 = 2048;
        localparam pDEPTH2 = 4096;
    `endif

`endif

    wire full_stage1;
    wire overflow_stage1;
    reg  ren_stage1 = 1'b0;
    wire [11:0] dout_stage1;
    wire empty_stage1;
    wire underflow_stage1;
    reg  wr_stage2 = 1'b0;
    reg  [71:0] din_stage2 = 72'd0;
    wire full_stage2;
    wire overflow_stage2;
    wire [71:0] dout_stage2;
    wire empty_stage2;
    wire empty_threshold_stage2;
    wire underflow_stage2;

    cdc_simple U_empty_stage1_cdc (
        .reset          (!rst_n),
        .clk            (rclk),
        .data_in        (empty_stage1_delayed),
        .data_out       (empty_stage1_usb),
        .data_out_r     ()
    );


    assign full = full_stage1;
    assign almost_empty = empty_threshold_stage2;
    assign overflow = overflow_stage1 || overflow_stage2;
    assign underflow = underflow_stage1 || underflow_stage2;
    assign fifo_dout = dout_stage2;

    // Operation modes:
    // 1. flushing: all FIFOs are flushed. This is done when arming. Note
    //    that fifo_top_husky is responsible for flushing the stage2 FIFO.
    // 2. normal: whenever possible, read from stage1 and write to stage2.
    //    Stalls may occur.
    //
    // We use a simple FSM to cover these cases, and to to handle the case
    // where stage2 is not initially full, and so we read stage1, but then
    // stage2 *is* full when we're ready to write to it.
    // Finally note that this state machine is not general-purpose, it is
    // tuned to the particulars of the case at hand (that the stage2 FIFO
    // support higher throughput than the stage1 FIFO, by design).

    localparam pS_IDLE = 0;
    localparam pS_FLUSHING = 1;
    reg state = pS_IDLE;

    wire normal_mode = !flushing;

    // Note: FSM may be overkill here but it works
    always @(posedge wclk) begin
        case (state)
            pS_IDLE: begin
                ren_stage1 <= 1'b0;
                if (flushing)
                    state <= pS_FLUSHING;
                else if (!empty_stage1 && (normal_mode? !full_stage2 : 1'b1)) begin
                    // to prevent underflowing on the last reads:
                    if (fifo_wr || ! ren_stage1)
                        ren_stage1 <= 1'b1;
                    state <= pS_IDLE;
                end
            end

            pS_FLUSHING: begin
                // Note: stage2 is flushed by fifo_top_husky
                if (!empty_stage1)
                    ren_stage1 <= 1'b1;
                else begin
                    ren_stage1 <= 1'b0;
                    state <= pS_IDLE;
                end
            end

        endcase
    end

    reg [3:0] ren_stage1_count = 4'd0;
    reg ren_stage1_r = 1'b0;

    reg [1:0] empty_stage1_r;
    wire empty_stage1_delayed = empty_stage1_r[1] && empty_stage1_r[0];
    always @(posedge wclk) begin
        empty_stage1_r <= {empty_stage1_r[0], empty_stage1};
        wr_stage2 <= 1'b0;
        if (flushing || reset_internal_count)
            ren_stage1_count <= 0;
        else begin
            ren_stage1_r <= ren_stage1;

            if (ren_stage1_r) begin
                if (ren_stage1_count == ((low_res)? 8:5)) begin
                    ren_stage1_count <= 0;
                    wr_stage2 <= 1'b1;
                end
                else
                    ren_stage1_count <= ren_stage1_count + 1;

                if (low_res) 
                    din_stage2 <= {din_stage2[63:0], (low_res_lsb)? dout_stage1[7:0] : dout_stage1[11:4]};
                else
                    din_stage2 <= {din_stage2[59:0], dout_stage1[11:0]};

            end
        end
    end

    // read-side empty signal is simply the 2nd FIFO's empty signal;
    // it accurately reflects whether data is available to be read; note that 
    // it does NOT mean or imply that the 1st FIFO is empty!
    assign empty_usb = empty_stage2;

    // The write-side empty flag *conservately* indicates whether all the
    // FIFOs here are well and truly empty. It is OK to show "not empty" when
    // it is, but not vice-versa.
    // 
    // This is tricky to get right, due to the two-stage architecture.
    // Consider this scenario where we could declare the FIFOs empty when they
    // are actually not:
    // - stage1 is no longer being written (the full capture or the segment is done)
    // - stage2 is read and is about to go empty
    // - but stage1 had one entry left; we don't know this because there is no "almost empty" flag available
    // - this triggers one more write to stage2, and so (after CDC delays) it
    //   will no longer be empty, and it gets read one last time
    // - the problem happens if that last read, which triggers a slow FIFO
    //   write, comes after (or at the same time) as the save_offset write:
    //   this makes things out of whack.
    //
    // If you're not convinced, try this in a regression and you *will* see
    // failures!
    // assign empty_adc = empty_stage2;  to induce errors!
    //
    // We use a simple FSM to construct our conservative empty flag. CDC
    // to-and-from the USB clock domain is key. This is quite conservative;
    // empty_adc is slow to go high, but that's quite alright (the only cost
    // to this is that segments can't be as close together as they possibly
    // could, but that is a rather degenerate use case anyhow).

    localparam pS_EMPTY_NOT = 0;
    localparam pS_EMPTY_WAIT = 1;
    localparam pS_EMPTY_DONE = 2;
    reg [1:0] empty_state = pS_EMPTY_NOT;

    reg empty_adc_reg = 1'b0;
    reg empty_pulse = 1'b0;
    wire empty_pulse_rclk;
    wire empty_pulse_back;
    wire empty_stage2_adc;
    assign empty_adc = empty_adc_reg;

    localparam pDONE_WRITING_DELAY = 4;
    reg [pDONE_WRITING_DELAY-1:0] done_writing_pulse = {pDONE_WRITING_DELAY{1'b0}};
    always @(posedge wclk) done_writing_pulse <= {done_writing_pulse[pDONE_WRITING_DELAY-2:0], done_writing};

    always @(posedge wclk) begin
        case (empty_state)
            pS_EMPTY_NOT: begin
                empty_adc_reg <= 1'b0;
                if (done_writing_pulse[pDONE_WRITING_DELAY-1] && empty_stage1 && empty_stage2_adc) begin
                    empty_state <= pS_EMPTY_WAIT;
                    empty_pulse <= 1'b1;
                end
            end

            pS_EMPTY_WAIT: begin
                empty_pulse <= 1'b0;
                if (fifo_wr) begin // should not happen under normal use! (but might)
                    empty_adc_reg <= 1'b0;
                    empty_state <= pS_EMPTY_NOT;
                end
                else if (empty_pulse_back)
                    empty_state <= pS_EMPTY_DONE;
            end

            pS_EMPTY_DONE: begin
                empty_adc_reg <= 1'b1;
                if (fifo_wr) begin
                    empty_adc_reg <= 1'b0;
                    empty_state <= pS_EMPTY_NOT;
                end
            end
        endcase
    end

    cdc_pulse U_empty_pulse_cdc (
       .reset_i       (!rst_n),
       .src_clk       (wclk),
       .src_pulse     (empty_pulse),
       .dst_clk       (rclk),
       .dst_pulse     (empty_pulse_rclk)
    );

    cdc_pulse U_empty_pulse_back_cdc (
       .reset_i       (!rst_n),
       .src_clk       (rclk),
       .src_pulse     (empty_pulse_rclk),
       .dst_clk       (wclk),
       .dst_pulse     (empty_pulse_back)
    );

    cdc_simple U_empty2_cdc (
        .reset          (!rst_n),
        .clk            (wclk),
        .data_in        (empty_stage2),
        .data_out       (empty_stage2_adc),
        .data_out_r     ()
    );



`ifdef NOXILINXFIFO
    fifo_sync #(
        .pDATA_WIDTH            (12),
        .pDEPTH                 (pDEPTH1),
        .pFALLTHROUGH           (0),
        .pFLOPS                 (0),
        .pDISTRIBUTED           (0),
        .pBRAM                  (1)
    ) U_fast_fifo (
        .clk                    (wclk),
        .rst_n                  (rst_n),
        .full_threshold_value   (0),
        .empty_threshold_value  (0),
        .wen                    (fifo_wr),
        .wdata                  (adc_datain),
        .full                   (full_stage1),
        .overflow               (overflow_stage1),
        .full_threshold         (),
        .empty_threshold        (),
        .ren                    (ren_stage1),
        .rdata                  (dout_stage1),
        .empty                  (empty_stage1),
        .almost_empty           (),
        .almost_full            (),
        .underflow              (underflow_stage1)
    );

    fifo_async #(
        .pDATA_WIDTH    (72),
        .pDEPTH         (pDEPTH2),
        .pFALLTHROUGH   (1),
        .pFLOPS         (0),
        .pDISTRIBUTED   (0),
        .pBRAM          (1)
    ) U_slower_fifos (
        .wclk                   (wclk),
        .rclk                   (rclk),
        .wrst_n                 (rst_n),
        .rrst_n                 (rst_n),
        .wfull_threshold_value  (0),
        .rempty_threshold_value (5),
        .wen                    (wr_stage2),
        .wdata                  (din_stage2),
        .wfull                  (full_stage2),
        .walmost_full           (),
        .woverflow              (overflow_stage2),
        .wfull_threshold        (),
        .ren                    (fifo_rd),
        .rdata                  (dout_stage2),
        .rempty                 (empty_stage2),
        .ralmost_empty          (),
        .rempty_threshold       (empty_threshold_stage2),
        .runderflow             (underflow_stage2)
    );


`else
    `ifdef TINYFIFO
        tiny_adc_fast_fifo U_fast_fifo (
            .clk            (wclk),
            .rst            (~rst_n),
            .din            (adc_datain),
            .wr_en          (fifo_wr),
            .rd_en          (ren_stage1),
            .dout           (dout_stage1),
            .full           (full_stage1),
            .empty          (empty_stage1),
            .overflow       (overflow_stage1),
            .underflow      (underflow_stage1)
        );
        tiny_fast_slower_fifo U_slower_fifos (
            .rst                (~rst_n),
            .wr_clk             (wclk),
            .rd_clk             (rclk),
            .din                (din_stage2),
            .wr_en              (wr_stage2),
            .rd_en              (fifo_rd),
            .dout               (dout_stage2),
            .full               (full_stage2),
            .empty              (empty_stage2),
            .prog_empty         (empty_threshold_stage2),
            .overflow           (overflow_stage2),
            .underflow          (underflow_stage2)
        );

    `else
        adc_fast_fifo U_fast_fifo (
            .clk            (wclk),
            .rst            (~rst_n),
            .din            (adc_datain),
            .wr_en          (fifo_wr),
            .rd_en          (ren_stage1),
            .dout           (dout_stage1),
            .full           (full_stage1),
            .empty          (empty_stage1),
            .overflow       (overflow_stage1),
            .underflow      (underflow_stage1)
        );
        fast_slower_fifo U_slower_fifos (
            .rst                (~rst_n),
            .wr_clk             (wclk),
            .rd_clk             (rclk),
            .din                (din_stage2),
            .wr_en              (wr_stage2),
            .rd_en              (fifo_rd),
            .dout               (dout_stage2),
            .full               (full_stage2),
            .empty              (empty_stage2),
            .prog_empty         (empty_threshold_stage2),
            .overflow           (overflow_stage2),
            .underflow          (underflow_stage2)
        );
    `endif

`endif

`ifdef ILA_FAST_FIFO_WRAPPER
    ila_fast_fifo_wrap_write U_ila1 (
        .clk            (wclk),
        .probe0         (fifo_wr),
        .probe1         (full_stage1),
        .probe2         (overflow_stage1),
        .probe3         (ren_stage1),
        .probe4         (empty_stage1),
        .probe5         (underflow_stage1),
        .probe6         (wr_stage2),
        .probe7         (full_stage2),
        .probe8         (empty_adc),
        .probe9         (empty_stage2)
    );

    ila_fast_fifo_wrap_read U_ila2 (
        .clk            (rclk),
        .probe0         (fifo_rd),
        .probe1         (empty_stage2),
        .probe2         (underflow_stage2),
        .probe3         (empty_usb)
    );

`endif

endmodule
