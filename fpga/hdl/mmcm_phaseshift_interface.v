`timescale 1ns / 1ps
`default_nettype none
/***********************************************************************
This file is part of the OpenADC Project. See www.newae.com for more details,
or the codebase at http://www.assembla.com/spaces/openadc .

This file is the 'phaseshift' interface. It interfaces with the delay module
(e.g.: DCM for Xilinx FPGAs) and provides a simple interface to adjust the
delay added in a line.

Copyright (c) 2012-2021, Colin O'Flynn <coflynn@newae.com>. All rights reserved.
This project (and file) is released under the 2-Clause BSD License:

Redistribution and use in source and binary forms, with or without 
modification, are permitted provided that the following conditions are met:

   * Redistributions of source code must retain the above copyright notice,
	  this list of conditions and the following disclaimer.
   * Redistributions in binary form must reproduce the above copyright
	  notice, this list of conditions and the following disclaimer in the
	  documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
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
    reg psdone_r;

    always @(posedge clk_usb) begin
       if (reset) begin
          state <= pS_RESET;          
       end 
       else begin
          psdone_r <= I_psdone;
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
                   ps_count <= ps_count + (-8'sd1);
                   state <= pS_WAIT;
                end 
                else if (I_step_index > ps_count) begin // increment
                   O_psincdec <= 1;
                   O_psen <= 1;
                   ps_count <= ps_count + 8'sd1;
                   state <= pS_WAIT;
                end else begin // no change / done
                   state <= pS_DONE;
                end
             end

             pS_WAIT: begin
                O_psen <= 0;
                if (psdone_r)
                   state <= pS_PULSE;
             end

             pS_DONE: begin
                O_done <= 1;
                state <= pS_IDLE;
             end

          endcase
       end
   end

endmodule
`default_nettype wire
