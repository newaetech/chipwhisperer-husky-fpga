// Copyright 1986-2020 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2020.2 (win64) Build 3064766 Wed Nov 18 09:12:45 MST 2020
// Date        : Fri Sep 17 14:07:43 2021
// Host        : qed running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode funcsim
//               c:/Users/jp/GitHub/OpenTitan/husky/fpga/vivado/cwhusky.srcs/sources_1/ip/tiny_adc_fast_fifo/tiny_adc_fast_fifo_sim_netlist.v
// Design      : tiny_adc_fast_fifo
// Purpose     : This verilog netlist is a functional simulation representation of the design and should not be modified
//               or synthesized. This netlist cannot be used for SDF annotated simulation.
// Device      : xc7a35tftg256-1
// --------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CHECK_LICENSE_TYPE = "tiny_adc_fast_fifo,fifo_generator_v13_2_5,{}" *) (* downgradeipidentifiedwarnings = "yes" *) (* x_core_info = "fifo_generator_v13_2_5,Vivado 2020.2" *) 
(* NotValidForBitStream *)
module tiny_adc_fast_fifo
   (clk,
    rst,
    din,
    wr_en,
    rd_en,
    dout,
    full,
    overflow,
    empty,
    underflow);
  (* x_interface_info = "xilinx.com:signal:clock:1.0 core_clk CLK" *) (* x_interface_parameter = "XIL_INTERFACENAME core_clk, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, PHASE 0.000, INSERT_VIP 0" *) input clk;
  input rst;
  (* x_interface_info = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE WR_DATA" *) input [11:0]din;
  (* x_interface_info = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE WR_EN" *) input wr_en;
  (* x_interface_info = "xilinx.com:interface:fifo_read:1.0 FIFO_READ RD_EN" *) input rd_en;
  (* x_interface_info = "xilinx.com:interface:fifo_read:1.0 FIFO_READ RD_DATA" *) output [11:0]dout;
  (* x_interface_info = "xilinx.com:interface:fifo_write:1.0 FIFO_WRITE FULL" *) output full;
  output overflow;
  (* x_interface_info = "xilinx.com:interface:fifo_read:1.0 FIFO_READ EMPTY" *) output empty;
  output underflow;

  wire clk;
  wire [11:0]din;
  wire [11:0]dout;
  wire empty;
  wire full;
  wire overflow;
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
  (* C_DIN_WIDTH = "12" *) 
  (* C_DIN_WIDTH_AXIS = "1" *) 
  (* C_DIN_WIDTH_RACH = "32" *) 
  (* C_DIN_WIDTH_RDCH = "64" *) 
  (* C_DIN_WIDTH_WACH = "1" *) 
  (* C_DIN_WIDTH_WDCH = "64" *) 
  (* C_DIN_WIDTH_WRCH = "2" *) 
  (* C_DOUT_RST_VAL = "0" *) 
  (* C_DOUT_WIDTH = "12" *) 
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
  (* C_PRIM_FIFO_TYPE = "1kx18" *) 
  (* C_PRIM_FIFO_TYPE_AXIS = "1kx18" *) 
  (* C_PRIM_FIFO_TYPE_RACH = "512x36" *) 
  (* C_PRIM_FIFO_TYPE_RDCH = "1kx36" *) 
  (* C_PRIM_FIFO_TYPE_WACH = "512x36" *) 
  (* C_PRIM_FIFO_TYPE_WDCH = "1kx36" *) 
  (* C_PRIM_FIFO_TYPE_WRCH = "512x36" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL = "4" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_AXIS = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_RACH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_RDCH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_WACH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_WDCH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_ASSERT_VAL_WRCH = "1022" *) 
  (* C_PROG_EMPTY_THRESH_NEGATE_VAL = "5" *) 
  (* C_PROG_EMPTY_TYPE = "0" *) 
  (* C_PROG_EMPTY_TYPE_AXIS = "0" *) 
  (* C_PROG_EMPTY_TYPE_RACH = "0" *) 
  (* C_PROG_EMPTY_TYPE_RDCH = "0" *) 
  (* C_PROG_EMPTY_TYPE_WACH = "0" *) 
  (* C_PROG_EMPTY_TYPE_WDCH = "0" *) 
  (* C_PROG_EMPTY_TYPE_WRCH = "0" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_AXIS = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_RACH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_RDCH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WACH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WDCH = "1023" *) 
  (* C_PROG_FULL_THRESH_ASSERT_VAL_WRCH = "1023" *) 
  (* C_PROG_FULL_THRESH_NEGATE_VAL = "1022" *) 
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
  tiny_adc_fast_fifo_fifo_generator_v13_2_5 U0
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
        .overflow(overflow),
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
`pragma protect encoding = (enctype = "BASE64", line_length = 76, bytes = 54336)
`pragma protect data_block
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
tLBkmtpwhei+suFS32zc
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
