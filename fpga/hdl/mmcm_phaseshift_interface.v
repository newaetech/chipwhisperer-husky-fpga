`timescale 1ns / 1ps
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

module mmcm_phaseshift_interface(
    input  wire                 clk_usb,            //Clock for inputs & PCLK for DCM
    input  wire                 reset,              //Reset - must also connect to DCM so this block knows when defaults are loaded
    input  wire signed [15:0]   I_step_index,       //Requested PS step index in 2's complement format
    input  wire                 I_load,             //When high starts a new phase shift operation    
    output reg                  O_done,             //High for one clock cycle once operation complete
    output reg                  O_psen,             //Connect to DCM
    output reg                  O_psincdec,         //Connect to DCM
    input  wire                 I_psdone            //Connect to DCM
);

    localparam pS_RESET = 3'd0;
    localparam pS_IDLE  = 3'd1;
    localparam pS_PULSE = 3'd2;
    localparam pS_WAIT  = 3'd3;
    localparam pS_DONE  = 3'd4;

    reg [2:0] state;
    reg signed [15:0] ps_count;

    always @(posedge clk_usb) begin
       if (reset) begin
          state <= pS_RESET;          
       end 
       else begin
          case (state)

             pS_RESET: begin
                O_done <= 0;
                O_psen <= 0;
                O_psincdec <= 0;
                state <= pS_IDLE;
                ps_count <= 0;
             end

             pS_IDLE: begin
                O_psen <= 0;
                O_psincdec <= 0;
                O_done <= 0;
                if (I_load)
                   state <= pS_PULSE;
             end

             pS_PULSE: begin
                if (I_step_index < ps_count) begin // decrement
                   O_psincdec <= 0;
                   O_psen <= 1;
                   ps_count <= ps_count + (-15'sd1);
                   state <= pS_WAIT;
                end 
                else if (I_step_index > ps_count) begin // increment
                   O_psincdec <= 1;
                   O_psen <= 1;
                   ps_count <= ps_count + 15'sd1;
                   state <= pS_WAIT;
                end else begin // no change / done
                   state <= pS_DONE;
                end
             end

             pS_WAIT: begin
                O_psen <= 0;
                if (I_psdone)
                   state <= pS_PULSE;
             end

             pS_DONE: begin
                O_done <= 1;
                state <= pS_IDLE;
             end

             default: state <= pS_RESET;

          endcase
       end
   end

endmodule
`default_nettype wire
