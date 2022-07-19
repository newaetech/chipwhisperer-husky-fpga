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

module edge_trigger #(
    parameter pBYTECNT_SIZE = 7
)(
    input wire          reset,

    input wire          trigger_in,
    input wire          adc_sampleclk,
    input wire          armed_and_ready,
    input wire          active,

    //USB register interface
    input wire          clk_usb,
    input  wire [7:0]   reg_address,  // Address of register
    input  wire [pBYTECNT_SIZE-1:0]  reg_bytecnt,  // Current byte count
    input  wire [7:0]   reg_datai,    // Data to write
    output reg  [7:0]   reg_datao,    // Data to read
    input  wire         reg_read,     // Read flag
    input  wire         reg_write,    // Write flag

    output wire         trigger
);

    reg [15:0] reg_edge_trigger_count;
    reg [15:0] edge_counter;
    reg trigger_in_r;
    reg triggered;
    reg triggered_r;
    reg running_r;

    // register reads:
    always @(*) begin
        if (reg_read) begin
            case (reg_address)
                `EDGE_TRIGGER_COUNT: reg_datao = edge_counter[reg_bytecnt*8 +: 8];
                default: reg_datao = 0;
            endcase
        end
        else
            reg_datao = 0;
    end

    // register writes:
    always @(posedge clk_usb) begin
        if (reset) begin
            reg_edge_trigger_count <= 0;
        end 
        else begin
            if (reg_write) begin
                case (reg_address)
                    `EDGE_TRIGGER_COUNT: reg_edge_trigger_count[reg_bytecnt*8 +: 8] <= reg_datai;
                    default: ;
                endcase
            end
        end
    end

    // trigger logic:
    wire running = active && armed_and_ready;
    always @(posedge adc_sampleclk) begin
        if (reset) begin
            trigger_in_r <= 1'b0;
            edge_counter <= 0;
            triggered <= 1'b0;
        end
        else begin
            trigger_in_r <= trigger_in;
            triggered_r <= triggered;
            running_r <= running;
            if (~running)
                triggered <= 1'b0;
            else begin
                if (running & ~running_r)
                    edge_counter <= 0;
                else if (~triggered) begin
                    if (trigger_in != trigger_in_r) begin
                        edge_counter <= edge_counter + 1;
                        if (edge_counter == reg_edge_trigger_count)
                            triggered <= 1'b1;
                    end
                end
            end
        end
    end

    assign trigger = triggered && ~triggered_r;


endmodule
`default_nettype wire
