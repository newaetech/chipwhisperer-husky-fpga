`include "includes.v"
`timescale 1 ns / 1 ps
`default_nettype none
/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more
details, or the codebase at http://www.chipwhisperer.com

Copyright (c) 2013-2021, NewAE Technology Inc. All rights reserved.
Author: Colin O'Flynn <coflynn@newae.com>

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

module reg_openadc_adcfifo #(
   parameter pBYTECNT_SIZE = 7
)(
   input  wire         reset_i,
   input  wire         clk_usb,
   input  wire [7:0]   reg_address,  // Address of register
   input  wire [pBYTECNT_SIZE-1:0]  reg_bytecnt,  // Current byte count
   input  wire [7:0]   reg_datai,    // Data to write
   output wire [7:0]   reg_datao,    // Data to read
   input  wire         reg_read,     // Read flag
   input  wire         reg_write,    // Write flag

   /* ADC Fifo Interface */
   input  wire [2:0]   fifo_state,
   input  wire         fifo_empty,
   output wire         fifo_rd_en,
   output reg          low_res,
   output reg          low_res_lsb,
   output reg          fast_fifo_read_mode,
   output reg  [16:0]  stream_segment_threshold,
   input  wire [8:0]   fifo_error_stat,
   input  wire [8:0]   fifo_first_error_stat,
   input  wire [2:0]   fifo_first_error_state,
   output reg          clear_fifo_errors,

   input  wire [7:0]   underflow_count,
   output reg          no_underflow_errors,
   input  wire         capture_done,

   // for debug only:
   input  wire [31:0]  fifo_read_count,
   input  wire [31:0]  fifo_read_count_error_freeze
);

   wire  reset;
   assign reset = reset_i;

   reg fifo_rd_en_reg;
   reg [5:0] reg_read_pipe;
   wire reg_read_r = reg_read_pipe[0];

   // in fast FIFO read mode, need to shave off a clock cycle:
   assign fifo_rd_en = fast_fifo_read_mode? reg_read & ~reg_read_r : fifo_rd_en_reg;

   reg [7:0] reg_datao_reg;
   assign reg_datao = reg_datao_reg;

   wire [9:0] fifo_stat = {fifo_empty, fifo_error_stat};


   always @(*) begin
      if (reg_read) begin
         case (reg_address)
            `FIFO_STAT:                 reg_datao_reg = fifo_stat[reg_bytecnt*8 +: 8];
            `FIFO_STATE:                reg_datao_reg = {5'b0, fifo_state};
            `FIFO_FIRST_ERROR:          reg_datao_reg = fifo_first_error_stat[reg_bytecnt*8 +: 8];
            `FIFO_FIRST_ERROR_STATE:    reg_datao_reg = {5'b0, fifo_first_error_state};
            `DEBUG_FIFO_READS:          reg_datao_reg = fifo_read_count[reg_bytecnt*8 +: 8];
            `DEBUG_FIFO_READS_FREEZE:   reg_datao_reg = fifo_read_count_error_freeze[reg_bytecnt*8 +: 8];
            `STREAM_SEGMENT_THRESHOLD:  reg_datao_reg = stream_segment_threshold[reg_bytecnt*8 +: 8];
            `ADC_LOW_RES:               reg_datao_reg = {6'b0, low_res_lsb, low_res};
            `FIFO_UNDERFLOW_COUNT:      reg_datao_reg = underflow_count;
            `FIFO_NO_UNDERFLOW_ERROR:   reg_datao_reg = {7'b0, no_underflow_errors};
            `CAPTURE_DONE:              reg_datao_reg = {7'b0, capture_done};
            default:                    reg_datao_reg = 0;
         endcase
      end
      else
         reg_datao_reg = 0;
   end

   always @(posedge clk_usb) begin
      if (reset) begin
         low_res <= 0;
         low_res_lsb <= 0;
         clear_fifo_errors <= 1'b0;
         stream_segment_threshold <= 65536;
         no_underflow_errors <= 1'b0;   // disables flagging of *slow* FIFO underflow errors only
      end 
      else if (reg_write) begin
         case (reg_address)
            `ADC_LOW_RES: begin
               low_res <= reg_datai[0];
               low_res_lsb <= reg_datai[1];
            end
            `STREAM_SEGMENT_THRESHOLD:
               stream_segment_threshold[reg_bytecnt*8 +: 8] <= reg_datai; 
            `FIFO_STAT:
               clear_fifo_errors <= reg_datai[0];
            `FIFO_NO_UNDERFLOW_ERROR:
               no_underflow_errors <= reg_datai[0];
            default: ;
         endcase
      end
   end

   always @(posedge clk_usb) begin
      if (reset) begin
         fast_fifo_read_mode <= 1'b0;
      end
      else if (reg_write) begin
         if (reg_address == `FAST_FIFO_READ_MODE)
            fast_fifo_read_mode <= reg_datai[0];
         else if (fast_fifo_read_mode) // need to clear it on any other write!
            fast_fifo_read_mode <= 1'b0;
      end
   end

   wire fifo_rd_en_condition;
   `ifdef CW310
       // accomodate slower read times on CW310:
       assign fifo_rd_en_condition = reg_read_pipe[4] && ~reg_read_pipe[5];
   `else
       assign fifo_rd_en_condition = reg_read && ~reg_read_r;
   `endif
   always @(posedge clk_usb) begin
      reg_read_pipe <= {reg_read_pipe[4:0], reg_read};
      if (fifo_rd_en_condition && (reg_address == `ADCREAD_ADDR)) begin
         fifo_rd_en_reg <= 1;
      end else begin
         fifo_rd_en_reg <= 0;
      end
   end


endmodule
`default_nettype wire
