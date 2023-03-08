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
   input  wire                          fsm_reset,
   input  wire                          clk_usb, // for debug only
   input  wire                          glitch_mmcm1_clk_out,
   input  wire                          ext_single_mode,
   input  wire                          oneshot,
   input  wire                          exttrig,
   input  wire [31:0]                   offset,
   input  wire [pNUM_GLITCH_WIDTH-1:0]  num_glitches,
   output reg                           exttrigger_resync,
   output reg                           done,
   output reg  [pNUM_GLITCH_WIDTH-1:0]  index,
   output reg  [pNUM_GLITCH_WIDTH:0]    glitch_done_count,
   input  wire                          glitch_go, // caution: synchronous to negedge of MMCM1 clock
   input  wire                          easy_done_exit,
   output wire                          idle,
   output wire [1:0]                    fsm_state,
   output wire [7:0]                    debug
);

   reg async_trigger = 1'b0;
   reg exttrig_r;
   reg [31:0] offset_r;
   reg [31:0] glitch_delay_cnt;
   reg glitch_go_r;

   localparam pS_IDLE = 0;
   localparam pS_WAIT = 1;
   localparam pS_NEXT = 2;
   localparam pS_DONE = 3;
   reg [1:0] state = pS_IDLE;
   assign fsm_state = state;

   wire glitch_condition = (glitch_delay_cnt == offset_r);

   assign idle = (state == pS_IDLE);

   assign debug = {glitch_condition,    // 7
                   oneshot,             // 6
                   done,                // 5
                   state,               // 4:3
                   async_trigger,       // 2
                   exttrigger_resync,   // 1
                   exttrig};            // 0

   // See note in clockglitch_a7.v explaining why negedges are used!

   `ifdef ASYNC_TRIGGER
       // This must be coded just so, otherwise Vivado will throw a "Synth 8-91
       // ambiguous clock" error. Or maybe we could get rid of the posedge exttrig
       // argument...
       // NOTE: ASYNC_TRIGGER option is untested!
       // Here be dragons... (async_trigger isn't synchronous to the logic
       // which uses it downstream)
       always @(negedge glitch_mmcm1_clk_out or posedge exttrig) begin
          exttrig_r <= exttrig;
          offset_r <= offset;
          // important: don't start FSM if glitches aren't going to be generated (otherwise it'll get stuck in DONE)
          if ((exttrig == 1'b1) && (ext_single_mode? oneshot : 1'b1))
             async_trigger <= 1'b1;
          else if (done)
             async_trigger <= 1'b0;
       end

   `else
       always @(negedge glitch_mmcm1_clk_out) begin
          exttrig_r <= exttrig;
          offset_r <= offset;
          // important: don't start FSM if glitches aren't going to be generated (otherwise it'll get stuck in DONE)
          if ((exttrig == 1'b1) && (ext_single_mode? oneshot : 1'b1))
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
   always @(negedge glitch_mmcm1_clk_out) begin
       glitch_go_r <= glitch_go;
       if (idle)
           glitch_done_count <= 0;
       else if (glitch_go_r  & ~glitch_go)
           glitch_done_count <= glitch_done_count + 1;
   end



   always @(negedge glitch_mmcm1_clk_out) begin
       if (state == pS_WAIT)
           glitch_delay_cnt <= glitch_delay_cnt + 1;
       else
           glitch_delay_cnt <= 0;

      if ((state == pS_WAIT) && glitch_condition)
         exttrigger_resync <= 1'b1;
      else
         exttrigger_resync <= 1'b0;
   end


   always @(negedge glitch_mmcm1_clk_out) begin
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
                   if (async_trigger && ~done) begin
                       state <= pS_WAIT;
                   end
               end

               pS_WAIT: begin
                   if (glitch_condition) begin
                       if (index < num_glitches) begin
                           index <= index + 1;
                           state <= pS_NEXT;
                       end
                       else begin
                           state <= pS_DONE;
                           index <= index + 1;
                       end
                   end
               end

               pS_NEXT: begin
                   state <= pS_WAIT;
               end

               pS_DONE: begin
                   if ((~exttrig_r && ((glitch_done_count == (num_glitches+1)) || (easy_done_exit && (num_glitches == 0)))) || fsm_reset) begin
                       state <= pS_IDLE;
                       done <= 1'b1;
                   end
               end


           endcase
       end
   end

`ifdef ILA_TRIGGER_RESYNC
    ila_trigger_resync U_ila_trigger_resync (
       .clk            (clk_usb),              // input wire clk
       .probe0         (state),                // input wire [1:0]  probe0 
       .probe1         (async_trigger),        // input wire [0:0]  probe1 
       .probe2         (exttrig),              // input wire [0:0]  probe2 
       .probe3         (done),                 // input wire [0:0]  probe3 
       .probe4         (glitch_condition),     // input wire [0:0]  probe4 
       .probe5         (glitch_done),          // input wire [4:0]  probe5 
       .probe6         (exttrigger_resync),    // input wire [0:0]  probe6 
       .probe7         (glitch_delay_cnt),     // input wire [31:0] probe7 
       .probe8         (num_glitches),         // input wire [4:0]  probe8 
       .probe9         (offset_r)              // input wire [31:0] probe9 
    );
`endif


endmodule
`default_nettype wire

