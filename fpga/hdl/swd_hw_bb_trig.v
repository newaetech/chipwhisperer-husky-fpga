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

   input  wire                          adc_clk,
   input  wire                          target_hs1,
   inout  wire                          swdio,
   output wire                          swclk,
   output wire                          trigger_pulse,

   // for debug:
   output wire                          active_output,
   output reg                           matched,
   output reg                           matching,
   output wire                          active,
   output wire                          compare_en,
   output reg                           bitrecord

);

    localparam pCOUNTER_WIDTH = (pPATTERN_DEPTH <= 32)?  5 :
                                (pPATTERN_DEPTH <= 64)?  6 :
                                (pPATTERN_DEPTH <= 128)? 7 :
                                (pPATTERN_DEPTH <= 256)? 8 :
                                (pPATTERN_DEPTH <= 512)? 9 : 10;

    reg [pPATTERN_DEPTH-1:0] pattern_data;
    reg [pPATTERN_DEPTH-1:0] pattern_en = {pPATTERN_DEPTH{1'b1}};
    reg [pPATTERN_DEPTH-1:0] pattern_hiz = {pPATTERN_DEPTH{1'b0}};
    reg [pPATTERN_DEPTH-1:0] trigger_bits = {pPATTERN_DEPTH{1'b0}};
    reg [pPATTERN_DEPTH-1:0] record_en = {pPATTERN_DEPTH{1'b0}};
    reg go_usb;
    wire go_target;
    reg [pCOUNTER_WIDTH:0] bit_counter;
    reg continuous_clk = 1'b0;
    reg record_mode = 1'b0;
    reg trigger_when_matched = 1'b0;
    reg [1:0] swdio_inactive_state = 2'b01;
    reg clk_sel = 1'b0;
    reg trigger_en = 1'b0;
    reg clear_matched;
    reg [7:0] clk_div = 8'b0;
    reg [7:0] clock_counter = 8'd0;
    reg drive_output = 1'b0;
    reg drive_data;
    reg [pCOUNTER_WIDTH-1:0] num_bits = 0;
    reg [pCOUNTER_WIDTH-1:0] register_bit = 0;
    reg [pSAVE_DEPTH-1:0] saved_payload = 0;
    reg [pSAVE_DEPTH-1:0] data_sr;

    assign swdio = (drive_output)? drive_data : 1'bz;
    assign active_output = drive_output;

    wire target_clk;
    assign target_clk = adc_clk;
    assign active = running;
    assign compare_en = pattern_en[bit_counter];


    always @(*) begin
       if (reg_read) begin
          case (reg_address)
            `BB_TRIG_PATTERN_DATA:      reg_datao = pattern_data[reg_bytecnt*8 +: 8];
            `BB_TRIG_PATTERN_EN:        reg_datao = pattern_en[reg_bytecnt*8 +: 8];
            `BB_TRIG_PATTERN_HIZ:       reg_datao = pattern_hiz[reg_bytecnt*8 +: 8];
            `BB_TRIG_RECORD_EN:         reg_datao = record_en[reg_bytecnt*8 +: 8];
            `BB_TRIG_CTRL_STAT:         reg_datao = {6'b0, active, matched};
            `BB_REG_BIT:                reg_datao = saved_payload[reg_bytecnt*8 +: 8];
            `BB_TRIG_BITS:              reg_datao = trigger_bits[reg_bytecnt*8 +: 8];
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
            `BB_TRIG_RECORD_EN:         record_en[reg_bytecnt*8 +: 8] <= reg_datai;
            `BB_TRIG_BITS:              trigger_bits[reg_bytecnt*8 +: 8] <= reg_datai;
            `BB_NUM_BITS:               num_bits[reg_bytecnt*8 +: 8] <= reg_datai;
            `BB_REG_BIT:                register_bit[reg_bytecnt*8 +: 8] <= reg_datai;
            `BB_TRIG_CTRL2: begin
                if (reg_bytecnt == 0) begin
                    continuous_clk <= reg_datai[7];
                    swdio_inactive_state <= reg_datai[6:5];
                    record_mode <= reg_datai[4];
                    trigger_when_matched <= reg_datai[3];
                    //clk_sel <= reg_datai[4];
                end
                else if (reg_bytecnt == 1)
                    clk_div <= reg_datai[7:0];
            end
            `BB_TRIG_CTRL_STAT: begin
                trigger_en <= reg_datai[7];
                clear_matched <= reg_datai[6];
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
    reg swclk_pre = 1'b0;
    reg swclk_pre_r;
    reg trigger;
    reg trigger_r;

    assign trigger_pulse = trigger_en && trigger && ~trigger_r;
    assign swclk = (running || continuous_clk) && swclk_pre;

    // generate swclk:
    always @(posedge target_clk) begin
        swclk_pre_r <= swclk_pre;
        if (clock_counter == clk_div) begin
            clock_counter <= 0;
            swclk_pre <= ~swclk_pre;
        end
        else
            clock_counter <= clock_counter + 1;
    end

    // driving logic:
    always @(posedge target_clk) begin
        trigger_r <= trigger;
        if (go_target) begin
            running <= 1'b1;
            if (clear_matched)
                matched <= 1'b0;
            bit_counter <= 0;
            drive_data <= pattern_data[0];
            drive_output <= ~pattern_hiz[0];
            matching <= 1'b1;
            trigger <= 1'b0;
            saved_payload <= 0;
        end

        else if (running) begin
            bitrecord <= 1'b0;
            if (clock_counter == clk_div) begin
                if (swclk_pre) begin// drive data on falling edge
                    if (bit_counter == ( (num_bits > 0)? num_bits-1 : (pPATTERN_DEPTH-1)) ) begin
                        running <= 1'b0;
                        drive_data <= swdio_inactive_state[1];
                        drive_output <= swdio_inactive_state[0];
                        if (matching)
                            matched <= 1'b1;
                        else
                            matched <= 1'b0;
                    end
                    else begin
                        drive_data <= pattern_data[bit_counter+1];
                        drive_output <= ~pattern_hiz[bit_counter+1];
                        bit_counter <= bit_counter + 1;
                    end
                end

                else begin // check pattern match and fire trigger on rising edge
                    if (record_mode && record_en[bit_counter]) begin
                        saved_payload <= {saved_payload[pSAVE_DEPTH-2:0], swdio};
                        bitrecord <= 1'b1;
                    end
                    /* comment out for resource efficiency
                    else begin
                        data_sr <= {swdio, data_sr[31:1]};
                        if (bit_counter == register_bit)
                            saved_payload <= {swdio, data_sr[31:1]};
                    end
                    */

                    if ((swdio != pattern_data[bit_counter]) && pattern_en[bit_counter])
                        matching <= 1'b0;
                    if ((matching || ~trigger_when_matched) && trigger_bits[bit_counter])
                        trigger <= 1'b1;
                    else
                        trigger <= 1'b0;
                end
            end
        end

        else begin
            matching <= 1'b0;
            trigger <= 1'b0;
            drive_data <= swdio_inactive_state[1];
            drive_output <= swdio_inactive_state[0];
        end
    end


endmodule

`default_nettype wire
