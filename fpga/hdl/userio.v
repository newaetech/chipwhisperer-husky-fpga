`default_nettype none
`timescale 1ns / 1ps

/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more details,
or the codebase at https://github.com/newaetech/chipwhisperer .

Copyright (c) 2021, Colin O'Flynn <coflynn@newae.com>. All rights reserved.
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
    parameter pBYTECNT_SIZE = 7
)(
    input  wire                         reset,
    input  wire                         usb_clk,

    input  wire [7:0]                   reg_address,
    input  wire [pBYTECNT_SIZE-1:0]     reg_bytecnt,
    input  wire [7:0]                   reg_datai,
    output reg  [7:0]                   reg_datao,
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

    wire [pWIDTH-1:0] userio_cwdriven;
    reg  [pWIDTH-1:0] reg_userio_cwdriven;
    reg userio_fpga_debug;
    reg [pWIDTH-1:0] userio_drive_data_reg;
    wire [pWIDTH-1:0] userio_drive_data;


    genvar i;

    generate
        for (i = 0; i < pWIDTH; i = i + 1) begin
            assign userio_d[i] = (~userio_cwdriven[i])? 1'bz : 
                                 (userio_fpga_debug)?   I_userio_debug_data[i] : userio_drive_data[i];
        end
    endgenerate

    assign userio_clk = (userio_target_debug)? FPGA_BONUS1 : 1'bz;


    `ifndef __ICARUS__
        PULLUP USERIO_PULLUP[pWIDTH-1:0] (.O(userio_d));
    `endif

    // USERIO drive direction can be set via USERIO_CW_DRIVEN, but this gets
    // overwritten by userio_fpga_debug, userio_target_debug,
    // userio_target_debug_swd  and trace_en:
    assign userio_cwdriven = (trace_en)? trace_userio_dir : 
                             userio_fpga_debug? {pWIDTH{1'b1}} :
                             (userio_target_debug && userio_target_debug_swd)? (~userio_clk? 8'b0010_0000 : 8'b0110_0000 ) :
                             (userio_target_debug && ~userio_target_debug_swd)?  8'b1110_0000  :
                             reg_userio_cwdriven;

    wire [8:0] userio_read = {userio_clk, userio_d};

    assign userio_drive_data = (userio_target_debug)? {target_MOSI, // carries TDI on USERIO_D7
                                                       target_PDID, // carries TMS/SWDIO on USERIO_D6
                                                       target_SCK,  // carries TCLK/SWDCLK on USERIO_D5
                                                       5'b0         // USERIO_D4:D0 undriven (TDO input on USERIO_D3)
                                                      } : userio_drive_data_reg;

    // register reads:
    always @(*) begin
        if (reg_read) begin
            case (reg_address)
                `USERIO_CW_DRIVEN:           reg_datao = userio_cwdriven[reg_bytecnt*8 +: 8];
                `USERIO_DEBUG_DRIVEN:        reg_datao = {5'b0, userio_target_debug_swd, userio_target_debug, userio_fpga_debug};
                `USERIO_DEBUG_SELECT:        reg_datao = {4'b0, userio_fpga_debug_select};
                `USERIO_READ:                reg_datao = userio_read[reg_bytecnt*8 +: 8];
                default: reg_datao = 0;
            endcase
        end
        else
            reg_datao = 0;
    end

    // register writes:
    always @(posedge usb_clk) begin
        if (reset) begin
            reg_userio_cwdriven <= 8'b0;
            userio_fpga_debug <= 1'b0;
            userio_target_debug <= 1'b0;
            userio_target_debug_swd <= 1'b0;
            userio_drive_data_reg <= 8'b0;
            userio_fpga_debug_select <= 4'b0;
        end 
        else if (reg_write) begin
            case (reg_address)
                `USERIO_CW_DRIVEN: reg_userio_cwdriven[reg_bytecnt*8 +: 8] <= reg_datai;
                `USERIO_DEBUG_DRIVEN: {userio_target_debug_swd, userio_target_debug, userio_fpga_debug} <= reg_datai[2:0];
                `USERIO_DEBUG_SELECT: userio_fpga_debug_select <= reg_datai[3:0];
                `USERIO_DRIVE_DATA: userio_drive_data_reg[reg_bytecnt*8 +: 8] <= reg_datai;
                default: ;
            endcase
        end
    end


endmodule

`default_nettype wire
