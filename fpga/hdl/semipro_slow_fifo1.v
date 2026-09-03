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

module semipro_slow_fifo1 #(
    parameter pDEPTH1 = 1024,
    parameter pDEPTH2 = 1024
)(
    input  wire                         clk,
    input  wire                         rst_n,
    input  wire                         wr,
    input  wire [35:0]                  din,
    output wire                         full,
    output wire                         overflow,
    input  wire                         rd,
    output wire [35:0]                  dout,
    output wire                         empty,
    output wire                         underflow
);


wire wr1 = wr;
wire [35:0] din1 = din;
wire [35:0] dout1;
reg  rd1 = 1'b0;
reg  wr2 = 1'b0;
reg  [35:0] din2;
wire [35:0] dout2;
wire rd2 = rd;

wire full1;
wire overflow1;
wire empty1;
wire underflow1;

wire full2;
wire overflow2;
wire empty2;
wire underflow2;

assign dout = dout2;
assign full = full1;
assign empty = empty2;
assign overflow = overflow1 || overflow2;
assign underflow = underflow1 || underflow2;


// simple FSM to handle case where fifo2 is not initially full,
// and so we read fifo1, but then fifo2 *is* full when we're ready to write to it:
localparam pS_IDLE = 0;
localparam pS_WAIT_WRITE = 1;
reg state = pS_IDLE;

always @(posedge clk) begin
    case (state)
        pS_IDLE: begin
            rd1 <= 1'b0;
            wr2 <= 1'b0;
            if (!empty1 && !full2) begin
                rd1 <= 1'b1;
                state <= pS_WAIT_WRITE;
            end
        end

        pS_WAIT_WRITE: begin
            rd1 <= 1'b0;
            if (!full2 && !rd1) begin
                wr2 <= 1'b1;
                state <= pS_IDLE;
            end
        end

    endcase
end

always @(posedge clk) begin
    if (rd1)
        din2 <= dout1;
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
        .clk                        (clk),
        .rst_n                      (rst_n),
        .full_threshold_value       (0),
        .empty_threshold_value      (0),
        .wen                        (wr1),
        .wdata                      (din1),
        .full                       (full1),
        .overflow                   (overflow1),
        .full_threshold             (),
        .empty_threshold            (),
        .ren                        (rd1),
        .rdata                      (dout1),
        .empty                      (empty1),
        .almost_empty               (),
        .almost_full                (),
        .underflow                  (underflow1)
    );

    fifo_sync #(
        .pDATA_WIDTH    (36),
        .pDEPTH         (pDEPTH2),
        .pFALLTHROUGH   (1),
        .pFLOPS         (0),
        .pDISTRIBUTED   (0),
        .pBRAM          (1)
    ) U_fifo2 (
        .clk                        (clk),
        .rst_n                      (rst_n),
        .full_threshold_value       (0),
        .empty_threshold_value      (0),
        .wen                        (wr2),
        .wdata                      (din2),
        .full                       (full2),
        .overflow                   (overflow2),
        .full_threshold             (),
        .empty_threshold            (),
        .ren                        (rd2),
        .rdata                      (dout2),
        .empty                      (empty2),
        .almost_empty               (),
        .almost_full                (),
        .underflow                  (underflow2)
    );


`else
    `ifdef TINYFIFO
        // no point in splitting FIFOs here!
        tiny_usb_slow_fifo1_semipro U_fifo1(
            .clk                (clk),
            .rst                (~rst_n),
            .din                (din),
            .wr_en              (wr1),
            .rd_en              (rd2),
            .dout               (dout2),
            .full               (full1),
            .empty              (empty2),
            .overflow           (overflow2),
            .underflow          (underflow2)
        );
        assign full2 = 1'b0;
        assign empty1 = 1'b0; // so that the (uneeded in this case) FSM remains idle
        assign overflow1 = 1'b0;
        assign underflow1 = 1'b0;

    `else
        usb_slow_fifo11_semipro U_fifo1(
            .clk                (clk),
            .rst                (~rst_n),
            .din                (din),
            .wr_en              (wr1),
            .rd_en              (rd1),
            .dout               (dout1),
            .full               (full1),
            .empty              (empty1),
            .overflow           (overflow1),
            .underflow          (underflow1)
        );

        usb_slow_fifo12_semipro U_fifo2(
            .clk                (clk),
            .rst                (~rst_n),
            .din                (din2),
            .wr_en              (wr2),
            .rd_en              (rd2),
            .dout               (dout2),
            .full               (full2),
            .empty              (empty2),
            .overflow           (overflow2),
            .underflow          (underflow2)
        );

    `endif

`endif

endmodule
