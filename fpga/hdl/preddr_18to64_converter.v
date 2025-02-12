`include "includes.v"
`timescale 1 ns / 1 ps
`default_nettype none

/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more
details, or the codebase at http://www.chipwhisperer.com
Built from fifo_top_husky.v and modified for Pro.

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

module preddr_18to64_converter (
    input wire          reset,
    input wire          wr_clk,
    input wire          rd_clk,
    input wire          enabled,
    input wire          capture_start,
    input wire          capture_done,
    input wire          I_fifo_flush,
    input wire [17:0]   I_data,
    input wire          I_wr,
    input wire          I_4bit_mode,
    input wire          clear_fifo_errors,

    input  wire         fifo_rd,
    output wire [63:0]  fifo_dout,
    output wire         fifo_empty,
    output reg          capture_done_out,
    output wire         capture_start_out,
    output wire [1:0]   fifo_errors,
    output wire         fifo_full
);


    // Assemble 64-bit words from 18-bit samples to feed DDR. Same approach as
    // fifo_top_husky_pro.v, different incoming width.
    reg [3:0] wide_word_count;
    reg wide_word_valid;
    reg wide_word_valid_r;
    reg [89:0] wide_word_shifter;
    reg [2:0] sample_counter;
    reg [63:0] fifo_din;
    reg fifo_wr = 1'b0;
    wire fifo_empty_raw;
    wire capture_done_rd;
    reg done_hold;
    reg fifo_empty_raw_r;
    reg capture_done_r;

    wire fifo_overflow;
    wire fifo_underflow;

    reg  fifo_overflow_sticky = 1'b0;
    reg  fifo_underflow_sticky = 1'b0;

    wire fifo_rd_rd = fifo_rd || (I_fifo_flush & ~fifo_empty);

    assign fifo_empty = (enabled)? fifo_empty_raw : 1'b1; // to prevent X's when there is no clock

    assign fifo_errors = {fifo_overflow_sticky, fifo_underflow_sticky};
    wire error_flag = |fifo_errors; // convenience for testbench

    // Generate filler writes, so that all the data we received is pushed out
    // when it's not a multiple of 64 bits; mark "capture done" for the read
    // side when this filler write is done (instead of using the
    // "capture_done" input which doesn't account for these filler writes).
    reg filler_write;
    reg filler_write_r;
    wire writing_done;
    reg writing_done_r;
    reg fifo_written;
    always @(posedge wr_clk) begin
        if (reset) begin
            filler_write <= 1'b0;
            filler_write_r  <= 1'b0;
            fifo_written <= 1'b0;
        end
        else begin
            filler_write_r <= filler_write;
            writing_done_r <= writing_done;

            if (I_4bit_mode)
                fifo_written <= 1'b1;
            else begin
                // in 9-bit mode, wait to see *2* fifo writes after capture_done, otherwise data
                // may not all get through:
                if (filler_write && fifo_wr)
                    fifo_written <= 1'b1;
                else if (~filler_write)
                    fifo_written <= 1'b0;
            end

            if (capture_done_r)
                filler_write <= 1'b1;
            else if (capture_start || (fifo_written && fifo_wr))
                filler_write <= 1'b0;
        end
    end
    assign writing_done = filler_write_r && ~filler_write;

    always @(posedge wr_clk) begin
        if (reset) begin
            wide_word_count <= 0;
            wide_word_valid <= 0;
            wide_word_valid_r <= 0;
            wide_word_shifter <= 0;
            sample_counter <= 0;
            fifo_din <= 0;
            fifo_wr <= 0;
            capture_done_r <= 0;
        end
        else begin
            wide_word_valid_r <= wide_word_valid;
            capture_done_r <= capture_done;
            if (enabled) begin
                fifo_wr <= wide_word_valid && ~wide_word_valid_r;
                if (capture_start) begin
                    wide_word_count <= 0;
                    wide_word_valid <= 0;
                    wide_word_shifter <= 0;
                    sample_counter <= 0;
                end
                else if (I_wr || filler_write) begin
                    if (I_4bit_mode) begin
                        wide_word_shifter <= {wide_word_shifter[81:0], I_data[7:0]};
                        if (sample_counter == 7) begin
                            wide_word_valid <= 1'b1;
                            sample_counter <= 0;
                        end
                        else begin
                            wide_word_valid <= 0;
                            sample_counter <= sample_counter + 1;
                        end
                    end

                    else begin // 18-bit capture
                        wide_word_shifter <= {wide_word_shifter[71:0], I_data};
                        if ( ((wide_word_count == 0) && (sample_counter == 4)) ||
                             ((wide_word_count == 1) && (sample_counter == 3)) ||
                             ((wide_word_count == 2) && (sample_counter == 4)) ||
                             ((wide_word_count == 3) && (sample_counter == 3)) ||
                             ((wide_word_count == 4) && (sample_counter == 4)) ||
                             ((wide_word_count == 5) && (sample_counter == 3)) ||
                             ((wide_word_count == 6) && (sample_counter == 4)) ||
                             ((wide_word_count == 7) && (sample_counter == 3)) ||
                             ((wide_word_count == 8) && (sample_counter == 4)) ) begin
                            wide_word_valid <= 1'b1;
                            sample_counter <= 1;        // reset to 1 instead of 0 to make the above conditions work
                                                        // in light of the fact that the very first valid word requires
                                                        // an extra read to fill up wide_word_shifter
                            if (wide_word_count < 8)
                                wide_word_count <= wide_word_count + 1;
                            else
                                wide_word_count <= 0;
                        end
                        else begin
                            wide_word_valid <= 0;
                            sample_counter <= sample_counter + 1;
                        end
                    end


                end

                if (wide_word_valid) begin
                    if (I_4bit_mode)
                        fifo_din <= wide_word_shifter[63:0];

                    else
                        fifo_din <= (wide_word_count == 1)? wide_word_shifter[89:26] :
                                    (wide_word_count == 2)? wide_word_shifter[79:16] :
                                    (wide_word_count == 3)? wide_word_shifter[87:24] :
                                    (wide_word_count == 4)? wide_word_shifter[77:14] :
                                    (wide_word_count == 5)? wide_word_shifter[85:22] :
                                    (wide_word_count == 6)? wide_word_shifter[75:12] :
                                    (wide_word_count == 7)? wide_word_shifter[83:20] :
                                    (wide_word_count == 8)? wide_word_shifter[73:10] :
                                                            wide_word_shifter[81:18] ;

                end
            end

            else begin
                wide_word_count <= 0;
                wide_word_valid <= 0;
                wide_word_shifter <= 0;
                sample_counter <= 0;
                fifo_din <= 0;
                fifo_wr <= 0;
            end
        end
    end

    always @(posedge rd_clk) begin
        if (reset) begin
            done_hold <= 1'b0;
            capture_done_out <= 1'b0;
            fifo_empty_raw_r <= 1'b0;
        end
        else if (enabled) begin
            // The capture_done pulse activates a hold signal; then when the FIFO
            // goes empty, we know we are done:
            fifo_empty_raw_r <= fifo_empty_raw;
            if (capture_done_rd)
                done_hold <= 1'b1;
            else if (capture_done_out)
                capture_done_out <= 1'b0;
            else if (done_hold && fifo_empty_raw && fifo_empty_raw_r) begin
                capture_done_out <= 1'b1;
                done_hold <= 1'b0;
            end
        end
        else begin
            done_hold <= 1'b0;
            capture_done_out <= 1'b0;
            fifo_empty_raw_r <= 1'b0;
        end
    end

    always @(posedge wr_clk) begin
        // lazily don't CDC clear_fifo_errors since it's set and cleared from Python
        if (clear_fifo_errors || capture_start)
            fifo_overflow_sticky <= 1'b0;
        else if (fifo_overflow)
            fifo_overflow_sticky <= 1'b1;
    end

    always @(posedge rd_clk) begin
        if (clear_fifo_errors || capture_start_out)
            fifo_underflow_sticky <= 1'b0;
        else if (fifo_underflow)
            fifo_underflow_sticky <= 1'b1;
    end


    cdc_pulse U_done (
        .reset_i       (reset),
        .src_clk       (wr_clk),
        .src_pulse     (writing_done_r),
        .dst_clk       (rd_clk),
        .dst_pulse     (capture_done_rd)
    );

    cdc_pulse U_capture_start_cdc (
        .reset_i       (reset),
        .src_clk       (wr_clk),
        .src_pulse     (capture_start && enabled),
        .dst_clk       (rd_clk),
        .dst_pulse     (capture_start_out)
    );


    // debug only: give each 9-bit "word" 16 bits, so we can follow the data
    wire [159:0] wider_word_shifter_debug;
    assign wider_word_shifter_debug[159:144] = {7'b0, wide_word_shifter[89:81]};
    assign wider_word_shifter_debug[143:128] = {7'b0, wide_word_shifter[80:72]};
    assign wider_word_shifter_debug[127:112] = {7'b0, wide_word_shifter[71:63]};
    assign wider_word_shifter_debug[111: 96] = {7'b0, wide_word_shifter[62:54]};
    assign wider_word_shifter_debug[ 95: 80] = {7'b0, wide_word_shifter[53:45]};
    assign wider_word_shifter_debug[ 79: 64] = {7'b0, wide_word_shifter[44:36]};
    assign wider_word_shifter_debug[ 63: 48] = {7'b0, wide_word_shifter[35:27]};
    assign wider_word_shifter_debug[ 47: 32] = {7'b0, wide_word_shifter[26:18]};
    assign wider_word_shifter_debug[ 31: 16] = {7'b0, wide_word_shifter[17: 9]};
    assign wider_word_shifter_debug[ 15:  0] = {7'b0, wide_word_shifter[ 8: 0]};

`ifdef __ICARUS__
    // debug only
    reg [31:0] fifo_writes = 0;
    reg [31:0] fifo_reads = 0;
    always @(posedge wr_clk) if (fifo_wr) fifo_writes <= fifo_writes + 1;
    always @(posedge rd_clk) if (fifo_rd) fifo_reads <= fifo_reads + 1;
