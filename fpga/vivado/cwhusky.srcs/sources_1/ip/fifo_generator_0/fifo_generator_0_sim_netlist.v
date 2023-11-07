// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (lin64) Build 3064766 Wed Nov 18 09:12:47 MST 2020
// Date        : Thu Jun  8 11:07:20 2023
// Host        : red running 64-bit Ubuntu 20.04.6 LTS
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
  (* x_interface_info = "xilinx.com:signal:clock:1.0 write_clk CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME write_clk, FREQ_HZ 1000000, FREQ_TOLERANCE_HZ 0, PHASE 0.000, INSERT_VIP 0" *) input wr_clk;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 read_clk CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME read_clk, FREQ_HZ 1000000, FREQ_TOLERANCE_HZ 0, PHASE 0.000, INSERT_VIP 0" *) input rd_clk;
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
  (* C_RD_FREQ = "1" *) 
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
  (* C_WR_FREQ = "1" *) 
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
