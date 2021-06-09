// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
// Date        : Wed Jun  9 11:47:38 2021
// Host        : qed running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               c:/Users/jp/GitHub/OpenTitan/husky/fpga/vivado/cwhusky.srcs/sources_1/ip/ila_drp/ila_drp_stub.v
// Design      : ila_drp
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tftg256-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "ila,Vivado 2020.2" *)
module ila_drp(clk, probe0, probe1, probe2, probe3, probe4, probe5)
/* synthesis syn_black_box black_box_pad_pin="clk,probe0[6:0],probe1[0:0],probe2[15:0],probe3[15:0],probe4[0:0],probe5[0:0]" */;
  input clk;
  input [6:0]probe0;
  input [0:0]probe1;
  input [15:0]probe2;
  input [15:0]probe3;
  input [0:0]probe4;
  input [0:0]probe5;
endmodule
