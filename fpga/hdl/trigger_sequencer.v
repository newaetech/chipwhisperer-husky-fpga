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

module trigger_sequencer #(
    parameter                                           pNUM_TRIGGERS = 4,
    parameter                                           pCOUNTER_WIDTH = 16
)(
    input  wire                                         adc_clk,

    input  wire                                         armed_and_ready,
    input  wire                                         I_bypass,
    input  wire [pNUM_TRIGGERS-1:0]                     I_trigger,
    input  wire [(pNUM_TRIGGERS-1)*pCOUNTER_WIDTH-1:0]  I_min_wait,
    input  wire [(pNUM_TRIGGERS-1)*pCOUNTER_WIDTH-1:0]  I_max_wait,
    input  wire [3:0]                                   I_last_trigger,         // when using fewer than pNUM_TRIGGERS
    output wire                                         O_trigger,
    output reg  [pNUM_TRIGGERS-1:0]                     O_active_trigger,       // indicates which trigger we're waiting for
    output wire [7:0]                                   debug,
    output wire [7:0]                                   debug2,
    input  wire                                         sad_active              // debug only
);

    localparam pTRIGGER_WIDTH = (pNUM_TRIGGERS ==  2)? 1 :
                                (pNUM_TRIGGERS <=  4)? 2 :
                                (pNUM_TRIGGERS <=  8)? 3 :
                                (pNUM_TRIGGERS <= 16)? 4 : 0;

    wire [pCOUNTER_WIDTH-1:0] min_wait [0:pNUM_TRIGGERS-2];
    wire [pCOUNTER_WIDTH-1:0] max_wait [0:pNUM_TRIGGERS-2];
    reg  [pCOUNTER_WIDTH-1:0] next_min_wait;
    reg  [pCOUNTER_WIDTH-1:0] next_max_wait;

    genvar i;
    generate 
        for (i = 0; i < pNUM_TRIGGERS-1; i = i + 1) begin
            assign min_wait[i] = I_min_wait[i*pCOUNTER_WIDTH +: pCOUNTER_WIDTH];
            assign max_wait[i] = I_max_wait[i*pCOUNTER_WIDTH +: pCOUNTER_WIDTH];
        end
    endgenerate

    reg [pNUM_TRIGGERS-1:0] trigger_r;
    reg [pNUM_TRIGGERS-1:0] trigger_r2;
    reg [pCOUNTER_WIDTH-1:0] counter;
    reg [pTRIGGER_WIDTH-1:0] slot;
    reg incr_index;
    reg reset_counter;
    reg sequence_trigger;
    reg sequence_trigger_reg;
    reg too_late;
    reg too_early;

    reg [1:0] state, next_state;
    localparam pS_IDLE = 0;
    localparam pS_WAIT_FIRST_TRIGGER = 1;
    localparam pS_WAIT_NEXT_TRIGGER = 2;

    assign O_trigger = (I_bypass)? I_trigger[0] : sequence_trigger_reg;

    //assign debug = {armed_and_ready, state, I_trigger[1:0], slot[1:0], O_trigger};
    assign debug = {armed_and_ready, state, I_trigger[1:0], too_early, slot, O_trigger};

    //assign debug2 = {state, sad_active, too_early, too_late, I_trigger[2:0]};
    assign debug2 = {state, sad_active, too_early, too_late, slot, I_trigger[1:0]};

    wire sequencer_enabled = armed_and_ready && ~I_bypass;

    always @(*) begin
        next_state = pS_IDLE;
        incr_index = 0;
        reset_counter = 0;
        sequence_trigger = 0;
        too_late = 0;
        too_early = 0;

        case (state)

            pS_IDLE: begin
                if (sequencer_enabled) 
                    next_state = pS_WAIT_FIRST_TRIGGER;
                else
                    next_state = pS_IDLE;
            end

            pS_WAIT_FIRST_TRIGGER: begin
                if (~sequencer_enabled)
                    next_state = pS_IDLE;
                else if (trigger_r[0] && ~trigger_r2[0]) begin
                    reset_counter = 1;
                    incr_index = 1;
                    next_state = pS_WAIT_NEXT_TRIGGER;
                end
                else
                    next_state = pS_WAIT_FIRST_TRIGGER;
            end

            pS_WAIT_NEXT_TRIGGER: begin
                if (~sequencer_enabled)
                    next_state = pS_IDLE;
                else if (trigger_r[slot] && ~trigger_r2[slot]) begin
                    if (counter >= next_min_wait) begin
                        // we don't check max_trigger here  because that's handled later
                        if (slot == I_last_trigger) begin
                            sequence_trigger = 1'b1;
                            next_state = pS_IDLE;
                        end
                        else begin
                            next_state = pS_WAIT_NEXT_TRIGGER;
                            reset_counter = 1;
                            incr_index = 1;
                        end
                    end
                    else begin
                        too_early = 1; // for debug only
                        //next_state = pS_IDLE; // give up now?
                        next_state = pS_WAIT_NEXT_TRIGGER; // no, keep waiting!
                    end
                end
                else if ((next_max_wait > 0) && (counter == next_max_wait)) begin
                    too_late = 1;
                    next_state = pS_IDLE;
                end
                else
                    next_state = pS_WAIT_NEXT_TRIGGER;
            end

        endcase
    end


    always @(posedge adc_clk) begin
        state <= next_state;
        sequence_trigger_reg <= sequence_trigger;
        trigger_r <= I_trigger;
        trigger_r2 <= trigger_r;
        if (I_bypass)
            O_active_trigger <= {pNUM_TRIGGERS{1'b1}}; // ensure no trigger gets blocked
        else begin
            O_active_trigger <= 0;
            O_active_trigger[slot] <= 1'b1;
        end
        if (state == pS_IDLE) begin
            slot <= 0;
            next_min_wait <= min_wait[0];
            next_max_wait <= max_wait[0];
        end
        else if (incr_index) begin
            slot <= slot + 1;
            next_min_wait <= min_wait[slot]; // note this doesn't get the incremented slot!
            next_max_wait <= max_wait[slot];
        end

        if (reset_counter)
            counter <= 1;
        else if (state == pS_WAIT_NEXT_TRIGGER)
            counter <= counter + 1;
    end


    // debug only:
    wire [pCOUNTER_WIDTH-1:0] min_wait0 = min_wait[0];
    wire [pCOUNTER_WIDTH-1:0] min_wait1 = min_wait[1];
    wire [pCOUNTER_WIDTH-1:0] min_wait2 = min_wait[2];

    wire [pCOUNTER_WIDTH-1:0] max_wait0 = max_wait[0];
    wire [pCOUNTER_WIDTH-1:0] max_wait1 = max_wait[1];
    wire [pCOUNTER_WIDTH-1:0] max_wait2 = max_wait[2];



endmodule
`default_nettype wire

