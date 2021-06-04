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
   input wire   reset,
   input wire   clk,    // clkgen or HS1
   input wire   exttrig,
   input wire [31:0] offset,
   output wire  exttrigger_resync
);

   reg data_status;
   reg async_trigger_inv;
   always @(posedge clk or posedge exttrig) begin
      if (exttrig == 1'b1)
         async_trigger_inv <= 1'b0;
      else
         async_trigger_inv <= data_status;
   end

   //async_trigger_inv gets set to '0' once trigger happens
   //and will get set back to '1' once we are no longer triggering

    /* Glitch Delay */
   reg [31:0] glitch_delay_cnt;

   //Counter is reset when trigger low
   always @(posedge clk) begin
      if (async_trigger_inv == 1'b1) begin
         glitch_delay_cnt <= 0;
      end else begin
         if (glitch_delay_cnt != 32'hFFFFFFFF)
            glitch_delay_cnt <= glitch_delay_cnt + 1;
      end
   end 

   always @(posedge clk or posedge exttrig) begin
      if (exttrig == 1'b1)
         data_status <= 1'b0;
      else if (reset)
         data_status <= 1'b1;
      else if (glitch_delay_cnt >= offset)
         data_status <= 1'b1;
   end

   reg exttrigger_resync_reg;

   //always @(posedge clk)
   //  delayed <= ~data_status;

   always @(posedge clk)
      exttrigger_resync_reg <= (glitch_delay_cnt == offset) ? ~async_trigger_inv : 1'b0;

   assign exttrigger_resync = exttrigger_resync_reg;

endmodule
`default_nettype wire

