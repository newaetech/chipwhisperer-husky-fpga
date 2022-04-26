`timescale 1ns / 1ps
`default_nettype none

/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more
details, or the codebase at http://www.chipwhisperer.com

Copyright (c) 2014-2021, NewAE Technology Inc. All rights reserved.
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


module trigger_resync(
   input  wire          reset,
   input  wire          clk,    // clkgen or HS1
   input  wire          exttrig,
   input  wire [31:0]   offset,
   output reg           exttrigger_resync
);

   reg async_trigger = 1'b0;
   reg [31:0] glitch_delay_cnt;

   // This must be coded just so, otherwise Vivado will throw a "Synth 8-91
   // ambiguous clock" error. Or maybe we could get rid of the posedge exttrig
   // argument...
   always @(posedge clk or posedge exttrig) begin
      if (exttrig == 1'b1)
         async_trigger <= 1'b1;
      else
         async_trigger <= 1'b0;
   end

   always @(posedge clk) begin
      if (~async_trigger)
         glitch_delay_cnt <= 0;
      else if (glitch_delay_cnt != 32'hFFFFFFFF)
         glitch_delay_cnt <= glitch_delay_cnt + 1;

      if (glitch_delay_cnt == offset)
         exttrigger_resync <= 1'b1;
      else
         exttrigger_resync <= 1'b0;
   end


endmodule
`default_nettype wire

