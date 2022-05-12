// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (lin64) Build 3064766 Wed Nov 18 09:12:47 MST 2020
// Date        : Tue Mar 29 21:17:56 2022
// Host        : red running 64-bit Ubuntu 18.04.6 LTS
// Command     : write_verilog -force -mode funcsim -rename_top sad_fifo -prefix
//               sad_fifo_ sad_fifo_sim_netlist.v
// Design      : sad_fifo
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a35tftg256-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "sad_fifo,fifo_generator_v13_2_5,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "fifo_generator_v13_2_5,Vivado 2020.2" *) 
(* NotValidForBitStream *)
module sad_fifo
   (clk,
    rst,
    din,
    wr_en,
    rd_en,
    dout,
    full,
    overflow,
    empty,
    almost_empty,
    underflow);
  (* x_interface_info = "xilinx.com:signal:clock:1.0 core_clk CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME core_clk, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.000, INSERT_VIP 0" *) input clk;
  input rst;
  (* x_interface_info = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE WR_DATA" *) input [7:0]din;
  (* x_interface_info = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE WR_EN" *) input wr_en;
  (* x_interface_info = "xilinx.com:interface:fifo_read:1.0 FIFO_READ RD_EN" *) input rd_en;
  (* x_interface_info = "xilinx.com:interface:fifo_read:1.0 FIFO_READ RD_DATA" *) output [7:0]dout;
  (* x_interface_info = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE FULL" *) output full;
  output overflow;
  (* x_interface_info = "xilinx.com:interface:fifo_read:1.0 FIFO_READ EMPTY" *) output empty;
  (* x_interface_info = "xilinx.com:interface:fifo_read:1.0 FIFO_READ ALMOST_EMPTY" *) output almost_empty;
  output underflow;

  wire almost_empty;
  wire clk;
  wire [7:0]din;
  wire [7:0]dout;
  wire empty;
  wire full;
  wire overflow;
  wire rd_en;
  wire rst;
  wire underflow;
  wire wr_en;
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
  wire [4:0]NLW_U0_data_count_UNCONNECTED;
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
  wire [4:0]NLW_U0_rd_data_count_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_bid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_bresp_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_buser_UNCONNECTED;
  wire [63:0]NLW_U0_s_axi_rdata_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_rid_UNCONNECTED;
  wire [1:0]NLW_U0_s_axi_rresp_UNCONNECTED;
  wire [0:0]NLW_U0_s_axi_ruser_UNCONNECTED;
  wire [4:0]NLW_U0_wr_data_count_UNCONNECTED;

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
  (* C_DATA_COUNT_WIDTH = "5" *) 
  (* C_DEFAULT_VALUE = "BlankString" *) 
  (* C_DIN_WIDTH = "8" *) 
  (* C_DIN_WIDTH_AXIS = "1" *) 
  (* C_DIN_WIDTH_RACH = "32" *) 
  (* C_DIN_WIDTH_RDCH = "64" *) 
  (* C_DIN_WIDTH_WACH = "1" *) 
  (* C_DIN_WIDTH_WDCH = "64" *) 
  (* C_DIN_WIDTH_WRCH = "2" *) 
  (* C_DOUT_RST_VAL = "0" *) 
  (* C_DOUT_WIDTH = "8" *) 
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
  (* C_FULL_FLAGS_RST_VAL = "1" *) 
  (* C_HAS_ALMOST_EMPTY = "1" *) 
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
  (* C_IMPLEMENTATION_TYPE = "0" *) 
  (* C_IMPLEMENTATION_TYPE_AXIS = "1" *) 
  (* C_IMPLEMENTATION_TYPE_RACH = "1" *) 
  (* C_IMPLEMENTATION_TYPE_RDCH = "1" *) 
  (* C_IMPLEMENTATION_TYPE_WACH = "1" *) 
  (* C_IMPLEMENTATION_TYPE_WDCH = "1" *) 
  (* C_IMPLEMENTATION_TYPE_WRCH = "1" *) 
  (* C_INIT_WR_PNTR_VAL = "0" *) 
  (* C_INTERFACE_TYPE = "0" *) 
  (* C_MEMORY_TYPE = "2" *) 
  (* C_MIF_FILE_NAME = "BlankString" *) 
  (* C_MSGON_VAL = "1" *) 
  (* C_OPTIMIZATION_MODE = "0" *) 
  (* C_OVERFLOW_LOW = "0" *) 
  (* C_POWER_SAVING_MODE = "0" *) 
  (* C_PRELOAD_LATENCY = "1" *) 
  (* C_PRELOAD_REGS = "0" *) 
  (* C_PRIM_FIFO_TYPE = "512x36" *) 
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
  (* C_PROG_FULL_THRESH_ASSERT_VAL = "30" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_AXIS = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_RACH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_RDCH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WACH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WDCH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WRCH = "1023" *) 
  (* C_PROG_FULL_THRESH_NEGATE_VAL = "29" *) 
  (* C_PROG_FULL_TYPE = "0" *) 
  (* C_PROG_FULL_TYPE_AXIS = "0" *) 
  (* C_PROG_FULL_TYPE_RACH = "0" *) 
  (* C_PROG_FULL_TYPE_RDCH = "0" *) 
  (* C_PROG_FULL_TYPE_WACH = "0" *) 
  (* C_PROG_FULL_TYPE_WDCH = "0" *) 
  (* C_PROG_FULL_TYPE_WRCH = "0" *) 
  (* C_RACH_TYPE = "0" *) 
  (* C_RDCH_TYPE = "0" *) 
  (* C_RD_DATA_COUNT_WIDTH = "5" *) 
  (* C_RD_DEPTH = "32" *) 
  (* C_RD_FREQ = "1" *) 
  (* C_RD_PNTR_WIDTH = "5" *) 
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
  (* C_USE_DOUT_RST = "1" *) 
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
  (* C_WR_DATA_COUNT_WIDTH = "5" *) 
  (* C_WR_DEPTH = "32" *) 
  (* C_WR_DEPTH_AXIS = "1024" *) 
  (* C_WR_DEPTH_RACH = "16" *) 
  (* C_WR_DEPTH_RDCH = "1024" *) 
  (* C_WR_DEPTH_WACH = "16" *) 
  (* C_WR_DEPTH_WDCH = "1024" *) 
  (* C_WR_DEPTH_WRCH = "16" *) 
  (* C_WR_FREQ = "1" *) 
  (* C_WR_PNTR_WIDTH = "5" *) 
  (* C_WR_PNTR_WIDTH_AXIS = "10" *) 
  (* C_WR_PNTR_WIDTH_RACH = "4" *) 
  (* C_WR_PNTR_WIDTH_RDCH = "10" *) 
  (* C_WR_PNTR_WIDTH_WACH = "4" *) 
  (* C_WR_PNTR_WIDTH_WDCH = "10" *) 
  (* C_WR_PNTR_WIDTH_WRCH = "4" *) 
  (* C_WR_RESPONSE_LATENCY = "1" *) 
  (* is_du_within_envelope = "true" *) 
  sad_fifo_fifo_generator_v13_2_5 U0
       (.almost_empty(almost_empty),
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
        .data_count(NLW_U0_data_count_UNCONNECTED[4:0]),
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
        .prog_empty_thresh({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_empty_thresh_assert({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_empty_thresh_negate({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_full(NLW_U0_prog_full_UNCONNECTED),
        .prog_full_thresh({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_full_thresh_assert({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .prog_full_thresh_negate({1'b0,1'b0,1'b0,1'b0,1'b0}),
        .rd_clk(1'b0),
        .rd_data_count(NLW_U0_rd_data_count_UNCONNECTED[4:0]),
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
        .wr_data_count(NLW_U0_wr_data_count_UNCONNECTED[4:0]),
        .wr_en(wr_en),
        .wr_rst(1'b0),
        .wr_rst_busy(NLW_U0_wr_rst_busy_UNCONNECTED));
endmodule

(* DEF_VAL = "1'b0" *) (* DEST_SYNC_FF = "2" *) (* INIT_SYNC_FF = "0" *) 
(* INV_DEF_VAL = "1'b1" *) (* RST_ACTIVE_HIGH = "1" *) (* VERSION = "0" *) 
(* XPM_MODULE = "TRUE" *) (* is_du_within_envelope = "true" *) (* keep_hierarchy = "true" *) 
(* xpm_cdc = "ASYNC_RST" *) 
module sad_fifo_xpm_cdc_async_rst
   (src_arst,
    dest_clk,
    dest_arst);
  input src_arst;
  input dest_clk;
  output dest_arst;

  (* RTL_KEEP = "true" *) (* async_reg = "true" *) (* xpm_cdc = "ASYNC_RST" *) wire [1:0]arststages_ff;
  wire dest_clk;
  wire src_arst;

  assign dest_arst = arststages_ff[1];
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "ASYNC_RST" *) 
  FDPE #(
    .INIT(1'b0)) 
    \arststages_ff_reg[0] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(1'b0),
        .PRE(src_arst),
        .Q(arststages_ff[0]));
  (* ASYNC_REG *) 
  (* KEEP = "true" *) 
  (* XPM_CDC = "ASYNC_RST" *) 
  FDPE #(
    .INIT(1'b0)) 
    \arststages_ff_reg[1] 
       (.C(dest_clk),
        .CE(1'b1),
        .D(arststages_ff[0]),
        .PRE(src_arst),
        .Q(arststages_ff[1]));
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 71600)
`pragma protect data_block
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
zogV+WqpVKw=
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
