`timescale 1 ns / 1 ps
`default_nettype none

/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more
details, or the codebase at http://www.chipwhisperer.com

Copyright (c) 2025, NewAE Technology Inc. All rights reserved.
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

module hw_bb_cocowrapper (
    // DUT things:
    input wire         clk_usb,
    input wire         clk_adc,
    input wire         reset,

    inout wire [7:0]    USB_Data,
    input wire [7:0]    USB_Addr,
    input wire          USB_RDn,
    input wire          USB_WRn,
    input wire          USB_CEn,
    input wire          USB_ALEn,

    //input  wire         bb_data_in,
    output wire         bb_data_out,
    output wire         bb_data_drive,
    output wire         bb_clock_out,
    output wire         trigger_bb,
    input  wire         glitchclk,

    // testbench things:
    input  wire [31:0]  errors,
    input  wire         expected_trigger,
    output reg          trigger_error

);

    parameter pDUMP = 0;
    parameter pBYTECNT_SIZE = 7;
    parameter pPATTERN_DEPTH = 256;
    parameter pSAVE_DEPTH = 64;

    initial begin
       if (pDUMP) begin
           $dumpfile("results/hw_bb_coco.fst");
           $dumpvars(0, hw_bb_cocowrapper);
       end
    end

    always @(posedge clk_adc) begin
        if (expected_trigger != trigger_bb)
            trigger_error <= 1'b1;
        else
            trigger_error <= 1'b0;
    end

    wire bb_data_in = bb_data_out;

    hw_bb_wrapper #(
        .pBYTECNT_SIZE      (7),
        .pPATTERN_DEPTH     (pPATTERN_DEPTH),
        .pSAVE_DEPTH        (pSAVE_DEPTH)
    ) U_dut (
        .reset              (reset),
        .clk_usb            (clk_usb),
        .clk_adc            (clk_adc),

        .USB_Data           (USB_Data     ),
        .USB_Addr           (USB_Addr     ),
        .USB_RDn            (USB_RDn      ),
        .USB_WRn            (USB_WRn      ),
        .USB_CEn            (USB_CEn      ),
        .USB_ALEn           (USB_ALEn     ),

        .bb_data_in         (bb_data_in   ),
        .bb_data_out        (bb_data_out  ),
        .bb_data_drive      (bb_data_drive),
        .bb_clock_out       (bb_clock_out ),
        .trigger_bb         (trigger_bb   ),
        .glitchclk          (glitchclk    )
    );

endmodule
`default_nettype wire
