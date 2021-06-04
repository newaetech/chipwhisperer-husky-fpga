`include "includes.v"
`timescale 1 ns / 1 ps
`default_nettype none

/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more
details, or the codebase at http://www.chipwhisperer.com

Copyright (c) 2021, NewAE Technology Inc. All rights reserved.
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

/* Convert short pulses into longer pulses, so that it can be observed on slow
   logic analyzers
*/

module slow_debug(  
    input wire         clk,
    input wire         I_fast,
    output reg         O_slow
);

   reg fast_r = 1'b0;
   reg [3:0] count;
   
   always @ (posedge clk) begin
      fast_r <= I_fast;
      if (I_fast & ~fast_r) begin
         count <= 0;
         O_slow <= 1;
      end
      else if (count < 15)
         count <= count + 1;
      else if (~I_fast)
         O_slow <= 0;
   end

endmodule
`default_nettype wire
