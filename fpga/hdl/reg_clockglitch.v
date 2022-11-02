`include "includes.v"
`timescale 1 ns / 1 ps
`default_nettype none

/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more details,
or the codebase at https://github.com/newaetech/chipwhisperer .

This file is the ChipWhisperer Clock Glitcher registers

Copyright (c) 2013-2021, Colin O'Flynn <coflynn@newae.com>. All rights reserved.
This file is released under the 2-Clause BSD License:

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

module reg_clockglitch #(
   parameter pBYTECNT_SIZE = 7,
   parameter pMAX_GLITCHES = 32,
   parameter pNUM_GLITCH_WIDTH = 5 // size as log2(pMAX_GLITCHES)
)(
   input  wire         reset,
   input  wire         clk_usb,
   input  wire [7:0]   reg_address,  // Address of register
   input  wire [pBYTECNT_SIZE-1:0]  reg_bytecnt,  // Current byte count
   input  wire [7:0]   reg_datai,    // Data to write
   output wire [7:0]   reg_datao,    // Data to read
   input  wire         reg_read,     // Read flag
   input  wire         reg_write,    // Write flag

   input  wire         mmcm_shutdown, // triggered by XADC error

   input wire          target_clk,    // HS1 or AUX
   input wire          pll_fpga_clk,

   output wire         glitchclk,
   output wire         glitch_mmcm1_clk_out,
   output wire         glitch_mmcm2_clk_out,
   output wire         glitch_enable,
   input wire          exttrigger,
   output wire         glitch_go,
   output reg          glitch_trigger,
   output wire         glitch_trigger_manual_sourceclock,

   output reg          led_glitch,
   output wire [7:0]   debug1,
   output wire [7:0]   debug2,
   output wire [7:0]   debug3
);


   wire phase1_load; // Controls width of pulse
   wire phase2_load; // Controls delay between falling edge of glitch & risinge edge of clock

   wire [15:0] phase_requested;
   wire phase1_done;
   wire phase2_done;

   wire [pNUM_GLITCH_WIDTH-1:0] clockglitch_count;
   
   // @ Address 56, 8 bytes (+8 extra reserved for future...)
   //
   // [1 .. 0 ] = Offset (DCM Load Value, MSB = 1, LSB=0)
   // [3 .. 2 ] = Width (DCM Load Value, MSB=3, LSB=2)
   // [4      ] = Offset (%, integer)
   // [5      ] = Offset (%, fraction)
   // [6      ] = Width (%, integer)
   // [7      ] = Width (%, fraction)
   //
   // i.e., 5.6% = 5 (integer) + 60 (fraction)
   //
   //


   reg [63:0]  clockglitch_settings_reg;
   wire [63:0] clockglitch_settings_read;

   reg [32*pMAX_GLITCHES-1:0] clockglitch_offset_reg;
   reg clockglitch_powerdown;

   reg [7:0] reg_datao_reg;
   wire [7:0] reg_datao_cg;
   assign reg_datao = reg_datao_reg | reg_datao_cg;

   wire mmcm1_locked;
   wire mmcm2_locked;

   reg phase1_done_reg;
   reg phase2_done_reg;

   assign phase_requested = clockglitch_settings_reg[15:0];

   wire mmcm_rst;

/*
    Clock-glitch settings main registers (address 51)
    *** NOTE these are different from the CW-lite/pro definitions! ***
    (due to the differences in offset and width settings for 7-series MMCM)
    [15..0]  = Glitch Offset / Width Phase
    [16] = Load offset phase (NOTE: only one of offset / width phase load bits can be set)
    [17] = Load width phase  (NOTE: only one of offset / width phase load bits can be set)
    [36..18] unused (left blank so that fields below coincide with CW-lite/pro)
    [37] = Offset change done
    [38] = Width change done
    [39] (Byte 4, Bit 7)  = Offset MMCM Locked
    [40] (Byte 5, Bit 0)  = Width MMCM Locked 
    [41] (Byte 5, Bit 1)  = MMCM Reset
    [43..42] (Byte 5, Bit [3..2]) = Glitch trigger source
         00 = Manual
         01 = Capture Trigger (with offset, continuous)
         10 = Continuous
         11 = Capture Trigger (with offset, single-shot when manual glitch is '1')

    [46..44] (Byte 5, Bit [6..4]) = Glitch Type
         000 = Glitch is XORd with Clock (Positive or Negative going glitch)
         001 = Glitch is ORd with Clock (Positive going glitch only)
         010 = Glitch Only
         011 = Clock Only      
         100 = Glitch only based on enable, does not use phase-based difference.
         Can generate very long glitch pulses.

    [47] (Byte 5, Bit 7) = Manual Glitch. Set to 1 then 0, glitch on rising edge

    [55..48] (Byte 6, Bits [7..0])
         Cycles to glitch-1 (e.g. 0 means 1 glitch) (lower 8 bits)

    [57..56] (Byte 7, Bits [1..0]) = Glitch Clock Source
          00 = Source 0 (HS1)
          01 = Source 1 (clk_usb)
          10 = Source 2 (pll_fpga_clk)

    [62..58] (Byte 7, Bits [6..2]) = Cycles to glitch (top 5 bits)

    [63] (Byte 7, Bit 7) = Unused (reads as 0, used to later expand if needed)
*/

   wire [2:0] glitch_type;
   wire [1:0] glitch_trigger_src;
   wire [12:0] max_glitches0;
   reg  [13*(pMAX_GLITCHES-1)-1:0] max_glitches1toN_reg;
   reg  [pNUM_GLITCH_WIDTH-1:0] num_glitches;
   reg  fsm_reset;
   reg  easy_done_exit;
   wire [1:0] trigger_resync_state;
   wire [pNUM_GLITCH_WIDTH:0] glitch_done_count;
   wire trigger_resync_idle;
   wire sourceclk;

   wire [31:0] offset = clockglitch_offset_reg[exttrigger_index*32 +: 32];
   wire exttrigger_done;
   wire [pNUM_GLITCH_WIDTH-1:0] exttrigger_index;
   wire exttrigger_resync;
   wire multiple_glitches_supported;
   wire continuous_mode;
   wire ext_single_mode;
   reg [7:0] powered_down = 8'h81;

   assign glitch_type = clockglitch_settings_reg[46:44];
   assign glitch_trigger_src = clockglitch_settings_reg[43:42];
   assign max_glitches0 = {clockglitch_settings_reg[62:58], clockglitch_settings_reg[55:48]};

   wire [13*pMAX_GLITCHES-1:0] all_max_glitches = {max_glitches1toN_reg, max_glitches0};

`ifdef __ICARUS__
   assign sourceclk = (clockglitch_settings_reg[57:56] == 2'b01) ? clk_usb : 
                      (clockglitch_settings_reg[57:56] == 2'b10) ? pll_fpga_clk :
                      (clockglitch_settings_reg[57:56] == 2'b00) ? target_clk   : target_clk;
`else
    wire mux1out;
    BUFGMUX #(
       .CLK_SEL_TYPE("ASYNC")
    ) sourceclk_mux1 (
       .O    (mux1out),
       .I0   (target_clk),
       .I1   (pll_fpga_clk),
       .S    (clockglitch_settings_reg[57])
    );  

    BUFGMUX #(
       .CLK_SEL_TYPE("ASYNC")
    ) sourceclk_mux2 (
       .O    (sourceclk),
       .I0   (mux1out),
       .I1   (clk_usb),
       .S    (clockglitch_settings_reg[56])
    ); 
`endif


   // manual glitch logic:
   reg manual;
   always @(posedge clk_usb)
      manual <= clockglitch_settings_reg[47];

   // Manual triggering is a bit convoluted. It originates in the USB clock
   // domain. We first generate a pulse from this in the sourceclock domain;
   // this is used only for the purpose of triggering a scope.LA capture with
   // sourceclock-based time reference (husky_glitch.ipynb needs this). This
   // pulse is then CDC's to the MMCM1 clock domain, and that's actually used
   // for glitch generation.
   (*ASYNC_REG = "True" *) reg manual_rs1, manual_rs2;
   reg manual_dly;
   always @(posedge sourceclk) begin
      //Resync with double-FF
      manual_rs1 <= manual;
      manual_rs2 <= manual_rs1;
      manual_dly <= ~manual_rs2;
   end
   wire manual_pulse_sourceclock = manual_rs2 & manual_dly;
   wire manual_pulse_mmcm1clock;

   cdc_pulse U_glitch_trigger_sourceclock_pulse (
      .reset_i       (reset),
      .src_clk       (sourceclk),
      .src_pulse     (manual_pulse_sourceclock),
      .dst_clk       (~glitch_mmcm1_clk_out),
      .dst_pulse     (manual_pulse_mmcm1clock)
   );
   assign glitch_trigger_manual_sourceclock = manual_pulse_sourceclock && (glitch_trigger_src == 2'b00);

   reg oneshot = 1'b0;

   // See note in clockglitch_a7.v explaining why negedges are used.
   always @(negedge glitch_mmcm1_clk_out) begin
      if (clockglitch_powerdown)
         glitch_trigger <= 1'b0;
      else if (glitch_trigger_src == 2'b10)
         glitch_trigger <= 1'b1;
      else if (glitch_trigger_src == 2'b00)
         glitch_trigger <= manual_pulse_mmcm1clock;
      else if (glitch_trigger_src == 2'b01)
         glitch_trigger <= exttrigger_resync;
      else if (glitch_trigger_src == 2'b11)
         glitch_trigger <= exttrigger_resync & oneshot;
   end 


   assign multiple_glitches_supported = (glitch_trigger_src == 2'b01) ||
                                        (glitch_trigger_src == 2'b11);
   assign continuous_mode = (glitch_trigger_src == 2'b10);
   assign ext_single_mode = (glitch_trigger_src == 2'b11);

   always @(negedge glitch_mmcm1_clk_out) begin
      if (reset)
         oneshot <= 1'b0;
      else if (manual_rs2 & manual_dly)
         oneshot <= 1'b1;
      else if (exttrigger_done)
         oneshot <= 1'b0;
   end

   assign clockglitch_settings_read[17:0] = clockglitch_settings_reg[17:0];
   assign clockglitch_settings_read[36:18] = 0;
   assign clockglitch_settings_read[37] = phase1_done_reg;
   assign clockglitch_settings_read[38] = phase2_done_reg;
   assign clockglitch_settings_read[39] = mmcm1_locked;
   assign clockglitch_settings_read[40] = mmcm2_locked;
   assign clockglitch_settings_read[63:41] = clockglitch_settings_reg[63:41];
   assign mmcm_rst = clockglitch_settings_reg[41];

   always @(posedge clk_usb) begin
      if (phase1_load)
         phase1_done_reg <= 'b0;
      else if (phase1_done)
         phase1_done_reg <= 'b1;

      if (phase2_load)
         phase2_done_reg <= 'b0;
      else if (phase2_done)
         phase2_done_reg <= 'b1;
   end

   always @(*) begin
      if (reg_read) begin
         case (reg_address)
            `CLOCKGLITCH_SETTINGS: reg_datao_reg = clockglitch_settings_read[reg_bytecnt*8 +: 8];
            `CLOCKGLITCH_OFFSET: reg_datao_reg = clockglitch_offset_reg[reg_bytecnt*8 +: 8];
            `CLOCKGLITCH_POWERDOWN: reg_datao_reg = {7'b0, clockglitch_powerdown};
            `CLOCKGLITCH_NUM_GLITCHES: reg_datao_reg = {2'b0, glitch_done_count};
            `CLOCKGLITCH_MULTIPLE_STATE: reg_datao_reg = trigger_resync_state;
            `CLOCKGLITCH_REPEATS: reg_datao_reg = max_glitches1toN_reg[reg_bytecnt*8 +: 8];
            `CLOCKGLITCH_POWERED_DOWN: reg_datao_reg = powered_down;
            default: reg_datao_reg = 0;
         endcase
      end
      else
         reg_datao_reg = 0;
   end

   always @(posedge clk_usb) // for debug
       if (mmcm_shutdown)
           powered_down <= 8'hAA;

   // single-cycle pulses:
   assign phase1_load  = clockglitch_settings_reg[16];
   assign phase2_load  = clockglitch_settings_reg[17];

   always @(posedge clk_usb) begin
      if (reset) begin
         clockglitch_settings_reg <= 0;
         clockglitch_offset_reg <= 0;
         clockglitch_powerdown <= 1;
         max_glitches1toN_reg <= 0;
         num_glitches <= 0;
         easy_done_exit <= 1;
      end 

      else if (clockglitch_settings_reg[16])
         clockglitch_settings_reg[16] <= 0;

      else if (clockglitch_settings_reg[17])
         clockglitch_settings_reg[17] <= 0;

      else if (reg_write) begin
         case (reg_address)
            `CLOCKGLITCH_SETTINGS: clockglitch_settings_reg[reg_bytecnt*8 +: 8] <= reg_datai;      
            `CLOCKGLITCH_OFFSET: clockglitch_offset_reg[reg_bytecnt*8 +: 8] <= reg_datai;      
            `CLOCKGLITCH_POWERDOWN: clockglitch_powerdown <= reg_datai[0];
            `CLOCKGLITCH_REPEATS: max_glitches1toN_reg[reg_bytecnt*8 +: 8] <= reg_datai;
            `CLOCKGLITCH_NUM_GLITCHES: num_glitches <= reg_datai;
            `CLOCKGLITCH_MULTIPLE_STATE: fsm_reset <= reg_datai[0];
            `CLOCKGLITCH_POWERED_DOWN: easy_done_exit <= reg_datai[0]; // re-using this address for a different purpose - no glitch debugging
         default: ;
         endcase
      end
   end

   trigger_resync #(
      .pMAX_GLITCHES        (pMAX_GLITCHES),
      .pNUM_GLITCH_WIDTH    (pNUM_GLITCH_WIDTH)
   ) resync(
      .reset                (reset),
      .fsm_reset            (fsm_reset),
      .clk_usb              (clk_usb),
      .glitch_mmcm1_clk_out (glitch_mmcm1_clk_out),
      .ext_single_mode      (ext_single_mode),
      .oneshot              (oneshot),
      .exttrig              (exttrigger),
      .offset               (offset),
      .exttrigger_resync    (exttrigger_resync),
      .done                 (exttrigger_done),
      .index                (exttrigger_index),
      .glitch_go            (glitch_go),
      .num_glitches         (num_glitches),
      .glitch_done_count    (glitch_done_count),
      .easy_done_exit       (easy_done_exit),
      .idle                 (trigger_resync_idle),
      .fsm_state            (trigger_resync_state),
      .debug                (debug3)            
   );

 /* Glitch Hardware */
 clockglitch_a7 #(
    .pBYTECNT_SIZE          (pBYTECNT_SIZE),
    .pMAX_GLITCHES          (pMAX_GLITCHES),
    .pNUM_GLITCH_WIDTH      (pNUM_GLITCH_WIDTH)
 ) U_clockglitch (
    .source_clk             (sourceclk),
    .reset                  (reset),
    .glitched_clk           (glitchclk),
    .glitch_trigger         (glitch_trigger),
    .all_max_glitches       (all_max_glitches),
    .trigger_resync_idle    (trigger_resync_idle),
    .multiple_glitches_supported (multiple_glitches_supported),
    .easy_done_exit         (easy_done_exit),
    .num_glitches           (num_glitches),
    .continuous_mode        (continuous_mode),
    .glitch_type            (glitch_type),
    .clk_usb                (clk_usb),
    .mmcm_rst               (mmcm_rst),
    .phase_requested        (phase_requested),
    .phase1_load            (phase1_load),
    .mmcm1_locked           (mmcm1_locked),
    .phase2_load            (phase2_load),
    .mmcm2_locked           (mmcm2_locked),
    .phase1_done            (phase1_done),
    .phase2_done            (phase2_done),
    .I_mmcm_powerdown       (clockglitch_powerdown || mmcm_shutdown),

    .glitch_mmcm1_clk_out_buf (glitch_mmcm1_clk_out),
    .glitch_mmcm2_clk_out_buf (glitch_mmcm2_clk_out),
    .glitch_enable          (glitch_enable),
    .glitch_go              (glitch_go),

    .reg_address            (reg_address), 
    .reg_bytecnt            (reg_bytecnt), 
    .reg_datao              (reg_datao_cg), 
    .reg_datai              (reg_datai), 
    .reg_read               (reg_read), 
    .reg_write              (reg_write),

    .glitch_count_debug     (clockglitch_count)
);

/* LED lighty up thing */
reg [18:0] led_extend;
always @(negedge glitch_mmcm1_clk_out) begin
   if (clockglitch_powerdown || mmcm_shutdown) begin
      led_extend <= 0;   
      led_glitch <= 1'b0;
   end
   else if (glitch_trigger) begin
      led_extend <= 0;   
      led_glitch <= 1'b1;
   end 
   else begin
      if (led_glitch == 1'b1)
         led_extend <= led_extend + 19'b1;
      if (led_extend == 19'h7FFFF)
         led_glitch <= 1'b0;
   end
end

assign debug1= {clockglitch_count[1:0], // 7:6
                glitch_done_count[1:0], // 5:4
                glitch_trigger,         // 3
                trigger_resync_idle,    // 2
                exttrigger_resync,      // 1
                exttrigger};            // 0

assign debug2= {glitch_done_count[1:0], // 7:6
                glitch_enable,          // 5
                glitchclk,              // 4
                glitch_trigger,         // 3
                glitch_mmcm1_clk_out,   // 2
                sourceclk,              // 1
                exttrigger              // 0
               };

endmodule
`default_nettype wire

