// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (lin64) Build 3064766 Wed Nov 18 09:12:47 MST 2020
// Date        : Mon Apr 10 13:38:51 2023
// Host        : red running 64-bit Ubuntu 18.04.6 LTS
// Command     : write_verilog -force -mode synth_stub -rename_top usb_slow_fifo_semipro -prefix
//               usb_slow_fifo_semipro_ usb_slow_fifo_stub.v
// Design      : usb_slow_fifo
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a100tftg256-3
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_2_5,Vivado 2020.2" *)
module usb_slow_fifo_semipro(rst, wr_clk, rd_clk, din, wr_en, rd_en, dout, full, 
  overflow, empty, underflow)
/* synthesis syn_black_box black_box_pad_pin="rst,wr_clk,rd_clk,din[35:0],wr_en,rd_en,dout[35:0],full,overflow,empty,underflow" */;
  input rst;
  input wr_clk;
  input rd_clk;
  input [35:0]din;
  input wr_en;
  input rd_en;
  output [35:0]dout;
  output full;
  output overflow;
  output empty;
  output underflow;
endmodule
