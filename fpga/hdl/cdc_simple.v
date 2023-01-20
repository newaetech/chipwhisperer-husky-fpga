`timescale 1ns / 1ps
`default_nettype none
/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more
details, or the codebase at http://www.chipwhisperer.com

Copyright (c) 2023, NewAE Technology Inc. All rights reserved.
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

  Instantiation template:

    cdc_simple U_cdc_simple (
        .reset          (reset),
        .clk            (CLK),
        .data_in        (data_in),
        .data_out       (data_out),
        .data_out_r     (data_out_r)
    );

*************************************************************************/

module cdc_simple #(
    parameter pPIPE_DEPTH = 2
) (
    input  wire         reset,
    input  wire         clk,
    input  wire         data_in,
    output reg          data_out,
    output reg          data_out_r
);

    (* ASYNC_REG = "TRUE" *) reg[pPIPE_DEPTH-1:0] pipe;

    always @(posedge clk) begin
        if (reset) begin
            pipe <= 0;
            data_out <= 0;
            data_out_r <= 0;
        end
        else
            {data_out_r, data_out, pipe} <= {data_out, pipe, data_in};
    end

endmodule
`default_nettype wire
