// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (lin64) Build 3064766 Wed Nov 18 09:12:47 MST 2020
// Date        : Thu Apr 20 20:21:24 2023
// Host        : red running 64-bit Ubuntu 18.04.6 LTS
// Command     : write_verilog -force -mode synth_stub
//               /home/jpnewae/git/cw_husky_semipro/fpga/vivado/cwhusky_semipro.srcs/sources_1/ip/fifo_generator_semipro/fifo_generator_semipro_stub.v
// Design      : fifo_generator_semipro
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tftg256-3
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_2_5,Vivado 2020.2" *)
module fifo_generator_semipro(rst, wr_clk, rd_clk, din, wr_en, rd_en, dout, full, 
  empty, underflow, prog_full, prog_empty)
/* synthesis syn_black_box black_box_pad_pin="rst,wr_clk,rd_clk,din[17:0],wr_en,rd_en,dout[17:0],full,empty,underflow,prog_full,prog_empty" */;
  input rst;
  input wr_clk;
  input rd_clk;
  input [17:0]din;
  input wr_en;
  input rd_en;
  output [17:0]dout;
  output full;
  output empty;
  output underflow;
  output prog_full;
  output prog_empty;
endmodule
