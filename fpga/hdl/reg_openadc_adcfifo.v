`include "includes.v"
`timescale 1 ns / 1 ps
`default_nettype none

/***********************************************************************
This file is part of the OpenADC Project. See www.newae.com for more details,
or the codebase at http://www.assembla.com/spaces/openadc .

This file is the OpenADC main registers. Does not include the actual data
transfer register which is in a seperate file.

Copyright (c) 2013-2021, Colin O'Flynn <coflynn@newae.com>. All rights reserved.
This project (and file) is released under the 2-Clause BSD License:

Redistribution and use in source and binary forms, with or without 
modification, are permitted provided that the following conditions are met:

   * Redistributions of source code must retain the above copyright notice,
	  this list of conditions and the following disclaimer.
   * Redistributions in binary form must reproduce the above copyright
	  notice, this list of conditions and the following disclaimer in the
	  documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.


*************************************************************************/
module reg_openadc_adcfifo #(
   parameter pBYTECNT_SIZE = 7
)(
   input  wire         reset_i,
   input  wire         clk_usb,
   input  wire [7:0]   reg_address,  // Address of register
   input  wire [pBYTECNT_SIZE-1:0]  reg_bytecnt,  // Current byte count
   input  wire [7:0]   reg_datai,    // Data to write
   inout  wire [7:0]   reg_datao,    // Data to read
   input  wire         reg_read,     // Read flag
   input  wire         reg_write,    // Write flag
   input  wire         reg_addrvalid,// Address valid flag

   /* ADC Fifo Interface */
   input  wire         fifo_empty,
   input  wire [7:0]   fifo_data,
   output wire         fifo_rd_en
);

   wire  reset;
   assign reset = reset_i;
   
   reg fifo_rd_en_reg;
   assign fifo_rd_en = fifo_rd_en_reg;
   
    
   reg [7:0] reg_datao_reg;
   reg reg_datao_valid_reg;
   reg reg_read_r;
   assign reg_datao = (reg_datao_valid_reg /*& reg_read*/) ? reg_datao_reg : 8'd0;
   
   
   always @(posedge clk_usb) begin
          if (reg_addrvalid) begin
             case (reg_address)
                `ADCREAD_ADDR: begin reg_datao_valid_reg <= 1; end
                default: begin reg_datao_valid_reg <= 0; end
             endcase
          end else begin
             reg_datao_valid_reg <= 0;
          end
   end
    
   //always @(reg_address, reg_addrvalid, reg_bytecnt, fifo_data) begin // TODO XXX verify change to @* works ok
   always @(*) begin
          if (reg_read) begin
             case (reg_address)
                //`ADCREAD_ADDR: reg_datao_reg <= (reg_bytecnt == 0) ? 8'hAC : fifo_data; 
                `ADCREAD_ADDR: reg_datao_reg <= fifo_data;  // TODO: unsure why AC byte was needed? should I keep it?
                default: reg_datao_reg <= 0;
             endcase
          end
   end

/*
	 always @(negedge clk_usb, negedge reg_read) begin
		if (reg_read == 0) begin
			fifo_rd_en_reg <= 0;
		end else if (reg_address == `ADCREAD_ADDR) begin
			if ((reg_bytecnt == 0) || (reg_bytecnt == 1)) begin
				fifo_rd_en_reg <= 0;
			end else begin
				fifo_rd_en_reg <= ~fifo_empty;
			end
		end else begin
			fifo_rd_en_reg <= 0;
		end
	 end	 
 */

   //always @(reg_read, reg_address, reg_bytecnt) begin
   always @(posedge clk_usb) begin
      reg_read_r <= reg_read;
      //if (reg_read && ~reg_read_r && (reg_address == `ADCREAD_ADDR) && (reg_bytecnt > 16'd0)) begin
      if (reg_read && ~reg_read_r && (reg_address == `ADCREAD_ADDR)) begin
         fifo_rd_en_reg <= 1;
      end else begin
         fifo_rd_en_reg <= 0;
      end
   end


endmodule
`default_nettype wire
