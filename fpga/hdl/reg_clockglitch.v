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
   parameter pBYTECNT_SIZE = 7
)(
   input  wire         reset,
   input  wire         clk_usb,
   input  wire [7:0]   reg_address,  // Address of register
   input  wire [pBYTECNT_SIZE-1:0]  reg_bytecnt,  // Current byte count
   input  wire [7:0]   reg_datai,    // Data to write
   output wire [7:0]   reg_datao,    // Data to read
   input  wire         reg_read,     // Read flag
   input  wire         reg_write,    // Write flag

   input wire          target_hs1,
   input wire          clkgen,
   input wire          pll_fpga_clk,

   output wire         glitchclk,
   output wire         glitch_mmcm1_clk_out,
   output wire         glitch_mmcm2_clk_out,
   output wire         glitch_enable,
   input wire          exttrigger,
   output wire         glitch_go,
   output reg          glitch_trigger,

   output wire         mmcm_unlocked,
   output reg          led_glitch
);


   wire phase1_load; // Controls width of pulse
   wire phase2_load; // Controls delay between falling edge of glitch & risinge edge of clock

   wire [15:0] phase_requested;
   wire phase1_done;
   wire phase2_done;

   
`ifdef SUPPORT_GLITCH_READBACK
    reg [127:0] clockglitch_readback_reg;
`endif

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

   reg [31:0] clockglitch_offset_reg;
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

   assign mmcm_unlocked = ~(mmcm1_locked & mmcm2_locked); 

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
         01 = Capture Trigger (with offset, continous)
         10 = Continous
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
          01 = Source 1 (clkgen)
          10 = Source 2 (pll_fpga_clk)

    [62..58] (Byte 7, Bits [6..2]) = Cycles to glitch (top 5 bits)

    [63] (Byte 7, Bit 7) = Unused (reads as 0, used to later expand if needed)
*/

   wire [2:0] glitch_type;
   wire [1:0] glitch_trigger_src;
   wire [12:0] max_glitches;
   wire sourceclk;

   assign glitch_type = clockglitch_settings_reg[46:44];
   assign glitch_trigger_src = clockglitch_settings_reg[43:42];
   assign max_glitches = {clockglitch_settings_reg[62:58], clockglitch_settings_reg[55:48]};
   assign sourceclk = (clockglitch_settings_reg[57:56] == 2'b01) ? clkgen : 
                      (clockglitch_settings_reg[57:56] == 2'b10) ? pll_fpga_clk : target_hs1;

   // manual glitch logic:
   reg manual;
   always @(posedge clk_usb)
      manual <= clockglitch_settings_reg[47];

   (*ASYNC_REG = "True" *) reg manual_rs1, manual_rs2;
   reg manual_dly;
   always @(posedge sourceclk) begin
      //Resync with double-FF
      manual_rs1 <= manual;
      manual_rs2 <= manual_rs1;
      
      //Use delay to convert to single pulse in sourceclk domain
      manual_dly <= ~manual_rs2;
   end

   wire exttrigger_resync;

   reg oneshot;

   always @(posedge sourceclk) begin
      if (clockglitch_powerdown)
         glitch_trigger <= 1'b0;
      if (glitch_trigger_src == 2'b10)
         glitch_trigger <= 1'b1;
      else if (glitch_trigger_src == 2'b00)
         glitch_trigger <= manual_rs2 & manual_dly;
      else if (glitch_trigger_src == 2'b01)
         glitch_trigger <= exttrigger_resync;
      else if (glitch_trigger_src == 2'b11)
         glitch_trigger <= exttrigger_resync & oneshot;
   end 

   always @(posedge sourceclk) begin
      if (manual_rs2 & manual_dly)
         oneshot <= 1'b1;
      else if (exttrigger_resync)
         oneshot <= 1'b0;
   end

   reg glitch_go_local;
   always @(posedge sourceclk) begin
      if (glitch_trigger)
         glitch_go_local <= 'b1;
      else 
         glitch_go_local <= 'b0;
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


   always @(posedge clk_usb) begin
      if (reg_read) begin
         case (reg_address)
            `CLOCKGLITCH_SETTINGS: reg_datao_reg <= clockglitch_settings_read[reg_bytecnt*8 +: 8];
            `CLOCKGLITCH_OFFSET: reg_datao_reg <= clockglitch_offset_reg[reg_bytecnt*8 +: 8];
            `CLOCKGLITCH_POWERDOWN: reg_datao_reg <= {7'b0, clockglitch_powerdown};

`ifdef SUPPORT_GLITCH_READBACK
            // ***** be careful to not add registers in this ifdef block unless you really mean to! *****
            `GLITCH_RECONFIG_RB_ADDR: reg_datao_reg <= clockglitch_readback_reg[reg_bytecnt*8 +: 8];
            `GLITCHCYCLES_CNT: reg_datao_reg <= clockglitch_cnt[reg_bytecnt*8 +: 8];
            // ***** be careful to not add registers in this ifdef block unless you really mean to! *****
`endif
            default: reg_datao_reg <= 0;
         endcase
      end
      else
         reg_datao_reg <= 0;
   end

   // single-cycle pulses:
   assign phase1_load  = clockglitch_settings_reg[16];
   assign phase2_load  = clockglitch_settings_reg[17];

   always @(posedge clk_usb) begin
      if (reset) begin
         clockglitch_settings_reg <= 0;
         clockglitch_offset_reg <= 0;
         clockglitch_powerdown <= 1;
`ifdef SUPPORT_GLITCH_READBACK
         clockglitch_cnt_rst <= 0;
         clockglitch_readback_reg <= {8'd0, 8'd10, 8'd0, 8'd10, 16'd0, 16'd0};
`endif
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
`ifdef SUPPORT_GLITCH_READBACK
            `GLITCHCYCLES_CNT: clockglitch_cnt_rst <= reg_datai[0];
            `GLITCH_RECONFIG_RB_ADDR: clockglitch_readback_reg[reg_bytecnt*8 +: 8] <= reg_datai;
`endif
         default: ;
         endcase
      end
   end


   trigger_resync resync(
      .reset                (reset),
      .clk                  (sourceclk),
      .exttrig              (exttrigger),
      .offset               (clockglitch_offset_reg),
      .exttrigger_resync    (exttrigger_resync)
   );

 /* Glitch Hardware */
 clockglitch_a7 #(
    .pBYTECNT_SIZE    (pBYTECNT_SIZE)
 ) U_clockglitch (
    .source_clk             (sourceclk),
    .reset                  (reset),
    .glitched_clk           (glitchclk),
    .glitch_trigger         (glitch_trigger),
    .max_glitches           (max_glitches),
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
    .I_mmcm_powerdown       (clockglitch_powerdown),

    .glitch_mmcm1_clk_out_buf (glitch_mmcm1_clk_out),
    .glitch_mmcm2_clk_out_buf (glitch_mmcm2_clk_out),
    .glitch_enable          (glitch_enable),
    .glitch_go              (glitch_go),

    .reg_address            (reg_address), 
    .reg_bytecnt            (reg_bytecnt), 
    .reg_datao              (reg_datao_cg), 
    .reg_datai              (reg_datai), 
    .reg_read               (reg_read), 
    .reg_write              (reg_write)

);

/* LED lighty up thing */
reg [18:0] led_extend;
always @(posedge sourceclk) begin
   if (clockglitch_powerdown) begin
      led_extend <= 0;   
      led_glitch <= 1'b0;
   end
   else if (glitch_go_local) begin
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


endmodule
`default_nettype wire

