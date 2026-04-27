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
    input  wire                         flushing,
    input  wire                         low_res,
    input  wire                         low_res_lsb,
    input  wire                         fifo_wr,
    input  wire [11:0]                  adc_datain,
    output wire                         full,
    output wire                         overflow,
    input  wire                         fifo_rd,
    output wire [47:0]                  fifo_dout,
    output wire                         empty,
    output wire                         almost_empty,
    output wire                         underflow
);

// TODO: tweak these!
// TODO: can I get even *MORE* presamples?!?
// Note: 512 is the minimum built-in FIFO depth; can investigate other implementations...
`ifdef PLUS
    `ifdef TINYFIFO
        localparam pDEPTH1 = 512;
        localparam pDEPTH2 = 1024;
    `else
        localparam pDEPTH1 = 512;
        localparam pDEPTH2 = 16384;
    `endif

`else
    `ifdef TINYFIFO
        localparam pDEPTH1 = 512;
        localparam pDEPTH2 = 1024;
    `else
        localparam pDEPTH1 = 512;
        localparam pDEPTH2 = 16384;
    `endif

`endif

    wire full_stage1;
    wire overflow_stage1;
    reg  ren_stage1 = 1'b0;
    wire [11:0] dout_stage1;
    wire empty_stage1;
    wire underflow_stage1;
    reg  wr_stage2 = 1'b0;
    reg  [47:0] din_stage2 = 48'd0;
    wire [3:0] full_stage2;
    wire [3:0] overflow_stage2;
    wire [47:0] dout_stage2;
    wire [3:0] empty_stage2;
    wire [3:0] empty_threshold_stage2;
    wire [3:0] underflow_stage2;


    assign full = full_stage1;
    assign empty = empty_stage2[0];
    assign almost_empty = empty_threshold_stage2[0];
    assign overflow = overflow_stage1 || overflow_stage2[0];
    assign underflow = underflow_stage1 || underflow_stage2[0];
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
    localparam pS_WAIT_WRITE = 1;
    localparam pS_FLUSHING = 2;
    reg [1:0] state = pS_IDLE;

    wire normal_mode = !flushing;

    // TODO: when no longer writing, then read every other cycle, to give the
    // empty flag a chance to show up? 
    //  - What about downsample? that's easy because by definition not writing
    //    each cycle!
    // Also TODO: when all is done, reconsider whether we need an FSM

    always @(posedge wclk) begin
        case (state)
            pS_IDLE: begin
                ren_stage1 <= 1'b0;
                if (flushing)
                    state <= pS_FLUSHING;
                else if (!empty_stage1 && (normal_mode? !full_stage2[0] : 1'b1)) begin
                    // to prevent underflowing on the last reads:
                    // TODO: make sure this works fine with downsampling (it should!)
                    if (fifo_wr || ! ren_stage1)
                        ren_stage1 <= 1'b1;
                    state <= pS_IDLE;
                end
            end

            // TODO: don't need this?
            /*
            pS_WAIT_WRITE: begin
                ren_stage1 <= 1'b0;
                if (!full2 && !ren_stage1) begin
                    wr2 <= 1'b1;
                    state <= pS_IDLE;
                end
            end
            */

            pS_FLUSHING: begin
                // note: stage2 is flushed by fifo_top_husky
                if (!empty_stage1)
                    ren_stage1 <= 1'b1;
                else begin
                    ren_stage1 <= 1'b0;
                    state <= pS_IDLE;
                end
            end

        endcase
    end

    reg [2:0] ren_stage1_count = 3'd0;
    reg ren_stage1_r = 1'b0;

    always @(posedge wclk) begin
        wr_stage2 <= 1'b0;
        if (flushing)
            ren_stage1_count <= 0;
        else begin
            ren_stage1_r <= ren_stage1;

            if (ren_stage1_r) begin
                if (ren_stage1_count == ((low_res)? 5:3)) begin
                    ren_stage1_count <= 0;
                    wr_stage2 <= 1'b1;
                end
                else
                    ren_stage1_count <= ren_stage1_count + 1;

                if (low_res) 
                    din_stage2 <= {din_stage2[39:0], (low_res_lsb)? dout_stage1[7:0] : dout_stage1[11:4]};
                else
                    din_stage2 <= {din_stage2[37:0], dout_stage1[11:0]};
            end
        end
    end



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

    // NOTE: could use a single wide FIFO, but it's easier to mirror what the
    // Xilinx case does, where we use 4x parallel FIFOs because it meets
    // timing more easily :shrug:
    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin
            fifo_async #(
                .pDATA_WIDTH    (12),
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
                .wdata                  (din_stage2[i*12 +: 12]),
                .wfull                  (full_stage2[i]),
                .walmost_full           (),
                .woverflow              (overflow_stage2[i]),
                .wfull_threshold        (),
                .ren                    (fifo_rd),
                .rdata                  (dout_stage2[i*12 +: 12]),
                .rempty                 (empty_stage2[i]),
                .ralmost_empty          (),
                .rempty_threshold       (empty_threshold_stage2[i]),
                .runderflow             (underflow_stage2[i])
            );
        end
    endgenerate

`else
    // TODO: Plus/Regular
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

    genvar i;
    generate
        for (i = 0; i < 4; i = i + 1) begin
            fast_slower_fifo U_slower_fifos (
                .rst                (~rst_n),
                .wr_clk             (wclk),
                .rd_clk             (rclk),
                .din                (din_stage2[i*12 +: 12]),
                .wr_en              (wr_stage2),
                .rd_en              (fifo_rd),
                .dout               (dout_stage2[i*12 +: 12]),
                .full               (full_stage2[i]),
                .empty              (empty_stage2[i]),
                .prog_empty         (empty_threshold_stage2[i]),
                .overflow           (overflow_stage2[i]),
                .underflow          (underflow_stage2[i])
            );
        end
    endgenerate

`endif


endmodule
