`timescale 1 ns / 1 ps
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

module trigger_sequencer_cocowrapper #(
    parameter pNUM_TRIGGERS = 4,
    parameter pCOUNTER_WIDTH = 16
)(
    // DUT:
    input  wire                                         clk,
    input  wire                                         armed_and_ready,
    input  wire                                         I_bypass,
    input  wire [pNUM_TRIGGERS-1:0]                     I_trigger,
    input  wire [(pNUM_TRIGGERS-1)*pCOUNTER_WIDTH-1:0]  I_min_wait,
    input  wire [(pNUM_TRIGGERS-1)*pCOUNTER_WIDTH-1:0]  I_max_wait,
    input  wire [3:0]                                   I_last_trigger,
    output wire                                         O_trigger,

    // testbench stuff:
    input  wire [31:0]                                  errors,
    input  wire [24*8-1:0]                              test_phase,
    input  wire [7:0]                                   trigger_allowed_q,
    input  wire                                         expected_trigger,
    input  wire [7:0]                                   expected_slot,
    output reg                                          trigger_error
);


   parameter pDUMP = 0;
   //parameter pNUM_TRIGGERS = 4;
   //parameter pCOUNTER_WIDTH = 16;

   initial begin
      if (pDUMP) begin
          $dumpfile("results/trigger_sequencer.fst");
          $dumpvars(0, trigger_sequencer_cocowrapper);
      end
   end

   reg [31:0] xilinx_mismatch_rcount = 32'b0;
   reg [31:0] xilinx_mismatch_wcount = 32'b0;
   reg [7:0] expected_slot_r;

   always @(posedge clk) begin
       if (expected_trigger != O_trigger)
           trigger_error <= 1'b1;
       else
           trigger_error <= 1'b0;
       expected_slot_r <= expected_slot;
   end

   wire slot_mismatch = (expected_slot_r != U_trigger_sequencer.slot);

    trigger_sequencer #(
        .pNUM_TRIGGERS                  (pNUM_TRIGGERS),
        .pCOUNTER_WIDTH                 (pCOUNTER_WIDTH)
    ) U_trigger_sequencer (
        .adc_clk                        (clk             ),
        .armed_and_ready                (armed_and_ready ),
        .I_bypass                       (I_bypass        ),
        .I_trigger                      (I_trigger       ),
        .I_min_wait                     (I_min_wait      ),
        .I_max_wait                     (I_max_wait      ),
        .I_last_trigger                 (I_last_trigger  ),
        .O_trigger                      (O_trigger       )
    );

endmodule
`default_nettype wire
