`timescale 1ns / 1ps
`default_nettype none
/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more
details, or the codebase at http://www.chipwhisperer.com

Copyright (c) 2012-2021, NewAE Technology Inc. All rights reserved.
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

module trigger_unit(
    input wire               reset,          //system reset

    input wire               adc_clk,        //ADC sample clock

    input wire               trigger,
    input wire               trigger_level_i,    //1 = trigger on high or rising edge
                                                 //0 = trigger on low or falling edge
    input wire               trigger_wait_i,     //1 = wait for trigger to go to 'inactive' state first (e.g.: edge sensitive)
                                                 //0 = don't wait
    input wire               trigger_now_i,      //1 = Trigger immediatly when armed
    input wire               arm_i,              //1 = arm, edge-sensitive so must be reset to 0 before arming again. Wait until the
                                                 //    arm_o goes high before doing this, otherwise the arm won't take effect.
    output reg               arm_o,              //Status of internal arm logic

    input wire [31:0]        trigger_offset_i,   //Delays the capture_go_o by this many ADC clock cycles
    output reg  [31:0]       trigger_length_o,   //Length of trigger pulse in ADC samples (only valid AFTER trigger happened)

    output reg               capture_active_o,     //1 = trigger conditions met, stays high until 'capture_done_i' goes high
    output reg               capture_go_o,         //pulses high for each segment capture start (even when segments aren't used)
    input wire               capture_done_i,       //1 = capture done
    input wire               armed_and_ready,

    input wire               cmd_arm_usb,          // for debug only
    output wire [8:0]        la_debug              // for debug only
    );

   //**** Trigger Logic *****
   reg armed;

   wire adc_capture_done;
   reg capture_go_start;

   assign adc_capture_done = capture_done_i;

   reg [31:0] adc_delay_cnt;

   wire trigger_now_r;
   wire trigger_now_r2;
   wire trigger_now;
   reg triggered;

   cdc_simple U_trigger_now_cdc (
       .reset          (reset),
       .clk            (adc_clk),
       .data_in        (trigger_now_i),
       .data_out       (trigger_now_r),
       .data_out_r     (trigger_now_r2)
   );

   assign trigger_now = trigger_now_r && ~trigger_now_r2;

   always @(posedge adc_clk) begin
       if (reset) begin
           adc_delay_cnt <= 0;
           capture_go_o <= 0;
       end
       else begin
           if (capture_go_start && (adc_delay_cnt == trigger_offset_i)) begin
               adc_delay_cnt <= 0;
               capture_go_o <= 1'b1;
           end
           else begin
               if (capture_go_o)
                   capture_go_o <= 1'b0;
               else if (capture_go_start)
                   adc_delay_cnt <= adc_delay_cnt + 1;
           end
       end
   end

   //ADC Trigger Stuff
   reg reset_arm;
   always @(posedge adc_clk) begin
      if (reset) begin
         reset_arm <= 0;
      end else begin
         if (((trigger == trigger_level_i) & armed) | trigger_now) begin
            reset_arm <= 1;
         end else if ((arm_i == 0) & (capture_active_o == 0)) begin
            reset_arm <= 0;
         end
      end
   end

   wire int_reset_capture;
   assign int_reset_capture = adc_capture_done | reset | (~arm_i);

   always @(posedge adc_clk) begin
      if (int_reset_capture) begin
         capture_active_o <= 1'b0;
         capture_go_start <= 1'b0;
         triggered <= 1'b0;
      end else begin
         if (((trigger == trigger_level_i) & armed) | trigger_now)
            capture_active_o <= 1;
         if ((((trigger == trigger_level_i) & (capture_active_o || armed)) | trigger_now) && !triggered)
            capture_go_start <= 1'b1;
         else if (capture_go_o)
            capture_go_start <= 1'b0;
      end

      // this could be simpler if we used a 0>1 transition detect on trigger above, but given that
      // the trigger input could be asynchronous, and we don't want to add delay to it, this seemed
      // like the best solution
      if (capture_go_start)
          triggered <= 1'b1;
      else if (trigger != trigger_level_i)
          triggered <= 1'b0;
   end

   wire resetarm;
   assign resetarm = reset | reset_arm;

   //'armed' goes high when arm command present & conditions met during rising clock edge
   always @(posedge adc_clk)
      if (resetarm) begin
         armed <= 0;
      end else if (armed_and_ready & ((trigger != trigger_level_i) | (trigger_wait_i == 0))) begin
         armed <= 1;
      end

   //'arm_o' goes high when arm command present (doesn't look at other conditions)
   always @(posedge adc_clk)
      if (resetarm) begin
         arm_o <= 0;
      end else if (arm_i) begin
         arm_o <= 1;
      end

   /** Trigger Length Detection - does not account for multiple togglings**/
   reg arm_i_dly;

   always @(posedge adc_clk)
      arm_i_dly <= arm_i;

   always @(posedge adc_clk) begin
      // don't count in the case of adc_trigger: it makes timing more difficult, it's not
      // likely useful, and it could be calculated by the host
      if (trigger == trigger_level_i)
         trigger_length_o <= trigger_length_o + 32'd1;
      else if (arm_i & ~arm_i_dly)
         trigger_length_o <= 0;
   end

   assign la_debug = { adc_capture_done,
                       armed_and_ready,
                       arm_o,  
                       int_reset_capture,
                       capture_done_i, 
                       capture_active_o,
                       armed,
                       trigger,
                       cmd_arm_usb };


   `ifdef ILA_TRIG
       ila_trig U_ila_trig (
          .clk            (adc_clk),              // input wire clk
          .probe0         (adc_capture_done),     // input wire [0:0]  probe0  
          .probe1         (capture_active_o),     // input wire [0:0]  probe1 
          .probe2         (trigger_now),          // input wire [0:0]  probe2 
          .probe3         (trigger),              // input wire [0:0]  probe3 
          .probe4         (arm_i),                // input wire [0:0]  probe4 
          .probe5         (armed),                // input wire [0:0]  probe5 
          .probe6         (int_reset_capture),    // input wire [0:0]  probe6 
          .probe7         (arm_i),                // input wire [0:0]  probe7 
          .probe8         (capture_go_start),     // input wire [0:0]  probe8 
          .probe9         (capture_go_o),         // input wire [0:0]  probe9 
          .probe10        (1'b0)                  // input wire [0:0]  probe10
       );
   `endif


endmodule
`default_nettype wire
