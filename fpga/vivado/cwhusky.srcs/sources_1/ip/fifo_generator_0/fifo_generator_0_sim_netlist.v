// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (lin64) Build 3064766 Wed Nov 18 09:12:47 MST 2020
// Date        : Mon Jan 10 11:46:59 2022
// Host        : red running 64-bit Ubuntu 18.04.6 LTS
// Command     : write_verilog -force -mode funcsim
//               /home/jpnewae/git/cw_husky/fpga/vivado/cwhusky.srcs/sources_1/ip/fifo_generator_0/fifo_generator_0_sim_netlist.v
// Design      : fifo_generator_0
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a35tftg256-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "fifo_generator_0,fifo_generator_v13_2_5,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "fifo_generator_v13_2_5,Vivado 2020.2" *) 
(* NotValidForBitStream *)
module fifo_generator_0
   (rst,
    wr_clk,
    rd_clk,
    din,
    wr_en,
    rd_en,
    dout,
    full,
    empty,
    underflow,
    prog_full,
    prog_empty);
  input rst;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 write_clk CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME write_clk, FREQ_HZ 20000000, FREQ_TOLERANCE_HZ 0, PHASE 0.000, INSERT_VIP 0" *) input wr_clk;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 read_clk CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME read_clk, FREQ_HZ 96000000, FREQ_TOLERANCE_HZ 0, PHASE 0.000, INSERT_VIP 0" *) input rd_clk;
  (* x_interface_info = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE WR_DATA" *) input [17:0]din;
  (* x_interface_info = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE WR_EN" *) input wr_en;
  (* x_interface_info = "xilinx.com:interface:fifo_read:1.0 FIFO_READ RD_EN" *) input rd_en;
  (* x_interface_info = "xilinx.com:interface:fifo_read:1.0 FIFO_READ RD_DATA" *) output [17:0]dout;
  (* x_interface_info = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE FULL" *) output full;
  (* x_interface_info = "xilinx.com:interface:fifo_read:1.0 FIFO_READ EMPTY" *) output empty;
  output underflow;
  output prog_full;
  output prog_empty;

  wire [17:0]din;
  wire [17:0]dout;
  wire empty;
  wire full;
  wire prog_empty;
  wire prog_full;
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
  wire NLW_U0_overflow_UNCONNECTED;
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
  wire [12:0]NLW_U0_data_count_UNCONNECTED;
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
  wire [12:0]NLW_U0_rd_data_count_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_buser_UNCONNECTED;
  wire [63:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_ruser_UNCONNECTED;
  wire [12:0]NLW_U0_wr_data_count_UNCONNECTED;

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
  (* C_DATA_COUNT_WIDTH = "13" *) 
  (* C_DEFAULT_VALUE = "BlankString" *) 
  (* C_DIN_WIDTH = "18" *) 
  (* C_DIN_WIDTH_AXIS = "1" *) 
  (* C_DIN_WIDTH_RACH = "32" *) 
  (* C_DIN_WIDTH_RDCH = "64" *) 
  (* C_DIN_WIDTH_WACH = "1" *) 
  (* C_DIN_WIDTH_WDCH = "64" *) 
  (* C_DIN_WIDTH_WRCH = "2" *) 
  (* C_DOUT_RST_VAL = "0" *) 
  (* C_DOUT_WIDTH = "18" *) 
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
  (* C_PRELOAD_LATENCY = "0" *) 
  (* C_PRELOAD_REGS = "1" *) 
  (* C_PRIM_FIFO_TYPE = "2kx18" *) 
  (* C_PRIM_FIFO_TYPE_AXIS = "1kx18" *) 
  (* C_PRIM_FIFO_TYPE_RACH = "512x36" *) 
  (* C_PRIM_FIFO_TYPE_RDCH = "1kx36" *) 
  (* C_PRIM_FIFO_TYPE_WACH = "512x36" *) 
  (* C_PRIM_FIFO_TYPE_WDCH = "1kx36" *) 
  (* C_PRIM_FIFO_TYPE_WRCH = "512x36" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL = "128" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_AXIS = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_RACH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_RDCH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_WACH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_WDCH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_WRCH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_NEGATE_VAL = "129" *) 
  (* C_PROG_EMPTY_TYPE = "1" *) 
  (* C_PROG_EMPTY_TYPE_AXIS = "0" *) 
  (* C_PROG_EMPTY_TYPE_RACH = "0" *) 
  (* C_PROG_EMPTY_TYPE_RDCH = "0" *) 
  (* C_PROG_EMPTY_TYPE_WACH = "0" *) 
  (* C_PROG_EMPTY_TYPE_WDCH = "0" *) 
  (* C_PROG_EMPTY_TYPE_WRCH = "0" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL = "8188" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_AXIS = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_RACH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_RDCH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WACH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WDCH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WRCH = "1023" *) 
  (* C_PROG_FULL_THRESH_NEGATE_VAL = "8187" *) 
  (* C_PROG_FULL_TYPE = "1" *) 
  (* C_PROG_FULL_TYPE_AXIS = "0" *) 
  (* C_PROG_FULL_TYPE_RACH = "0" *) 
  (* C_PROG_FULL_TYPE_RDCH = "0" *) 
  (* C_PROG_FULL_TYPE_WACH = "0" *) 
  (* C_PROG_FULL_TYPE_WDCH = "0" *) 
  (* C_PROG_FULL_TYPE_WRCH = "0" *) 
  (* C_RACH_TYPE = "0" *) 
  (* C_RDCH_TYPE = "0" *) 
  (* C_RD_DATA_COUNT_WIDTH = "13" *) 
  (* C_RD_DEPTH = "8192" *) 
  (* C_RD_FREQ = "96" *) 
  (* C_RD_PNTR_WIDTH = "13" *) 
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
  (* C_WR_DATA_COUNT_WIDTH = "13" *) 
  (* C_WR_DEPTH = "8192" *) 
  (* C_WR_DEPTH_AXIS = "1024" *) 
  (* C_WR_DEPTH_RACH = "16" *) 
  (* C_WR_DEPTH_RDCH = "1024" *) 
  (* C_WR_DEPTH_WACH = "16" *) 
  (* C_WR_DEPTH_WDCH = "1024" *) 
  (* C_WR_DEPTH_WRCH = "16" *) 
  (* C_WR_FREQ = "20" *) 
  (* C_WR_PNTR_WIDTH = "13" *) 
  (* C_WR_PNTR_WIDTH_AXIS = "10" *) 
  (* C_WR_PNTR_WIDTH_RACH = "4" *) 
  (* C_WR_PNTR_WIDTH_RDCH = "10" *) 
  (* C_WR_PNTR_WIDTH_WACH = "4" *) 
  (* C_WR_PNTR_WIDTH_WDCH = "10" *) 
  (* C_WR_PNTR_WIDTH_WRCH = "4" *) 
  (* C_WR_RESPONSE_LATENCY = "1" *) 
  (* is_du_within_envelope = "true" *) 
  fifo_generator_0_fifo_generator_v13_2_5 U0
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
        .data_count(NLW_U0_data_count_UNCONNECTED[12:0]),
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
        .prog_empty(prog_empty),
        .prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_empty_thresh_assert({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_empty_thresh_negate({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_full(prog_full),
        .prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_full_thresh_assert({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_full_thresh_negate({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .rd_clk(rd_clk),
        .rd_data_count(NLW_U0_rd_data_count_UNCONNECTED[12:0]),
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
        .wr_data_count(NLW_U0_wr_data_count_UNCONNECTED[12:0]),
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 69408)
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
