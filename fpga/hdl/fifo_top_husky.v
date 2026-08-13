`include "includes.v"
`timescale 1 ns / 1 ps
`default_nettype none

/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more
details, or the codebase at http://www.chipwhisperer.com

Copyright (c) 2021-2026, NewAE Technology Inc. All rights reserved.
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

module fifo_top_husky(
    input wire    reset,

    //ADC Sample Input
    input wire [11:0]   adc_datain,
    input wire          adc_sampleclk,
    input wire          capture_active, //for debug only
    input wire          capture_go,
    output reg          adc_capture_stop,
    input wire          arm_i,
    input wire          arm_usb,
    input wire [15:0]   num_segments,
    input wire [19:0]   segment_cycles,
    input wire          segment_cycle_counter_en,

    //FIFO to USB Read Interface
    input wire          clk_usb,
    input wire          low_res,        // if set, return just 8 bits per sample; if clear return all 12 bits per sample
    input wire          low_res_lsb,    // useless except for testing: if set, return the 8 LSB bits when in low_res mode
    input wire [13:0]   stream_segment_threshold,
    input wire          fifo_read_fifoen,
    output wire         fifo_read_fifoempty,
    output reg  [7:0]   fifo_read_data,
    input  wire         fast_fifo_read_mode, // not to be confused with the ADC fast FIFO, this denote fast reading of the *slow* FIFO

    input wire  [16:0]  presample_i,
    input wire  [31:0]  samples_to_collect,
    input wire  [31:0]  total_stream_words,

    output wire [23:0]  max_samples_8b,
    output wire [23:0]  max_samples_12b,
    output wire [23:0]  max_presamples_8b,
    output wire [23:0]  max_presamples_12b,
    output wire [23:0]  max_segment_total_bytes,

    input wire  [12:0]  downsample_i, //Ignores this many samples inbetween captured measurements

    output wire         fifo_overflow, //If overflow happens (bad during stream mode)
    input  wire         stream_mode, //1=Enable stream mode, 0=Normal
    output reg          error_flag,
    output reg [9:0]    error_stat,
    output reg [9:0]    first_error_stat,
    output reg [2:0]    first_error_state,
    output reg [16:0]   first_error_presample_counter,
    output reg [15:0]   first_error_segment_counter,
    output reg [31:0]   first_error_sample_counter,

    input  wire         clear_fifo_errors,
    input  wire         trigger_too_soon,
    output reg          stream_segment_available,
    input  wire         no_clip_errors,
    input  wire         no_gain_errors,
    output reg [7:0]    underflow_count,
    input  wire         no_underflow_errors,  // disables flagging of *slow* FIFO underflow errors only
    output reg          capture_done,
    output reg          armed_and_ready,
    output reg [2:0]    state,
    output reg          flushing,
    output wire         fast_fifo_empty,

    // for debug only:
    output wire         slow_fifo_wr,
    output wire         slow_fifo_rd,
    output reg  [31:0]  fifo_read_count,
    output reg  [31:0]  fifo_read_count_error_freeze,
    output wire [7:0]   debug

);

    parameter pMAX_UNDERFLOWS = 3; // Note: not sure if optimal (could maybe reduce?), but works

`ifdef PLUS
    parameter pMAX_SAMPLES_8b = 518353;
    parameter pMAX_SAMPLES_12b = 346246;
    parameter pMAX_PRESAMPLES_8b = 75745;
    parameter pMAX_PRESAMPLES_12b = 51163;
    parameter pMAX_SEGMENT_TOTAL_BYTES = 48*9*1024;

