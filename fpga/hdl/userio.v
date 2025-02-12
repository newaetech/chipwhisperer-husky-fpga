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
   parameter pWIDTH = 8
)(
   input  wire                          usb_clk,
   inout  wire [pWIDTH-1:0]             userio_d,
   input  wire [pWIDTH-1:0]             I_userio_drive_data,
   input  wire [pWIDTH-1:0]             I_userio_cwdriven,
   input  wire                          I_userio_fpga_debug,
   input  wire [pWIDTH-1:0]             I_userio_debug_data,
   input  wire                          userio_clk
);

   genvar i;

   generate
      for (i = 0; i < pWIDTH; i = i + 1) begin
         assign userio_d[i] = (~I_userio_cwdriven[i])? 1'bz : 
                              (I_userio_fpga_debug)?   I_userio_debug_data[i] : I_userio_drive_data[i];
      end
   endgenerate

   `ifndef __ICARUS__
      PULLUP USERIO_PULLUP[pWIDTH-1:0] (.O(userio_d));
   `endif


endmodule

`default_nettype wire
