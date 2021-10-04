// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
// Date        : Fri Sep 17 13:05:56 2021
// Host        : qed running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Users/jp/GitHub/OpenTitan/husky/fpga/vivado/cwhusky.srcs/sources_1/ip/adc_fast_fifo/adc_fast_fifo_stub.v
// Design      : adc_fast_fifo
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tftg256-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_2_5,Vivado 2020.2" *)
module adc_fast_fifo(clk, rst, din, wr_en, rd_en, dout, full, overflow, empty, 
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
