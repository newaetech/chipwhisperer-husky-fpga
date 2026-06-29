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

module slow_fifo_wrapper (
    input  wire                         clk,
    input  wire                         rst_n,
    input  wire                         fast_fifo_empty,
    input  wire                         fifo_wr,
    input  wire [71:0]                  fifo_din,
    output wire                         fifo_full,
    output wire                         fifo_full_threshold,
    output wire                         overflow,
    input  wire                         fifo_rd,
    output wire [71:0]                  fifo_dout,
    output wire                         fifo_empty,
    output wire                         underflow,
    output wire                         stage2_wr
);

// TODO: tweak these!
// TODO: do we really need two FIFOs here?
`ifdef PLUS
    `ifdef TINYFIFO
        localparam pDEPTH1 = 512;
        localparam pDEPTH2 = 512;
    `else
        localparam pDEPTH1 = 4096;
        localparam pDEPTH2 = 65536;
    `endif

`else
    `ifdef TINYFIFO
        localparam pDEPTH1 = 512;
        localparam pDEPTH2 = 512;
    `else
        localparam pDEPTH1 = 16384;
        localparam pDEPTH2 = 16384;
    `endif

`endif

assign stage2_wr = wr2;

wire wr1 = fifo_wr;
wire [71:0] din1 = fifo_din;
wire [71:0] dout1;
reg  rd1 = 1'b0;
wire wr2;
wire [71:0] din2;
wire [71:0] dout2;
wire rd2 = fifo_rd;

wire full1;
wire overflow1;
wire empty1;
wire underflow1;
wire empty_threshold1;
wire full_threshold1;
wire full_threshold2;

wire full2;
wire overflow2;
wire empty2;
wire underflow2;

assign fifo_dout = dout2;
assign fifo_full = full1;
assign fifo_full_threshold = full_threshold1;
assign fifo_empty = empty2;
assign overflow = overflow1 || overflow2;
assign underflow = underflow1 || underflow2;

assign wr2 = rd1;
assign din2 = dout1;

always @(posedge clk) begin
    if ( (!empty_threshold1 && !full_threshold2) ||
         (!rd1 && !empty1 && !full2 && fast_fifo_empty))
        rd1 <= 1'b1;
    else
        rd1 <= 1'b0;
end

/* debug only!
reg [31:0] fill_size2;
reg [31:0] fill_size_ext;
always @(posedge clk) begin
    if (arm_pulse_usb) begin
        fill_size2 <= 0;
        fill_size_ext <= 0;
    end
    else begin
        case ({wr2, rd2})
            2'b10: fill_size2 <= fill_size2 + 6;
            2'b01: fill_size2 <= fill_size2 - 6;
        endcase

        case ({fifo_wr, fifo_rd})
            2'b10: fill_size_ext <= fill_size_ext + 6;
            2'b01: fill_size_ext <= fill_size_ext - 6;
        endcase
    end
end
*/


`ifdef NOXILINXFIFO
    fifo_sync #(
        .pDATA_WIDTH    (72),
        .pDEPTH         (pDEPTH1),
        .pFALLTHROUGH   (1),
        .pFLOPS         (0),
        .pDISTRIBUTED   (0),
        .pBRAM          (1)
    ) U_fifo1 (
        .clk                        (clk),
        .rst_n                      (rst_n),
        .full_threshold_value       (pDEPTH1-1),
        .empty_threshold_value      (5),
        .wen                        (wr1),
        .wdata                      (din1),
        .full                       (full1),
        .overflow                   (overflow1),
        .full_threshold             (full_threshold1),
        .empty_threshold            (empty_threshold1),
        .ren                        (rd1),
        .rdata                      (dout1),
        .empty                      (empty1),
        .almost_empty               (),
        .almost_full                (),
        .underflow                  (underflow1)
    );

    fifo_sync #(
        .pDATA_WIDTH    (72),
        .pDEPTH         (pDEPTH2),
        .pFALLTHROUGH   (1),
        .pFLOPS         (0),
        .pDISTRIBUTED   (0),
        .pBRAM          (1)
    ) U_fifo2 (
        .clk                        (clk),
        .rst_n                      (rst_n),
        .full_threshold_value       (pDEPTH2-1),
        .empty_threshold_value      (0),
        .wen                        (wr2),
        .wdata                      (din2),
        .full                       (full2),
        .overflow                   (overflow2),
        .full_threshold             (full_threshold2),
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
        // we still split the FIFO for debug purposes!
        tiny_usb_slow_fifo1_plus U_fifo1(
            .clk                (clk),
            .rst                (~rst_n),
            .din                (din1),
            .wr_en              (wr1),
            .rd_en              (rd1),
            .dout               (dout1),
            .full               (full1),
            .empty              (empty1),
            .prog_empty         (empty_threshold1),
            .prog_full          (full_threshold1),
            .overflow           (overflow1),
            .underflow          (underflow1)
        );
        tiny_usb_slow_fifo2_plus U_fifo2(
            .clk                (clk),
            .rst                (~rst_n),
            .din                (din2),
            .wr_en              (wr2),
            .rd_en              (rd2),
            .dout               (dout2),
            .full               (full2),
            .empty              (empty2),
            .prog_full          (full_threshold2),
            .overflow           (overflow2),
            .underflow          (underflow2)
        );

    `else
        // TODO: Plus/Regular
        usb_slow_fifo1_plus U_fifo1(
            .clk                (clk),
            .rst                (~rst_n),
            .din                (din1),
            .wr_en              (wr1),
            .rd_en              (rd1),
            .dout               (dout1),
            .full               (full1),
            .empty              (empty1),
            .prog_empty         (empty_threshold1),
            .prog_full          (full_threshold1),
            .overflow           (overflow1),
            .underflow          (underflow1)
        );
        usb_slow_fifo2_plus U_fifo2(
            .clk                (clk),
            .rst                (~rst_n),
            .din                (din2),
            .wr_en              (wr2),
            .rd_en              (rd2),
            .dout               (dout2),
            .full               (full2),
            .empty              (empty2),
            .prog_full          (full_threshold2),
            .overflow           (overflow2),
            .underflow          (underflow2)
        );

    `endif

`endif


`ifdef ILA_SLOW_FIFO_WRAPPER
    ila_slow_fifo_wrap U_ila1 (
        .clk            (clk),
        .probe0         (wr1),
        .probe1         (full1),
        .probe2         (overflow1),
        .probe3         (full_threshold1),
        .probe4         (empty_threshold1),
        .probe5         (rd1),
        .probe6         (empty1),
        .probe7         (underflow1),

        .probe8         (wr2),
        .probe9         (full2),
        .probe10        (overflow2),
        .probe11        (rd2),
        .probe12        (empty2),
        .probe13        (underflow2),
        .probe14        (fifo_empty)
    );

`endif


endmodule
