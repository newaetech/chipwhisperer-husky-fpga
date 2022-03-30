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


/* NOTE!
* This is not functional! This shows rough modifications to the previous
* version in an attempt to make it run faster. The previous version runs at
* ~100 MHz; these modifications take it up to ~150 MHz. This is still too far
* from our target 200 MHz. This approach was optimized for low storage, but it
* looks like it's not feasible for the Husky FPGA fabric speed. It would be
* possible to make this functional by tweaking the control logic timing, but
* since this won't go fast enough for Husky, this approach is abandoned. Look
* to the next commit for a different approach which optimizes for speed
* instead.
*
* High-level idea of how this works: first, realize that we must maintain
* pREF_SAMPLES SAD counters. We use a *single* FIFO into which we push the ADC
* sample. Once a SAD counter has summed pREF_SAMPLES samples, we need to start
* substracting expired sums; since we're doing sums of *absolute* differences,
    * we have 4 cases to consider to maintain a correct SAD counter:
*       1- current sample  > reference sample and pREF_SAMPLES-old sample  > reference sample;
*       2- current sample  > reference sample and pREF_SAMPLES-old sample <= reference sample;
*       3- current sample  > reference sample and pREF_SAMPLES-old sample  > reference sample;
*       4- current sample <= reference sample and pREF_SAMPLES-old sample <= reference sample;
* This allows use to use a single pREF_SAMPLES-deep FIFO (instead of
* pREF_SAMPLES FIFOs, each pREF_SAMPLES deep). This is a significant
* area/storage optimization, especially if pREF_SAMPLES is large. However the
* 4 cases that have to be considered make timing tricky.
* One speed optimization which was tried here is to store an extra bit for
* each pREF_SAMPLES so that the pREF_SAMPLES-old sample vs reference sample
* comparison does not have to be repeated. Here we've also tried pre-computing
* everything which composes the SAD counters update value. But it's still not
* fast enough for this FPGA fabric.
* 
* Saving this for posterity in case the right application for this comes along
* later: one which needs a large pREF_SAMPLES but which doesn't need to go "too
* fast" (< 150 MHz on an Artix7).
*/

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
    input wire [pBITS_PER_SAMPLE-1:0] adc_datain,
    input wire          adc_sampleclk,
    input wire          arm_i,
    input wire          active,

    //USB register interface
    input wire          clk_usb,
    input  wire [7:0]   reg_address,  // Address of register
    input  wire [pBYTECNT_SIZE-1:0]  reg_bytecnt,  // Current byte count
    input  wire [7:0]   reg_datai,    // Data to write
    output reg  [7:0]   reg_datao,    // Data to read
    input  wire         reg_read,     // Read flag
    input  wire         reg_write,    // Write flag

    input  wire         ext_trigger,  // debug only
    output reg          trigger
);

    wire [pBITS_PER_SAMPLE-1:0] fifo_out;
    reg  [pBITS_PER_SAMPLE-1:0] fifo_out_r;
    reg  fifo_wr;
    reg  fifo_rd;
    wire fifo_full;
    wire fifo_empty;
    wire fifo_almost_empty;
    wire fifo_overflow;
    wire fifo_underflow;
    reg  fifo_overflow_sticky;
    reg  fifo_underflow_sticky;
    reg fifo_not_empty_error;
    reg  triggered;
    reg clear_status;
    reg clear_status_r;
    wire clear_status_adc;

    reg [pREF_SAMPLES*pBITS_PER_SAMPLE-1:0] refsamples;
    reg [pBITS_PER_SAMPLE-1:0] nextrefsample [0:pREF_SAMPLES-1];
    reg [31:0] threshold; // must be wide enough so it doesn't overflow (must hold addition of pREF_SAMPLES numbers that are each pBITS_PER_SAMPLE bits wide)
    reg [6:0] counter; // must be wide enough to count to pREF_SAMPLES-1
    reg [6:0] counter_counter [0:pREF_SAMPLES-1]; // must be wide enough to count to pREF_SAMPLES-1

    // register reads:
    always @(*) begin
        if (reg_read) begin
            case (reg_address)
                `SAD_REFERENCE: reg_datao = refsamples[reg_bytecnt*8 +: 8];
                `SAD_THRESHOLD: reg_datao = threshold[reg_bytecnt*8 +: 8];
                `SAD_STATUS: reg_datao = {4'b0, fifo_not_empty_error, fifo_overflow_sticky, fifo_underflow_sticky, triggered};
                `SAD_BITS_PER_SAMPLE: reg_datao = pBITS_PER_SAMPLE;
                `SAD_REF_SAMPLES: reg_datao = pREF_SAMPLES;
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
            clear_status_r <= 0;
        end 
        else begin
            clear_status_r <= clear_status;
            if (reg_write) begin
                case (reg_address)
                    `SAD_REFERENCE: refsamples[reg_bytecnt*8 +: 8] <= reg_datai;
                    `SAD_THRESHOLD: threshold[reg_bytecnt*8 +: 8] <= reg_datai;
                    default: ;
                endcase
                if (reg_address == `SAD_STATUS)
                    clear_status <= 1'b1;
                else
                    clear_status <= 1'b0;
            end
        end
    end

   cdc_pulse U_clear_status_cdc (
      .reset_i       (reset),
      .src_clk       (clk_usb),
      .src_pulse     (clear_status && ~clear_status_r),
      .dst_clk       (adc_sampleclk),
      .dst_pulse     (clear_status_adc)
   );

    always @(posedge adc_sampleclk) begin
        if (reset) begin
            triggered <= 1'b0;
            fifo_overflow_sticky <= 1'b0;
            fifo_underflow_sticky <= 1'b0;
            fifo_not_empty_error <= 1'b0;
        end
        else begin
            if (clear_status_adc) begin
                triggered <= 1'b0;
                fifo_overflow_sticky <= 1'b0;
                fifo_underflow_sticky <= 1'b0;
                fifo_not_empty_error <= 1'b0;
            end
            else begin
                if (trigger)
                    triggered <= 1'b1;
                if (fifo_overflow)
                    fifo_overflow_sticky <= 1'b1;
                if (fifo_underflow)
                    fifo_underflow_sticky <= 1'b1;
                if ((state == pS_IDLE) && ~fifo_empty)
                    fifo_not_empty_error <= 1'b1;
            end
        end
    end


    reg counter_active [0:pREF_SAMPLES-1];
    reg use_ref_samples [0:pREF_SAMPLES-1];
    reg individual_trigger [0:pREF_SAMPLES-1];
    // these need to be wider than pBITS_PER_SAMPLE since we're adding many pBITS_PER_SAMPLE-wide numbers... 
    //reg [14:0] sad_counter [0:pREF_SAMPLES-1]; // pBITS_PER_SAMPLE=8, pREF_SAMPLES=128
    reg [13:0] sad_counter [0:pREF_SAMPLES-1]; // pBITS_PER_SAMPLE=8, pREF_SAMPLES=32
    //reg [9:0] sad_counter [0:pREF_SAMPLES-1]; // pBITS_PER_SAMPLE=5, pREF_SAMPLES=32
    reg [13:0] counter_incr [0:pREF_SAMPLES-1]; // pBITS_PER_SAMPLE=8, pREF_SAMPLES=32

    reg sign [0:pREF_SAMPLES-1];
    wire [pREF_SAMPLES-1:0] allsigns = {sign[31],
                                        sign[30],
                                        sign[29],
                                        sign[28],
                                        sign[27],
                                        sign[26],
                                        sign[25],
                                        sign[24],
                                        sign[23],
                                        sign[22],
                                        sign[21],
                                        sign[20],
                                        sign[19],
                                        sign[18],
                                        sign[17],
                                        sign[16],
                                        sign[15],
                                        sign[14],
                                        sign[13],
                                        sign[12],
                                        sign[11],
                                        sign[10],
                                        sign[9],
                                        sign[8],
                                        sign[7],
                                        sign[6],
                                        sign[5],
                                        sign[4],
                                        sign[3],
                                        sign[2],
                                        sign[1],
                                        sign[0]};
    wire [pREF_SAMPLES-1:0] allsignouts;
    wire signout [0:pREF_SAMPLES-1];
    reg [1:0] nextcase [0:pREF_SAMPLES-1];

    assign signout[31] = allsignouts[31];
    assign signout[30] = allsignouts[30];
    assign signout[29] = allsignouts[29];
    assign signout[28] = allsignouts[28];
    assign signout[27] = allsignouts[27];
    assign signout[26] = allsignouts[26];
    assign signout[25] = allsignouts[25];
    assign signout[24] = allsignouts[24];
    assign signout[23] = allsignouts[23];
    assign signout[22] = allsignouts[22];
    assign signout[21] = allsignouts[21];
    assign signout[20] = allsignouts[20];
    assign signout[19] = allsignouts[19];
    assign signout[18] = allsignouts[18];
    assign signout[17] = allsignouts[17];
    assign signout[16] = allsignouts[16];
    assign signout[15] = allsignouts[15];
    assign signout[14] = allsignouts[14];
    assign signout[13] = allsignouts[13];
    assign signout[12] = allsignouts[12];
    assign signout[11] = allsignouts[11];
    assign signout[10] = allsignouts[10];
    assign signout[9] = allsignouts[9];
    assign signout[8] = allsignouts[8];
    assign signout[7] = allsignouts[7];
    assign signout[6] = allsignouts[6];
    assign signout[5] = allsignouts[5];
    assign signout[4] = allsignouts[4];
    assign signout[3] = allsignouts[3];
    assign signout[2] = allsignouts[2];
    assign signout[1] = allsignouts[1];
    assign signout[0] = allsignouts[0];

    always @(posedge adc_sampleclk)
        fifo_out_r <= fifo_out;

    // instantiate counters and do most of the heavy lifting:
    genvar i;
    generate 
        for (i = 0; i < pREF_SAMPLES; i = i + 1) begin: gen_counter_registers
            always @(posedge adc_sampleclk) begin
                if (state == pS_IDLE)
                    sad_counter[i] <= 0;
                else if (counter_active[i]) begin
                    if (use_ref_samples[i]) begin
                        //sad_counter[i] <= sad_counter[i] + nextrefsample[i] - adc_datain ;
                        if (adc_datain > nextrefsample[i]) begin
                            //sad_counter[i] <= sad_counter[i] + adc_datain - nextrefsample[i];
                            nextcase[i] <= 1;
                            sign[i] <= 1'b1;
                        end
                        else begin
                            //sad_counter[i] <= sad_counter[i] + nextrefsample[i];
                            nextcase[i] <= 0;
                            sign[i] <= 1'b0;
                        end

                        if (nextcase[i])
                            sad_counter[i] <= sad_counter[i] + adc_datain - nextrefsample[i];
                        else
                            sad_counter[i] <= sad_counter[i] + nextrefsample[i];

                    end

                    else begin
                        //sad_counter[i] <= sad_counter[i] + adc_datain - fifo_out;

                        ////if ( (fifo_out   > refsamples[counter_counter[i]*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE]) && 
                        //if ( signout[i] && 
                        //     (adc_datain > refsamples[counter_counter[i]*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE]) )
                        //    sad_counter[i] <= sad_counter[i] + adc_datain - fifo_out;
                        ////else if ( (fifo_out   <= refsamples[counter_counter[i]*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE]) && 
                        //else if ( ~signout[i] && 
                        //          (adc_datain <= refsamples[counter_counter[i]*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE]) )
                        //    sad_counter[i] <= sad_counter[i] - adc_datain + fifo_out;
                        ////else if ( (fifo_out   >  refsamples[counter_counter[i]*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE]) && 
                        //else if ( signout[i] && 
                        //          (adc_datain <= refsamples[counter_counter[i]*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE]) )
                        //    sad_counter[i] <= sad_counter[i] - adc_datain - fifo_out + (refsamples[counter_counter[i]*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE] *2);
                        //else
                        //    sad_counter[i] <= sad_counter[i] + adc_datain + fifo_out - (refsamples[counter_counter[i]*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE] *2);


                        if ( signout[i] && (adc_datain > nextrefsample[i]) ) begin
                            nextcase[i] <= 0;
                            sign[i] <= 1'b1;
                        end
                        else if ( ~signout[i] && (adc_datain <= nextrefsample[i]) ) begin
                            nextcase[i] <= 1;
                            sign[i] <= 1'b0;
                        end
                        else if ( signout[i] && (adc_datain <= nextrefsample[i]) ) begin
                            nextcase[i] <= 2;
                            sign[i] <= 1'b0;
                        end
                        else begin
                            nextcase[i] <= 3;
                            sign[i] <= 1'b1;
                        end


                        if (nextcase[i] == 0)
                            //counter_incr[i] <= adc_datain - fifo_out_r;
                            sad_counter[i] <= sad_counter[i] + adc_datain - fifo_out_r;
                        else if (nextcase[i] == 1)
                            //counter_incr[i] <= -adc_datain + fifo_out_r;
                            sad_counter[i] <= sad_counter[i] - adc_datain + fifo_out_r;
                        else if (nextcase[i] == 2)
                            //counter_incr[i] <= -adc_datain - fifo_out_r + (nextrefsample[i] *2);
                            sad_counter[i] <= sad_counter[i] - adc_datain - fifo_out_r + (nextrefsample[i] *2);
                        else
                            //counter_incr[i] <= adc_datain + fifo_out_r - (nextrefsample[i] *2);
                            sad_counter[i] <= sad_counter[i] + adc_datain + fifo_out_r - (nextrefsample[i] *2);

                        /*
                        if ( signout[i] && (adc_datain > nextrefsample[i]) ) begin
                            sad_counter[i] <= sad_counter[i] + adc_datain - fifo_out_r;
                            sign[i] <= 1'b1;
                        end
                        else if ( ~signout[i] && (adc_datain <= nextrefsample[i]) ) begin
                            sad_counter[i] <= sad_counter[i] - adc_datain + fifo_out_r;
                            sign[i] <= 1'b0;
                        end
                        else if ( signout[i] && (adc_datain <= nextrefsample[i]) ) begin
                            sad_counter[i] <= sad_counter[i] - adc_datain - fifo_out_r + (nextrefsample[i] *2);
                            sign[i] <= 1'b0;
                        end
                        else begin
                            sad_counter[i] <= sad_counter[i] + adc_datain + fifo_out_r - (nextrefsample[i] *2);
                            sign[i] <= 1'b1;
                        end
                        */

                        //sad_counter[i] <= sad_counter[i] + counter_incr[i];

                    end

               end
            end

            always @ (posedge adc_sampleclk) begin
                nextrefsample[i] <= refsamples[counter_counter[i]*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE];
            end

            always @ (posedge adc_sampleclk) begin
                if (counter_active[i]) begin
                    if (counter_counter[i] < pREF_SAMPLES-1)
                        counter_counter[i] <= counter_counter[i] + 1;
                    else begin
                        use_ref_samples[i] <= 1'b0;
                        counter_counter[i] <= 0;
                    end
                end
                else begin
                    use_ref_samples[i] <= 1'b1;
                    counter_counter[i] <= 0;
                end
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
                    for (c = 0; c < pREF_SAMPLES; c = c + 1)
                        counter_active[c] <= 0;
                    if (arm_i && active)
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
                    if (~(arm_i && active)) begin // exit to FLUSH if no longer armed
                        fifo_wr <= 1'b0;
                        state <= pS_FLUSH;
                    end
                    else begin
                        for (c = 0; c < pREF_SAMPLES; c = c + 1) begin
                            if (individual_trigger[c]) begin
                                trigger <= 1'b1;
                                fifo_wr <= 1'b0;
                                state <= pS_FLUSH;
                            end
                        end
                    end
                end

                pS_FLUSH: begin
                    // empty FIFO so we're ready for the next round
                    fifo_wr <= 1'b0;
                    if (fifo_almost_empty) begin
                        fifo_rd <= 1'b0;
                        state <= pS_IDLE;
                    end
                end

            endcase
        end
    end



    `ifdef NOFIFO
       //for clean iverilog compilation

    `else
       sad_fifo U_fifo(
          .clk          (adc_sampleclk),
          .rst          (reset),
          .din          ({allsigns, adc_datain}),
          .wr_en        (fifo_wr),
          .rd_en        (fifo_rd),
          .dout         ({allsignouts, fifo_out}),
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

    wire [15:0] sad_counter0 = sad_counter[0];
    wire [15:0] sad_counter1 = sad_counter[1];
    wire [15:0] sad_counter2 = sad_counter[2];
    wire [15:0] sad_counter3 = sad_counter[3];
    wire [15:0] sad_counter4 = sad_counter[4];
    wire [15:0] sad_counter5 = sad_counter[5];
    wire [15:0] sad_counter6 = sad_counter[6];
    wire [15:0] sad_counter7 = sad_counter[7];

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
    wire [31:0] individual_trigger_debug =  {individual_trigger[31],
                                             individual_trigger[30],
                                             individual_trigger[29],
                                             individual_trigger[28],
                                             individual_trigger[27],
                                             individual_trigger[26],
                                             individual_trigger[25],
                                             individual_trigger[24],
                                             individual_trigger[23],
                                             individual_trigger[22],
                                             individual_trigger[21],
                                             individual_trigger[20],
                                             individual_trigger[19],
                                             individual_trigger[18],
                                             individual_trigger[17],
                                             individual_trigger[16],
                                             individual_trigger[15],
                                             individual_trigger[14],
                                             individual_trigger[13],
                                             individual_trigger[12],
                                             individual_trigger[11],
                                             individual_trigger[10],
                                             individual_trigger[9],
                                             individual_trigger[8],
                                             individual_trigger[7],
                                             individual_trigger[6],
                                             individual_trigger[5],
                                             individual_trigger[4],
                                             individual_trigger[3],
                                             individual_trigger[2],
                                             individual_trigger[1],
                                             individual_trigger[0]};

   `ifdef ILA_SAD
       ila_sad U_ila_sad (
          .clk            (clk_usb),              // input wire clk
          .probe0         (adc_datain),           // input wire [7:0]  probe0 
          .probe1         (state),                // input wire [1:0]  probe1 
          .probe2         (individual_trigger_debug),// input wire [31:0]  probe2 
          .probe3         (trigger),              // input wire [0:0]  probe3 
          .probe4         (sad_counter0),         // input wire [15:0]  probe4 
          .probe5         (sad_counter1),         // input wire [15:0]  probe5 
          .probe6         (refsamples[31:0]),     // input wire [31:0]  probe6 
          .probe7         (counter_counter0),     // input wire [6:0]  probe7 
          .probe8         (arm_i),                // input wire [0:0]  probe8 
          .probe9         (ext_trigger)           // input wire [0:0]  probe9
       );
   `endif


endmodule
`default_nettype wire