`endif

`ifdef NOXILINXFIFO
    `ifdef TINYFIFO
        fifo_async #(
            .pDATA_WIDTH    (64),
            .pDEPTH         (512),
            .pFALLTHROUGH   (0),
            .pFLOPS         (0),
            .pDISTRIBUTED   (0),
            .pBRAM          (1)
        ) U_pre_ddr_fifo (
            .wclk                   (wr_clk),
            .rclk                   (rd_clk),
            .wrst_n                 (~reset),
            .rrst_n                 (~reset),
            .wfull_threshold_value  (0),
            .rempty_threshold_value (0),
            .wen                    (fifo_wr),
            .wdata                  (fifo_din),
            .wfull                  (fifo_full),
            .walmost_full           (),
            .woverflow              (fifo_overflow),
            .wfull_threshold        (),
            .rempty_threshold       (),
            .ren                    (fifo_rd_rd),
            .rdata                  (fifo_dout),
            .rempty                 (fifo_empty_raw),
            .ralmost_empty          (),
            .runderflow             (fifo_underflow)
        );
    `else
        fifo_async #(
            .pDATA_WIDTH    (64),
            .pDEPTH         (4096),
            .pFALLTHROUGH   (0),
            .pFLOPS         (0),
            .pDISTRIBUTED   (0),
            .pBRAM          (1)
        ) U_pre_ddr_fifo (
            .wclk                   (wr_clk),
            .rclk                   (rd_clk),
            .wrst_n                 (~reset),
            .rrst_n                 (~reset),
            .wfull_threshold_value  (0),
            .rempty_threshold_value (0),
            .wen                    (fifo_wr),
            .wdata                  (fifo_din),
            .wfull                  (fifo_full),
            .walmost_full           (),
            .woverflow              (fifo_overflow),
            .wfull_threshold        (),
            .rempty_threshold       (),
            .ren                    (fifo_rd_rd),
            .rdata                  (fifo_dout),
            .rempty                 (fifo_empty_raw),
            .ralmost_empty          (),
            .runderflow             (fifo_underflow)
        );
    `endif

`else
    pre_ddr_generic_fifo U_pre_ddr_fifo (
       .rst          (reset),
       .wr_clk       (wr_clk),
       .rd_clk       (rd_clk),
       .din          (fifo_din),
       .wr_en        (fifo_wr),
       .rd_en        (fifo_rd_rd),
       .dout         (fifo_dout),
       .full         (fifo_full),
       .empty        (fifo_empty_raw),
       .overflow     (fifo_overflow),
       .underflow    (fifo_underflow)
    );
