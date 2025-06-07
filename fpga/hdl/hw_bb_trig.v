`include "includes.v"
`default_nettype none
`timescale 1ns / 1ps

/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more details,
or the codebase at https://github.com/newaetech/chipwhisperer .

Copyright (c) 2024-2025, NewAE Technology Inc. All rights reserved.
Author: Jean-Pierre Thibault <jpthibault@newae.com>
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

module hw_bb_trig #(
   parameter pBYTECNT_SIZE = 7,
   parameter pPATTERN_DEPTH = 256,
   parameter pSAVE_DEPTH = 64
)(
   input  wire                          reset,
   input  wire                          clk_usb,
   input  wire [7:0]                    reg_address,
   input  wire [pBYTECNT_SIZE-1:0]      reg_bytecnt,
   input  wire [7:0]                    reg_datai,
   output reg  [7:0]                    reg_datao,
   input  wire                          reg_read,
   input  wire                          reg_write,

   input  wire                          clock,
   input  wire                          data_in,
   output wire                          data_out,
   output wire                          data_drive,
   output wire                          clock_out,
   output wire                          trigger_pulse,

   input  wire                          glitch_in,

   output wire [7:0]                    debug
);

    localparam pCOUNTER_WIDTH = (pPATTERN_DEPTH <= 32)?  5 :
                                (pPATTERN_DEPTH <= 64)?  6 :
                                (pPATTERN_DEPTH <= 128)? 7 :
                                (pPATTERN_DEPTH <= 256)? 8 :
                                (pPATTERN_DEPTH <= 512)? 9 : 10;

    reg matched;
    reg matching;
    reg bitrecord = 1'b0; // for debug only
    reg [pPATTERN_DEPTH-1:0] pattern_data;
    reg [pPATTERN_DEPTH-1:0] pattern_en = {pPATTERN_DEPTH{1'b1}};
    reg [pPATTERN_DEPTH-1:0] pattern_hiz = {pPATTERN_DEPTH{1'b0}};
    reg [pPATTERN_DEPTH-1:0] clk_en = {pPATTERN_DEPTH{1'b1}};
    reg [pPATTERN_DEPTH-1:0] trigger_bits = {pPATTERN_DEPTH{1'b0}};
    reg [pPATTERN_DEPTH-1:0] record_en = {pPATTERN_DEPTH{1'b0}};
    reg go_usb = 1'b0;
    wire go_target_pulse;
    reg [pCOUNTER_WIDTH:0] bit_counter_drive;
    reg [pCOUNTER_WIDTH:0] bit_counter_check;
    reg continuous_clk = 1'b0;
    reg trigger_when_matched = 1'b0;
    reg [1:0] data_io_inactive_state = 2'b01;
    reg trigger_en = 1'b0;
    reg clear_matched;
    reg [7:0] clk_div = 8'b0;
    reg [7:0] clock_counter = 8'd0;
    reg drive_output = 1'b0;
    reg clock_enabled = 1'b0;
    reg drive_data;
    reg [15:0] num_bits = 0; // max-sized because of where it sits in the register space
    reg [pSAVE_DEPTH-1:0] saved_payload = 0;
    reg [pSAVE_DEPTH-1:0] data_sr;

    wire glitch_it = glitch_in && enable_glitch_output;
    assign data_out = (glitch_it)? 1'b0 : drive_data;
    assign data_drive = (glitch_it)? 1'b1 : drive_output;

    wire active_output = drive_output || (glitch_it && glitch_in);

    wire active = running;

    reg enable_glitch_output = 1'b0;
    reg drive_edge = 1'b1; //0/1: drive data on falling/rising edge of clock_out_pre
    reg check_edge = 1'b1; //0/1: check data and fire trigger on falling/rising edge of clock_out_pre

    reg [3:0] data_reg_select;

    always @(*) begin
       if (reg_read) begin
          case (reg_address)
              `BB_TRIG_DATA: begin
                  case (data_reg_select)
                      `BB_TRIG_PATTERN_DATA:    reg_datao = pattern_data[reg_bytecnt*8 +: 8];
                      `BB_TRIG_PATTERN_EN:      reg_datao = pattern_en[reg_bytecnt*8 +: 8];
                      `BB_TRIG_PATTERN_HIZ:     reg_datao = pattern_hiz[reg_bytecnt*8 +: 8];
                      `BB_TRIG_RECORD_EN:       reg_datao = record_en[reg_bytecnt*8 +: 8];
                      `BB_TRIG_BITS:            reg_datao = trigger_bits[reg_bytecnt*8 +: 8];
                      `BB_TRIG_CLK_EN:          reg_datao = clk_en[reg_bytecnt*8 +: 8];
                      `BB_TRIG_SAVED_DATA:      reg_datao = saved_payload[reg_bytecnt*8 +: 8];
                  endcase
              end
              `BB_TRIG_CTRL_STAT: begin
                  case (reg_bytecnt)
                      0: reg_datao = {6'b0, enable_glitch_output, active, matched};
                      1: reg_datao = pPATTERN_DEPTH & 8'hFF;
                      2: reg_datao = pPATTERN_DEPTH >> 8;
                  endcase
              end
              default: reg_datao = 0;
          endcase
       end
       else
          reg_datao = 0;
    end


    always @(posedge clk_usb) begin
       if (reg_write) begin
          case (reg_address)
              `BB_TRIG_REG_SELECT: data_reg_select      <= reg_datai;
              `BB_TRIG_DATA: begin
                  case (data_reg_select)
                      `BB_TRIG_PATTERN_DATA: pattern_data[reg_bytecnt*8 +: 8]   <= reg_datai;
                      `BB_TRIG_PATTERN_EN:   pattern_en[reg_bytecnt*8 +: 8]     <= reg_datai;
                      `BB_TRIG_PATTERN_HIZ:  pattern_hiz[reg_bytecnt*8 +: 8]    <= reg_datai;
                      `BB_TRIG_RECORD_EN:    record_en[reg_bytecnt*8 +: 8]      <= reg_datai;
                      `BB_TRIG_BITS:         trigger_bits[reg_bytecnt*8 +: 8]   <= reg_datai;
                      `BB_TRIG_CLK_EN:       clk_en[reg_bytecnt*8 +: 8]         <= reg_datai;
                  endcase
              end
              `BB_TRIG_CTRL_STAT: begin
                  case (reg_bytecnt)
                      0: begin
                          trigger_en                    <= reg_datai[7];
                          clear_matched                 <= reg_datai[6];
                      end
                      1: begin
                          continuous_clk                <= reg_datai[7];
                          data_io_inactive_state        <= reg_datai[6:5];
                          trigger_when_matched          <= reg_datai[3];
                          enable_glitch_output          <= reg_datai[2];
                          drive_edge                    <= reg_datai[1];
                          check_edge                    <= reg_datai[0];
                      end
                      2: clk_div                        <= reg_datai[7:0];
                      3: num_bits[0 +: 8]               <= reg_datai;
                      4: num_bits[8 +: 8]               <= reg_datai;
                      default: ;
                  endcase
              end
              default: ;
          endcase
       end
       if (go_usb)
           go_usb <= 1'b0;
       else if (reg_write && (reg_address == `BB_TRIG_CTRL_STAT) && (reg_bytecnt == 5))
           go_usb <= 1'b1;
    end

    cdc_pulse U_go_cdc (
        .reset_i       (reset),
        .src_clk       (clk_usb),
        .dst_clk       (clock),
        .src_pulse     (go_usb),
        .dst_pulse     (go_target_pulse)
    );

    reg running = 1'b0;
    reg go_wait_sync = 1'b0;
    reg clock_out_pre = 1'b0;
    reg trigger;
    reg trigger_r;

    assign trigger_pulse = trigger_en && trigger && ~trigger_r;
    assign clock_out = ((running && clock_enabled) || continuous_clk) && clock_out_pre;

    // generate clock_out:
    always @(posedge clock) begin
        // note that clk_div is the number of input clock cycles per *half period* of
        // the generated clock; in other words, clk_div is twice the actual clock divisor:
        if (clock_counter == clk_div) begin
            clock_counter <= 0;
            clock_out_pre <= ~clock_out_pre;
        end
        else
            clock_counter <= clock_counter + 1;
    end

    // driving logic:
    always @(posedge clock) begin
        trigger_r <= trigger;
        // synchronize "go" to our running clock output:
        if (go_wait_sync && (clock_counter == (clk_div-1)) && (clock_out_pre != drive_edge)) begin
            go_wait_sync <= 1'b0;
            running <= 1'b1;
            trigger <= 1'b0;
            matching <= 1'b1;
            bit_counter_drive <= 0;
            bit_counter_check <= 0;
            //bit_counter <= {(pCOUNTER_WIDTH+1){1'b1}};
            //drive_data <= pattern_data[0];
            //drive_output <= ~pattern_hiz[0];
            clock_enabled <= clk_en[0];
        end
        else if (go_target_pulse) begin
            go_wait_sync <= 1'b1;
            saved_payload <= 0;
            if (clear_matched)
                matched <= 1'b0;
        end

        else if (running) begin
            bitrecord <= 1'b0;
            trigger <= 1'b0;
            if (clock_counter == clk_div) begin
                // drive data on falling or rising edge:
                if (clock_out_pre != drive_edge) begin 
                    if (bit_counter_drive == ( (num_bits > 0)? num_bits : pPATTERN_DEPTH) ) begin
                        running <= 1'b0;
                        drive_data <= data_io_inactive_state[1];
                        drive_output <= data_io_inactive_state[0];
                        if (matching)
                            matched <= 1'b1;
                        else
                            matched <= 1'b0;
                    end
                    else begin
                        drive_data <= pattern_data[bit_counter_drive];
                        drive_output <= ~pattern_hiz[bit_counter_drive];
                        clock_enabled <= clk_en[bit_counter_drive];
                        bit_counter_drive <= bit_counter_drive + 1;
                    end
                end

                // check pattern match and fire trigger on falling or rising edge:
                if (clock_out_pre != check_edge) begin 
                    bit_counter_check <= bit_counter_check + 1;
                    if (record_en[bit_counter_check]) begin
                        saved_payload <= {saved_payload[pSAVE_DEPTH-2:0], data_in};
                        bitrecord <= 1'b1;
                    end

                    if ((data_in != pattern_data[bit_counter_check]) && pattern_en[bit_counter_check])
                        matching <= 1'b0;
                    if ((matching || ~trigger_when_matched) && trigger_bits[bit_counter_check])
                        trigger <= 1'b1;
                    else
                        trigger <= 1'b0;
                end
            end
        end

        else begin
            matching <= 1'b0;
            trigger <= 1'b0;
            bitrecord <= 1'b0;
            drive_data <= data_io_inactive_state[1];
            drive_output <= data_io_inactive_state[0];
        end
    end

    /*
    assign debug = {active_output,
                    active,
                    data_drive,
                    data_out,
                    bitrecord,
                    glitch_it,
                    drive_output,
                    drive_data
                   };
    */

    assign debug = {active_output,
                    active,
                    data_drive,
                    pattern_en[bit_counter_check],
                    trigger,
                    bitrecord,
                    matched,
                    matching
                   };


endmodule

`default_nettype wire
