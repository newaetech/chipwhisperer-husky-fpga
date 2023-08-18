`timescale 1ns / 1ps
`default_nettype none
/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more
details, or the codebase at http://www.chipwhisperer.com

Copyright (c) 2023, NewAE Technology Inc. All rights reserved.
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

module trigger_chooser (
    input  wire [15:0]  I_trigsrc,
    input  wire [7:0]   I_trigmod, // only 2:0 is used, but 7:0 makes for easier indexing/setting from Python

    input  wire         auxio,
    input  wire         trigger_nrst_i,
    input  wire         trigger_io1_i,
    input  wire         trigger_io2_i,
    input  wire         trigger_io3_i,
    input  wire         trigger_io4_i,
    input  wire [7:0]   userio_d,

    input  wire         trigger_advio_i,
    input  wire         trigger_sad_i,
    input  wire         trigger_decodedio_i,
    input  wire         trigger_trace_i,
    input  wire         trigger_adc_i,
    input  wire         trigger_edge_i,

    output wire         O_decodeio_active,
    output wire         O_trace_active,
    output wire         O_sad_active,
    output wire         O_edge_trigger_active,
    output wire         O_adc_trigger_active,
    output wire         O_trace_trigger_in_use,
    output wire         O_trigger,
    output wire         trigger_ext,    // for edge/UART
    input  wire         I_active_trigger
);

// All this used to be in reg_chipwhisperer.v; moved here when added sequenced triggers.

    wire trigger_and;
    wire trigger_or;

    assign trigger_and = ((I_trigsrc[0]  & auxio)          | ~I_trigsrc[0]) &
                         ((I_trigsrc[1]  & trigger_nrst_i) | ~I_trigsrc[1]) &
                         ((I_trigsrc[2]  & trigger_io1_i)  | ~I_trigsrc[2]) &
                         ((I_trigsrc[3]  & trigger_io2_i)  | ~I_trigsrc[3]) &
                         ((I_trigsrc[4]  & trigger_io3_i)  | ~I_trigsrc[4]) &
                         ((I_trigsrc[5]  & trigger_io4_i)  | ~I_trigsrc[5]) &
                         ((I_trigsrc[8]  & userio_d[0])    | ~I_trigsrc[8]) &
                         ((I_trigsrc[9]  & userio_d[1])    | ~I_trigsrc[9]) &
                         ((I_trigsrc[10] & userio_d[2])    | ~I_trigsrc[10]) &
                         ((I_trigsrc[11] & userio_d[3])    | ~I_trigsrc[11]) &
                         ((I_trigsrc[12] & userio_d[4])    | ~I_trigsrc[12]) &
                         ((I_trigsrc[13] & userio_d[5])    | ~I_trigsrc[13]) &
                         ((I_trigsrc[14] & userio_d[6])    | ~I_trigsrc[14]) &
                         ((I_trigsrc[15] & userio_d[7])    | ~I_trigsrc[15]);

    assign trigger_or  = (I_trigsrc[0]  & auxio)          |
                         (I_trigsrc[1]  & trigger_nrst_i) |
                         (I_trigsrc[2]  & trigger_io1_i)  |
                         (I_trigsrc[3]  & trigger_io2_i)  |
                         (I_trigsrc[4]  & trigger_io3_i)  |
                         (I_trigsrc[5]  & trigger_io4_i)  |
                         (I_trigsrc[8]  & userio_d[0])    |
                         (I_trigsrc[9]  & userio_d[1])    |
                         (I_trigsrc[10] & userio_d[2])    |
                         (I_trigsrc[11] & userio_d[3])    |
                         (I_trigsrc[12] & userio_d[4])    |
                         (I_trigsrc[13] & userio_d[5])    |
                         (I_trigsrc[14] & userio_d[6])    |
                         (I_trigsrc[15] & userio_d[7]);

    assign trigger_ext =  (I_trigsrc[7:6] == 2'b00) ? trigger_or :
                          (I_trigsrc[7:6] == 2'b01) ? trigger_and : 
                          (I_trigsrc[7:6] == 2'b10) ? (~trigger_and) :
                          1'b0;

    assign O_trigger = (I_trigmod[2:0] == 3'b000) ? trigger_ext :
                       (I_trigmod[2:0] == 3'b001) ? trigger_advio_i : 
                       (I_trigmod[2:0] == 3'b010) ? trigger_sad_i :
                       (I_trigmod[2:0] == 3'b011) ? trigger_decodedio_i :
                       (I_trigmod[2:0] == 3'b100) ? trigger_trace_i :
                       (I_trigmod[2:0] == 3'b101) ? trigger_adc_i :
                       (I_trigmod[2:0] == 3'b110) ? trigger_edge_i : 1'b0;

   assign O_decodeio_active       = I_active_trigger && (I_trigmod[2:0] == 3'b011);
   assign O_trace_active          = I_active_trigger && (I_trigmod[2:0] == 3'b100);
   assign O_sad_active            = I_active_trigger && (I_trigmod[2:0] == 3'b010);
   assign O_edge_trigger_active   = I_active_trigger && (I_trigmod[2:0] == 3'b110);
   assign O_adc_trigger_active    = I_active_trigger && (I_trigmod[2:0] == 3'b101);

   // trace is different because it can be used standalone (e.g. not for triggering), 
   // so we need to know if any trigger is using trace:
   assign O_trace_trigger_in_use  = (I_trigmod[2:0] == 3'b100);


endmodule
`default_nettype wire

