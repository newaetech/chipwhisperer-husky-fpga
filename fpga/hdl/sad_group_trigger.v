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

  A simple module -- the only way I could figure out figure out how to
  do multi-dimensional code generation.

*************************************************************************/

module sad_group_trigger #(
    parameter pGROUP_SIZE = 8
)(
    input wire                          clock,
    input wire [pGROUP_SIZE-1:0]        trigger_inputs,
    output reg                          trigger_output
);

    always @(posedge clock) begin
        trigger_output <= |trigger_inputs;
    end

endmodule

`default_nettype wire
