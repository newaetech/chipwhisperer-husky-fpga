`include "includes.v"
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

module hw_bb_wrapper #(  
    parameter pBYTECNT_SIZE = 7,
    parameter pPATTERN_DEPTH = 256,
    parameter pSAVE_DEPTH = 64
)(
    input wire         clk_usb,
    input wire         clk_adc,
    input wire         reset,

    inout wire [7:0]    USB_Data,
    input wire [7:0]    USB_Addr,
    input wire          USB_RDn,
    input wire          USB_WRn,
    input wire          USB_CEn,
    input wire          USB_ALEn,

    input  wire         bb_data_in,
    output wire         bb_data_out,
    output wire         bb_data_drive,
    output wire         bb_clock_out,
    output wire         trigger_bb,
    input  wire         glitchclk,

    output wire         clock_out_debug,
    output wire         clock_out_normal,
    output wire [15:0]  clk_div_debug

);

   wire cmdfifo_isout;
   wire [7:0] cmdfifo_din;
   wire [7:0] cmdfifo_dout;
   wire [pBYTECNT_SIZE-1:0]  reg_bytecnt;
   wire [7:0]   write_data;
   reg  [7:0]   read_data;
   reg  [7:0]   read_data_reg;
   wire         reg_read;
   wire         reg_write;
   wire [7:0]   reg_address;
   reg [11:0] adc_datain_r;

   wire [7:0] read_data_hw_bb;

   assign USB_Data = cmdfifo_isout ? cmdfifo_dout : 8'bZ;
   assign cmdfifo_din = USB_Data;

   always @(posedge clk_usb) read_data <= read_data_hw_bb;

    usb_reg_main #(
       .pBYTECNT_SIZE    (pBYTECNT_SIZE)
    ) U_usb_reg_main (
       .clk_usb          (clk_usb), 
       .reset            (reset),
       .cwusb_din        (cmdfifo_din), 
       .cwusb_dout       (cmdfifo_dout), 
       .cwusb_rdn        (USB_RDn), 
       .cwusb_wrn        (USB_WRn),
       .cwusb_cen        (USB_CEn),
       .cwusb_alen       (USB_ALEn),
       .cwusb_addr       (USB_Addr),
       .cwusb_isout      (cmdfifo_isout), 
       .fast_fifo_read   (1'b0),
       .reg_address      (reg_address), 
       .reg_bytecnt      (reg_bytecnt), 
       .reg_datao        (write_data), 
       .reg_datai        (read_data),
       .reg_read         (reg_read), 
       .reg_write        (reg_write) 
    );

    hw_bb_trig #(
      .pBYTECNT_SIZE            (pBYTECNT_SIZE),
      .pPATTERN_DEPTH           (pPATTERN_DEPTH),
      .pSAVE_DEPTH              (pSAVE_DEPTH)
    ) U_hw_bb_trig (
      .reset                    (reset         ),
      .clk_usb                  (clk_usb       ),
      .reg_address              (reg_address   ),
      .reg_bytecnt              (reg_bytecnt   ),
      .reg_datai                (write_data    ),
      .reg_datao                (read_data_hw_bb ),
      .reg_read                 (reg_read      ),
      .reg_write                (reg_write     ),

      .clock                    (clk_adc       ),
      .data_in                  (bb_data_in    ),
      .data_out                 (bb_data_out   ),
      .data_drive               (bb_data_drive ),
      .clock_out                (bb_clock_out  ),
      .clock_out_debug          (clock_out_debug),
      .clock_out_normal         (clock_out_normal),
      .clk_div_debug            (clk_div_debug ),
      .trigger_pulse            (trigger_bb    ),

      .trigger_active           (1'b1          ),
      .glitch_in                (glitchclk     ),
      .debug                    (              )
    );   


endmodule
`default_nettype wire
