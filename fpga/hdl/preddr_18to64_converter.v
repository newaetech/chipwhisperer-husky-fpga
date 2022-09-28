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

module preddr_18to64_converter (
    input wire          reset,
    input wire          wr_clk,
    input wire          rd_clk,
    input wire          capture_start,
    input wire          I_fifo_flush,
    input wire [17:0]   I_data,
    input wire          I_wr,

    input  wire         fifo_rd,
    output wire [63:0]  fifo_dout,
    output wire         fifo_empty
);


    // Assemble 64-bit words from 18-bit samples to feed DDR. Same approach as
    // fifo_top_husky_pro.v, different incoming width.
    reg [3:0] wide_word_count;
    reg wide_word_valid;
    reg [89:0] wide_word_shifter;
    reg [3:0] sample_counter;
    reg [63:0] fifo_din;
    reg fifo_wr;

    // TODO: report these somewhere
    wire fifo_full;
    wire fifo_overflow;
    wire fifo_underflow;

    wire fifo_rd_rd = fifo_rd || (I_fifo_flush & ~fifo_empty);

    always @(posedge wr_clk) begin
        if (reset) begin
            wide_word_count <= 0;
            wide_word_valid <= 0;
            wide_word_shifter <= 0;
            sample_counter <= 0;
            fifo_din <= 0;
            fifo_wr <= 0;
        end
        else begin
            fifo_wr <= wide_word_valid;
            if (capture_start) begin
                wide_word_count <= 0;
                wide_word_valid <= 0;
                wide_word_shifter <= 0;
                sample_counter <= 0;
            end
            else if (I_wr) begin
                wide_word_shifter <= {wide_word_shifter[53:0], I_data};
                if ( ((wide_word_count == 0) && (sample_counter == 3)) ||
                     ((wide_word_count == 1) && (sample_counter == 3)) ||
                     ((wide_word_count == 2) && (sample_counter == 2)) ||
                     ((wide_word_count == 3) && (sample_counter == 3)) ||
                     ((wide_word_count == 4) && (sample_counter == 2)) ||
                     ((wide_word_count == 5) && (sample_counter == 3)) ||
                     ((wide_word_count == 6) && (sample_counter == 2)) ||
                     ((wide_word_count == 7) && (sample_counter == 3)) ||
                     ((wide_word_count == 8) && (sample_counter == 3)) ) begin
                    wide_word_valid <= 1'b1;
                    sample_counter <= 0;
                    if (wide_word_count < 8)
                        wide_word_count <= wide_word_count + 1;
                    else
                        wide_word_count <= 0;
                end
                else begin
                    wide_word_valid <= 0;
                    sample_counter <= sample_counter + 1;
                end
            end

            if (wide_word_valid)
                fifo_din <= (wide_word_count == 1)? wide_word_shifter[89:26] :
                            (wide_word_count == 2)? wide_word_shifter[79:16] :
                            (wide_word_count == 3)? wide_word_shifter[87:24] :
                            (wide_word_count == 4)? wide_word_shifter[77:14] :
                            (wide_word_count == 5)? wide_word_shifter[85:22] :
                            (wide_word_count == 6)? wide_word_shifter[75:12] :
                            (wide_word_count == 7)? wide_word_shifter[83:20] :
                            (wide_word_count == 8)? wide_word_shifter[73:10] :
                                                    wide_word_shifter[81:18] ;
        end
    end

`ifdef NOFIFO
    //for clean iverilog compilation
    // TODO: need to indicate "write_done_adc" equivalent
`else
    pre_ddr_generic_fifo U_pre_ddr_fifo (
       .rst          (reset),
       .wr_clk       (wr_clk),
       .rd_clk       (rd_clk),
       .din          (fifo_din),
       .wr_en        (fifo_wr),
       .rd_en        (fifo_rd_rd),
       .dout         (fifo_dout),
       .full         (fifo_full),
       .empty        (fifo_empty),
       .overflow     (fifo_overflow),
       .underflow    (fifo_underflow)
    );
`endif // NOFIFO


endmodule
`default_nettype wire
