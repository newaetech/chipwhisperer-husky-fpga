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
   parameter pBYTECNT_SIZE = 7
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
   output wire         cmd_arm,
   output wire         trigger_mode,
   output wire         trigger_wait,
   output wire [11:0]  trigger_level,
   output wire         trigger_source,
   output wire         trigger_now,
   output wire [31:0]  trigger_offset,
   input  wire [31:0]  trigger_length,

   /* Measurement of external clock frequency */
   input  wire [31:0]  extclk_frequency,
   output wire         extclk_measure_src,
   input  wire [31:0]  adcclk_frequency,

   /* Interface to phase shift module */
   output wire [15:0]  phase_o,
   output wire         phase_ld_o,
   input  wire         phase_done_i,    // TODO: currently unused

   /* Interface to fifo/capture module */
   output reg  [15:0] num_segments,
   output reg  [19:0] segment_cycles,

   /* Additional ADC control lines */
   output reg         data_source_select,
   output wire [2:0]  adc_clk_src_o,
   output wire        clkgen_src_o,
   output wire        clkblock_dcm_reset_o,
   output wire        clkblock_gen_reset_o,
   input  wire        clkblock_dcm_locked_i,
   input  wire        clkblock_gen_locked_i,
   output wire [14:0] presamples_o,
   output wire [31:0] maxsamples_o,
   input  wire [31:0] maxsamples_i,
   output wire [12:0] downsample_o,
   output wire        fifo_stream,
   output reg  [1:0]  led_select,
   output reg         no_clip_errors,

   input  wire        extclk_change,
   output reg         extclk_monitor_disabled,
   output reg [31:0]  extclk_limit,

   output reg         adc_clkgen_power_down,
   output reg         clkgen_power_down 

);

   wire reset;
   wire cmd_arm_usb;

   assign  trigger_level = 12'b0; // TODO: add register?

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
   assign cmd_arm = arm_r2;


   wire reset_fromreg;
   assign reset = reset_i | reset_fromreg;
   assign reset_o = reset;


   //Register definitions
   reg [7:0]  registers_gain;
   reg [7:0]  registers_settings;
   reg [7:0]  registers_echo;
   reg [15:0] registers_downsample;
   reg [31:0] registers_advclocksettings;
   wire [31:0] registers_advclocksettings_read;
   wire [31:0] registers_extclk_frequency;
   wire [31:0] registers_adcclk_frequency;
   reg [31:0] registers_samples;
   reg [14:0] registers_presamples;
   reg [31:0] registers_offset;
   reg [15:0] phase_out;
   reg        phase_loadout;
   wire [47:0] version_data;
   wire [31:0] system_frequency = 32'd`SYSTEM_CLK;
   wire [31:0] buildtime;
   reg new_reset;

   assign version_data[47:16] = 32'b0;
   assign version_data[15:11] = 5'd`HW_TYPE;
   assign version_data[10:8] = 3'd`HW_VER;
   assign version_data[7:4] = 0;
   assign version_data[3:0] = 4'd`REGISTER_VERSION;

   assign trigger_offset = registers_offset;

   assign phase_o = phase_out;
   assign phase_ld_o = phase_loadout;

   //assign reset_fromreg = registers_settings[0] || new_reset;
   assign reset_fromreg = new_reset;
   assign trigger_mode = registers_settings[2];
   assign cmd_arm_usb = registers_settings[3];
   assign fifo_stream = registers_settings[4];
   assign trigger_wait = registers_settings[5];
   assign trigger_now = registers_settings[6];
   assign trigger_source = registers_settings[7];

   assign registers_advclocksettings_read[4:0] = registers_advclocksettings[4:0];
   assign registers_advclocksettings_read[5] = clkblock_gen_locked_i;
   assign registers_advclocksettings_read[6] = clkblock_dcm_locked_i;
   assign registers_advclocksettings_read[7] = 1'b1;
   assign registers_advclocksettings_read[31:26] = registers_advclocksettings[31:26];
   assign registers_advclocksettings_read[24:8] = registers_advclocksettings[24:8];
   assign adc_clk_src_o[2:0] = registers_advclocksettings[2:0];
   assign clkgen_src_o = registers_advclocksettings[3];
   assign clkblock_dcm_reset_o = registers_advclocksettings[4];
   assign clkblock_gen_reset_o = registers_advclocksettings[26];
   assign extclk_measure_src = registers_advclocksettings[27];

   assign downsample_o = registers_downsample[12:0];

   assign registers_advclocksettings_read[25] = 1'b0;

   assign gain = registers_gain;
   assign maxsamples_o = registers_samples;
   assign presamples_o = registers_presamples;

   assign registers_extclk_frequency = extclk_frequency;
   assign registers_adcclk_frequency = adcclk_frequency;

   reg [7:0] reg_datao_reg;
   assign reg_datao = reg_datao_reg;

   always @(posedge clk_usb) begin
          if (reg_read) begin
             case (reg_address)
                `GAIN_ADDR: reg_datao_reg <= registers_gain; 
                `SETTINGS_ADDR: reg_datao_reg <= registers_settings;
                `STATUS_ADDR: reg_datao_reg <= status; 
                `ECHO_ADDR: reg_datao_reg <= registers_echo;
                `EXTFREQ_ADDR: reg_datao_reg <= registers_extclk_frequency[reg_bytecnt*8 +: 8]; 
                `ADCFREQ_ADDR: reg_datao_reg <= registers_adcclk_frequency[reg_bytecnt*8 +: 8]; 
                `PHASE_ADDR: reg_datao_reg <= phase_out[reg_bytecnt*8 +: 8]; 
                `VERSION_ADDR: reg_datao_reg <= version_data[reg_bytecnt*8 +: 8];
                `DECIMATE_ADDR: reg_datao_reg <= registers_downsample[reg_bytecnt*8 +: 8];
                `SAMPLES_ADDR: reg_datao_reg <= registers_samples[reg_bytecnt*8 +: 8];
                `PRESAMPLES_ADDR: reg_datao_reg <= registers_presamples[reg_bytecnt*8 +: 8];
                `OFFSET_ADDR: reg_datao_reg <= registers_offset[reg_bytecnt*8 +: 8];
                `ADVCLOCK_ADDR: reg_datao_reg <= registers_advclocksettings_read[reg_bytecnt*8 +: 8];
                `SYSTEMCLK_ADDR: reg_datao_reg <= system_frequency[reg_bytecnt*8 +: 8];
                `TRIGGER_DUR_ADDR: reg_datao_reg <= trigger_length[reg_bytecnt*8 +: 8];
                `FPGA_BUILDTIME_ADDR: reg_datao_reg <= buildtime[reg_bytecnt*8 +: 8];
                `NUM_SEGMENTS: reg_datao_reg <= num_segments[reg_bytecnt*8 +: 8];
                `SEGMENT_CYCLES: reg_datao_reg <= segment_cycles[reg_bytecnt*8 +: 8];
                `DATA_SOURCE_SELECT: reg_datao_reg <= data_source_select;
                `LED_SELECT: reg_datao_reg <= led_select;
                `NO_CLIP_ERRORS: reg_datao_reg <= no_clip_errors;
                `CLKGEN_POWERDOWN: reg_datao_reg <= {6'b0, adc_clkgen_power_down, clkgen_power_down};
                `EXTCLK_MONITOR_DISABLED: reg_datao_reg <= extclk_monitor_disabled;
                `EXTCLK_MONITOR_STAT: reg_datao_reg <= extclk_change;
                `EXTCLK_CHANGE_LIMIT: reg_datao_reg <= extclk_limit[reg_bytecnt*8 +: 8];
                default: reg_datao_reg <= 0;
             endcase
          end
          else
             reg_datao_reg <= 0;
   end

   always @(posedge clk_usb) begin
      if (reset) begin
         registers_gain <= 0;
         registers_settings <= 8'b0010_0100; // default to trigger on rising edge
         registers_echo <= 0;
         registers_samples <= maxsamples_i;
         registers_presamples <= 0;
         registers_offset <= 0;
         registers_advclocksettings <= 32'h00000102;
         registers_downsample <= 0;
         data_source_select <= 1; // default to ADC
         num_segments <= 1;
         segment_cycles <= 0;
         led_select <= 0;
         no_clip_errors <= 0;
         // CLKGEN MMCMs are powered down by default, because we can get too hot if all MMCMs are kept on:
         adc_clkgen_power_down <= 1;
         clkgen_power_down <= 1;
         phase_out <= 0;
         extclk_monitor_disabled <= 1;
         extclk_limit <= 32'd9; // corresponds to ~100 Hz tolerance
      end else if (reg_write) begin
         case (reg_address)
            `GAIN_ADDR: registers_gain <= reg_datai;
            `SETTINGS_ADDR: registers_settings <= reg_datai;
            `ECHO_ADDR: registers_echo <= reg_datai;
            `DECIMATE_ADDR:  registers_downsample[reg_bytecnt*8 +: 8] <= reg_datai;
            `SAMPLES_ADDR: registers_samples[reg_bytecnt*8 +: 8] <= reg_datai;
            `PRESAMPLES_ADDR: registers_presamples[reg_bytecnt*8 +: 8] <= reg_datai;
            `OFFSET_ADDR: registers_offset[reg_bytecnt*8 +: 8] <= reg_datai;
            `ADVCLOCK_ADDR: registers_advclocksettings[reg_bytecnt*8 +: 8] <= reg_datai;
            `NUM_SEGMENTS: num_segments[reg_bytecnt*8 +: 8] <= reg_datai;
            `SEGMENT_CYCLES: segment_cycles[reg_bytecnt*8 +: 8] <= reg_datai;
            `DATA_SOURCE_SELECT: data_source_select <= reg_datai[0];
            `LED_SELECT: led_select <= reg_datai[1:0];
            `NO_CLIP_ERRORS: no_clip_errors <= reg_datai[0];
            `CLKGEN_POWERDOWN: {adc_clkgen_power_down, clkgen_power_down} <= reg_datai[1:0];
            `PHASE_ADDR: phase_out[reg_bytecnt*8 +: 8] <= reg_datai;
            `EXTCLK_MONITOR_DISABLED: extclk_monitor_disabled <= reg_datai[0];
            `EXTCLK_CHANGE_LIMIT: extclk_limit[reg_bytecnt*8 +: 8] <= reg_datai;
            default: ;
         endcase
      end
   end

   // it's handy to have a reset-only register, which doesn't get reset when you reset...
   always @(posedge clk_usb) begin
      if (reg_write && (reg_address == `RESET))
         new_reset <= reg_datai[0];
   end

   always @(posedge clk_usb) begin
      if (reset)
         phase_loadout <= 1'b0;
      else if ( reg_write && (reg_address == `PHASE_ADDR) && (reg_bytecnt == 1) )
         phase_loadout <= 1'b1;
      else
         phase_loadout <= 1'b0;
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


endmodule
`default_nettype wire
