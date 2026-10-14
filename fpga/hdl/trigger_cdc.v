`timescale 1ns / 1ps
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

module trigger_cdc #(
    parameter pSYNC_STAGES = 5
)(
    input  wire src_clk,
    input  wire dst_clk,
    input  wire src_data,
    output wire dst_pulse
);

// Like cdc_pulse but for when the input is *not* a single-cycle pulse.
// Output is a pulse, with the same latency as you would get from cdc_pulse.
// This module is very specific to its use in reg_chipwhisperer.v and
// shouldn't be used elsewhere unless this is what you really mean to do.

reg src_data_r;
always @(posedge src_clk) src_data_r <= src_data;

(* ASYNC_REG = "TRUE" *) reg [pSYNC_STAGES-1:0] dst_pipe;
always @(posedge dst_clk) dst_pipe <= {dst_pipe[pSYNC_STAGES-2:0], src_data_r};

assign dst_pulse = dst_pipe[pSYNC_STAGES-2] && !dst_pipe[pSYNC_STAGES-1];

endmodule
`default_nettype wire

