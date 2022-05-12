`include "includes.v"
`timescale 1 ns / 1 ps
`default_nettype none
/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more
details, or the codebase at http://www.chipwhisperer.com

Copyright (c) 2022, NewAE Technology Inc. All rights reserved.
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

module sad_wrapper #(  
    parameter pBYTECNT_SIZE = 7,
    parameter pREF_SAMPLES = 8, 
    parameter pBITS_PER_SAMPLE = 12
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

    input wire [11:0]   adc_datain,
    input wire          arm_i,
    output wire         trigger
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

   wire [7:0] read_data_sad;
   always @(posedge clk_usb) read_data <= read_data_sad;

   assign USB_Data = cmdfifo_isout ? cmdfifo_dout : 8'bZ;
   assign cmdfifo_din = USB_Data;

   always @(posedge clk_adc)
       adc_datain_r <= adc_datain;

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


sad #(
    .pBYTECNT_SIZE      (7),
    .pREF_SAMPLES       (pREF_SAMPLES),
    .pBITS_PER_SAMPLE   (pBITS_PER_SAMPLE)
) U_big_dut (
    .reset              (reset),
    .adc_datain         (adc_datain_r[pBITS_PER_SAMPLE-1:0]),
    .adc_sampleclk      (clk_adc),
    .arm_i              (arm_i),
    .active             (1'b1),
    .clk_usb            (clk_usb),
    .reg_address        (reg_address),
    .reg_bytecnt        (reg_bytecnt),
    .reg_datai          (write_data),
    .reg_datao          (read_data_sad),
    .reg_read           (reg_read),
    .reg_write          (reg_write),
    .ext_trigger        (1'b0),
    .trigger            (trigger)
);

/* instantiate alongside known-working area-optimized version for debug:
slowsad #(
    .pBYTECNT_SIZE      (7),
    .pREF_SAMPLES       (pREF_SAMPLES),
    .pBITS_PER_SAMPLE   (pBITS_PER_SAMPLE)
) U_slow_dut (
    .reset              (reset),
    .adc_datain         (adc_datain_r[pBITS_PER_SAMPLE-1:0]),
    .adc_sampleclk      (clk_adc),
    .arm_i              (arm_i),
    .active             (1'b1),
    .clk_usb            (clk_usb),
    .reg_address        (reg_address),
    .reg_bytecnt        (reg_bytecnt),
    .reg_datai          (write_data),
    .reg_datao          (read_data_sad),
    .reg_read           (reg_read),
    .reg_write          (reg_write),
    .ext_trigger        (1'b0),
    .trigger            (trigger)
);
*/



endmodule
`default_nettype wire
