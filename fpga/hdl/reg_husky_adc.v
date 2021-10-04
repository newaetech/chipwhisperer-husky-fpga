`include "includes.v"
`timescale 1 ns / 1 ps
`default_nettype none

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

module reg_husky_adc #(
   parameter pBYTECNT_SIZE = 7
)(
   input  wire         reset_i,
   input  wire         clk_usb,
   input  wire [7:0]   reg_address,  // Address of register
   input  wire [7:0]   reg_datai,    // Data to write
   output wire [7:0]   reg_datao,    // Data to read
   input  wire         reg_read,     // Read flag
   input  wire         reg_write,    // Write flag

   output reg          ADC_RESET,
   output reg          ADC_SDATA,
   output reg          ADC_SEN,
   output reg          ADC_DFS,
   output reg          ADC_OE,
   output reg          ADC_SCLK,
   input wire          ADC_OVR_SDOUT,

   output reg  [4:0]   VMAG_D
); 

   `define CW_ADC_CTRL          60
   `define CW_VMAG_CTRL         61

   // Bit-bang access to the ADC (ADS4128) registers.
   // Focus is on simplicity.
   // Every write of the CW_ADC_CTRL register sets the outputs to the ADC as follows:
   // 
   // bit 7: ADC_RESET
   // bit 6: ADC_SEN
   // bit 5: unused
   // bit 4: ADC_SDATA
   // bit 3: ADC_DFS
   // bit 2: ~ADC_OE
   // bit 0: ADC_SCLK
   // 
   // When bit 1 is set, the value on ADC_OVR_SDOUT is shifted into the 8-bit register which 
   // can be read at the same CW_ADC_CTRL address.
   // Refer to ADS4128 data sheet for further details.
   //
   // Register write example: 
   // To write 0xAA to address 0x55, do the following sequence of writes to CW_ADC_CTRL (all values hex):
   // 41,01,00,11,10,01,00,11,10,01,00,11,10,01,00,11,10,11,10,01,00,11,10,01,00,11,10,01,00,11,10,01,00,41
   //SEN|  A7 |  A6 |  A5 |  A4 |  A3 |  A2 |  A1 |  A0 |  D7 |  D6 |  D5 |  D4 |  D3 |  D2 |  D1 |  D0 | SEN
   //
   // Register read example: 
   // To read from address 0x55, do the following sequence of writes to CW_ADC_CTRL (all values hex):
   // 41,01,00,11,10,01,00,11,10,01,00,11,10,01,00,11,10,01,02,01,02,01,02,01,02,01,02,01,02,01,02,01,02,41
   //SEN|  A7 |  A6 |  A5 |  A4 |  A3 |  A2 |  A1 |  A0 |  D7 |  D6 |  D5 |  D4 |  D3 |  D2 |  D1 |  D0 | SEN
   // Followed by reading CW_ADC_CTRL to obtain the read data byte.


   reg [7:0] reg_datao_reg;
   reg [7:0] data_reg;
   reg reg_write_r;
   assign reg_datao = reg_datao_reg;

   always @(*) begin
      if (reg_read) begin
         case (reg_address)
           `CW_ADC_CTRL: reg_datao_reg = data_reg;
           `CW_VMAG_CTRL: reg_datao_reg = VMAG_D;
           default: reg_datao_reg = 0;
         endcase
      end
      else
         reg_datao_reg = 0;
   end  

   always @(posedge clk_usb) begin
      if (reset_i) begin
         data_reg <= 8'd0;
         ADC_RESET  <= 0;
         ADC_SEN    <= 1;
         ADC_SDATA  <= 0;
         ADC_DFS    <= 0;
         ADC_OE     <= 1;
         ADC_SCLK   <= 1;
      end 
      else begin
         reg_write_r <= reg_write;
         if (reg_write && ~reg_write_r && (reg_address == `CW_ADC_CTRL)) begin
            ADC_RESET  <= reg_datai[7];
            ADC_SEN    <= reg_datai[6];
            ADC_SDATA  <= reg_datai[4];
            ADC_DFS    <= reg_datai[3];
            ADC_OE     <= ~reg_datai[2];
            ADC_SCLK   <= reg_datai[0];
            if (reg_datai[1])
               data_reg <= {data_reg[6:0], ADC_OVR_SDOUT};
         end
         else if (reg_write && (reg_address == `CW_VMAG_CTRL))
            VMAG_D <= reg_datai[4:0];
      end
   end

   `ifdef ILA_ADC
       ila_adc U_ila_adc (
	.clk            (clk_usb),      // input wire clk
	.probe0         (ADC_RESET),    // input wire [0:0]  probe0  
	.probe1         (ADC_SEN),      // input wire [0:0]  probe1 
	.probe2         (ADC_SDATA),    // input wire [0:0]  probe2 
	.probe3         (ADC_DFS),      // input wire [0:0]  probe3 
	.probe4         (ADC_OE),       // input wire [0:0]  probe4 
	.probe5         (ADC_SCLK),     // input wire [0:0]  probe5 
	.probe6         (data_reg),     // input wire [7:0]  probe6 
	.probe7         (1'b0),         // input wire [0:0]  probe7 
	.probe8         (reg_write),    // input wire [0:0]  probe8 
	.probe9         (reg_write_r),  // input wire [0:0]  probe9
        .probe10        (ADC_OVR_SDOUT) // input wire [0:0]  probe10
       );
   `endif


endmodule
`default_nettype wire
