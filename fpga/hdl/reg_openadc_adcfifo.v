`include "includes.v"
`timescale 1 ns / 1 ps
`default_nettype none
/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more
details, or the codebase at http://www.chipwhisperer.com

Copyright (c) 2013-2021, NewAE Technology Inc. All rights reserved.
Author: Colin O'Flynn <coflynn@newae.com>

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

module reg_openadc_adcfifo #(
   parameter pBYTECNT_SIZE = 7
)(
   input  wire         reset_i,
   input  wire         clk_usb,
   input  wire         ui_clk,
   input  wire [7:0]   reg_address,  // Address of register
   input  wire [pBYTECNT_SIZE-1:0]  reg_bytecnt,  // Current byte count
   input  wire [7:0]   reg_datai,    // Data to write
   output wire [7:0]   reg_datao,    // Data to read
   input  wire         reg_read,     // Read flag
   input  wire         reg_write,    // Write flag

   /* ADC Fifo Interface */
   input  wire [6:0]   state,
   input  wire         fifo_empty,
   output wire         fifo_rd_en,
   output reg          low_res,
   output reg          low_res_lsb,
   output reg          fast_fifo_read_mode,
   output reg  [16:0]  stream_segment_threshold,
   input  wire [12:0]  fifo_error_stat,
   input  wire [12:0]  fifo_first_error_stat,
   input  wire [2:0]   fifo_first_error_state,
   output reg          clear_fifo_errors,

   input  wire [7:0]   underflow_count,
   output reg          no_underflow_errors,
   input  wire         capture_done,
   output reg          O_data_source_select,

   input  wire [1:0]   trace_fifo_errors,
   input  wire [1:0]   la_fifo_errors,
   input  wire         adc_flushing,
   input  wire         la_flushing,
   input  wire         trace_flushing,
   input  wire         postddr_flush,

   // DDR3 (Pro) stuff:
   output reg          O_use_ddr,
   output reg          O_ddr3_rwtest_en,
   output reg          O_ddr3_clear_fail,
   output reg          O_xo_en,
   output reg          O_vddr_enable,
   input  wire         I_vddr_pgood,
   input  wire         I_ddr3_pass,
   input  wire         I_ddr3_fail,
   input  wire [6:0]   I_ddr3_stat,
   input  wire [15:0]  I_ddr3_iteration,
   input  wire [7:0]   I_ddr3_errors,
   input  wire [31:0]  I_ddr3_read_read,
   input  wire [31:0]  I_ddr3_read_idle,
   input  wire [31:0]  I_ddr3_write_write,
   input  wire [31:0]  I_ddr3_write_idle,
   input  wire [15:0]  I_ddr3_max_read_stall_count,
   input  wire [15:0]  I_ddr3_max_write_stall_count,

   output reg          ddr_single_write,
   output reg          ddr_single_read,
   output reg  [29:0]  ddr_single_address,
   output reg  [63:0]  ddr_single_write_data,
   input  wire [63:0]  ddr_single_read_data,
   input  wire         ddr_read_data_done,
   input  wire         ddr_single_done,
   input  wire         ddr_write_data_done,
   output reg  [29:0]  ddr_la_start_address,
   output reg  [29:0]  ddr_trace_start_address,
   output reg          ddr_start_la_read,
   output reg          ddr_start_trace_read,
   output reg          ddr_start_adc_read,

   // for debug only:
   input  wire [31:0]  fifo_read_count,
   input  wire [31:0]  fifo_read_count_error_freeze
);

   wire  reset;
   assign reset = reset_i;

   reg fifo_rd_en_reg;
   reg [5:0] reg_read_pipe;
   wire reg_read_r = reg_read_pipe[0];

   // in fast FIFO read mode, need to shave off a clock cycle:
   assign fifo_rd_en = fast_fifo_read_mode? reg_read & ~reg_read_r : fifo_rd_en_reg;

   reg [7:0] reg_datao_reg;
   assign reg_datao = reg_datao_reg;

   wire [23:0] fifo_stat = {1'b0,               // 23
                            trace_flushing | postddr_flush,     // 22
                            la_flushing | postddr_flush,        // 21
                            adc_flushing | postddr_flush,       // 20
                            trace_fifo_errors,  // 19:18
                            la_fifo_errors,     // 17:16
                            2'b0,               // 15:14
                            fifo_empty,         // 13 (this is post-ddr/slow FIFO empty)
                            fifo_error_stat};   // 12:0

   wire [159:0] ddr3_rw_stats = {I_ddr3_read_read,              // 159:128
                                 I_ddr3_read_idle,              // 127:96
                                 I_ddr3_write_write,            // 95:64
                                 I_ddr3_write_idle,             // 63:32
                                 I_ddr3_max_read_stall_count,   // 31:16
                                 I_ddr3_max_write_stall_count}; // 15:0

   wire ddr_single_done_usb;
   wire ddr_read_data_done_usb;

   wire [23:0] fifo_first_error_combined;
   assign fifo_first_error_combined[23:16] = {5'b0, fifo_first_error_state};
   assign fifo_first_error_combined[15:0] = {3'b0, fifo_first_error_stat};

   wire [23:0] ddr3_stats;
   assign ddr3_stats[23:16] = I_ddr3_errors;
   assign ddr3_stats[15:8]  = {6'b0, I_ddr3_fail, I_ddr3_pass};
   assign ddr3_stats[7:0]   = {1'b0, I_ddr3_stat};

   always @(*) begin
      if (reg_read) begin
         case (reg_address)
            `FIFO_STAT:                 reg_datao_reg = fifo_stat[reg_bytecnt*8 +: 8];
            `FIFO_STATE:                reg_datao_reg = {1'b0, state};
            `FIFO_FIRST_ERROR:          reg_datao_reg = fifo_first_error_combined[reg_bytecnt*8 +: 8];
            `DEBUG_FIFO_READS:          reg_datao_reg = fifo_read_count[reg_bytecnt*8 +: 8];
            `DEBUG_FIFO_READS_FREEZE:   reg_datao_reg = fifo_read_count_error_freeze[reg_bytecnt*8 +: 8];
            `STREAM_SEGMENT_THRESHOLD:  reg_datao_reg = stream_segment_threshold[reg_bytecnt*8 +: 8];
            `ADC_LOW_RES:               reg_datao_reg = {6'b0, low_res_lsb, low_res};
            `FIFO_UNDERFLOW_COUNT:      reg_datao_reg = underflow_count;
            `FIFO_NO_UNDERFLOW_ERROR:   reg_datao_reg = {7'b0, no_underflow_errors};
            `CAPTURE_DONE:              reg_datao_reg = {7'b0, capture_done};

            // DDR stuff for Pro:
            `REG_DDR3_STAT:             reg_datao_reg = ddr3_stats[reg_bytecnt*8 +: 8];
            `REG_DDR3_TEST_LOOPS:       reg_datao_reg = I_ddr3_iteration[reg_bytecnt*8 +: 8];
            `REG_XO_EN:                 reg_datao_reg = {5'b0, I_vddr_pgood, O_vddr_enable, O_xo_en};
            `REG_DDR3_RW_STATS:         reg_datao_reg = ddr3_rw_stats[reg_bytecnt*8 +: 8];
            `FIFO_CONFIG:               reg_datao_reg = {6'b0, O_data_source_select, O_use_ddr};
            `REG_DDR_SINGLE_RW_DATA:    reg_datao_reg = ddr_single_read_data[reg_bytecnt*8 +: 8];
            `REG_DDR_SINGLE_RW_ADDR:    reg_datao_reg = {6'b0, ddr_single_read, ddr_single_write};
            `REG_DDR_LA_START_ADDR:     reg_datao_reg = ddr_la_start_address[reg_bytecnt*8 +: 8];
            `REG_DDR_TRACE_START_ADDR:  reg_datao_reg = ddr_trace_start_address[reg_bytecnt*8 +: 8];
            `REG_DDR_START_READ:        reg_datao_reg = {ddr_write_data_done, 4'b0, ddr_start_trace_read, ddr_start_la_read, ddr_start_adc_read };
            default:                    reg_datao_reg = 0;
         endcase
      end
      else
         reg_datao_reg = 0;
   end

   always @(posedge clk_usb) begin
      if (reset) begin
         low_res <= 0;
         low_res_lsb <= 0;
         clear_fifo_errors <= 1'b0;
         stream_segment_threshold <= 65536;
         no_underflow_errors <= 1'b0;   // disables flagging of *slow* FIFO underflow errors only
         O_ddr3_rwtest_en <= 1'b0;
         O_ddr3_clear_fail <= 1'b0;
         O_vddr_enable <= 1'b0;
         O_xo_en <= 1'b0;
         O_use_ddr <= 1'b1;
         O_data_source_select <= 1; // default to ADC
         `ifdef __ICARUS__
             // Use different defaults, due to the smaller DDR address space in simulation.
             // Convention is trace start address > LA start address, and ADC start address is 0; 
             // error checking on crossing boundaries assumes this.
             ddr_la_start_address    <= 30'h0001_0000;
             ddr_trace_start_address <= 30'h0004_0000;
         `else
             ddr_la_start_address    <= 30'h1000_0000;
             ddr_trace_start_address <= 30'h2000_0000;
         `endif
      end 
      else if (reg_write) begin
         case (reg_address)
            `ADC_LOW_RES:               {low_res_lsb, low_res} <= reg_datai[1:0];
            `STREAM_SEGMENT_THRESHOLD:  stream_segment_threshold[reg_bytecnt*8 +: 8] <= reg_datai; 
            `FIFO_STAT:                 clear_fifo_errors <= reg_datai[0];
            `FIFO_NO_UNDERFLOW_ERROR:   no_underflow_errors <= reg_datai[0];
            `REG_DDR3_STAT:             {O_ddr3_clear_fail, O_ddr3_rwtest_en} <= reg_datai[1:0];
            `REG_XO_EN:                 {O_vddr_enable, O_xo_en} <= reg_datai[1:0];
            `FIFO_CONFIG:               {O_data_source_select, O_use_ddr} <= reg_datai[1:0];
            `REG_DDR_SINGLE_RW_DATA:    ddr_single_write_data[reg_bytecnt*8 +: 8] <= reg_datai;
            `REG_DDR_SINGLE_RW_ADDR:    ddr_single_address[reg_bytecnt*8 +: 8] <= reg_datai;
            `REG_DDR_LA_START_ADDR:     ddr_la_start_address[reg_bytecnt*8 +: 8] <= reg_datai;
            `REG_DDR_TRACE_START_ADDR:  ddr_trace_start_address[reg_bytecnt*8 +: 8] <= reg_datai;
            default: ;
         endcase
      end
   end

   // REG_DDR_START_READ register is special:
   always @(posedge clk_usb) begin
      if (reset) begin
         ddr_start_adc_read <= 1'b0;
         ddr_start_trace_read <= 1'b0;
         ddr_start_la_read <= 1'b0;
      end 
      else if (ddr_read_data_done_usb) begin
          ddr_start_adc_read <= 1'b0;
          ddr_start_trace_read <= 1'b0;
          ddr_start_la_read <= 1'b0;
      end
      else if (reg_write && (reg_address == `REG_DDR_START_READ))
          {ddr_start_trace_read, ddr_start_la_read, ddr_start_adc_read} <= reg_datai[2:0];
   end


   always @(posedge clk_usb) begin
      if (reset) begin
          ddr_single_write <= 1'b0;
          ddr_single_read <= 1'b0;
      end
      else if (ddr_single_done_usb) begin
          ddr_single_write <= 1'b0;
          ddr_single_read <= 1'b0;
      end
      else if (reg_write && (reg_address == `REG_DDR_SINGLE_RW_ADDR) && (reg_bytecnt == 3)) begin
          if (reg_datai[7])
              ddr_single_write <= 1'b1;
          else
              ddr_single_read <= 1'b1;
      end
  end

  cdc_pulse U_single_done_cdc (
     .reset_i       (reset),
     .src_clk       (ui_clk),
     .src_pulse     (ddr_single_done),
     .dst_clk       (clk_usb),
     .dst_pulse     (ddr_single_done_usb)
  );

  cdc_pulse U_read_done_cdc (
     .reset_i       (reset),
     .src_clk       (ui_clk),
     .src_pulse     (ddr_read_data_done),
     .dst_clk       (clk_usb),
     .dst_pulse     (ddr_read_data_done_usb)
  );


   always @(posedge clk_usb) begin
      if (reset) begin
         fast_fifo_read_mode <= 1'b0;
      end
      else if (reg_write) begin
         if (reg_address == `FAST_FIFO_READ_MODE)
            fast_fifo_read_mode <= reg_datai[0];
         else if (fast_fifo_read_mode) // need to clear it on any other write!
            fast_fifo_read_mode <= 1'b0;
      end
   end

   wire fifo_rd_en_condition;
   `ifdef CW310
       // accomodate slower read times on CW310:
       assign fifo_rd_en_condition = reg_read_pipe[4] && ~reg_read_pipe[5];
   `else
       assign fifo_rd_en_condition = reg_read && ~reg_read_r;
   `endif
   always @(posedge clk_usb) begin
      reg_read_pipe <= {reg_read_pipe[4:0], reg_read};
      if (fifo_rd_en_condition && (reg_address == `ADCREAD_ADDR)) begin
         fifo_rd_en_reg <= 1;
      end else begin
         fifo_rd_en_reg <= 0;
      end
   end


endmodule
`default_nettype wire
