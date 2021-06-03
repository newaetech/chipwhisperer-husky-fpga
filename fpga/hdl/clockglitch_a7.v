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

module clockglitch_a7 #(
   parameter pBYTECNT_SIZE = 7
)(
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
    input wire          phase1_load,
    output wire         phase1_done,
    output wire         mmcm1_locked,

    // Controls delay between falling edge of glitch & risinge edge of clock
    input wire          phase2_load,
    output wire         phase2_done,
    output wire         mmcm2_locked,

    input wire [15:0]   phase_requested,

    input wire          I_mmcm_powerdown,

    // register interface
    input  wire [7:0]                   reg_address,
    input  wire [pBYTECNT_SIZE-1:0]     reg_bytecnt,
    input  wire [7:0]                   reg_datai,
    output wire [7:0]                   reg_datao,
    input  wire                         reg_read,
    input  wire                         reg_write

);

    wire glitch_mmcm1_clk_out;
    wire mmcm1_clkfbstopped;
    wire mmcm1_clkinstopped;
    wire mmcm1_clkfb;

    wire [6:0] drp1_addr;
    wire [15:0] drp1_din;
    wire [15:0] drp1_dout;
    wire drp1_den;
    wire drp1_dwe;
    wire drp1_drdy;

    wire [6:0] drp2_addr;
    wire [15:0] drp2_din;
    wire [15:0] drp2_dout;
    wire drp2_den;
    wire drp2_dwe;
    wire drp2_drdy;

    wire mmcm1_PSEN;
    wire mmcm1_PSINCDEC;
    wire mmcm1_PSDONE;

    wire glitch_mmcm2_clk_out;
    wire mmcm2_clkfbstopped;
    wire mmcm2_clkinstopped;
    wire mmcm2_clkfb;

    wire mmcm2_DRDY;
    wire mmcm2_PSEN;
    wire mmcm2_PSINCDEC;
    wire mmcm2_PSDONE;

    wire psen;
    wire psdone;

    wire [7:0] reg_datao_drp1;
    wire [7:0] reg_datao_drp2;
    assign reg_datao = reg_datao_drp1 | reg_datao_drp2;

    mmcm_phaseshift_interface U_offset_phaseshift (
      .clk_usb          (clk_usb),
      .reset            (mmcm_rst),
      .I_step_index     (phase_requested),
      .I_load           (phase1_load),
      .O_done           (phase1_done),
      .O_psen           (mmcm1_PSEN),
      .O_psincdec       (mmcm1_PSINCDEC),
      .I_psdone         (mmcm1_PSDONE)
    );

    mmcm_phaseshift_interface U_width_phaseshift (
      .clk_usb          (clk_usb),
      .reset            (mmcm_rst),
      .I_step_index     (phase_requested),
      .I_load           (phase2_load),
      .O_done           (phase2_done),
      .O_psen           (mmcm2_PSEN),
      .O_psincdec       (mmcm2_PSINCDEC),
      .I_psdone         (mmcm2_PSDONE)
    );

   
   wire glitchstream;

   reg glitch_next_reg1;
   reg glitch_next_reg2;
   //Need to think carefully about which clock to syncronize this too, and
   //which edge. Lots of trouble as different options on outputs & adjustable
   //phase
   always @(negedge glitch_mmcm1_clk_out_buf) begin
      glitch_next_reg1 <= glitch_next;
      glitch_next_reg2 <= glitch_next_reg1;
   end

   wire glitch_mmcm1_clk_out_buf;
   wire glitch_mmcm2_clk_out_buf;

`ifdef __ICARUS__
   assign glitch_mmcm1_clk_out_buf = glitch_mmcm1_clk_out;
   assign glitch_mmcm2_clk_out_buf = glitch_mmcm2_clk_out;
`else
   BUFG ubuf1(
      .I    (glitch_mmcm1_clk_out),
      .O    (glitch_mmcm1_clk_out_buf)
   );
   BUFG ubuf2(
      .I    (glitch_mmcm2_clk_out),
      .O    (glitch_mmcm2_clk_out_buf)
   );
