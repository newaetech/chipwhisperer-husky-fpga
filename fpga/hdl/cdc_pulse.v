`default_nettype none
`timescale 1ns / 1ps
/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more
details, or the codebase at http://www.chipwhisperer.com

Copyright (c) 2019-2021, NewAE Technology Inc. All rights reserved.
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

module cdc_pulse #(
   parameter pSYNC_STAGES = 2
)(
   input  wire         reset_i,
   input  wire         src_clk,
   input  wire         src_pulse,
   input  wire         dst_clk,
   output reg          dst_pulse
);

   (* ASYNC_REG = "TRUE" *) reg  [pSYNC_STAGES-1:0] req_pipe;
   (* ASYNC_REG = "TRUE" *) reg  [pSYNC_STAGES-1:0] ack_pipe;
   reg  src_req = 1'b0;
   reg  dst_req = 1'b0;
   reg  dst_req_r = 1'b0;
   reg  src_ack = 1'b0;
   wire busy;

   always @(posedge src_clk) begin
      if (reset_i) begin
         src_ack <= 0;
         ack_pipe <= 0;
         src_req <= 0;
      end
      else begin
         {src_ack, ack_pipe} <= {ack_pipe, dst_req};
         if (~busy & src_pulse)
            src_req <= 1'b1;
         else if (src_ack)
            src_req <= 1'b0;
         end
   end

   assign busy = src_req | src_ack;

   always @(posedge dst_clk) begin
      if (reset_i) begin
         dst_req_r <= 0;
         dst_req <= 0;
         req_pipe <= 0;
         dst_pulse <= 0;
      end
      else begin
         {dst_req_r, dst_req, req_pipe} <= {dst_req, req_pipe, src_req};
         dst_pulse <= ~dst_req_r & dst_req;
      end
   end

endmodule

`default_nettype wire
