`include "includes.v"
`timescale 1 ns / 1 ps
`default_nettype none

/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more
details, or the codebase at http://www.chipwhisperer.com

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

module trigger_pulse_cdc #(
    parameter pWIDTH = 1
)(
    input  wire                 reset_i,
    input  wire                 src_clk,
    input  wire                 dst_clk,
    input  wire [pWIDTH-1:0]    trigger_src,
    output wire [pWIDTH-1:0]    trigger_dst
);

genvar i;
generate
    for (i = 0; i < pWIDTH; i = i + 1) begin: gen_cdc_pulse
        cdc_pulse U_cdc_pulse (
           .reset_i       (reset_i),
           .src_clk       (src_clk),
           .src_pulse     (trigger_src[i]),
           .dst_clk       (dst_clk),
           .dst_pulse     (trigger_dst[i])
        );
    end
endgenerate


endmodule
`default_nettype wire