`endif

   assign glitchstream = (glitch_mmcm1_clk_out_buf & glitch_mmcm2_clk_out_buf) & glitch_next_reg2;

   assign glitched_clk = (glitch_type == 3'b000) ? source_clk ^ glitchstream :  // glitch XORd with clock
                         (glitch_type == 3'b001) ? source_clk | glitchstream :  // glitch ORd with clock
                         (glitch_type == 3'b010) ? glitchstream :               // glitch only
                         (glitch_type == 3'b011) ? source_clk :                 // clock only
                         (glitch_type == 3'b100) ? glitch_next_reg2 :           // glitch only based on enable
                         1'b0;

`ifndef __ICARUS__
   MMCME2_ADV #(
      .BANDWIDTH                    ("OPTIMIZED"), // Jitter programming (OPTIMIZED, HIGH, LOW)
      .CLKFBOUT_MULT_F              (6.0), // Multiply value for all CLKOUT (2.000-64.000)
      .CLKOUT0_DIVIDE_F             (6.0),
      .CLKFBOUT_PHASE               (0.0), // Phase offset in degrees of CLKFB (-360.000-360.000).
      .CLKIN1_PERIOD                (100.0),
      .CLKOUT0_DUTY_CYCLE           (0.5),
      .CLKOUT0_PHASE                (0.0),  // Phase offset for CLKOUT outputs (-360.000-360.000).
      .CLKOUT4_CASCADE              ("FALSE"), // Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
      .COMPENSATION                 ("INTERNAL"), // ZHOLD, BUF_IN, EXTERNAL, INTERNAL
      .DIVCLK_DIVIDE                (1), // Master division value (1-106)
      .STARTUP_WAIT                 ("FALSE"), // Delays DONE until MMCM is locked (FALSE, TRUE)
      .CLKFBOUT_USE_FINE_PS         ("FALSE"),
      .CLKOUT0_USE_FINE_PS          ("TRUE")
   ) U_mmcm1_offset (
      // Clock Outputs:
      .CLKOUT0                      (glitch_mmcm1_clk_out), 
      .CLKOUT0B                     (), // WARNING: Vivado doesn't let you cascade MMCMs from CLKOUT0B, and the error is cryptic if you do!
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
      .DADDR                        (drp1_addr),
      .DCLK                         (clk_usb),
      .DEN                          (drp1_den),
      .DI                           (drp1_din),
      .DWE                          (drp1_dwe),
      .DO                           (drp1_dout),
      .DRDY                         (drp1_drdy),
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
      .CLKFBOUT_MULT_F              (6.0), // Multiply value for all CLKOUT (2.000-64.000)
      .CLKOUT0_DIVIDE_F             (6.0),
      .CLKFBOUT_PHASE               (0.0), // Phase offset in degrees of CLKFB (-360.000-360.000).
      .CLKIN1_PERIOD                (100.0),
      .CLKOUT0_DUTY_CYCLE           (0.5),
      .CLKOUT0_PHASE                (0.0),  // Phase offset for CLKOUT outputs (-360.000-360.000).
      .CLKOUT4_CASCADE              ("FALSE"), // Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
      .COMPENSATION                 ("INTERNAL"), // ZHOLD, BUF_IN, EXTERNAL, INTERNAL
      .DIVCLK_DIVIDE                (1), // Master division value (1-106)
      .STARTUP_WAIT                 ("FALSE"), // Delays DONE until MMCM is locked (FALSE, TRUE)
      .CLKFBOUT_USE_FINE_PS         ("FALSE"),
      .CLKOUT0_USE_FINE_PS          ("TRUE")
   ) U_mmcm2_width (
      // Clock Outputs:
      .CLKOUT0                      (),
      .CLKOUT0B                     (glitch_mmcm2_clk_out),
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
      .CLKIN1                       (glitch_mmcm1_clk_out),
      .CLKIN2                       (1'b0),
      // Control Ports: 1-bit (each) input: MMCM control ports
      .CLKINSEL                     (1'b1),
      .PWRDWN                       (I_mmcm_powerdown),
      .RST                          (mmcm_rst),
      // DRP Ports:
      .DADDR                        (drp2_addr),
      .DCLK                         (clk_usb),
      .DEN                          (drp2_den),
      .DI                           (drp2_din),
      .DWE                          (drp2_dwe),
      .DO                           (drp2_dout),
      .DRDY                         (drp2_drdy),
      // Dynamic Phase Shift Ports:
      .PSCLK                        (clk_usb),
      .PSEN                         (mmcm2_PSEN),
      .PSINCDEC                     (mmcm2_PSINCDEC),
      .PSDONE                       (mmcm2_PSDONE),
      // Feedback Clocks
      .CLKFBIN                      (mmcm2_clkfb)
   );
`endif

   reg_mmcm_drp #(
      .pBYTECNT_SIZE    (pBYTECNT_SIZE),
      .pDRP_ADDR        (`CG1_DRP_ADDR),
      .pDRP_DATA        (`CG1_DRP_DATA)
   ) U_cg_mmcm1_drp (
      .reset_i          (mmcm_rst),
      .clk_usb          (clk_usb),
      .reg_address      (reg_address), 
      .reg_bytecnt      (reg_bytecnt), 
      .reg_datao        (reg_datao_drp1), 
      .reg_datai        (reg_datai), 
      .reg_read         (reg_read), 
      .reg_write        (reg_write), 
      .drp_addr         (drp1_addr ),
      .drp_den          (drp1_den  ),
      .drp_din          (drp1_din  ),
      .drp_dout         (drp1_dout ),
      .drp_drdy         (drp1_drdy ),
      .drp_dwe          (drp1_dwe  )
   ); 

   reg_mmcm_drp #(
      .pBYTECNT_SIZE    (pBYTECNT_SIZE),
      .pDRP_ADDR        (`CG2_DRP_ADDR),
      .pDRP_DATA        (`CG2_DRP_DATA)
   ) U_cg_mmcm2_drp (
      .reset_i          (mmcm_rst),
      .clk_usb          (clk_usb),
      .reg_address      (reg_address), 
      .reg_bytecnt      (reg_bytecnt), 
      .reg_datao        (reg_datao_drp2), 
      .reg_datai        (reg_datai), 
      .reg_read         (reg_read), 
      .reg_write        (reg_write), 
      .drp_addr         (drp2_addr ),
      .drp_den          (drp2_den  ),
      .drp_din          (drp2_din  ),
      .drp_dout         (drp2_dout ),
      .drp_drdy         (drp2_drdy ),
      .drp_dwe          (drp2_dwe  )
   ); 


`ifdef ILA_GLITCH_PS
    ila_glitch_ps U_ila_glitch_ps (
       .clk            (clk_usb),              // input wire clk
       .probe0         (phase1_load),          // input wire [0:0]  probe0 
       .probe1         (phase2_load),          // input wire [0:0]  probe1 
       .probe2         (phase1_done),          // input wire [0:0]  probe2 
       .probe3         (mmcm1_PSEN),           // input wire [0:0]  probe3 
       .probe4         (mmcm2_PSEN),           // input wire [0:0]  probe4 
       .probe5         (mmcm1_PSINCDEC),       // input wire [0:0]  probe5 
       .probe6         (mmcm2_PSINCDEC),       // input wire [0:0]  probe6 
       .probe7         (mmcm_rst),             // input wire [0:0]  probe7 
       .probe8         (phase2_done)           // input wire [0:0]  probe8 
    );
`endif


endmodule

`default_nettype wire