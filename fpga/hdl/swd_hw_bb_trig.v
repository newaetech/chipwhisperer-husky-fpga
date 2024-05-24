`include "includes.v"
`default_nettype none
`timescale 1ns / 1ps

/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more details,
or the codebase at https://github.com/newaetech/chipwhisperer .

Copyright (c) 2024, NewAE Technology Inc. All rights reserved.
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

module swd_hw_bb_trig #(
   parameter pBYTECNT_SIZE = 7,
   parameter pPATTERN_DEPTH = 256
)(
   input  wire                          reset,
   input  wire                          clk_usb,
   input  wire [7:0]                    reg_address,
   input  wire [pBYTECNT_SIZE-1:0]      reg_bytecnt,
   input  wire [7:0]                    reg_datai,
   output reg  [7:0]                    reg_datao,
   input  wire                          reg_read,
   input  wire                          reg_write,

   input  wire                          pll_fpga_clk,
   input  wire                          target_hs1,
   inout  wire                          swdio,
   output wire                          swclk,
   output wire                          trigger_pulse,

   // for debug:
   output wire                          active_output,
   output reg                           matched,
   output reg                           matching

);

    localparam pCOUNTER_WIDTH = (pPATTERN_DEPTH <= 32)?  5 :
                                (pPATTERN_DEPTH <= 64)?  6 :
                                (pPATTERN_DEPTH <= 128)? 7 :
                                (pPATTERN_DEPTH <= 256)? 8 :
                                (pPATTERN_DEPTH <= 512)? 9 : 10;

    reg [pPATTERN_DEPTH-1:0] pattern_data;
    reg [pPATTERN_DEPTH-1:0] pattern_en = {pPATTERN_DEPTH{1'b1}};
    reg [pPATTERN_DEPTH-1:0] pattern_hiz = {pPATTERN_DEPTH{1'b0}};
    reg [pPATTERN_DEPTH-1:0] clk_en = {pPATTERN_DEPTH{1'b1}};
    reg go_usb;
    wire go_target;
    reg [pCOUNTER_WIDTH:0] bit_counter;
    reg clk_sel = 1'b0;
    reg trigger_en = 1'b0;
    reg [3:0] clk_div = 4'd4;
    reg [3:0] clock_counter;
    reg drive_output = 1'b0;
    reg drive_data;
    reg [pCOUNTER_WIDTH-1:0] trigger_bit = 0;
    reg [pCOUNTER_WIDTH-1:0] num_bits = 0;

    assign swdio = (drive_output)? drive_data : 1'bz;
    assign active_output = drive_output;

    wire target_clk;
`ifdef __ICARUS__
    assign target_clk = (clk_sel)? target_hs1 : pll_fpga_clk;
`else
    BUFGMUX #(
       .CLK_SEL_TYPE("ASYNC")
    ) U_target_clk_mux (
       .O    (target_clk),
       .I0   (pll_fpga_clk),
       .I1   (target_hs1),
       .S    (clk_sel)
    );
`endif


    always @(*) begin
       if (reg_read) begin
          case (reg_address)
            `BB_TRIG_PATTERN_DATA:      reg_datao = pattern_data[reg_bytecnt*8 +: 8];
            `BB_TRIG_PATTERN_EN:        reg_datao = pattern_en[reg_bytecnt*8 +: 8];
            `BB_TRIG_PATTERN_HIZ:       reg_datao = pattern_hiz[reg_bytecnt*8 +: 8];
            `BB_TRIG_CLK_EN:            reg_datao = clk_en[reg_bytecnt*8 +: 8];
            `BB_TRIG_CTRL_STAT:         reg_datao = {7'b0, matched};
            default: reg_datao = 0;
          endcase
       end
       else
          reg_datao = 0;
    end


    always @(posedge clk_usb) begin
       if (reg_write) begin
          case (reg_address)
            `BB_TRIG_PATTERN_DATA:      pattern_data[reg_bytecnt*8 +: 8] <= reg_datai;
            `BB_TRIG_PATTERN_EN:        pattern_en[reg_bytecnt*8 +: 8] <= reg_datai;
            `BB_TRIG_PATTERN_HIZ:       pattern_hiz[reg_bytecnt*8 +: 8] <= reg_datai;
            `BB_TRIG_CLK_EN:            clk_en[reg_bytecnt*8 +: 8] <= reg_datai;
            `BB_TRIG_BIT:               trigger_bit[reg_bytecnt*8 +: 8] <= reg_datai;
            `BB_NUM_BITS:               num_bits[reg_bytecnt*8 +: 8] <= reg_datai;
            `BB_TRIG_CTRL_STAT: begin
                trigger_en <= reg_datai[6];
                clk_sel <= reg_datai[4];
                clk_div <= reg_datai[3:0];
            end
            default: ;
          endcase
       end
       if (go_usb)
           go_usb <= 1'b0;
       else if (reg_write && (reg_address == `BB_TRIG_CTRL_STAT))
           go_usb <= 1'b1;
    end

    cdc_pulse U_go_cdc (
        .reset_i       (reset),
        .src_clk       (clk_usb),
        .dst_clk       (target_clk),
        .src_pulse     (go_usb),
        .dst_pulse     (go_target)
    );

    reg running = 1'b0;
    reg swclk_pre, swclk_pre_r;
    reg matched_r;

    assign trigger_pulse = trigger_en && matched && ~matched_r;
    assign swclk = running && swclk_pre && clk_en[bit_counter];

    // driving logic:
    always @(posedge target_clk) begin
        swclk_pre_r <= swclk_pre;
        matched_r <= matched;
        if (go_target) begin
            running <= 1'b1;
            matched <= 1'b0;
            bit_counter <= 0;
            clock_counter <= 0;
            swclk_pre <= 1'b0;
            drive_data <= pattern_data[0];
            drive_output <= ~pattern_hiz[0];
            matching <= 1'b1;
            matched <= 1'b0;
        end

        else if (running) begin
            if (clock_counter == clk_div) begin
                clock_counter <= 0;
                swclk_pre <= ~swclk_pre;
                if (swclk_pre) begin// drive data on falling edge
                    drive_data <= pattern_data[bit_counter+1];
                    drive_output <= ~pattern_hiz[bit_counter+1];
                    bit_counter <= bit_counter + 1;
                end
                else begin // rising edge
                    if (bit_counter == ( (num_bits > 0)? num_bits : (pPATTERN_DEPTH-1)) ) begin
                        running <= 1'b0;
                        drive_output <= 1'b0;
                    end
                end
            end
            else
                clock_counter <= clock_counter + 1;

            // check pattern match; fire trigger
            if (~swclk_pre && ~swclk_pre_r) begin // TODO- specific to clk_div=4... advancing sampling edge...
                                          // do this more properly...
                if ((swdio != pattern_data[bit_counter]) && pattern_en[bit_counter])
                    matching <= 1'b0;
                else if (matching && (bit_counter == trigger_bit) && (trigger_bit > 0))
                    matched <= 1'b1;
            end
        end

        else begin
            matching <= 1'b0;
        end
    end




endmodule

`default_nettype wire
