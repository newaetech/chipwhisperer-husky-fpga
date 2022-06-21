`timescale 1ns / 1ps
`default_nettype none
`include "includes.v"
/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more
details, or the codebase at http://www.chipwhisperer.com

Copyright (c) 2012-2022, NewAE Technology Inc. All rights reserved.
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
    input  wire                         ADC_clk_feedback, // Clock from ADC (used for sampling)

    output wire                         ADC_clk_sample // Clock to System compensates for wire delay of ADC clock
);

/* Note: this is a rather useless module, but it exists because if we move the
* simple assignments up to openadc_interface.v (or do away with them entirely
* by renaming the signals appropriately, then the Xilinx fast FIFO doesn't
* simulate properly with iverilog (its empty flag never goes low).
*
*   ¯\_(ツ)_/¯
*
*/

    assign ADC_clk_sample = ADC_clk_feedback;

endmodule
`default_nettype wire
