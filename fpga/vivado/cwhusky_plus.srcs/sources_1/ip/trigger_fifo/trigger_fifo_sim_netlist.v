// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (lin64) Build 3064766 Wed Nov 18 09:12:47 MST 2020
// Date        : Fri Sep  1 20:01:28 2023
// Host        : red running 64-bit Ubuntu 20.04.6 LTS
// Command     : write_verilog -force -mode funcsim
//               /home/jpnewae/git/cw_husky/fpga/vivado/cwhusky_plus.srcs/sources_1/ip/trigger_fifo/trigger_fifo_sim_netlist.v
// Design      : trigger_fifo
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a100tftg256-3
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
  wire [10:0]NLW_U0_data_count_UNCONNECTED;
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
  wire [10:0]NLW_U0_rd_data_count_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_buser_UNCONNECTED;
  wire [63:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_ruser_UNCONNECTED;
  wire [10:0]NLW_U0_wr_data_count_UNCONNECTED;

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
  (* C_DATA_COUNT_WIDTH = "11" *) 
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
  (* C_PRIM_FIFO_TYPE = "2kx18" *) 
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
  (* C_PROG_FULL_THRESH_ASSERT_VAL = "2046" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_AXIS = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_RACH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_RDCH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WACH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WDCH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WRCH = "1023" *) 
  (* C_PROG_FULL_THRESH_NEGATE_VAL = "2045" *) 
  (* C_PROG_FULL_TYPE = "0" *) 
  (* C_PROG_FULL_TYPE_AXIS = "0" *) 
  (* C_PROG_FULL_TYPE_RACH = "0" *) 
  (* C_PROG_FULL_TYPE_RDCH = "0" *) 
  (* C_PROG_FULL_TYPE_WACH = "0" *) 
  (* C_PROG_FULL_TYPE_WDCH = "0" *) 
  (* C_PROG_FULL_TYPE_WRCH = "0" *) 
  (* C_RACH_TYPE = "0" *) 
  (* C_RDCH_TYPE = "0" *) 
  (* C_RD_DATA_COUNT_WIDTH = "11" *) 
  (* C_RD_DEPTH = "2048" *) 
  (* C_RD_FREQ = "1" *) 
  (* C_RD_PNTR_WIDTH = "11" *) 
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
  (* C_WR_DATA_COUNT_WIDTH = "11" *) 
  (* C_WR_DEPTH = "2048" *) 
  (* C_WR_DEPTH_AXIS = "1024" *) 
  (* C_WR_DEPTH_RACH = "16" *) 
  (* C_WR_DEPTH_RDCH = "1024" *) 
  (* C_WR_DEPTH_WACH = "16" *) 
  (* C_WR_DEPTH_WDCH = "1024" *) 
  (* C_WR_DEPTH_WRCH = "16" *) 
  (* C_WR_FREQ = "1" *) 
  (* C_WR_PNTR_WIDTH = "11" *) 
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
        .data_count(NLW_U0_data_count_UNCONNECTED[10:0]),
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
        .prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_empty_thresh_assert({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_empty_thresh_negate({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_full(NLW_U0_prog_full_UNCONNECTED),
        .prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_full_thresh_assert({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_full_thresh_negate({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .rd_clk(1'b0),
        .rd_data_count(NLW_U0_rd_data_count_UNCONNECTED[10:0]),
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
        .wr_data_count(NLW_U0_wr_data_count_UNCONNECTED[10:0]),
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 58400)
`pragma protect data_block
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
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
