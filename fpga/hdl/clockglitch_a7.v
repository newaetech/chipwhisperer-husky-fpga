`timescale 1ns / 1ps
`default_nettype none
`include "includes.v"

/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more details,
or the codebase at https://github.com/newaetech/chipwhisperer .

Copyright (c) 2013-2021, Colin O'Flynn <coflynn@newae.com>. All rights reserved.
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

module clockglitch_a7(
   // Source Clock
    input wire          source_clk, // HS1 or clkgen

    // Glitchy Clock
    output wire         glitched_clk,

    // Glitch request
    input wire          glitch_next,
    input wire [2:0]    glitch_type,
     /*
     000 = Glitch is XORd with Clock (Positive or Negative going glitch)
     001 = Glitch is ORd with Clock (Positive going glitch only)
     010 = Glitch Only
     011 = Clock Only 
     100 = Glitch only, based on enable reg only (output active during entire clock cycle)
    */

    input wire          clk_usb,
    input wire          mmcm_rst,

    // Controls width of pulse
    input wire [8:0]    phase1_requested,
    output wire [8:0]   phase1_actual,
    input wire          phase1_load,
    output wire         phase1_done,
    output wire         mmcm1_locked,

    // Controls delay between falling edge of glitch & risinge edge of clock
    input wire [8:0]    phase2_requested,
    output wire [8:0]   phase2_actual,
    input wire          phase2_load,
    output wire         phase2_done,
    output wire         mmcm2_locked,

    input wire          I_mmcm_powerdown
);


    wire mmcm1_clk_out;
    wire mmcm1_clkfbstopped;
    wire mmcm1_clkinstopped;
    wire mmcm1_clkfb;
    wire [7:0] mmcm1_DADDR;
    wire mmcm1_DEN = 1'b0; // TODO-temp
    wire [15:0] mmcm1_DI;
    wire mmcm1_DWE = 1'b0; // TODO-temp
    wire [15:0] mmcm1_DO;
    wire mmcm1_DRDY;
    wire mmcm1_PSEN;
    wire mmcm1_PSINCDEC;
    wire mmcm1_PSDONE;

    wire mmcm2_clk_out;
    wire mmcm2_clkfbstopped;
    wire mmcm2_clkinstopped;
    wire mmcm2_clkfb;
    wire [7:0] mmcm2_DADDR;
    wire mmcm2_DEN = 1'b0; // TODO-temp
    wire [15:0] mmcm2_DI;
    wire mmcm2_DWE = 1'b0; // TODO-temp
    wire [15:0] mmcm2_DO;
    wire mmcm2_DRDY;
    wire mmcm2_PSEN;
    wire mmcm2_PSINCDEC;
    wire mmcm2_PSDONE;


    dcm_phaseshift_interface dcmps1(
      .clk_usb          (clk_usb),
      .reset_i          (mmcm_rst),
      .default_value_i  (9'd0),
      .value_i          (phase1_requested),
      .load_i           (phase1_load),
      .value_o          (phase1_actual),
      .done_o           (phase1_done),
      .dcm_psen_o       (mmcm1_PSEN),
      .dcm_psincdec_o   (mmcm1_PSINCDEC),
      .dcm_psdone_i     (mmcm1_PSDONE),
      .dcm_status_i     (8'b0)  // TODO
    );

   wire dcm2_psen;
   wire dcm2_psincdec;
   wire dcm2_psdone;

   dcm_phaseshift_interface dcmps2(
      .clk_usb          (clk_usb),
      .reset_i          (mmcm_rst),
      .default_value_i  (9'd0),
      .value_i          (phase2_requested),
      .load_i           (phase2_load),
      .value_o          (phase2_actual),
      .done_o           (phase2_done),
      .dcm_psen_o       (mmcm2_PSEN),
      .dcm_psincdec_o   (mmcm2_PSINCDEC),
      .dcm_psdone_i     (mmcm2_PSDONE),
      .dcm_status_i     (8'b0)  // TODO
   );

   wire glitchstream;

   reg glitch_next_reg1;
   reg glitch_next_reg2;
   //Need to think carefully about which clock to syncronize this too, and
   //which edge. Lots of trouble as different options on outputs & adjustable
   //phase
   always @(negedge mmcm1_clk_out) begin
      glitch_next_reg1 <= glitch_next;
      glitch_next_reg2 <= glitch_next_reg1;
   end

   // TODO: maybe BUFG on mmcm1_clk_out and mmcm2_clk_out?
   assign glitchstream = (mmcm1_clk_out & mmcm2_clk_out) & glitch_next_reg2;

   assign glitched_clk = (glitch_type == 3'b000) ? source_clk ^ glitchstream :  // glitch XORd with clock
                         (glitch_type == 3'b001) ? source_clk | glitchstream :  // glitch ORd with clock
                         (glitch_type == 3'b010) ? glitchstream :               // glitch only
                         (glitch_type == 3'b011) ? source_clk :                 // clock only
                         (glitch_type == 3'b100) ? glitch_next_reg2 :           // glitch only based on enable
                         1'b0;

`ifndef __ICARUS__
   MMCME2_ADV #(
      .BANDWIDTH                    ("OPTIMIZED"), // Jitter programming (OPTIMIZED, HIGH, LOW)
      .CLKFBOUT_MULT_F              (60.0), // Multiply value for all CLKOUT (2.000-64.000)
      .CLKOUT0_DIVIDE_F             (60.0),
      .CLKFBOUT_PHASE               (0.0), // Phase offset in degrees of CLKFB (-360.000-360.000).
      .CLKIN1_PERIOD                (100.0),
      .CLKOUT0_DUTY_CYCLE           (0.5),
      .CLKOUT0_PHASE                (0.0),  // Phase offset for CLKOUT outputs (-360.000-360.000).
      .CLKOUT4_CASCADE              ("FALSE"), // Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
      .COMPENSATION                 ("ZHOLD"), // ZHOLD, BUF_IN, EXTERNAL, INTERNAL
      .DIVCLK_DIVIDE                (1), // Master division value (1-106)
      .STARTUP_WAIT                 ("FALSE"), // Delays DONE until MMCM is locked (FALSE, TRUE)
      .CLKFBOUT_USE_FINE_PS         ("FALSE"),
      .CLKOUT0_USE_FINE_PS          ("TRUE")
   ) U_mmcm1 (
      // Clock Outputs:
      .CLKOUT0                      (),
      .CLKOUT0B                     (mmcm1_clk_out),
      .CLKOUT1                      (),
      .CLKOUT1B                     (),
      .CLKOUT2                      (),
      .CLKOUT2B                     (),
      .CLKOUT3                      (),
      .CLKOUT3B                     (),
      .CLKOUT4                      (),
      .CLKOUT5                      (),
      .CLKOUT6                      (),
      // Feedback Clocks:
      .CLKFBOUT                     (mmcm1_clkfb),
      .CLKFBOUTB                    (),
      // Status Ports: 1-bit (each) output: MMCM status ports
      .CLKFBSTOPPED                 (mmcm1_clkfbstopped),
      .CLKINSTOPPED                 (mmcm1_clkinstopped),
      .LOCKED                       (mmcm1_locked),
      // Clock Inputs:
      .CLKIN1                       (source_clk),
      .CLKIN2                       (1'b0),
      // Control Ports: 1-bit (each) input: MMCM control ports
      .CLKINSEL                     (1'b1),
      .PWRDWN                       (I_mmcm_powerdown),
      .RST                          (mmcm_rst),
      // DRP Ports:
      .DADDR                        (mmcm1_DADDR),
      .DCLK                         (clk_usb),
      .DEN                          (mmcm1_DEN),
      .DI                           (mmcm1_DI),
      .DWE                          (mmcm1_DWE),
      .DO                           (mmcm1_DO),
      .DRDY                         (mmcm1_DRDY),
      // Dynamic Phase Shift Ports:
      .PSCLK                        (clk_usb),
      .PSEN                         (mmcm1_PSEN),
      .PSINCDEC                     (mmcm1_PSINCDEC),
      .PSDONE                       (mmcm1_PSDONE),
      // Feedback Clocks
      .CLKFBIN                      (mmcm1_clkfb) // 1-bit input: Feedback clock
   );

   MMCME2_ADV #(
      .BANDWIDTH                    ("OPTIMIZED"), // Jitter programming (OPTIMIZED, HIGH, LOW)
      .CLKFBOUT_MULT_F              (60.0), // Multiply value for all CLKOUT (2.000-64.000)
      .CLKOUT0_DIVIDE_F             (60.0),
      .CLKFBOUT_PHASE               (0.0), // Phase offset in degrees of CLKFB (-360.000-360.000).
      .CLKIN1_PERIOD                (100.0),
      .CLKOUT0_DUTY_CYCLE           (0.5),
      .CLKOUT0_PHASE                (0.0),  // Phase offset for CLKOUT outputs (-360.000-360.000).
      .CLKOUT4_CASCADE              ("FALSE"), // Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
      .COMPENSATION                 ("ZHOLD"), // ZHOLD, BUF_IN, EXTERNAL, INTERNAL
      .DIVCLK_DIVIDE                (1), // Master division value (1-106)
      .STARTUP_WAIT                 ("FALSE"), // Delays DONE until MMCM is locked (FALSE, TRUE)
      .CLKFBOUT_USE_FINE_PS         ("FALSE"),
      .CLKOUT0_USE_FINE_PS          ("TRUE")
   ) U_mmcm2 (
      // Clock Outputs:
      .CLKOUT0                      (mmcm2_clk_out),
      .CLKOUT0B                     (),
      .CLKOUT1                      (),
      .CLKOUT1B                     (),
      .CLKOUT2                      (),
      .CLKOUT2B                     (),
      .CLKOUT3                      (),
      .CLKOUT3B                     (),
      .CLKOUT4                      (),
      .CLKOUT5                      (),
      .CLKOUT6                      (),
      // Feedback Clocks:
      .CLKFBOUT                     (mmcm2_clkfb),
      .CLKFBOUTB                    (),
      // Status Ports: 1-bit (each) output: MMCM status ports
      .CLKFBSTOPPED                 (mmcm2_clkfbstopped),
      .CLKINSTOPPED                 (mmcm2_clkinstopped),
      .LOCKED                       (mmcm2_locked),
      // Clock Inputs:
      .CLKIN1                       (source_clk),
      .CLKIN2                       (1'b0),
      // Control Ports: 1-bit (each) input: MMCM control ports
      .CLKINSEL                     (1'b1),
      .PWRDWN                       (I_mmcm_powerdown),
      .RST                          (mmcm_rst),
      // DRP Ports:
      .DADDR                        (mmcm2_DADDR),
      .DCLK                         (clk_usb),
      .DEN                          (mmcm2_DEN),
      .DI                           (mmcm2_DI),
      .DWE                          (mmcm2_DWE),
      .DO                           (mmcm2_DO),
      .DRDY                         (mmcm2_DRDY),
      // Dynamic Phase Shift Ports:
      .PSCLK                        (clk_usb),
      .PSEN                         (mmcm2_PSEN),
      .PSINCDEC                     (mmcm2_PSINCDEC),
      .PSDONE                       (mmcm2_PSDONE),
      // Feedback Clocks
      .CLKFBIN                      (mmcm2_clkfb)
   );
`endif


endmodule

`default_nettype wire
