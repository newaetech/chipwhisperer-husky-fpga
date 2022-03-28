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

module sad #(
    // Note: pREF_SAMPLES * pBITS_PER_SAMPLE / 8 must not exceed 2**pBYTECNT_SIZE
    // FIFO allows up to 1024 pREF_SAMPLES and 12 pBITS_PER_SAMPLE; if either is
    // exceeded, the FIFO must be updated in Vivado.
    parameter pBYTECNT_SIZE = 7,
    parameter pREF_SAMPLES = 8, 
    parameter pBITS_PER_SAMPLE = 12
)(
    input wire          reset,

    //ADC Sample Input
    input wire [11:0]   adc_datain,
    input wire          adc_sampleclk,
    input wire          arm_i,

    //USB register interface
    input wire          clk_usb,
    input  wire [7:0]   reg_address,  // Address of register
    input  wire [pBYTECNT_SIZE-1:0]  reg_bytecnt,  // Current byte count
    input  wire [7:0]   reg_datai,    // Data to write
    output reg  [7:0]   reg_datao,    // Data to read
    input  wire         reg_read,     // Read flag
    input  wire         reg_write,    // Write flag

    output reg          trigger
);

    wire [11:0] fifo_out;
    reg  fifo_wr;
    reg  fifo_rd;
    wire fifo_full;
    wire fifo_empty;
    wire fifo_almost_empty;
    wire fifo_overflow;
    wire fifo_underflow;

    reg [pREF_SAMPLES*pBITS_PER_SAMPLE-1:0] refsamples;
    reg [31:0] threshold; // must be wide enough so it doesn't overflow (must hold addition of pREF_SAMPLES numbers that are each pBITS_PER_SAMPLE bits wide)
    reg [6:0] counter; // must be wide enough to count to pREF_SAMPLES-1
    reg [6:0] counter_counter [0:pREF_SAMPLES-1]; // must be wide enough to count to pREF_SAMPLES-1

    // register reads:
    always @(*) begin
        if (reg_read) begin
            case (reg_address)
                `SAD_REFERENCE: reg_datao = refsamples[reg_bytecnt*8 +: 8];
                `SAD_THRESHOLD: reg_datao = threshold[reg_bytecnt*8 +: 8];
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
        end 
        else if (reg_write) begin
            case (reg_address)
                `SAD_REFERENCE: refsamples[reg_bytecnt*8 +: 8] <= reg_datai;
                `SAD_THRESHOLD: threshold[reg_bytecnt*8 +: 8] <= reg_datai;
                default: ;
            endcase
        end
    end

    // TODO: fill in blurb to describe the high-level approach here (since concept is simple
    // but might be hard to quickly grok from the code)

    reg counter_active [0:pREF_SAMPLES-1];
    reg use_ref_samples [0:pREF_SAMPLES-1];
    reg individual_trigger [0:pREF_SAMPLES-1];
    // TODO: these need to be wider, since we're adding many pBITS_PER_SAMPLE-wide numbers...
    reg [31:0] sad_counter [0:pREF_SAMPLES-1];
    reg [31:0] next_sad_counter [0:pREF_SAMPLES-1];

    wire [11:0] minusref = refsamples[counter_counter[0]*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE];

    // instantiate counters and do most of the heavy lifting:
    genvar i;
    generate 
        for (i = 0; i < pREF_SAMPLES; i = i + 1) begin: gen_counter_registers
            always @(posedge adc_sampleclk) begin
                if (reset) 
                    sad_counter[i] <= 0;
                else if (counter_active[i]) begin
                    if (use_ref_samples[i]) begin
                        if (adc_datain > refsamples[counter_counter[i]*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE])
                            sad_counter[i] <= sad_counter[i] + adc_datain - refsamples[counter_counter[i]*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE];
                        else
                            sad_counter[i] <= sad_counter[i] + refsamples[counter_counter[i]*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE] - adc_datain ;
                    end

                    else begin
                        if ( (fifo_out   > refsamples[counter_counter[i]*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE]) && 
                             (adc_datain > refsamples[counter_counter[i]*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE]) )
                            sad_counter[i] <= sad_counter[i] + adc_datain - fifo_out;
                        else if ( (fifo_out   <= refsamples[counter_counter[i]*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE]) && 
                                  (adc_datain <= refsamples[counter_counter[i]*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE]) )
                            sad_counter[i] <= sad_counter[i] - adc_datain + fifo_out;
                        else if ( (fifo_out   >  refsamples[counter_counter[i]*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE]) && 
                                  (adc_datain <= refsamples[counter_counter[i]*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE]) )
                            sad_counter[i] <= sad_counter[i] - adc_datain - fifo_out + (refsamples[counter_counter[i]*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE] *2);
                        else
                            sad_counter[i] <= sad_counter[i] + adc_datain + fifo_out - (refsamples[counter_counter[i]*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE] *2);
                    end

               end
            end


            /*
            always @(posedge adc_sampleclk) begin
                if (use_ref_samples[i])
                    next_sad_counter[i] <= sad_counter[i] + adc_datain - refsamples[counter_counter[i]*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE];
                else
                    next_sad_counter[i] <= sad_counter[i] + adc_datain - fifo_out;
            end
            */

            always @ (posedge adc_sampleclk) begin
                if (counter_active[i]) begin
                    if (counter_counter[i] < pREF_SAMPLES-1)
                        counter_counter[i] <= counter_counter[i] + 1;
                    else begin
                        use_ref_samples[i] <= 1'b0;
                        counter_counter[i] <= 0;
                    end
                end
                else
                    use_ref_samples[i] <= 1'b1;
            end

            always @ (posedge adc_sampleclk) begin
                if (counter_active[i] && ~use_ref_samples[i] && sad_counter[i] <= threshold)
                    individual_trigger[i] <= 1'b1;
                else
                    individual_trigger[i] <= 1'b0;
            end

        end
    endgenerate


    // FSM:
    localparam pS_IDLE = 0;
    localparam pS_INITIALIZING = 1;
    localparam pS_RUNNING = 2;
    localparam pS_FLUSH = 3;
    reg [1:0] state;

    integer c;

    always @ (posedge adc_sampleclk) begin
        if (reset) begin
            state <= pS_IDLE;
            counter <= 0;
            trigger <= 1'b0;
            fifo_wr <= 1'b0;
            fifo_rd <= 1'b0;
        end

        else begin
            case (state)

                pS_IDLE: begin
                    counter <= 0;
                    trigger <= 1'b0;
                    fifo_wr <= 1'b0;
                    fifo_rd <= 1'b0;
                    for (c = 0; c < pREF_SAMPLES; c = c + 1) begin
                        counter_active[c] <= 0;
                        counter_counter[c] <= 0;
                    end
                    if (arm_i)
                        state <= pS_INITIALIZING;
                end

                pS_INITIALIZING: begin
                    // In this state we kick off the counters, one by one.
                    fifo_wr <= 1'b1;
                    counter <= counter + 1;
                    counter_active[counter] <= 1'b1;
                    if (counter == pREF_SAMPLES-1) begin
                        state <= pS_RUNNING;
                        fifo_rd <= 1'b1;
                    end
                end

                pS_RUNNING: begin
                    // In this state all the counters are running.
                    // When this state is entered, most counters are still "initializing";
                    // when use_ref_samples[counter] goes low, this indicates that that counter is done initializing
                    for (c = 0; c < pREF_SAMPLES; c = c + 1) begin
                        if (individual_trigger[c]) begin
                            trigger <= 1'b1;
                            fifo_wr <= 1'b0;
                            state <= pS_FLUSH;
                        end
                    end
                end

                pS_FLUSH: begin
                    // empty FIFO so we're ready for the next round
                    if (fifo_almost_empty) begin
                        fifo_rd <= 1'b0;
                        state <= pS_IDLE;
                    end
                end

            endcase
        end
    end


    // TODO: add FIFO error state detection


    `ifdef NOFIFO
       //for clean iverilog compilation

    `else
       sad_fifo U_fifo(
          .clk          (adc_sampleclk),
          .rst          (reset),
          .din          (adc_datain),
          .wr_en        (fifo_wr),
          .rd_en        (fifo_rd),
          .dout         (fifo_out),
          .full         (fifo_full),
          .empty        (fifo_empty),
          .almost_empty (fifo_almost_empty),
          .overflow     (fifo_overflow),
          .underflow    (fifo_underflow)
       );

   `endif

    // strictly for easier debugging:
    wire state_idle = (state == pS_IDLE);
    wire state_initializing = (state == pS_INITIALIZING);
    wire state_running = (state == pS_RUNNING);
    wire state_flush = (state == pS_FLUSH);

    // for debug; constant width so it doesn't disappear from gtkwave when changing pBITS_PER_SAMPLE:
    wire [11:0] refsample0 = refsamples[0*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE];
    wire [11:0] refsample1 = refsamples[1*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE];
    wire [11:0] refsample2 = refsamples[2*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE];
    wire [11:0] refsample3 = refsamples[3*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE];

    wire [31:0] sad_counter0 = sad_counter[0];
    wire [31:0] sad_counter1 = sad_counter[1];
    wire [31:0] sad_counter2 = sad_counter[2];
    wire [31:0] sad_counter3 = sad_counter[3];
    wire [31:0] sad_counter4 = sad_counter[4];
    wire [31:0] sad_counter5 = sad_counter[5];
    wire [31:0] sad_counter6 = sad_counter[6];
    wire [31:0] sad_counter7 = sad_counter[7];

    wire [6:0] counter_counter0 = counter_counter[0];
    wire [6:0] counter_counter1 = counter_counter[1];
    wire [6:0] counter_counter2 = counter_counter[2];
    wire [6:0] counter_counter3 = counter_counter[3];

    wire [7:0] use_ref_samples_debug =  {use_ref_samples[7],
                                         use_ref_samples[6],
                                         use_ref_samples[5],
                                         use_ref_samples[4],
                                         use_ref_samples[3],
                                         use_ref_samples[2],
                                         use_ref_samples[1],
                                         use_ref_samples[0]};
    wire [7:0] counter_active_debug  =  {counter_active[7],
                                         counter_active[6],
                                         counter_active[5],
                                         counter_active[4],
                                         counter_active[3],
                                         counter_active[2],
                                         counter_active[1],
                                         counter_active[0]};
    wire [7:0] individual_trigger_debug  =  {individual_trigger[7],
                                             individual_trigger[6],
                                             individual_trigger[5],
                                             individual_trigger[4],
                                             individual_trigger[3],
                                             individual_trigger[2],
                                             individual_trigger[1],
                                             individual_trigger[0]};


endmodule
`default_nettype wire
