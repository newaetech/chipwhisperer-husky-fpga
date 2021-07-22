`default_nettype none
`timescale 1ns / 1ps
/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more
details, or the codebase at http://www.chipwhisperer.com

Copyright (c) 2019-2021, NewAE Technology Inc. All rights reserved.
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

module usb_reg_main #(
   parameter pBYTECNT_SIZE = 7
)(
   input  wire         clk_usb,
   input  wire         reset,

   /* Interface to ChipWhisperer-Lite USB Chip */
   input  wire [7:0]   cwusb_din,
   output wire [7:0]   cwusb_dout,
   output wire         cwusb_isout,
   input  wire [7:0]   cwusb_addr,
   input  wire         cwusb_rdn,
   input  wire         cwusb_wrn,
   input  wire         cwusb_cen,
   input  wire         cwusb_alen,

 /* Interface to registers */
   input  wire         fast_fifo_read,
   output reg  [7:0]   reg_address,  // Address of register
   output reg  [pBYTECNT_SIZE-1:0]  reg_bytecnt,  // Current byte count
   output reg  [7:0]   reg_datao,    // Data to write
   input  wire [7:0]   reg_datai,    // Data to read
   output wire         reg_read,     // Read flag. One clock cycle AFTER this flag is high
                                     // valid data must be present on the reg_datai bus
   output reg          reg_write     // Write flag. When high on rising edge valid data is
                                     // present on reg_datao
);


   reg isoutreg, isoutregdly;
   reg cwusb_wrn_rs, cwusb_wrn_rs_dly;
   reg cwusb_alen_r;
   reg reg_write_dly;
   reg drive_data_out;
   reg fast_fifo_read_r;

   // note: could possibly be simplified, and delays reduced?
   always @(posedge clk_usb) begin
      isoutreg <= ~cwusb_rdn;
      isoutregdly <= isoutreg;

      cwusb_alen_r <= cwusb_alen;

      cwusb_wrn_rs <= cwusb_wrn;
      cwusb_wrn_rs_dly <= cwusb_wrn_rs;
      reg_write <= cwusb_wrn_rs & ~cwusb_wrn_rs_dly;
   end


   assign reg_read = isoutreg;
   assign cwusb_dout = reg_datai;

   //Don't immediatly turn off output drivers
   assign cwusb_isout = isoutreg | isoutregdly | (drive_data_out & cwusb_wrn);

   // for fast FIFO reading, we need to talk hold of the data bus; we only
   // give it up when we see a write start:
   always @(posedge clk_usb) begin
      fast_fifo_read_r <= fast_fifo_read;
      reg_address <= cwusb_addr;

      if (~cwusb_cen & ~cwusb_wrn_rs)
         reg_datao <= cwusb_din;

      if (~cwusb_wrn)
         drive_data_out <= 1'b0;
      else if (fast_fifo_read & ~fast_fifo_read_r)
         drive_data_out <= 1'b1;
   end

   // Byte count block. We need to increment after a read or after a write
   always @(posedge clk_usb) reg_write_dly <= reg_write;

   always @(posedge clk_usb) begin
      if (reset)
         reg_bytecnt <= 0;
      else if (~cwusb_alen_r) begin
         reg_bytecnt <= 0;
      end else if ((isoutregdly & !isoutreg) || (reg_write_dly) ) begin
         //roll-over is allowed (only access to use it is FIFO read, where we
         //only look at reg_bytecnt % 4)
         reg_bytecnt <= reg_bytecnt + 1;
      end
   end


   `ifdef ILA_USB
       ila_usb U_ila_usb (
	    .clk            (clk_usb),      // input wire clk
	    .probe0         (cwusb_din),    // input wire [7:0]  probe0  
	    .probe1         (cwusb_dout),   // input wire [7:0]  probe1 
	    .probe2         (cwusb_isout),  // input wire [0:0]  probe2 
	    .probe3         (cwusb_addr),   // input wire [7:0]  probe3 
	    .probe4         (cwusb_rdn),    // input wire [0:0]  probe4 
	    .probe5         (cwusb_wrn),    // input wire [0:0]  probe5 
	    .probe6         (cwusb_cen),    // input wire [0:0]  probe6 
	    .probe7         (reg_address),  // input wire [7:0]  probe7 
	    .probe8         (reg_bytecnt),  // input wire [6:0]  probe8 
	    .probe9         (reg_datao),    // input wire [7:0]  probe9
        .probe10        (reg_datai),    // input wire [7:0]  probe10
        .probe11        (reg_read),     // input wire [0:0]  probe11
        .probe12        (reg_write),    // input wire [0:0]  probe12
        .probe13        (fast_fifo_read),// input wire [0:0]  probe13
        .probe14        (drive_data_out)// input wire [0:0]  probe14
       );
   `endif

   `ifdef ILA_USB_LITE
       //wire fifo_read_address = (reg_address == `ADCREAD_ADDR);
       ila_usb_lite U_ila_usb (
	    .clk            (clk_usb),      // input wire clk
	    .probe0         (cwusb_dout),   // input wire [7:0]  probe0 
	    .probe1         (cwusb_isout),  // input wire [0:0]  probe1 
	    .probe2         (cwusb_rdn),    // input wire [0:0]  probe2 
	    .probe3         (cwusb_wrn),    // input wire [0:0]  probe3 
	    .probe4         (cwusb_cen),    // input wire [0:0]  probe4 
        .probe5         (reg_read),     // input wire [0:0]  probe5
        .probe6         (reg_write),    // input wire [0:0]  probe6
        .probe7         (fast_fifo_read),// input wire [0:0]  probe7
        .probe8         (drive_data_out),// input wire [0:0]  probe8
        //.probe9         (fifo_read_address)// input wire [0:0]  probe9
        .probe9         (reg_address)    // input wire [7:0]  probe9
       );
   `endif


endmodule

`default_nettype wire
