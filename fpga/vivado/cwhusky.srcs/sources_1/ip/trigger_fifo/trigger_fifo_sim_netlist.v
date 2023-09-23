// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (lin64) Build 3064766 Wed Nov 18 09:12:47 MST 2020
// Date        : Fri Sep  1 18:38:33 2023
// Host        : red running 64-bit Ubuntu 20.04.6 LTS
// Command     : write_verilog -force -mode funcsim
//               /home/jpnewae/git/cw_husky/fpga/vivado/cwhusky.srcs/sources_1/ip/trigger_fifo/trigger_fifo_sim_netlist.v
// Design      : trigger_fifo
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a35tftg256-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "trigger_fifo,fifo_generator_v13_2_5,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "fifo_generator_v13_2_5,Vivado 2020.2" *) 
(* NotValidForBitStream *)
module trigger_fifo
   (clk,
    rst,
    din,
    wr_en,
    rd_en,
    dout,
    full,
    empty,
    underflow);
  (* x_interface_info = "xilinx.com:signal:clock:1.0 core_clk CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME core_clk, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.000, INSERT_VIP 0" *) input clk;
  input rst;
  (* x_interface_info = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE WR_DATA" *) input [31:0]din;
  (* x_interface_info = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE WR_EN" *) input wr_en;
  (* x_interface_info = "xilinx.com:interface:fifo_read:1.0 FIFO_READ RD_EN" *) input rd_en;
  (* x_interface_info = "xilinx.com:interface:fifo_read:1.0 FIFO_READ RD_DATA" *) output [31:0]dout;
  (* x_interface_info = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE FULL" *) output full;
  (* x_interface_info = "xilinx.com:interface:fifo_read:1.0 FIFO_READ EMPTY" *) output empty;
  output underflow;

  wire clk;
  wire [31:0]din;
  wire [31:0]dout;
  wire empty;
  wire full;
  wire rd_en;
  wire rst;
  wire underflow;
  wire wr_en;
  wire NLW_U0_almost_empty_UNCONNECTED;
  wire NLW_U0_almost_full_UNCONNECTED;
  wire NLW_U0_axi_ar_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_ar_overflow_UNCONNECTED;
  wire NLW_U0_axi_ar_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_ar_prog_full_UNCONNECTED;
  wire NLW_U0_axi_ar_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_ar_underflow_UNCONNECTED;
  wire NLW_U0_axi_aw_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_aw_overflow_UNCONNECTED;
  wire NLW_U0_axi_aw_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_aw_prog_full_UNCONNECTED;
  wire NLW_U0_axi_aw_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_aw_underflow_UNCONNECTED;
  wire NLW_U0_axi_b_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_b_overflow_UNCONNECTED;
  wire NLW_U0_axi_b_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_b_prog_full_UNCONNECTED;
  wire NLW_U0_axi_b_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_b_underflow_UNCONNECTED;
  wire NLW_U0_axi_r_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_r_overflow_UNCONNECTED;
  wire NLW_U0_axi_r_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_r_prog_full_UNCONNECTED;
  wire NLW_U0_axi_r_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_r_underflow_UNCONNECTED;
  wire NLW_U0_axi_w_dbiterr_UNCONNECTED;
  wire NLW_U0_axi_w_overflow_UNCONNECTED;
  wire NLW_U0_axi_w_prog_empty_UNCONNECTED;
  wire NLW_U0_axi_w_prog_full_UNCONNECTED;
  wire NLW_U0_axi_w_sbiterr_UNCONNECTED;
  wire NLW_U0_axi_w_underflow_UNCONNECTED;
  wire NLW_U0_axis_dbiterr_UNCONNECTED;
  wire NLW_U0_axis_overflow_UNCONNECTED;
  wire NLW_U0_axis_prog_empty_UNCONNECTED;
  wire NLW_U0_axis_prog_full_UNCONNECTED;
  wire NLW_U0_axis_sbiterr_UNCONNECTED;
  wire NLW_U0_axis_underflow_UNCONNECTED;
  wire NLW_U0_dbiterr_UNCONNECTED;
  wire NLW_U0_m_axi_arvalid_UNCONNECTED;
  wire NLW_U0_m_axi_awvalid_UNCONNECTED;
  wire NLW_U0_m_axi_bready_UNCONNECTED;
  wire NLW_U0_m_axi_rready_UNCONNECTED;
  wire NLW_U0_m_axi_wlast_UNCONNECTED;
  wire NLW_U0_m_axi_wvalid_UNCONNECTED;
  wire NLW_U0_m_axis_tlast_UNCONNECTED;
  wire NLW_U0_m_axis_tvalid_UNCONNECTED;
  wire NLW_U0_overflow_UNCONNECTED;
  wire NLW_U0_prog_empty_UNCONNECTED;
  wire NLW_U0_prog_full_UNCONNECTED;
  wire NLW_U0_rd_rst_busy_UNCONNECTED;
  wire NLW_U0_s_axi_arready_UNCONNECTED;
  wire NLW_U0_s_axi_awready_UNCONNECTED;
  wire NLW_U0_s_axi_bvalid_UNCONNECTED;
  wire NLW_U0_s_axi_rlast_UNCONNECTED;
  wire NLW_U0_s_axi_rvalid_UNCONNECTED;
  wire NLW_U0_s_axi_wready_UNCONNECTED;
  wire NLW_U0_s_axis_tready_UNCONNECTED;
  wire NLW_U0_sbiterr_UNCONNECTED;
  wire NLW_U0_valid_UNCONNECTED;
  wire NLW_U0_wr_ack_UNCONNECTED;
  wire NLW_U0_wr_rst_busy_UNCONNECTED;
  wire [4:0]NLW_U0_axi_ar_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_ar_rd_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_ar_wr_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_aw_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_aw_rd_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_aw_wr_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_b_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_b_rd_data_count_UNCONNECTED;
  wire [4:0]NLW_U0_axi_b_wr_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_r_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_r_rd_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_r_wr_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_w_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_w_rd_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axi_w_wr_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axis_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axis_rd_data_count_UNCONNECTED;
  wire [10:0]NLW_U0_axis_wr_data_count_UNCONNECTED;
  wire [9:0]NLW_U0_data_count_UNCONNECTED;
  wire [31:0]NLW_U0_m_axi_araddr_UNCONNECTED;
  wire [1:0]NLW_U0_m_axi_arburst_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_arcache_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_arid_UNCONNECTED;
  wire [7:0]NLW_U0_m_axi_arlen_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_arlock_UNCONNECTED;
  wire [2:0]NLW_U0_m_axi_arprot_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_arqos_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_arregion_UNCONNECTED;
  wire [2:0]NLW_U0_m_axi_arsize_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_aruser_UNCONNECTED;
  wire [31:0]NLW_U0_m_axi_awaddr_UNCONNECTED;
  wire [1:0]NLW_U0_m_axi_awburst_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_awcache_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_awid_UNCONNECTED;
  wire [7:0]NLW_U0_m_axi_awlen_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_awlock_UNCONNECTED;
  wire [2:0]NLW_U0_m_axi_awprot_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_awqos_UNCONNECTED;
  wire [3:0]NLW_U0_m_axi_awregion_UNCONNECTED;
  wire [2:0]NLW_U0_m_axi_awsize_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_awuser_UNCONNECTED;
  wire [63:0]NLW_U0_m_axi_wdata_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_wid_UNCONNECTED;
  wire [7:0]NLW_U0_m_axi_wstrb_UNCONNECTED;
  wire [0:0]NLW_U0_m_axi_wuser_UNCONNECTED;
  wire [7:0]NLW_U0_m_axis_tdata_UNCONNECTED;
  wire [0:0]NLW_U0_m_axis_tdest_UNCONNECTED;
  wire [0:0]NLW_U0_m_axis_tid_UNCONNECTED;
  wire [0:0]NLW_U0_m_axis_tkeep_UNCONNECTED;
  wire [0:0]NLW_U0_m_axis_tstrb_UNCONNECTED;
  wire [3:0]NLW_U0_m_axis_tuser_UNCONNECTED;
  wire [9:0]NLW_U0_rd_data_count_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_buser_UNCONNECTED;
  wire [63:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_ruser_UNCONNECTED;
  wire [9:0]NLW_U0_wr_data_count_UNCONNECTED;

  (* C_ADD_NGC_CONSTRAINT = "0" *) 
  (* C_APPLICATION_TYPE_AXIS = "0" *) 
  (* C_APPLICATION_TYPE_RACH = "0" *) 
  (* C_APPLICATION_TYPE_RDCH = "0" *) 
  (* C_APPLICATION_TYPE_WACH = "0" *) 
  (* C_APPLICATION_TYPE_WDCH = "0" *) 
  (* C_APPLICATION_TYPE_WRCH = "0" *) 
  (* C_AXIS_TDATA_WIDTH = "8" *) 
  (* C_AXIS_TDEST_WIDTH = "1" *) 
  (* C_AXIS_TID_WIDTH = "1" *) 
  (* C_AXIS_TKEEP_WIDTH = "1" *) 
  (* C_AXIS_TSTRB_WIDTH = "1" *) 
  (* C_AXIS_TUSER_WIDTH = "4" *) 
  (* C_AXIS_TYPE = "0" *) 
  (* C_AXI_ADDR_WIDTH = "32" *) 
  (* C_AXI_ARUSER_WIDTH = "1" *) 
  (* C_AXI_AWUSER_WIDTH = "1" *) 
  (* C_AXI_BUSER_WIDTH = "1" *) 
  (* C_AXI_DATA_WIDTH = "64" *) 
  (* C_AXI_ID_WIDTH = "1" *) 
  (* C_AXI_LEN_WIDTH = "8" *) 
  (* C_AXI_LOCK_WIDTH = "1" *) 
  (* C_AXI_RUSER_WIDTH = "1" *) 
  (* C_AXI_TYPE = "1" *) 
  (* C_AXI_WUSER_WIDTH = "1" *) 
  (* C_COMMON_CLOCK = "1" *) 
  (* C_COUNT_TYPE = "0" *) 
  (* C_DATA_COUNT_WIDTH = "10" *) 
  (* C_DEFAULT_VALUE = "BlankString" *) 
  (* C_DIN_WIDTH = "32" *) 
  (* C_DIN_WIDTH_AXIS = "1" *) 
  (* C_DIN_WIDTH_RACH = "32" *) 
  (* C_DIN_WIDTH_RDCH = "64" *) 
  (* C_DIN_WIDTH_WACH = "1" *) 
  (* C_DIN_WIDTH_WDCH = "64" *) 
  (* C_DIN_WIDTH_WRCH = "2" *) 
  (* C_DOUT_RST_VAL = "0" *) 
  (* C_DOUT_WIDTH = "32" *) 
  (* C_ENABLE_RLOCS = "0" *) 
  (* C_ENABLE_RST_SYNC = "1" *) 
  (* C_EN_SAFETY_CKT = "0" *) 
  (* C_ERROR_INJECTION_TYPE = "0" *) 
  (* C_ERROR_INJECTION_TYPE_AXIS = "0" *) 
  (* C_ERROR_INJECTION_TYPE_RACH = "0" *) 
  (* C_ERROR_INJECTION_TYPE_RDCH = "0" *) 
  (* C_ERROR_INJECTION_TYPE_WACH = "0" *) 
  (* C_ERROR_INJECTION_TYPE_WDCH = "0" *) 
  (* C_ERROR_INJECTION_TYPE_WRCH = "0" *) 
  (* C_FAMILY = "artix7" *) 
  (* C_FULL_FLAGS_RST_VAL = "0" *) 
  (* C_HAS_ALMOST_EMPTY = "0" *) 
  (* C_HAS_ALMOST_FULL = "0" *) 
  (* C_HAS_AXIS_TDATA = "1" *) 
  (* C_HAS_AXIS_TDEST = "0" *) 
  (* C_HAS_AXIS_TID = "0" *) 
  (* C_HAS_AXIS_TKEEP = "0" *) 
  (* C_HAS_AXIS_TLAST = "0" *) 
  (* C_HAS_AXIS_TREADY = "1" *) 
  (* C_HAS_AXIS_TSTRB = "0" *) 
  (* C_HAS_AXIS_TUSER = "1" *) 
  (* C_HAS_AXI_ARUSER = "0" *) 
  (* C_HAS_AXI_AWUSER = "0" *) 
  (* C_HAS_AXI_BUSER = "0" *) 
  (* C_HAS_AXI_ID = "0" *) 
  (* C_HAS_AXI_RD_CHANNEL = "1" *) 
  (* C_HAS_AXI_RUSER = "0" *) 
  (* C_HAS_AXI_WR_CHANNEL = "1" *) 
  (* C_HAS_AXI_WUSER = "0" *) 
  (* C_HAS_BACKUP = "0" *) 
  (* C_HAS_DATA_COUNT = "0" *) 
  (* C_HAS_DATA_COUNTS_AXIS = "0" *) 
  (* C_HAS_DATA_COUNTS_RACH = "0" *) 
  (* C_HAS_DATA_COUNTS_RDCH = "0" *) 
  (* C_HAS_DATA_COUNTS_WACH = "0" *) 
  (* C_HAS_DATA_COUNTS_WDCH = "0" *) 
  (* C_HAS_DATA_COUNTS_WRCH = "0" *) 
  (* C_HAS_INT_CLK = "0" *) 
  (* C_HAS_MASTER_CE = "0" *) 
  (* C_HAS_MEMINIT_FILE = "0" *) 
  (* C_HAS_OVERFLOW = "0" *) 
  (* C_HAS_PROG_FLAGS_AXIS = "0" *) 
  (* C_HAS_PROG_FLAGS_RACH = "0" *) 
  (* C_HAS_PROG_FLAGS_RDCH = "0" *) 
  (* C_HAS_PROG_FLAGS_WACH = "0" *) 
  (* C_HAS_PROG_FLAGS_WDCH = "0" *) 
  (* C_HAS_PROG_FLAGS_WRCH = "0" *) 
  (* C_HAS_RD_DATA_COUNT = "0" *) 
  (* C_HAS_RD_RST = "0" *) 
  (* C_HAS_RST = "1" *) 
  (* C_HAS_SLAVE_CE = "0" *) 
  (* C_HAS_SRST = "0" *) 
  (* C_HAS_UNDERFLOW = "1" *) 
  (* C_HAS_VALID = "0" *) 
  (* C_HAS_WR_ACK = "0" *) 
  (* C_HAS_WR_DATA_COUNT = "0" *) 
  (* C_HAS_WR_RST = "0" *) 
  (* C_IMPLEMENTATION_TYPE = "6" *) 
  (* C_IMPLEMENTATION_TYPE_AXIS = "1" *) 
  (* C_IMPLEMENTATION_TYPE_RACH = "1" *) 
  (* C_IMPLEMENTATION_TYPE_RDCH = "1" *) 
  (* C_IMPLEMENTATION_TYPE_WACH = "1" *) 
  (* C_IMPLEMENTATION_TYPE_WDCH = "1" *) 
  (* C_IMPLEMENTATION_TYPE_WRCH = "1" *) 
  (* C_INIT_WR_PNTR_VAL = "0" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_MEMORY_TYPE = "4" *) 
  (* C_MIF_FILE_NAME = "BlankString" *) 
  (* C_MSGON_VAL = "1" *) 
  (* C_OPTIMIZATION_MODE = "0" *) 
  (* C_OVERFLOW_LOW = "0" *) 
  (* C_POWER_SAVING_MODE = "0" *) 
  (* C_PRELOAD_LATENCY = "1" *) 
  (* C_PRELOAD_REGS = "0" *) 
  (* C_PRIM_FIFO_TYPE = "1kx36" *) 
  (* C_PRIM_FIFO_TYPE_AXIS = "1kx18" *) 
  (* C_PRIM_FIFO_TYPE_RACH = "512x36" *) 
  (* C_PRIM_FIFO_TYPE_RDCH = "1kx36" *) 
  (* C_PRIM_FIFO_TYPE_WACH = "512x36" *) 
  (* C_PRIM_FIFO_TYPE_WDCH = "1kx36" *) 
  (* C_PRIM_FIFO_TYPE_WRCH = "512x36" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL = "2" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_AXIS = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_RACH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_RDCH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_WACH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_WDCH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_WRCH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_NEGATE_VAL = "3" *) 
  (* C_PROG_EMPTY_TYPE = "0" *) 
  (* C_PROG_EMPTY_TYPE_AXIS = "0" *) 
  (* C_PROG_EMPTY_TYPE_RACH = "0" *) 
  (* C_PROG_EMPTY_TYPE_RDCH = "0" *) 
  (* C_PROG_EMPTY_TYPE_WACH = "0" *) 
  (* C_PROG_EMPTY_TYPE_WDCH = "0" *) 
  (* C_PROG_EMPTY_TYPE_WRCH = "0" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL = "1022" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_AXIS = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_RACH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_RDCH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WACH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WDCH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WRCH = "1023" *) 
  (* C_PROG_FULL_THRESH_NEGATE_VAL = "1021" *) 
  (* C_PROG_FULL_TYPE = "0" *) 
  (* C_PROG_FULL_TYPE_AXIS = "0" *) 
  (* C_PROG_FULL_TYPE_RACH = "0" *) 
  (* C_PROG_FULL_TYPE_RDCH = "0" *) 
  (* C_PROG_FULL_TYPE_WACH = "0" *) 
  (* C_PROG_FULL_TYPE_WDCH = "0" *) 
  (* C_PROG_FULL_TYPE_WRCH = "0" *) 
  (* C_RACH_TYPE = "0" *) 
  (* C_RDCH_TYPE = "0" *) 
  (* C_RD_DATA_COUNT_WIDTH = "10" *) 
  (* C_RD_DEPTH = "1024" *) 
  (* C_RD_FREQ = "1" *) 
  (* C_RD_PNTR_WIDTH = "10" *) 
  (* C_REG_SLICE_MODE_AXIS = "0" *) 
  (* C_REG_SLICE_MODE_RACH = "0" *) 
  (* C_REG_SLICE_MODE_RDCH = "0" *) 
  (* C_REG_SLICE_MODE_WACH = "0" *) 
  (* C_REG_SLICE_MODE_WDCH = "0" *) 
  (* C_REG_SLICE_MODE_WRCH = "0" *) 
  (* C_SELECT_XPM = "0" *) 
  (* C_SYNCHRONIZER_STAGE = "2" *) 
  (* C_UNDERFLOW_LOW = "0" *) 
  (* C_USE_COMMON_OVERFLOW = "0" *) 
  (* C_USE_COMMON_UNDERFLOW = "0" *) 
  (* C_USE_DEFAULT_SETTINGS = "0" *) 
  (* C_USE_DOUT_RST = "0" *) 
  (* C_USE_ECC = "0" *) 
  (* C_USE_ECC_AXIS = "0" *) 
  (* C_USE_ECC_RACH = "0" *) 
  (* C_USE_ECC_RDCH = "0" *) 
  (* C_USE_ECC_WACH = "0" *) 
  (* C_USE_ECC_WDCH = "0" *) 
  (* C_USE_ECC_WRCH = "0" *) 
  (* C_USE_EMBEDDED_REG = "0" *) 
  (* C_USE_FIFO16_FLAGS = "0" *) 
  (* C_USE_FWFT_DATA_COUNT = "0" *) 
  (* C_USE_PIPELINE_REG = "0" *) 
  (* C_VALID_LOW = "0" *) 
  (* C_WACH_TYPE = "0" *) 
  (* C_WDCH_TYPE = "0" *) 
  (* C_WRCH_TYPE = "0" *) 
  (* C_WR_ACK_LOW = "0" *) 
  (* C_WR_DATA_COUNT_WIDTH = "10" *) 
  (* C_WR_DEPTH = "1024" *) 
  (* C_WR_DEPTH_AXIS = "1024" *) 
  (* C_WR_DEPTH_RACH = "16" *) 
  (* C_WR_DEPTH_RDCH = "1024" *) 
  (* C_WR_DEPTH_WACH = "16" *) 
  (* C_WR_DEPTH_WDCH = "1024" *) 
  (* C_WR_DEPTH_WRCH = "16" *) 
  (* C_WR_FREQ = "1" *) 
  (* C_WR_PNTR_WIDTH = "10" *) 
  (* C_WR_PNTR_WIDTH_AXIS = "10" *) 
  (* C_WR_PNTR_WIDTH_RACH = "4" *) 
  (* C_WR_PNTR_WIDTH_RDCH = "10" *) 
  (* C_WR_PNTR_WIDTH_WACH = "4" *) 
  (* C_WR_PNTR_WIDTH_WDCH = "10" *) 
  (* C_WR_PNTR_WIDTH_WRCH = "4" *) 
  (* C_WR_RESPONSE_LATENCY = "1" *) 
  (* is_du_within_envelope = "true" *) 
  trigger_fifo_fifo_generator_v13_2_5 U0
       (.almost_empty(NLW_U0_almost_empty_UNCONNECTED),
        .almost_full(NLW_U0_almost_full_UNCONNECTED),
        .axi_ar_data_count(NLW_U0_axi_ar_data_count_UNCONNECTED[4:0]),
        .axi_ar_dbiterr(NLW_U0_axi_ar_dbiterr_UNCONNECTED),
        .axi_ar_injectdbiterr(1'b0),
        .axi_ar_injectsbiterr(1'b0),
        .axi_ar_overflow(NLW_U0_axi_ar_overflow_UNCONNECTED),
        .axi_ar_prog_empty(NLW_U0_axi_ar_prog_empty_UNCONNECTED),
        .axi_ar_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_ar_prog_full(NLW_U0_axi_ar_prog_full_UNCONNECTED),
        .axi_ar_prog_full_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_ar_rd_data_count(NLW_U0_axi_ar_rd_data_count_UNCONNECTED[4:0]),
        .axi_ar_sbiterr(NLW_U0_axi_ar_sbiterr_UNCONNECTED),
        .axi_ar_underflow(NLW_U0_axi_ar_underflow_UNCONNECTED),
        .axi_ar_wr_data_count(NLW_U0_axi_ar_wr_data_count_UNCONNECTED[4:0]),
        .axi_aw_data_count(NLW_U0_axi_aw_data_count_UNCONNECTED[4:0]),
        .axi_aw_dbiterr(NLW_U0_axi_aw_dbiterr_UNCONNECTED),
        .axi_aw_injectdbiterr(1'b0),
        .axi_aw_injectsbiterr(1'b0),
        .axi_aw_overflow(NLW_U0_axi_aw_overflow_UNCONNECTED),
        .axi_aw_prog_empty(NLW_U0_axi_aw_prog_empty_UNCONNECTED),
        .axi_aw_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_aw_prog_full(NLW_U0_axi_aw_prog_full_UNCONNECTED),
        .axi_aw_prog_full_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_aw_rd_data_count(NLW_U0_axi_aw_rd_data_count_UNCONNECTED[4:0]),
        .axi_aw_sbiterr(NLW_U0_axi_aw_sbiterr_UNCONNECTED),
        .axi_aw_underflow(NLW_U0_axi_aw_underflow_UNCONNECTED),
        .axi_aw_wr_data_count(NLW_U0_axi_aw_wr_data_count_UNCONNECTED[4:0]),
        .axi_b_data_count(NLW_U0_axi_b_data_count_UNCONNECTED[4:0]),
        .axi_b_dbiterr(NLW_U0_axi_b_dbiterr_UNCONNECTED),
        .axi_b_injectdbiterr(1'b0),
        .axi_b_injectsbiterr(1'b0),
        .axi_b_overflow(NLW_U0_axi_b_overflow_UNCONNECTED),
        .axi_b_prog_empty(NLW_U0_axi_b_prog_empty_UNCONNECTED),
        .axi_b_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_b_prog_full(NLW_U0_axi_b_prog_full_UNCONNECTED),
        .axi_b_prog_full_thresh({1'b0,1'b0,1'b0,1'b0}),
        .axi_b_rd_data_count(NLW_U0_axi_b_rd_data_count_UNCONNECTED[4:0]),
        .axi_b_sbiterr(NLW_U0_axi_b_sbiterr_UNCONNECTED),
        .axi_b_underflow(NLW_U0_axi_b_underflow_UNCONNECTED),
        .axi_b_wr_data_count(NLW_U0_axi_b_wr_data_count_UNCONNECTED[4:0]),
        .axi_r_data_count(NLW_U0_axi_r_data_count_UNCONNECTED[10:0]),
        .axi_r_dbiterr(NLW_U0_axi_r_dbiterr_UNCONNECTED),
        .axi_r_injectdbiterr(1'b0),
        .axi_r_injectsbiterr(1'b0),
        .axi_r_overflow(NLW_U0_axi_r_overflow_UNCONNECTED),
        .axi_r_prog_empty(NLW_U0_axi_r_prog_empty_UNCONNECTED),
        .axi_r_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axi_r_prog_full(NLW_U0_axi_r_prog_full_UNCONNECTED),
        .axi_r_prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axi_r_rd_data_count(NLW_U0_axi_r_rd_data_count_UNCONNECTED[10:0]),
        .axi_r_sbiterr(NLW_U0_axi_r_sbiterr_UNCONNECTED),
        .axi_r_underflow(NLW_U0_axi_r_underflow_UNCONNECTED),
        .axi_r_wr_data_count(NLW_U0_axi_r_wr_data_count_UNCONNECTED[10:0]),
        .axi_w_data_count(NLW_U0_axi_w_data_count_UNCONNECTED[10:0]),
        .axi_w_dbiterr(NLW_U0_axi_w_dbiterr_UNCONNECTED),
        .axi_w_injectdbiterr(1'b0),
        .axi_w_injectsbiterr(1'b0),
        .axi_w_overflow(NLW_U0_axi_w_overflow_UNCONNECTED),
        .axi_w_prog_empty(NLW_U0_axi_w_prog_empty_UNCONNECTED),
        .axi_w_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axi_w_prog_full(NLW_U0_axi_w_prog_full_UNCONNECTED),
        .axi_w_prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axi_w_rd_data_count(NLW_U0_axi_w_rd_data_count_UNCONNECTED[10:0]),
        .axi_w_sbiterr(NLW_U0_axi_w_sbiterr_UNCONNECTED),
        .axi_w_underflow(NLW_U0_axi_w_underflow_UNCONNECTED),
        .axi_w_wr_data_count(NLW_U0_axi_w_wr_data_count_UNCONNECTED[10:0]),
        .axis_data_count(NLW_U0_axis_data_count_UNCONNECTED[10:0]),
        .axis_dbiterr(NLW_U0_axis_dbiterr_UNCONNECTED),
        .axis_injectdbiterr(1'b0),
        .axis_injectsbiterr(1'b0),
        .axis_overflow(NLW_U0_axis_overflow_UNCONNECTED),
        .axis_prog_empty(NLW_U0_axis_prog_empty_UNCONNECTED),
        .axis_prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axis_prog_full(NLW_U0_axis_prog_full_UNCONNECTED),
        .axis_prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .axis_rd_data_count(NLW_U0_axis_rd_data_count_UNCONNECTED[10:0]),
        .axis_sbiterr(NLW_U0_axis_sbiterr_UNCONNECTED),
        .axis_underflow(NLW_U0_axis_underflow_UNCONNECTED),
        .axis_wr_data_count(NLW_U0_axis_wr_data_count_UNCONNECTED[10:0]),
        .backup(1'b0),
        .backup_marker(1'b0),
        .clk(clk),
        .data_count(NLW_U0_data_count_UNCONNECTED[9:0]),
        .dbiterr(NLW_U0_dbiterr_UNCONNECTED),
        .din(din),
        .dout(dout),
        .empty(empty),
        .full(full),
        .injectdbiterr(1'b0),
        .injectsbiterr(1'b0),
        .int_clk(1'b0),
        .m_aclk(1'b0),
        .m_aclk_en(1'b0),
        .m_axi_araddr(NLW_U0_m_axi_araddr_UNCONNECTED[31:0]),
        .m_axi_arburst(NLW_U0_m_axi_arburst_UNCONNECTED[1:0]),
        .m_axi_arcache(NLW_U0_m_axi_arcache_UNCONNECTED[3:0]),
        .m_axi_arid(NLW_U0_m_axi_arid_UNCONNECTED[0]),
        .m_axi_arlen(NLW_U0_m_axi_arlen_UNCONNECTED[7:0]),
        .m_axi_arlock(NLW_U0_m_axi_arlock_UNCONNECTED[0]),
        .m_axi_arprot(NLW_U0_m_axi_arprot_UNCONNECTED[2:0]),
        .m_axi_arqos(NLW_U0_m_axi_arqos_UNCONNECTED[3:0]),
        .m_axi_arready(1'b0),
        .m_axi_arregion(NLW_U0_m_axi_arregion_UNCONNECTED[3:0]),
        .m_axi_arsize(NLW_U0_m_axi_arsize_UNCONNECTED[2:0]),
        .m_axi_aruser(NLW_U0_m_axi_aruser_UNCONNECTED[0]),
        .m_axi_arvalid(NLW_U0_m_axi_arvalid_UNCONNECTED),
        .m_axi_awaddr(NLW_U0_m_axi_awaddr_UNCONNECTED[31:0]),
        .m_axi_awburst(NLW_U0_m_axi_awburst_UNCONNECTED[1:0]),
        .m_axi_awcache(NLW_U0_m_axi_awcache_UNCONNECTED[3:0]),
        .m_axi_awid(NLW_U0_m_axi_awid_UNCONNECTED[0]),
        .m_axi_awlen(NLW_U0_m_axi_awlen_UNCONNECTED[7:0]),
        .m_axi_awlock(NLW_U0_m_axi_awlock_UNCONNECTED[0]),
        .m_axi_awprot(NLW_U0_m_axi_awprot_UNCONNECTED[2:0]),
        .m_axi_awqos(NLW_U0_m_axi_awqos_UNCONNECTED[3:0]),
        .m_axi_awready(1'b0),
        .m_axi_awregion(NLW_U0_m_axi_awregion_UNCONNECTED[3:0]),
        .m_axi_awsize(NLW_U0_m_axi_awsize_UNCONNECTED[2:0]),
        .m_axi_awuser(NLW_U0_m_axi_awuser_UNCONNECTED[0]),
        .m_axi_awvalid(NLW_U0_m_axi_awvalid_UNCONNECTED),
        .m_axi_bid(1'b0),
        .m_axi_bready(NLW_U0_m_axi_bready_UNCONNECTED),
        .m_axi_bresp({1'b0,1'b0}),
        .m_axi_buser(1'b0),
        .m_axi_bvalid(1'b0),
        .m_axi_rdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .m_axi_rid(1'b0),
        .m_axi_rlast(1'b0),
        .m_axi_rready(NLW_U0_m_axi_rready_UNCONNECTED),
        .m_axi_rresp({1'b0,1'b0}),
        .m_axi_ruser(1'b0),
        .m_axi_rvalid(1'b0),
        .m_axi_wdata(NLW_U0_m_axi_wdata_UNCONNECTED[63:0]),
        .m_axi_wid(NLW_U0_m_axi_wid_UNCONNECTED[0]),
        .m_axi_wlast(NLW_U0_m_axi_wlast_UNCONNECTED),
        .m_axi_wready(1'b0),
        .m_axi_wstrb(NLW_U0_m_axi_wstrb_UNCONNECTED[7:0]),
        .m_axi_wuser(NLW_U0_m_axi_wuser_UNCONNECTED[0]),
        .m_axi_wvalid(NLW_U0_m_axi_wvalid_UNCONNECTED),
        .m_axis_tdata(NLW_U0_m_axis_tdata_UNCONNECTED[7:0]),
        .m_axis_tdest(NLW_U0_m_axis_tdest_UNCONNECTED[0]),
        .m_axis_tid(NLW_U0_m_axis_tid_UNCONNECTED[0]),
        .m_axis_tkeep(NLW_U0_m_axis_tkeep_UNCONNECTED[0]),
        .m_axis_tlast(NLW_U0_m_axis_tlast_UNCONNECTED),
        .m_axis_tready(1'b0),
        .m_axis_tstrb(NLW_U0_m_axis_tstrb_UNCONNECTED[0]),
        .m_axis_tuser(NLW_U0_m_axis_tuser_UNCONNECTED[3:0]),
        .m_axis_tvalid(NLW_U0_m_axis_tvalid_UNCONNECTED),
        .overflow(NLW_U0_overflow_UNCONNECTED),
        .prog_empty(NLW_U0_prog_empty_UNCONNECTED),
        .prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_empty_thresh_assert({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_empty_thresh_negate({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_full(NLW_U0_prog_full_UNCONNECTED),
        .prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_full_thresh_assert({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_full_thresh_negate({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .rd_clk(1'b0),
        .rd_data_count(NLW_U0_rd_data_count_UNCONNECTED[9:0]),
        .rd_en(rd_en),
        .rd_rst(1'b0),
        .rd_rst_busy(NLW_U0_rd_rst_busy_UNCONNECTED),
        .rst(rst),
        .s_aclk(1'b0),
        .s_aclk_en(1'b0),
        .s_aresetn(1'b0),
        .s_axi_araddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arburst({1'b0,1'b0}),
        .s_axi_arcache({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arid(1'b0),
        .s_axi_arlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arlock(1'b0),
        .s_axi_arprot({1'b0,1'b0,1'b0}),
        .s_axi_arqos({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arready(NLW_U0_s_axi_arready_UNCONNECTED),
        .s_axi_arregion({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_arsize({1'b0,1'b0,1'b0}),
        .s_axi_aruser(1'b0),
        .s_axi_arvalid(1'b0),
        .s_axi_awaddr({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awburst({1'b0,1'b0}),
        .s_axi_awcache({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awid(1'b0),
        .s_axi_awlen({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awlock(1'b0),
        .s_axi_awprot({1'b0,1'b0,1'b0}),
        .s_axi_awqos({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awready(NLW_U0_s_axi_awready_UNCONNECTED),
        .s_axi_awregion({1'b0,1'b0,1'b0,1'b0}),
        .s_axi_awsize({1'b0,1'b0,1'b0}),
        .s_axi_awuser(1'b0),
        .s_axi_awvalid(1'b0),
        .s_axi_bid(NLW_U0_s_axi_bid_UNCONNECTED[0]),
        .s_axi_bready(1'b0),
        .s_axi_bresp(NLW_U0_s_axi_bresp_UNCONNECTED[1:0]),
        .s_axi_buser(NLW_U0_s_axi_buser_UNCONNECTED[0]),
        .s_axi_bvalid(NLW_U0_s_axi_bvalid_UNCONNECTED),
        .s_axi_rdata(NLW_U0_s_axi_rdata_UNCONNECTED[63:0]),
        .s_axi_rid(NLW_U0_s_axi_rid_UNCONNECTED[0]),
        .s_axi_rlast(NLW_U0_s_axi_rlast_UNCONNECTED),
        .s_axi_rready(1'b0),
        .s_axi_rresp(NLW_U0_s_axi_rresp_UNCONNECTED[1:0]),
        .s_axi_ruser(NLW_U0_s_axi_ruser_UNCONNECTED[0]),
        .s_axi_rvalid(NLW_U0_s_axi_rvalid_UNCONNECTED),
        .s_axi_wdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wid(1'b0),
        .s_axi_wlast(1'b0),
        .s_axi_wready(NLW_U0_s_axi_wready_UNCONNECTED),
        .s_axi_wstrb({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axi_wuser(1'b0),
        .s_axi_wvalid(1'b0),
        .s_axis_tdata({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .s_axis_tdest(1'b0),
        .s_axis_tid(1'b0),
        .s_axis_tkeep(1'b0),
        .s_axis_tlast(1'b0),
        .s_axis_tready(NLW_U0_s_axis_tready_UNCONNECTED),
        .s_axis_tstrb(1'b0),
        .s_axis_tuser({1'b0,1'b0,1'b0,1'b0}),
        .s_axis_tvalid(1'b0),
        .sbiterr(NLW_U0_sbiterr_UNCONNECTED),
        .sleep(1'b0),
        .srst(1'b0),
        .underflow(underflow),
        .valid(NLW_U0_valid_UNCONNECTED),
        .wr_ack(NLW_U0_wr_ack_UNCONNECTED),
        .wr_clk(1'b0),
        .wr_data_count(NLW_U0_wr_data_count_UNCONNECTED[9:0]),
        .wr_en(wr_en),
        .wr_rst(1'b0),
        .wr_rst_busy(NLW_U0_wr_rst_busy_UNCONNECTED));
endmodule
`pragma protect begin_protected
`pragma protect version = 1
`pragma protect encrypt_agent = "XILINX"
`pragma protect encrypt_agent_info = "Xilinx Encryption Tool 2020.2"
`pragma protect key_keyowner="Cadence Design Systems.", key_keyname="cds_rsa_key", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=64)
`pragma protect key_block
SFoQ2tXDMrL2nCJbfpmHXuteJlKaWDWl3o9OY1miFvmYb8EDywmDpLUHQktJ/VoW+17fK5WHgFVI
FZV1B91GDQ==

`pragma protect key_keyowner="Synopsys", key_keyname="SNPS-VCS-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
mxGWDRjEAsKmBqldxevT1RKZvqK7vn0KlTODVXNGlRcGf9zOAmj0Z7Ppu79POBDb8oNQyCY+2q1q
BddzhQfh5WLIVX9BNUMIF6M6IF0elM4GMSLHGeYEwqSaMPC+thuR8FGj1J7z6rH+43gDYhtIeyY+
ZuZUz/Pqg8Lu63Xwe+0=

`pragma protect key_keyowner="Aldec", key_keyname="ALDEC15_001", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
HLwPjQzkuqv5FEDBriEJS2DikBeIHB/bWuVWooHY5ChdoHatcmqCHpSvnGxVzLwObZWHFys2nR9y
P3zxywjtgtOWq/n3cYVa5li6eyiUmGXv2OE8nw1nLnAY1kzBvGd6VwQ45t6l4Hx5+oqpIfuU2KI2
7/Qpj2atiTN3Y+q5He/BMXLIxF9vWuU6XL/+HsxriGAumcZDuESdidlxOztbW1bFhYr1/qWwou2q
wynnRVKYHL41aWycgFdkDoDEFFxv8ft8+F5Ux+J5Hg5XdgRULJc6uUQE/lDG3zOqzPftlODB52zU
d0cm8gFOvSZ2nO8ZB8THnxoAGe33iIZJfMcefA==

`pragma protect key_keyowner="ATRENTA", key_keyname="ATR-SG-2015-RSA-3", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
jlR0iZ4fp9QXiFgaT07DMAK1YFLyBpsOGOOR9j2PWImFEh8oTBt4cvmGo+2z1Umbt9OMQwOhyepO
QIsKLFzUXYUba+SFFLBoCiaww24KICecbUfd3VV5sg2bEJjAdtYTT6mJqyc3vQRvBlONeBFdIGy2
AXqdK7QtXGLsLAIF/z4FG8cfG6nSD6e16gccBC6+kl5MoShdnmebKLyoo6UKFdMbDK88sHvTcD9S
LNCau6RK7FkTZg23FV0tf6cTP9Rray9YEcowm2AAh51Wldo2lGJ2W5iiDatRKH/W1bu7FGWZG+OT
+VZE+Ckiuf4T6cuu+G5IbrtMv6a4U93R0gtxXQ==

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VELOCE-RSA", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=128)
`pragma protect key_block
p/kq+JjPPJbOTWT2SRiPJ99/iH6kkVGEiluRRXpuRN+j+cVPgJD1v4QVjw3zMWLlvTGB7OOqC+JG
Lc62Wiizd/BFfGj2JYkTZMatcOWok7A87HK+vRTjr4nZMApD2jKaneJdU1279KsIEeRfImCQ2uRl
QRNMH3PPdNGYCnOGgNk=

`pragma protect key_keyowner="Mentor Graphics Corporation", key_keyname="MGC-VERIF-SIM-RSA-2", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
kyyI/O29YYc5VBwhz19i7AV7MC75r43hHVKAOTBiGBhRu8zZxCwGGcNFqc2HgHcWC6nq4jCIbIXf
S3FDzPdasegnERlWvoob9/SXM88zKsyeTbUf+DRu5lB8SPROBMaIhnj375C5XLowL17MXZdmB6fV
X5ukCg7cNhCjssKt/bIJibWkfna7hvj4ye+CLWmi3LdEiix8KTwRoBS3ZJrjM4/N6FfZkXerVxs+
txkhdsmG9ga1g/xErhTRilhqrV2WetlpX86qH/64sRGVxrWeEfNoHhMZsqEK0jWDx4WavKt8XY7W
NDzMXLZ2m5Dv5HMiJWgFG+ntPwgiYYtBuwu7Eg==

`pragma protect key_keyowner="Real Intent", key_keyname="RI-RSA-KEY-1", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
tv6UL1ZWqo3dAIlhN5UTNGzJyqzdHpCqh217JPvIvHiWJgcFh2tw1n7HWnOPcK3VhCt31AGnCEFe
HpTiinXvHna65L2X2HhtNUrsgvZlUuh/oQR273wp5JPFDPD97NQ4ELkGI+w26HTYLgZ70K5rQo87
D4AkQNRuzTRS5G12yb4RU7ZYgmkYLuq1UyqjlxyN62Del4XoqZyivOGw5H+7wlfkNRu98iQwqq12
jthZbH/ue5wxZJUcb7NmEwL+3abpyDNmWs1qORHOFoE3t97/9XMmeSCpM2+KnSKJvsV5VbuoTCOT
964fsEh7ey4IVb4aum095gQjLCqTmDm8DWFmaw==

`pragma protect key_keyowner="Xilinx", key_keyname="xilinxt_2020_08", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
Oxo3AgNmVWgrXtMKDIThYfXr0YJfyFr7Bsjn2ge/G72mb25MA8Dbkd9ZZPtwqU1poazNnTng5Cx5
s8C1zMNEoo38jNY8zEUBjCCuasJgeMo5xsiha+3ZIBiuHS0KLrjLaPFIQZdsYevb44fg6J5YQLn5
jd1M6YdNMd1VwSezDxtbk9sN8ExPrmtwum/6L1ia9j9UlIzPTEaJ60Xz7tloPsgsbkborO2JLiIk
kIAY2q1b8tuhHzJ5DoXlvIo49wSDj75ncLrkwbAd26huob7aOmX1bS34pJLF17JzqYH0MoPJbHxb
RPdD+qUawXFsMSs2fOLnZrNxeG8L+TyAT0N8tQ==

`pragma protect key_keyowner="Metrics Technologies Inc.", key_keyname="DSim", key_method="rsa"
`pragma protect encoding = (enctype="BASE64", line_length=76, bytes=256)
`pragma protect key_block
CIR/vwxo0IBrPr5+bMp2YuBCQTNBRIIbqgEB18Oewkc8CuHzGCAgPyQUBUKaUG3bBy+KDOPVxBP5
cE/d3QYZAT11fyB1OMMTrjmEIZcr0Vk3nVTAnivoxxxkmdzPjkj0OcGcU9fMArPi3dfTgIsKdtCq
94+mV/70WeprgijzuZFWD7uH+gVioY/+rq/Wc1O6x1n949w8YGgSCTurUvhsobx2bonoC317J0Wm
IX17XRkSBIFgzqA8iC+GV5oCfxIGkihKmXxjIJbMamlOdCOycEkjkh3JYmm7TLNxmI65iffsabR0
t5+iI0l8eJxFhElzWeREqE43cnJYLaKZBUA+DA==

`pragma protect data_method = "AES128-CBC"
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 52288)
`pragma protect data_block
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
eliDLMCYUP+Rhwg4wMaujsCspA==
`pragma protect end_protected
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;
    parameter GRES_WIDTH = 10000;
    parameter GRES_START = 10000;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
    wire GRESTORE;
    tri1 p_up_tmp;
    tri (weak1, strong0) PLL_LOCKG = p_up_tmp;

    wire PROGB_GLBL;
    wire CCLKO_GLBL;
    wire FCSBO_GLBL;
    wire [3:0] DO_GLBL;
    wire [3:0] DI_GLBL;
   
    reg GSR_int;
    reg GTS_int;
    reg PRLD_int;
    reg GRESTORE_int;

//--------   JTAG Globals --------------
    wire JTAG_TDO_GLBL;
    wire JTAG_TCK_GLBL;
    wire JTAG_TDI_GLBL;
    wire JTAG_TMS_GLBL;
    wire JTAG_TRST_GLBL;

    reg JTAG_CAPTURE_GLBL;
    reg JTAG_RESET_GLBL;
    reg JTAG_SHIFT_GLBL;
    reg JTAG_UPDATE_GLBL;
    reg JTAG_RUNTEST_GLBL;

    reg JTAG_SEL1_GLBL = 0;
    reg JTAG_SEL2_GLBL = 0 ;
    reg JTAG_SEL3_GLBL = 0;
    reg JTAG_SEL4_GLBL = 0;

    reg JTAG_USER_TDO1_GLBL = 1'bz;
    reg JTAG_USER_TDO2_GLBL = 1'bz;
    reg JTAG_USER_TDO3_GLBL = 1'bz;
    reg JTAG_USER_TDO4_GLBL = 1'bz;

    assign (strong1, weak0) GSR = GSR_int;
    assign (strong1, weak0) GTS = GTS_int;
    assign (weak1, weak0) PRLD = PRLD_int;
    assign (strong1, weak0) GRESTORE = GRESTORE_int;

    initial begin
	GSR_int = 1'b1;
	PRLD_int = 1'b1;
	#(ROC_WIDTH)
	GSR_int = 1'b0;
	PRLD_int = 1'b0;
    end

    initial begin
	GTS_int = 1'b1;
	#(TOC_WIDTH)
	GTS_int = 1'b0;
    end

    initial begin 
	GRESTORE_int = 1'b0;
	#(GRES_START);
	GRESTORE_int = 1'b1;
	#(GRES_WIDTH);
	GRESTORE_int = 1'b0;
    end

endmodule
`endif
