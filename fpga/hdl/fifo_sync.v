`timescale 1 ns / 1 ps
`default_nettype none

/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more
details, or the codebase at http://www.chipwhisperer.com
Built from fifo_top_husky.v and modified for Pro.

http://www.sunburst-design.com/papers/CummingsSNUG2002SJ_FIFO1.pdf

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

module fifo_sync #(
    parameter pDATA_WIDTH = 8,
    parameter pDEPTH = 32,
    parameter pFALLTHROUGH = 0, // "first word fall through" 
    parameter pBRAM = 0
)(
    input  wire                         clk, 
    input  wire                         rst_n,
    input  wire [pADDR_WIDTH-1:0]       full_threshold_value,
    input  wire                         wen, 
    input  wire [pDATA_WIDTH-1:0]       wdata,
    output wire                         full,
    output reg                          overflow,
    output wire                         full_threshold,
    input  wire                         ren, 
    output wire [pDATA_WIDTH-1:0]       rdata,
    output wire                         empty,
    output wire                         almost_empty,
    output reg                          underflow
);

    localparam pADDR_WIDTH = (pDEPTH ==    32)? 5 :
                             (pDEPTH ==    64)? 6 :
                             (pDEPTH ==   128)? 7 :
                             (pDEPTH ==   256)? 8 :
                             (pDEPTH ==   512)? 9 :
                             (pDEPTH ==  1024)? 10 :
                             (pDEPTH ==  2048)? 11 :
                             (pDEPTH ==  4096)? 12 :
                             (pDEPTH ==  8192)? 13 :
                             (pDEPTH == 16384)? 14 :
                             (pDEPTH == 32768)? 15 :
                             (pDEPTH == 65536)? 16 : 0;

    wire [pADDR_WIDTH-1:0] waddr, raddr;
    reg  [pADDR_WIDTH:0] wptr, rptr;
    wire [pDATA_WIDTH-1:0] rdata_fwft;
    reg  [pDATA_WIDTH-1:0] rdata_reg;

    assign waddr = wptr[pADDR_WIDTH-1:0];
    assign raddr = rptr[pADDR_WIDTH-1:0];

    // r/w pointers:
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wptr <= 0;
            rptr <= 0;
        end
        else begin
            if (wen && !full)
                wptr <= wptr + 1;
            if (ren && !empty)
                rptr <= rptr + 1;
        end
    end

    // over/underflow flags:
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            overflow <= 1'b0;
            underflow <= 1'b0;
        end
        else begin
            if (wen && full) 
                overflow <= 1'b1;
            else 
                overflow <= 1'b0;
            if (ren && empty) 
                underflow <= 1'b1;
            else 
                underflow <= 1'b0;
        end
    end

    // storage:
    generate
        if (pBRAM) begin : bram_inst
            // TODO: Xilinx BRAM
        end
        else begin: flop_inst
            // RTL Verilog memory model
            reg [pDATA_WIDTH-1:0] mem [0:pDEPTH-1];
            assign rdata_fwft = mem[raddr];
            always @(posedge clk) begin
                if (wen && !full) mem[waddr] <= wdata;
                if (ren && !empty) rdata_reg <= rdata_fwft;
            end
            //debug only:
            wire [63:0] mem0 = mem[0];
            wire [63:0] mem1 = mem[1];
            wire [63:0] mem2 = mem[2];
            wire [63:0] mem3 = mem[3];
        end
    endgenerate

    // optional first word fall through mode
    assign rdata = pFALLTHROUGH ? rdata_fwft : rdata_reg;

    assign empty = (wptr == rptr);
    assign almost_empty = (wptr == rptr + 1) || empty;
    assign full = ( (wptr[pADDR_WIDTH] != rptr[pADDR_WIDTH]) &&
                    (wptr[pADDR_WIDTH-1:0] == rptr[pADDR_WIDTH-1:0]) );

    // programmable almost full threshold
    assign full_threshold = (rptr + full_threshold_value <= wptr);


endmodule

`default_nettype wire

