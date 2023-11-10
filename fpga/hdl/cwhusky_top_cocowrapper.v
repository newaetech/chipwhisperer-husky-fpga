`timescale 1 ns / 1 ps
`default_nettype none
`include "includes.v"
`include "defines_trace.v"
`include "defines_pw.v"

/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more
details, or the codebase at http://www.chipwhisperer.com

Copyright (c) 2021, NewAE Technology Inc. All rights reserved.
Author: Jean-Pierre Thibault <jpthibault@newae.com>

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

module cwhusky_top_cocowrapper(
    input wire         clk_usb,

    output wire        LED_ADC, //  LED_CLK1FAIL on schematic,
    output wire        LED_GLITCH, // LED_CLK2FAIL on schematic
    output wire        LED_ARMED,
    output wire        LED_CAP,

    /* FPGA - USB Interface */
    inout wire [7:0]    USB_Data,
    input wire [7:0]    USB_Addr,
    input wire          USB_RDn,
    input wire          USB_WRn,
    input wire          USB_CEn,
    input wire          USB_ALEn,                   // USB_SPARE1
    inout wire          USB_SPARE0,

    // currently unused:
    //input wire          FPGA_BONUS1,
    //input wire          FPGA_BONUS2,
    //input wire          FPGA_BONUS3,
    //input wire          FPGA_BONUS4,

    // ADC
    input wire          ADC_clk_fbp, // CW310: these are actually used for the MIG reference clock input
    input wire          ADC_clk_fbn,
    input wire          PLL_CLK1,    // CW310 PLL is used as the ADC clock
    input wire          ui_clk,      // testbench only
    //output wire         ADC_CLKP,
    //output wire         ADC_CLKN,
    //output wire         ADC_SCLK,     // CW310 new
    //output wire         ADC_SDATA,
    //output wire         ADC_SEN,
    //output wire         ADC_RESET,
    //output wire         ADC_DFS,
    //output wire         ADC_OE,
    //input wire          ADC_OVR_SDOUT,
    //input wire [5:0]    ADC_DP,
    //input wire [5:0]    ADC_DN,

    // VGA
    //output wire [4:0]   VMAG_D,
    //output wire         VDBSPWM,

    // PLL
    //input wire          PLL_STATUS,
    //input wire          PLLFPGAP,
    //input wire          PLLFPGAN,

    inout  wire [7:0]   USERIO_D,
    inout  wire         USERIO_CLK,

    //input wire          FPGA_CDOUT, /* Input FROM SAM3U */
    //output wire         FPGA_CDIN, /* Output TO SAM3U */

    //input  wire         SAM_MOSI,
    //output wire         SAM_MISO,
    //input  wire         SAM_SPCK,
    //input  wire         SAM_CS, // not used

    /* XMEGA Programming - not used, but need to ensure line is floating */
    inout  wire         target_PDID,
    inout  wire         target_PDIC,

    /* Spare Lines - AVR Programming */
    inout  wire         target_nRST,
    inout  wire         target_MISO,
    inout  wire         target_MOSI,
    inout  wire         target_SCK,

    /* Target IO Interfaces */
    inout wire          target_io4, // Normally trigger
    inout wire          target_io3, // Normally Spare / SmartCard Comms
    inout wire          target_io2, // Normally RXD
    inout wire          target_io1, // Normally TXD / SmartCard Reset
    input wire          target_hs1, // Clock from victim device
    output wire         target_hs2, // Clock to victim device

    //output wire         glitchout_highpwr, // high-speed glitch output
    //output wire         glitchout_lowpwr, // high-speed glitch output 

    //output wire         target_poweron,
    input  wire [31:0]  w,

    //output wire         TRIG_GLITCHOUT, //trigger/glitch out MCX
    inout  wire         AUXIO, // AUX I/O MCX

    // cocotb testbench stuff:
    input  wire         adc_reading,
    input  wire         la_reading,
    input  wire         trace_reading,
    input  wire         glitch_reading,
    input  wire         expected_glitch,

    input  wire [7:0]   adc_job,
    input  wire [7:0]   la_job,
    input  wire [7:0]   trace_job,
    input  wire [7:0]   glitch_job,
    input  wire [24*8-1:0] current_action,
    input  wire [24*8-1:0] current_read_lock,
    input  wire [31:0]  errors
);


   parameter pDUMP = 0;

   initial begin
      if (pDUMP) begin
          //$display("YYY Got the DUMP!");
          $dumpfile("results/cwhusky_coco.fst");
          $dumpvars(0, cwhusky_top_cocowrapper);
      end
   end

   wire glitch_out;
   wire glitch_clk;
   reg glitch_error_reg;
   wire glitch_error = (glitch_out != expected_glitch); // easier to visualize
   // glitch_error is flopped, otherwise simulator/cocotb may "see" false errors at every edge:
   always @(negedge glitch_clk) glitch_error_reg <= glitch_error;


cwhusky_top U_dut (  
    .clk_usb            (clk_usb      ),
    .ADC_clk_fbp        (PLL_CLK1     ),
    .ADC_clk_fbn        (1'b0         ),
    //.glitch_out         (glitch_out   ), TODO?!?
    //.glitch_clk         (glitch_clk   ), TODO?!?
    //.ADC_DP             (6'b0         ),
    //.ADC_DN             (6'b0         ),
    //.ADC_CLKP           (             ),
    //.ADC_CLKN           (             ),
    .LED_ADC            (LED_ADC      ),
    .LED_GLITCH         (LED_GLITCH   ),
    .LED_ARMED          (LED_ARMED    ),
    .LED_CAP            (LED_CAP      ),
    .USB_Data           (USB_Data     ),
    .USB_Addr           (USB_Addr     ),
    .USB_RDn            (USB_RDn      ),
    .USB_WRn            (USB_WRn      ),
    .USB_CEn            (USB_CEn      ),
    .USB_ALEn           (USB_ALEn     ),
    .USB_SPARE0         (USB_SPARE0   ),
    //.FPGA_BONUS1        (FPGA_BONUS1  ),
    //.FPGA_BONUS2        (FPGA_BONUS2  ),
    //.FPGA_BONUS3        (FPGA_BONUS3  ),
    //.FPGA_BONUS4        (FPGA_BONUS4  ),
    //.SAM_MOSI           (SAM_MOSI     ),
    //.SAM_MISO           (SAM_MISO     ),
    //.SAM_SPCK           (SAM_SPCK     ),
    //.SAM_CS             (SAM_CS       ),
    .target_PDID        (target_PDID  ),
    .target_PDIC        (target_PDIC  ),
    .target_nRST        (target_nRST  ),
    .target_MISO        (target_MISO  ),
    .target_MOSI        (target_MOSI  ),
    .target_SCK         (target_SCK   ),
    .target_io4         (target_io4   ),
    .target_io3         (target_io3   ),
    .target_io2         (target_io2   ),
    .target_io1         (target_io1   ),
    .target_hs1         (target_hs1   ),
    .target_hs2         (target_hs2   ),
    //.TRIG_GLITCHOUT     (TRIG_GLITCHOUT),
    .AUXIO              (AUXIO        ),
    //.ADC_OVR_SDOUT      (1'b0         ),
    //.FPGA_CDOUT         (1'b0         ),
    .USERIO_D           (USERIO_D     ),
    .USERIO_CLK         (USERIO_CLK   )
    //.PLL_STATUS         (1'b0         ),
    //.PLLFPGAP           (clk_adc      ),
    //.PLLFPGAN           (1'b0         )
);


endmodule
`default_nettype wire
