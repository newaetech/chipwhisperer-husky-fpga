// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
// Date        : Wed Feb 24 10:16:04 2021
// Host        : qed running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               C:/Users/jp/GitHub/OpenTitan/husky/fpga/vivado/cwhusky.srcs/sources_1/ip/MMCM_clkgen/MMCM_clkgen_stub.v
// Design      : MMCM_clkgen
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tftg256-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module MMCM_clkgen(clk_out1, daddr, dclk, den, din, dout, drdy, dwe, reset, 
  locked, clk_in1)
/* synthesis syn_black_box black_box_pad_pin="clk_out1,daddr[6:0],dclk,den,din[15:0],dout[15:0],drdy,dwe,reset,locked,clk_in1" */;
  output clk_out1;
  input [6:0]daddr;
  input dclk;
  input den;
  input [15:0]din;
  output [15:0]dout;
  output drdy;
  input dwe;
  input reset;
  output locked;
  input clk_in1;
endmodule
