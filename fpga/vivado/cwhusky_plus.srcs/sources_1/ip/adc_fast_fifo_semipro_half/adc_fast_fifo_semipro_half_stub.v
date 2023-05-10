// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (lin64) Build 3064766 Wed Nov 18 09:12:47 MST 2020
// Date        : Wed May 10 11:48:04 2023
// Host        : red running 64-bit Ubuntu 20.04.6 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/jpnewae/git/cw_husky_semipro/fpga/vivado/cwhusky_plus.srcs/sources_1/ip/adc_fast_fifo_semipro_half/adc_fast_fifo_semipro_half_stub.v
// Design      : adc_fast_fifo_semipro_half
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tftg256-3
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_2_5,Vivado 2020.2" *)
module adc_fast_fifo_semipro_half(clk, rst, din, wr_en, rd_en, dout, full, overflow, empty, 
  underflow)
/* synthesis syn_black_box black_box_pad_pin="clk,rst,din[11:0],wr_en,rd_en,dout[11:0],full,overflow,empty,underflow" */;
  input clk;
  input rst;
  input [11:0]din;
  input wr_en;
  input rd_en;
  output [11:0]dout;
  output full;
  output overflow;
  output empty;
  output underflow;
endmodule
