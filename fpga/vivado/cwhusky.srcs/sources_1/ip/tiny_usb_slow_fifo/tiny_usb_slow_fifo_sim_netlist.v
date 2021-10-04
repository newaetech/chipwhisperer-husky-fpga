// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
// Date        : Fri Sep 17 14:05:46 2021
// Host        : qed running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               c:/Users/jp/GitHub/OpenTitan/husky/fpga/vivado/cwhusky.srcs/sources_1/ip/tiny_usb_slow_fifo/tiny_usb_slow_fifo_sim_netlist.v
// Design      : tiny_usb_slow_fifo
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a35tftg256-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "tiny_usb_slow_fifo,fifo_generator_v13_2_5,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "fifo_generator_v13_2_5,Vivado 2020.2" *) 
(* NotValidForBitStream *)
module tiny_usb_slow_fifo
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
  (* x_interface_info = "xilinx.com:signal:clock:1.0 write_clk CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME write_clk, FREQ_HZ 200000000, FREQ_TOLERANCE_HZ 0, PHASE 0.000, INSERT_VIP 0" *) input wr_clk;
  (* x_interface_info = "xilinx.com:signal:clock:1.0 read_clk CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME read_clk, FREQ_HZ 96000000, FREQ_TOLERANCE_HZ 0, PHASE 0.000, INSERT_VIP 0" *) input rd_clk;
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
  (* C_COMMON_CLOCK = "0" *) 
  (* C_COUNT_TYPE = "0" *) 
  (* C_DATA_COUNT_WIDTH = "10" *) 
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
  (* C_PRIM_FIFO_TYPE = "1kx36" *) 
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
  (* C_PROG_FULL_THRESH_ASSERT_VAL = "1010" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_AXIS = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_RACH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_RDCH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WACH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WDCH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WRCH = "1023" *) 
  (* C_PROG_FULL_THRESH_NEGATE_VAL = "1009" *) 
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
  (* C_RD_FREQ = "96" *) 
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
  (* C_WR_FREQ = "200" *) 
  (* C_WR_PNTR_WIDTH = "10" *) 
  (* C_WR_PNTR_WIDTH_AXIS = "10" *) 
  (* C_WR_PNTR_WIDTH_RACH = "4" *) 
  (* C_WR_PNTR_WIDTH_RDCH = "10" *) 
  (* C_WR_PNTR_WIDTH_WACH = "4" *) 
  (* C_WR_PNTR_WIDTH_WDCH = "10" *) 
  (* C_WR_PNTR_WIDTH_WRCH = "4" *) 
  (* C_WR_RESPONSE_LATENCY = "1" *) 
  (* is_du_within_envelope = "true" *) 
  tiny_usb_slow_fifo_fifo_generator_v13_2_5 U0
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
        .overflow(overflow),
        .prog_empty(NLW_U0_prog_empty_UNCONNECTED),
        .prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_empty_thresh_assert({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_empty_thresh_negate({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_full(NLW_U0_prog_full_UNCONNECTED),
        .prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_full_thresh_assert({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_full_thresh_negate({1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0,1'b0}),
        .rd_clk(rd_clk),
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
        .wr_clk(wr_clk),
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 54512)
`pragma protect data_block
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
8b0AFGwwjwA471lI+8urtODp1Zw=
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
