`include "includes.v"
`timescale 1 ns / 1 ps
`default_nettype none

/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more
details, or the codebase at http://www.chipwhisperer.com

Copyright (c) 2024, NewAE Technology Inc. All rights reserved.
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

module sad_single_counter #(
    // IMPORTANT NOTE! Not intended for actual use! Just to demonstrate the
    // limits of computing SAD across all reference samples in a single clock
    // cycle.  As such, some bits were intentionally left out (i.e. using
    // xadc_error, armed_and_ready, etc...).
    parameter pBYTECNT_SIZE = 7,
    parameter pREF_SAMPLES = 32, 
    parameter pBITS_PER_SAMPLE = 8,
    parameter pSAD_COUNTER_WIDTH = 16
)(
    input wire          reset,
    input wire          xadc_error,

    //ADC Sample Input
    input wire [pBITS_PER_SAMPLE-1:0] adc_datain,
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

    // verilator lint_off UNUSED
    input  wire         ext_trigger,  // debug only
    input  wire         io4,  // debug only
    // verilator lint_on UNUSED
    output reg          trigger
);

    reg [pREF_SAMPLES*pBITS_PER_SAMPLE-1:0] refsamples;
    reg [pSAD_COUNTER_WIDTH-1:0] threshold;

    reg [pSAD_COUNTER_WIDTH-1:0] sad_counter;
    reg [pSAD_COUNTER_WIDTH-1:0] sad_counter_r;

    wire [pBITS_PER_SAMPLE-1:0] refsample [0:pREF_SAMPLES-1];
    reg [pBITS_PER_SAMPLE-1:0] adc_datain_rpr, adc_datain_rmr; // sign extend
    reg [pBITS_PER_SAMPLE-1:0] adc_datain_r [0:pREF_SAMPLES-1];

    wire [31:0] wide_threshold_reg = {{(32-pSAD_COUNTER_WIDTH){1'b0}}, threshold}; // having a variable-width register isn't very convenient for Python
    wire [15:0] ref_samples = pREF_SAMPLES;
    reg [7:0] refbase;

    // These are a property of this module; used here to make sure Python
    // knows what it's talking to, in case there may be different SAD modules
    // used in different targets or builds.
    // Format: 2 MSB = version code (00: sad.v, 01: sad_x2_slowclock.v)
    //         6 LSB = trigger latency
    //wire [7:0] version_bits = 8'hFF; // not valid, but ok since nobody should actually use this
    wire [7:0] version_bits = {2'b00, 6'd08};

    // register reads:
    always @(*) begin
        if (reg_read) begin
            case (reg_address)
                `SAD_REFERENCE: reg_datao = refsamples[{refbase, reg_bytecnt}*8 +: 8];
                `SAD_THRESHOLD: reg_datao = wide_threshold_reg[reg_bytecnt*8 +: 8];
                `SAD_BITS_PER_SAMPLE: reg_datao = pBITS_PER_SAMPLE;
                `SAD_REF_SAMPLES: reg_datao = ref_samples[reg_bytecnt*8 +: 8];
                `SAD_COUNTER_WIDTH: reg_datao = pSAD_COUNTER_WIDTH;
                `SAD_VERSION: reg_datao = version_bits;
                default: reg_datao = 0;
            endcase
        end
        else
            reg_datao = 0;
    end

    // register writes:
    always @(posedge clk_usb) begin
        if (reset) begin
            refsamples <= 0;
            threshold <= 0;
            refbase <= 0;
        end 
        else begin
            if (reg_write) begin
                case (reg_address)
                    `SAD_REFERENCE: refsamples[{refbase, reg_bytecnt}*8 +: 8] <= reg_datai;
                    `SAD_THRESHOLD: threshold[reg_bytecnt*8 +: 8] <= reg_datai;
                    `SAD_REFERENCE_BASE: refbase <= reg_datai;
                    default: ;
                endcase
            end
        end
    end

    genvar i;
    generate 
        for (i = 0; i < pREF_SAMPLES; i = i + 1) begin: gen_sad_counters
            assign refsample[i] =  refsamples[i*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE];

            always @(posedge adc_sampleclk) begin
                if (i == 0)
                    adc_datain_r[i] <=  adc_datain;
                else
                    adc_datain_r[i] <=  adc_datain_r[i-1];
            end


        end
    endgenerate

    integer j;
    always @(*) begin
        sad_counter = 0;
        for (j = 0; j < pREF_SAMPLES; j = j + 1)
            sad_counter = sad_counter + abs(adc_datain_r[pREF_SAMPLES-j-1], refsample[j]);
    end

    always @(posedge adc_sampleclk) begin
        sad_counter_r <= sad_counter;
        // Note this will almost certainly trigger falsely when starting up;
        // leaving as-in since this is just proof-of-concept. To prevent false
        // triggers, would need something like the ready2trigger logic that
        // our other sad implementations use.
        if (sad_counter_r <= threshold)
            trigger <= 1'b1;
        else
            trigger <= 1'b0;
    end

    function [pBITS_PER_SAMPLE-1:0] abs;
        input [pBITS_PER_SAMPLE-1:0] op1, op2;
        if (op1 > op2)
            abs = op1 - op2;
        else
            abs = op2 - op1;
    endfunction

    // for debug only:
    // verilator lint_off UNUSED
    // verilator lint_off WIDTH
    wire [pBITS_PER_SAMPLE-1:0] refsample0 = refsample[0];
    wire [pBITS_PER_SAMPLE-1:0] refsample1 = refsample[1];
    wire [pBITS_PER_SAMPLE-1:0] refsample2 = refsample[2];
    wire [pBITS_PER_SAMPLE-1:0] refsample3 = refsample[3];

    wire [pSAD_COUNTER_WIDTH-1:0] sad_counter0 = abs(adc_datain_r[0], refsample[0]);
    wire [pSAD_COUNTER_WIDTH-1:0] sad_counter1 = abs(adc_datain_r[1], refsample[1]);
    wire [pSAD_COUNTER_WIDTH-1:0] sad_counter2 = abs(adc_datain_r[2], refsample[2]);
    wire [pSAD_COUNTER_WIDTH-1:0] sad_counter3 = abs(adc_datain_r[3], refsample[3]);

    // verilator lint_on UNUSED
    // verilator lint_on WIDTH

endmodule
`default_nettype wire
