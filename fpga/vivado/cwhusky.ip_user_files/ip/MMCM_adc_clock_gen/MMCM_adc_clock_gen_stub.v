// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (win64) Build 2708876 Wed Nov  6 21:40:23 MST 2019
// Date        : Fri May 21 13:58:20 2021
// Host        : qed running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               C:/Users/jp/GitHub/OpenTitan/husky/fpga/vivado/cwhusky.srcs/sources_1/ip/MMCM_adc_clock_gen/MMCM_adc_clock_gen_stub.v
// Design      : MMCM_adc_clock_gen
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tftg256-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
module MMCM_adc_clock_gen(clkfb_in, clk_out1, clk_out2, clkfb_out, psclk, 
  psen, psincdec, psdone, reset, power_down, locked, clk_in1)
/* synthesis syn_black_box black_box_pad_pin="clkfb_in,clk_out1,clk_out2,clkfb_out,psclk,psen,psincdec,psdone,reset,power_down,locked,clk_in1" */;
  input clkfb_in;
  output clk_out1;
  output clk_out2;
  output clkfb_out;
  input psclk;
  input psen;
  input psincdec;
  output psdone;
  input reset;
  input power_down;
  output locked;
  input clk_in1;
endmodule
