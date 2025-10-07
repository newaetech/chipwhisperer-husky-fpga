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

   input  wire                          trigger_active,
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
    reg bitrecord = 1'b0;
    reg match_check = 1'b0;
    reg go_usb = 1'b0;
    wire go_target_pulse;
    reg [pCOUNTER_WIDTH:0] bit_counter_drive;
    reg [pCOUNTER_WIDTH:0] bit_counter_check;
    reg continuous_clk = 1'b0;
    reg trigger_when_matched = 1'b0;
    reg [1:0] data_io_inactive_state = 2'b01;
    reg trigger_en = 1'b0;
    reg [1:0] glitch_mode = 2'b00;
    reg [6:0] clk_div = 7'd1;
    reg [7:0] clock_counter = 8'd0;
    reg drive_output = 1'b0;
    reg drive_data;
    reg [15:0] num_bits = 0; // max-sized because of where it sits in the register space
    reg [pSAVE_DEPTH-1:0] saved_payload = 0;

    wire glitch_it = glitch_in && enable_glitch_output;
    wire glitch_value = (glitch_mode == 2'b00)? 1'b0 : 
                        (glitch_mode == 2'b01)? 1'b1 : ~drive_data;
    assign data_out = (glitch_it)? glitch_value : drive_data;
    assign data_drive = (glitch_it)? 1'b1 : drive_output;

    wire active = running;

    reg enable_glitch_output = 1'b0;
    reg drive_edge = 1'b1; // drive data on falling (0) / rising (1) edge of clock_out_pre
    reg check_edge = 1'b1; // check data and fire trigger on falling (0) / rising (1) edge of clock_out_pre

    always @(*) begin
       if (reg_read) begin
          case (reg_address)
              `BB_TRIG_DATA: reg_datao = saved_payload[reg_bytecnt*8 +: 8];
              `BB_TRIG_CTRL_STAT: begin
                  case (reg_bytecnt)
                      0: reg_datao = {fifo_overflow_error, fifo_underflow_error, 3'b0, enable_glitch_output, active, matched};
                      1: reg_datao = pPATTERN_DEPTH & 8'hFF;
                      2: reg_datao = pPATTERN_DEPTH >> 8;
                      3: reg_datao = pSAVE_DEPTH & 8'hFF;
                      4: reg_datao = pSAVE_DEPTH >> 8;
                  endcase
              end
              default: reg_datao = 0;
          endcase
       end
       else
          reg_datao = 0;
    end


    reg fifo_wr = 1'b0;
    always @(posedge clk_usb) begin
       if (reg_write) begin
          case (reg_address)
              `BB_TRIG_CTRL_STAT: begin
                  case (reg_bytecnt)
                      0: begin
                          trigger_en                    <= reg_datai[7];
                          glitch_mode                   <= reg_datai[1:0];
                      end
                      1: begin
                          continuous_clk                <= reg_datai[7];
                          data_io_inactive_state        <= reg_datai[6:5];
                          trigger_when_matched          <= reg_datai[3];
                          enable_glitch_output          <= reg_datai[2];
                          drive_edge                    <= reg_datai[1];
                          check_edge                    <= reg_datai[0];
                      end
                      2: clk_div                        <= reg_datai[7:1]; // yes, omit LSB to divide by 2
                      3: num_bits[0 +: 8]               <= reg_datai;
                      4: num_bits[8 +: 8]               <= reg_datai;
                      default: ;
                  endcase
              end
              default: ;
          endcase
       end

       if (reg_write && (reg_address == `BB_TRIG_DATA) && ~fifo_wr)
           fifo_wr <= 1'b1;
       else
           fifo_wr <= 1'b0;


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
    reg running_r;
    reg go_wait_sync = 1'b0;
    reg clock_out_pre = 1'b0;
    reg trigger;
    reg trigger_r;
    reg driving = 1'b0;

    assign trigger_pulse = running && trigger_en && trigger_active && trigger && ~trigger_r;
    wire clock_enable = continuous_clk || (drive_edge)? driving : running;
    assign clock_out = clock_enable && clock_out_pre_r;

    wire fifo_overflow_error;
    wire fifo_underflow_error;
    wire fifo_empty;
    wire [4:0] fifo_dout;
    reg  fifo_rd = 1'b0;

    fifo_async #(
        .pDATA_WIDTH    (5),
        .pDEPTH         (pPATTERN_DEPTH),
        .pFALLTHROUGH   (1),
        .pFLOPS         (1),
        .pDISTRIBUTED   (0),
        .pBRAM          (0)
    ) U_fifo (
        .wclk                   (clk_usb),
        .rclk                   (clock),
        .wrst_n                 (~reset),
        .rrst_n                 (~reset),
        .wfull_threshold_value  (0),
        .rempty_threshold_value (0),
        .wen                    (fifo_wr),
        .wdata                  (reg_datai[4:0]),
        .wfull                  (),
        .walmost_full           (),
        .woverflow              (fifo_overflow_error),
        .wfull_threshold        (),
        .ren                    (fifo_rd),
        .rdata                  (fifo_dout),
        .rempty                 (fifo_empty),
        .ralmost_empty          (),
        .rempty_threshold       (),
        .runderflow             (fifo_underflow_error)
    );

    wire pattern_data = fifo_dout[0];
    wire pattern_hiz = fifo_dout[1];
    wire pattern_en = fifo_dout[2];
    wire trigger_bits = fifo_dout[3];
    wire record_en = fifo_dout[4];

    reg clock_out_pre_r;

    reg record_en_r;
    reg pattern_data_r;
    reg pattern_en_r;
    reg trigger_bits_r;

    always @(posedge clock) begin
        if (fifo_rd) begin
            record_en_r     <= record_en;
            pattern_data_r  <= pattern_data;
            pattern_en_r    <= pattern_en;
            trigger_bits_r  <= trigger_bits;
        end
    end

    wire record_en_check    = (drive_edge == check_edge)? record_en    : record_en_r;
    wire pattern_en_check   = (drive_edge == check_edge)? pattern_en   : pattern_en_r;
    wire pattern_data_check = (drive_edge == check_edge)? pattern_data : pattern_data_r;
    wire trigger_bits_check = (drive_edge == check_edge)? trigger_bits : trigger_bits_r;

    // generate clock_out:
    always @(posedge clock) begin
        // note that clk_div is the number of input clock cycles per *half period* of
        // the generated clock; in other words, clk_div is twice the actual clock divisor:
        clock_out_pre_r <= clock_out_pre;
        if (clock_counter == (clk_div-1)) begin
            clock_counter <= 0;
            clock_out_pre <= ~clock_out_pre;
        end
        else
            clock_counter <= clock_counter + 1;
    end

    always @(posedge clock) begin
        trigger_r <= trigger;
        running_r <= running;
        // synchronize "go" to our running clock output:
        if (go_wait_sync && (clock_counter == 0) && (clock_out_pre_r != drive_edge)) begin
            go_wait_sync <= 1'b0;
            running <= 1'b1;
            trigger <= 1'b0;
            matching <= 1'b1;
            bit_counter_drive <= 0;
            bit_counter_check <= 0;
            driving <= 1'b0;
        end
        else if (go_target_pulse) begin
            go_wait_sync <= 1'b1;
            saved_payload <= 0;
            matched <= 1'b0;
        end

        else if (running) begin
            bitrecord <= 1'b0;
            match_check <= 1'b0;
            trigger <= 1'b0;

            // drive logic:
            if (clock_counter == 0) begin
                // drive data on falling or rising edge:
                if (clock_out_pre_r != drive_edge) begin 
                    driving <= 1'b1;
                    if (bit_counter_drive == ( (num_bits > 0)? num_bits : pPATTERN_DEPTH) ) begin
                        running <= 1'b0;
                        driving <= 1'b0;
                        drive_data <= data_io_inactive_state[1];
                        drive_output <= data_io_inactive_state[0];
                        if (matching)
                            matched <= 1'b1;
                        else
                            matched <= 1'b0;
                    end
                    else begin
                        if (~fifo_empty) fifo_rd <= 1'b1; // check on empty because FWFT: need to block last read
                        drive_data <= pattern_data;
                        drive_output <= ~pattern_hiz;
                        bit_counter_drive <= bit_counter_drive + 1;
                    end
                end
                else
                    fifo_rd <= 1'b0;
            end
            else
                fifo_rd <= 1'b0;

            // check logic:
            if (clock_counter == 0) begin
                // check pattern match and fire trigger on falling or rising edge:
                if ((clock_out_pre_r != check_edge) && (driving || (check_edge == drive_edge))) begin 
                    bit_counter_check <= bit_counter_check + 1;
                    match_check <= 1'b1;
                    if (record_en_check) 
                        bitrecord <= 1'b1;

                    if ((matching || ~trigger_when_matched) && trigger_bits_check)
                        trigger <= 1'b1;
                    else
                        trigger <= 1'b0;
                end
            end

            // record logic:
            if (bitrecord)
                saved_payload <= {saved_payload[pSAVE_DEPTH-2:0], data_in};
            if ((data_in != pattern_data_check) && pattern_en_check && match_check)
                matching <= 1'b0;

        end

        else begin
            fifo_rd <= 1'b0;
            matching <= 1'b0;
            trigger <= 1'b0;
            bitrecord <= 1'b0;
            match_check <= 1'b0;
            drive_data <= data_io_inactive_state[1];
            drive_output <= data_io_inactive_state[0];
        end
    end

    assign debug = {trigger_active,
                    active,
                    data_drive,
                    pattern_en,
                    trigger_pulse,
                    bitrecord,
                    matched,
                    matching
                   };

endmodule

`default_nettype wire
