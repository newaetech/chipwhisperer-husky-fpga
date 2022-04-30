`timescale 1ns / 1ps
`default_nettype none

/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more
details, or the codebase at http://www.chipwhisperer.com

Copyright (c) 2014-2022, NewAE Technology Inc. All rights reserved.
Author: Colin O'Flynn <coflynn@newae.com>, Jean-Pierre Thibault <jpthibault@newae.com>

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


module trigger_resync #(
   parameter pMAX_GLITCHES = 32,
   parameter pNUM_GLITCH_WIDTH = 5,
   parameter pSYNC_STAGES = 2
)(
   input  wire                          reset,
   input  wire                          clk,    // clkgen or HS1
   input  wire                          exttrig,
   input  wire [31:0]                   offset,
   input  wire [pNUM_GLITCH_WIDTH-1:0]  num_glitches,
   output reg                           exttrigger_resync,
   output reg                           done,
   output reg [pNUM_GLITCH_WIDTH-1:0]   index,
   output reg [pNUM_GLITCH_WIDTH-1:0]   glitch_done_count,
   input  wire                          glitch_go, // caution: synchronous to negedge of MMCM1 clock
   output wire                          idle
);

   reg async_trigger = 1'b0;
   reg [31:0] glitch_delay_cnt;

   (* ASYNC_REG = "TRUE" *) reg  [pSYNC_STAGES-1:0] glitch_go_pipe;
   reg glitch_go_sync;
   reg glitch_go_sync_r;

   localparam pS_IDLE = 0;
   localparam pS_WAIT = 1;
   localparam pS_NEXT = 2;
   localparam pS_DONE = 3;
   reg [1:0] state = pS_IDLE;

   wire glitch_condition = (glitch_delay_cnt == offset);

   assign idle = (state == pS_IDLE);

   `ifdef ASYNC_TRIGGER
       // This must be coded just so, otherwise Vivado will throw a "Synth 8-91
       // ambiguous clock" error. Or maybe we could get rid of the posedge exttrig
       // argument...
       always @(posedge clk or posedge exttrig) begin
   `else
       always @(posedge clk) begin
          if (exttrig == 1'b1)
             async_trigger <= 1'b1;
          else if (done)
             async_trigger <= 1'b0;
       end
   `endif


   // Count glitch_go's, to know when we're done:
   // (Waiting to see a glitch_go when in DONE state doesn't work, because if
   // the last two glitches are close together, we'll see the second-last
   // glitch in DONE and exit too early. All this matters because we have to
   // maintain a valid index for clockglitch_a7 and we can't reset it too
   // soon.)
   always @(posedge clk) begin
       {glitch_go_sync_r, glitch_go_sync, glitch_go_pipe} <= {glitch_go_sync, glitch_go_pipe, glitch_go};
       if (state == pS_IDLE)
           glitch_done_count <= 0;
       else if (glitch_go_sync_r & ~glitch_go_sync)
           glitch_done_count <= glitch_done_count + 1;
   end


   always @(posedge clk) begin
       if (state == pS_WAIT)
           glitch_delay_cnt <= glitch_delay_cnt + 1;
       else
           glitch_delay_cnt <= 0;

      if ((state == pS_WAIT) && glitch_condition)
         exttrigger_resync <= 1'b1;
      else
         exttrigger_resync <= 1'b0;
   end


   always @(posedge clk) begin
       if (reset) begin
           state <= pS_IDLE;
           done <= 1'b0;
           index <= 0;
       end
       else begin
           case (state)

               pS_IDLE: begin
                   index <= 0;
                   done <= 1'b0;
                   if (async_trigger && (num_glitches != 0) && ~done) begin
                       state <= pS_WAIT;
                   end
               end

               pS_WAIT: begin
                   //if (exttrigger_resync) begin
                   if (glitch_condition) begin
                       if (index < num_glitches-1)
                           state <= pS_NEXT;
                       else begin
                           state <= pS_DONE;
                           index <= index + 1;
                       end
                   end
               end

               pS_NEXT: begin
                   index <= index + 1;
                   state <= pS_WAIT;
               end

               pS_DONE: begin
                   if (~exttrig && (glitch_done_count == num_glitches)) begin
                       state <= pS_IDLE;
                       done <= 1'b1;
                   end
               end


           endcase
       end
   end


endmodule
`default_nettype wire

