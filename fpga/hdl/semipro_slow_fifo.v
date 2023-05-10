`timescale 1 ns / 1 ps
`default_nettype none

/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more
details, or the codebase at http://www.chipwhisperer.com

Copyright (c) 2023, NewAE Technology Inc. All rights reserved.
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

module semipro_slow_fifo #(
    parameter pDEPTH1 = 1024,
    parameter pDEPTH2 = 1024
)(
    input  wire                         streaming,
    input  wire                         wclk,
    input  wire                         rclk,
    input  wire                         rst_n,
    input  wire                         wr,
    input  wire [35:0]                  din,
    output wire                         full,
    output wire                         overflow,
    input  wire                         rd,
    output wire [35:0]                  dout,
    output wire                         empty,
    output wire                         underflow,
    input  wire                         fast_fifo_wr, // debug only
    input  wire                         fast_fifo_full // debug only
);

/* The purpose of this module is to squeeze as much BRAM FIFO storage as
* possible by getting around Xilinx FIFO limitations:
* 1- FIFO depth limited to powers of 2
* 2- empty flag on built-in FIFOs have a significant latency which goes up as
*    the FIFO depth increases, which makes deep FIFOs unsuitable for
*    U_adc_fast_fifo (due to how that FIFO is used for presamples
* The workaround is to keep U_adc_fast_fifo reasonably shallow (due to 2) and
* to use this module to create a synthetic U_usb_slow_fifo out of 2 FIFOs to
* maximimize storage depth (due to 1)
*
* To keep things ~simple, this module can be used in one of two ways:
* 1- when not streaming: first the second FIFO is filled; once it gets filled,
*    the first FIFO is filled. Reading is not supported when FIFOs are getting
*    filled. This is what happens IRL when doing a normal (non-streaming
*    capture). When reading begins, the first FIFO's contents get emptied into
*    the second FIFO whenever this is possible, so that the output data always
*    originates from the second FIFO.
* 2- when streaming: only the second FIFO is used, in order to support
*    simultaneous reading and writing. (This limitation could be lifted (by
*    improving/complicating this design) but this is likely not necessary in
*    practice, so let's keeps things simple.)
*/ 

    reg  fifo1_wr;
    reg  [35:0] fifo1_din;
    wire fifo1_full;
    wire fifo1_overflow;
    reg  fifo1_rd;
    wire [35:0] fifo1_dout;
    wire fifo1_empty;
    wire fifo1_underflow;
    reg  fifo2_wr;
    reg  [35:0] fifo2_din;
    wire fifo2_full;
    wire fifo2_overflow;
    wire fifo2_empty;
    wire fifo2_underflow;

    reg fifo_fill_mode;

    assign underflow = fifo1_underflow || fifo2_underflow;
    assign overflow = fifo1_overflow || fifo2_overflow;
    assign full = fifo1_full; // fifo2_full doesn't matter-- if fifo1 is full then we don't want to be written to!
    assign empty = fifo1_empty && fifo2_empty;

    always @(*) begin
        // defaults to prevent latches
        fifo1_wr = 1'b0;
        fifo2_wr = 1'b0;
        fifo1_rd = 1'b0;
        fifo1_din = din;
        fifo2_din = din;

        if (streaming) begin
            fifo1_wr = 1'b0;
            fifo1_rd = 1'b0;
            fifo2_wr = wr;
            fifo2_din = din;
        end

        else begin // not streaming
            // 1: fill 2nd FIFO
            if (fifo_fill_mode == 0) begin
                fifo2_wr = wr;
                fifo2_din = din;
            end

            // 2: once 2nd FIFO is full, start filling first FIFO
            else begin
                fifo1_wr = wr;
                fifo1_din = din;
                fifo2_din = fifo1_dout;
                if (~fifo1_empty && ~fifo2_full) begin
                    fifo1_rd = 1'b1;
                    fifo2_wr = 1'b1;
                end
                else begin
                    fifo1_rd = 1'b0;
                    fifo2_wr = 1'b0;
                end

            end
        end
    end

    always @(posedge wclk) begin
        if (~rst_n)
            fifo_fill_mode <= 0;
        else begin
            if (fifo1_empty && fifo2_empty)
                fifo_fill_mode <= 0;
            else if (fifo2_full)        // note: we don't need to use almost_full here because we know that back-to-back writes can't occur
                fifo_fill_mode <= 1;
        end
    end


    `ifdef NOXILINXFIFO

        fifo_sync #(
            .pDATA_WIDTH    (36),
            .pDEPTH         (pDEPTH1),
            .pFALLTHROUGH   (1),
            .pFLOPS         (0),
            .pDISTRIBUTED   (0),
            .pBRAM          (1)
        ) U_fifo1 (
            .clk                        (wclk),
            .rst_n                      (rst_n),
            .full_threshold_value       (0),
            .empty_threshold_value      (0),
            .wen                        (fifo1_wr),
            .wdata                      (fifo1_din),
            .full                       (fifo1_full),
            .overflow                   (fifo1_overflow),
            .full_threshold             (),
            .empty_threshold            (),
            .ren                        (fifo1_rd),
            .rdata                      (fifo1_dout),
            .empty                      (fifo1_empty),
            .almost_empty               (),
            .almost_full                (),
            .underflow                  (fifo1_underflow)
        );

        fifo_async #(
            .pDATA_WIDTH    (36),
            .pDEPTH         (pDEPTH2),
            .pFALLTHROUGH   (1),
            .pFLOPS         (0),
            .pDISTRIBUTED   (0),
            .pBRAM          (1)
        ) U_fifo2 (
            .wclk                   (wclk),
            .rclk                   (rclk),
            .wrst_n                 (rst_n),
            .rrst_n                 (rst_n),
            .wfull_threshold_value  (0),
            .rempty_threshold_value (0),
            .wen                    (fifo2_wr),
            .wdata                  (fifo2_din),
            .wfull                  (fifo2_full),
            .walmost_full           (),
            .woverflow              (fifo2_overflow),
            .wfull_threshold        (),
            .ren                    (rd),
            .rdata                  (dout),
            .rempty                 (fifo2_empty),
            .ralmost_empty          (),
            .rempty_threshold       (),
            .runderflow             (fifo2_underflow)
        );


    `else
        `ifdef TINYFIFO
            tiny_usb_slow_fifo1_semipro U_fifo1(
                .clk                (wclk),
                .rst                (~rst_n),
                .din                (fifo1_din),
                .wr_en              (fifo1_wr),
                .rd_en              (fifo1_rd),
                .dout               (fifo1_dout),
                .full               (fifo1_full),
                .empty              (fifo1_empty),
                .overflow           (fifo1_overflow),
                .underflow          (fifo1_underflow)
            );
            tiny_usb_slow_fifo U_fifo2(
                .rst                (~rst_n),
                .wr_clk             (wclk),
                .rd_clk             (rclk),
                .din                (fifo2_din),
                .wr_en              (fifo2_wr),
                .rd_en              (rd),
                .dout               (dout),
                .full               (fifo2_full),
                .empty              (fifo2_empty),
                .overflow           (fifo2_overflow),
                .underflow          (fifo2_underflow)
            );

        `else
            usb_slow_fifo1_semipro U_fifo1(
                .clk                (wclk),
                .rst                (~rst_n),
                .din                (fifo1_din),
                .wr_en              (fifo1_wr),
                .rd_en              (fifo1_rd),
                .dout               (fifo1_dout),
                .full               (fifo1_full),
                .empty              (fifo1_empty),
                .overflow           (fifo1_overflow),
                .underflow          (fifo1_underflow)
            );
            usb_slow_fifo_semipro U_fifo2(
                .rst                (~rst_n),
                .wr_clk             (wclk),
                .rd_clk             (rclk),
                .din                (fifo2_din),
                .wr_en              (fifo2_wr),
                .rd_en              (rd),
                .dout               (dout),
                .full               (fifo2_full),
                .empty              (fifo2_empty),
                .overflow           (fifo2_overflow),
                .underflow          (fifo2_underflow)
            );
        `endif

    `endif

    `ifdef ILA_COMBI_FIFO
       ila_combi_fifo U_ila_combi_fifo (
          .clk            (rclk),
          .probe0         (rst_n),
          .probe1         (wr),
          .probe2         (rd),
          .probe3         (fifo1_full),
          .probe4         (fifo1_empty),
          .probe5         (fifo1_overflow),
          .probe6         (fifo1_underflow),
          .probe7         (fifo2_full),
          .probe8         (fifo2_empty),
          .probe9         (fifo2_overflow),
          .probe10        (fifo2_underflow),
          .probe11        (fifo_fill_mode),
          .probe12        (streaming),
          .probe13        (fifo1_wr),
          .probe14        (fifo1_rd),
          .probe15        (fifo2_wr),
          .probe16        (fast_fifo_wr),
          .probe17        (fast_fifo_full)
       );
    `endif


endmodule
