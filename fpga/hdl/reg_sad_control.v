`include "includes.v"
`timescale 1 ns / 1 ps
`default_nettype none

/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more
details, or the codebase at http://www.chipwhisperer.com

Copyright (c) 2024, NewAE Technology Inc. All rights reserved.
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

module reg_sad_control #(
   parameter pBYTECNT_SIZE = 7
)(
   input  wire         clk_usb,
   input  wire [7:0]   reg_address,  // Address of register
   input  wire [7:0]   reg_datai,    // Data to write
   //output wire [7:0]   reg_datao,    // Data to read
   //input  wire         reg_read,     // Read flag
   input  wire         reg_write,    // Write flag

   output reg          reset_o,
   output reg          armed_and_ready,
   output reg          sad_active,
   output reg          xadc_error
); 


   reg [7:0] reg_datao_reg;
   reg [7:0] data_reg;
   reg reg_write_r;

   always @(posedge clk_usb) begin
      if (reg_write && reg_address == `FIFO_STAT) // borrowing an address!
          {reset_o, armed_and_ready, sad_active, xadc_error} <= reg_datai[3:0];
   end


endmodule
`default_nettype wire
