`include "includes.v"
`timescale 1 ns / 1 ps
`default_nettype none

/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more
details, or the codebase at http://www.chipwhisperer.com

Copyright (c) 2013-2021, NewAE Technology Inc. All rights reserved.
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

module reg_openadc #(
   parameter pBYTECNT_SIZE = 7,
   parameter pTRIGGER_FIFO_WIDTH = 32,
   parameter pTRIGGER_FIFO_DEPTH = 512
)(
   input  wire         reset_i,
   output wire         reset_o,
   input  wire         clk_usb,
   input  wire         adc_sampleclk,
   input  wire [7:0]   reg_address,  // Address of register
   input  wire [pBYTECNT_SIZE-1:0]  reg_bytecnt,  // Current byte count
   input  wire [7:0]   reg_datai,    // Data to write
   output wire [7:0]   reg_datao,    // Data to read
   input  wire         reg_read,     // Read flag
   input  wire         reg_write,    // Write flag

   /* Interface to gain module */
   output wire [7:0]   gain,

   /* General status stuff input */
   input  wire [7:0]   status,

   /* Interface to trigger unit */
   output wire         cmd_arm_adc,
   output wire         cmd_arm_usb,
   output wire         trigger_mode,
   output wire         trigger_wait,
   output reg  [11:0]  trigger_adclevel,
   output wire         trigger_now,
   output wire [31:0]  trigger_offset,
   input  wire [31:0]  trigger_length,

   /* Measurement of external clock frequency */
   input  wire [31:0]  extclk_frequency,
   input  wire [31:0]  adcclk_frequency,
   input  wire [31:0]  pllclk_frequency,

   /* Interface to fifo/capture module */
   output reg  [15:0] num_segments,
   output reg  [19:0] segment_cycles,
   output reg         segment_cycle_counter_en,

   /* Additional ADC control lines */
   output reg         data_source_select,
   input  wire        clkblock_dcm_locked_i,
   input  wire        clkblock_gen_locked_i,
   output wire [14:0] presamples_o,
   output wire [31:0] maxsamples_o,
   input  wire [31:0] maxsamples_i,
   output wire [12:0] downsample_o,
   output wire        fifo_stream,
   output reg  [1:0]  led_select,
   output reg         no_clip_errors,
   output reg         no_gain_errors,
   output reg         clip_test,

   input  wire        trigger_event, // capture_go_o from trigger_unit.v, to count cycles between successive triggers

   input  wire        extclk_change,
   output reg         extclk_monitor_disabled,
   output reg [31:0]  extclk_limit,
   output reg         O_disable_adc_error
);

   wire reset;

   (* ASYNC_REG = "TRUE" *) reg[1:0] arm_pipe;
   reg arm_r;
   reg arm_r2;

   always @(posedge adc_sampleclk) begin
      if (reset) begin
         arm_pipe <= 0;
         arm_r <= 0;
         arm_r2 <= 0;
      end
      else begin
         {arm_r2, arm_r, arm_pipe} <= {arm_r, arm_pipe, cmd_arm_usb};
      end
   end
   assign cmd_arm_adc = arm_r2;


   wire reset_fromreg;
   assign reset = reset_i | reset_fromreg;
   assign reset_o = reset;

   wire [31:0] max_samples_constant = 32'd`MAX_SAMPLES;
   wire [31:0] max_segment_samples_constant = 32'd`MAX_SEGMENT_SAMPLES;

   //Register definitions
   reg [7:0]  registers_gain;
   reg [7:0]  registers_settings;
   reg [63:0]  registers_echo;
   reg [15:0] registers_downsample;
   reg [31:0] registers_advclocksettings;
   wire [31:0] registers_advclocksettings_read;
   wire [31:0] registers_extclk_frequency;
   wire [31:0] registers_adcclk_frequency;
   reg [31:0] registers_samples;
   reg [14:0] registers_presamples;
   reg [31:0] registers_offset;
   wire [47:0] version_data;
   wire [31:0] system_frequency = 32'd`SYSTEM_CLK;
   wire [31:0] buildtime;
   reg new_reset;

   reg  trigger_fifo_rd_usb;
   reg  trigger_fifo_clear_usb;


   assign version_data[47:16] = 32'b0;
   assign version_data[15:11] = 5'd`HW_TYPE;
   assign version_data[10:8] = 3'd`HW_VER;
   assign version_data[7:4] = 0;
   assign version_data[3:0] = 4'd`REGISTER_VERSION;

   assign trigger_offset = registers_offset;

   assign reset_fromreg = registers_settings[0] || new_reset;
   //assign reset_fromreg = new_reset;
   assign trigger_mode = registers_settings[2];
   assign cmd_arm_usb = registers_settings[3];
   assign fifo_stream = registers_settings[4];
   assign trigger_wait = registers_settings[5];
   assign trigger_now = registers_settings[6];

   assign registers_advclocksettings_read[4:0] = registers_advclocksettings[4:0];
   assign registers_advclocksettings_read[5] = clkblock_gen_locked_i;
   assign registers_advclocksettings_read[6] = clkblock_dcm_locked_i;
   assign registers_advclocksettings_read[7] = 1'b1;
   assign registers_advclocksettings_read[31:26] = registers_advclocksettings[31:26];
   assign registers_advclocksettings_read[24:8] = registers_advclocksettings[24:8];
   wire extmeasure_src = registers_advclocksettings[27];
   assign downsample_o = registers_downsample[12:0];

   assign registers_advclocksettings_read[25] = 1'b0;

   assign gain = registers_gain;
   assign maxsamples_o = registers_samples;
   assign presamples_o = registers_presamples;

   assign registers_extclk_frequency = (extmeasure_src)? pllclk_frequency : extclk_frequency;
   assign registers_adcclk_frequency = adcclk_frequency;

   reg [7:0] reg_datao_reg;
   assign reg_datao = reg_datao_reg;

   always @(*) begin
          if (reg_read) begin
             case (reg_address)
                `GAIN_ADDR: reg_datao_reg = registers_gain; 
                `SETTINGS_ADDR: reg_datao_reg = registers_settings;
                `STATUS_ADDR: reg_datao_reg = status; 
                `ECHO_ADDR: reg_datao_reg = registers_echo[reg_bytecnt*8 +: 8];
                `EXTFREQ_ADDR: reg_datao_reg = registers_extclk_frequency[reg_bytecnt*8 +: 8]; 
                `ADCFREQ_ADDR: reg_datao_reg = registers_adcclk_frequency[reg_bytecnt*8 +: 8]; 
                `VERSION_ADDR: reg_datao_reg = version_data[reg_bytecnt*8 +: 8];
                `DECIMATE_ADDR: reg_datao_reg = registers_downsample[reg_bytecnt*8 +: 8];
                `SAMPLES_ADDR: reg_datao_reg = registers_samples[reg_bytecnt*8 +: 8];
                `MAX_SAMPLES_ADDR: reg_datao_reg = max_samples_constant[reg_bytecnt*8 +: 8];
                `MAX_SEGMENT_SAMPLES_ADDR: reg_datao_reg = max_segment_samples_constant[reg_bytecnt*8 +: 8];
                `PRESAMPLES_ADDR: reg_datao_reg = registers_presamples[reg_bytecnt*8 +: 8];
                `OFFSET_ADDR: reg_datao_reg = registers_offset[reg_bytecnt*8 +: 8];
                `ADVCLOCK_ADDR: reg_datao_reg = registers_advclocksettings_read[reg_bytecnt*8 +: 8];
                `SYSTEMCLK_ADDR: reg_datao_reg = system_frequency[reg_bytecnt*8 +: 8];
                `TRIGGER_DUR_ADDR: reg_datao_reg = trigger_length[reg_bytecnt*8 +: 8];
                `FPGA_BUILDTIME_ADDR: reg_datao_reg = buildtime[reg_bytecnt*8 +: 8];
                `NUM_SEGMENTS: reg_datao_reg = num_segments[reg_bytecnt*8 +: 8];
                `SEGMENT_CYCLES: reg_datao_reg = segment_cycles[reg_bytecnt*8 +: 8];
                `SEGMENT_CYCLE_COUNTER_EN: reg_datao_reg = {7'b0, segment_cycle_counter_en};
                `DATA_SOURCE_SELECT: reg_datao_reg = data_source_select;
                `LED_SELECT: reg_datao_reg = led_select;
                `NO_CLIP_ERRORS: reg_datao_reg = {6'b0, no_gain_errors, no_clip_errors};
                `CLIP_TEST: reg_datao_reg = clip_test;
                `EXTCLK_MONITOR_DISABLED: reg_datao_reg = {6'b0, O_disable_adc_error, extclk_monitor_disabled};
                `EXTCLK_MONITOR_STAT: reg_datao_reg = extclk_change;
                `EXTCLK_CHANGE_LIMIT: reg_datao_reg = extclk_limit[reg_bytecnt*8 +: 8];
                `ADC_TRIGGER_LEVEL: reg_datao_reg = trigger_adclevel[reg_bytecnt*8 +: 8];
                `NUM_TRIGGERS_DATA: reg_datao_reg = trigger_fifo_dout[reg_bytecnt*8 +: 8];
                `NUM_TRIGGERS_STAT: reg_datao_reg = {5'b0, trigger_fifo_underflow, trigger_fifo_overflow, trigger_fifo_empty};
                default: reg_datao_reg = 0;
             endcase
          end
          else
             reg_datao_reg = 0;
   end

   always @(posedge clk_usb) begin
      if (reset) begin
         registers_gain <= 0;
         registers_settings <= 8'b0010_0100; // default to trigger on rising edge
         registers_echo <= 0;
         registers_samples <= maxsamples_i; // for backwards compatibility with CW-lite, but
                                            // MAX_SAMPLES_ADDR and MAX_SEGMENT_SAMPLES_ADDR registers should be used instead
         registers_presamples <= 0;
         registers_offset <= 0;
         registers_advclocksettings <= 32'h00000102;
         registers_downsample <= 0;
         data_source_select <= 1; // default to ADC
         num_segments <= 1;
         segment_cycles <= 0;
         segment_cycle_counter_en <= 0;
         led_select <= 0;
         no_clip_errors <= 0;
         no_gain_errors <= 0;
         clip_test <= 0;
         extclk_monitor_disabled <= 1;
         O_disable_adc_error <= 0;
         extclk_limit <= 32'd9; // corresponds to ~100 kHz tolerance
         trigger_adclevel <= 12'd0;
         trigger_fifo_clear_usb <= 1'b0;
         trigger_fifo_rd_usb <= 1'b1;
      end 

      else begin
          if (reg_write) begin
             case (reg_address)
                `GAIN_ADDR: registers_gain <= reg_datai;
                `SETTINGS_ADDR: registers_settings <= reg_datai;
                `ECHO_ADDR: registers_echo[reg_bytecnt*8 +: 8] <= reg_datai;
                `DECIMATE_ADDR:  registers_downsample[reg_bytecnt*8 +: 8] <= reg_datai;
                `SAMPLES_ADDR: registers_samples[reg_bytecnt*8 +: 8] <= reg_datai;
                `PRESAMPLES_ADDR: registers_presamples[reg_bytecnt*8 +: 8] <= reg_datai;
                `OFFSET_ADDR: registers_offset[reg_bytecnt*8 +: 8] <= reg_datai;
                `ADVCLOCK_ADDR: registers_advclocksettings[reg_bytecnt*8 +: 8] <= reg_datai;
                `NUM_SEGMENTS: num_segments[reg_bytecnt*8 +: 8] <= reg_datai;
                `SEGMENT_CYCLES: segment_cycles[reg_bytecnt*8 +: 8] <= reg_datai;
                `SEGMENT_CYCLE_COUNTER_EN: segment_cycle_counter_en <= reg_datai[0];
                `DATA_SOURCE_SELECT: data_source_select <= reg_datai[0];
                `LED_SELECT: led_select <= reg_datai[1:0];
                `NO_CLIP_ERRORS: {no_gain_errors, no_clip_errors} <= reg_datai[1:0];
                `CLIP_TEST: clip_test <= reg_datai[0];
                `EXTCLK_MONITOR_DISABLED: {O_disable_adc_error, extclk_monitor_disabled} <= reg_datai[1:0];
                `EXTCLK_CHANGE_LIMIT: extclk_limit[reg_bytecnt*8 +: 8] <= reg_datai;
                `ADC_TRIGGER_LEVEL: trigger_adclevel[reg_bytecnt*8 +: 8] <= reg_datai;
                default: ;
             endcase
         end

         // "special" registers:
         if (reg_write && (reg_address == `NUM_TRIGGERS_STAT))
             trigger_fifo_clear_usb <= 1'b1;
         else
             trigger_fifo_clear_usb <= 1'b0;

         if (reg_write && (reg_address == `NUM_TRIGGERS_DATA))
             trigger_fifo_rd_usb <= 1'b1;
         else
             trigger_fifo_rd_usb <= 1'b0;

      end
   end

   // it's handy to have a reset-only register, which doesn't get reset when you reset...
   always @(posedge clk_usb) begin
      if (reg_write && (reg_address == `RESET))
         new_reset <= reg_datai[0];
   end


   `ifndef __ICARUS__
      USR_ACCESSE2 U_buildtime (
         .CFGCLK(),
         .DATA(buildtime),
         .DATAVALID()
      );
   `else
      assign buildtime = 0;
   `endif


   `ifdef ILA_REG
       ila_reg U_ila_usb (
	      .clk            (clk_usb),      // input wire clk
	      .probe0         (reset_fromreg),// input wire [0:0]  probe0  
	      .probe1         (reset_o),      // input wire [0:0]  probe1 
              .probe2         (new_reset),    // input wire [0:0]  probe2 
	      .probe3         (registers_echo)// input wire [7:0]  probe3 
       );
   `endif

    // Count times between successive triggers:
    // We have a pTRIGGER_FIFO_WIDTH-bit counter.
    // Flag counter overflows by keeping it at {pTRIGGER_FIFO_WIDTH{1'b1}}.
    // Since this FIFO is relatively shallow, keep things simple (instead of
    // high-performance) for reading it: status register indicates if the FIFO
    // is empty; writing that status register triggers popping the next FIFO
    // entry, which the user then reads from another register.
    // Finally, automatically flush the FIFO upon arming, for a better user
    // experience.

    reg  [pTRIGGER_FIFO_WIDTH-1:0] trigger_fifo_count = 0;
    reg  trigger_fifo_wr = 1'b0;
    wire trigger_fifo_full;
    reg  trigger_fifo_overflow = 1'b0;
    wire trigger_fifo_rd;
    wire [pTRIGGER_FIFO_WIDTH-1:0] trigger_fifo_dout;
    wire trigger_fifo_empty;
    wire trigger_fifo_underflow;
    reg  trigger_fifo_flush = 1'b0;
    reg  reset_trigger_fifo_count;
    reg  cmd_arm_adc_r;
    wire trigger_fifo_clear;
    reg  trigger_event_r;

    wire trigger_fifo_flush_filtered = trigger_fifo_flush && ~trigger_fifo_empty;

    always @(posedge adc_sampleclk) begin
        cmd_arm_adc_r <= cmd_arm_adc;
        trigger_event_r <= trigger_event;
        if (trigger_fifo_empty)
            trigger_fifo_flush <= 1'b0;
        else if (cmd_arm_adc && ~cmd_arm_adc_r)
            trigger_fifo_flush <= 1'b1;

        if (trigger_fifo_clear || (cmd_arm_adc && ~cmd_arm_adc_r))
            trigger_fifo_overflow <= 1'b0;
        else if (trigger_event && ~trigger_event_r) begin
            if (trigger_fifo_full)
                trigger_fifo_overflow <= 1'b1;
            else begin
                reset_trigger_fifo_count <= 1'b1;
                trigger_fifo_wr <= 1'b1;
            end
        end
        else begin
            trigger_fifo_wr <= 1'b0;
            reset_trigger_fifo_count <= 1'b0;
            if (reset_trigger_fifo_count)
                trigger_fifo_count <= 0;
            else if (trigger_fifo_count <= {pTRIGGER_FIFO_WIDTH{1'b1}})
                // don't overflow
                trigger_fifo_count <= trigger_fifo_count + 1;
        end
    end

    cdc_pulse U_trigger_fifo_clear_cdc (
       .reset_i       (reset),
       .src_clk       (clk_usb),
       .src_pulse     (trigger_fifo_clear_usb),
       .dst_clk       (adc_sampleclk),
       .dst_pulse     (trigger_fifo_clear)
    );


    cdc_pulse U_trigger_fifo_rd_cdc (
       .reset_i       (reset),
       .src_clk       (clk_usb),
       .src_pulse     (trigger_fifo_rd_usb),
       .dst_clk       (adc_sampleclk),
       .dst_pulse     (trigger_fifo_rd)
    );


    fifo_sync #(
        .pDATA_WIDTH    (pTRIGGER_FIFO_WIDTH),
        .pDEPTH         (pTRIGGER_FIFO_DEPTH),
        .pFALLTHROUGH   (0),
        .pFLOPS         (0),
        .pDISTRIBUTED   (0),
        .pBRAM          (1)
    ) U_trigger_fifo (
        .clk            (adc_sampleclk),
        .rst_n          (~reset),
        .full_threshold_value (0),
        .empty_threshold_value (0),
        .wen            (trigger_fifo_wr),
        .wdata          (trigger_fifo_count),
        .full           (trigger_fifo_full),
        .overflow       (),
        .full_threshold (),
        .empty_threshold(),
        .ren            (trigger_fifo_rd || trigger_fifo_flush_filtered),
        .rdata          (trigger_fifo_dout),
        .empty          (trigger_fifo_empty),
        .almost_empty   (),
        .almost_full    (),
        .underflow      (trigger_fifo_underflow)
    );

endmodule
`default_nettype wire