`else
    parameter pMAX_SAMPLES_8b = 204796;
    parameter pMAX_SAMPLES_12b = 137215;
    parameter pMAX_PRESAMPLES_8b = 38890;
    parameter pMAX_PRESAMPLES_12b = 26605;
    parameter pMAX_SEGMENT_TOTAL_BYTES = 18*9*1024;

`endif

    assign max_samples_8b          = pMAX_SAMPLES_8b;
    assign max_samples_12b         = pMAX_SAMPLES_12b;
    assign max_presamples_8b       = pMAX_PRESAMPLES_8b;
    assign max_presamples_12b      = pMAX_PRESAMPLES_12b;
    assign max_segment_total_bytes = pMAX_SEGMENT_TOTAL_BYTES;

    wire                fast_fifo_wr;
    reg                 fast_fifo_rd_en = 1'b0;
    wire                fast_fifo_rd;
    wire [71:0]         fast_fifo_dout;
    wire                fast_fifo_full;
    wire                fast_fifo_almost_empty;
    wire                fast_fifo_overflow;
    wire                fast_fifo_underflow;
    wire                empty_stage1_usb;
    reg                 reset_fast_fifo_internal_count;

    wire [71:0]         slow_fifo_din;
    reg                 slow_fifo_prewr = 1'b0;
    reg                 slow_fifo_rd_slow = 1'b0;
    wire                slow_fifo_rd_fast;
    wire [71:0]         slow_fifo_dout;
    wire                slow_fifo_full;
    wire                slow_fifo_full_threshold;
    wire                slow_fifo_empty;
    wire                slow_fifo_overflow;
    wire                slow_fifo_underflow;

    reg                 fast_fifo_overflow_reg;
    reg                 fast_fifo_underflow_reg;
    reg                 slow_fifo_overflow_reg;
    reg                 slow_fifo_underflow_reg;
    reg                 presample_fifo_count_overflow_reg;
    reg                 presample_fifo_count_underflow_reg;

    reg  [16:0]         presample_counter;
    reg  [3:0]          write_word_counter = 4'b0000;
    reg  [31:0]         sample_counter;
    reg  [15:0]         segment_counter;
    reg  [19:0]         segment_cycle_counter;

    reg                 arm_r;
    wire                arm_pulse_adc;
    wire                arm_pulse_usb;
    reg                 arm_usb_r;
    reg                 arming;
    reg                 capture_go_r;
    reg                 capture_go_r2;
    wire                flushing_adc;

    reg [1:0]           slow_fifo_underflow_count;
    reg                 slow_fifo_underflow_masked;

    reg  [3:0]          done_wait_count;
    reg                 gain_error = 1'b0;
    reg                 segment_error;
    reg                 clip_error = 1'b0;
    wire                clear_fifo_errors_adc;

    reg [31:0]          read_count;
    reg                 first_read;
    reg                 first_read_done;

    assign fifo_overflow = fast_fifo_overflow_reg || slow_fifo_overflow_reg;


    // make overflows and underflows sticky:
    always @(posedge adc_sampleclk) begin
       if (arm_pulse_adc || clear_fifo_errors_adc) begin
          fast_fifo_overflow_reg <= 1'b0;
          presample_fifo_count_overflow_reg <= 1'b0;
          presample_fifo_count_underflow_reg <= 1'b0;
       end
       else begin
          if (fast_fifo_overflow)
             fast_fifo_overflow_reg <= 1'b1;
          if (presample_fifo_count_overflow)
              presample_fifo_count_overflow_reg <= 1'b1;
          if (presample_fifo_count_underflow)
              presample_fifo_count_underflow_reg <= 1'b1;
       end
    end

    always @(posedge clk_usb) begin
       if (arm_pulse_usb || clear_fifo_errors) begin
          slow_fifo_overflow_reg <= 1'b0;
          slow_fifo_underflow_reg <= 1'b0;
          fast_fifo_underflow_reg <= 1'b0;
       end
       else begin
          if (slow_fifo_overflow)
             slow_fifo_overflow_reg <= 1'b1;
          if (slow_fifo_underflow)
             slow_fifo_underflow_reg <= 1'b1;
          if (fast_fifo_underflow)
             fast_fifo_underflow_reg <= 1'b1;
       end
    end

    reg save_offset_error = 1'b0;
    always @(posedge clk_usb) begin
       if (arm_pulse_usb || clear_fifo_errors)
           save_offset_error <= 1'b0;
       // Note: would be nice to also catch the case of a slow_fifo_prewr
       // for current capture occuring after save_offset_usb, but could be
       // hard to avoid false-positives
       else if (save_offset_usb && slow_fifo_prewr)
           save_offset_error <= 1'b1;
   end

    assign fifo_read_fifoempty = slow_fifo_empty;

    //Counter for downsampling (NOT proper decimation)
    reg [12:0] downsample_ctr;
    wire downsample_max;
    reg downsample_wr_en;

    assign downsample_max = (downsample_ctr == downsample_i) ? 1'b1 : 'b0;

    always @(posedge adc_sampleclk) begin
       if (arm_pulse_adc) begin
          downsample_ctr <= 13'd0;
          downsample_wr_en <= 1'b0;
       end 
       else begin
          // NOTE: capture_go_r* condition is to align downsample captures on
          // the trigger event. If downsample+presample support gets added,
          // this condition makes it possible to have two successive writes
          // that are very close together.
          if (downsample_max || (capture_go_r && ~capture_go_r2)) begin
             downsample_ctr <= 13'd0;
             downsample_wr_en <= 1'b1;
          end
          else begin
             downsample_ctr <= downsample_ctr + 13'd1;
             downsample_wr_en <= 1'b0;
          end
       end
    end


    // Presample logic: when armed, we always write to the fast FIFO. When
    // we reach the requested number of presamples, we start to also read
    // and discard, so as to keep exactly the requested number of presamples
    // in the fast FIFO. During this time, no data is sent to the slow FIFO.
    // When the trigger is received, the fast FIFO read data is then written
    // to the slow FIFO.

    localparam pS_IDLE = 0;
    localparam pS_PRESAMP_FILLING = 1;
    localparam pS_PRESAMP_FULL = 2;
    localparam pS_TRIGGERED = 3;
    localparam pS_SEGMENT_DONE = 4;
    localparam pS_DONE = 5;
    localparam pS_SAVE_OFFSET = 6;
    reg [2:0] state_r;

    wire state_idle = (state == pS_IDLE);
    wire state_presamp_filling = (state == pS_PRESAMP_FILLING);
    wire state_presamp_full = (state == pS_PRESAMP_FULL);
    wire state_triggered = (state == pS_TRIGGERED);
    wire state_segment_done = (state == pS_SEGMENT_DONE);
    wire state_done = (state == pS_DONE);
    wire state_save_offset = (state == pS_SAVE_OFFSET);

    wire stop_capture_conditions;
    reg fsm_fast_wr_en;
    reg [19:0] segment_cycles_adjusted;

    assign stop_capture_conditions = arm_pulse_adc || adc_capture_stop;

    reg  presamp_done1_r;
    wire presamp_done1 = (capture_go && (segment_counter == 0));
    wire next_segment_go_pre = segment_cycle_counter_en?  ((segment_cycle_counter == segment_cycles_adjusted) && (segment_cycles > 0)) :
                                                          (capture_go && ~capture_go_r);

    wire presamp_done = presamp_done1_r || next_segment_go;
    wire presamp_error = presamp_done && (state == pS_PRESAMP_FILLING);
    wire internal_error = presample_fifo_error || save_offset_error;

    reg next_segment_go;
    reg last_segment;
    reg last_sample;
    always @(posedge adc_sampleclk) begin
        if (segment_cycles > 1) // alternatively, could do this in Python instead  (but why- everything works now)
            segment_cycles_adjusted <= segment_cycles - 2;
        else
            segment_cycles_adjusted <= segment_cycles;
        next_segment_go <= next_segment_go_pre; // this would add a cycle of latency but we've compensate by registering the ADC input in openadc_interface.v
        last_segment <= (segment_counter == (num_segments-1));
        if (downsample_i > 0)
            last_sample <= sample_counter == samples_to_collect-1;
        else
            last_sample <= sample_counter == samples_to_collect-2;
        presamp_done1_r <= presamp_done1;
    end


    // gain errors:
    genvar i, j;
    reg [8:0] clip_lores;
    reg [5:0] clip_hires;
    reg [9:0] logain_lores;
    reg [5:0] logain_hires;
    generate
        for (i = 0; i < 9; i = i + 1) begin: clip_gen_lores
            always @(posedge clk_usb) begin
                if (clear_fifo_errors)
                    clip_lores[i] <= 1'b0;
                else if (slow_fifo_prewr && low_res) begin
                    if (slow_fifo_din[i*8+:8] == {8'h00} || slow_fifo_din[i*8+:8] == {8'hFF})
                        clip_lores[i] <= 1'b1;
                    else
                        clip_lores[i] <= 1'b0;
                end

                if (no_gain_errors || clear_fifo_errors)
                    logain_lores[i] <= 1'b0;
                else if (capture_go)
                    logain_lores[i] <= 1'b1;
                else if (low_res && slow_fifo_prewr && (slow_fifo_din[(i*8)+7]? slow_fifo_din[(i*8)+5+:2] != 2'b00 : slow_fifo_din[(i*8)+4+:3] != 3'b111))
                    logain_lores[i] <= 1'b0;
            end
        end
    endgenerate

    generate
        for (j = 0; j < 6; j = j + 1) begin: clip_gen_hires
            always @(posedge clk_usb) begin
                if (clear_fifo_errors)
                    clip_hires[j] <= 1'b0;
                else if (slow_fifo_prewr && ~low_res) begin
                    if (slow_fifo_din[j*12+:12] == {12'h000} || slow_fifo_din[j*12+:12] == {12'hFFF})
                        clip_hires[j] <= 1'b1;
                    else
                        clip_hires[j] <= 1'b0;
                end

                if (no_gain_errors || clear_fifo_errors)
                    logain_hires[j] <= 1'b0;
                else if (capture_go)
                    logain_hires[j] <= 1'b1;
                else if (~low_res && slow_fifo_prewr && (slow_fifo_din[(j*12)+11]? slow_fifo_din[(j*12)+9+:2] != 2'b00 : slow_fifo_din[(j*12)+8+:3] != 3'b111))
                    logain_hires[j] <= 1'b0;
            end
        end
    endgenerate

    always @ (posedge clk_usb) begin
        if (no_clip_errors || clear_fifo_errors)
            clip_error <= 1'b0;
        else if ((low_res)? |clip_lores : |clip_hires)
            clip_error <= 1'b1;

        if (no_gain_errors || clear_fifo_errors)
            gain_error <= 1'b0;
        else if ((state == pS_IDLE) && (state_r == pS_DONE) && ((low_res)? &logain_lores : &logain_hires))
            gain_error <= 1'b1;
    end


    // write-side FSM (fast ADC clock):
    // controls writing the first stage of the storage FIFOs
    reg save_offset = 1'b0;
    reg done_writing = 1'b0;
    always @ (posedge adc_sampleclk) begin
       if (reset) begin
          state <= pS_IDLE;
          presample_counter <= 0;
          sample_counter <= 0;
          adc_capture_stop <= 1'b0;
          segment_counter <= 0;
          segment_cycle_counter <= 0;
          segment_error <= 1'b0;
       end

       else begin
          state_r <= state;
          case (state)

             pS_IDLE: begin
                save_offset <= 1'b0;
                presample_counter <= 0;
                sample_counter <= 0;
                adc_capture_stop <= 1'b0;
                segment_counter <= 0;
                segment_cycle_counter <= 0;
                segment_error <= 1'b0;
                fsm_fast_wr_en <= 1'b0;
                reset_fast_fifo_internal_count <= 1'b0;
                done_writing <= 1'b0;

                if (armed_and_ready && ~adc_capture_stop) begin
                   if (presample_i > 0) begin
                      fsm_fast_wr_en <= 1'b1;
                      state <= pS_PRESAMP_FILLING;
                   end
                   else if (capture_go_r) begin
                      fsm_fast_wr_en <= 1'b1;
                      state <= pS_TRIGGERED;
                   end
                end
             end

             pS_PRESAMP_FILLING: begin
                reset_fast_fifo_internal_count <= 1'b0;
                save_offset <= 1'b0;
                if (next_segment_go && (state_r == pS_PRESAMP_FILLING))
                   segment_error <= 1'b1;
                if (segment_counter > 0)
                   segment_cycle_counter <= segment_cycle_counter + 1;
                if (stop_capture_conditions) begin
                   fsm_fast_wr_en <= 1'b0;
                   state <= pS_DONE;
                end
                else if (presamp_done) begin
                   state <= pS_TRIGGERED;
                end
                else if (presample_counter == (presample_i-2))
                   state <= pS_PRESAMP_FULL;
                else if (fast_fifo_wr) begin
                   presample_counter <= presample_counter + 1;
                end
             end

             pS_PRESAMP_FULL: begin
                if (segment_counter > 0)
                   segment_cycle_counter <= segment_cycle_counter + 1;
                if (stop_capture_conditions) begin
                   fsm_fast_wr_en <= 1'b0;
                   state <= pS_DONE;
                end
                else if (presamp_done) begin
                   if (state_r != pS_PRESAMP_FULL)
                       segment_error <= 1'b1;
                   segment_cycle_counter <= 0;
                   sample_counter <= presample_i;
                   state <= pS_TRIGGERED;
                end
             end

             pS_TRIGGERED: begin
                reset_fast_fifo_internal_count <= 1'b0;
                save_offset <= 1'b0;
                if ( (next_segment_go && (state_r == pS_TRIGGERED)) || save_offset_done)
                   segment_error <= 1'b1;
                segment_cycle_counter <= segment_cycle_counter + 1;

                if (stop_capture_conditions || (last_sample && fast_fifo_wr && last_segment)) begin
                    adc_capture_stop <= 1'b1;
                    done_wait_count <= 10;  // established by trial/error to account for the latency in the Xilinx FIFO updating its empty flag
                    fsm_fast_wr_en <= 1'b0;
                    done_writing <= 1'b1;
                    state <= pS_DONE;
                end

                else if (last_sample && ~last_segment && fast_fifo_wr) begin
                   fsm_fast_wr_en <= 1'b0;
                   done_writing <= 1'b1;
                   state <= pS_SEGMENT_DONE;
                end

                if (fast_fifo_wr) begin
                   sample_counter <= sample_counter + 1;
                end
             end

             pS_SEGMENT_DONE: begin
                segment_cycle_counter <= segment_cycle_counter + 1;
                if (next_segment_go) begin
                   segment_error <= 1'b1;
                   // NOTE: we don't save the offset here because the data will be junk anyways
                   reset_fast_fifo_internal_count <= 1'b1;
                   state <= pS_IDLE;
                end
                else if (fast_fifo_empty_adc && !slow_fifo_full_adc) begin
                   if (presample_i > 0) begin
                      segment_counter <= segment_counter + 1;
                      sample_counter <= 0;
                      presample_counter <= 0;
                      fsm_fast_wr_en <= 1'b1;
                      save_offset <= 1'b1;
                      reset_fast_fifo_internal_count <= 1'b1;
                      state <= pS_PRESAMP_FILLING;
                   end
                   else begin
                      save_offset <= 1'b1;
                      state <= pS_SAVE_OFFSET;
                   end
                end
             end

             pS_SAVE_OFFSET: begin
                segment_cycle_counter <= segment_cycle_counter + 1;
                save_offset <= 1'b0;
                done_writing <= 1'b0;
                if (next_segment_go) begin
                   segment_counter <= segment_counter + 1;
                   segment_cycle_counter <= 0;
                   sample_counter <= 0;
                   fsm_fast_wr_en <= 1'b1;
                   reset_fast_fifo_internal_count <= 1'b1;
                   state <= pS_TRIGGERED;
                end
             end

             pS_DONE: begin
                // serves two purposes:
                // 1. wait for the fast FIFO to empty (and for the slow FIFO to have space for the offset word)
                // 2. wait state so that we don't get back out of idle right away
                if (fast_fifo_empty_adc && !slow_fifo_full_adc && (done_wait_count == 0)) begin
                   save_offset <= 1'b1;
                   state <= pS_IDLE;
                end
                else if (arm_i)
                   state <= pS_IDLE;
                else
                   done_wait_count <= done_wait_count - 1;
             end

          endcase
       end
    end

    always @(posedge adc_sampleclk) begin
       if (arm_pulse_adc)
          capture_done <= 1'b0;
       else if (state == pS_DONE)
          capture_done <= 1'b1;
    end


   wire clear_fifo_errors_r2;
   assign clear_fifo_errors_adc = clear_fifo_errors_r2;

   cdc_simple U_clear_fifo_errors_cdc (
       .reset          (reset),
       .clk            (adc_sampleclk),
       .data_in        (clear_fifo_errors),
       .data_out       (),
       .data_out_r     (clear_fifo_errors_r2)
   );

   cdc_simple U_flushing_adc_cdc (
       .reset          (reset),
       .clk            (adc_sampleclk),
       .data_in        (flushing),
       .data_out       (flushing_adc),
       .data_out_r     ()
   );

   wire flushing_adc_usb;
   cdc_simple U_flushing_adc_usb_cdc (
       .reset          (reset),
       .clk            (clk_usb),
       .data_in        (flushing_adc),
       .data_out       (flushing_adc_usb),
       .data_out_r     ()
   );


    always @(posedge adc_sampleclk) begin
       if (reset) begin
          arming <= 1'b0;
          armed_and_ready <= 1'b0;
          capture_go_r <= 1'b0;
          capture_go_r2 <= 1'b0;
       end
       else begin
          capture_go_r <= capture_go;
          capture_go_r2 <= capture_go_r;
          arm_r <= arm_i;
          if (arm_i && ~arm_r && ~arming) begin
             arming <= 1'b1;
             armed_and_ready <= 1'b0;
          end
          else if (arming && ~flushing_adc) begin       // Thread carefully with this logic; the risk is that flushing_adc hasn't gone high yet
                                                        // before this condition is satisfied (and hence flushing hasn't even begun. Two clock
                                                        // domains are involved so exsercise caution.
             arming <= 1'b0;
             armed_and_ready <= 1'b1;
          end
          else if (adc_capture_stop)
             armed_and_ready <= 1'b0;
       end
    end


    assign fast_fifo_wr = downsample_wr_en & fsm_fast_wr_en & !flushing_adc;
    assign slow_fifo_wr = slow_fifo_prewr & !flushing_adc || save_offset_usb;

    // FIFO flushing mechanism: kick off flushing all FIFOs when arming.
    // Controlled from USB clock domain since that's closest to the ARM event,
    // and FIFOs use all the clocks anyways. Complicated only by all the
    // clocks.


    assign arm_pulse_usb = arm_usb && ~arm_usb_r;
    always @(posedge clk_usb) begin
        if (reset) begin
            flushing <= 1'b0;
            arm_usb_r <= 1'b0;
        end
        else begin
            arm_usb_r <= arm_usb;
            if (arm_pulse_usb)
                flushing <= 1'b1;
            // last condition is to ensure that CDC from flushing to flushing_adc had a chance to occur:
            else if (fast_fifo_empty && slow_fifo_empty && flushing_adc_usb)
                flushing <= 1'b0;
        end
    end

    cdc_pulse U_fifo_rst_start_cdc (
       .reset_i       (reset),
       .src_clk       (clk_usb),
       .src_pulse     (arm_pulse_usb),
       .dst_clk       (adc_sampleclk),
       .dst_pulse     (arm_pulse_adc)
    );

    always @(*) begin
       if (stream_mode)
          slow_fifo_underflow_masked = slow_fifo_underflow_reg && (read_count < total_stream_words) && ~no_underflow_errors; 
       else
          slow_fifo_underflow_masked = slow_fifo_underflow_reg && ~no_underflow_errors && (slow_fifo_underflow_count == pMAX_UNDERFLOWS);
    end

    wire slow_fifo_underflow_masked_adc;
    cdc_simple U_slow_fifo_underflow_masked_cdc (
        .reset          (reset),
        .clk            (adc_sampleclk),
        .data_in        (slow_fifo_underflow_masked),
        .data_out       (slow_fifo_underflow_masked_adc),
        .data_out_r     ()
    );

    function [9:0] error_bits (input [9:0] current_error);
       begin
          error_bits = current_error;
          if (trigger_too_soon)                 error_bits[9] = 1'b1;
          if (gain_error)                       error_bits[8] = 1'b1;
          if (segment_error)                    error_bits[7] = 1'b1;
          if (internal_error)                   error_bits[6] = 1'b1;
          if (clip_error)                       error_bits[5] = 1'b1;
          if (presamp_error)                    error_bits[4] = 1'b1;
          if (fast_fifo_overflow_reg)           error_bits[3] = 1'b1;
          if (fast_fifo_underflow_reg)          error_bits[2] = 1'b1;
          if (slow_fifo_overflow_reg)           error_bits[1] = 1'b1;
          if (slow_fifo_underflow_masked_adc)   error_bits[0] = 1'b1;
       end
    endfunction

    always @(posedge adc_sampleclk) begin
       if (reset) begin
          error_flag <= 0;
          error_stat <= 0;
          first_error_stat <= 0;
          underflow_count <= 0;
          first_error_state <= pS_IDLE;
       end
       else begin
          if (arm_pulse_adc || clear_fifo_errors_adc) begin
             error_stat <= 0;
             first_error_stat <= 0;
             error_flag <= 0;
             underflow_count <= 0;
             first_error_state <= pS_IDLE;
          end
          else begin
             if (gain_error || segment_error || clip_error || presamp_error || internal_error ||
                 fast_fifo_overflow_reg || fast_fifo_underflow_reg || slow_fifo_overflow_reg || slow_fifo_underflow_masked_adc) begin
                error_flag <= 1;
                if (!error_flag) begin
                   first_error_stat <= error_bits(first_error_stat);
                   first_error_state <= state_r;
                   first_error_presample_counter <= presample_counter;
                   first_error_sample_counter <= sample_counter;
                   first_error_segment_counter <= segment_counter;
                end
             end

             error_stat <= error_bits(error_stat);

             if (slow_fifo_underflow_masked_adc && (underflow_count != 8'hFF))
                underflow_count <= underflow_count + 1;
          end
       end
    end

    always @(posedge clk_usb) begin
       if (reset)
          slow_fifo_underflow_count <= 0;
       else begin
          // SAM3U likes to read multiples of 4 bytes, so we don't flag an
          // underflow unless we observe at least pMAX_UNDERFLOWS underflow reads.
          // Note that with this architecture, the Python side code reads
          // multiples of *9* bytes, so these underflows can still occur.
          if (arm_pulse_usb)
             slow_fifo_underflow_count <= 0;
          else if (slow_fifo_underflow && slow_fifo_underflow_count < pMAX_UNDERFLOWS)
             slow_fifo_underflow_count <= slow_fifo_underflow_count + 1;

       end
    end

    wire presamp_running_usb;
    cdc_simple U_presamp_running_cdc (
        .reset          (reset),
        .clk            (clk_usb),
        .data_in        (presamp_running),
        .data_out       (presamp_running_usb),
        .data_out_r     ()
    );

    wire save_offset_usb;
    cdc_pulse U_save_offset_cdc (
       .reset_i       (reset),
       .src_clk       (adc_sampleclk),
       .src_pulse     (save_offset),
       .dst_clk       (clk_usb),
       .dst_pulse     (save_offset_usb)
    );

    wire save_offset_done;
    cdc_pulse U_save_offset_done_cdc (
       .reset_i       (reset),
       .src_clk       (clk_usb),
       .src_pulse     (save_offset_usb),
       .dst_clk       (adc_sampleclk),
       .dst_pulse     (save_offset_done)
    );

    // Read fast FIFO / write slow FIFO. Two states:
    // 1. presamples:
    //    When in pS_PRESAMP_FULL, have ADC side issue CDC'd pulses for reading the
    //    fast FIFO in order to keep its fill level constant
    // 2. otherwise, do a fast-read + slow-write whenever it's possible

    reg presamp_actually_running = 1'b0;
    reg presamp_running_usb_r;
    always @(posedge clk_usb) begin
        // NOTE: case 1 is handled by presample_fifo_count_rd block
        // below; maybe combine? except that they're different clock domains--
        // so just need to make it more clear how these two always blocks are
        // connected
        presamp_running_usb_r <= presamp_running_usb;
        if (presamp_running_usb)
            presamp_actually_running <= 1'b1;
        else if (!presamp_running_usb_r && presample_fifo_count_empty)
            presamp_actually_running <= 1'b0;

        if (presamp_actually_running) begin
            fast_fifo_rd_en <= 1'b0;
            slow_fifo_prewr <= 1'b0;
        end

        else if ( (!slow_fifo_full_threshold && !fast_fifo_almost_empty && !fast_fifo_empty) ||
                  (!slow_fifo_prewr && !slow_fifo_full && !fast_fifo_empty && empty_stage1_usb) ) begin
                  // Note: maybe need to split up the slow_fifo_full / fast_fifo_empty cases? because only latter should care about
                  // empty_stage1_usb. But maybe this is ok for simplicity?
            fast_fifo_rd_en <= 1'b1;
            slow_fifo_prewr <= 1'b1;
        end

        else begin
            fast_fifo_rd_en <= 1'b0;
            slow_fifo_prewr <= 1'b0;
        end
    end


`ifdef ILA_DEBUG_FIFOS
    ila_fifos U_ila_fifos (
        .clk            (clk_usb),
        .probe0         (slow_fifo_prewr),
        .probe1         (fast_fifo_rd_en),
        .probe2         (slow_fifo_full_threshold),
        .probe3         (slow_fifo_full),
        .probe4         (fast_fifo_almost_empty),
        .probe5         (fast_fifo_empty),
        .probe6         (fast_fifo_overflow),
        .probe7         (state),
        .probe8         (error_flag),
        .probe9         (error_stat),
        .probe10        (flushing),
        .probe11        (all_fifos_empty)
    );

    ila_fifos U_ila_fifos_adc (
        .clk            (adc_sampleclk),
        .probe0         (fast_fifo_empty_adc),
        .probe1         (fast_fifo_empty),
        .probe2         (flushing_adc),
        .probe3         (slow_fifo_full_adc),
        .probe4         (save_offset),
        .probe5         (next_segment_go),
        .probe6         (fast_fifo_overflow),
        .probe7         (state),
        .probe8         (error_flag),
        .probe9         (error_stat),
        .probe10        (segment_error),
        .probe11        (all_fifos_empty)
    );

`endif


    // Details of how the presamples feature is implemented:
    // 1. Fill phase (pS_PRESAMP_FILLING):
    //    Fast FIFO is written but not read.
    // 2. Full phase (pS_PRESAMP_FULL):
    //    After exactly "presamples" samples have been written to the fast FIFO,
    //    we keep writing to the fast FIFO but must read (and discard) the
    //    exact same number of samples that we write. Since fast FIFO reads
    //    and writes are on different clock domains, this can be a bit tricky.
    //    We use a small async FIFO as a counter of sorts: for every 4 writes
    //    we push an entry into the FIFO. On the read side, we pop the FIFO
    //    whenever possible (and carry out 4 sample reads). This cheap+simple
    //    mechanism allows us to have the same number of reads and writes.
    // 3. Triggered phase (pS_TRIGGERED):
    //    When the capture trigger is received, then we (a) stop pushing into
    //    the async count FIFO, (b) finish popping all its entries. Once this
    //    is done we revert to "normal" operation, where any data in the fast
    //    FIFO is moved onwards into the slow FIFO.

    wire presample_fifo_count_full;
    wire presample_fifo_count_overflow;
    wire presample_fifo_count_empty;
    wire presample_fifo_count_almost_empty;
    wire presample_fifo_count_underflow;
    reg  presample_fifo_count_wr = 1'b0;
    reg  presample_fifo_count_rd = 1'b0;


    reg presamp_running = 1'b0;
    reg presamp_fifo_filling = 1'b0;
    reg [3:0] segment_offset;
    reg next_segment_go_r;
    always @(posedge adc_sampleclk) begin
        // NOTE: presamp_running is used to prevent reading the slow FIFO
        //if (state == pS_IDLE) // this resets too early!
        if ((state == pS_PRESAMP_FILLING) && (state_r != pS_PRESAMP_FILLING))
            presamp_running <= 1'b1;
        else if ((state_r == pS_PRESAMP_FULL) && (state != pS_PRESAMP_FULL))
            presamp_running <= 1'b0;

        if (capture_go || next_segment_go_pre)
            presamp_fifo_filling <= 1'b0;
        else if ((state == pS_PRESAMP_FULL) && (state_r != pS_PRESAMP_FULL))
            presamp_fifo_filling <= 1'b1;

        if (presamp_fifo_filling && fast_fifo_wr) begin
            if (low_res) begin
                if (write_word_counter < 8)
                    write_word_counter <= write_word_counter + 1;
                else
                    write_word_counter <= 0;
            end
            else begin
                if (write_word_counter < 5)
                    write_word_counter <= write_word_counter + 1;
                else
                    write_word_counter <= 0;
            end

            if (write_word_counter == ((low_res)? 8 : 5))
                presample_fifo_count_wr <= 1'b1;
            else
                presample_fifo_count_wr <= 1'b0;

        end
        else if (!presamp_fifo_filling) begin
            write_word_counter <= 1;
            presample_fifo_count_wr <= 1'b0;
        end

        next_segment_go_r <= next_segment_go;
        // Note 1: capture_go condition is needed for the first segment of a segment_cycle_counter_en capture:
        // Note 2: state check is important to ensure that "error" conditions
        // (that are not real errors depending on the use-case)
        // don't clobber a previously stored offset (i.e. if multiple triggers
        // fire in a non-segmented capture)
        if ( (next_segment_go || (capture_go_r && !capture_go_r2)) &&
                  (state_idle || state_presamp_full || state_save_offset) )
            segment_offset <= (presample_i > 0)? write_word_counter : 0;
    end

    always @(posedge clk_usb) begin
        // Important note!
        // The (!fast_fifo_rd && !fast_fifo_empty) condition added to handle
        // issue which occurs only on-target with Xilinx FIFOs, never in
        // simulation: without this condition, the presample FIFO would
        // *occasionally* not empty which would ultimately result in remaining
        // stuck in pS_SEGMENT_DONE. This was seen when using segments with
        // presamples. A similar issue *should* have occurred with presamples
        // and no segments, but this was never observed. Can't get rid of the
        // Xilinx FIFOs fast enough...
        if (!presample_fifo_count_empty && (!fast_fifo_almost_empty || (!fast_fifo_rd && !fast_fifo_empty)) && !(presample_fifo_count_rd && presample_fifo_count_almost_empty)) begin
            presample_fifo_count_rd <= 1'b1;
        end
        else begin
            presample_fifo_count_rd <= 1'b0;
        end
    end


    // Note 1: the latency through this FIFO will NOT match that of
    // fast_fifo_wrapper, but that's ok since the logic around this accounts
    // for that.
    //
    // Note 2: a shallower depth could be used but would restrict the
    // *minimum* number of presamples. This may be surprising and is best
    // understood by comparing simulation waveforms with more vs fewer
    // presamples.
    //
    fifo_async #(
        .pDATA_WIDTH    (1), // ideally 0 but synthesis should optimize this out anyways
        .pDEPTH         (16),
        .pFALLTHROUGH   (1),
        .pFLOPS         (1),
        .pDISTRIBUTED   (0),
        .pBRAM          (0)
    ) U_presample_count_fifo (
        .wclk                   (adc_sampleclk),
        .rclk                   (clk_usb),
        .wrst_n                 (!reset),
        .rrst_n                 (!reset),
        .wfull_threshold_value  (0),
        .rempty_threshold_value (0),
        .wen                    (presample_fifo_count_wr),
        .wdata                  (1'b0),
        .wfull                  (presample_fifo_count_full),
        .walmost_full           (),
        .woverflow              (presample_fifo_count_overflow),
        .wfull_threshold        (),
        .ren                    (presample_fifo_count_rd),
        .rdata                  (),
        .rempty                 (presample_fifo_count_empty),
        .ralmost_empty          (presample_fifo_count_almost_empty),
        .rempty_threshold       (),
        .runderflow             (presample_fifo_count_underflow)
    );

    // Note: if segments are too close together, then presample fifo is likely
    // to overflow (because we won't be reading it because the fast FIFO isn't
    // almost empty yet). This gets captured elsewhere into presamp_error for
    // convenience (technically it's a segmenting error, but presamp/segment
    // errors are close relatives).
    wire presample_fifo_error = presample_fifo_count_overflow_reg || presample_fifo_count_underflow_reg;

    assign slow_fifo_din = (save_offset_usb)? {4'b0, segment_offset, 8'hFF, 8'h00, 8'hEE, 8'h11, 8'hDD, 8'h00, 8'hCC, 8'hFF} : fast_fifo_dout;

    reg [3:0] slow_read_count = 0; // 72/8 = 9 USB reads required for each FIFO read, regardless of low_res

    // Read slow FIFO:
    always @(posedge clk_usb) begin
       if (flushing) begin
          slow_read_count <= 0;
          slow_fifo_rd_slow <= 1'b0;
       end

       else if (fifo_read_fifoen || first_read) begin
       //else if (fifo_read_fifoen) begin
           if (slow_read_count < 8) begin
               slow_read_count <= slow_read_count + 1;
               slow_fifo_rd_slow <= 1'b0;
           end
           else begin
               slow_read_count <= 0;
               slow_fifo_rd_slow <= 1'b1;
           end
       end
       else
           slow_fifo_rd_slow <= 1'b0;
    end

    assign slow_fifo_rd_fast = fifo_read_fifoen && (slow_read_count == 8);

    assign slow_fifo_rd = (flushing && ~slow_fifo_empty) || ((fast_fifo_read_mode)? slow_fifo_rd_fast : slow_fifo_rd_slow);

    reg [7:0] fifo_read_data_pre;
    always @(*) begin
        if (slow_fifo_underflow_reg)
            fifo_read_data_pre = 0;
        else begin
            fifo_read_data_pre = slow_fifo_dout[(8-slow_read_count)*8 +: 8];
        end
    end
    // register the FIFO output to help meet timing
    always @(posedge clk_usb) begin
        if (arm_pulse_usb) begin
            first_read <= 1'b0;
            first_read_done <= 1'b0;
        end
        else if (first_read) begin
            first_read <= 1'b0;
            first_read_done <= 1'b1;
        end
        else if (!slow_fifo_empty && !first_read_done && !flushing) begin
            first_read <= 1'b1;
        end

        if (fifo_read_fifoen || first_read) fifo_read_data <= fifo_read_data_pre;

    end

    assign fast_fifo_rd = presample_fifo_count_rd || 
                          (fast_fifo_rd_en && !slow_fifo_full && !fast_fifo_empty) ||
                          (flushing && !fast_fifo_empty);

    // checked by testbench:
    wire debug_illegal_fast_fifo_rd = fast_fifo_rd && (state == pS_SAVE_OFFSET);

    // strictly for easier debugging:
    wire all_fifos_empty = fast_fifo_empty_adc | slow_fifo_empty;
    wire all_fifos_full  = fast_fifo_full  & slow_fifo_full;
    wire any_fifo_overunder = fast_fifo_underflow_reg | fast_fifo_overflow_reg | slow_fifo_underflow_reg | slow_fifo_overflow_reg;

    wire fast_fifo_empty_adc;
    fast_fifo_wrapper U_fast_fifo_wrapper (
        .wclk                   (adc_sampleclk),
        .rclk                   (clk_usb),
        .rst_n                  (~reset),
        .done_writing           (done_writing),
        .flushing               (flushing),
        .reset_internal_count   (reset_fast_fifo_internal_count),
        .low_res                (low_res),
        .low_res_lsb            (low_res_lsb),
        .fifo_wr                (fast_fifo_wr),
        .adc_datain             (adc_datain),
        .full                   (fast_fifo_full),
        .overflow               (fast_fifo_overflow),
        .fifo_rd                (fast_fifo_rd),
        .fifo_dout              (fast_fifo_dout),
        .empty_usb              (fast_fifo_empty),
        .empty_adc              (fast_fifo_empty_adc),
        .almost_empty           (fast_fifo_almost_empty),
        .underflow              (fast_fifo_underflow),
        .empty_stage1_usb       (empty_stage1_usb),
        .segment_error          (segment_error)
    );


    wire slow_fifo_stage2_wr;
    slow_fifo_wrapper U_slow_fifo_wrapper (
        .clk                    (clk_usb),
        .rst_n                  (~reset),
        .fast_fifo_empty        (fast_fifo_empty),
        .fifo_wr                (slow_fifo_wr),
        .fifo_din               (slow_fifo_din),
        .fifo_full              (slow_fifo_full),
        .fifo_full_threshold    (slow_fifo_full_threshold),
        .overflow               (slow_fifo_overflow),
        .fifo_rd                (slow_fifo_rd),
        .fifo_dout              (slow_fifo_dout),
        .fifo_empty             (slow_fifo_empty),
        .underflow              (slow_fifo_underflow),
        .stage2_wr              (slow_fifo_stage2_wr)
    );

    wire slow_fifo_full_adc;
    cdc_simple U_slow_fifo_full_cdc (
        .reset          (reset),
        .clk            (adc_sampleclk),
        .data_in        (slow_fifo_full),
        .data_out       (),
        .data_out_r     (slow_fifo_full_adc)
    );


   // track how many *words* (not samples or bytes, as used to be the case!) are available to be read:
   reg [31:0] write_count;
   always @(posedge clk_usb) begin
       if (arm_pulse_usb) begin
           write_count <= 0;
           read_count <= 0;
           stream_segment_available <= 1'b0;
       end
       else begin
           if (slow_fifo_stage2_wr)
               write_count <= write_count + 1;
           if (slow_fifo_rd)
               read_count <= read_count + 1;

           if (|error_stat[3:0])
               // if any FIFO overflow/underflow errors occur, ensure that SAM3U will be able to read as much as it wants
               // (so that the capture terminates normally on the SAM3U side)
               stream_segment_available <= 1'b1;
           else begin
               if (write_count > read_count)
                   stream_segment_available <= ( (write_count - read_count > stream_segment_threshold) || (write_count >= total_stream_words) );
               else
                   stream_segment_available <= 1'b0;
           end

       end
   end


   // for debug: count FIFO reads
   always @(posedge clk_usb) begin
      if (arm_pulse_usb) begin
         fifo_read_count <= 0;
         fifo_read_count_error_freeze <= 0;
      end
      else if (slow_fifo_rd) begin
         fifo_read_count <= fifo_read_count + 1;
         if (!error_flag)
            fifo_read_count_error_freeze <= fifo_read_count_error_freeze + 1;
      end
   end


   assign debug = {adc_capture_stop,
                   arm_pulse_adc,
                   armed_and_ready,
                   arming,
                   capture_go,
                   state};


   `ifdef ILA_HUSKY_FIFO
       `ifdef ILA_DEBUG_FAST_FIFO
           ila_fast_fifo U_ila_fast_fifo (
              .clk            (adc_sampleclk),        // input wire clk
              .probe0         (reset),                // input wire [0:0]  probe0  
              .probe1         (adc_datain),           // input wire [11:0] probe1 
              .probe2         (fast_fifo_wr),         // input wire [0:0]  probe2 
              .probe3         (fast_fifo_rd),         // input wire [7:0]  probe3 
              .probe4         (fast_fifo_dout),       // input wire [11:0] probe4 
              .probe5         (fast_fifo_full),       // input wire [0:0]  probe5 
              .probe6         (fast_fifo_empty),      // input wire [0:0]  probe6 
              .probe7         (fast_fifo_overflow),   // input wire [0:0]  probe7 
              .probe8         (fast_fifo_underflow),  // input wire [0:0]  probe8 
              .probe9         (downsample_wr_en),     // input wire [0:0]  probe9 
              .probe10        (fast_fifo_read_mode),  // input wire [0:0]  probe10 
              .probe11        (stream_segment_available), // input wire [0:0]  probe11 
              .probe12        (),                     // input wire [0:0]  probe12 
              
              .probe13        ()                ,     // input wire [0:0]  probe13 
              .probe14        (reset_hi_count),       // input wire [6:0]  probe14 
              .probe15        (reset_lo_count),       // input wire [9:0]  probe15 
              .probe16        (arm_pulse_adc),        // input wire [0:0]  probe16 
              .probe17        (capture_active),       // input wire [0:0]  probe17 

              .probe18        (adc_capture_stop),     // input wire [0:0]  probe18 
              .probe19        (presample_counter[11:0]), // input wire [11:0] probe19 
              .probe20        (sample_counter[11:0]),    // input wire [11:0] probe20 
              .probe21        (state_idle),           // input wire [0:0]  probe21
              .probe22        (state_presamp_filling),// input wire [0:0]  probe22
              .probe23        (state_presamp_full),   // input wire [0:0]  probe23
              .probe24        (state_triggered),      // input wire [0:0]  probe24
              .probe25        (state_done)            // input wire [0:0]  probe25
           );
       `else
           ila_lean_fast_fifo U_ila_fast_fifo (
              .clk            (adc_sampleclk),        // input wire clk
              .probe0         (reset),                // input wire [0:0]  probe0  
              .probe1         (fast_fifo_wr),         // input wire [0:0]  probe1 
              .probe2         (fast_fifo_rd),         // input wire [0:0]  probe2 
              .probe3         (fast_fifo_dout),       // input wire [11:0] probe3 
              .probe4         (fast_fifo_full),       // input wire [0:0]  probe4 
              .probe5         (fast_fifo_empty),      // input wire [0:0]  probe5 
              .probe6         (fast_fifo_overflow),   // input wire [0:0]  probe6 
              .probe7         (fast_fifo_underflow),  // input wire [0:0]  probe7 
              .probe8         (capture_active),       // input wire [0:0]  probe8 
              .probe9         (adc_capture_stop),     // input wire [0:0]  probe9 
              .probe10        (state_idle),           // input wire [0:0]  probe10
              .probe11        (state_presamp_filling),// input wire [0:0]  probe11
              .probe12        (state_presamp_full),   // input wire [0:0]  probe12
              .probe13        (state_triggered),      // input wire [0:0]  probe13
              .probe14        (state_done),           // input wire [0:0]  probe14
              .probe15        (error_stat),           // input wire [7:0]  probe15
              .probe16        (error_flag),           // input wire [0:0]  probe16
              .probe17        (adc_datain)            // input wire [11:0]  probe17
           );
       `endif


       ila_slow_fifo U_ila_slow_fifo (
          .clk            (clk_usb),              // input wire clk
          .probe0         (reset),                // input wire [0:0]  probe0  
          .probe1         (slow_fifo_din),        // input wire [35:0] probe1 
          .probe2         (slow_fifo_wr),         // input wire [0:0]  probe2 
          .probe3         (slow_fifo_rd),         // input wire [7:0]  probe3 
          .probe4         (slow_fifo_dout),       // input wire [35:0] probe4 
          .probe5         (slow_fifo_full),       // input wire [0:0]  probe5 
          .probe6         (slow_fifo_empty),      // input wire [0:0]  probe6 
          .probe7         (slow_fifo_overflow),   // input wire [0:0]  probe7 
          .probe8         (slow_fifo_underflow),  // input wire [0:0]  probe8 
          .probe9         (arm_pulse_usb),        // input wire [0:0]  probe9
          .probe10        (flushing),             // input wire [0:0]  probe10
          .probe11        (slow_fifo_rd_fast),    // input wire [0:0]  probe11
          .probe12        (fifo_read_fifoen),     // input wire [0:0]  probe12
          .probe13        (slow_read_count),      // input wire [3:0]  probe13
          .probe14        (stream_segment_available), // input wire [0:0]  probe14
          .probe15        (fast_fifo_read_mode)   // input wire [0:0]  probe15
       );

       ila_slow_fifo_wr U_ila_slow_fifo_wr (
          .clk            (adc_sampleclk),        // input wire clk
          .probe0         (reset),
          .probe1         (slow_fifo_din),      // 36
          .probe2         (fast_fifo_dout),     // 12
          .probe3         (fast_fifo_rd),
          .probe4         (slow_fifo_prewr),
          .probe5         (slow_fifo_wr),
          .probe6         (slow_fifo_full),
          .probe7         (slow_fifo_overflow),
          .probe8         (flushing)
       );


       /*
       ila_long_fifo U_ila_long_fifo (
          .clk            (clk_usb),              // input wire clk
          .probe0         (slow_fifo_wr),         // input wire [0:0]  probe0 
          .probe1         (slow_fifo_rd),         // input wire [0:0]  probe1 
          .probe2         (slow_fifo_full),       // input wire [0:0]  probe2 
          .probe3         (slow_fifo_empty),      // input wire [0:0]  probe3 
          .probe4         (slow_fifo_overflow),   // input wire [0:0]  probe4 
          .probe5         (slow_fifo_underflow),  // input wire [0:0]  probe5 
          .probe6         (stream_segment_available), // input wire [0:0]  probe6
          .probe7         (fast_fifo_overflow),   // input wire [0:0]  probe7 
          .probe8         (error_flag),           // input wire [0:0]  probe8 
          .probe9         (flushing),             // input wire [0:0]  probe8 
          .probe10        (arm_pulse_usb),        // input wire [0:0]  probe8 
          .probe11        (fast_fifo_empty_usb),  // input wire [0:0]  probe8 
          .probe12        (reg_write),            // input wire [0:0]  probe8 
          .probe13        (reg_datai),            // input wire [0:0]  probe8 
          .probe14        (reg_address),          // input wire [0:0]  probe8 
          .probe15        (state)                 // input wire [0:0]  probe8 
       );
       */

   `endif

   `ifdef ILA_FIFO_COUNTS
       ila_fifo_counts U_ila_fifo_counts (
          .clk            (clk_usb),              // input wire clk
          .probe0         (stream_segment_available),  // input wire [0:0]   probe0 
          .probe1         (write_count_to_usb[18:0]),  // input wire [18:0]  probe1 
          .probe2         (read_count[18:0]),          // input wire [18:0]  probe2 
          .probe3         (slow_fifo_rd),         // input wire [0:0]  probe3 
          .probe4         (slow_fifo_wr),         // input wire [0:0]  probe4 
          .probe5         (slow_fifo_full),       // input wire [0:0]  probe5 
          .probe6         (slow_fifo_empty),      // input wire [0:0]  probe6 
          .probe7         (slow_fifo_overflow),   // input wire [0:0]  probe7 
          .probe8         (slow_fifo_underflow),  // input wire [0:0]  probe8 
          .probe9         (error_flag),           // input wire [0:0]  probe9 
          .probe10        (fast_fifo_dout)        // input wire [11:0] probe10 
       );
   `endif

   `ifdef ILA_FIFO_GAIN
       ila_fifo_gain U_ila_fifo_gain (
          .clk            (clk_usb),              // input wire clk
          .probe0         (gain_error),           // input wire [0:0]  probe0 
          .probe1         (clip_error),           // input wire [0:0]  probe1 
          .probe2         (clear_fifo_errors_adc),// input wire [0:0]  probe2 
          .probe3         (clear_fifo_errors),    // input wire [0:0]  probe3 
          .probe4         (gain_error),           // input wire [0:0]  probe4 
          .probe5         (error_flag),           // input wire [0:0]  probe5 
          .probe6         (error_stat),           // input wire [8:0]  probe6 
          .probe7         (slow_fifo_wr),         // input wire [0:0]  probe7 
          .probe8         (slow_fifo_din)         // input wire [35:0] probe8 
       );
   `endif

   `ifdef ILA_SEGMENTS
       ila_segments U_ila_segments (
          .clk            (adc_sampleclk),        // input wire clk
          .probe0         (state_idle),           // input wire [0:0]  probe0 
          .probe1         (state_done),           // input wire [0:0]  probe1 
          .probe2         (state_presamp_filling),// input wire [0:0]  probe2 
          .probe3         (state_presamp_full),   // input wire [0:0]  probe3 
          .probe4         (state_triggered),      // input wire [0:0]  probe4 
          .probe5         (state_segment_done),   // input wire [0:0]  probe5 
          .probe6         (error_flag),           // input wire [0:0]  probe6 
          .probe7         (error_stat),           // input wire [7:0]  probe7 
          .probe8         (presamp_done),         // input wire [0:0]  probe8 
          .probe9         (segment_cycle_counter),// input wire [19:0] probe9 
          .probe10        (segment_counter),      // input wire [15:0] probe10 
          .probe11        (capture_go),           // input wire [0:0]  probe11
          .probe12        (capture_active),       // input wire [0:0]  probe12 
          .probe13        (fast_fifo_empty),      // input wire [0:0]  probe13 
          .probe14        (arm_pulse_adc),        // input wire [0:0]  probe14 
       );
   `endif

   `ifdef ILA_SEGMENTS2
       (* ASYNC_REG = "TRUE" *) reg slow_fifo_rd_adc;
       always @(posedge adc_sampleclk)
          slow_fifo_rd_adc <= slow_fifo_rd;

       ila_segments2 U_ila_segments2 (
          .clk            (clk_usb),              // input wire clk
          .probe0         (state_idle),           // input wire [0:0]  probe0 
          .probe1         (state_done),           // input wire [0:0]  probe1 
          .probe2         (state_presamp_filling),// input wire [0:0]  probe2 
          .probe3         (state_presamp_full),   // input wire [0:0]  probe3 
          .probe4         (state_triggered),      // input wire [0:0]  probe4 
          .probe5         (state_segment_done),   // input wire [0:0]  probe5 
          .probe6         (error_flag),           // input wire [0:0]  probe6 
          .probe7         (error_stat),           // input wire [7:0]  probe7 
          .probe8         (presamp_done),         // input wire [0:0]  probe8 
          .probe9         (next_segment_go),      // input wire [0:0]  probe9
          .probe10        (segment_counter[4:0]), // input wire [4:0]  probe10 
          .probe11        (capture_go),           // input wire [0:0]  probe11
          .probe12        (capture_active),       // input wire [0:0]  probe12 
          .probe13        (fast_fifo_empty),      // input wire [0:0]  probe13 
          .probe14        (arm_pulse_usb),        // input wire [0:0]  probe14 
          //.probe15        (adc_datain),           // input wire [11:0] probe15
          .probe15        (segment_cycle_counter[11:0]), // input wire [11:0] probe15
          .probe16        (fast_fifo_wr),         // input wire [0:0]  probe16
          .probe17        (fast_fifo_rd),         // input wire [0:0]  probe17
          .probe18        (fast_fifo_dout),       // input wire [11:0] probe18
          .probe19        (slow_fifo_wr),         // input wire [0:0]  probe19
          .probe20        (slow_fifo_rd_adc),     // input wire [0:0]  probe20
          .probe21        (slow_fifo_full),       // input wire [0:0]  probe21
          .probe22        (slow_fifo_overflow_reg),// input wire [0:0] probe22
          .probe23        (slow_fifo_underflow_reg) // input wire [0:0] probe23
       );

   `endif


   `ifdef ILA_RESET
       ila_reset_fifo U_ila_reset_fifo (
          .clk            (adc_sampleclk),
          .probe0         (reset),
          .probe1         (state),                      // 3
          .probe2         (presample_counter),          // 15
          .probe3         (sample_counter),             // 32
          .probe4         (fast_fifo_presample_drain),
          .probe5         (adc_capture_stop),
          .probe6         (fast_fifo_rd_en),
          .probe7         (segment_counter),            // 16
          .probe8         (segment_cycle_counter),      // 20
          .probe9         (filling_out_to_done),
          .probe10        (flushing),
          .probe11        (flushing_adc),
          .probe12        (flushing_adc_usb),
          .probe13        (arming),
          .probe14        (armed_and_ready),
          .probe15        (capture_go_r),
          .probe16        (underflow_count),            // 8
          .probe17        (slow_fifo_underflow_reg),
          .probe18        (slow_fifo_underflow_count),
          .probe19        (fast_write_count),           // 3
          .probe20        (fast_read_count),            // 2
          .probe21        (slow_fifo_prewr),
          .probe22        (slow_read_count),            // 4
          .probe23        (slow_fifo_rd_slow),
          .probe24        (slow_fifo_dout_r)            // 4
      );

   `endif


endmodule
`default_nettype wire
