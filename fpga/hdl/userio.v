`default_nettype none
`timescale 1ns / 1ps

/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more details,
or the codebase at https://github.com/newaetech/chipwhisperer .

Copyright (c) 2021-2025, Colin O'Flynn <coflynn@newae.com>. All rights reserved.
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

module userio #(
    parameter pWIDTH = 8,
    parameter pBYTECNT_SIZE = 7,
    parameter pPLL_CLOCKS = 6
)(
    input  wire                         reset,
    input  wire                         usb_clk,
    input  wire                         target_clk,
    input  wire                         pll_shutdown,

    input  wire [7:0]                   reg_address,
    input  wire [pBYTECNT_SIZE-1:0]     reg_bytecnt,
    input  wire [7:0]                   reg_datai,
    output wire [7:0]                   reg_datao,
    input  wire                         reg_read,
    input  wire                         reg_write,

    input  wire                         trace_en,
    input  wire [7:0]                   trace_userio_dir,
    input  wire                         target_MOSI,
    input  wire                         target_PDID,
    input  wire                         target_SCK,
    input  wire                         FPGA_BONUS1,

    output reg [3:0]                    userio_fpga_debug_select,
    output reg                          userio_target_debug,
    output reg                          userio_target_debug_swd,

    inout  wire [pWIDTH-1:0]            userio_d,
    input  wire [pWIDTH-1:0]            I_userio_debug_data,
    inout  wire                         userio_clk
);

    wire [5:0] pll_out;
    wire locked;

    // most of these are pWIDTH+1 because of the CK pin
    wire [pWIDTH:0] userio_cwdriven;
    reg  [pWIDTH:0] reg_userio_cwdriven;
    reg  [pWIDTH:0] userio_clockout;
    wire [pWIDTH:0] userio_clockgen = {{(9-pPLL_CLOCKS){1'b0}}, pll_out[pPLL_CLOCKS-1:0]};

    wire [pWIDTH:0] reg_userio_clockout = {userio_clockout[pWIDTH-:pPLL_CLOCKS], {(9-pPLL_CLOCKS){1'b0}}};

    reg  [pWIDTH:0] userio_drive_data_reg;
    reg  [7:0] userio_drive_data_byte1;
    wire [pWIDTH:0] userio_drive_data;

    reg userio_fpga_debug;
    reg [7:0] reg_datao_reg;
    wire [7:0] reg_datao_drp;
    reg clksel;

    genvar i;

    generate
        for (i = 0; i < pWIDTH; i = i + 1) begin
            assign userio_d[i] = (~userio_cwdriven[i])?    1'bz : 
                                 (userio_fpga_debug)?      I_userio_debug_data[i] : 
                                 (reg_userio_clockout[i])? userio_clockgen[pWIDTH-i] : userio_drive_data[i];
        end
    endgenerate

    assign userio_clk = (~userio_cwdriven[pWIDTH])?    1'bz :
                        (userio_target_debug)?         FPGA_BONUS1 : 
                        (reg_userio_clockout[pWIDTH])? userio_clockgen[0] : userio_drive_data[8];

    `ifndef __ICARUS__
        PULLUP USERIO_D_PULLUP[pWIDTH-1:0] (.O(userio_d));
        PULLUP USERIO_C_PULLUP (.O(userio_clk));
    `endif

    // USERIO drive direction can be set via USERIO_CW_DRIVEN, but this gets
    // overwritten by userio_fpga_debug, userio_target_debug,
    // userio_target_debug_swd  and trace_en:
    assign userio_cwdriven = (trace_en)? {1'b0, trace_userio_dir} : 
                             (userio_fpga_debug)? {(pWIDTH+1){1'b1}} :
                             (userio_target_debug && userio_target_debug_swd)? (~(userio_clk)? 9'b0_0010_0000 : 9'b0_0110_0000 ) :
                             (userio_target_debug && ~userio_target_debug_swd)?  9'b0_1110_0000  :
                             reg_userio_cwdriven;

    wire [8:0] userio_read = {userio_clk, userio_d};

    assign userio_drive_data = (userio_target_debug)? {1'b0,        // USERIO_CK
                                                       target_MOSI, // carries TDI on USERIO_D7
                                                       target_PDID, // carries TMS/SWDIO on USERIO_D6
                                                       target_SCK,  // carries TCLK/SWDCLK on USERIO_D5
                                                       5'b0         // USERIO_D4:D0 undriven (TDO input on USERIO_D3)
                                                      } : userio_drive_data_reg;

    // register reads:
    always @(*) begin
        if (reg_read) begin
            case (reg_address)
                `USERIO_CONFIG:
                    case (reg_bytecnt)
                        0: reg_datao_reg = {6'b0, locked, clksel};                                                      // old USERIO_CLKSEL register
                        1: reg_datao_reg = {4'b0, userio_fpga_debug_select};                                            // old USERIO_DEBUG_SELECT register
                        2: reg_datao_reg = {5'b0, userio_target_debug_swd, userio_target_debug, userio_fpga_debug};     // old USERIO_DEBUG_DRIVEN register
                        3: reg_datao_reg = userio_cwdriven[7:0];                                                        // old USERIO_CW_DRIVEN register
                        4: reg_datao_reg = {7'b0, userio_cwdriven[8]};                                                  // ''
                        5: reg_datao_reg = reg_userio_clockout[7:0];                                                    // old USERIO_CLOCK_OUT register
                        6: reg_datao_reg = {7'b0, reg_userio_clockout[8]};                                              // ''
                    endcase

                `USERIO_DRIVE_DATA:          reg_datao_reg = userio_read[reg_bytecnt*8 +: 8];
                default: reg_datao_reg = 0;
            endcase
        end
        else
            reg_datao_reg = 0;
    end

    assign reg_datao = reg_datao_reg | reg_datao_drp;

    // register writes:
    always @(posedge usb_clk) begin
        if (reset) begin
            reg_userio_cwdriven <= 9'b0;
            userio_fpga_debug <= 1'b0;
            userio_target_debug <= 1'b0;
            userio_target_debug_swd <= 1'b0;
            userio_drive_data_reg <= 9'b0;
            userio_fpga_debug_select <= 4'b0;
            userio_clockout <= 9'b0;
            clksel <= 1'b0;
        end 
        else if (reg_write) begin
            case (reg_address)
                `USERIO_CONFIG:
                    case (reg_bytecnt)
                        0: clksel <= reg_datai[0];                                                              // old USERIO_CLKSEL register
                        1: userio_fpga_debug_select <= reg_datai[3:0];                                          // old USERIO_DEBUG_SELECT register
                        2: {userio_target_debug_swd, userio_target_debug, userio_fpga_debug} <= reg_datai[2:0]; // old USERIO_DEBUG_DRIVEN register
                        3: reg_userio_cwdriven[7:0] <= reg_datai;                                               // old USERIO_CW_DRIVEN register
                        4: reg_userio_cwdriven[8] <= reg_datai[0];                                              // ''
                        5: userio_clockout[7:0] <= reg_datai;                                                   // old USERIO_CLOCK_OUT register
                        6: userio_clockout[8] <= reg_datai[0];                                                  // ''
                    endcase


                `USERIO_DRIVE_DATA: begin
                    // atomic update of all 9 bits:
                    if (reg_bytecnt == 0)
                        userio_drive_data_byte1 <= reg_datai;
                    else
                        userio_drive_data_reg <= {reg_datai[0], userio_drive_data_byte1};
                end
                default: ;
            endcase
        end
    end


    `ifndef __ICARUS__
        wire CLKFBOUT;
        PLLE2_ADV #(
            .BANDWIDTH              ("OPTIMIZED"), // OPTIMIZED, HIGH, LOW
            .CLKFBOUT_MULT          (10),
            .CLKFBOUT_PHASE         (0.0), // Phase offset in degrees of CLKFB, (-360.000-360.000).
            .CLKIN1_PERIOD          (10.4), // CLKIN_PERIOD: Input clock period in nS to ps resolution (i.e. 33.333 is 30 MHz).
            .CLKIN2_PERIOD          (5.0),
            .CLKOUT0_DIVIDE         (10),
            .CLKOUT1_DIVIDE         (20),
            .CLKOUT2_DIVIDE         (40),
            .CLKOUT3_DIVIDE         (60),
            .CLKOUT4_DIVIDE         (120),
            .CLKOUT5_DIVIDE         (120),
            .CLKOUT0_DUTY_CYCLE     (0.5),
            .CLKOUT1_DUTY_CYCLE     (0.5),
            .CLKOUT2_DUTY_CYCLE     (0.5),
            .CLKOUT3_DUTY_CYCLE     (0.5),
            .CLKOUT4_DUTY_CYCLE     (0.5),
            .CLKOUT5_DUTY_CYCLE     (0.5),
            .CLKOUT0_PHASE          (0.0),
            .CLKOUT1_PHASE          (0.0),
            .CLKOUT2_PHASE          (0.0),
            .CLKOUT3_PHASE          (0.0),
            .CLKOUT4_PHASE          (0.0),
            .CLKOUT5_PHASE          (0.0),
            .COMPENSATION           ("INTERNAL"), // ZHOLD, BUF_IN, EXTERNAL, INTERNAL
            .DIVCLK_DIVIDE          (1), // Master division value (1-56)
            .REF_JITTER1            (0.0), // REF_JITTER: Reference input jitter in UI (0.000-0.999).
            .REF_JITTER2            (0.0),
            .STARTUP_WAIT           ("FALSE") // Delay DONE until PLL Locks, ("TRUE"/"FALSE")
        )
        U_USERIO_PLLE2_ADV (
            .CLKOUT0                (pll_out[0]),
            .CLKOUT1                (pll_out[1]),
            .CLKOUT2                (pll_out[2]),
            .CLKOUT3                (pll_out[3]),
            .CLKOUT4                (pll_out[4]),
            .CLKOUT5                (pll_out[5]),
            .DO                     (drp_dout),
            .DRDY                   (),
            .CLKFBOUT               (CLKFBOUT),
            .LOCKED                 (locked),
            .CLKIN1                 (target_clk),
            .CLKIN2                 (usb_clk),
            .CLKINSEL               (clksel), // 1-bit input: Clock select, High=CLKIN1 Low=CLKIN2
            .PWRDWN                 (pll_shutdown), // TODO: add some manual enable/disable flag also?
            .RST                    (drp_reset),
            .DADDR                  (drp_addr),
            .DCLK                   (usb_clk),
            .DEN                    (drp_den),
            .DI                     (drp_din),
            .DWE                    (drp_dwe),
            .CLKFBIN                (CLKFBOUT)
        );
    `else
        assign locked = 1'b1;
        reg [5:0] pll_out_reg = 6'b0;
        always @(posedge usb_clk) pll_out_reg <= pll_out_reg + 1;
        assign pll_out = pll_out_reg;
    `endif

    wire [6:0]  drp_addr;
    wire [15:0] drp_din;
    wire [15:0] drp_dout;
    wire        drp_den;
    wire        drp_dwe;
    wire        drp_reset;

 
   reg_mmcm_drp #(
      .pBYTECNT_SIZE    (pBYTECNT_SIZE),
      .pDRP_ADDR        (`USERIO_DRP_ADDR),
      .pDRP_DATA        (`USERIO_DRP_DATA),
      .pDRP_RESET       (`USERIO_DRP_RESET)
   ) U_userio_drp (
      .reset_i          (reset),
      .clk_usb          (usb_clk),
      .selected         (1'b1),
      .reg_address      (reg_address), 
      .reg_bytecnt      (reg_bytecnt), 
      .reg_datao        (reg_datao_drp), 
      .reg_datai        (reg_datai), 
      .reg_read         (reg_read), 
      .reg_write        (reg_write), 
      .drp_addr         (drp_addr ),
      .drp_den          (drp_den  ),
      .drp_din          (drp_din  ),
      .drp_dout         (drp_dout ),
      .drp_dwe          (drp_dwe  ),
      .drp_reset        (drp_reset)
   ); 




endmodule

`default_nettype wire
