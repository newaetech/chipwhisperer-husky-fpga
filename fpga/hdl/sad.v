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
    parameter pREF_SAMPLES = 32, 
    parameter pBITS_PER_SAMPLE = 8,
    parameter pDIRTY_ENABLED = 0
)(
    input wire          reset,

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

    input  wire         ext_trigger,  // debug only
    input  wire         io4,  // debug only
    output reg          trigger
);

    wire [pBITS_PER_SAMPLE-1:0] fifo_out [0:pREF_SAMPLES-1];
    reg  fifo_wr;
    reg  fifo_rd;
    wire fifo_empty[0:pREF_SAMPLES-1];
    wire fifo_almost_empty[0:pREF_SAMPLES-1];
    wire fifo_overflow[0:pREF_SAMPLES-1];
    wire fifo_underflow[0:pREF_SAMPLES-1];
    reg  fifo_overflow_sticky;
    reg  fifo_underflow_sticky;
    reg fifo_not_empty_error;
    reg  triggered;
    reg clear_status;
    reg clear_status_r;
    wire clear_status_adc;

    reg multiple_triggers;
    reg [pBITS_PER_SAMPLE-1:0] maxdev;
    reg dirty[0:pREF_SAMPLES-1];
    reg [4:0] dirty_counter [0:pREF_SAMPLES-1];
    reg [pREF_SAMPLES*pBITS_PER_SAMPLE-1:0] refsamples;
    reg [pBITS_PER_SAMPLE-1:0] nextrefsample [0:pREF_SAMPLES-1];
    reg [31:0] threshold; // must be wide enough so it doesn't overflow (must hold addition of pREF_SAMPLES numbers that are each pBITS_PER_SAMPLE bits wide)
    reg [4:0] counter; // must be wide enough to count to pREF_SAMPLES-1
    reg [4:0] counter_counter [0:pREF_SAMPLES-1]; // must be wide enough to count to pREF_SAMPLES-1
    reg [pBITS_PER_SAMPLE-1:0] adc_datain_r;

    `ifdef SAD_DEBUG
        reg [pBITS_PER_SAMPLE-1:0] trigger_index;
    `endif


    // register reads:
    always @(*) begin
        if (reg_read) begin
            case (reg_address)
                `SAD_REFERENCE: reg_datao = refsamples[reg_bytecnt*8 +: 8];
                `SAD_THRESHOLD: reg_datao = threshold[reg_bytecnt*8 +: 8];
                `SAD_STATUS: reg_datao = {4'b0, fifo_not_empty_error, fifo_overflow_sticky, fifo_underflow_sticky, triggered};
                `SAD_BITS_PER_SAMPLE: reg_datao = pBITS_PER_SAMPLE;
                `SAD_REF_SAMPLES: reg_datao = pREF_SAMPLES;
                `SAD_MAX_DEV: reg_datao = maxdev[reg_bytecnt*8 +: 8];
                `SAD_MULTIPLE_TRIGGERS: reg_datao = {7'b0, multiple_triggers};
                `ifdef SAD_DEBUG
                    `SAD_DEBUG_TRIGGER_INDEX: reg_datao = trigger_index[reg_bytecnt*8 +: 8];
                    `SAD_DEBUG_FIFO_RD: reg_datao = debug_fifo_out_usb;
                `endif
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
            maxdev <= 0;
            multiple_triggers <= 0;
        end 
        else begin
            clear_status_r <= clear_status;
            if (reg_write) begin
                case (reg_address)
                    `SAD_REFERENCE: refsamples[reg_bytecnt*8 +: 8] <= reg_datai;
                    `SAD_THRESHOLD: threshold[reg_bytecnt*8 +: 8] <= reg_datai;
                    `SAD_MAX_DEV: maxdev[reg_bytecnt*8 +: 8] <= reg_datai;
                    `SAD_MULTIPLE_TRIGGERS: multiple_triggers <= reg_datai[0];
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
            adc_datain_r <= adc_datain;
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
                if (fifo_overflow[0])
                    fifo_overflow_sticky <= 1'b1;
                if (fifo_underflow[0])
                    fifo_underflow_sticky <= 1'b1;
                if ((state == pS_IDLE) && ~fifo_empty[0])
                    fifo_not_empty_error <= 1'b1;
            end
        end
    end


    reg counter_active [0:pREF_SAMPLES-1];
    reg counter_active_r [0:pREF_SAMPLES-1];
    reg counter_active_r2 [0:pREF_SAMPLES-1];
    reg use_ref_samples [0:pREF_SAMPLES-1];
    reg use_ref_samples_r [0:pREF_SAMPLES-1];
    reg use_ref_samples_r2 [0:pREF_SAMPLES-1];
    reg individual_trigger [0:pREF_SAMPLES-1];
    // TODO: these need to be wider than pBITS_PER_SAMPLE since we're adding many pBITS_PER_SAMPLE-wide numbers... hard-coded here for pBITS_PER_SAMPLE=8, pREF_SAMPLES=32
    reg [12:0] sad_counter [0:pREF_SAMPLES-1];
    reg [pBITS_PER_SAMPLE-1:0] counter_incr [0:pREF_SAMPLES-1]; // pBITS_PER_SAMPLE=8, pREF_SAMPLES=32
    reg [pBITS_PER_SAMPLE-1:0] fifo_out_r [0:pREF_SAMPLES-1];

    /* Instantiate counters and do most of the heavy lifting.
    * High-level approach is that we have a FIFO for each of the pREF_SAMPLES
    * SAD counters, which makes it easy to discard old differences from the
    * running counter.
    * We use some pre-registering of signals to make timing as easy as
    * possible; meets 200 MHz with ease for Husky. But it's BIG! We can fit
    * pREF_SAMPLES=32 with pBITS_PER_SAMPLE=12, but not pREF_SAMPLES=64.
    */
    genvar i;
    generate 
        for (i = 0; i < pREF_SAMPLES; i = i + 1) begin: gen_counter_registers

            `ifdef NOFIFO
               //for clean iverilog compilation
            `else
               // Here we instantiate one small FIFO for each SAD counter. We
               // could just as easily instantiate a single large FIFO instead
               // but this may make timing closure easier?
               sad_fifo U_fifo(
                  .clk          (adc_sampleclk),
                  .rst          (reset),
                  .din          (counter_incr[i]),
                  .wr_en        (fifo_wr),
                  .rd_en        (fifo_rd),
                  .dout         (fifo_out[i]),
                  .full         (),
                  .empty        (fifo_empty[i]),
                  .almost_empty (fifo_almost_empty[i]),
                  .overflow     (fifo_overflow[i]),
                  .underflow    (fifo_underflow[i])
               );
           `endif

            always @ (posedge adc_sampleclk)
                nextrefsample[i] <= refsamples[counter_counter[i]*pBITS_PER_SAMPLE +: pBITS_PER_SAMPLE];

            always @(posedge adc_sampleclk) begin
                if (state == pS_IDLE) begin
                    sad_counter[i] <= 0;
                    counter_incr[i] <= 0;
                    dirty[i] <= 0;
                    counter_active_r[i] <= 0;
                    counter_active_r2[i] <= 0;
                    use_ref_samples_r[i] <= 0;
                    use_ref_samples_r2[i] <= 0;
                end

                else begin
                    counter_active_r[i] <= counter_active[i];
                    counter_active_r2[i] <= counter_active_r[i];
                    use_ref_samples_r[i] <= use_ref_samples[i];
                    use_ref_samples_r2[i] <= use_ref_samples_r[i];
                    fifo_out_r[i] <= fifo_out[i];
                    if (counter_active_r2[i]) begin
                        if (use_ref_samples_r[i])
                            sad_counter[i] <= sad_counter[i] + counter_incr[i];
                        else
                            sad_counter[i] <= sad_counter[i] + counter_incr[i] - fifo_out_r[i];
                    end

                    if (counter_active_r[i]) begin
                        if (adc_datain_r > nextrefsample[i])
                            counter_incr[i] <= adc_datain_r - nextrefsample[i];
                        else
                            counter_incr[i] <= nextrefsample[i] - adc_datain_r;
                    end

                    // This was an idea: if any single sample difference exceeds maxdev, mark
                    // that sad_counter as "dirty" has scrolled off. "dirty" counters will not cause a trigger.
                    // However in practice this doesn't seem to yield better results (there is still jitter in
                    // SAD-captured traces). Leaving it here, disabled by default, in case it's useful later.
                    if (pDIRTY_ENABLED) begin
                        if (dirty[i] && counter_counter[i] == dirty_counter[i])
                            dirty[i] <= 1'b0;
                        else if (maxdev && counter_incr[i] > maxdev) begin
                            dirty[i] <= 1'b1;
                            dirty_counter[i] <= counter_counter[i];
                        end
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
                if (~dirty[i] && counter_active[i] && ~use_ref_samples_r2[i] && sad_counter[i] <= threshold && (counter_counter[i] == 2))
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
                    if (armed_and_ready && active)
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
                    trigger <= 1'b0;
                    if (~active) begin       // exit to FLUSH if no longer active
                        fifo_wr <= 1'b0;
                        state <= pS_FLUSH;
                    end
                    else if (armed_and_ready && active) begin
                        for (c = 0; c < pREF_SAMPLES; c = c + 1) begin
                            if (individual_trigger[c]) begin
                                trigger <= 1'b1;
                                `ifdef SAD_DEBUG
                                    if (~triggered)
                                        trigger_index <= c;
                                `endif
                                if (~multiple_triggers) begin // are we done?
                                    fifo_wr <= 1'b0;
                                    state <= pS_FLUSH;
                                end
                            end
                        end
                    end
                end

                pS_FLUSH: begin
                    // empty FIFO so we're ready for the next round
                    fifo_wr <= 1'b0;
                    if (fifo_almost_empty[0] || fifo_empty[0])
                        fifo_rd <= 1'b0;
                    if (~armed_and_ready || clear_status_adc)
                        state <= pS_IDLE;
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
    wire [15:0] sad_counter8 = sad_counter[8];
    wire [15:0] sad_counter9 = sad_counter[9];
    wire [15:0] sad_counter10 = sad_counter[10];
    wire [15:0] sad_counter11 = sad_counter[11];
    wire [15:0] sad_counter12 = sad_counter[12];
    wire [15:0] sad_counter13 = sad_counter[13];
    wire [15:0] sad_counter29 = sad_counter[29];
    wire [15:0] sad_counter30 = sad_counter[30];
    wire [15:0] sad_counter31 = sad_counter[31];

    wire [6:0] counter_counter0 = counter_counter[0];
    wire [6:0] counter_counter1 = counter_counter[1];
    wire [6:0] counter_counter2 = counter_counter[2];
    wire [6:0] counter_counter3 = counter_counter[3];
    wire [6:0] counter_counter9 = counter_counter[9];
    wire [6:0] counter_counter10 = counter_counter[10];
    wire [6:0] counter_counter11 = counter_counter[11];
    wire [6:0] counter_counter12 = counter_counter[12];
    wire [6:0] counter_counter13 = counter_counter[13];

    wire [7:0] fifo_out0 = fifo_out[0];
    wire fifo_empty0 = fifo_empty[0];
    wire [7:0] nextrefsample0 = nextrefsample[0];
    wire [7:0] nextrefsample1 = nextrefsample[1];
    wire [7:0] nextrefsample2 = nextrefsample[2];
    wire [7:0] nextrefsample3 = nextrefsample[3];
    wire [7:0] counter_incr0 = counter_incr[0];
    wire [7:0] counter_incr30 = counter_incr[30];
    wire counter_active_debug30 = counter_active[30];
    wire use_ref_samples_debug30 = use_ref_samples[30];
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
    wire [7:0] dirty_debug =  {dirty[7],
                               dirty[6],
                               dirty[5],
                               dirty[4],
                               dirty[3],
                               dirty[2],
                               dirty[1],
                               dirty[0]};
    wire [4:0] dirty_counter0 = dirty_counter[0];

    `ifdef SAD_DEBUG
        wire debug_wr;
        wire debug_rd;
        wire debug_almost_full;
        wire debug_overflow;
        wire debug_underflow;
        reg reg_read_r;
        reg debug_rd_usb;
        wire debug_reg_rd;
        wire debug_empty;
        wire [pBITS_PER_SAMPLE-1:0] debug_fifo_out;

        assign debug_wr = triggered? 1'b0 : fifo_wr;
        always @(posedge clk_usb) begin
            reg_read_r <= reg_read;
            if (reg_read && (reg_address == `SAD_DEBUG_FIFO_RD) && ~reg_read_r)
                debug_rd_usb <= 1'b1;
            else
                debug_rd_usb <= 1'b0;
        end

       cdc_pulse U_debug_rd (
          .reset_i       (reset),
          .src_clk       (clk_usb),
          .src_pulse     (debug_rd_usb),
          .dst_clk       (adc_sampleclk),
          .dst_pulse     (debug_reg_rd)
       );

       assign debug_rd = (fifo_wr && debug_almost_full) || debug_reg_rd;

       (* ASYNC_REG = "TRUE" *) reg [pBITS_PER_SAMPLE-1:0] debug_fifo_out_usb;
       always @ (posedge clk_usb)
           debug_fifo_out_usb <= debug_fifo_out;

        `ifdef NOFIFO
           //for clean iverilog compilation
        `else
             sad_debug_fifo U_debug_fifo(
                .clk          (adc_sampleclk),
                .rst          (reset),
                .din          (adc_datain_r),
                .wr_en        (debug_wr),
                .rd_en        (debug_rd),
                .dout         (debug_fifo_out),
                .full         (),
                .empty        (debug_empty),
                .almost_full  (debug_almost_full),
                .almost_empty (),
                .overflow     (debug_overflow),
                .underflow    (debug_underflow)
             );
         `endif

     `else
       (* ASYNC_REG = "TRUE" *) reg [pBITS_PER_SAMPLE-1:0] debug_fifo_out_usb;
    `endif


   `ifdef ILA_SAD
       ila_sad U_ila_sad (
          .clk            (clk_usb),              // input wire clk
          .probe0         (adc_datain_r),         // input wire [7:0]  probe0 
          .probe1         (state),                // input wire [1:0]  probe1 
          .probe2         (individual_trigger_debug),// input wire [31:0]  probe2 
          .probe3         (trigger),              // input wire [0:0]  probe3 
          .probe4         (sad_counter0),         // input wire [15:0]  probe4 
          .probe5         (sad_counter1),         // input wire [15:0]  probe5 
          .probe6         (refsamples[31:0]),     // input wire [31:0]  probe6 
          .probe7         (counter_counter0),     // input wire [6:0]  probe7 
          .probe8         (armed_and_ready),      // input wire [0:0]  probe8 
          .probe9         (ext_trigger),          // input wire [0:0]  probe9
          .probe10        (io4 ),                 // input wire [0:0]  probe10
          .probe11        (sad_counter2),         // input wire [15:0]  probe11 
          .probe12        (sad_counter3),         // input wire [15:0]  probe12 
          .probe13        (fifo_almost_empty[0]), // input wire [0:0]  probe13 
          .probe14        (fifo_empty[0]),        // input wire [0:0]  probe14 
          .probe15        (fifo_underflow[0]),    // input wire [0:0]  probe15 
          .probe16        (fifo_overflow[0]),     // input wire [0:0]  probe16 
          .probe17        (fifo_underflow_sticky),// input wire [0:0]  probe17 
          .probe18        (fifo_overflow_sticky), // input wire [0:0]  probe18 
          .probe19        (fifo_wr),              // input wire [0:0]  probe19 
          .probe20        (fifo_rd),              // input wire [0:0]  probe20 
          .probe21        (active)                // input wire [0:0]  probe21 
       );
   `endif


endmodule
`default_nettype wire