`endif // NOXILINXFIFO

`ifdef ILA_PREDDR_CONVERTER
    ila_preddr_converter U_preddr_converter (
        .clk            (wr_clk),               // input wire clk
        .probe0         (reset),                // input wire [0:0]  
        .probe1         (fifo_wr),              // input wire [0:0]  
        .probe2         (fifo_din),             // input wire [63:0] 
        .probe3         (fifo_full),            // input wire [0:0]  
        .probe4         (fifo_empty_raw),       // input wire [0:0]  
        .probe5         (fifo_overflow),        // input wire [0:0]  
        .probe6         (fifo_underflow),       // input wire [0:0]  
        .probe7         (wide_word_valid),      // input wire [0:0]  
        .probe8         (wide_word_shifter),    // input wire [89:0] 
        .probe9         (wide_word_count),      // input wire [3:0]  
        .probe10        (sample_counter),       // input wire [2:0] 
        .probe11        (capture_start),        // input wire [0:0]  
        .probe12        (I_data),               // input wire [17:0]  
        .probe13        (capture_done),         // input wire [0:0]  
        .probe14        (I_wr),                 // input wire [0:0]  
        .probe15        (I_4bit_mode)           // input wire [0:0]  
    );

    ila_preddr_converter_rd U_preddr_converter_rd (
        .clk            (rd_clk),               // input wire clk
        .probe0         (reset),                // input wire [0:0]  
        .probe1         (fifo_rd),              // input wire [0:0]  
        .probe2         (fifo_dout),            // input wire [63:0] 
        .probe3         (fifo_empty_raw),       // input wire [0:0]  
        .probe4         (capture_done_out),     // input wire [0:0]  
        .probe5         (capture_start_out),    // input wire [0:0]  
        .probe6         (fifo_underflow),       // input wire [0:0]  
        .probe7         (done_hold),            // input wire [0:0]  
        .probe8         (capture_done_rd)       // input wire [0:0]  
    );

`endif


endmodule
`default_nettype wire
