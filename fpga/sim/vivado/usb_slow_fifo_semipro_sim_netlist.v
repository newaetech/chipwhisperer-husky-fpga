// Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2019.2 (lin64) Build 2708876 Wed Nov  6 21:39:14 MST 2019
// Date        : Thu Apr 20 20:15:35 2023
// Host        : red running 64-bit Ubuntu 18.04.6 LTS
// Command     : write_verilog -force -mode funcsim
//               /home/jpnewae/git/xilinx_simulation_fifos/xilinx_simulation_fifos.srcs/sources_1/ip/usb_slow_fifo_semipro/usb_slow_fifo_semipro_sim_netlist.v
// Design      : usb_slow_fifo_semipro
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7k160tfbg676-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "usb_slow_fifo_semipro,fifo_generator_v13_2_5,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "fifo_generator_v13_2_5,Vivado 2019.2" *) 
(* NotValidForBitStream *)
module usb_slow_fifo_semipro
   (rst,
    wr_clk,
    rd_clk,
    din,
    wr_en,
    rd_en,
    dout,
    full,
    overflow,
    empty,
    underflow);
  input rst;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 write_clk CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME write_clk, FREQ_HZ 200000000, PHASE 0.000, INSERT_VIP 0" *) input wr_clk;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 read_clk CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME read_clk, FREQ_HZ 96000000, PHASE 0.000, INSERT_VIP 0" *) input rd_clk;
  (* x_interface_info = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE WR_DATA" *) input [35:0]din;
  (* x_interface_info = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE WR_EN" *) input wr_en;
  (* x_interface_info = "xilinx.com:interface:fifo_read:1.0 FIFO_READ RD_EN" *) input rd_en;
  (* x_interface_info = "xilinx.com:interface:fifo_read:1.0 FIFO_READ RD_DATA" *) output [35:0]dout;
  (* x_interface_info = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE FULL" *) output full;
  output overflow;
  (* x_interface_info = "xilinx.com:interface:fifo_read:1.0 FIFO_READ EMPTY" *) output empty;
  output underflow;

  wire [35:0]din;
  wire [35:0]dout;
  wire empty;
  wire full;
  wire overflow;
  wire rd_clk;
  wire rd_en;
  wire rst;
  wire underflow;
  wire wr_clk;
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
  wire [15:0]NLW_U0_data_count_UNCONNECTED;
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
  wire [15:0]NLW_U0_rd_data_count_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_buser_UNCONNECTED;
  wire [63:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_ruser_UNCONNECTED;
  wire [15:0]NLW_U0_wr_data_count_UNCONNECTED;

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
  (* C_COMMON_CLOCK = "0" *) 
  (* C_COUNT_TYPE = "0" *) 
  (* C_DATA_COUNT_WIDTH = "16" *) 
  (* C_DEFAULT_VALUE = "BlankString" *) 
  (* C_DIN_WIDTH = "36" *) 
  (* C_DIN_WIDTH_AXIS = "1" *) 
  (* C_DIN_WIDTH_RACH = "32" *) 
  (* C_DIN_WIDTH_RDCH = "64" *) 
  (* C_DIN_WIDTH_WACH = "1" *) 
  (* C_DIN_WIDTH_WDCH = "64" *) 
  (* C_DIN_WIDTH_WRCH = "2" *) 
  (* C_DOUT_RST_VAL = "0" *) 
  (* C_DOUT_WIDTH = "36" *) 
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
  (* C_FAMILY = "kintex7" *) 
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
  (* C_HAS_OVERFLOW = "1" *) 
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
  (* C_PRELOAD_LATENCY = "0" *) 
  (* C_PRELOAD_REGS = "1" *) 
  (* C_PRIM_FIFO_TYPE = "2kx18" *) 
  (* C_PRIM_FIFO_TYPE_AXIS = "1kx18" *) 
  (* C_PRIM_FIFO_TYPE_RACH = "512x36" *) 
  (* C_PRIM_FIFO_TYPE_RDCH = "1kx36" *) 
  (* C_PRIM_FIFO_TYPE_WACH = "512x36" *) 
  (* C_PRIM_FIFO_TYPE_WDCH = "1kx36" *) 
  (* C_PRIM_FIFO_TYPE_WRCH = "512x36" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL = "6" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_AXIS = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_RACH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_RDCH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_WACH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_WDCH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_WRCH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_NEGATE_VAL = "7" *) 
  (* C_PROG_EMPTY_TYPE = "0" *) 
  (* C_PROG_EMPTY_TYPE_AXIS = "0" *) 
  (* C_PROG_EMPTY_TYPE_RACH = "0" *) 
  (* C_PROG_EMPTY_TYPE_RDCH = "0" *) 
  (* C_PROG_EMPTY_TYPE_WACH = "0" *) 
  (* C_PROG_EMPTY_TYPE_WDCH = "0" *) 
  (* C_PROG_EMPTY_TYPE_WRCH = "0" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL = "65553" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_AXIS = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_RACH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_RDCH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WACH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WDCH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WRCH = "1023" *) 
  (* C_PROG_FULL_THRESH_NEGATE_VAL = "65552" *) 
  (* C_PROG_FULL_TYPE = "0" *) 
  (* C_PROG_FULL_TYPE_AXIS = "0" *) 
  (* C_PROG_FULL_TYPE_RACH = "0" *) 
  (* C_PROG_FULL_TYPE_RDCH = "0" *) 
  (* C_PROG_FULL_TYPE_WACH = "0" *) 
  (* C_PROG_FULL_TYPE_WDCH = "0" *) 
  (* C_PROG_FULL_TYPE_WRCH = "0" *) 
  (* C_RACH_TYPE = "0" *) 
  (* C_RDCH_TYPE = "0" *) 
  (* C_RD_DATA_COUNT_WIDTH = "16" *) 
  (* C_RD_DEPTH = "65536" *) 
  (* C_RD_FREQ = "96" *) 
  (* C_RD_PNTR_WIDTH = "16" *) 
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
  (* C_WR_DATA_COUNT_WIDTH = "16" *) 
  (* C_WR_DEPTH = "65536" *) 
  (* C_WR_DEPTH_AXIS = "1024" *) 
  (* C_WR_DEPTH_RACH = "16" *) 
  (* C_WR_DEPTH_RDCH = "1024" *) 
  (* C_WR_DEPTH_WACH = "16" *) 
  (* C_WR_DEPTH_WDCH = "1024" *) 
  (* C_WR_DEPTH_WRCH = "16" *) 
  (* C_WR_FREQ = "200" *) 
  (* C_WR_PNTR_WIDTH = "16" *) 
  (* C_WR_PNTR_WIDTH_AXIS = "10" *) 
  (* C_WR_PNTR_WIDTH_RACH = "4" *) 
  (* C_WR_PNTR_WIDTH_RDCH = "10" *) 
  (* C_WR_PNTR_WIDTH_WACH = "4" *) 
  (* C_WR_PNTR_WIDTH_WDCH = "10" *) 
  (* C_WR_PNTR_WIDTH_WRCH = "4" *) 
  (* C_WR_RESPONSE_LATENCY = "1" *) 
  usb_slow_fifo_semipro_fifo_generator_v13_2_5 U0
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
        .clk(1'b0),
        .data_count(NLW_U0_data_count_UNCONNECTED[15:0]),
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
        .overflow(overflow),
        .prog_empty(NLW_U0_prog_empty_UNCONNECTED),
        .prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_empty_thresh_assert({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_empty_thresh_negate({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_full(NLW_U0_prog_full_UNCONNECTED),
        .prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_full_thresh_assert({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_full_thresh_negate({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .rd_clk(rd_clk),
        .rd_data_count(NLW_U0_rd_data_count_UNCONNECTED[15:0]),
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
        .wr_clk(wr_clk),
        .wr_data_count(NLW_U0_wr_data_count_UNCONNECTED[15:0]),
        .wr_en(wr_en),
        .wr_rst(1'b0),
        .wr_rst_busy(NLW_U0_wr_rst_busy_UNCONNECTED));
endmodule

(* ORIG_REF_NAME = "builtin_extdepth_v6" *) 
module usb_slow_fifo_semipro_builtin_extdepth_v6
   (ful,
    emp,
    dout,
    full,
    empty,
    wr_clk,
    rd_rst_i,
    wr_tmp,
    din,
    rd_clk,
    dout_15_sp_1,
    full_0,
    empty_0);
  output [0:0]ful;
  output [0:0]emp;
  output [17:0]dout;
  output full;
  output empty;
  input wr_clk;
  input rd_rst_i;
  input wr_tmp;
  input [17:0]din;
  input rd_clk;
  input dout_15_sp_1;
  input [0:0]full_0;
  input [0:0]empty_0;

  wire [17:0]\d[10]_9 ;
  wire [17:0]\d[11]_10 ;
  wire [17:0]\d[12]_11 ;
  wire [17:0]\d[13]_12 ;
  wire [17:0]\d[14]_13 ;
  wire [17:0]\d[15]_14 ;
  wire [17:0]\d[16]_15 ;
  wire [17:0]\d[17]_16 ;
  wire [17:0]\d[18]_17 ;
  wire [17:0]\d[19]_18 ;
  wire [17:0]\d[1]_0 ;
  wire [17:0]\d[20]_19 ;
  wire [17:0]\d[21]_20 ;
  wire [17:0]\d[22]_21 ;
  wire [17:0]\d[23]_22 ;
  wire [17:0]\d[24]_23 ;
  wire [17:0]\d[25]_24 ;
  wire [17:0]\d[26]_25 ;
  wire [17:0]\d[27]_26 ;
  wire [17:0]\d[28]_27 ;
  wire [17:0]\d[29]_28 ;
  wire [17:0]\d[2]_1 ;
  wire [17:0]\d[30]_29 ;
  wire [17:0]\d[31]_30 ;
  wire [17:0]\d[3]_2 ;
  wire [17:0]\d[4]_3 ;
  wire [17:0]\d[5]_4 ;
  wire [17:0]\d[6]_5 ;
  wire [17:0]\d[7]_6 ;
  wire [17:0]\d[8]_7 ;
  wire [17:0]\d[9]_8 ;
  (* async_reg = "true" *) (* msgon = "true" *) wire dbr_as_reg;
  (* async_reg = "true" *) (* msgon = "true" *) wire dbr_d1;
  wire [17:0]din;
  wire [17:0]dout;
  wire dout_15_sn_1;
  wire e_1;
  wire e_10;
  wire e_11;
  wire e_12;
  wire e_13;
  wire e_14;
  wire e_15;
  wire e_16;
  wire e_17;
  wire e_18;
  wire e_19;
  wire e_2;
  wire e_20;
  wire e_21;
  wire e_22;
  wire e_23;
  wire e_24;
  wire e_25;
  wire e_26;
  wire e_27;
  wire e_28;
  wire e_29;
  wire e_3;
  wire e_30;
  wire e_31;
  wire e_4;
  wire e_5;
  wire e_6;
  wire e_7;
  wire e_8;
  wire e_9;
  wire [0:0]emp;
  wire empty;
  wire [0:0]empty_0;
  wire [0:0]ful;
  wire ful_0;
  wire ful_1;
  wire ful_10;
  wire ful_11;
  wire ful_12;
  wire ful_13;
  wire ful_14;
  wire ful_15;
  wire ful_16;
  wire ful_17;
  wire ful_18;
  wire ful_19;
  wire ful_2;
  wire ful_20;
  wire ful_21;
  wire ful_22;
  wire ful_23;
  wire ful_24;
  wire ful_25;
  wire ful_26;
  wire ful_27;
  wire ful_28;
  wire ful_29;
  wire ful_3;
  wire ful_30;
  wire ful_4;
  wire ful_5;
  wire ful_6;
  wire ful_7;
  wire ful_8;
  wire ful_9;
  wire full;
  wire [0:0]full_0;
  wire rd_clk;
  wire rd_rst_i;
  (* async_reg = "true" *) (* msgon = "true" *) wire sbr_as_reg;
  (* async_reg = "true" *) (* msgon = "true" *) wire sbr_d1;
  wire wr_clk;
  wire wr_tmp;

  assign dout_15_sn_1 = dout_15_sp_1;
  usb_slow_fifo_semipro_builtin_prim_v6_31 \gchain.gp1[10].gbldc.inst_prim 
       (.\d[10]_9 (\d[10]_9 ),
        .\d[9]_8 (\d[9]_8 ),
        .e_22(e_22),
        .e_23(e_23),
        .ful_21(ful_21),
        .ful_22(ful_22),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_32 \gchain.gp1[11].gbldc.inst_prim 
       (.\d[10]_9 (\d[10]_9 ),
        .\d[11]_10 (\d[11]_10 ),
        .e_21(e_21),
        .e_22(e_22),
        .ful_20(ful_20),
        .ful_21(ful_21),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_33 \gchain.gp1[12].gbldc.inst_prim 
       (.\d[11]_10 (\d[11]_10 ),
        .\d[12]_11 (\d[12]_11 ),
        .e_20(e_20),
        .e_21(e_21),
        .ful_19(ful_19),
        .ful_20(ful_20),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_34 \gchain.gp1[13].gbldc.inst_prim 
       (.\d[12]_11 (\d[12]_11 ),
        .\d[13]_12 (\d[13]_12 ),
        .e_19(e_19),
        .e_20(e_20),
        .ful_18(ful_18),
        .ful_19(ful_19),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_35 \gchain.gp1[14].gbldc.inst_prim 
       (.\d[13]_12 (\d[13]_12 ),
        .\d[14]_13 (\d[14]_13 ),
        .e_18(e_18),
        .e_19(e_19),
        .ful_17(ful_17),
        .ful_18(ful_18),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_36 \gchain.gp1[15].gbldc.inst_prim 
       (.\d[14]_13 (\d[14]_13 ),
        .\d[15]_14 (\d[15]_14 ),
        .e_17(e_17),
        .e_18(e_18),
        .ful_16(ful_16),
        .ful_17(ful_17),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_37 \gchain.gp1[16].gbldc.inst_prim 
       (.\d[15]_14 (\d[15]_14 ),
        .\d[16]_15 (\d[16]_15 ),
        .e_16(e_16),
        .e_17(e_17),
        .ful_15(ful_15),
        .ful_16(ful_16),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_38 \gchain.gp1[17].gbldc.inst_prim 
       (.\d[16]_15 (\d[16]_15 ),
        .\d[17]_16 (\d[17]_16 ),
        .e_15(e_15),
        .e_16(e_16),
        .ful_14(ful_14),
        .ful_15(ful_15),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_39 \gchain.gp1[18].gbldc.inst_prim 
       (.\d[17]_16 (\d[17]_16 ),
        .\d[18]_17 (\d[18]_17 ),
        .e_14(e_14),
        .e_15(e_15),
        .ful_13(ful_13),
        .ful_14(ful_14),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_40 \gchain.gp1[19].gbldc.inst_prim 
       (.\d[18]_17 (\d[18]_17 ),
        .\d[19]_18 (\d[19]_18 ),
        .e_13(e_13),
        .e_14(e_14),
        .ful_12(ful_12),
        .ful_13(ful_13),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_41 \gchain.gp1[1].gbldc.inst_prim 
       (.\d[1]_0 (\d[1]_0 ),
        .din(din),
        .e_31(e_31),
        .ful(ful),
        .ful_30(ful_30),
        .full(full),
        .full_0(full_0),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk),
        .wr_tmp(wr_tmp));
  usb_slow_fifo_semipro_builtin_prim_v6_42 \gchain.gp1[20].gbldc.inst_prim 
       (.\d[19]_18 (\d[19]_18 ),
        .\d[20]_19 (\d[20]_19 ),
        .e_12(e_12),
        .e_13(e_13),
        .ful_11(ful_11),
        .ful_12(ful_12),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_43 \gchain.gp1[21].gbldc.inst_prim 
       (.\d[20]_19 (\d[20]_19 ),
        .\d[21]_20 (\d[21]_20 ),
        .e_11(e_11),
        .e_12(e_12),
        .ful_10(ful_10),
        .ful_11(ful_11),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_44 \gchain.gp1[22].gbldc.inst_prim 
       (.\d[21]_20 (\d[21]_20 ),
        .\d[22]_21 (\d[22]_21 ),
        .e_10(e_10),
        .e_11(e_11),
        .ful_10(ful_10),
        .ful_9(ful_9),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_45 \gchain.gp1[23].gbldc.inst_prim 
       (.\d[22]_21 (\d[22]_21 ),
        .\d[23]_22 (\d[23]_22 ),
        .e_10(e_10),
        .e_9(e_9),
        .ful_8(ful_8),
        .ful_9(ful_9),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_46 \gchain.gp1[24].gbldc.inst_prim 
       (.\d[23]_22 (\d[23]_22 ),
        .\d[24]_23 (\d[24]_23 ),
        .e_8(e_8),
        .e_9(e_9),
        .ful_7(ful_7),
        .ful_8(ful_8),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_47 \gchain.gp1[25].gbldc.inst_prim 
       (.\d[24]_23 (\d[24]_23 ),
        .\d[25]_24 (\d[25]_24 ),
        .e_7(e_7),
        .e_8(e_8),
        .ful_6(ful_6),
        .ful_7(ful_7),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_48 \gchain.gp1[26].gbldc.inst_prim 
       (.\d[25]_24 (\d[25]_24 ),
        .\d[26]_25 (\d[26]_25 ),
        .e_6(e_6),
        .e_7(e_7),
        .ful_5(ful_5),
        .ful_6(ful_6),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_49 \gchain.gp1[27].gbldc.inst_prim 
       (.\d[26]_25 (\d[26]_25 ),
        .\d[27]_26 (\d[27]_26 ),
        .e_5(e_5),
        .e_6(e_6),
        .ful_4(ful_4),
        .ful_5(ful_5),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_50 \gchain.gp1[28].gbldc.inst_prim 
       (.\d[27]_26 (\d[27]_26 ),
        .\d[28]_27 (\d[28]_27 ),
        .e_4(e_4),
        .e_5(e_5),
        .ful_3(ful_3),
        .ful_4(ful_4),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_51 \gchain.gp1[29].gbldc.inst_prim 
       (.\d[28]_27 (\d[28]_27 ),
        .\d[29]_28 (\d[29]_28 ),
        .e_3(e_3),
        .e_4(e_4),
        .ful_2(ful_2),
        .ful_3(ful_3),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_52 \gchain.gp1[2].gbldc.inst_prim 
       (.\d[1]_0 (\d[1]_0 ),
        .\d[2]_1 (\d[2]_1 ),
        .e_30(e_30),
        .e_31(e_31),
        .ful_29(ful_29),
        .ful_30(ful_30),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_53 \gchain.gp1[30].gbldc.inst_prim 
       (.\d[29]_28 (\d[29]_28 ),
        .\d[30]_29 (\d[30]_29 ),
        .e_2(e_2),
        .e_3(e_3),
        .ful_1(ful_1),
        .ful_2(ful_2),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_54 \gchain.gp1[31].gbldc.inst_prim 
       (.\d[30]_29 (\d[30]_29 ),
        .\d[31]_30 (\d[31]_30 ),
        .e_1(e_1),
        .e_2(e_2),
        .ful_0(ful_0),
        .ful_1(ful_1),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6__parameterized0_55 \gchain.gp1[32].gbldl.inst_prim 
       (.\d[31]_30 (\d[31]_30 ),
        .dout(dout),
        .dout_15_sp_1(dout_15_sn_1),
        .e_1(e_1),
        .emp(emp),
        .empty(empty),
        .empty_0(empty_0),
        .ful_0(ful_0),
        .rd_clk(rd_clk),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_56 \gchain.gp1[3].gbldc.inst_prim 
       (.\d[2]_1 (\d[2]_1 ),
        .\d[3]_2 (\d[3]_2 ),
        .e_29(e_29),
        .e_30(e_30),
        .ful_28(ful_28),
        .ful_29(ful_29),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_57 \gchain.gp1[4].gbldc.inst_prim 
       (.\d[3]_2 (\d[3]_2 ),
        .\d[4]_3 (\d[4]_3 ),
        .e_28(e_28),
        .e_29(e_29),
        .ful_27(ful_27),
        .ful_28(ful_28),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_58 \gchain.gp1[5].gbldc.inst_prim 
       (.\d[4]_3 (\d[4]_3 ),
        .\d[5]_4 (\d[5]_4 ),
        .e_27(e_27),
        .e_28(e_28),
        .ful_26(ful_26),
        .ful_27(ful_27),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_59 \gchain.gp1[6].gbldc.inst_prim 
       (.\d[5]_4 (\d[5]_4 ),
        .\d[6]_5 (\d[6]_5 ),
        .e_26(e_26),
        .e_27(e_27),
        .ful_25(ful_25),
        .ful_26(ful_26),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_60 \gchain.gp1[7].gbldc.inst_prim 
       (.\d[6]_5 (\d[6]_5 ),
        .\d[7]_6 (\d[7]_6 ),
        .e_25(e_25),
        .e_26(e_26),
        .ful_24(ful_24),
        .ful_25(ful_25),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_61 \gchain.gp1[8].gbldc.inst_prim 
       (.\d[7]_6 (\d[7]_6 ),
        .\d[8]_7 (\d[8]_7 ),
        .e_24(e_24),
        .e_25(e_25),
        .ful_23(ful_23),
        .ful_24(ful_24),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_62 \gchain.gp1[9].gbldc.inst_prim 
       (.\d[8]_7 (\d[8]_7 ),
        .\d[9]_8 (\d[9]_8 ),
        .e_23(e_23),
        .e_24(e_24),
        .ful_22(ful_22),
        .ful_23(ful_23),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  LUT1 #(
    .INIT(2'h2)) 
    i_0
       (.I0(1'b0),
        .O(sbr_d1));
  LUT1 #(
    .INIT(2'h2)) 
    i_1
       (.I0(1'b0),
        .O(dbr_d1));
  LUT1 #(
    .INIT(2'h2)) 
    i_2
       (.I0(1'b0),
        .O(sbr_as_reg));
  LUT1 #(
    .INIT(2'h2)) 
    i_3
       (.I0(1'b0),
        .O(dbr_as_reg));
endmodule

(* ORIG_REF_NAME = "builtin_extdepth_v6" *) 
module usb_slow_fifo_semipro_builtin_extdepth_v6_0
   (wr_clk_0,
    wr_tmp,
    rd_clk_0,
    dout,
    rd_en_0,
    overflow_int,
    underflow_int,
    wr_clk,
    rd_rst_i,
    din,
    rd_clk,
    rd_en,
    emp,
    ful,
    wr_en);
  output [0:0]wr_clk_0;
  output wr_tmp;
  output [0:0]rd_clk_0;
  output [17:0]dout;
  output rd_en_0;
  output overflow_int;
  output underflow_int;
  input wr_clk;
  input rd_rst_i;
  input [17:0]din;
  input rd_clk;
  input rd_en;
  input [0:0]emp;
  input [0:0]ful;
  input wr_en;

  wire [17:0]\d[10]_40 ;
  wire [17:0]\d[11]_41 ;
  wire [17:0]\d[12]_42 ;
  wire [17:0]\d[13]_43 ;
  wire [17:0]\d[14]_44 ;
  wire [17:0]\d[15]_45 ;
  wire [17:0]\d[16]_46 ;
  wire [17:0]\d[17]_47 ;
  wire [17:0]\d[18]_48 ;
  wire [17:0]\d[19]_49 ;
  wire [17:0]\d[1]_31 ;
  wire [17:0]\d[20]_50 ;
  wire [17:0]\d[21]_51 ;
  wire [17:0]\d[22]_52 ;
  wire [17:0]\d[23]_53 ;
  wire [17:0]\d[24]_54 ;
  wire [17:0]\d[25]_55 ;
  wire [17:0]\d[26]_56 ;
  wire [17:0]\d[27]_57 ;
  wire [17:0]\d[28]_58 ;
  wire [17:0]\d[29]_59 ;
  wire [17:0]\d[2]_32 ;
  wire [17:0]\d[30]_60 ;
  wire [17:0]\d[31]_61 ;
  wire [17:0]\d[3]_33 ;
  wire [17:0]\d[4]_34 ;
  wire [17:0]\d[5]_35 ;
  wire [17:0]\d[6]_36 ;
  wire [17:0]\d[7]_37 ;
  wire [17:0]\d[8]_38 ;
  wire [17:0]\d[9]_39 ;
  (* async_reg = "true" *) (* msgon = "true" *) wire dbr_as_reg;
  (* async_reg = "true" *) (* msgon = "true" *) wire dbr_d1;
  wire [17:0]din;
  wire [17:0]dout;
  wire e_1;
  wire e_10;
  wire e_11;
  wire e_12;
  wire e_13;
  wire e_14;
  wire e_15;
  wire e_16;
  wire e_17;
  wire e_18;
  wire e_19;
  wire e_2;
  wire e_20;
  wire e_21;
  wire e_22;
  wire e_23;
  wire e_24;
  wire e_25;
  wire e_26;
  wire e_27;
  wire e_28;
  wire e_29;
  wire e_3;
  wire e_30;
  wire e_31;
  wire e_4;
  wire e_5;
  wire e_6;
  wire e_7;
  wire e_8;
  wire e_9;
  wire [0:0]emp;
  wire [0:0]ful;
  wire ful_0;
  wire ful_1;
  wire ful_10;
  wire ful_11;
  wire ful_12;
  wire ful_13;
  wire ful_14;
  wire ful_15;
  wire ful_16;
  wire ful_17;
  wire ful_18;
  wire ful_19;
  wire ful_2;
  wire ful_20;
  wire ful_21;
  wire ful_22;
  wire ful_23;
  wire ful_24;
  wire ful_25;
  wire ful_26;
  wire ful_27;
  wire ful_28;
  wire ful_29;
  wire ful_3;
  wire ful_30;
  wire ful_4;
  wire ful_5;
  wire ful_6;
  wire ful_7;
  wire ful_8;
  wire ful_9;
  wire overflow_int;
  wire rd_clk;
  wire [0:0]rd_clk_0;
  wire rd_en;
  wire rd_en_0;
  wire rd_rst_i;
  (* async_reg = "true" *) (* msgon = "true" *) wire sbr_as_reg;
  (* async_reg = "true" *) (* msgon = "true" *) wire sbr_d1;
  wire underflow_int;
  wire wr_clk;
  wire [0:0]wr_clk_0;
  wire wr_en;
  wire wr_tmp;

  usb_slow_fifo_semipro_builtin_prim_v6 \gchain.gp1[10].gbldc.inst_prim 
       (.\d[10]_40 (\d[10]_40 ),
        .\d[9]_39 (\d[9]_39 ),
        .e_22(e_22),
        .e_23(e_23),
        .ful_21(ful_21),
        .ful_22(ful_22),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_1 \gchain.gp1[11].gbldc.inst_prim 
       (.\d[10]_40 (\d[10]_40 ),
        .\d[11]_41 (\d[11]_41 ),
        .e_21(e_21),
        .e_22(e_22),
        .ful_20(ful_20),
        .ful_21(ful_21),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_2 \gchain.gp1[12].gbldc.inst_prim 
       (.\d[11]_41 (\d[11]_41 ),
        .\d[12]_42 (\d[12]_42 ),
        .e_20(e_20),
        .e_21(e_21),
        .ful_19(ful_19),
        .ful_20(ful_20),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_3 \gchain.gp1[13].gbldc.inst_prim 
       (.\d[12]_42 (\d[12]_42 ),
        .\d[13]_43 (\d[13]_43 ),
        .e_19(e_19),
        .e_20(e_20),
        .ful_18(ful_18),
        .ful_19(ful_19),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_4 \gchain.gp1[14].gbldc.inst_prim 
       (.\d[13]_43 (\d[13]_43 ),
        .\d[14]_44 (\d[14]_44 ),
        .e_18(e_18),
        .e_19(e_19),
        .ful_17(ful_17),
        .ful_18(ful_18),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_5 \gchain.gp1[15].gbldc.inst_prim 
       (.\d[14]_44 (\d[14]_44 ),
        .\d[15]_45 (\d[15]_45 ),
        .e_17(e_17),
        .e_18(e_18),
        .ful_16(ful_16),
        .ful_17(ful_17),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_6 \gchain.gp1[16].gbldc.inst_prim 
       (.\d[15]_45 (\d[15]_45 ),
        .\d[16]_46 (\d[16]_46 ),
        .e_16(e_16),
        .e_17(e_17),
        .ful_15(ful_15),
        .ful_16(ful_16),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_7 \gchain.gp1[17].gbldc.inst_prim 
       (.\d[16]_46 (\d[16]_46 ),
        .\d[17]_47 (\d[17]_47 ),
        .e_15(e_15),
        .e_16(e_16),
        .ful_14(ful_14),
        .ful_15(ful_15),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_8 \gchain.gp1[18].gbldc.inst_prim 
       (.\d[17]_47 (\d[17]_47 ),
        .\d[18]_48 (\d[18]_48 ),
        .e_14(e_14),
        .e_15(e_15),
        .ful_13(ful_13),
        .ful_14(ful_14),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_9 \gchain.gp1[19].gbldc.inst_prim 
       (.\d[18]_48 (\d[18]_48 ),
        .\d[19]_49 (\d[19]_49 ),
        .e_13(e_13),
        .e_14(e_14),
        .ful_12(ful_12),
        .ful_13(ful_13),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_10 \gchain.gp1[1].gbldc.inst_prim 
       (.\d[1]_31 (\d[1]_31 ),
        .din(din),
        .e_31(e_31),
        .ful(ful),
        .ful_30(ful_30),
        .overflow_int(overflow_int),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk),
        .wr_clk_0(wr_clk_0),
        .wr_en(wr_en),
        .wr_tmp(wr_tmp));
  usb_slow_fifo_semipro_builtin_prim_v6_11 \gchain.gp1[20].gbldc.inst_prim 
       (.\d[19]_49 (\d[19]_49 ),
        .\d[20]_50 (\d[20]_50 ),
        .e_12(e_12),
        .e_13(e_13),
        .ful_11(ful_11),
        .ful_12(ful_12),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_12 \gchain.gp1[21].gbldc.inst_prim 
       (.\d[20]_50 (\d[20]_50 ),
        .\d[21]_51 (\d[21]_51 ),
        .e_11(e_11),
        .e_12(e_12),
        .ful_10(ful_10),
        .ful_11(ful_11),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_13 \gchain.gp1[22].gbldc.inst_prim 
       (.\d[21]_51 (\d[21]_51 ),
        .\d[22]_52 (\d[22]_52 ),
        .e_10(e_10),
        .e_11(e_11),
        .ful_10(ful_10),
        .ful_9(ful_9),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_14 \gchain.gp1[23].gbldc.inst_prim 
       (.\d[22]_52 (\d[22]_52 ),
        .\d[23]_53 (\d[23]_53 ),
        .e_10(e_10),
        .e_9(e_9),
        .ful_8(ful_8),
        .ful_9(ful_9),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_15 \gchain.gp1[24].gbldc.inst_prim 
       (.\d[23]_53 (\d[23]_53 ),
        .\d[24]_54 (\d[24]_54 ),
        .e_8(e_8),
        .e_9(e_9),
        .ful_7(ful_7),
        .ful_8(ful_8),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_16 \gchain.gp1[25].gbldc.inst_prim 
       (.\d[24]_54 (\d[24]_54 ),
        .\d[25]_55 (\d[25]_55 ),
        .e_7(e_7),
        .e_8(e_8),
        .ful_6(ful_6),
        .ful_7(ful_7),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_17 \gchain.gp1[26].gbldc.inst_prim 
       (.\d[25]_55 (\d[25]_55 ),
        .\d[26]_56 (\d[26]_56 ),
        .e_6(e_6),
        .e_7(e_7),
        .ful_5(ful_5),
        .ful_6(ful_6),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_18 \gchain.gp1[27].gbldc.inst_prim 
       (.\d[26]_56 (\d[26]_56 ),
        .\d[27]_57 (\d[27]_57 ),
        .e_5(e_5),
        .e_6(e_6),
        .ful_4(ful_4),
        .ful_5(ful_5),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_19 \gchain.gp1[28].gbldc.inst_prim 
       (.\d[27]_57 (\d[27]_57 ),
        .\d[28]_58 (\d[28]_58 ),
        .e_4(e_4),
        .e_5(e_5),
        .ful_3(ful_3),
        .ful_4(ful_4),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_20 \gchain.gp1[29].gbldc.inst_prim 
       (.\d[28]_58 (\d[28]_58 ),
        .\d[29]_59 (\d[29]_59 ),
        .e_3(e_3),
        .e_4(e_4),
        .ful_2(ful_2),
        .ful_3(ful_3),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_21 \gchain.gp1[2].gbldc.inst_prim 
       (.\d[1]_31 (\d[1]_31 ),
        .\d[2]_32 (\d[2]_32 ),
        .e_30(e_30),
        .e_31(e_31),
        .ful_29(ful_29),
        .ful_30(ful_30),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_22 \gchain.gp1[30].gbldc.inst_prim 
       (.\d[29]_59 (\d[29]_59 ),
        .\d[30]_60 (\d[30]_60 ),
        .e_2(e_2),
        .e_3(e_3),
        .ful_1(ful_1),
        .ful_2(ful_2),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_23 \gchain.gp1[31].gbldc.inst_prim 
       (.\d[30]_60 (\d[30]_60 ),
        .\d[31]_61 (\d[31]_61 ),
        .e_1(e_1),
        .e_2(e_2),
        .ful_0(ful_0),
        .ful_1(ful_1),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6__parameterized0 \gchain.gp1[32].gbldl.inst_prim 
       (.\d[31]_61 (\d[31]_61 ),
        .dout(dout),
        .e_1(e_1),
        .emp(emp),
        .ful_0(ful_0),
        .rd_clk(rd_clk),
        .rd_clk_0(rd_clk_0),
        .rd_en(rd_en),
        .rd_en_0(rd_en_0),
        .rd_rst_i(rd_rst_i),
        .underflow_int(underflow_int),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_24 \gchain.gp1[3].gbldc.inst_prim 
       (.\d[2]_32 (\d[2]_32 ),
        .\d[3]_33 (\d[3]_33 ),
        .e_29(e_29),
        .e_30(e_30),
        .ful_28(ful_28),
        .ful_29(ful_29),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_25 \gchain.gp1[4].gbldc.inst_prim 
       (.\d[3]_33 (\d[3]_33 ),
        .\d[4]_34 (\d[4]_34 ),
        .e_28(e_28),
        .e_29(e_29),
        .ful_27(ful_27),
        .ful_28(ful_28),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_26 \gchain.gp1[5].gbldc.inst_prim 
       (.\d[4]_34 (\d[4]_34 ),
        .\d[5]_35 (\d[5]_35 ),
        .e_27(e_27),
        .e_28(e_28),
        .ful_26(ful_26),
        .ful_27(ful_27),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_27 \gchain.gp1[6].gbldc.inst_prim 
       (.\d[5]_35 (\d[5]_35 ),
        .\d[6]_36 (\d[6]_36 ),
        .e_26(e_26),
        .e_27(e_27),
        .ful_25(ful_25),
        .ful_26(ful_26),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_28 \gchain.gp1[7].gbldc.inst_prim 
       (.\d[6]_36 (\d[6]_36 ),
        .\d[7]_37 (\d[7]_37 ),
        .e_25(e_25),
        .e_26(e_26),
        .ful_24(ful_24),
        .ful_25(ful_25),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_29 \gchain.gp1[8].gbldc.inst_prim 
       (.\d[7]_37 (\d[7]_37 ),
        .\d[8]_38 (\d[8]_38 ),
        .e_24(e_24),
        .e_25(e_25),
        .ful_23(ful_23),
        .ful_24(ful_24),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_prim_v6_30 \gchain.gp1[9].gbldc.inst_prim 
       (.\d[8]_38 (\d[8]_38 ),
        .\d[9]_39 (\d[9]_39 ),
        .e_23(e_23),
        .e_24(e_24),
        .ful_22(ful_22),
        .ful_23(ful_23),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk));
  LUT1 #(
    .INIT(2'h2)) 
    i_0
       (.I0(1'b0),
        .O(sbr_d1));
  LUT1 #(
    .INIT(2'h2)) 
    i_1
       (.I0(1'b0),
        .O(dbr_d1));
  LUT1 #(
    .INIT(2'h2)) 
    i_2
       (.I0(1'b0),
        .O(sbr_as_reg));
  LUT1 #(
    .INIT(2'h2)) 
    i_3
       (.I0(1'b0),
        .O(dbr_as_reg));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6
   (ful_22,
    \d[10]_40 ,
    e_22,
    wr_clk,
    rd_rst_i,
    e_23,
    \d[9]_39 ,
    ful_21);
  output ful_22;
  output [17:0]\d[10]_40 ;
  output e_22;
  input wr_clk;
  input rd_rst_i;
  input e_23;
  input [17:0]\d[9]_39 ;
  input ful_21;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[10]_40 ;
  wire [17:0]\d[9]_39 ;
  wire e_22;
  wire e_23;
  wire emp_22;
  wire ful_21;
  wire ful_22;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[9]_39 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[9]_39 [17:16]}),
        .DO({DO,\d[10]_40 [15:0]}),
        .DOP({DOP,\d[10]_40 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_22),
        .FULL(ful_22),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_22),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_23),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__51 
       (.I0(emp_22),
        .I1(ful_21),
        .O(e_22));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_1
   (ful_21,
    \d[11]_41 ,
    e_21,
    wr_clk,
    rd_rst_i,
    e_22,
    \d[10]_40 ,
    ful_20);
  output ful_21;
  output [17:0]\d[11]_41 ;
  output e_21;
  input wr_clk;
  input rd_rst_i;
  input e_22;
  input [17:0]\d[10]_40 ;
  input ful_20;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[10]_40 ;
  wire [17:0]\d[11]_41 ;
  wire e_21;
  wire e_22;
  wire emp_21;
  wire ful_20;
  wire ful_21;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[10]_40 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[10]_40 [17:16]}),
        .DO({DO,\d[11]_41 [15:0]}),
        .DOP({DOP,\d[11]_41 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_21),
        .FULL(ful_21),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_21),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_22),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__50 
       (.I0(emp_21),
        .I1(ful_20),
        .O(e_21));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_10
   (wr_clk_0,
    \d[1]_31 ,
    e_31,
    wr_tmp,
    overflow_int,
    wr_clk,
    rd_rst_i,
    din,
    ful_30,
    ful,
    wr_en);
  output [0:0]wr_clk_0;
  output [17:0]\d[1]_31 ;
  output e_31;
  output wr_tmp;
  output overflow_int;
  input wr_clk;
  input rd_rst_i;
  input [17:0]din;
  input ful_30;
  input [0:0]ful;
  input wr_en;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[1]_31 ;
  wire [17:0]din;
  wire e_31;
  wire emp_31;
  wire [0:0]ful;
  wire ful_30;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire overflow_int;
  wire [2:2]pf;
  wire rd_rst_i;
  wire wr_clk;
  wire [0:0]wr_clk_0;
  wire wr_en;
  wire wr_tmp;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(pf),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,din[15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,din[17:16]}),
        .DO({DO,\d[1]_31 [15:0]}),
        .DOP({DOP,\d[1]_31 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_31),
        .FULL(wr_clk_0),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_31),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(wr_tmp),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__30 
       (.I0(emp_31),
        .I1(ful_30),
        .O(e_31));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT3 #(
    .INIT(8'h02)) 
    \gf36e1_inst.sngfifo36e1_i_2 
       (.I0(wr_en),
        .I1(wr_clk_0),
        .I2(ful),
        .O(wr_tmp));
  (* SOFT_HLUTNM = "soft_lutpair0" *) 
  LUT3 #(
    .INIT(8'hE0)) 
    \govw.govw2.OVERFLOW_i_1 
       (.I0(wr_clk_0),
        .I1(ful),
        .I2(wr_en),
        .O(overflow_int));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_11
   (ful_12,
    \d[20]_50 ,
    e_12,
    wr_clk,
    rd_rst_i,
    e_13,
    \d[19]_49 ,
    ful_11);
  output ful_12;
  output [17:0]\d[20]_50 ;
  output e_12;
  input wr_clk;
  input rd_rst_i;
  input e_13;
  input [17:0]\d[19]_49 ;
  input ful_11;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[19]_49 ;
  wire [17:0]\d[20]_50 ;
  wire e_12;
  wire e_13;
  wire emp_12;
  wire ful_11;
  wire ful_12;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[19]_49 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[19]_49 [17:16]}),
        .DO({DO,\d[20]_50 [15:0]}),
        .DOP({DOP,\d[20]_50 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_12),
        .FULL(ful_12),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_12),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_13),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__41 
       (.I0(emp_12),
        .I1(ful_11),
        .O(e_12));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_12
   (ful_11,
    \d[21]_51 ,
    e_11,
    wr_clk,
    rd_rst_i,
    e_12,
    \d[20]_50 ,
    ful_10);
  output ful_11;
  output [17:0]\d[21]_51 ;
  output e_11;
  input wr_clk;
  input rd_rst_i;
  input e_12;
  input [17:0]\d[20]_50 ;
  input ful_10;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[20]_50 ;
  wire [17:0]\d[21]_51 ;
  wire e_11;
  wire e_12;
  wire emp_11;
  wire ful_10;
  wire ful_11;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[20]_50 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[20]_50 [17:16]}),
        .DO({DO,\d[21]_51 [15:0]}),
        .DOP({DOP,\d[21]_51 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_11),
        .FULL(ful_11),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_11),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_12),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__40 
       (.I0(emp_11),
        .I1(ful_10),
        .O(e_11));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_13
   (ful_10,
    \d[22]_52 ,
    e_10,
    wr_clk,
    rd_rst_i,
    e_11,
    \d[21]_51 ,
    ful_9);
  output ful_10;
  output [17:0]\d[22]_52 ;
  output e_10;
  input wr_clk;
  input rd_rst_i;
  input e_11;
  input [17:0]\d[21]_51 ;
  input ful_9;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[21]_51 ;
  wire [17:0]\d[22]_52 ;
  wire e_10;
  wire e_11;
  wire emp_10;
  wire ful_10;
  wire ful_9;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[21]_51 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[21]_51 [17:16]}),
        .DO({DO,\d[22]_52 [15:0]}),
        .DOP({DOP,\d[22]_52 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_10),
        .FULL(ful_10),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_10),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_11),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__39 
       (.I0(emp_10),
        .I1(ful_9),
        .O(e_10));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_14
   (ful_9,
    \d[23]_53 ,
    e_9,
    wr_clk,
    rd_rst_i,
    e_10,
    \d[22]_52 ,
    ful_8);
  output ful_9;
  output [17:0]\d[23]_53 ;
  output e_9;
  input wr_clk;
  input rd_rst_i;
  input e_10;
  input [17:0]\d[22]_52 ;
  input ful_8;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[22]_52 ;
  wire [17:0]\d[23]_53 ;
  wire e_10;
  wire e_9;
  wire emp_9;
  wire ful_8;
  wire ful_9;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[22]_52 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[22]_52 [17:16]}),
        .DO({DO,\d[23]_53 [15:0]}),
        .DOP({DOP,\d[23]_53 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_9),
        .FULL(ful_9),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_9),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_10),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__38 
       (.I0(emp_9),
        .I1(ful_8),
        .O(e_9));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_15
   (ful_8,
    \d[24]_54 ,
    e_8,
    wr_clk,
    rd_rst_i,
    e_9,
    \d[23]_53 ,
    ful_7);
  output ful_8;
  output [17:0]\d[24]_54 ;
  output e_8;
  input wr_clk;
  input rd_rst_i;
  input e_9;
  input [17:0]\d[23]_53 ;
  input ful_7;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[23]_53 ;
  wire [17:0]\d[24]_54 ;
  wire e_8;
  wire e_9;
  wire emp_8;
  wire ful_7;
  wire ful_8;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[23]_53 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[23]_53 [17:16]}),
        .DO({DO,\d[24]_54 [15:0]}),
        .DOP({DOP,\d[24]_54 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_8),
        .FULL(ful_8),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_8),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_9),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__37 
       (.I0(emp_8),
        .I1(ful_7),
        .O(e_8));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_16
   (ful_7,
    \d[25]_55 ,
    e_7,
    wr_clk,
    rd_rst_i,
    e_8,
    \d[24]_54 ,
    ful_6);
  output ful_7;
  output [17:0]\d[25]_55 ;
  output e_7;
  input wr_clk;
  input rd_rst_i;
  input e_8;
  input [17:0]\d[24]_54 ;
  input ful_6;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[24]_54 ;
  wire [17:0]\d[25]_55 ;
  wire e_7;
  wire e_8;
  wire emp_7;
  wire ful_6;
  wire ful_7;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[24]_54 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[24]_54 [17:16]}),
        .DO({DO,\d[25]_55 [15:0]}),
        .DOP({DOP,\d[25]_55 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_7),
        .FULL(ful_7),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_7),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_8),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__36 
       (.I0(emp_7),
        .I1(ful_6),
        .O(e_7));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_17
   (ful_6,
    \d[26]_56 ,
    e_6,
    wr_clk,
    rd_rst_i,
    e_7,
    \d[25]_55 ,
    ful_5);
  output ful_6;
  output [17:0]\d[26]_56 ;
  output e_6;
  input wr_clk;
  input rd_rst_i;
  input e_7;
  input [17:0]\d[25]_55 ;
  input ful_5;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[25]_55 ;
  wire [17:0]\d[26]_56 ;
  wire e_6;
  wire e_7;
  wire emp_6;
  wire ful_5;
  wire ful_6;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[25]_55 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[25]_55 [17:16]}),
        .DO({DO,\d[26]_56 [15:0]}),
        .DOP({DOP,\d[26]_56 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_6),
        .FULL(ful_6),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_6),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_7),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__35 
       (.I0(emp_6),
        .I1(ful_5),
        .O(e_6));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_18
   (ful_5,
    \d[27]_57 ,
    e_5,
    wr_clk,
    rd_rst_i,
    e_6,
    \d[26]_56 ,
    ful_4);
  output ful_5;
  output [17:0]\d[27]_57 ;
  output e_5;
  input wr_clk;
  input rd_rst_i;
  input e_6;
  input [17:0]\d[26]_56 ;
  input ful_4;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[26]_56 ;
  wire [17:0]\d[27]_57 ;
  wire e_5;
  wire e_6;
  wire emp_5;
  wire ful_4;
  wire ful_5;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[26]_56 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[26]_56 [17:16]}),
        .DO({DO,\d[27]_57 [15:0]}),
        .DOP({DOP,\d[27]_57 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_5),
        .FULL(ful_5),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_5),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_6),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__34 
       (.I0(emp_5),
        .I1(ful_4),
        .O(e_5));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_19
   (ful_4,
    \d[28]_58 ,
    e_4,
    wr_clk,
    rd_rst_i,
    e_5,
    \d[27]_57 ,
    ful_3);
  output ful_4;
  output [17:0]\d[28]_58 ;
  output e_4;
  input wr_clk;
  input rd_rst_i;
  input e_5;
  input [17:0]\d[27]_57 ;
  input ful_3;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[27]_57 ;
  wire [17:0]\d[28]_58 ;
  wire e_4;
  wire e_5;
  wire emp_4;
  wire ful_3;
  wire ful_4;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[27]_57 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[27]_57 [17:16]}),
        .DO({DO,\d[28]_58 [15:0]}),
        .DOP({DOP,\d[28]_58 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_4),
        .FULL(ful_4),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_4),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_5),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__33 
       (.I0(emp_4),
        .I1(ful_3),
        .O(e_4));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_2
   (ful_20,
    \d[12]_42 ,
    e_20,
    wr_clk,
    rd_rst_i,
    e_21,
    \d[11]_41 ,
    ful_19);
  output ful_20;
  output [17:0]\d[12]_42 ;
  output e_20;
  input wr_clk;
  input rd_rst_i;
  input e_21;
  input [17:0]\d[11]_41 ;
  input ful_19;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[11]_41 ;
  wire [17:0]\d[12]_42 ;
  wire e_20;
  wire e_21;
  wire emp_20;
  wire ful_19;
  wire ful_20;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[11]_41 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[11]_41 [17:16]}),
        .DO({DO,\d[12]_42 [15:0]}),
        .DOP({DOP,\d[12]_42 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_20),
        .FULL(ful_20),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_20),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_21),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__49 
       (.I0(emp_20),
        .I1(ful_19),
        .O(e_20));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_20
   (ful_3,
    \d[29]_59 ,
    e_3,
    wr_clk,
    rd_rst_i,
    e_4,
    \d[28]_58 ,
    ful_2);
  output ful_3;
  output [17:0]\d[29]_59 ;
  output e_3;
  input wr_clk;
  input rd_rst_i;
  input e_4;
  input [17:0]\d[28]_58 ;
  input ful_2;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[28]_58 ;
  wire [17:0]\d[29]_59 ;
  wire e_3;
  wire e_4;
  wire emp_3;
  wire ful_2;
  wire ful_3;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[28]_58 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[28]_58 [17:16]}),
        .DO({DO,\d[29]_59 [15:0]}),
        .DOP({DOP,\d[29]_59 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_3),
        .FULL(ful_3),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_3),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_4),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__32 
       (.I0(emp_3),
        .I1(ful_2),
        .O(e_3));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_21
   (ful_30,
    \d[2]_32 ,
    e_30,
    wr_clk,
    rd_rst_i,
    e_31,
    \d[1]_31 ,
    ful_29);
  output ful_30;
  output [17:0]\d[2]_32 ;
  output e_30;
  input wr_clk;
  input rd_rst_i;
  input e_31;
  input [17:0]\d[1]_31 ;
  input ful_29;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[1]_31 ;
  wire [17:0]\d[2]_32 ;
  wire e_30;
  wire e_31;
  wire emp_30;
  wire ful_29;
  wire ful_30;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[1]_31 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[1]_31 [17:16]}),
        .DO({DO,\d[2]_32 [15:0]}),
        .DOP({DOP,\d[2]_32 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_30),
        .FULL(ful_30),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_30),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_31),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__59 
       (.I0(emp_30),
        .I1(ful_29),
        .O(e_30));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_22
   (ful_2,
    \d[30]_60 ,
    e_2,
    wr_clk,
    rd_rst_i,
    e_3,
    \d[29]_59 ,
    ful_1);
  output ful_2;
  output [17:0]\d[30]_60 ;
  output e_2;
  input wr_clk;
  input rd_rst_i;
  input e_3;
  input [17:0]\d[29]_59 ;
  input ful_1;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[29]_59 ;
  wire [17:0]\d[30]_60 ;
  wire e_2;
  wire e_3;
  wire emp_2;
  wire ful_1;
  wire ful_2;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[29]_59 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[29]_59 [17:16]}),
        .DO({DO,\d[30]_60 [15:0]}),
        .DOP({DOP,\d[30]_60 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_2),
        .FULL(ful_2),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_2),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_3),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__31 
       (.I0(emp_2),
        .I1(ful_1),
        .O(e_2));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_23
   (ful_1,
    \d[31]_61 ,
    e_1,
    wr_clk,
    rd_rst_i,
    e_2,
    \d[30]_60 ,
    ful_0);
  output ful_1;
  output [17:0]\d[31]_61 ;
  output e_1;
  input wr_clk;
  input rd_rst_i;
  input e_2;
  input [17:0]\d[30]_60 ;
  input ful_0;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[30]_60 ;
  wire [17:0]\d[31]_61 ;
  wire e_1;
  wire e_2;
  wire emp_1;
  wire ful_0;
  wire ful_1;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[30]_60 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[30]_60 [17:16]}),
        .DO({DO,\d[31]_61 [15:0]}),
        .DOP({DOP,\d[31]_61 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_1),
        .FULL(ful_1),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_1),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_2),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_3 
       (.I0(emp_1),
        .I1(ful_0),
        .O(e_1));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_24
   (ful_29,
    \d[3]_33 ,
    e_29,
    wr_clk,
    rd_rst_i,
    e_30,
    \d[2]_32 ,
    ful_28);
  output ful_29;
  output [17:0]\d[3]_33 ;
  output e_29;
  input wr_clk;
  input rd_rst_i;
  input e_30;
  input [17:0]\d[2]_32 ;
  input ful_28;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[2]_32 ;
  wire [17:0]\d[3]_33 ;
  wire e_29;
  wire e_30;
  wire emp_29;
  wire ful_28;
  wire ful_29;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[2]_32 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[2]_32 [17:16]}),
        .DO({DO,\d[3]_33 [15:0]}),
        .DOP({DOP,\d[3]_33 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_29),
        .FULL(ful_29),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_29),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_30),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__58 
       (.I0(emp_29),
        .I1(ful_28),
        .O(e_29));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_25
   (ful_28,
    \d[4]_34 ,
    e_28,
    wr_clk,
    rd_rst_i,
    e_29,
    \d[3]_33 ,
    ful_27);
  output ful_28;
  output [17:0]\d[4]_34 ;
  output e_28;
  input wr_clk;
  input rd_rst_i;
  input e_29;
  input [17:0]\d[3]_33 ;
  input ful_27;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[3]_33 ;
  wire [17:0]\d[4]_34 ;
  wire e_28;
  wire e_29;
  wire emp_28;
  wire ful_27;
  wire ful_28;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[3]_33 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[3]_33 [17:16]}),
        .DO({DO,\d[4]_34 [15:0]}),
        .DOP({DOP,\d[4]_34 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_28),
        .FULL(ful_28),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_28),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_29),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__57 
       (.I0(emp_28),
        .I1(ful_27),
        .O(e_28));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_26
   (ful_27,
    \d[5]_35 ,
    e_27,
    wr_clk,
    rd_rst_i,
    e_28,
    \d[4]_34 ,
    ful_26);
  output ful_27;
  output [17:0]\d[5]_35 ;
  output e_27;
  input wr_clk;
  input rd_rst_i;
  input e_28;
  input [17:0]\d[4]_34 ;
  input ful_26;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[4]_34 ;
  wire [17:0]\d[5]_35 ;
  wire e_27;
  wire e_28;
  wire emp_27;
  wire ful_26;
  wire ful_27;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[4]_34 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[4]_34 [17:16]}),
        .DO({DO,\d[5]_35 [15:0]}),
        .DOP({DOP,\d[5]_35 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_27),
        .FULL(ful_27),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_27),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_28),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__56 
       (.I0(emp_27),
        .I1(ful_26),
        .O(e_27));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_27
   (ful_26,
    \d[6]_36 ,
    e_26,
    wr_clk,
    rd_rst_i,
    e_27,
    \d[5]_35 ,
    ful_25);
  output ful_26;
  output [17:0]\d[6]_36 ;
  output e_26;
  input wr_clk;
  input rd_rst_i;
  input e_27;
  input [17:0]\d[5]_35 ;
  input ful_25;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[5]_35 ;
  wire [17:0]\d[6]_36 ;
  wire e_26;
  wire e_27;
  wire emp_26;
  wire ful_25;
  wire ful_26;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[5]_35 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[5]_35 [17:16]}),
        .DO({DO,\d[6]_36 [15:0]}),
        .DOP({DOP,\d[6]_36 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_26),
        .FULL(ful_26),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_26),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_27),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__55 
       (.I0(emp_26),
        .I1(ful_25),
        .O(e_26));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_28
   (ful_25,
    \d[7]_37 ,
    e_25,
    wr_clk,
    rd_rst_i,
    e_26,
    \d[6]_36 ,
    ful_24);
  output ful_25;
  output [17:0]\d[7]_37 ;
  output e_25;
  input wr_clk;
  input rd_rst_i;
  input e_26;
  input [17:0]\d[6]_36 ;
  input ful_24;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[6]_36 ;
  wire [17:0]\d[7]_37 ;
  wire e_25;
  wire e_26;
  wire emp_25;
  wire ful_24;
  wire ful_25;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[6]_36 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[6]_36 [17:16]}),
        .DO({DO,\d[7]_37 [15:0]}),
        .DOP({DOP,\d[7]_37 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_25),
        .FULL(ful_25),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_25),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_26),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__54 
       (.I0(emp_25),
        .I1(ful_24),
        .O(e_25));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_29
   (ful_24,
    \d[8]_38 ,
    e_24,
    wr_clk,
    rd_rst_i,
    e_25,
    \d[7]_37 ,
    ful_23);
  output ful_24;
  output [17:0]\d[8]_38 ;
  output e_24;
  input wr_clk;
  input rd_rst_i;
  input e_25;
  input [17:0]\d[7]_37 ;
  input ful_23;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[7]_37 ;
  wire [17:0]\d[8]_38 ;
  wire e_24;
  wire e_25;
  wire emp_24;
  wire ful_23;
  wire ful_24;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[7]_37 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[7]_37 [17:16]}),
        .DO({DO,\d[8]_38 [15:0]}),
        .DOP({DOP,\d[8]_38 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_24),
        .FULL(ful_24),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_24),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_25),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__53 
       (.I0(emp_24),
        .I1(ful_23),
        .O(e_24));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_3
   (ful_19,
    \d[13]_43 ,
    e_19,
    wr_clk,
    rd_rst_i,
    e_20,
    \d[12]_42 ,
    ful_18);
  output ful_19;
  output [17:0]\d[13]_43 ;
  output e_19;
  input wr_clk;
  input rd_rst_i;
  input e_20;
  input [17:0]\d[12]_42 ;
  input ful_18;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[12]_42 ;
  wire [17:0]\d[13]_43 ;
  wire e_19;
  wire e_20;
  wire emp_19;
  wire ful_18;
  wire ful_19;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[12]_42 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[12]_42 [17:16]}),
        .DO({DO,\d[13]_43 [15:0]}),
        .DOP({DOP,\d[13]_43 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_19),
        .FULL(ful_19),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_19),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_20),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__48 
       (.I0(emp_19),
        .I1(ful_18),
        .O(e_19));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_30
   (ful_23,
    \d[9]_39 ,
    e_23,
    wr_clk,
    rd_rst_i,
    e_24,
    \d[8]_38 ,
    ful_22);
  output ful_23;
  output [17:0]\d[9]_39 ;
  output e_23;
  input wr_clk;
  input rd_rst_i;
  input e_24;
  input [17:0]\d[8]_38 ;
  input ful_22;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[8]_38 ;
  wire [17:0]\d[9]_39 ;
  wire e_23;
  wire e_24;
  wire emp_23;
  wire ful_22;
  wire ful_23;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[8]_38 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[8]_38 [17:16]}),
        .DO({DO,\d[9]_39 [15:0]}),
        .DOP({DOP,\d[9]_39 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_23),
        .FULL(ful_23),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_23),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_24),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__52 
       (.I0(emp_23),
        .I1(ful_22),
        .O(e_23));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_31
   (ful_22,
    \d[10]_9 ,
    e_22,
    wr_clk,
    rd_rst_i,
    e_23,
    \d[9]_8 ,
    ful_21);
  output ful_22;
  output [17:0]\d[10]_9 ;
  output e_22;
  input wr_clk;
  input rd_rst_i;
  input e_23;
  input [17:0]\d[9]_8 ;
  input ful_21;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[10]_9 ;
  wire [17:0]\d[9]_8 ;
  wire e_22;
  wire e_23;
  wire emp_22;
  wire ful_21;
  wire ful_22;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[9]_8 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[9]_8 [17:16]}),
        .DO({DO,\d[10]_9 [15:0]}),
        .DOP({DOP,\d[10]_9 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_22),
        .FULL(ful_22),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_22),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_23),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__21 
       (.I0(emp_22),
        .I1(ful_21),
        .O(e_22));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_32
   (ful_21,
    \d[11]_10 ,
    e_21,
    wr_clk,
    rd_rst_i,
    e_22,
    \d[10]_9 ,
    ful_20);
  output ful_21;
  output [17:0]\d[11]_10 ;
  output e_21;
  input wr_clk;
  input rd_rst_i;
  input e_22;
  input [17:0]\d[10]_9 ;
  input ful_20;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[10]_9 ;
  wire [17:0]\d[11]_10 ;
  wire e_21;
  wire e_22;
  wire emp_21;
  wire ful_20;
  wire ful_21;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[10]_9 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[10]_9 [17:16]}),
        .DO({DO,\d[11]_10 [15:0]}),
        .DOP({DOP,\d[11]_10 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_21),
        .FULL(ful_21),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_21),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_22),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__20 
       (.I0(emp_21),
        .I1(ful_20),
        .O(e_21));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_33
   (ful_20,
    \d[12]_11 ,
    e_20,
    wr_clk,
    rd_rst_i,
    e_21,
    \d[11]_10 ,
    ful_19);
  output ful_20;
  output [17:0]\d[12]_11 ;
  output e_20;
  input wr_clk;
  input rd_rst_i;
  input e_21;
  input [17:0]\d[11]_10 ;
  input ful_19;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[11]_10 ;
  wire [17:0]\d[12]_11 ;
  wire e_20;
  wire e_21;
  wire emp_20;
  wire ful_19;
  wire ful_20;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[11]_10 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[11]_10 [17:16]}),
        .DO({DO,\d[12]_11 [15:0]}),
        .DOP({DOP,\d[12]_11 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_20),
        .FULL(ful_20),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_20),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_21),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__19 
       (.I0(emp_20),
        .I1(ful_19),
        .O(e_20));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_34
   (ful_19,
    \d[13]_12 ,
    e_19,
    wr_clk,
    rd_rst_i,
    e_20,
    \d[12]_11 ,
    ful_18);
  output ful_19;
  output [17:0]\d[13]_12 ;
  output e_19;
  input wr_clk;
  input rd_rst_i;
  input e_20;
  input [17:0]\d[12]_11 ;
  input ful_18;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[12]_11 ;
  wire [17:0]\d[13]_12 ;
  wire e_19;
  wire e_20;
  wire emp_19;
  wire ful_18;
  wire ful_19;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[12]_11 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[12]_11 [17:16]}),
        .DO({DO,\d[13]_12 [15:0]}),
        .DOP({DOP,\d[13]_12 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_19),
        .FULL(ful_19),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_19),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_20),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__18 
       (.I0(emp_19),
        .I1(ful_18),
        .O(e_19));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_35
   (ful_18,
    \d[14]_13 ,
    e_18,
    wr_clk,
    rd_rst_i,
    e_19,
    \d[13]_12 ,
    ful_17);
  output ful_18;
  output [17:0]\d[14]_13 ;
  output e_18;
  input wr_clk;
  input rd_rst_i;
  input e_19;
  input [17:0]\d[13]_12 ;
  input ful_17;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[13]_12 ;
  wire [17:0]\d[14]_13 ;
  wire e_18;
  wire e_19;
  wire emp_18;
  wire ful_17;
  wire ful_18;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[13]_12 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[13]_12 [17:16]}),
        .DO({DO,\d[14]_13 [15:0]}),
        .DOP({DOP,\d[14]_13 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_18),
        .FULL(ful_18),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_18),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_19),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__17 
       (.I0(emp_18),
        .I1(ful_17),
        .O(e_18));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_36
   (ful_17,
    \d[15]_14 ,
    e_17,
    wr_clk,
    rd_rst_i,
    e_18,
    \d[14]_13 ,
    ful_16);
  output ful_17;
  output [17:0]\d[15]_14 ;
  output e_17;
  input wr_clk;
  input rd_rst_i;
  input e_18;
  input [17:0]\d[14]_13 ;
  input ful_16;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[14]_13 ;
  wire [17:0]\d[15]_14 ;
  wire e_17;
  wire e_18;
  wire emp_17;
  wire ful_16;
  wire ful_17;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[14]_13 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[14]_13 [17:16]}),
        .DO({DO,\d[15]_14 [15:0]}),
        .DOP({DOP,\d[15]_14 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_17),
        .FULL(ful_17),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_17),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_18),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__16 
       (.I0(emp_17),
        .I1(ful_16),
        .O(e_17));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_37
   (ful_16,
    \d[16]_15 ,
    e_16,
    wr_clk,
    rd_rst_i,
    e_17,
    \d[15]_14 ,
    ful_15);
  output ful_16;
  output [17:0]\d[16]_15 ;
  output e_16;
  input wr_clk;
  input rd_rst_i;
  input e_17;
  input [17:0]\d[15]_14 ;
  input ful_15;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[15]_14 ;
  wire [17:0]\d[16]_15 ;
  wire e_16;
  wire e_17;
  wire emp_16;
  wire ful_15;
  wire ful_16;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[15]_14 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[15]_14 [17:16]}),
        .DO({DO,\d[16]_15 [15:0]}),
        .DOP({DOP,\d[16]_15 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_16),
        .FULL(ful_16),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_16),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_17),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__15 
       (.I0(emp_16),
        .I1(ful_15),
        .O(e_16));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_38
   (ful_15,
    \d[17]_16 ,
    e_15,
    wr_clk,
    rd_rst_i,
    e_16,
    \d[16]_15 ,
    ful_14);
  output ful_15;
  output [17:0]\d[17]_16 ;
  output e_15;
  input wr_clk;
  input rd_rst_i;
  input e_16;
  input [17:0]\d[16]_15 ;
  input ful_14;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[16]_15 ;
  wire [17:0]\d[17]_16 ;
  wire e_15;
  wire e_16;
  wire emp_15;
  wire ful_14;
  wire ful_15;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[16]_15 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[16]_15 [17:16]}),
        .DO({DO,\d[17]_16 [15:0]}),
        .DOP({DOP,\d[17]_16 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_15),
        .FULL(ful_15),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_15),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_16),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__14 
       (.I0(emp_15),
        .I1(ful_14),
        .O(e_15));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_39
   (ful_14,
    \d[18]_17 ,
    e_14,
    wr_clk,
    rd_rst_i,
    e_15,
    \d[17]_16 ,
    ful_13);
  output ful_14;
  output [17:0]\d[18]_17 ;
  output e_14;
  input wr_clk;
  input rd_rst_i;
  input e_15;
  input [17:0]\d[17]_16 ;
  input ful_13;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[17]_16 ;
  wire [17:0]\d[18]_17 ;
  wire e_14;
  wire e_15;
  wire emp_14;
  wire ful_13;
  wire ful_14;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[17]_16 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[17]_16 [17:16]}),
        .DO({DO,\d[18]_17 [15:0]}),
        .DOP({DOP,\d[18]_17 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_14),
        .FULL(ful_14),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_14),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_15),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__13 
       (.I0(emp_14),
        .I1(ful_13),
        .O(e_14));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_4
   (ful_18,
    \d[14]_44 ,
    e_18,
    wr_clk,
    rd_rst_i,
    e_19,
    \d[13]_43 ,
    ful_17);
  output ful_18;
  output [17:0]\d[14]_44 ;
  output e_18;
  input wr_clk;
  input rd_rst_i;
  input e_19;
  input [17:0]\d[13]_43 ;
  input ful_17;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[13]_43 ;
  wire [17:0]\d[14]_44 ;
  wire e_18;
  wire e_19;
  wire emp_18;
  wire ful_17;
  wire ful_18;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[13]_43 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[13]_43 [17:16]}),
        .DO({DO,\d[14]_44 [15:0]}),
        .DOP({DOP,\d[14]_44 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_18),
        .FULL(ful_18),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_18),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_19),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__47 
       (.I0(emp_18),
        .I1(ful_17),
        .O(e_18));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_40
   (ful_13,
    \d[19]_18 ,
    e_13,
    wr_clk,
    rd_rst_i,
    e_14,
    \d[18]_17 ,
    ful_12);
  output ful_13;
  output [17:0]\d[19]_18 ;
  output e_13;
  input wr_clk;
  input rd_rst_i;
  input e_14;
  input [17:0]\d[18]_17 ;
  input ful_12;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[18]_17 ;
  wire [17:0]\d[19]_18 ;
  wire e_13;
  wire e_14;
  wire emp_13;
  wire ful_12;
  wire ful_13;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[18]_17 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[18]_17 [17:16]}),
        .DO({DO,\d[19]_18 [15:0]}),
        .DOP({DOP,\d[19]_18 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_13),
        .FULL(ful_13),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_13),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_14),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__12 
       (.I0(emp_13),
        .I1(ful_12),
        .O(e_13));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_41
   (ful,
    \d[1]_0 ,
    e_31,
    full,
    wr_clk,
    rd_rst_i,
    wr_tmp,
    din,
    ful_30,
    full_0);
  output [0:0]ful;
  output [17:0]\d[1]_0 ;
  output e_31;
  output full;
  input wr_clk;
  input rd_rst_i;
  input wr_tmp;
  input [17:0]din;
  input ful_30;
  input [0:0]full_0;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[1]_0 ;
  wire [17:0]din;
  wire e_31;
  wire emp_31;
  wire [0:0]ful;
  wire ful_30;
  wire full;
  wire [0:0]full_0;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire [1:1]pf;
  wire rd_rst_i;
  wire wr_clk;
  wire wr_tmp;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  LUT2 #(
    .INIT(4'hE)) 
    full_INST_0
       (.I0(ful),
        .I1(full_0),
        .O(full));
  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(pf),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,din[15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,din[17:16]}),
        .DO({DO,\d[1]_0 [15:0]}),
        .DOP({DOP,\d[1]_0 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_31),
        .FULL(ful),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_31),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(wr_tmp),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__0 
       (.I0(emp_31),
        .I1(ful_30),
        .O(e_31));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_42
   (ful_12,
    \d[20]_19 ,
    e_12,
    wr_clk,
    rd_rst_i,
    e_13,
    \d[19]_18 ,
    ful_11);
  output ful_12;
  output [17:0]\d[20]_19 ;
  output e_12;
  input wr_clk;
  input rd_rst_i;
  input e_13;
  input [17:0]\d[19]_18 ;
  input ful_11;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[19]_18 ;
  wire [17:0]\d[20]_19 ;
  wire e_12;
  wire e_13;
  wire emp_12;
  wire ful_11;
  wire ful_12;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[19]_18 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[19]_18 [17:16]}),
        .DO({DO,\d[20]_19 [15:0]}),
        .DOP({DOP,\d[20]_19 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_12),
        .FULL(ful_12),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_12),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_13),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__11 
       (.I0(emp_12),
        .I1(ful_11),
        .O(e_12));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_43
   (ful_11,
    \d[21]_20 ,
    e_11,
    wr_clk,
    rd_rst_i,
    e_12,
    \d[20]_19 ,
    ful_10);
  output ful_11;
  output [17:0]\d[21]_20 ;
  output e_11;
  input wr_clk;
  input rd_rst_i;
  input e_12;
  input [17:0]\d[20]_19 ;
  input ful_10;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[20]_19 ;
  wire [17:0]\d[21]_20 ;
  wire e_11;
  wire e_12;
  wire emp_11;
  wire ful_10;
  wire ful_11;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[20]_19 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[20]_19 [17:16]}),
        .DO({DO,\d[21]_20 [15:0]}),
        .DOP({DOP,\d[21]_20 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_11),
        .FULL(ful_11),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_11),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_12),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__10 
       (.I0(emp_11),
        .I1(ful_10),
        .O(e_11));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_44
   (ful_10,
    \d[22]_21 ,
    e_10,
    wr_clk,
    rd_rst_i,
    e_11,
    \d[21]_20 ,
    ful_9);
  output ful_10;
  output [17:0]\d[22]_21 ;
  output e_10;
  input wr_clk;
  input rd_rst_i;
  input e_11;
  input [17:0]\d[21]_20 ;
  input ful_9;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[21]_20 ;
  wire [17:0]\d[22]_21 ;
  wire e_10;
  wire e_11;
  wire emp_10;
  wire ful_10;
  wire ful_9;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[21]_20 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[21]_20 [17:16]}),
        .DO({DO,\d[22]_21 [15:0]}),
        .DOP({DOP,\d[22]_21 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_10),
        .FULL(ful_10),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_10),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_11),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__9 
       (.I0(emp_10),
        .I1(ful_9),
        .O(e_10));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_45
   (ful_9,
    \d[23]_22 ,
    e_9,
    wr_clk,
    rd_rst_i,
    e_10,
    \d[22]_21 ,
    ful_8);
  output ful_9;
  output [17:0]\d[23]_22 ;
  output e_9;
  input wr_clk;
  input rd_rst_i;
  input e_10;
  input [17:0]\d[22]_21 ;
  input ful_8;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[22]_21 ;
  wire [17:0]\d[23]_22 ;
  wire e_10;
  wire e_9;
  wire emp_9;
  wire ful_8;
  wire ful_9;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[22]_21 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[22]_21 [17:16]}),
        .DO({DO,\d[23]_22 [15:0]}),
        .DOP({DOP,\d[23]_22 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_9),
        .FULL(ful_9),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_9),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_10),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__8 
       (.I0(emp_9),
        .I1(ful_8),
        .O(e_9));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_46
   (ful_8,
    \d[24]_23 ,
    e_8,
    wr_clk,
    rd_rst_i,
    e_9,
    \d[23]_22 ,
    ful_7);
  output ful_8;
  output [17:0]\d[24]_23 ;
  output e_8;
  input wr_clk;
  input rd_rst_i;
  input e_9;
  input [17:0]\d[23]_22 ;
  input ful_7;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[23]_22 ;
  wire [17:0]\d[24]_23 ;
  wire e_8;
  wire e_9;
  wire emp_8;
  wire ful_7;
  wire ful_8;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[23]_22 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[23]_22 [17:16]}),
        .DO({DO,\d[24]_23 [15:0]}),
        .DOP({DOP,\d[24]_23 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_8),
        .FULL(ful_8),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_8),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_9),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__7 
       (.I0(emp_8),
        .I1(ful_7),
        .O(e_8));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_47
   (ful_7,
    \d[25]_24 ,
    e_7,
    wr_clk,
    rd_rst_i,
    e_8,
    \d[24]_23 ,
    ful_6);
  output ful_7;
  output [17:0]\d[25]_24 ;
  output e_7;
  input wr_clk;
  input rd_rst_i;
  input e_8;
  input [17:0]\d[24]_23 ;
  input ful_6;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[24]_23 ;
  wire [17:0]\d[25]_24 ;
  wire e_7;
  wire e_8;
  wire emp_7;
  wire ful_6;
  wire ful_7;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[24]_23 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[24]_23 [17:16]}),
        .DO({DO,\d[25]_24 [15:0]}),
        .DOP({DOP,\d[25]_24 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_7),
        .FULL(ful_7),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_7),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_8),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__6 
       (.I0(emp_7),
        .I1(ful_6),
        .O(e_7));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_48
   (ful_6,
    \d[26]_25 ,
    e_6,
    wr_clk,
    rd_rst_i,
    e_7,
    \d[25]_24 ,
    ful_5);
  output ful_6;
  output [17:0]\d[26]_25 ;
  output e_6;
  input wr_clk;
  input rd_rst_i;
  input e_7;
  input [17:0]\d[25]_24 ;
  input ful_5;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[25]_24 ;
  wire [17:0]\d[26]_25 ;
  wire e_6;
  wire e_7;
  wire emp_6;
  wire ful_5;
  wire ful_6;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[25]_24 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[25]_24 [17:16]}),
        .DO({DO,\d[26]_25 [15:0]}),
        .DOP({DOP,\d[26]_25 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_6),
        .FULL(ful_6),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_6),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_7),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__5 
       (.I0(emp_6),
        .I1(ful_5),
        .O(e_6));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_49
   (ful_5,
    \d[27]_26 ,
    e_5,
    wr_clk,
    rd_rst_i,
    e_6,
    \d[26]_25 ,
    ful_4);
  output ful_5;
  output [17:0]\d[27]_26 ;
  output e_5;
  input wr_clk;
  input rd_rst_i;
  input e_6;
  input [17:0]\d[26]_25 ;
  input ful_4;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[26]_25 ;
  wire [17:0]\d[27]_26 ;
  wire e_5;
  wire e_6;
  wire emp_5;
  wire ful_4;
  wire ful_5;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[26]_25 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[26]_25 [17:16]}),
        .DO({DO,\d[27]_26 [15:0]}),
        .DOP({DOP,\d[27]_26 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_5),
        .FULL(ful_5),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_5),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_6),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__4 
       (.I0(emp_5),
        .I1(ful_4),
        .O(e_5));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_5
   (ful_17,
    \d[15]_45 ,
    e_17,
    wr_clk,
    rd_rst_i,
    e_18,
    \d[14]_44 ,
    ful_16);
  output ful_17;
  output [17:0]\d[15]_45 ;
  output e_17;
  input wr_clk;
  input rd_rst_i;
  input e_18;
  input [17:0]\d[14]_44 ;
  input ful_16;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[14]_44 ;
  wire [17:0]\d[15]_45 ;
  wire e_17;
  wire e_18;
  wire emp_17;
  wire ful_16;
  wire ful_17;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[14]_44 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[14]_44 [17:16]}),
        .DO({DO,\d[15]_45 [15:0]}),
        .DOP({DOP,\d[15]_45 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_17),
        .FULL(ful_17),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_17),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_18),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__46 
       (.I0(emp_17),
        .I1(ful_16),
        .O(e_17));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_50
   (ful_4,
    \d[28]_27 ,
    e_4,
    wr_clk,
    rd_rst_i,
    e_5,
    \d[27]_26 ,
    ful_3);
  output ful_4;
  output [17:0]\d[28]_27 ;
  output e_4;
  input wr_clk;
  input rd_rst_i;
  input e_5;
  input [17:0]\d[27]_26 ;
  input ful_3;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[27]_26 ;
  wire [17:0]\d[28]_27 ;
  wire e_4;
  wire e_5;
  wire emp_4;
  wire ful_3;
  wire ful_4;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[27]_26 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[27]_26 [17:16]}),
        .DO({DO,\d[28]_27 [15:0]}),
        .DOP({DOP,\d[28]_27 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_4),
        .FULL(ful_4),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_4),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_5),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__3 
       (.I0(emp_4),
        .I1(ful_3),
        .O(e_4));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_51
   (ful_3,
    \d[29]_28 ,
    e_3,
    wr_clk,
    rd_rst_i,
    e_4,
    \d[28]_27 ,
    ful_2);
  output ful_3;
  output [17:0]\d[29]_28 ;
  output e_3;
  input wr_clk;
  input rd_rst_i;
  input e_4;
  input [17:0]\d[28]_27 ;
  input ful_2;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[28]_27 ;
  wire [17:0]\d[29]_28 ;
  wire e_3;
  wire e_4;
  wire emp_3;
  wire ful_2;
  wire ful_3;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[28]_27 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[28]_27 [17:16]}),
        .DO({DO,\d[29]_28 [15:0]}),
        .DOP({DOP,\d[29]_28 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_3),
        .FULL(ful_3),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_3),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_4),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__2 
       (.I0(emp_3),
        .I1(ful_2),
        .O(e_3));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_52
   (ful_30,
    \d[2]_1 ,
    e_30,
    wr_clk,
    rd_rst_i,
    e_31,
    \d[1]_0 ,
    ful_29);
  output ful_30;
  output [17:0]\d[2]_1 ;
  output e_30;
  input wr_clk;
  input rd_rst_i;
  input e_31;
  input [17:0]\d[1]_0 ;
  input ful_29;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[1]_0 ;
  wire [17:0]\d[2]_1 ;
  wire e_30;
  wire e_31;
  wire emp_30;
  wire ful_29;
  wire ful_30;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[1]_0 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[1]_0 [17:16]}),
        .DO({DO,\d[2]_1 [15:0]}),
        .DOP({DOP,\d[2]_1 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_30),
        .FULL(ful_30),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_30),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_31),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__29 
       (.I0(emp_30),
        .I1(ful_29),
        .O(e_30));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_53
   (ful_2,
    \d[30]_29 ,
    e_2,
    wr_clk,
    rd_rst_i,
    e_3,
    \d[29]_28 ,
    ful_1);
  output ful_2;
  output [17:0]\d[30]_29 ;
  output e_2;
  input wr_clk;
  input rd_rst_i;
  input e_3;
  input [17:0]\d[29]_28 ;
  input ful_1;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[29]_28 ;
  wire [17:0]\d[30]_29 ;
  wire e_2;
  wire e_3;
  wire emp_2;
  wire ful_1;
  wire ful_2;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[29]_28 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[29]_28 [17:16]}),
        .DO({DO,\d[30]_29 [15:0]}),
        .DOP({DOP,\d[30]_29 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_2),
        .FULL(ful_2),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_2),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_3),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__1 
       (.I0(emp_2),
        .I1(ful_1),
        .O(e_2));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_54
   (ful_1,
    \d[31]_30 ,
    e_1,
    wr_clk,
    rd_rst_i,
    e_2,
    \d[30]_29 ,
    ful_0);
  output ful_1;
  output [17:0]\d[31]_30 ;
  output e_1;
  input wr_clk;
  input rd_rst_i;
  input e_2;
  input [17:0]\d[30]_29 ;
  input ful_0;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[30]_29 ;
  wire [17:0]\d[31]_30 ;
  wire e_1;
  wire e_2;
  wire emp_1;
  wire ful_0;
  wire ful_1;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[30]_29 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[30]_29 [17:16]}),
        .DO({DO,\d[31]_30 [15:0]}),
        .DOP({DOP,\d[31]_30 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_1),
        .FULL(ful_1),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_1),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_2),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1 
       (.I0(emp_1),
        .I1(ful_0),
        .O(e_1));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_56
   (ful_29,
    \d[3]_2 ,
    e_29,
    wr_clk,
    rd_rst_i,
    e_30,
    \d[2]_1 ,
    ful_28);
  output ful_29;
  output [17:0]\d[3]_2 ;
  output e_29;
  input wr_clk;
  input rd_rst_i;
  input e_30;
  input [17:0]\d[2]_1 ;
  input ful_28;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[2]_1 ;
  wire [17:0]\d[3]_2 ;
  wire e_29;
  wire e_30;
  wire emp_29;
  wire ful_28;
  wire ful_29;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[2]_1 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[2]_1 [17:16]}),
        .DO({DO,\d[3]_2 [15:0]}),
        .DOP({DOP,\d[3]_2 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_29),
        .FULL(ful_29),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_29),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_30),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__28 
       (.I0(emp_29),
        .I1(ful_28),
        .O(e_29));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_57
   (ful_28,
    \d[4]_3 ,
    e_28,
    wr_clk,
    rd_rst_i,
    e_29,
    \d[3]_2 ,
    ful_27);
  output ful_28;
  output [17:0]\d[4]_3 ;
  output e_28;
  input wr_clk;
  input rd_rst_i;
  input e_29;
  input [17:0]\d[3]_2 ;
  input ful_27;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[3]_2 ;
  wire [17:0]\d[4]_3 ;
  wire e_28;
  wire e_29;
  wire emp_28;
  wire ful_27;
  wire ful_28;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[3]_2 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[3]_2 [17:16]}),
        .DO({DO,\d[4]_3 [15:0]}),
        .DOP({DOP,\d[4]_3 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_28),
        .FULL(ful_28),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_28),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_29),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__27 
       (.I0(emp_28),
        .I1(ful_27),
        .O(e_28));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_58
   (ful_27,
    \d[5]_4 ,
    e_27,
    wr_clk,
    rd_rst_i,
    e_28,
    \d[4]_3 ,
    ful_26);
  output ful_27;
  output [17:0]\d[5]_4 ;
  output e_27;
  input wr_clk;
  input rd_rst_i;
  input e_28;
  input [17:0]\d[4]_3 ;
  input ful_26;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[4]_3 ;
  wire [17:0]\d[5]_4 ;
  wire e_27;
  wire e_28;
  wire emp_27;
  wire ful_26;
  wire ful_27;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[4]_3 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[4]_3 [17:16]}),
        .DO({DO,\d[5]_4 [15:0]}),
        .DOP({DOP,\d[5]_4 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_27),
        .FULL(ful_27),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_27),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_28),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__26 
       (.I0(emp_27),
        .I1(ful_26),
        .O(e_27));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_59
   (ful_26,
    \d[6]_5 ,
    e_26,
    wr_clk,
    rd_rst_i,
    e_27,
    \d[5]_4 ,
    ful_25);
  output ful_26;
  output [17:0]\d[6]_5 ;
  output e_26;
  input wr_clk;
  input rd_rst_i;
  input e_27;
  input [17:0]\d[5]_4 ;
  input ful_25;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[5]_4 ;
  wire [17:0]\d[6]_5 ;
  wire e_26;
  wire e_27;
  wire emp_26;
  wire ful_25;
  wire ful_26;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[5]_4 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[5]_4 [17:16]}),
        .DO({DO,\d[6]_5 [15:0]}),
        .DOP({DOP,\d[6]_5 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_26),
        .FULL(ful_26),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_26),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_27),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__25 
       (.I0(emp_26),
        .I1(ful_25),
        .O(e_26));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_6
   (ful_16,
    \d[16]_46 ,
    e_16,
    wr_clk,
    rd_rst_i,
    e_17,
    \d[15]_45 ,
    ful_15);
  output ful_16;
  output [17:0]\d[16]_46 ;
  output e_16;
  input wr_clk;
  input rd_rst_i;
  input e_17;
  input [17:0]\d[15]_45 ;
  input ful_15;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[15]_45 ;
  wire [17:0]\d[16]_46 ;
  wire e_16;
  wire e_17;
  wire emp_16;
  wire ful_15;
  wire ful_16;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[15]_45 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[15]_45 [17:16]}),
        .DO({DO,\d[16]_46 [15:0]}),
        .DOP({DOP,\d[16]_46 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_16),
        .FULL(ful_16),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_16),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_17),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__45 
       (.I0(emp_16),
        .I1(ful_15),
        .O(e_16));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_60
   (ful_25,
    \d[7]_6 ,
    e_25,
    wr_clk,
    rd_rst_i,
    e_26,
    \d[6]_5 ,
    ful_24);
  output ful_25;
  output [17:0]\d[7]_6 ;
  output e_25;
  input wr_clk;
  input rd_rst_i;
  input e_26;
  input [17:0]\d[6]_5 ;
  input ful_24;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[6]_5 ;
  wire [17:0]\d[7]_6 ;
  wire e_25;
  wire e_26;
  wire emp_25;
  wire ful_24;
  wire ful_25;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[6]_5 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[6]_5 [17:16]}),
        .DO({DO,\d[7]_6 [15:0]}),
        .DOP({DOP,\d[7]_6 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_25),
        .FULL(ful_25),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_25),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_26),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__24 
       (.I0(emp_25),
        .I1(ful_24),
        .O(e_25));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_61
   (ful_24,
    \d[8]_7 ,
    e_24,
    wr_clk,
    rd_rst_i,
    e_25,
    \d[7]_6 ,
    ful_23);
  output ful_24;
  output [17:0]\d[8]_7 ;
  output e_24;
  input wr_clk;
  input rd_rst_i;
  input e_25;
  input [17:0]\d[7]_6 ;
  input ful_23;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[7]_6 ;
  wire [17:0]\d[8]_7 ;
  wire e_24;
  wire e_25;
  wire emp_24;
  wire ful_23;
  wire ful_24;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[7]_6 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[7]_6 [17:16]}),
        .DO({DO,\d[8]_7 [15:0]}),
        .DOP({DOP,\d[8]_7 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_24),
        .FULL(ful_24),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_24),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_25),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__23 
       (.I0(emp_24),
        .I1(ful_23),
        .O(e_24));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_62
   (ful_23,
    \d[9]_8 ,
    e_23,
    wr_clk,
    rd_rst_i,
    e_24,
    \d[8]_7 ,
    ful_22);
  output ful_23;
  output [17:0]\d[9]_8 ;
  output e_23;
  input wr_clk;
  input rd_rst_i;
  input e_24;
  input [17:0]\d[8]_7 ;
  input ful_22;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[8]_7 ;
  wire [17:0]\d[9]_8 ;
  wire e_23;
  wire e_24;
  wire emp_23;
  wire ful_22;
  wire ful_23;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[8]_7 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[8]_7 [17:16]}),
        .DO({DO,\d[9]_8 [15:0]}),
        .DOP({DOP,\d[9]_8 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_23),
        .FULL(ful_23),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_23),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_24),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__22 
       (.I0(emp_23),
        .I1(ful_22),
        .O(e_23));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_7
   (ful_15,
    \d[17]_47 ,
    e_15,
    wr_clk,
    rd_rst_i,
    e_16,
    \d[16]_46 ,
    ful_14);
  output ful_15;
  output [17:0]\d[17]_47 ;
  output e_15;
  input wr_clk;
  input rd_rst_i;
  input e_16;
  input [17:0]\d[16]_46 ;
  input ful_14;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[16]_46 ;
  wire [17:0]\d[17]_47 ;
  wire e_15;
  wire e_16;
  wire emp_15;
  wire ful_14;
  wire ful_15;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[16]_46 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[16]_46 [17:16]}),
        .DO({DO,\d[17]_47 [15:0]}),
        .DOP({DOP,\d[17]_47 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_15),
        .FULL(ful_15),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_15),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_16),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__44 
       (.I0(emp_15),
        .I1(ful_14),
        .O(e_15));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_8
   (ful_14,
    \d[18]_48 ,
    e_14,
    wr_clk,
    rd_rst_i,
    e_15,
    \d[17]_47 ,
    ful_13);
  output ful_14;
  output [17:0]\d[18]_48 ;
  output e_14;
  input wr_clk;
  input rd_rst_i;
  input e_15;
  input [17:0]\d[17]_47 ;
  input ful_13;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[17]_47 ;
  wire [17:0]\d[18]_48 ;
  wire e_14;
  wire e_15;
  wire emp_14;
  wire ful_13;
  wire ful_14;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[17]_47 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[17]_47 [17:16]}),
        .DO({DO,\d[18]_48 [15:0]}),
        .DOP({DOP,\d[18]_48 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_14),
        .FULL(ful_14),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_14),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_15),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__43 
       (.I0(emp_14),
        .I1(ful_13),
        .O(e_14));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6_9
   (ful_13,
    \d[19]_49 ,
    e_13,
    wr_clk,
    rd_rst_i,
    e_14,
    \d[18]_48 ,
    ful_12);
  output ful_13;
  output [17:0]\d[19]_49 ;
  output e_13;
  input wr_clk;
  input rd_rst_i;
  input e_14;
  input [17:0]\d[18]_48 ;
  input ful_12;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[18]_48 ;
  wire [17:0]\d[19]_49 ;
  wire e_13;
  wire e_14;
  wire emp_13;
  wire ful_12;
  wire ful_13;
  wire \gf36e1_inst.sngfifo36e1_n_0 ;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_2 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_6 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire rd_rst_i;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h000A),
    .ALMOST_FULL_OFFSET(13'h000F),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(\gf36e1_inst.sngfifo36e1_n_0 ),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(\gf36e1_inst.sngfifo36e1_n_2 ),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[18]_48 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[18]_48 [17:16]}),
        .DO({DO,\d[19]_49 [15:0]}),
        .DOP({DOP,\d[19]_49 [17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp_13),
        .FULL(ful_13),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(wr_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(e_13),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(\gf36e1_inst.sngfifo36e1_n_6 ),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_14),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  LUT2 #(
    .INIT(4'h1)) 
    \gf36e1_inst.sngfifo36e1_i_1__42 
       (.I0(emp_13),
        .I1(ful_12),
        .O(e_13));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6__parameterized0
   (rd_clk_0,
    ful_0,
    dout,
    rd_en_0,
    underflow_int,
    rd_clk,
    rd_rst_i,
    wr_clk,
    e_1,
    \d[31]_61 ,
    rd_en,
    emp);
  output [0:0]rd_clk_0;
  output ful_0;
  output [17:0]dout;
  output rd_en_0;
  output underflow_int;
  input rd_clk;
  input rd_rst_i;
  input wr_clk;
  input e_1;
  input [17:0]\d[31]_61 ;
  input rd_en;
  input [0:0]emp;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[31]_61 ;
  wire [2:2]dbiterr_col;
  wire [17:0]dout;
  wire e_1;
  wire [0:0]emp;
  wire ful_0;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire [2:2]pe;
  wire rd_clk;
  wire [0:0]rd_clk_0;
  wire rd_en;
  wire rd_en_0;
  wire rd_rst_i;
  wire [2:2]sbiterr_col;
  wire underflow_int;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h0006),
    .ALMOST_FULL_OFFSET(13'h000A),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(pe),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(dbiterr_col),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[31]_61 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[31]_61 [17:16]}),
        .DO({DO,dout[15:0]}),
        .DOP({DOP,dout[17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(rd_clk_0),
        .FULL(ful_0),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(rd_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(rd_en_0),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(sbiterr_col),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_1),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT3 #(
    .INIT(8'h02)) 
    \gf36e1_inst.sngfifo36e1_i_1__60 
       (.I0(rd_en),
        .I1(rd_clk_0),
        .I2(emp),
        .O(rd_en_0));
  (* SOFT_HLUTNM = "soft_lutpair1" *) 
  LUT3 #(
    .INIT(8'hE0)) 
    \gunf.gunf2.UNDERFLOW_i_1 
       (.I0(rd_clk_0),
        .I1(emp),
        .I2(rd_en),
        .O(underflow_int));
endmodule

(* ORIG_REF_NAME = "builtin_prim_v6" *) 
module usb_slow_fifo_semipro_builtin_prim_v6__parameterized0_55
   (emp,
    ful_0,
    dout,
    empty,
    rd_clk,
    dout_15_sp_1,
    rd_rst_i,
    wr_clk,
    e_1,
    \d[31]_30 ,
    empty_0);
  output [0:0]emp;
  output ful_0;
  output [17:0]dout;
  output empty;
  input rd_clk;
  input dout_15_sp_1;
  input rd_rst_i;
  input wr_clk;
  input e_1;
  input [17:0]\d[31]_30 ;
  input [0:0]empty_0;

  wire [63:16]DO;
  wire [7:2]DOP;
  wire [12:11]RDCOUNT;
  wire [12:11]WRCOUNT;
  wire [17:0]\d[31]_30 ;
  wire [1:1]dbiterr_col;
  wire [17:0]dout;
  wire dout_15_sn_1;
  wire e_1;
  wire [0:0]emp;
  wire empty;
  wire [0:0]empty_0;
  wire ful_0;
  wire \gf36e1_inst.sngfifo36e1_n_1 ;
  wire \gf36e1_inst.sngfifo36e1_n_10 ;
  wire \gf36e1_inst.sngfifo36e1_n_11 ;
  wire \gf36e1_inst.sngfifo36e1_n_12 ;
  wire \gf36e1_inst.sngfifo36e1_n_13 ;
  wire \gf36e1_inst.sngfifo36e1_n_14 ;
  wire \gf36e1_inst.sngfifo36e1_n_15 ;
  wire \gf36e1_inst.sngfifo36e1_n_16 ;
  wire \gf36e1_inst.sngfifo36e1_n_17 ;
  wire \gf36e1_inst.sngfifo36e1_n_18 ;
  wire \gf36e1_inst.sngfifo36e1_n_19 ;
  wire \gf36e1_inst.sngfifo36e1_n_20 ;
  wire \gf36e1_inst.sngfifo36e1_n_23 ;
  wire \gf36e1_inst.sngfifo36e1_n_24 ;
  wire \gf36e1_inst.sngfifo36e1_n_25 ;
  wire \gf36e1_inst.sngfifo36e1_n_26 ;
  wire \gf36e1_inst.sngfifo36e1_n_27 ;
  wire \gf36e1_inst.sngfifo36e1_n_28 ;
  wire \gf36e1_inst.sngfifo36e1_n_29 ;
  wire \gf36e1_inst.sngfifo36e1_n_30 ;
  wire \gf36e1_inst.sngfifo36e1_n_31 ;
  wire \gf36e1_inst.sngfifo36e1_n_32 ;
  wire \gf36e1_inst.sngfifo36e1_n_33 ;
  wire \gf36e1_inst.sngfifo36e1_n_5 ;
  wire \gf36e1_inst.sngfifo36e1_n_7 ;
  wire [1:1]pe;
  wire rd_clk;
  wire rd_rst_i;
  wire [1:1]sbiterr_col;
  wire wr_clk;
  wire [7:0]\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED ;

  assign dout_15_sn_1 = dout_15_sp_1;
  LUT2 #(
    .INIT(4'hE)) 
    empty_INST_0
       (.I0(emp),
        .I1(empty_0),
        .O(empty));
  (* box_type = "PRIMITIVE" *) 
  FIFO36E1 #(
    .ALMOST_EMPTY_OFFSET(13'h0006),
    .ALMOST_FULL_OFFSET(13'h000A),
    .DATA_WIDTH(18),
    .DO_REG(1),
    .EN_ECC_READ("FALSE"),
    .EN_ECC_WRITE("FALSE"),
    .EN_SYN("FALSE"),
    .FIFO_MODE("FIFO36"),
    .FIRST_WORD_FALL_THROUGH("TRUE"),
    .INIT(72'h000000000000000000),
    .IS_RDCLK_INVERTED(1'b0),
    .IS_RDEN_INVERTED(1'b0),
    .IS_RSTREG_INVERTED(1'b0),
    .IS_RST_INVERTED(1'b0),
    .IS_WRCLK_INVERTED(1'b0),
    .IS_WREN_INVERTED(1'b0),
    .SIM_DEVICE("7SERIES"),
    .SRVAL(72'h000000000000000000)) 
    \gf36e1_inst.sngfifo36e1 
       (.ALMOSTEMPTY(pe),
        .ALMOSTFULL(\gf36e1_inst.sngfifo36e1_n_1 ),
        .DBITERR(dbiterr_col),
        .DI({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[31]_30 [15:0]}),
        .DIP({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,\d[31]_30 [17:16]}),
        .DO({DO,dout[15:0]}),
        .DOP({DOP,dout[17:16]}),
        .ECCPARITY(\NLW_gf36e1_inst.sngfifo36e1_ECCPARITY_UNCONNECTED [7:0]),
        .EMPTY(emp),
        .FULL(ful_0),
        .INJECTDBITERR(1'b0),
        .INJECTSBITERR(1'b0),
        .RDCLK(rd_clk),
        .RDCOUNT({RDCOUNT,\gf36e1_inst.sngfifo36e1_n_10 ,\gf36e1_inst.sngfifo36e1_n_11 ,\gf36e1_inst.sngfifo36e1_n_12 ,\gf36e1_inst.sngfifo36e1_n_13 ,\gf36e1_inst.sngfifo36e1_n_14 ,\gf36e1_inst.sngfifo36e1_n_15 ,\gf36e1_inst.sngfifo36e1_n_16 ,\gf36e1_inst.sngfifo36e1_n_17 ,\gf36e1_inst.sngfifo36e1_n_18 ,\gf36e1_inst.sngfifo36e1_n_19 ,\gf36e1_inst.sngfifo36e1_n_20 }),
        .RDEN(dout_15_sn_1),
        .RDERR(\gf36e1_inst.sngfifo36e1_n_5 ),
        .REGCE(1'b0),
        .RST(rd_rst_i),
        .RSTREG(1'b0),
        .SBITERR(sbiterr_col),
        .WRCLK(wr_clk),
        .WRCOUNT({WRCOUNT,\gf36e1_inst.sngfifo36e1_n_23 ,\gf36e1_inst.sngfifo36e1_n_24 ,\gf36e1_inst.sngfifo36e1_n_25 ,\gf36e1_inst.sngfifo36e1_n_26 ,\gf36e1_inst.sngfifo36e1_n_27 ,\gf36e1_inst.sngfifo36e1_n_28 ,\gf36e1_inst.sngfifo36e1_n_29 ,\gf36e1_inst.sngfifo36e1_n_30 ,\gf36e1_inst.sngfifo36e1_n_31 ,\gf36e1_inst.sngfifo36e1_n_32 ,\gf36e1_inst.sngfifo36e1_n_33 }),
        .WREN(e_1),
        .WRERR(\gf36e1_inst.sngfifo36e1_n_7 ));
endmodule

(* ORIG_REF_NAME = "builtin_top_v6" *) 
module usb_slow_fifo_semipro_builtin_top_v6
   (dout,
    overflow,
    underflow,
    full,
    empty,
    wr_clk,
    rd_rst_i,
    din,
    rd_clk,
    rd_en,
    wr_en);
  output [35:0]dout;
  output overflow;
  output underflow;
  output full;
  output empty;
  input wr_clk;
  input rd_rst_i;
  input [35:0]din;
  input rd_clk;
  input rd_en;
  input wr_en;

  wire [35:0]din;
  wire [35:0]dout;
  wire [2:1]emp;
  wire empty;
  wire [2:1]ful;
  wire full;
  wire \gextw[2].gnll_fifo.inst_extd_n_21 ;
  wire overflow;
  wire overflow_int;
  wire rd_clk;
  wire rd_en;
  wire rd_rst_i;
  wire underflow;
  wire underflow_int;
  wire wr_clk;
  wire wr_en;
  wire wr_tmp;

  usb_slow_fifo_semipro_builtin_extdepth_v6 \gextw[1].gnll_fifo.inst_extd 
       (.din(din[17:0]),
        .dout(dout[17:0]),
        .dout_15_sp_1(\gextw[2].gnll_fifo.inst_extd_n_21 ),
        .emp(emp[1]),
        .empty(empty),
        .empty_0(emp[2]),
        .ful(ful[1]),
        .full(full),
        .full_0(ful[2]),
        .rd_clk(rd_clk),
        .rd_rst_i(rd_rst_i),
        .wr_clk(wr_clk),
        .wr_tmp(wr_tmp));
  usb_slow_fifo_semipro_builtin_extdepth_v6_0 \gextw[2].gnll_fifo.inst_extd 
       (.din(din[35:18]),
        .dout(dout[35:18]),
        .emp(emp[1]),
        .ful(ful[1]),
        .overflow_int(overflow_int),
        .rd_clk(rd_clk),
        .rd_clk_0(emp[2]),
        .rd_en(rd_en),
        .rd_en_0(\gextw[2].gnll_fifo.inst_extd_n_21 ),
        .rd_rst_i(rd_rst_i),
        .underflow_int(underflow_int),
        .wr_clk(wr_clk),
        .wr_clk_0(ful[2]),
        .wr_en(wr_en),
        .wr_tmp(wr_tmp));
  FDRE #(
    .INIT(1'b0)) 
    \govw.govw2.OVERFLOW_reg 
       (.C(wr_clk),
        .CE(1'b1),
        .D(overflow_int),
        .Q(overflow),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \gunf.gunf2.UNDERFLOW_reg 
       (.C(rd_clk),
        .CE(1'b1),
        .D(underflow_int),
        .Q(underflow),
        .R(1'b0));
endmodule

(* ORIG_REF_NAME = "fifo_generator_top" *) 
module usb_slow_fifo_semipro_fifo_generator_top
   (dout,
    overflow,
    underflow,
    full,
    empty,
    rd_clk,
    rd_en,
    wr_clk,
    din,
    rst,
    wr_en);
  output [35:0]dout;
  output overflow;
  output underflow;
  output full;
  output empty;
  input rd_clk;
  input rd_en;
  input wr_clk;
  input [35:0]din;
  input rst;
  input wr_en;

  wire [35:0]din;
  wire [35:0]dout;
  wire empty;
  wire full;
  wire overflow;
  wire rd_clk;
  wire rd_en;
  wire rst;
  wire underflow;
  wire wr_clk;
  wire wr_en;

  usb_slow_fifo_semipro_fifo_generator_v13_2_5_builtin \gbi.bi 
       (.din(din),
        .dout(dout),
        .empty(empty),
        .full(full),
        .overflow(overflow),
        .rd_clk(rd_clk),
        .rd_en(rd_en),
        .rst(rst),
        .underflow(underflow),
        .wr_clk(wr_clk),
        .wr_en(wr_en));
endmodule

(* C_ADD_NGC_CONSTRAINT = "0" *) (* C_APPLICATION_TYPE_AXIS = "0" *) (* C_APPLICATION_TYPE_RACH = "0" *) 
(* C_APPLICATION_TYPE_RDCH = "0" *) (* C_APPLICATION_TYPE_WACH = "0" *) (* C_APPLICATION_TYPE_WDCH = "0" *) 
(* C_APPLICATION_TYPE_WRCH = "0" *) (* C_AXIS_TDATA_WIDTH = "8" *) (* C_AXIS_TDEST_WIDTH = "1" *) 
(* C_AXIS_TID_WIDTH = "1" *) (* C_AXIS_TKEEP_WIDTH = "1" *) (* C_AXIS_TSTRB_WIDTH = "1" *) 
(* C_AXIS_TUSER_WIDTH = "4" *) (* C_AXIS_TYPE = "0" *) (* C_AXI_ADDR_WIDTH = "32" *) 
(* C_AXI_ARUSER_WIDTH = "1" *) (* C_AXI_AWUSER_WIDTH = "1" *) (* C_AXI_BUSER_WIDTH = "1" *) 
(* C_AXI_DATA_WIDTH = "64" *) (* C_AXI_ID_WIDTH = "1" *) (* C_AXI_LEN_WIDTH = "8" *) 
(* C_AXI_LOCK_WIDTH = "1" *) (* C_AXI_RUSER_WIDTH = "1" *) (* C_AXI_TYPE = "1" *) 
(* C_AXI_WUSER_WIDTH = "1" *) (* C_COMMON_CLOCK = "0" *) (* C_COUNT_TYPE = "0" *) 
(* C_DATA_COUNT_WIDTH = "16" *) (* C_DEFAULT_VALUE = "BlankString" *) (* C_DIN_WIDTH = "36" *) 
(* C_DIN_WIDTH_AXIS = "1" *) (* C_DIN_WIDTH_RACH = "32" *) (* C_DIN_WIDTH_RDCH = "64" *) 
(* C_DIN_WIDTH_WACH = "1" *) (* C_DIN_WIDTH_WDCH = "64" *) (* C_DIN_WIDTH_WRCH = "2" *) 
(* C_DOUT_RST_VAL = "0" *) (* C_DOUT_WIDTH = "36" *) (* C_ENABLE_RLOCS = "0" *) 
(* C_ENABLE_RST_SYNC = "1" *) (* C_EN_SAFETY_CKT = "0" *) (* C_ERROR_INJECTION_TYPE = "0" *) 
(* C_ERROR_INJECTION_TYPE_AXIS = "0" *) (* C_ERROR_INJECTION_TYPE_RACH = "0" *) (* C_ERROR_INJECTION_TYPE_RDCH = "0" *) 
(* C_ERROR_INJECTION_TYPE_WACH = "0" *) (* C_ERROR_INJECTION_TYPE_WDCH = "0" *) (* C_ERROR_INJECTION_TYPE_WRCH = "0" *) 
(* C_FAMILY = "kintex7" *) (* C_FULL_FLAGS_RST_VAL = "0" *) (* C_HAS_ALMOST_EMPTY = "0" *) 
(* C_HAS_ALMOST_FULL = "0" *) (* C_HAS_AXIS_TDATA = "1" *) (* C_HAS_AXIS_TDEST = "0" *) 
(* C_HAS_AXIS_TID = "0" *) (* C_HAS_AXIS_TKEEP = "0" *) (* C_HAS_AXIS_TLAST = "0" *) 
(* C_HAS_AXIS_TREADY = "1" *) (* C_HAS_AXIS_TSTRB = "0" *) (* C_HAS_AXIS_TUSER = "1" *) 
(* C_HAS_AXI_ARUSER = "0" *) (* C_HAS_AXI_AWUSER = "0" *) (* C_HAS_AXI_BUSER = "0" *) 
(* C_HAS_AXI_ID = "0" *) (* C_HAS_AXI_RD_CHANNEL = "1" *) (* C_HAS_AXI_RUSER = "0" *) 
(* C_HAS_AXI_WR_CHANNEL = "1" *) (* C_HAS_AXI_WUSER = "0" *) (* C_HAS_BACKUP = "0" *) 
(* C_HAS_DATA_COUNT = "0" *) (* C_HAS_DATA_COUNTS_AXIS = "0" *) (* C_HAS_DATA_COUNTS_RACH = "0" *) 
(* C_HAS_DATA_COUNTS_RDCH = "0" *) (* C_HAS_DATA_COUNTS_WACH = "0" *) (* C_HAS_DATA_COUNTS_WDCH = "0" *) 
(* C_HAS_DATA_COUNTS_WRCH = "0" *) (* C_HAS_INT_CLK = "0" *) (* C_HAS_MASTER_CE = "0" *) 
(* C_HAS_MEMINIT_FILE = "0" *) (* C_HAS_OVERFLOW = "1" *) (* C_HAS_PROG_FLAGS_AXIS = "0" *) 
(* C_HAS_PROG_FLAGS_RACH = "0" *) (* C_HAS_PROG_FLAGS_RDCH = "0" *) (* C_HAS_PROG_FLAGS_WACH = "0" *) 
(* C_HAS_PROG_FLAGS_WDCH = "0" *) (* C_HAS_PROG_FLAGS_WRCH = "0" *) (* C_HAS_RD_DATA_COUNT = "0" *) 
(* C_HAS_RD_RST = "0" *) (* C_HAS_RST = "1" *) (* C_HAS_SLAVE_CE = "0" *) 
(* C_HAS_SRST = "0" *) (* C_HAS_UNDERFLOW = "1" *) (* C_HAS_VALID = "0" *) 
(* C_HAS_WR_ACK = "0" *) (* C_HAS_WR_DATA_COUNT = "0" *) (* C_HAS_WR_RST = "0" *) 
(* C_IMPLEMENTATION_TYPE = "6" *) (* C_IMPLEMENTATION_TYPE_AXIS = "1" *) (* C_IMPLEMENTATION_TYPE_RACH = "1" *) 
(* C_IMPLEMENTATION_TYPE_RDCH = "1" *) (* C_IMPLEMENTATION_TYPE_WACH = "1" *) (* C_IMPLEMENTATION_TYPE_WDCH = "1" *) 
(* C_IMPLEMENTATION_TYPE_WRCH = "1" *) (* C_INIT_WR_PNTR_VAL = "0" *) (* C_INTERFACE_TYPE = "0" *) 
(* C_MEMORY_TYPE = "4" *) (* C_MIF_FILE_NAME = "BlankString" *) (* C_MSGON_VAL = "1" *) 
(* C_OPTIMIZATION_MODE = "0" *) (* C_OVERFLOW_LOW = "0" *) (* C_POWER_SAVING_MODE = "0" *) 
(* C_PRELOAD_LATENCY = "0" *) (* C_PRELOAD_REGS = "1" *) (* C_PRIM_FIFO_TYPE = "2kx18" *) 
(* C_PRIM_FIFO_TYPE_AXIS = "1kx18" *) (* C_PRIM_FIFO_TYPE_RACH = "512x36" *) (* C_PRIM_FIFO_TYPE_RDCH = "1kx36" *) 
(* C_PRIM_FIFO_TYPE_WACH = "512x36" *) (* C_PRIM_FIFO_TYPE_WDCH = "1kx36" *) (* C_PRIM_FIFO_TYPE_WRCH = "512x36" *) 
(* C_PROG_EMPTY_THRESH_ASSERT_VAL = "6" *) (* C_PROG_EMPTY_THRESH_ASSERT_VAL_AXIS = "1022" *) (* C_PROG_EMPTY_THRESH_ASSERT_VAL_RACH = "1022" *) 
(* C_PROG_EMPTY_THRESH_ASSERT_VAL_RDCH = "1022" *) (* C_PROG_EMPTY_THRESH_ASSERT_VAL_WACH = "1022" *) (* C_PROG_EMPTY_THRESH_ASSERT_VAL_WDCH = "1022" *) 
(* C_PROG_EMPTY_THRESH_ASSERT_VAL_WRCH = "1022" *) (* C_PROG_EMPTY_THRESH_NEGATE_VAL = "7" *) (* C_PROG_EMPTY_TYPE = "0" *) 
(* C_PROG_EMPTY_TYPE_AXIS = "0" *) (* C_PROG_EMPTY_TYPE_RACH = "0" *) (* C_PROG_EMPTY_TYPE_RDCH = "0" *) 
(* C_PROG_EMPTY_TYPE_WACH = "0" *) (* C_PROG_EMPTY_TYPE_WDCH = "0" *) (* C_PROG_EMPTY_TYPE_WRCH = "0" *) 
(* C_PROG_FULL_THRESH_ASSERT_VAL = "65553" *) (* C_PROG_FULL_THRESH_ASSERT_VAL_AXIS = "1023" *) (* C_PROG_FULL_THRESH_ASSERT_VAL_RACH = "1023" *) 
(* C_PROG_FULL_THRESH_ASSERT_VAL_RDCH = "1023" *) (* C_PROG_FULL_THRESH_ASSERT_VAL_WACH = "1023" *) (* C_PROG_FULL_THRESH_ASSERT_VAL_WDCH = "1023" *) 
(* C_PROG_FULL_THRESH_ASSERT_VAL_WRCH = "1023" *) (* C_PROG_FULL_THRESH_NEGATE_VAL = "65552" *) (* C_PROG_FULL_TYPE = "0" *) 
(* C_PROG_FULL_TYPE_AXIS = "0" *) (* C_PROG_FULL_TYPE_RACH = "0" *) (* C_PROG_FULL_TYPE_RDCH = "0" *) 
(* C_PROG_FULL_TYPE_WACH = "0" *) (* C_PROG_FULL_TYPE_WDCH = "0" *) (* C_PROG_FULL_TYPE_WRCH = "0" *) 
(* C_RACH_TYPE = "0" *) (* C_RDCH_TYPE = "0" *) (* C_RD_DATA_COUNT_WIDTH = "16" *) 
(* C_RD_DEPTH = "65536" *) (* C_RD_FREQ = "96" *) (* C_RD_PNTR_WIDTH = "16" *) 
(* C_REG_SLICE_MODE_AXIS = "0" *) (* C_REG_SLICE_MODE_RACH = "0" *) (* C_REG_SLICE_MODE_RDCH = "0" *) 
(* C_REG_SLICE_MODE_WACH = "0" *) (* C_REG_SLICE_MODE_WDCH = "0" *) (* C_REG_SLICE_MODE_WRCH = "0" *) 
(* C_SELECT_XPM = "0" *) (* C_SYNCHRONIZER_STAGE = "2" *) (* C_UNDERFLOW_LOW = "0" *) 
(* C_USE_COMMON_OVERFLOW = "0" *) (* C_USE_COMMON_UNDERFLOW = "0" *) (* C_USE_DEFAULT_SETTINGS = "0" *) 
(* C_USE_DOUT_RST = "0" *) (* C_USE_ECC = "0" *) (* C_USE_ECC_AXIS = "0" *) 
(* C_USE_ECC_RACH = "0" *) (* C_USE_ECC_RDCH = "0" *) (* C_USE_ECC_WACH = "0" *) 
(* C_USE_ECC_WDCH = "0" *) (* C_USE_ECC_WRCH = "0" *) (* C_USE_EMBEDDED_REG = "0" *) 
(* C_USE_FIFO16_FLAGS = "0" *) (* C_USE_FWFT_DATA_COUNT = "0" *) (* C_USE_PIPELINE_REG = "0" *) 
(* C_VALID_LOW = "0" *) (* C_WACH_TYPE = "0" *) (* C_WDCH_TYPE = "0" *) 
(* C_WRCH_TYPE = "0" *) (* C_WR_ACK_LOW = "0" *) (* C_WR_DATA_COUNT_WIDTH = "16" *) 
(* C_WR_DEPTH = "65536" *) (* C_WR_DEPTH_AXIS = "1024" *) (* C_WR_DEPTH_RACH = "16" *) 
(* C_WR_DEPTH_RDCH = "1024" *) (* C_WR_DEPTH_WACH = "16" *) (* C_WR_DEPTH_WDCH = "1024" *) 
(* C_WR_DEPTH_WRCH = "16" *) (* C_WR_FREQ = "200" *) (* C_WR_PNTR_WIDTH = "16" *) 
(* C_WR_PNTR_WIDTH_AXIS = "10" *) (* C_WR_PNTR_WIDTH_RACH = "4" *) (* C_WR_PNTR_WIDTH_RDCH = "10" *) 
(* C_WR_PNTR_WIDTH_WACH = "4" *) (* C_WR_PNTR_WIDTH_WDCH = "10" *) (* C_WR_PNTR_WIDTH_WRCH = "4" *) 
(* C_WR_RESPONSE_LATENCY = "1" *) (* ORIG_REF_NAME = "fifo_generator_v13_2_5" *) 
module usb_slow_fifo_semipro_fifo_generator_v13_2_5
   (backup,
    backup_marker,
    clk,
    rst,
    srst,
    wr_clk,
    wr_rst,
    rd_clk,
    rd_rst,
    din,
    wr_en,
    rd_en,
    prog_empty_thresh,
    prog_empty_thresh_assert,
    prog_empty_thresh_negate,
    prog_full_thresh,
    prog_full_thresh_assert,
    prog_full_thresh_negate,
    int_clk,
    injectdbiterr,
    injectsbiterr,
    sleep,
    dout,
    full,
    almost_full,
    wr_ack,
    overflow,
    empty,
    almost_empty,
    valid,
    underflow,
    data_count,
    rd_data_count,
    wr_data_count,
    prog_full,
    prog_empty,
    sbiterr,
    dbiterr,
    wr_rst_busy,
    rd_rst_busy,
    m_aclk,
    s_aclk,
    s_aresetn,
    m_aclk_en,
    s_aclk_en,
    s_axi_awid,
    s_axi_awaddr,
    s_axi_awlen,
    s_axi_awsize,
    s_axi_awburst,
    s_axi_awlock,
    s_axi_awcache,
    s_axi_awprot,
    s_axi_awqos,
    s_axi_awregion,
    s_axi_awuser,
    s_axi_awvalid,
    s_axi_awready,
    s_axi_wid,
    s_axi_wdata,
    s_axi_wstrb,
    s_axi_wlast,
    s_axi_wuser,
    s_axi_wvalid,
    s_axi_wready,
    s_axi_bid,
    s_axi_bresp,
    s_axi_buser,
    s_axi_bvalid,
    s_axi_bready,
    m_axi_awid,
    m_axi_awaddr,
    m_axi_awlen,
    m_axi_awsize,
    m_axi_awburst,
    m_axi_awlock,
    m_axi_awcache,
    m_axi_awprot,
    m_axi_awqos,
    m_axi_awregion,
    m_axi_awuser,
    m_axi_awvalid,
    m_axi_awready,
    m_axi_wid,
    m_axi_wdata,
    m_axi_wstrb,
    m_axi_wlast,
    m_axi_wuser,
    m_axi_wvalid,
    m_axi_wready,
    m_axi_bid,
    m_axi_bresp,
    m_axi_buser,
    m_axi_bvalid,
    m_axi_bready,
    s_axi_arid,
    s_axi_araddr,
    s_axi_arlen,
    s_axi_arsize,
    s_axi_arburst,
    s_axi_arlock,
    s_axi_arcache,
    s_axi_arprot,
    s_axi_arqos,
    s_axi_arregion,
    s_axi_aruser,
    s_axi_arvalid,
    s_axi_arready,
    s_axi_rid,
    s_axi_rdata,
    s_axi_rresp,
    s_axi_rlast,
    s_axi_ruser,
    s_axi_rvalid,
    s_axi_rready,
    m_axi_arid,
    m_axi_araddr,
    m_axi_arlen,
    m_axi_arsize,
    m_axi_arburst,
    m_axi_arlock,
    m_axi_arcache,
    m_axi_arprot,
    m_axi_arqos,
    m_axi_arregion,
    m_axi_aruser,
    m_axi_arvalid,
    m_axi_arready,
    m_axi_rid,
    m_axi_rdata,
    m_axi_rresp,
    m_axi_rlast,
    m_axi_ruser,
    m_axi_rvalid,
    m_axi_rready,
    s_axis_tvalid,
    s_axis_tready,
    s_axis_tdata,
    s_axis_tstrb,
    s_axis_tkeep,
    s_axis_tlast,
    s_axis_tid,
    s_axis_tdest,
    s_axis_tuser,
    m_axis_tvalid,
    m_axis_tready,
    m_axis_tdata,
    m_axis_tstrb,
    m_axis_tkeep,
    m_axis_tlast,
    m_axis_tid,
    m_axis_tdest,
    m_axis_tuser,
    axi_aw_injectsbiterr,
    axi_aw_injectdbiterr,
    axi_aw_prog_full_thresh,
    axi_aw_prog_empty_thresh,
    axi_aw_data_count,
    axi_aw_wr_data_count,
    axi_aw_rd_data_count,
    axi_aw_sbiterr,
    axi_aw_dbiterr,
    axi_aw_overflow,
    axi_aw_underflow,
    axi_aw_prog_full,
    axi_aw_prog_empty,
    axi_w_injectsbiterr,
    axi_w_injectdbiterr,
    axi_w_prog_full_thresh,
    axi_w_prog_empty_thresh,
    axi_w_data_count,
    axi_w_wr_data_count,
    axi_w_rd_data_count,
    axi_w_sbiterr,
    axi_w_dbiterr,
    axi_w_overflow,
    axi_w_underflow,
    axi_w_prog_full,
    axi_w_prog_empty,
    axi_b_injectsbiterr,
    axi_b_injectdbiterr,
    axi_b_prog_full_thresh,
    axi_b_prog_empty_thresh,
    axi_b_data_count,
    axi_b_wr_data_count,
    axi_b_rd_data_count,
    axi_b_sbiterr,
    axi_b_dbiterr,
    axi_b_overflow,
    axi_b_underflow,
    axi_b_prog_full,
    axi_b_prog_empty,
    axi_ar_injectsbiterr,
    axi_ar_injectdbiterr,
    axi_ar_prog_full_thresh,
    axi_ar_prog_empty_thresh,
    axi_ar_data_count,
    axi_ar_wr_data_count,
    axi_ar_rd_data_count,
    axi_ar_sbiterr,
    axi_ar_dbiterr,
    axi_ar_overflow,
    axi_ar_underflow,
    axi_ar_prog_full,
    axi_ar_prog_empty,
    axi_r_injectsbiterr,
    axi_r_injectdbiterr,
    axi_r_prog_full_thresh,
    axi_r_prog_empty_thresh,
    axi_r_data_count,
    axi_r_wr_data_count,
    axi_r_rd_data_count,
    axi_r_sbiterr,
    axi_r_dbiterr,
    axi_r_overflow,
    axi_r_underflow,
    axi_r_prog_full,
    axi_r_prog_empty,
    axis_injectsbiterr,
    axis_injectdbiterr,
    axis_prog_full_thresh,
    axis_prog_empty_thresh,
    axis_data_count,
    axis_wr_data_count,
    axis_rd_data_count,
    axis_sbiterr,
    axis_dbiterr,
    axis_overflow,
    axis_underflow,
    axis_prog_full,
    axis_prog_empty);
  input backup;
  input backup_marker;
  input clk;
  input rst;
  input srst;
  input wr_clk;
  input wr_rst;
  input rd_clk;
  input rd_rst;
  input [35:0]din;
  input wr_en;
  input rd_en;
  input [15:0]prog_empty_thresh;
  input [15:0]prog_empty_thresh_assert;
  input [15:0]prog_empty_thresh_negate;
  input [15:0]prog_full_thresh;
  input [15:0]prog_full_thresh_assert;
  input [15:0]prog_full_thresh_negate;
  input int_clk;
  input injectdbiterr;
  input injectsbiterr;
  input sleep;
  output [35:0]dout;
  output full;
  output almost_full;
  output wr_ack;
  output overflow;
  output empty;
  output almost_empty;
  output valid;
  output underflow;
  output [15:0]data_count;
  output [15:0]rd_data_count;
  output [15:0]wr_data_count;
  output prog_full;
  output prog_empty;
  output sbiterr;
  output dbiterr;
  output wr_rst_busy;
  output rd_rst_busy;
  input m_aclk;
  input s_aclk;
  input s_aresetn;
  input m_aclk_en;
  input s_aclk_en;
  input [0:0]s_axi_awid;
  input [31:0]s_axi_awaddr;
  input [7:0]s_axi_awlen;
  input [2:0]s_axi_awsize;
  input [1:0]s_axi_awburst;
  input [0:0]s_axi_awlock;
  input [3:0]s_axi_awcache;
  input [2:0]s_axi_awprot;
  input [3:0]s_axi_awqos;
  input [3:0]s_axi_awregion;
  input [0:0]s_axi_awuser;
  input s_axi_awvalid;
  output s_axi_awready;
  input [0:0]s_axi_wid;
  input [63:0]s_axi_wdata;
  input [7:0]s_axi_wstrb;
  input s_axi_wlast;
  input [0:0]s_axi_wuser;
  input s_axi_wvalid;
  output s_axi_wready;
  output [0:0]s_axi_bid;
  output [1:0]s_axi_bresp;
  output [0:0]s_axi_buser;
  output s_axi_bvalid;
  input s_axi_bready;
  output [0:0]m_axi_awid;
  output [31:0]m_axi_awaddr;
  output [7:0]m_axi_awlen;
  output [2:0]m_axi_awsize;
  output [1:0]m_axi_awburst;
  output [0:0]m_axi_awlock;
  output [3:0]m_axi_awcache;
  output [2:0]m_axi_awprot;
  output [3:0]m_axi_awqos;
  output [3:0]m_axi_awregion;
  output [0:0]m_axi_awuser;
  output m_axi_awvalid;
  input m_axi_awready;
  output [0:0]m_axi_wid;
  output [63:0]m_axi_wdata;
  output [7:0]m_axi_wstrb;
  output m_axi_wlast;
  output [0:0]m_axi_wuser;
  output m_axi_wvalid;
  input m_axi_wready;
  input [0:0]m_axi_bid;
  input [1:0]m_axi_bresp;
  input [0:0]m_axi_buser;
  input m_axi_bvalid;
  output m_axi_bready;
  input [0:0]s_axi_arid;
  input [31:0]s_axi_araddr;
  input [7:0]s_axi_arlen;
  input [2:0]s_axi_arsize;
  input [1:0]s_axi_arburst;
  input [0:0]s_axi_arlock;
  input [3:0]s_axi_arcache;
  input [2:0]s_axi_arprot;
  input [3:0]s_axi_arqos;
  input [3:0]s_axi_arregion;
  input [0:0]s_axi_aruser;
  input s_axi_arvalid;
  output s_axi_arready;
  output [0:0]s_axi_rid;
  output [63:0]s_axi_rdata;
  output [1:0]s_axi_rresp;
  output s_axi_rlast;
  output [0:0]s_axi_ruser;
  output s_axi_rvalid;
  input s_axi_rready;
  output [0:0]m_axi_arid;
  output [31:0]m_axi_araddr;
  output [7:0]m_axi_arlen;
  output [2:0]m_axi_arsize;
  output [1:0]m_axi_arburst;
  output [0:0]m_axi_arlock;
  output [3:0]m_axi_arcache;
  output [2:0]m_axi_arprot;
  output [3:0]m_axi_arqos;
  output [3:0]m_axi_arregion;
  output [0:0]m_axi_aruser;
  output m_axi_arvalid;
  input m_axi_arready;
  input [0:0]m_axi_rid;
  input [63:0]m_axi_rdata;
  input [1:0]m_axi_rresp;
  input m_axi_rlast;
  input [0:0]m_axi_ruser;
  input m_axi_rvalid;
  output m_axi_rready;
  input s_axis_tvalid;
  output s_axis_tready;
  input [7:0]s_axis_tdata;
  input [0:0]s_axis_tstrb;
  input [0:0]s_axis_tkeep;
  input s_axis_tlast;
  input [0:0]s_axis_tid;
  input [0:0]s_axis_tdest;
  input [3:0]s_axis_tuser;
  output m_axis_tvalid;
  input m_axis_tready;
  output [7:0]m_axis_tdata;
  output [0:0]m_axis_tstrb;
  output [0:0]m_axis_tkeep;
  output m_axis_tlast;
  output [0:0]m_axis_tid;
  output [0:0]m_axis_tdest;
  output [3:0]m_axis_tuser;
  input axi_aw_injectsbiterr;
  input axi_aw_injectdbiterr;
  input [3:0]axi_aw_prog_full_thresh;
  input [3:0]axi_aw_prog_empty_thresh;
  output [4:0]axi_aw_data_count;
  output [4:0]axi_aw_wr_data_count;
  output [4:0]axi_aw_rd_data_count;
  output axi_aw_sbiterr;
  output axi_aw_dbiterr;
  output axi_aw_overflow;
  output axi_aw_underflow;
  output axi_aw_prog_full;
  output axi_aw_prog_empty;
  input axi_w_injectsbiterr;
  input axi_w_injectdbiterr;
  input [9:0]axi_w_prog_full_thresh;
  input [9:0]axi_w_prog_empty_thresh;
  output [10:0]axi_w_data_count;
  output [10:0]axi_w_wr_data_count;
  output [10:0]axi_w_rd_data_count;
  output axi_w_sbiterr;
  output axi_w_dbiterr;
  output axi_w_overflow;
  output axi_w_underflow;
  output axi_w_prog_full;
  output axi_w_prog_empty;
  input axi_b_injectsbiterr;
  input axi_b_injectdbiterr;
  input [3:0]axi_b_prog_full_thresh;
  input [3:0]axi_b_prog_empty_thresh;
  output [4:0]axi_b_data_count;
  output [4:0]axi_b_wr_data_count;
  output [4:0]axi_b_rd_data_count;
  output axi_b_sbiterr;
  output axi_b_dbiterr;
  output axi_b_overflow;
  output axi_b_underflow;
  output axi_b_prog_full;
  output axi_b_prog_empty;
  input axi_ar_injectsbiterr;
  input axi_ar_injectdbiterr;
  input [3:0]axi_ar_prog_full_thresh;
  input [3:0]axi_ar_prog_empty_thresh;
  output [4:0]axi_ar_data_count;
  output [4:0]axi_ar_wr_data_count;
  output [4:0]axi_ar_rd_data_count;
  output axi_ar_sbiterr;
  output axi_ar_dbiterr;
  output axi_ar_overflow;
  output axi_ar_underflow;
  output axi_ar_prog_full;
  output axi_ar_prog_empty;
  input axi_r_injectsbiterr;
  input axi_r_injectdbiterr;
  input [9:0]axi_r_prog_full_thresh;
  input [9:0]axi_r_prog_empty_thresh;
  output [10:0]axi_r_data_count;
  output [10:0]axi_r_wr_data_count;
  output [10:0]axi_r_rd_data_count;
  output axi_r_sbiterr;
  output axi_r_dbiterr;
  output axi_r_overflow;
  output axi_r_underflow;
  output axi_r_prog_full;
  output axi_r_prog_empty;
  input axis_injectsbiterr;
  input axis_injectdbiterr;
  input [9:0]axis_prog_full_thresh;
  input [9:0]axis_prog_empty_thresh;
  output [10:0]axis_data_count;
  output [10:0]axis_wr_data_count;
  output [10:0]axis_rd_data_count;
  output axis_sbiterr;
  output axis_dbiterr;
  output axis_overflow;
  output axis_underflow;
  output axis_prog_full;
  output axis_prog_empty;

  wire \<const0> ;
  wire \<const1> ;
  wire [35:0]din;
  wire [35:0]dout;
  wire empty;
  wire full;
  wire overflow;
  wire rd_clk;
  wire rd_en;
  wire rst;
  wire underflow;
  wire wr_clk;
  wire wr_en;

  assign almost_empty = \<const0> ;
  assign almost_full = \<const0> ;
  assign axi_ar_data_count[4] = \<const0> ;
  assign axi_ar_data_count[3] = \<const0> ;
  assign axi_ar_data_count[2] = \<const0> ;
  assign axi_ar_data_count[1] = \<const0> ;
  assign axi_ar_data_count[0] = \<const0> ;
  assign axi_ar_dbiterr = \<const0> ;
  assign axi_ar_overflow = \<const0> ;
  assign axi_ar_prog_empty = \<const1> ;
  assign axi_ar_prog_full = \<const0> ;
  assign axi_ar_rd_data_count[4] = \<const0> ;
  assign axi_ar_rd_data_count[3] = \<const0> ;
  assign axi_ar_rd_data_count[2] = \<const0> ;
  assign axi_ar_rd_data_count[1] = \<const0> ;
  assign axi_ar_rd_data_count[0] = \<const0> ;
  assign axi_ar_sbiterr = \<const0> ;
  assign axi_ar_underflow = \<const0> ;
  assign axi_ar_wr_data_count[4] = \<const0> ;
  assign axi_ar_wr_data_count[3] = \<const0> ;
  assign axi_ar_wr_data_count[2] = \<const0> ;
  assign axi_ar_wr_data_count[1] = \<const0> ;
  assign axi_ar_wr_data_count[0] = \<const0> ;
  assign axi_aw_data_count[4] = \<const0> ;
  assign axi_aw_data_count[3] = \<const0> ;
  assign axi_aw_data_count[2] = \<const0> ;
  assign axi_aw_data_count[1] = \<const0> ;
  assign axi_aw_data_count[0] = \<const0> ;
  assign axi_aw_dbiterr = \<const0> ;
  assign axi_aw_overflow = \<const0> ;
  assign axi_aw_prog_empty = \<const1> ;
  assign axi_aw_prog_full = \<const0> ;
  assign axi_aw_rd_data_count[4] = \<const0> ;
  assign axi_aw_rd_data_count[3] = \<const0> ;
  assign axi_aw_rd_data_count[2] = \<const0> ;
  assign axi_aw_rd_data_count[1] = \<const0> ;
  assign axi_aw_rd_data_count[0] = \<const0> ;
  assign axi_aw_sbiterr = \<const0> ;
  assign axi_aw_underflow = \<const0> ;
  assign axi_aw_wr_data_count[4] = \<const0> ;
  assign axi_aw_wr_data_count[3] = \<const0> ;
  assign axi_aw_wr_data_count[2] = \<const0> ;
  assign axi_aw_wr_data_count[1] = \<const0> ;
  assign axi_aw_wr_data_count[0] = \<const0> ;
  assign axi_b_data_count[4] = \<const0> ;
  assign axi_b_data_count[3] = \<const0> ;
  assign axi_b_data_count[2] = \<const0> ;
  assign axi_b_data_count[1] = \<const0> ;
  assign axi_b_data_count[0] = \<const0> ;
  assign axi_b_dbiterr = \<const0> ;
  assign axi_b_overflow = \<const0> ;
  assign axi_b_prog_empty = \<const1> ;
  assign axi_b_prog_full = \<const0> ;
  assign axi_b_rd_data_count[4] = \<const0> ;
  assign axi_b_rd_data_count[3] = \<const0> ;
  assign axi_b_rd_data_count[2] = \<const0> ;
  assign axi_b_rd_data_count[1] = \<const0> ;
  assign axi_b_rd_data_count[0] = \<const0> ;
  assign axi_b_sbiterr = \<const0> ;
  assign axi_b_underflow = \<const0> ;
  assign axi_b_wr_data_count[4] = \<const0> ;
  assign axi_b_wr_data_count[3] = \<const0> ;
  assign axi_b_wr_data_count[2] = \<const0> ;
  assign axi_b_wr_data_count[1] = \<const0> ;
  assign axi_b_wr_data_count[0] = \<const0> ;
  assign axi_r_data_count[10] = \<const0> ;
  assign axi_r_data_count[9] = \<const0> ;
  assign axi_r_data_count[8] = \<const0> ;
  assign axi_r_data_count[7] = \<const0> ;
  assign axi_r_data_count[6] = \<const0> ;
  assign axi_r_data_count[5] = \<const0> ;
  assign axi_r_data_count[4] = \<const0> ;
  assign axi_r_data_count[3] = \<const0> ;
  assign axi_r_data_count[2] = \<const0> ;
  assign axi_r_data_count[1] = \<const0> ;
  assign axi_r_data_count[0] = \<const0> ;
  assign axi_r_dbiterr = \<const0> ;
  assign axi_r_overflow = \<const0> ;
  assign axi_r_prog_empty = \<const1> ;
  assign axi_r_prog_full = \<const0> ;
  assign axi_r_rd_data_count[10] = \<const0> ;
  assign axi_r_rd_data_count[9] = \<const0> ;
  assign axi_r_rd_data_count[8] = \<const0> ;
  assign axi_r_rd_data_count[7] = \<const0> ;
  assign axi_r_rd_data_count[6] = \<const0> ;
  assign axi_r_rd_data_count[5] = \<const0> ;
  assign axi_r_rd_data_count[4] = \<const0> ;
  assign axi_r_rd_data_count[3] = \<const0> ;
  assign axi_r_rd_data_count[2] = \<const0> ;
  assign axi_r_rd_data_count[1] = \<const0> ;
  assign axi_r_rd_data_count[0] = \<const0> ;
  assign axi_r_sbiterr = \<const0> ;
  assign axi_r_underflow = \<const0> ;
  assign axi_r_wr_data_count[10] = \<const0> ;
  assign axi_r_wr_data_count[9] = \<const0> ;
  assign axi_r_wr_data_count[8] = \<const0> ;
  assign axi_r_wr_data_count[7] = \<const0> ;
  assign axi_r_wr_data_count[6] = \<const0> ;
  assign axi_r_wr_data_count[5] = \<const0> ;
  assign axi_r_wr_data_count[4] = \<const0> ;
  assign axi_r_wr_data_count[3] = \<const0> ;
  assign axi_r_wr_data_count[2] = \<const0> ;
  assign axi_r_wr_data_count[1] = \<const0> ;
  assign axi_r_wr_data_count[0] = \<const0> ;
  assign axi_w_data_count[10] = \<const0> ;
  assign axi_w_data_count[9] = \<const0> ;
  assign axi_w_data_count[8] = \<const0> ;
  assign axi_w_data_count[7] = \<const0> ;
  assign axi_w_data_count[6] = \<const0> ;
  assign axi_w_data_count[5] = \<const0> ;
  assign axi_w_data_count[4] = \<const0> ;
  assign axi_w_data_count[3] = \<const0> ;
  assign axi_w_data_count[2] = \<const0> ;
  assign axi_w_data_count[1] = \<const0> ;
  assign axi_w_data_count[0] = \<const0> ;
  assign axi_w_dbiterr = \<const0> ;
  assign axi_w_overflow = \<const0> ;
  assign axi_w_prog_empty = \<const1> ;
  assign axi_w_prog_full = \<const0> ;
  assign axi_w_rd_data_count[10] = \<const0> ;
  assign axi_w_rd_data_count[9] = \<const0> ;
  assign axi_w_rd_data_count[8] = \<const0> ;
  assign axi_w_rd_data_count[7] = \<const0> ;
  assign axi_w_rd_data_count[6] = \<const0> ;
  assign axi_w_rd_data_count[5] = \<const0> ;
  assign axi_w_rd_data_count[4] = \<const0> ;
  assign axi_w_rd_data_count[3] = \<const0> ;
  assign axi_w_rd_data_count[2] = \<const0> ;
  assign axi_w_rd_data_count[1] = \<const0> ;
  assign axi_w_rd_data_count[0] = \<const0> ;
  assign axi_w_sbiterr = \<const0> ;
  assign axi_w_underflow = \<const0> ;
  assign axi_w_wr_data_count[10] = \<const0> ;
  assign axi_w_wr_data_count[9] = \<const0> ;
  assign axi_w_wr_data_count[8] = \<const0> ;
  assign axi_w_wr_data_count[7] = \<const0> ;
  assign axi_w_wr_data_count[6] = \<const0> ;
  assign axi_w_wr_data_count[5] = \<const0> ;
  assign axi_w_wr_data_count[4] = \<const0> ;
  assign axi_w_wr_data_count[3] = \<const0> ;
  assign axi_w_wr_data_count[2] = \<const0> ;
  assign axi_w_wr_data_count[1] = \<const0> ;
  assign axi_w_wr_data_count[0] = \<const0> ;
  assign axis_data_count[10] = \<const0> ;
  assign axis_data_count[9] = \<const0> ;
  assign axis_data_count[8] = \<const0> ;
  assign axis_data_count[7] = \<const0> ;
  assign axis_data_count[6] = \<const0> ;
  assign axis_data_count[5] = \<const0> ;
  assign axis_data_count[4] = \<const0> ;
  assign axis_data_count[3] = \<const0> ;
  assign axis_data_count[2] = \<const0> ;
  assign axis_data_count[1] = \<const0> ;
  assign axis_data_count[0] = \<const0> ;
  assign axis_dbiterr = \<const0> ;
  assign axis_overflow = \<const0> ;
  assign axis_prog_empty = \<const1> ;
  assign axis_prog_full = \<const0> ;
  assign axis_rd_data_count[10] = \<const0> ;
  assign axis_rd_data_count[9] = \<const0> ;
  assign axis_rd_data_count[8] = \<const0> ;
  assign axis_rd_data_count[7] = \<const0> ;
  assign axis_rd_data_count[6] = \<const0> ;
  assign axis_rd_data_count[5] = \<const0> ;
  assign axis_rd_data_count[4] = \<const0> ;
  assign axis_rd_data_count[3] = \<const0> ;
  assign axis_rd_data_count[2] = \<const0> ;
  assign axis_rd_data_count[1] = \<const0> ;
  assign axis_rd_data_count[0] = \<const0> ;
  assign axis_sbiterr = \<const0> ;
  assign axis_underflow = \<const0> ;
  assign axis_wr_data_count[10] = \<const0> ;
  assign axis_wr_data_count[9] = \<const0> ;
  assign axis_wr_data_count[8] = \<const0> ;
  assign axis_wr_data_count[7] = \<const0> ;
  assign axis_wr_data_count[6] = \<const0> ;
  assign axis_wr_data_count[5] = \<const0> ;
  assign axis_wr_data_count[4] = \<const0> ;
  assign axis_wr_data_count[3] = \<const0> ;
  assign axis_wr_data_count[2] = \<const0> ;
  assign axis_wr_data_count[1] = \<const0> ;
  assign axis_wr_data_count[0] = \<const0> ;
  assign data_count[15] = \<const0> ;
  assign data_count[14] = \<const0> ;
  assign data_count[13] = \<const0> ;
  assign data_count[12] = \<const0> ;
  assign data_count[11] = \<const0> ;
  assign data_count[10] = \<const0> ;
  assign data_count[9] = \<const0> ;
  assign data_count[8] = \<const0> ;
  assign data_count[7] = \<const0> ;
  assign data_count[6] = \<const0> ;
  assign data_count[5] = \<const0> ;
  assign data_count[4] = \<const0> ;
  assign data_count[3] = \<const0> ;
  assign data_count[2] = \<const0> ;
  assign data_count[1] = \<const0> ;
  assign data_count[0] = \<const0> ;
  assign dbiterr = \<const0> ;
  assign m_axi_araddr[31] = \<const0> ;
  assign m_axi_araddr[30] = \<const0> ;
  assign m_axi_araddr[29] = \<const0> ;
  assign m_axi_araddr[28] = \<const0> ;
  assign m_axi_araddr[27] = \<const0> ;
  assign m_axi_araddr[26] = \<const0> ;
  assign m_axi_araddr[25] = \<const0> ;
  assign m_axi_araddr[24] = \<const0> ;
  assign m_axi_araddr[23] = \<const0> ;
  assign m_axi_araddr[22] = \<const0> ;
  assign m_axi_araddr[21] = \<const0> ;
  assign m_axi_araddr[20] = \<const0> ;
  assign m_axi_araddr[19] = \<const0> ;
  assign m_axi_araddr[18] = \<const0> ;
  assign m_axi_araddr[17] = \<const0> ;
  assign m_axi_araddr[16] = \<const0> ;
  assign m_axi_araddr[15] = \<const0> ;
  assign m_axi_araddr[14] = \<const0> ;
  assign m_axi_araddr[13] = \<const0> ;
  assign m_axi_araddr[12] = \<const0> ;
  assign m_axi_araddr[11] = \<const0> ;
  assign m_axi_araddr[10] = \<const0> ;
  assign m_axi_araddr[9] = \<const0> ;
  assign m_axi_araddr[8] = \<const0> ;
  assign m_axi_araddr[7] = \<const0> ;
  assign m_axi_araddr[6] = \<const0> ;
  assign m_axi_araddr[5] = \<const0> ;
  assign m_axi_araddr[4] = \<const0> ;
  assign m_axi_araddr[3] = \<const0> ;
  assign m_axi_araddr[2] = \<const0> ;
  assign m_axi_araddr[1] = \<const0> ;
  assign m_axi_araddr[0] = \<const0> ;
  assign m_axi_arburst[1] = \<const0> ;
  assign m_axi_arburst[0] = \<const0> ;
  assign m_axi_arcache[3] = \<const0> ;
  assign m_axi_arcache[2] = \<const0> ;
  assign m_axi_arcache[1] = \<const0> ;
  assign m_axi_arcache[0] = \<const0> ;
  assign m_axi_arid[0] = \<const0> ;
  assign m_axi_arlen[7] = \<const0> ;
  assign m_axi_arlen[6] = \<const0> ;
  assign m_axi_arlen[5] = \<const0> ;
  assign m_axi_arlen[4] = \<const0> ;
  assign m_axi_arlen[3] = \<const0> ;
  assign m_axi_arlen[2] = \<const0> ;
  assign m_axi_arlen[1] = \<const0> ;
  assign m_axi_arlen[0] = \<const0> ;
  assign m_axi_arlock[0] = \<const0> ;
  assign m_axi_arprot[2] = \<const0> ;
  assign m_axi_arprot[1] = \<const0> ;
  assign m_axi_arprot[0] = \<const0> ;
  assign m_axi_arqos[3] = \<const0> ;
  assign m_axi_arqos[2] = \<const0> ;
  assign m_axi_arqos[1] = \<const0> ;
  assign m_axi_arqos[0] = \<const0> ;
  assign m_axi_arregion[3] = \<const0> ;
  assign m_axi_arregion[2] = \<const0> ;
  assign m_axi_arregion[1] = \<const0> ;
  assign m_axi_arregion[0] = \<const0> ;
  assign m_axi_arsize[2] = \<const0> ;
  assign m_axi_arsize[1] = \<const0> ;
  assign m_axi_arsize[0] = \<const0> ;
  assign m_axi_aruser[0] = \<const0> ;
  assign m_axi_arvalid = \<const0> ;
  assign m_axi_awaddr[31] = \<const0> ;
  assign m_axi_awaddr[30] = \<const0> ;
  assign m_axi_awaddr[29] = \<const0> ;
  assign m_axi_awaddr[28] = \<const0> ;
  assign m_axi_awaddr[27] = \<const0> ;
  assign m_axi_awaddr[26] = \<const0> ;
  assign m_axi_awaddr[25] = \<const0> ;
  assign m_axi_awaddr[24] = \<const0> ;
  assign m_axi_awaddr[23] = \<const0> ;
  assign m_axi_awaddr[22] = \<const0> ;
  assign m_axi_awaddr[21] = \<const0> ;
  assign m_axi_awaddr[20] = \<const0> ;
  assign m_axi_awaddr[19] = \<const0> ;
  assign m_axi_awaddr[18] = \<const0> ;
  assign m_axi_awaddr[17] = \<const0> ;
  assign m_axi_awaddr[16] = \<const0> ;
  assign m_axi_awaddr[15] = \<const0> ;
  assign m_axi_awaddr[14] = \<const0> ;
  assign m_axi_awaddr[13] = \<const0> ;
  assign m_axi_awaddr[12] = \<const0> ;
  assign m_axi_awaddr[11] = \<const0> ;
  assign m_axi_awaddr[10] = \<const0> ;
  assign m_axi_awaddr[9] = \<const0> ;
  assign m_axi_awaddr[8] = \<const0> ;
  assign m_axi_awaddr[7] = \<const0> ;
  assign m_axi_awaddr[6] = \<const0> ;
  assign m_axi_awaddr[5] = \<const0> ;
  assign m_axi_awaddr[4] = \<const0> ;
  assign m_axi_awaddr[3] = \<const0> ;
  assign m_axi_awaddr[2] = \<const0> ;
  assign m_axi_awaddr[1] = \<const0> ;
  assign m_axi_awaddr[0] = \<const0> ;
  assign m_axi_awburst[1] = \<const0> ;
  assign m_axi_awburst[0] = \<const0> ;
  assign m_axi_awcache[3] = \<const0> ;
  assign m_axi_awcache[2] = \<const0> ;
  assign m_axi_awcache[1] = \<const0> ;
  assign m_axi_awcache[0] = \<const0> ;
  assign m_axi_awid[0] = \<const0> ;
  assign m_axi_awlen[7] = \<const0> ;
  assign m_axi_awlen[6] = \<const0> ;
  assign m_axi_awlen[5] = \<const0> ;
  assign m_axi_awlen[4] = \<const0> ;
  assign m_axi_awlen[3] = \<const0> ;
  assign m_axi_awlen[2] = \<const0> ;
  assign m_axi_awlen[1] = \<const0> ;
  assign m_axi_awlen[0] = \<const0> ;
  assign m_axi_awlock[0] = \<const0> ;
  assign m_axi_awprot[2] = \<const0> ;
  assign m_axi_awprot[1] = \<const0> ;
  assign m_axi_awprot[0] = \<const0> ;
  assign m_axi_awqos[3] = \<const0> ;
  assign m_axi_awqos[2] = \<const0> ;
  assign m_axi_awqos[1] = \<const0> ;
  assign m_axi_awqos[0] = \<const0> ;
  assign m_axi_awregion[3] = \<const0> ;
  assign m_axi_awregion[2] = \<const0> ;
  assign m_axi_awregion[1] = \<const0> ;
  assign m_axi_awregion[0] = \<const0> ;
  assign m_axi_awsize[2] = \<const0> ;
  assign m_axi_awsize[1] = \<const0> ;
  assign m_axi_awsize[0] = \<const0> ;
  assign m_axi_awuser[0] = \<const0> ;
  assign m_axi_awvalid = \<const0> ;
  assign m_axi_bready = \<const0> ;
  assign m_axi_rready = \<const0> ;
  assign m_axi_wdata[63] = \<const0> ;
  assign m_axi_wdata[62] = \<const0> ;
  assign m_axi_wdata[61] = \<const0> ;
  assign m_axi_wdata[60] = \<const0> ;
  assign m_axi_wdata[59] = \<const0> ;
  assign m_axi_wdata[58] = \<const0> ;
  assign m_axi_wdata[57] = \<const0> ;
  assign m_axi_wdata[56] = \<const0> ;
  assign m_axi_wdata[55] = \<const0> ;
  assign m_axi_wdata[54] = \<const0> ;
  assign m_axi_wdata[53] = \<const0> ;
  assign m_axi_wdata[52] = \<const0> ;
  assign m_axi_wdata[51] = \<const0> ;
  assign m_axi_wdata[50] = \<const0> ;
  assign m_axi_wdata[49] = \<const0> ;
  assign m_axi_wdata[48] = \<const0> ;
  assign m_axi_wdata[47] = \<const0> ;
  assign m_axi_wdata[46] = \<const0> ;
  assign m_axi_wdata[45] = \<const0> ;
  assign m_axi_wdata[44] = \<const0> ;
  assign m_axi_wdata[43] = \<const0> ;
  assign m_axi_wdata[42] = \<const0> ;
  assign m_axi_wdata[41] = \<const0> ;
  assign m_axi_wdata[40] = \<const0> ;
  assign m_axi_wdata[39] = \<const0> ;
  assign m_axi_wdata[38] = \<const0> ;
  assign m_axi_wdata[37] = \<const0> ;
  assign m_axi_wdata[36] = \<const0> ;
  assign m_axi_wdata[35] = \<const0> ;
  assign m_axi_wdata[34] = \<const0> ;
  assign m_axi_wdata[33] = \<const0> ;
  assign m_axi_wdata[32] = \<const0> ;
  assign m_axi_wdata[31] = \<const0> ;
  assign m_axi_wdata[30] = \<const0> ;
  assign m_axi_wdata[29] = \<const0> ;
  assign m_axi_wdata[28] = \<const0> ;
  assign m_axi_wdata[27] = \<const0> ;
  assign m_axi_wdata[26] = \<const0> ;
  assign m_axi_wdata[25] = \<const0> ;
  assign m_axi_wdata[24] = \<const0> ;
  assign m_axi_wdata[23] = \<const0> ;
  assign m_axi_wdata[22] = \<const0> ;
  assign m_axi_wdata[21] = \<const0> ;
  assign m_axi_wdata[20] = \<const0> ;
  assign m_axi_wdata[19] = \<const0> ;
  assign m_axi_wdata[18] = \<const0> ;
  assign m_axi_wdata[17] = \<const0> ;
  assign m_axi_wdata[16] = \<const0> ;
  assign m_axi_wdata[15] = \<const0> ;
  assign m_axi_wdata[14] = \<const0> ;
  assign m_axi_wdata[13] = \<const0> ;
  assign m_axi_wdata[12] = \<const0> ;
  assign m_axi_wdata[11] = \<const0> ;
  assign m_axi_wdata[10] = \<const0> ;
  assign m_axi_wdata[9] = \<const0> ;
  assign m_axi_wdata[8] = \<const0> ;
  assign m_axi_wdata[7] = \<const0> ;
  assign m_axi_wdata[6] = \<const0> ;
  assign m_axi_wdata[5] = \<const0> ;
  assign m_axi_wdata[4] = \<const0> ;
  assign m_axi_wdata[3] = \<const0> ;
  assign m_axi_wdata[2] = \<const0> ;
  assign m_axi_wdata[1] = \<const0> ;
  assign m_axi_wdata[0] = \<const0> ;
  assign m_axi_wid[0] = \<const0> ;
  assign m_axi_wlast = \<const0> ;
  assign m_axi_wstrb[7] = \<const0> ;
  assign m_axi_wstrb[6] = \<const0> ;
  assign m_axi_wstrb[5] = \<const0> ;
  assign m_axi_wstrb[4] = \<const0> ;
  assign m_axi_wstrb[3] = \<const0> ;
  assign m_axi_wstrb[2] = \<const0> ;
  assign m_axi_wstrb[1] = \<const0> ;
  assign m_axi_wstrb[0] = \<const0> ;
  assign m_axi_wuser[0] = \<const0> ;
  assign m_axi_wvalid = \<const0> ;
  assign m_axis_tdata[7] = \<const0> ;
  assign m_axis_tdata[6] = \<const0> ;
  assign m_axis_tdata[5] = \<const0> ;
  assign m_axis_tdata[4] = \<const0> ;
  assign m_axis_tdata[3] = \<const0> ;
  assign m_axis_tdata[2] = \<const0> ;
  assign m_axis_tdata[1] = \<const0> ;
  assign m_axis_tdata[0] = \<const0> ;
  assign m_axis_tdest[0] = \<const0> ;
  assign m_axis_tid[0] = \<const0> ;
  assign m_axis_tkeep[0] = \<const0> ;
  assign m_axis_tlast = \<const0> ;
  assign m_axis_tstrb[0] = \<const0> ;
  assign m_axis_tuser[3] = \<const0> ;
  assign m_axis_tuser[2] = \<const0> ;
  assign m_axis_tuser[1] = \<const0> ;
  assign m_axis_tuser[0] = \<const0> ;
  assign m_axis_tvalid = \<const0> ;
  assign prog_empty = \<const0> ;
  assign prog_full = \<const0> ;
  assign rd_data_count[15] = \<const0> ;
  assign rd_data_count[14] = \<const0> ;
  assign rd_data_count[13] = \<const0> ;
  assign rd_data_count[12] = \<const0> ;
  assign rd_data_count[11] = \<const0> ;
  assign rd_data_count[10] = \<const0> ;
  assign rd_data_count[9] = \<const0> ;
  assign rd_data_count[8] = \<const0> ;
  assign rd_data_count[7] = \<const0> ;
  assign rd_data_count[6] = \<const0> ;
  assign rd_data_count[5] = \<const0> ;
  assign rd_data_count[4] = \<const0> ;
  assign rd_data_count[3] = \<const0> ;
  assign rd_data_count[2] = \<const0> ;
  assign rd_data_count[1] = \<const0> ;
  assign rd_data_count[0] = \<const0> ;
  assign rd_rst_busy = \<const1> ;
  assign s_axi_arready = \<const0> ;
  assign s_axi_awready = \<const0> ;
  assign s_axi_bid[0] = \<const0> ;
  assign s_axi_bresp[1] = \<const0> ;
  assign s_axi_bresp[0] = \<const0> ;
  assign s_axi_buser[0] = \<const0> ;
  assign s_axi_bvalid = \<const0> ;
  assign s_axi_rdata[63] = \<const0> ;
  assign s_axi_rdata[62] = \<const0> ;
  assign s_axi_rdata[61] = \<const0> ;
  assign s_axi_rdata[60] = \<const0> ;
  assign s_axi_rdata[59] = \<const0> ;
  assign s_axi_rdata[58] = \<const0> ;
  assign s_axi_rdata[57] = \<const0> ;
  assign s_axi_rdata[56] = \<const0> ;
  assign s_axi_rdata[55] = \<const0> ;
  assign s_axi_rdata[54] = \<const0> ;
  assign s_axi_rdata[53] = \<const0> ;
  assign s_axi_rdata[52] = \<const0> ;
  assign s_axi_rdata[51] = \<const0> ;
  assign s_axi_rdata[50] = \<const0> ;
  assign s_axi_rdata[49] = \<const0> ;
  assign s_axi_rdata[48] = \<const0> ;
  assign s_axi_rdata[47] = \<const0> ;
  assign s_axi_rdata[46] = \<const0> ;
  assign s_axi_rdata[45] = \<const0> ;
  assign s_axi_rdata[44] = \<const0> ;
  assign s_axi_rdata[43] = \<const0> ;
  assign s_axi_rdata[42] = \<const0> ;
  assign s_axi_rdata[41] = \<const0> ;
  assign s_axi_rdata[40] = \<const0> ;
  assign s_axi_rdata[39] = \<const0> ;
  assign s_axi_rdata[38] = \<const0> ;
  assign s_axi_rdata[37] = \<const0> ;
  assign s_axi_rdata[36] = \<const0> ;
  assign s_axi_rdata[35] = \<const0> ;
  assign s_axi_rdata[34] = \<const0> ;
  assign s_axi_rdata[33] = \<const0> ;
  assign s_axi_rdata[32] = \<const0> ;
  assign s_axi_rdata[31] = \<const0> ;
  assign s_axi_rdata[30] = \<const0> ;
  assign s_axi_rdata[29] = \<const0> ;
  assign s_axi_rdata[28] = \<const0> ;
  assign s_axi_rdata[27] = \<const0> ;
  assign s_axi_rdata[26] = \<const0> ;
  assign s_axi_rdata[25] = \<const0> ;
  assign s_axi_rdata[24] = \<const0> ;
  assign s_axi_rdata[23] = \<const0> ;
  assign s_axi_rdata[22] = \<const0> ;
  assign s_axi_rdata[21] = \<const0> ;
  assign s_axi_rdata[20] = \<const0> ;
  assign s_axi_rdata[19] = \<const0> ;
  assign s_axi_rdata[18] = \<const0> ;
  assign s_axi_rdata[17] = \<const0> ;
  assign s_axi_rdata[16] = \<const0> ;
  assign s_axi_rdata[15] = \<const0> ;
  assign s_axi_rdata[14] = \<const0> ;
  assign s_axi_rdata[13] = \<const0> ;
  assign s_axi_rdata[12] = \<const0> ;
  assign s_axi_rdata[11] = \<const0> ;
  assign s_axi_rdata[10] = \<const0> ;
  assign s_axi_rdata[9] = \<const0> ;
  assign s_axi_rdata[8] = \<const0> ;
  assign s_axi_rdata[7] = \<const0> ;
  assign s_axi_rdata[6] = \<const0> ;
  assign s_axi_rdata[5] = \<const0> ;
  assign s_axi_rdata[4] = \<const0> ;
  assign s_axi_rdata[3] = \<const0> ;
  assign s_axi_rdata[2] = \<const0> ;
  assign s_axi_rdata[1] = \<const0> ;
  assign s_axi_rdata[0] = \<const0> ;
  assign s_axi_rid[0] = \<const0> ;
  assign s_axi_rlast = \<const0> ;
  assign s_axi_rresp[1] = \<const0> ;
  assign s_axi_rresp[0] = \<const0> ;
  assign s_axi_ruser[0] = \<const0> ;
  assign s_axi_rvalid = \<const0> ;
  assign s_axi_wready = \<const0> ;
  assign s_axis_tready = \<const0> ;
  assign sbiterr = \<const0> ;
  assign valid = \<const0> ;
  assign wr_ack = \<const0> ;
  assign wr_data_count[15] = \<const0> ;
  assign wr_data_count[14] = \<const0> ;
  assign wr_data_count[13] = \<const0> ;
  assign wr_data_count[12] = \<const0> ;
  assign wr_data_count[11] = \<const0> ;
  assign wr_data_count[10] = \<const0> ;
  assign wr_data_count[9] = \<const0> ;
  assign wr_data_count[8] = \<const0> ;
  assign wr_data_count[7] = \<const0> ;
  assign wr_data_count[6] = \<const0> ;
  assign wr_data_count[5] = \<const0> ;
  assign wr_data_count[4] = \<const0> ;
  assign wr_data_count[3] = \<const0> ;
  assign wr_data_count[2] = \<const0> ;
  assign wr_data_count[1] = \<const0> ;
  assign wr_data_count[0] = \<const0> ;
  assign wr_rst_busy = \<const1> ;
  GND GND
       (.G(\<const0> ));
  VCC VCC
       (.P(\<const1> ));
  usb_slow_fifo_semipro_fifo_generator_v13_2_5_synth inst_fifo_gen
       (.din(din),
        .dout(dout),
        .empty(empty),
        .full(full),
        .overflow(overflow),
        .rd_clk(rd_clk),
        .rd_en(rd_en),
        .rst(rst),
        .underflow(underflow),
        .wr_clk(wr_clk),
        .wr_en(wr_en));
endmodule

(* ORIG_REF_NAME = "fifo_generator_v13_2_5_builtin" *) 
module usb_slow_fifo_semipro_fifo_generator_v13_2_5_builtin
   (dout,
    overflow,
    underflow,
    full,
    empty,
    rd_clk,
    rd_en,
    wr_clk,
    din,
    rst,
    wr_en);
  output [35:0]dout;
  output overflow;
  output underflow;
  output full;
  output empty;
  input rd_clk;
  input rd_en;
  input wr_clk;
  input [35:0]din;
  input rst;
  input wr_en;

  wire [35:0]din;
  wire [35:0]dout;
  wire empty;
  wire full;
  wire overflow;
  wire rd_clk;
  wire rd_en;
  wire rd_rst_i;
  wire rst;
  wire underflow;
  wire wr_clk;
  wire wr_en;

  usb_slow_fifo_semipro_reset_builtin \g7ser_birst.rstbt 
       (.rd_clk(rd_clk),
        .rd_rst_i(rd_rst_i),
        .rst(rst),
        .wr_clk(wr_clk));
  usb_slow_fifo_semipro_builtin_top_v6 \v7_bi_fifo.fblk 
       (.din(din),
        .dout(dout),
        .empty(empty),
        .full(full),
        .overflow(overflow),
        .rd_clk(rd_clk),
        .rd_en(rd_en),
        .rd_rst_i(rd_rst_i),
        .underflow(underflow),
        .wr_clk(wr_clk),
        .wr_en(wr_en));
endmodule

(* ORIG_REF_NAME = "fifo_generator_v13_2_5_synth" *) 
module usb_slow_fifo_semipro_fifo_generator_v13_2_5_synth
   (dout,
    overflow,
    underflow,
    full,
    empty,
    rd_clk,
    rd_en,
    wr_clk,
    din,
    rst,
    wr_en);
  output [35:0]dout;
  output overflow;
  output underflow;
  output full;
  output empty;
  input rd_clk;
  input rd_en;
  input wr_clk;
  input [35:0]din;
  input rst;
  input wr_en;

  wire [35:0]din;
  wire [35:0]dout;
  wire empty;
  wire full;
  wire overflow;
  wire rd_clk;
  wire rd_en;
  wire rst;
  wire underflow;
  wire wr_clk;
  wire wr_en;

  usb_slow_fifo_semipro_fifo_generator_top \gconvfifo.rf 
       (.din(din),
        .dout(dout),
        .empty(empty),
        .full(full),
        .overflow(overflow),
        .rd_clk(rd_clk),
        .rd_en(rd_en),
        .rst(rst),
        .underflow(underflow),
        .wr_clk(wr_clk),
        .wr_en(wr_en));
endmodule

(* ORIG_REF_NAME = "reset_builtin" *) 
module usb_slow_fifo_semipro_reset_builtin
   (rd_rst_i,
    rd_clk,
    wr_clk,
    rst);
  output rd_rst_i;
  input rd_clk;
  input wr_clk;
  input rst;

  (* async_reg = "true" *) (* msgon = "true" *) wire [5:0]power_on_rd_rst;
  (* async_reg = "true" *) (* msgon = "true" *) wire [5:0]power_on_wr_rst;
  wire rd_clk;
  wire rd_rst_i;
  wire rd_rst_reg;
  (* async_reg = "true" *) (* msgon = "true" *) wire rd_rst_reg1;
  (* async_reg = "true" *) (* msgon = "true" *) wire rd_rst_reg2;
  wire rst;
  wire \rsync.ric.rd_rst_fb_reg[1]_srl4_n_0 ;
  wire \rsync.ric.rd_rst_fb_reg_n_0_[0] ;
  wire \rsync.ric.rd_rst_reg_i_1_n_0 ;
  wire wr_clk;
  (* async_reg = "true" *) (* msgon = "true" *) wire wr_rst_reg1;
  (* async_reg = "true" *) (* msgon = "true" *) wire wr_rst_reg2;

  LUT2 #(
    .INIT(4'hE)) 
    \gf36e1_inst.sngfifo36e1_i_2__0 
       (.I0(rd_rst_reg),
        .I1(power_on_rd_rst[0]),
        .O(rd_rst_i));
  (* ASYNC_REG *) 
  (* KEEP = "yes" *) 
  (* msgon = "true" *) 
  FDRE #(
    .INIT(1'b1)) 
    \rsync.ric.power_on_rd_rst_reg[0] 
       (.C(rd_clk),
        .CE(1'b1),
        .D(power_on_rd_rst[1]),
        .Q(power_on_rd_rst[0]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "yes" *) 
  (* msgon = "true" *) 
  FDRE #(
    .INIT(1'b1)) 
    \rsync.ric.power_on_rd_rst_reg[1] 
       (.C(rd_clk),
        .CE(1'b1),
        .D(power_on_rd_rst[2]),
        .Q(power_on_rd_rst[1]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "yes" *) 
  (* msgon = "true" *) 
  FDRE #(
    .INIT(1'b1)) 
    \rsync.ric.power_on_rd_rst_reg[2] 
       (.C(rd_clk),
        .CE(1'b1),
        .D(power_on_rd_rst[3]),
        .Q(power_on_rd_rst[2]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "yes" *) 
  (* msgon = "true" *) 
  FDRE #(
    .INIT(1'b1)) 
    \rsync.ric.power_on_rd_rst_reg[3] 
       (.C(rd_clk),
        .CE(1'b1),
        .D(power_on_rd_rst[4]),
        .Q(power_on_rd_rst[3]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "yes" *) 
  (* msgon = "true" *) 
  FDRE #(
    .INIT(1'b1)) 
    \rsync.ric.power_on_rd_rst_reg[4] 
       (.C(rd_clk),
        .CE(1'b1),
        .D(power_on_rd_rst[5]),
        .Q(power_on_rd_rst[4]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "yes" *) 
  (* msgon = "true" *) 
  FDRE #(
    .INIT(1'b1)) 
    \rsync.ric.power_on_rd_rst_reg[5] 
       (.C(rd_clk),
        .CE(1'b1),
        .D(1'b0),
        .Q(power_on_rd_rst[5]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "yes" *) 
  (* msgon = "true" *) 
  FDRE #(
    .INIT(1'b1)) 
    \rsync.ric.power_on_wr_rst_reg[0] 
       (.C(wr_clk),
        .CE(1'b1),
        .D(power_on_wr_rst[1]),
        .Q(power_on_wr_rst[0]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "yes" *) 
  (* msgon = "true" *) 
  FDRE #(
    .INIT(1'b1)) 
    \rsync.ric.power_on_wr_rst_reg[1] 
       (.C(wr_clk),
        .CE(1'b1),
        .D(power_on_wr_rst[2]),
        .Q(power_on_wr_rst[1]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "yes" *) 
  (* msgon = "true" *) 
  FDRE #(
    .INIT(1'b1)) 
    \rsync.ric.power_on_wr_rst_reg[2] 
       (.C(wr_clk),
        .CE(1'b1),
        .D(power_on_wr_rst[3]),
        .Q(power_on_wr_rst[2]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "yes" *) 
  (* msgon = "true" *) 
  FDRE #(
    .INIT(1'b1)) 
    \rsync.ric.power_on_wr_rst_reg[3] 
       (.C(wr_clk),
        .CE(1'b1),
        .D(power_on_wr_rst[4]),
        .Q(power_on_wr_rst[3]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "yes" *) 
  (* msgon = "true" *) 
  FDRE #(
    .INIT(1'b1)) 
    \rsync.ric.power_on_wr_rst_reg[4] 
       (.C(wr_clk),
        .CE(1'b1),
        .D(power_on_wr_rst[5]),
        .Q(power_on_wr_rst[4]),
        .R(1'b0));
  (* ASYNC_REG *) 
  (* KEEP = "yes" *) 
  (* msgon = "true" *) 
  FDRE #(
    .INIT(1'b1)) 
    \rsync.ric.power_on_wr_rst_reg[5] 
       (.C(wr_clk),
        .CE(1'b1),
        .D(1'b0),
        .Q(power_on_wr_rst[5]),
        .R(1'b0));
  FDRE #(
    .INIT(1'b0)) 
    \rsync.ric.rd_rst_fb_reg[0] 
       (.C(rd_clk),
        .CE(1'b1),
        .D(\rsync.ric.rd_rst_fb_reg[1]_srl4_n_0 ),
        .Q(\rsync.ric.rd_rst_fb_reg_n_0_[0] ),
        .R(1'b0));
  (* srl_bus_name = "U0/\inst_fifo_gen/gconvfifo.rf/gbi.bi/g7ser_birst.rstbt/rsync.ric.rd_rst_fb_reg " *) 
  (* srl_name = "U0/\inst_fifo_gen/gconvfifo.rf/gbi.bi/g7ser_birst.rstbt/rsync.ric.rd_rst_fb_reg[1]_srl4 " *) 
  SRL16E #(
    .INIT(16'h0000)) 
    \rsync.ric.rd_rst_fb_reg[1]_srl4 
       (.A0(1'b1),
        .A1(1'b1),
        .A2(1'b0),
        .A3(1'b0),
        .CE(1'b1),
        .CLK(rd_clk),
        .D(rd_rst_reg),
        .Q(\rsync.ric.rd_rst_fb_reg[1]_srl4_n_0 ));
  (* ASYNC_REG *) 
  (* KEEP = "yes" *) 
  (* msgon = "true" *) 
  FDPE #(
    .INIT(1'b0)) 
    \rsync.ric.rd_rst_reg1_reg 
       (.C(rd_clk),
        .CE(1'b1),
        .D(1'b0),
        .PRE(rst),
        .Q(rd_rst_reg1));
  (* ASYNC_REG *) 
  (* KEEP = "yes" *) 
  (* msgon = "true" *) 
  FDPE #(
    .INIT(1'b0)) 
    \rsync.ric.rd_rst_reg2_reg 
       (.C(rd_clk),
        .CE(1'b1),
        .D(rd_rst_reg1),
        .PRE(rst),
        .Q(rd_rst_reg2));
  LUT2 #(
    .INIT(4'h2)) 
    \rsync.ric.rd_rst_reg_i_1 
       (.I0(rd_rst_reg),
        .I1(\rsync.ric.rd_rst_fb_reg_n_0_[0] ),
        .O(\rsync.ric.rd_rst_reg_i_1_n_0 ));
  FDPE #(
    .INIT(1'b0)) 
    \rsync.ric.rd_rst_reg_reg 
       (.C(rd_clk),
        .CE(1'b1),
        .D(\rsync.ric.rd_rst_reg_i_1_n_0 ),
        .PRE(rd_rst_reg2),
        .Q(rd_rst_reg));
  (* ASYNC_REG *) 
  (* KEEP = "yes" *) 
  (* msgon = "true" *) 
  FDPE #(
    .INIT(1'b0)) 
    \rsync.ric.wr_rst_reg1_reg 
       (.C(wr_clk),
        .CE(1'b1),
        .D(1'b0),
        .PRE(rst),
        .Q(wr_rst_reg1));
  (* ASYNC_REG *) 
  (* KEEP = "yes" *) 
  (* msgon = "true" *) 
  FDPE #(
    .INIT(1'b0)) 
    \rsync.ric.wr_rst_reg2_reg 
       (.C(wr_clk),
        .CE(1'b1),
        .D(wr_rst_reg1),
        .PRE(rst),
        .Q(wr_rst_reg2));
endmodule
`ifndef GLBL
`define GLBL
`timescale  1 ps / 1 ps

module glbl ();

    parameter ROC_WIDTH = 100000;
    parameter TOC_WIDTH = 0;

//--------   STARTUP Globals --------------
    wire GSR;
    wire GTS;
    wire GWE;
    wire PRLD;
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

endmodule
`endif
