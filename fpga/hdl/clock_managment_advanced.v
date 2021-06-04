`timescale 1ns / 1ps
`default_nettype none
`include "includes.v"
/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more
details, or the codebase at http://www.chipwhisperer.com

Copyright (c) 2012-2021, NewAE Technology Inc. All rights reserved.
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

module clock_managment_advanced #(
   parameter pBYTECNT_SIZE = 7
)(
    input  wire                         reset,       //Does NOT reset CLKGEN block

    // Clock sources
    input  wire                         clk_usb,     //System clock
    input  wire                         clk_ext,     //External clock, aka HS1

    output wire                         adc_clk_out, //Output clock to ADC
    input  wire                         adc_clk_feedback, // Clock from ADC (used for sampling)
    output wire                         clkgen, // Clock to DUT

    // Clock selection
    input  wire [2:0]                   clkadc_source,
    input  wire                         clkgen_source,

    output wire                         systemsample_clk, // Clock to System compensates for wire delay of ADC clock
    input  wire                         clkgen_reset,

    // Phase shift control for external clock (clock: clk_usb)
    input  wire [15:0]                  phase_requested,
    input  wire                         phase_load,
    output wire                         phase_done, 

    output wire                         dcm_adc_locked,
    output wire                         dcm_gen_locked ,

    // register interface
    input  wire [7:0]                   reg_address,
    input  wire [pBYTECNT_SIZE-1:0]     reg_bytecnt,
    input  wire [7:0]                   reg_datai,
    output wire [7:0]                   reg_datao,
    input  wire                         reg_read,
    input  wire                         reg_write,

    // MMCM control
    input  wire                         adc_clkgen_power_down,
    input  wire                         clkgen_power_down 
);

    wire ADC_clk_extsrc;
    wire ADC_clk_sample;

    wire [6:0] drp_addr;
    wire drp_den;
    wire [15:0] drp_din;
    wire [15:0] drp_dout;
    wire drp_drdy;
    wire drp_dwe;

    wire mmcm_psen;
    wire mmcm_psincdec;
    wire mmcm_psdone;

    mmcm_phaseshift_interface U_offset_phaseshift (
      .clk_usb          (clk_usb),
      .reset            (reset),
      .I_step_index     (phase_requested),
      .I_load           (phase_load),
      .O_done           (phase_done),
      .O_psen           (mmcm_psen),
      .O_psincdec       (mmcm_psincdec),
      .I_psdone         (mmcm_psdone)
    );

   reg_mmcm_drp #(
      .pBYTECNT_SIZE    (pBYTECNT_SIZE),
      .pDRP_ADDR        (`DRP_ADDR),
      .pDRP_DATA        (`DRP_DATA)
   ) U_reg_mmcm_drp (
      .reset_i          (reset),
      .clk_usb          (clk_usb),
      .reg_address      (reg_address), 
      .reg_bytecnt      (reg_bytecnt), 
      .reg_datao        (reg_datao), 
      .reg_datai        (reg_datai), 
      .reg_read         (reg_read), 
      .reg_write        (reg_write), 

      .drp_addr         (drp_addr ),
      .drp_den          (drp_den  ),
      .drp_din          (drp_din  ),
      .drp_dout         (drp_dout ),
      .drp_drdy         (drp_drdy ),
      .drp_dwe          (drp_dwe  )
   ); 


    wire clkb;
    wire clkgenfx_in;

    wire dcm_clk_in;
    wire clkgenfx_out;
     
`ifdef __ICARUS__
       assign dcm_clk_in = clkadc_source[2]? clk_ext : clkgenfx_out;
       assign clkgenfx_in = clkgen_source? clk_ext : clk_usb;
`else
       BUFGMUX #(
          .CLK_SEL_TYPE("ASYNC")
       ) clkdcm_mux (
          .O    (dcm_clk_in),
          .I0   (clkgenfx_out),
          .I1   (clk_ext),
          .S    (clkadc_source[2])
       );  

       BUFGMUX #(
          .CLK_SEL_TYPE("ASYNC")
       ) clkgenfx_mux (
          .O    (clkgenfx_in),
          .I0   (clk_usb),
          .I1   (clk_ext),
          .S    (clkgen_source)
       ); 
`endif

    wire dcm_clk;

    wire ADC_clk_times4;
    wire ADC_clk;

`ifdef __ICARUS__
       assign ADC_clk_times4 = dcm_clk_in;
       assign ADC_clk = dcm_clk_in;
       assign clkgenfx_out = clkgenfx_in;
`else
    wire adcfb;
    MMCM_adc_clock_gen U_adc_clock_gen (
       // Clock out ports
       .reset           (reset),
       .clk_in1         (dcm_clk_in),
       .clk_out1        (ADC_clk),
       .clk_out2        (ADC_clk_times4),
       .locked          (dcm_adc_locked),
       .power_down      (adc_clkgen_power_down),
       .clkfb_in        (adcfb),
       .clkfb_out       (adcfb),
       .psclk           (clk_usb),
       .psen            (mmcm_psen),
       .psincdec        (mmcm_psincdec),
       .psdone          (mmcm_psdone)
    );

    MMCM_clkgen U_clkgen (
       .reset           (reset || clkgen_reset),
       .clk_in1         (clkgenfx_in),
       .clk_out1        (clkgenfx_out),
       .locked          (dcm_gen_locked),
       .power_down      (clkgen_power_down),
       // Dynamic reconfiguration ports:
       .daddr           (drp_addr),
       .dclk            (clk_usb),
       .den             (drp_den),
       .din             (drp_din),
       .dout            (drp_dout),
       .drdy            (drp_drdy),
       .dwe             (drp_dwe)
    );
`endif

    assign clkgen = clkgenfx_out;

    //Output buffers
    wire out_from_dcmmux;
`ifdef __ICARUS__
       assign ADC_clk_sample = clkadc_source[0]? clk_ext : out_from_dcmmux;
       assign out_from_dcmmux = clkadc_source[1]? ADC_clk : ADC_clk_times4;
`else
       BUFGMUX #(
          .CLK_SEL_TYPE("ASYNC")
       )
       adcclk_mux (
          .O    (ADC_clk_sample),
          .I0   (out_from_dcmmux),
          .I1   (clk_ext),
          .S    (clkadc_source[0])
       );

        BUFGMUX #(
          .CLK_SEL_TYPE("ASYNC")
       )
       adcclk_0_mux (
          .O    (out_from_dcmmux),
          .I0   (ADC_clk_times4),
          .I1   (ADC_clk),
          .S    (clkadc_source[1])
       );
`endif

    assign adc_clk_out = ADC_clk_sample;

    assign systemsample_clk = adc_clk_feedback;

endmodule
`default_nettype wire
