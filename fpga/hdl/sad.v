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

/* Note!
* Not verified. Turns out this variant (using BRAMs for a single ultra-wide
* FIFO) doesn't fit or make sense for Husky. Saving for posterity in case it's
* useful in the future.
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

    wire [pBITS_PER_SAMPLE-1:0] fifo_out [0:pREF_SAMPLES-1];
    reg  fifo_wr;
    reg  fifo_rd;
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
                // Note: since all FIFOs share the same read/write signal, we
                // only need to look at one fifo's status signals.
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
    reg counter_active_r [0:pREF_SAMPLES-1];
    reg counter_active_r2 [0:pREF_SAMPLES-1];
    reg use_ref_samples [0:pREF_SAMPLES-1];
    reg use_ref_samples_r [0:pREF_SAMPLES-1];
    reg individual_trigger [0:pREF_SAMPLES-1];
    // TODO: these need to be wider than pBITS_PER_SAMPLE since we're adding many pBITS_PER_SAMPLE-wide numbers... hard-coded here for pBITS_PER_SAMPLE=8, pREF_SAMPLES=128
    reg [15:0] sad_counter [0:pREF_SAMPLES-1];
    reg [pBITS_PER_SAMPLE-1:0] counter_incr [0:pREF_SAMPLES-1]; // pBITS_PER_SAMPLE=8, pREF_SAMPLES=32
    reg [pBITS_PER_SAMPLE-1:0] fifo_out_r [0:pREF_SAMPLES-1];

    wire [pBITS_PER_SAMPLE*pREF_SAMPLES-1:0] fifo_in = {counter_incr[63], //  ugh...
                                                        counter_incr[62],
                                                        counter_incr[61],
                                                        counter_incr[60],
                                                        counter_incr[59],
                                                        counter_incr[58],
                                                        counter_incr[57],
                                                        counter_incr[56],
                                                        counter_incr[55],
                                                        counter_incr[54],
                                                        counter_incr[53],
                                                        counter_incr[52],
                                                        counter_incr[51],
                                                        counter_incr[50],
                                                        counter_incr[49],
                                                        counter_incr[48],
                                                        counter_incr[47],
                                                        counter_incr[46],
                                                        counter_incr[45],
                                                        counter_incr[44],
                                                        counter_incr[43],
                                                        counter_incr[42],
                                                        counter_incr[41],
                                                        counter_incr[40],
                                                        counter_incr[39],
                                                        counter_incr[38],
                                                        counter_incr[37],
                                                        counter_incr[36],
                                                        counter_incr[35],
                                                        counter_incr[34],
                                                        counter_incr[33],
                                                        counter_incr[32],
                                                        counter_incr[31],
                                                        counter_incr[30],
                                                        counter_incr[29],
                                                        counter_incr[28],
                                                        counter_incr[27],
                                                        counter_incr[26],
                                                        counter_incr[25],
                                                        counter_incr[24],
                                                        counter_incr[23],
                                                        counter_incr[22],
                                                        counter_incr[21],
                                                        counter_incr[20],
                                                        counter_incr[19],
                                                        counter_incr[18],
                                                        counter_incr[17],
                                                        counter_incr[16],
                                                        counter_incr[15],
                                                        counter_incr[14],
                                                        counter_incr[13],
                                                        counter_incr[12],
                                                        counter_incr[11],
                                                        counter_incr[10],
                                                        counter_incr[9],
                                                        counter_incr[8],
                                                        counter_incr[7],
                                                        counter_incr[6],
                                                        counter_incr[5],
                                                        counter_incr[4],
                                                        counter_incr[3],
                                                        counter_incr[2],
                                                        counter_incr[1],
                                                        counter_incr[0]};
    wire [pBITS_PER_SAMPLE*pREF_SAMPLES-1:0] fifo_out_wide;

     `ifdef NOFIFO
        //for clean iverilog compilation
     `else
        // Here we instantiate one small FIFO for each SAD counter. We
        // could just as easily instantiate a single large FIFO instead
        // but this may make timing closure easier?
        sad_fifo U_fifo(
           .clk          (adc_sampleclk),
           .rst          (reset),
           .din          (fifo_in),
           .wr_en        (fifo_wr),
           .rd_en        (fifo_rd),
           .dout         (fifo_out_wide),
           .full         (),
           .empty        (fifo_empty),
           .almost_empty (fifo_almost_empty),
           .overflow     (fifo_overflow),
           .underflow    (fifo_underflow)
        );
    `endif


    /* Instantiate counters and do most of the heavy lifting.
    * High-level approach is that we have a FIFO for each of the pREF_SAMPLES
    * SAD counters, which makes it easy to discard old differences from the
    * running counter. Here these FIFOs are actually combined into a single
    * big FIFO so that it may be implemented with BRAMs.
    * We use some pre-registering of signals to make timing as easy as
    * possible; meets 200 MHz with ease for Husky. But it's BIG! We can fit
    * pREF_SAMPLES=32 with pBITS_PER_SAMPLE=12, but not pREF_SAMPLES=64.
    */
    genvar i;
    generate 
        for (i = 0; i < pREF_SAMPLES; i = i + 1) begin: gen_counter_registers

            assign fifo_out[i] = fifo_out_wide[i*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE];

            always @ (posedge adc_sampleclk)
                nextrefsample[i] <= refsamples[counter_counter[i]*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE];

            always @(posedge adc_sampleclk) begin
                if (state == pS_IDLE) begin
                    sad_counter[i] <= 0;
                    counter_incr[i] <= 0;
                end

                else begin
                    counter_active_r[i] <= counter_active[i];
                    counter_active_r2[i] <= counter_active_r[i];
                    use_ref_samples_r[i] <= use_ref_samples[i];
                    fifo_out_r[i] <= fifo_out[i];
                    if (counter_active_r2[i])
                        if (use_ref_samples_r[i])
                            sad_counter[i] <= sad_counter[i] + counter_incr[i];
                        else
                            sad_counter[i] <= sad_counter[i] + counter_incr[i] - fifo_out_r[i];

                    if (counter_active_r[i]) begin
                        if (adc_datain > nextrefsample[i])
                            counter_incr[i] <= adc_datain - nextrefsample[i];
                        else
                            counter_incr[i] <= nextrefsample[i] - adc_datain;
                    end

               end
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
                    if (counter == pREF_SAMPLES-2)
                        fifo_rd <= 1'b1;
                    else if (counter == pREF_SAMPLES-1)
                        state <= pS_RUNNING;
                end

                pS_RUNNING: begin
                    // In this state all the counters are running.
                    // When this state is entered, most counters are still "initializing";
                    // when use_ref_samples[counter] goes low, this indicates that that counter is done initializing
                    if (~(arm_i && active)) begin       // exit to FLUSH if no longer armed & active
                        fifo_wr <= 1'b0;                // TODO: should we keep running if not armed?
                        state <= pS_FLUSH;
                    end
                    else begin
                        for (c = 0; c < pREF_SAMPLES; c = c + 1) begin
                            if (individual_trigger[c]) begin
                                trigger <= 1'b1;
                                fifo_wr <= 1'b0;
                                state <= pS_FLUSH; // TODO: should we go to flush here, or just keep running?
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


    // DEBUG STUFF:

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

    wire [7:0] nextrefsample0 = nextrefsample[0];
    wire [7:0] nextrefsample1 = nextrefsample[1];
    wire [7:0] nextrefsample2 = nextrefsample[2];
    wire [7:0] nextrefsample3 = nextrefsample[3];
    wire [7:0] counter_incr0 = counter_incr[0];
    wire use_ref_samples_r0 = use_ref_samples_r[0];

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
