`include "includes.v"
`timescale 1 ns / 1 ps
`default_nettype none
/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more
details, or the codebase at http://www.chipwhisperer.com

Copyright (c) 2021, NewAE Technology Inc. All rights reserved.
Author: Jean-Pierre Thibault <jpthibault@newae.com>

  chipwhisperer is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  chipwhisperer is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU Lesser General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with chipwhisperer.  If not, see <http://www.gnu.org/licenses/>.
*************************************************************************/

module cwhusky_top(  
    input wire         clk_usb,

    output wire        LED_ADC, //  LED_CLK1FAIL on schematic,
    output wire        LED_GLITCH, // LED_CLK2FAIL on schematic
    output wire        LED_ARMED,
    output wire        LED_CAP,

    /* FPGA - USB Interface */
    inout wire [7:0]    USB_Data,
    input wire [7:0]    USB_Addr,
    input wire          USB_RDn,
    input wire          USB_WRn,
    input wire          USB_CEn,
    input wire          USB_ALEn,                   // USB_SPARE1
    inout wire          USB_SPARE0,

    input wire          FPGA_BONUS1,
    // currently unused:
    input wire          FPGA_BONUS2,
    input wire          FPGA_BONUS3,
    input wire          FPGA_BONUS4,

    // ADC
    input wire          ADC_clk_fbp,
    input wire          ADC_clk_fbn,
    output wire         ADC_CLKP,
    output wire         ADC_CLKN,
    output wire         ADC_SCLK,
    output wire         ADC_SDATA,
    output wire         ADC_SEN,
    output wire         ADC_RESET,
    output wire         ADC_DFS,
    output wire         ADC_OE,
    input wire          ADC_OVR_SDOUT,
    input wire [5:0]    ADC_DP,
    input wire [5:0]    ADC_DN,

    // VGA
    output wire [4:0]   VMAG_D,
    output wire         VDBSPWM,

    // PLL
    input wire          PLL_STATUS,
    input wire          PLLFPGAP,
    input wire          PLLFPGAN,

    inout  wire [7:0]   USERIO_D,
    inout  wire         USERIO_CLK,

    input wire          FPGA_CDOUT, /* Input FROM SAM3U */
    output wire         FPGA_CDIN, /* Output TO SAM3U */

    input  wire         SAM_MOSI,
    output wire         SAM_MISO,
    input  wire         SAM_SPCK,
    input  wire         SAM_CS, // not used

    /* XMEGA Programming - not used, but need to ensure line is floating */
    inout  wire         target_PDID,
    inout  wire         target_PDIC,

    /* Spare Lines - AVR Programming */
    inout  wire         target_nRST,
    inout  wire         target_MISO,
    inout  wire         target_MOSI,
    inout  wire         target_SCK,

    /* Target IO Interfaces */
    inout wire          target_io4, // Normally trigger
    inout wire          target_io3, // Normally Spare / SmartCard Comms
    inout wire          target_io2, // Normally RXD
    inout wire          target_io1, // Normally TXD / SmartCard Reset
    input wire          target_hs1, // Clock from victim device
    output wire         target_hs2, // Clock to victim device

    output wire         glitchout_highpwr, // high-speed glitch output
    output wire         glitchout_lowpwr, // high-speed glitch output 

    output wire         target_poweron,

    output wire         TRIG_GLITCHOUT, //trigger/glitch out MCX
    inout  wire         AUXIO // AUX I/O MCX
);

    parameter pBYTECNT_SIZE = 7;
    parameter pUSERIO_WIDTH = 8;
    parameter pTRACE_BUFFER_SIZE = 64;
    parameter pTRACE_MATCH_RULES = 8;
`ifdef PLUS
    parameter pSEQUENCER_NUM_TRIGGERS = 4;
`else
    parameter pSEQUENCER_NUM_TRIGGERS = 2;
`endif
    parameter pSEQUENCER_COUNTER_WIDTH = 16;

   wire         target_npower;
   wire         stream_segment_available;

   wire         reg_rst;

   wire clk_usb_buf;
   wire ADC_clk_fb;
   wire pll_fpga_clk;
   wire observer_clk;
   wire observer_locked;

   `ifdef __ICARUS__
      assign clk_usb_buf = clk_usb;
   `else
      IBUFG IBUFG_usb_inst (
         .O(clk_usb_buf),
         .I(clk_usb)
      );
   `endif

   wire cmdfifo_isout;
   wire [7:0] cmdfifo_din;
   wire [7:0] cmdfifo_dout;
   wire [pBYTECNT_SIZE-1:0]  reg_bytecnt;
   wire [7:0]   write_data;
   wire [7:0]   read_data;
   reg  [7:0]   read_data_reg;
   wire         reg_read;
   wire         reg_write;
   wire [7:0]   reg_address;

   wire [7:0] read_data_openadc;
   wire [7:0] read_data_cw;
   wire [7:0] read_data_adc;
   wire [7:0] read_data_glitch;
   wire [7:0] read_data_xadc;
   wire [7:0] read_data_la;
   wire [7:0] read_data_trace;
   always @(posedge clk_usb_buf) read_data_reg <= read_data_openadc | read_data_cw | read_data_adc | read_data_glitch | read_data_xadc | read_data_la | read_data_trace;
   //always @(*) read_data_reg = read_data_openadc | read_data_cw | read_data_adc | read_data_glitch | read_data_xadc | read_data_la;
   assign read_data = (reg_address == `ADCREAD_ADDR)? fifo_dout : read_data_reg;

   wire trigger_capture;
   wire trigger_glitch;
   wire trigger_trace;
   wire extclk_mux;
   wire target_clk;
   wire glitchclk;
   wire glitch_mmcm1_clk_out;
   wire glitch_mmcm2_clk_out;
   wire glitch_enable;
   wire glitch_go;
   wire glitch_trigger;
   wire glitch_trigger_manual_sourceclock;
   wire capture_active;
   wire enable_avrprog;
   wire [11:0] ADC_data;

   wire fifo_error_flag;
   wire xadc_error_flag;
   wire trace_error_flag;
   wire error_flag = fifo_error_flag | xadc_error_flag | trace_error_flag;
   wire fast_fifo_read;

   wire slow_fifo_wr;
   wire slow_fifo_rd;
   wire [7:0] fifo_dout;

   wire [8:0] tu_la_debug;
   wire [7:0] la_debug2;
   wire [7:0] fifo_debug;
   wire [7:0] sequencer_debug;
   wire [4:0] seq_trace_sad_debug;
   wire [7:0] seq_trace_sad_debug2;
   wire [7:0] edge_trigger_debug;
   wire [7:0] clockglitch_debug1;
   wire [7:0] clockglitch_debug2;
   wire [7:0] clockglitch_debug3;

   wire flash_pattern;

   wire userio_fpga_debug;
   wire userio_target_debug;
   wire userio_target_debug_swd;
   wire [3:0] userio_fpga_debug_select;
   wire [pUSERIO_WIDTH-1:0] userio_cwdriven;
   wire [pUSERIO_WIDTH-1:0] userio_drive_data;
   wire [pUSERIO_WIDTH-1:0] userio_drive_data_reg;
   wire [pUSERIO_WIDTH-1:0] userio_debug_data;

   wire uart_trigger_line;
   wire edge_trigger_line;
   wire decodeio_active;
   wire trace_active;
   wire trace_trigger_in_use;
   wire sad_active;
   wire edge_trigger_active;
   wire adc_trigger_active;
   wire trace_trig_out;
   wire trigger_adc;
   wire trigger_sad;
   wire trigger_edge_counter;
   wire trace_trig_out_adc;

   wire la_exists;
   wire trace_exists;

   wire           fifo_full;
   wire           fifo_overflow_blocked;
   wire [17:0]    fifo_in_data;
   wire           fifo_wr;
   wire           fifo_read;
   wire           fifo_flush;
   wire           trace_fifo_flush;
   wire           la_fifo_flush;
   wire           trace_arm_usb;
   wire           trace_arm_fe;
   wire           clear_errors;
   wire [17:0]    fifo_out_data;
   wire [5:0]     fifo_status;
   wire           fifo_empty;
   wire           trace_fifo_error_flag;
   wire           synchronized;
   wire           la_clear_read_flags;
   wire           la_clear_write_flags;
   wire           fifo_clear_read_flags;
   wire           fifo_clear_write_flags;

   wire           trace_fifo_wr;
   wire           la_fifo_wr;
   wire [17:0]    trace_wr_data;
   wire [17:0]    la_wr_data;
   wire           fifo_wr_clk;
   wire           fifo_source_sel;

   wire           cmd_arm_usb;
   wire           armed_and_ready;

   assign USB_SPARE0 = enable_avrprog? 1'bz : stream_segment_available;

   usb_reg_main #(
      .pBYTECNT_SIZE    (pBYTECNT_SIZE)
   ) U_usb_reg_main (
      .clk_usb          (clk_usb_buf), 
      .reset            (reg_rst),
      .cwusb_din        (cmdfifo_din), 
      .cwusb_dout       (cmdfifo_dout), 
      .cwusb_rdn        (USB_RDn), 
      .cwusb_wrn        (USB_WRn),
      .cwusb_cen        (USB_CEn),
      .cwusb_alen       (USB_ALEn),
      .cwusb_addr       (USB_Addr),
      .cwusb_isout      (cmdfifo_isout), 
      .fast_fifo_read   (fast_fifo_read),
      .reg_address      (reg_address), 
      .reg_bytecnt      (reg_bytecnt), 
      .reg_datao        (write_data), 
      .reg_datai        (read_data),
      .reg_read         (reg_read), 
      .reg_write        (reg_write) 
   );

   wire [7:0] usb_debug1 = { USB_RDn,           // D7
                             USB_WRn,           // D6
                             USB_CEn,           // D5
                             clk_usb_buf,       // D4
                             USB_Data[7:4]      // D3:0
                           };

   wire [7:0] usb_debug2 = { USB_RDn,           // D7
                             USB_WRn,           // D6
                             USB_CEn,           // D5
                             clk_usb_buf,       // D4
                             USB_Data[3:0]      // D3:0
                           };

   /*
   wire [7:0] usb_debug2 = { USB_RDn,           // D7
                             USB_WRn,           // D6
                             USB_CEn,           // D5
                             clk_usb_buf,       // D4
                             reg_read,          // D3
                             reg_write,         // D2
                             USB_Addr[1:0]      // D1:0
                           };
   */

   wire [7:0] usb_debug3 = { reg_write,         // D7
                             USB_Data[6:0]      // D6:0
                           };



   `ifdef USERIO_DEBUG
      // synthesize slower debug signals, so that slower logic analyzers can catch them:
      wire reg_read_slow;
      wire slow_fifo_wr_slow;
      wire slow_fifo_rd_slow;

      slow_debug U_slow_reg_read (
         .clk           (clk_usb_buf),
         .I_fast        (reg_read),
         .O_slow        (reg_read_slow)
      );

      slow_debug U_slow_fifo_wr (
         .clk           (ADC_clk_fb),
         .I_fast        (slow_fifo_wr),
         .O_slow        (slow_fifo_wr_slow)
      );

      slow_debug U_slow_fifo_rd (
         .clk           (clk_usb_buf),
         .I_fast        (slow_fifo_rd),
         .O_slow        (slow_fifo_rd_slow)
      );

      assign userio_debug_data = (userio_fpga_debug_select == 4'b0000)? {glitch_enable,
                                                                         glitchclk,
                                                                         fifo_error_flag,
                                                                         fast_fifo_read,
                                                                         reg_read_slow,
                                                                         slow_fifo_rd_slow,
                                                                         slow_fifo_wr_slow,
                                                                         stream_segment_available} :
                                 (userio_fpga_debug_select == 4'b0001)? tu_la_debug[7:0] :
                                 (userio_fpga_debug_select == 4'b0010)? fifo_debug : 
                                 (userio_fpga_debug_select == 4'b0011)? {1'b0,
                                                                         xadc_error_flag,
                                                                         glitch_mmcm1_clk_out,
                                                                         glitch_mmcm2_clk_out,
                                                                         glitchclk,
                                                                         glitch_enable,
                                                                         trigger_capture,
                                                                         cmd_arm_usb} :
                                 (userio_fpga_debug_select == 4'b0100)?  clockglitch_debug1 : 
                                 (userio_fpga_debug_select == 4'b0101)?  clockglitch_debug2 :
                                 (userio_fpga_debug_select == 4'b0110)?  usb_debug1 :
                                 (userio_fpga_debug_select == 4'b0111)?  usb_debug2 : 
                                 (userio_fpga_debug_select == 4'b1000)?  usb_debug3 :
                                 (userio_fpga_debug_select == 4'b1001)?  edge_trigger_debug :
                                 (userio_fpga_debug_select == 4'b1010)?  {cmd_arm_usb, clockglitch_debug3[6:0]} :
                                 (userio_fpga_debug_select == 4'b1011)?  {edge_trigger_line,
                                                                         target_io4,
                                                                         uart_trigger_line,
                                                                         trigger_sad,
                                                                         trace_trig_out,
                                                                         trigger_adc,
                                                                         trigger_edge_counter,
                                                                         cmd_arm_usb} : 
                                 (userio_fpga_debug_select == 4'b1100)?  la_debug2 : 
                                 (userio_fpga_debug_select == 4'b1101)?  sequencer_debug :
                                 (userio_fpga_debug_select == 4'b1110)?  {seq_trace_sad_debug, 3'b0} : seq_trace_sad_debug2;
                                 //(userio_fpga_debug_select == 4'b1010)?  clockglitch_debug3 : 8'b0;

   `else
      assign userio_debug_data[7:0] = 8'bz;
   `endif

   assign USB_Data = cmdfifo_isout ? cmdfifo_dout : 8'bZ;
   assign cmdfifo_din = USB_Data;


   wire led_glitch;
   wire cw_led_cap;
   wire cw_led_armed;
   wire trace_en;
   wire trace_capture_on;
   wire [7:0] trace_userio_dir;
   wire freq_measure;
   wire clear_adc_error;
   wire disable_adc_error;
   reg PLL_STATUS_reg = 1'b1;

   // fast-flash red LEDs when some internal error has occurred:
   assign LED_ADC = (error_flag)? flash_pattern : ~PLL_STATUS_reg;
   assign LED_GLITCH = error_flag? flash_pattern : led_glitch;
   assign LED_CAP = cw_led_cap;
   assign LED_ARMED = cw_led_armed;

   always @(posedge clk_usb_buf) begin
       if (clear_adc_error || disable_adc_error)
           PLL_STATUS_reg <= 1'b1;
       else if (~PLL_STATUS) // make it sticky!
           PLL_STATUS_reg <= 1'b0;
   end

   openadc_interface #(
        .pBYTECNT_SIZE  (pBYTECNT_SIZE)
   ) oadc (
        .clk_usb                (clk_usb_buf),
        .ADC_slow_clk_even      (ADC_slow_clk_even),
        .ADC_slow_clk_odd       (ADC_slow_clk_odd),
        .reset_o                (reg_rst),
        .xadc_error             (xadc_error_flag),

        .LED_capture            (cw_led_cap),
        .LED_armed              (cw_led_armed),
        .O_clear_adc_error      (clear_adc_error),
        .O_disable_adc_error    (disable_adc_error),
        .ADC_data               (ADC_data),
        .ADC_clk_feedback       (ADC_clk_fb),
        .pll_fpga_clk           (pll_fpga_clk),
        .PLL_STATUS             (PLL_STATUS),
        .DUT_CLK_i              (extclk_mux),
        .DUT_trigger_i          (trigger_capture),
        .trigger_io4_i          (target_io4),
        .trigger_adc            (trigger_adc),
        .trigger_sad            (trigger_sad),
        .trigger_edge_counter   (trigger_edge_counter),
        .sad_active             (sad_active),
        .edge_trigger_active    (edge_trigger_active),
        .adc_trigger_active     (adc_trigger_active),
        .amp_gain               (VDBSPWM),
        .fifo_dout              (fifo_dout),
        .cmd_arm_usb            (cmd_arm_usb),
        .armed_and_ready        (armed_and_ready),
        .freq_measure           (freq_measure),

        .reg_address            (reg_address),
        .reg_bytecnt            (reg_bytecnt), 
        .reg_datao              (read_data_openadc), 
        .reg_datai              (write_data), 
        .reg_read               (reg_read), 
        .reg_write              (reg_write), 
        .fast_fifo_read         (fast_fifo_read),

        .fifo_error_flag        (fifo_error_flag),
        .stream_segment_available (stream_segment_available),

        .capture_active         (capture_active),
        .trigger_in             (edge_trigger_line),

        .flash_pattern          (flash_pattern),

     // TODO-later: use `ifdef PRO for these
        .O_xo_en                (),
        .O_vddr_enable          (),
        .I_vddr_pgood           (1'b0),
        .temp_out               (12'b0),

        .ddr3_addr              (),
        .ddr3_ba                (),
        .ddr3_cas_n             (),
        .ddr3_ck_n              (),
        .ddr3_ck_p              (),
        .ddr3_cke               (),
        .ddr3_ras_n             (),
        .ddr3_reset_n           (),
        .ddr3_we_n              (),
        .ddr3_dq                (),
        .ddr3_dqs_n             (),
        .ddr3_dqs_p             (),
        .ddr3_dm                (),
        .ddr3_cs_n              (),
        .ddr3_odt               (),
        // CW310-specific:
        .ADC_clk_fbp            (1'b0),
        .ADC_clk_fbn            (1'b0),

        .slow_fifo_wr           (slow_fifo_wr),
        .slow_fifo_rd           (slow_fifo_rd),
        .la_debug2              (la_debug2),
        .la_debug               (tu_la_debug),
        .edge_trigger_debug     (edge_trigger_debug),
        .fifo_debug             (fifo_debug)

   );

   wire enable_output_nrst;
   wire output_nrst;
   wire enable_output_pdid;
   wire output_pdid;
   wire enable_output_pdic;
   wire output_pdic;

   reg_husky_adc #(
        .pBYTECNT_SIZE  (pBYTECNT_SIZE)
   ) U_reg_husky_adc (
        .reset_i        (reg_rst),
        .clk_usb        (clk_usb_buf),
        .reg_address    (reg_address),
        .reg_datao      (read_data_adc), 
        .reg_datai      (write_data), 
        .reg_read       (reg_read), 
        .reg_write      (reg_write), 

        .ADC_RESET      (ADC_RESET    ),
        .ADC_SDATA      (ADC_SDATA    ),
        .ADC_SEN        (ADC_SEN      ),
        .ADC_DFS        (ADC_DFS      ),
        .ADC_OE         (ADC_OE       ),
        .ADC_SCLK       (ADC_SCLK     ),
        .ADC_OVR_SDOUT  (ADC_OVR_SDOUT),
        .VMAG_D         (VMAG_D)
   );


   reg_chipwhisperer  #(
        .pBYTECNT_SIZE                  (pBYTECNT_SIZE),
        .pUSERIO_WIDTH                  (pUSERIO_WIDTH),
        .pSEQUENCER_NUM_TRIGGERS        (pSEQUENCER_NUM_TRIGGERS  ),
        .pSEQUENCER_COUNTER_WIDTH       (pSEQUENCER_COUNTER_WIDTH )
   ) reg_chipwhisperer (
        .reset_i                (reg_rst),
        .clk_usb                (clk_usb_buf),
        .reg_address            (reg_address),
        .reg_bytecnt            (reg_bytecnt), 
        .reg_datao              (read_data_cw), 
        .reg_datai              (write_data), 
        .reg_read               (reg_read), 
        .reg_write              (reg_write), 

        .auxio                  (AUXIO),
        .target_hs1             (target_hs1),
        .target_hs2             (target_hs2),
        .extclk_o               (extclk_mux),
        .target_clk             (target_clk),
        .trigger_io1_i          (target_io1),
        .trigger_io2_i          (target_io2),
        .trigger_io3_i          (target_io3),
        .trigger_io4_i          (target_io4),
        .trigger_nrst_i         (target_nRST),
        .uart_trigger_line      (uart_trigger_line),
        .edge_trigger_line      (edge_trigger_line),
        .decodeio_active        (decodeio_active),
        .trace_active           (trace_active),
        .trace_trigger_in_use   (trace_trigger_in_use),
        .sad_active             (sad_active),
        .edge_trigger_active    (edge_trigger_active),
        .adc_trigger_active     (adc_trigger_active),
        .trigger_advio_i        (1'b0),
        .trigger_decodedio_i    (trace_trig_out),
        .trigger_trace_i        (trace_trig_out),
        .trigger_adc_i          (trigger_adc),
        .trigger_sad_i          (trigger_sad),
        .trigger_edge_i         (trigger_edge_counter),
        .pll_fpga_clk           (pll_fpga_clk),
        .glitchclk              (glitchclk),
        .glitch_mmcm1_clk_out   (glitch_mmcm1_clk_out),
        .adc_sample_clk         (ADC_clk_fb),
        .trace_fe_clk           (fe_clk),

        .targetio1_io           (target_io1),
        .targetio2_io           (target_io2),
        .targetio3_io           (target_io3),
        .targetio4_io           (target_io4),

        .target_PDID            (target_PDID),
        .target_PDIC            (target_PDIC),
        .target_nRST            (target_nRST),
        .target_MISO            (target_MISO),
        .target_MOSI            (target_MOSI),
        .target_SCK             (target_SCK),

        .hsglitcha_o            (glitchout_highpwr),
        .hsglitchb_o            (glitchout_lowpwr),

        .enable_avrprog         (enable_avrprog),

        .enable_output_nrst     (enable_output_nrst),
        .output_nrst            (output_nrst),
        .enable_output_pdid     (enable_output_pdid),
        .output_pdid            (output_pdid),
        .enable_output_pdic     (enable_output_pdic),
        .output_pdic            (output_pdic),

        .uart_tx_i              (FPGA_CDOUT),
        .uart_rx_o              (FPGA_CDIN),
        .targetpower_off        (target_npower),

        .trace_en               (trace_en),
        .trace_userio_dir       (trace_userio_dir),
        .userio_cwdriven        (userio_cwdriven),
        .userio_drive_data      (userio_drive_data_reg),
        .userio_fpga_debug      (userio_fpga_debug),
        .userio_target_debug    (userio_target_debug),
        .userio_target_debug_swd(userio_target_debug_swd),
        .userio_fpga_debug_select (userio_fpga_debug_select),
        .userio_d               (USERIO_D),
        .userio_clk             (USERIO_CLK),

        .trace_exists           (trace_exists),
        .la_exists              (la_exists),

        .cw310_adc_clk_sel      (), // CW310 only

        .sequencer_debug        (sequencer_debug),
        .sequencer_debug2       (seq_trace_sad_debug2),
        .seq_trace_sad_debug    (seq_trace_sad_debug),

        .armed_and_ready        (armed_and_ready),
        .trigger_capture        (trigger_capture),
        .trigger_glitch         (trigger_glitch),
        .trigger_trace          (trigger_trace),
        .trig_glitch_o_mcx      (TRIG_GLITCHOUT)
   );

   assign userio_drive_data = userio_target_debug? {target_MOSI, // carries TDI on USERIO_D7
                                                    target_PDID, // carries TMS/SWDIO on USERIO_D6
                                                    target_SCK,  // carries TCLK/SWDCLK on USERIO_D5
                                                    5'b0         // USERIO_D4:D0 undriven (TDO input on USERIO_D3)
                                                   } : userio_drive_data_reg;

   assign USERIO_CLK = userio_target_debug? FPGA_BONUS1 : 1'bz;

   userio #(
      .pWIDTH                   (pUSERIO_WIDTH)
   ) U_userio (
      .usb_clk                  (clk_usb_buf),
      .userio_d                 (USERIO_D),
      .userio_clk               (USERIO_CLK),
      .I_userio_cwdriven        (userio_cwdriven),
      .I_userio_fpga_debug      (userio_fpga_debug),
      .I_userio_drive_data      (userio_drive_data),
      .I_userio_debug_data      (userio_debug_data)
   );


`ifndef SAD_ONLY
   reg_clockglitch #(
        .pBYTECNT_SIZE  (pBYTECNT_SIZE)
   ) reg_clockglitch (
        .reset          (reg_rst),
        .clk_usb        (clk_usb_buf),
        .reg_address    (reg_address),
        .reg_bytecnt    (reg_bytecnt), 
        .reg_datao      (read_data_glitch), 
        .reg_datai      (write_data), 
        .reg_read       (reg_read), 
        .reg_write      (reg_write), 
        .mmcm_shutdown  (xadc_error_flag),
        .target_clk     (extclk_mux),
        .pll_fpga_clk   (pll_fpga_clk),
        .glitchclk      (glitchclk),
        .glitch_mmcm1_clk_out (glitch_mmcm1_clk_out),
        .glitch_mmcm2_clk_out (glitch_mmcm2_clk_out),
        .glitch_enable  (glitch_enable),
        .exttrigger     (trigger_glitch),
        .glitch_go      (glitch_go),
        .glitch_trigger (glitch_trigger),
        .glitch_trigger_manual_sourceclock (glitch_trigger_manual_sourceclock),
        .led_glitch     (led_glitch),
        .debug1         (clockglitch_debug1),
        .debug2         (clockglitch_debug2),
        .debug3         (clockglitch_debug3)
   );

   `ifdef LOGIC_ANALYZER
   // NOTE: while this block is ifdef'd, building without LOGIC_ANALYZER
   // and/or TRACE isn't tested and may not work. Think of this as just
   // a start towards selectively enabling components.
   assign la_exists = 1;
   reg_la #(
        .pBYTECNT_SIZE  (pBYTECNT_SIZE)
   ) reg_la (
        .reset                  (reg_rst),
        .clk_usb                (clk_usb_buf),
        .reg_address            (reg_address),
        .reg_bytecnt            (reg_bytecnt), 
        .reg_datao              (read_data_la), 
        .reg_datai              (write_data), 
        .reg_read               (reg_read), 
        .reg_write              (reg_write), 
        .target_clk             (extclk_mux),
        .pll_fpga_clk           (pll_fpga_clk),
        .observer_clk           (observer_clk),
        .observer_locked        (observer_locked),
        .mmcm_shutdown          (xadc_error_flag),
        .I_trace_en             (trace_en),
        .O_enabled              (), // PRO only
        .O_4bit_mode            (), // TODO!
        .freq_measure           (freq_measure),

        .glitchclk              (glitchclk),
        .glitch_mmcm1_clk_out   (glitch_mmcm1_clk_out),
        .glitch_mmcm2_clk_out   (glitch_mmcm2_clk_out),
        .glitch_enable          (glitch_enable),
        .io1                    (target_io1),
        .io2                    (target_io2),
        .io3                    (target_io3),
        .io4                    (target_io4),
        .hs1                    (target_hs1),
        .hs2                    (target_hs2),
        .aux_mcx                (AUXIO),
        .trig_mcx               (TRIG_GLITCHOUT),
        .adc_sample_clk         (ADC_clk_fb),
        .userio0                (USERIO_D[0]),
        .userio1                (USERIO_D[1]),
        .userio2                (USERIO_D[2]),
        .userio3                (USERIO_D[3]),
        .userio4                (USERIO_D[4]),
        .userio5                (USERIO_D[5]),
        .userio6                (USERIO_D[6]),
        .userio7                (USERIO_D[7]),
        .userio_clk             (USERIO_CLK),
        .trigger_glitch         (trigger_glitch),

        .clockglitch_debug      (clockglitch_debug3),
        .tu_la_debug            (tu_la_debug),
        .trace_data             (trace_data_sdr),
        .trace_debug            (trace_debug),
        .trace_fe_clk           (fe_clk),

        .glitch_go              (glitch_go),
        .glitch_trigger_manual_sourceclock (glitch_trigger_manual_sourceclock),
        .glitch_trigger         (glitch_trigger),
        .capture_active         (capture_active),
        .capture_start          (), // unused
        .capture_done           (), // unused

        .fifo_wr                (la_fifo_wr),
        .fifo_wr_data           (la_wr_data),
        .fifo_flush             (la_fifo_flush),
        .fifo_empty             (fifo_empty),
        .fifo_clear_read_flags  (la_clear_read_flags),
        .fifo_clear_write_flags (la_clear_write_flags)
   );
   `else
       assign read_data_la = 0;
       assign la_exists = 0;
   `endif
`endif // SAD_ONLY

   wire target_highz = target_npower;
   assign target_poweron = ~target_npower;

   assign target_PDID = (target_highz) ? 1'bZ :
                        (userio_target_debug & userio_target_debug_swd & ~USERIO_CLK) ? USERIO_D[6] :
                        (enable_output_pdid) ? output_pdid : 1'bZ;

   assign target_PDIC = (target_highz) ? 1'bZ:
                        (enable_output_pdic) ? output_pdic : 1'bZ;

   assign target_nRST = (target_highz) ? 1'bZ :
                        (enable_avrprog) ? ( (USB_SPARE0)? 1'bz : 1'b0 )  :
                        (enable_output_nrst) ? output_nrst : 1'bZ;

   assign target_MOSI = (target_highz) ? 1'bZ :
                        (enable_avrprog) ? SAM_MOSI : 1'bZ;

   assign target_SCK = (target_highz) ? 1'bZ :
                       (enable_avrprog) ? SAM_SPCK : 1'bZ;

   assign SAM_MISO = (userio_target_debug)? USERIO_D[3] :
                     (enable_avrprog) ? target_MISO : 1'bZ;


   // generate ADC output differential clock
   `ifdef __ICARUS__
      assign ADC_CLKP = extclk_mux;
      assign ADC_CLKN = extclk_mux;

   `else
      wire adc_clk_out_oddr;
      ODDR  #(
         .DDR_CLK_EDGE     ("OPPOSITE_EDGE"),
         .INIT             (1'b0),
         .SRTYPE           ("SYNC")
      ) U_ODDR_adc_clk_out (
         .Q                (adc_clk_out_oddr),
         .C                (extclk_mux),
         .CE               (1'b1),
         .D1               (1'b1),
         .D2               (1'b0),
         .R                (1'b0),
         .S                (1'b0)
      );

      OBUFDS #(
         .IOSTANDARD       ("LVDS_25"),
         .SLEW             ("FAST")
      ) U_OBUFDS_adc_clk_out (
         .O                (ADC_CLKP),
         .OB               (ADC_CLKN),
         .I                (adc_clk_out_oddr)
      );
   `endif


   // take in ADC input differential clock
   `ifdef __ICARUS__
      assign ADC_clk_fb = ADC_clk_fbp;

      // for SAD:
      reg ADC_slow_clk_even = 1'b0;
      reg ADC_slow_clk_odd  = 1'b1;
      always @(posedge ADC_clk_fb) ADC_slow_clk_even <= ~ADC_slow_clk_even;
      always @(posedge ADC_clk_fb) ADC_slow_clk_odd  <= ~ADC_slow_clk_odd;

   `else
      wire ADC_clk_fb_prebuf;
      IBUFDS #(
         .DIFF_TERM        ("FALSE"),
         .IBUF_LOW_PWR     ("FALSE"),
         .IOSTANDARD       ("LVDS_25")
      ) U_IBUFDS_adc_clk_fb (
         .I                (ADC_clk_fbp),
         .IB               (ADC_clk_fbn),
         .O                (ADC_clk_fb_prebuf)
      );

      BUFG BUFG_adc_clk (
         .O(ADC_clk_fb),
         .I(ADC_clk_fb_prebuf)
      );

      `ifdef SAD_X2
          // for SAD:
          // reference: https://support.xilinx.com/s/question/0D52E00006hpe4DSAQ/how-to-divide-a-clock-by-2-with-a-simple-primitive-without-clock-wizard-artix7?language=en_US)
          // except they suggest sourcing the BUFGCE input clock from the BUFG_adc_clk *input*, but Vivado doesn't recognize that as a clock,
          // so we're using the output instead...
          wire ADC_slow_clk_even;
          wire ADC_slow_clk_odd;
          reg bufgce_count = 1'b0;
          always @(posedge ADC_clk_fb) bufgce_count <= ~bufgce_count;
          BUFGCE U_slow_adc_even (
              //.I    (ADC_clk_fb_prebuf),
              .I    (ADC_clk_fb),
              .CE   (bufgce_count),
              .O    (ADC_slow_clk_even)
          );
          BUFGCE U_slow_adc_odd (
              //.I    (ADC_clk_fb_prebuf),
              .I    (ADC_clk_fb),
              .CE   (~bufgce_count),
              .O    (ADC_slow_clk_odd)
          );
      `else
          wire ADC_slow_clk_even = 1'b0;
          wire ADC_slow_clk_odd = 1'b0;
      `endif

   `endif


   // take in PLL input differential clock
   `ifdef __ICARUS__
      assign pll_fpga_clk = PLLFPGAP;

   `else
      IBUFDS #(
         .DIFF_TERM        ("FALSE"),
         .IBUF_LOW_PWR     ("FALSE"),
         .IOSTANDARD       ("LVDS_25")
      ) U_IBUFDS_pll_fpga_clk (
         .I                (PLLFPGAP),
         .IB               (PLLFPGAN),
         .O                (pll_fpga_clk)
      );
   `endif



   `ifdef __ICARUS__
      assign ADC_data = {ADC_DP, ADC_DN};
   `else
   wire [5:0] ADC_D;
   wire [5:0] ADC_D_delayed;

   `ifdef ADC_IDELAY
       IDELAYCTRL U_idelayctrl (
           .RST          (reg_rst),
           .REFCLK       (ADC_clk_fb),
           .RDY          ()
       );
   `endif

   genvar adc_index;
   generate 
      for (adc_index = 0; adc_index < 6; adc_index = adc_index + 1) begin: gen_adc_data
         IBUFDS #(
            .DIFF_TERM          ("FALSE"),
            .IBUF_LOW_PWR       ("FALSE"),
            .IOSTANDARD         ("LVDS_25")
         ) U_adc_ibufds (
            .O                  (ADC_D[adc_index]),
            .I                  (ADC_DP[adc_index]),
            .IB                 (ADC_DN[adc_index])
         );

         `ifdef ADC_IDELAY
             IDELAYE2 #(
                 .CINVCTRL_SEL              ("FALSE"), // Enable dynamic clock inversion (FALSE, TRUE)
                 .DELAY_SRC                 ("IDATAIN"), // Delay input (IDATAIN, DATAIN)
                 .HIGH_PERFORMANCE_MODE     ("TRUE"), // Reduced jitter ("TRUE"), Reduced power ("FALSE")
                 .IDELAY_TYPE               ("FIXED"), // FIXED, VARIABLE, VAR_LOAD, VAR_LOAD_PIPE
                 //.IDELAY_VALUE              (9), // Input delay tap setting (0-31); 9 x 78ps = 0.702 ns
                 .IDELAY_VALUE              (4), // Input delay tap setting (0-31); 9 x 78ps = 0.702 ns
                 .PIPE_SEL                  ("FALSE"), // Select pipelined mode, FALSE, TRUE
                 .REFCLK_FREQUENCY          (200.0), // IDELAYCTRL clock input frequency in MHz (190.0-210.0, 290.0-310.0).
                 .SIGNAL_PATTERN            ("DATA") // DATA, CLOCK input signal
             )
             IDELAYE2_inst (
                 .CNTVALUEOUT               (), // 5-bit output: Counter value output
                 .DATAOUT                   (ADC_D_delayed[adc_index]), // 1-bit output: Delayed data output
                 .C                         (1'b0), // 1-bit input: Clock input
                 .CE                        (1'b0), // 1-bit input: Active high enable increment/decrement input
                 .CINVCTRL                  (1'b0), // 1-bit input: Dynamic clock inversion input
                 .CNTVALUEIN                (5'b0), // 5-bit input: Counter value input
                 .DATAIN                    (1'b0), // 1-bit input: Internal delay data input
                 .IDATAIN                   (ADC_D[adc_index]), // 1-bit input: Data input from the I/O
                 .INC                       (1'b0), // 1-bit input: Increment / Decrement tap delay input
                 .LD                        (1'b0), // 1-bit input: Load IDELAY_VALUE input
                 .LDPIPEEN                  (1'b0), // 1-bit input: Enable PIPELINE register to load data input
                 .REGRST                    (1'b0) // 1-bit input: Active-high reset tap-delay input
             );
         `else
             assign ADC_D_delayed = ADC_D;
         `endif

         IDDR #(
            .DDR_CLK_EDGE     ("OPPOSITE_EDGE"),
            .INIT_Q1          (0),
            .INIT_Q2          (0),
            .SRTYPE           ("SYNC")
         ) U_adc_iddr (
            .Q1               (ADC_data[adc_index*2]),
            .Q2               (ADC_data[adc_index*2+1]),
            .D                (ADC_D_delayed[adc_index]),
            .CE               (1'b1),
            .C                (ADC_clk_fb),
            .S                (1'b0),
            .R                (1'b0)
         );
      end
   endgenerate
   `endif

   `ifdef XADC_EN
       xadc #(
          .pBYTECNT_SIZE    (pBYTECNT_SIZE)
       ) U_xadc (
          .reset_i          (reg_rst),
          .clk_usb          (clk_usb_buf),
          .reg_address      (reg_address), 
          .reg_bytecnt      (reg_bytecnt), 
          .reg_datao        (read_data_xadc), 
          .reg_datai        (write_data), 
          .reg_read         (reg_read), 
          .reg_write        (reg_write), 
          .O_xadc_temp_out  (), // PRO only
          .xadc_error       (xadc_error_flag)
       ); 

   `else
      assign read_data_xadc = 0;
      assign xadc_error_flag = 0;
   `endif

   wire [7:0] trace_data_sdr;
   wire [8:0] trace_debug;
   wire fe_clk;

`ifndef SAD_ONLY
   `ifdef TRACE

       wire TRACECLOCK = USERIO_CLK;
       wire [3:0] TRACEDATA  = USERIO_D[7:4];

       // here we choose trace_top's serial input: either SWO (USERIO_D[2]) or
       // the chosen UART trigger line; also, ensure that the line is held
       // high if it's not meant to see anything (e.g. in the case of
       // sequenced triggers, when it's not its turn)
       reg serial_in;
       always @ (*) begin
           if (decodeio_active)
               serial_in = uart_trigger_line;
           else if (trace_en) begin
               if (trace_trigger_in_use)
                   serial_in = (trace_active)? USERIO_D[2] : 1'b1;
               else
                   serial_in = USERIO_D[2];
           end
           else
               serial_in = 1'b1;
       end

       reg [22:0] count_fe_clock;
       always @(posedge fe_clk) count_fe_clock <= count_fe_clock + 1;
       assign trace_exists = 1;

       trace_top #(
          .pBYTECNT_SIZE                (pBYTECNT_SIZE),
          .pBUFFER_SIZE                 (pTRACE_BUFFER_SIZE),
          .pMATCH_RULES                 (pTRACE_MATCH_RULES),
          .pUSERIO_WIDTH                (1),
          .pMAIN_REG_SELECT             (`TW_MAIN_REG_SELECT),
          .pTRACE_REG_SELECT            (`TW_TRACE_REG_SELECT),
          .pREGISTERED_READ             (0),
          .pNUM_TRIGGER_WIDTH           (16)
       ) U_trace_top (
          .trace_clk_in                 (TRACECLOCK),
          .fe_clk                       (fe_clk),
          .usb_clk                      (clk_usb_buf),
          .fifo_rd_clk                  (clk_usb_buf),
          .reset_pin                    (reg_rst),
          .fpga_reset                   (),
          .I_external_arm               (cmd_arm_usb),
          .flash_pattern                (),
          .buildtime                    (32'b0),
          .O_trace_en                   (trace_en),
          .O_trace_capture_on           (trace_capture_on),
          .O_trace_userio_dir           (trace_userio_dir),
          .mmcm_shutdown                (xadc_error_flag),

          .trace_data                   (TRACEDATA),
          .swo                          (serial_in),
          .O_trace_trig_out             (trace_trig_out),
          .m3_trig                      (trigger_trace),
          .O_soft_trig_passthru         (),     // N/A, used for CW305 DST only

          .target_clk                   (target_clk),
          .I_fe_clock_count             (count_fe_clock),

          .trigger_clk                  (observer_clk),
          .trigger_clk_locked           (observer_locked),
          // in Husky, trigger_clk is generated and controlled in reg_la.v:
          .trigger_clk_psen             (),
          .trigger_clk_psincdec         (),
          .trigger_clk_psdone           (1'b0),
          .trig_drp_addr                (),
          .trig_drp_den                 (),
          .trig_drp_din                 (),
          .trig_drp_dout                (16'b0),
          .trig_drp_dwe                 (),
          .trig_drp_reset               (),

          `ifdef __ICARUS__
          .I_trace_sdr                  (8'b0),
          `endif
                                                  
          .USB_nCS                      (USB_CEn  ),

          // for CW610-style faster FIFO reading: not needed here since we
          // don't need streaming, and if we did it would make more sense to
          // do it as it's done for the ADC samples:
          .O_data_available             (),
          .I_fast_fifo_rdn              (1'b0),
          .usb_drive_data               (),

          .reg_address                  (reg_address),
          .reg_bytecnt                  (reg_bytecnt), 
          .write_data                   (write_data), 
          .read_data                    (read_data_trace),
          .reg_read                     (reg_read), 
          .reg_write                    (reg_write), 
          .reg_addrvalid                (1'b1),

          .O_led_select                 (),
          .O_error_flag                 (trace_error_flag),

          // in Husky, these are controlled by userio module instead:
          .userio_d                     (1'b0),
          .O_userio_pwdriven            (),
          .O_userio_drive_data          (),

          .arm_usb                      (trace_arm_usb),
          .arm_fe                       (trace_arm_fe),
          .capturing                    (),
          .capture_start                (),  // PRO only
          .capture_done                 (),  // PRO only

          .fifo_full                    (fifo_full),
          .fifo_overflow_blocked        (fifo_overflow_blocked),
          .fifo_in_data                 (trace_wr_data),
          .fifo_wr                      (trace_fifo_wr),
                                               
          .fifo_read                    (fifo_read),
          .fifo_flush                   (trace_fifo_flush),
          .clear_errors                 (clear_errors),
                                               
          .fifo_out_data                (fifo_out_data),
          .fifo_status                  (fifo_status),
          .fifo_empty                   (fifo_empty),
          .fifo_error_flag              (trace_fifo_error_flag),

          .trace_debug                  (trace_debug),
          .trace_data_sdr               (trace_data_sdr),
          .synchronized                 (synchronized)
       );

       cdc_pulse U_trace_trig_cdc (
          .reset_i       (reg_rst),
          .src_clk       (fe_clk),
          .src_pulse     (trace_trig_out),
          .dst_clk       (ADC_clk_fb),
          .dst_pulse     (trace_trig_out_adc)
       );

   `else
      assign read_data_trace = 0;
      assign trace_error_flag = 0;
      assign trace_trig_out = 0;
      assign trace_trig_out_adc = 0;
      assign trace_exists = 0;
      assign trace_data_sdr = 0;
      assign fe_clk = 0;

   `endif

   // fifo_source_sel controls FIFO acccess.
   // 0: trace
   // 1: LA
   // In order to capture LA, trace must be disabled (REG_TRACE_EN) *or* its
   // capture mode set to "off"
   assign fifo_source_sel = ~trace_capture_on; 
   `ifdef __ICARUS__
       assign fifo_wr_clk = fifo_source_sel? observer_clk : fe_clk;
   `else
       BUFGMUX #(
          .CLK_SEL_TYPE("ASYNC")
       ) U_fifo_clk_mux (
          .O    (fifo_wr_clk),
          .I0   (fe_clk),
          .I1   (observer_clk),
          .S    (fifo_source_sel)
       );
   `endif
   assign fifo_in_data = fifo_source_sel? la_wr_data : trace_wr_data;
   assign fifo_wr = fifo_source_sel? la_fifo_wr : trace_fifo_wr;

   assign fifo_flush = trace_fifo_flush || la_fifo_flush;

   assign fifo_clear_read_flags = trace_arm_usb || la_clear_read_flags;
   assign fifo_clear_write_flags = trace_arm_fe || la_clear_write_flags;

   // NOTE: this FIFO is shared by LOGIC_ANALYZER and TRACE.
   // There are no other ifdef's around it, as per the note above in the
   // LOGIC_ANALYZER block.
   fifo U_fifo (
      .reset_i                  (reg_rst),
      .cwusb_clk                (clk_usb_buf),
      .fe_clk                   (fifo_wr_clk),

      .O_fifo_full              (fifo_full),
      .O_fifo_overflow_blocked  (fifo_overflow_blocked),
      .I_data                   (fifo_in_data),
      .I_wr                     (fifo_wr),

      .I_fifo_read              (fifo_read),
      .I_fifo_flush             (fifo_flush),
      .I_clear_read_flags       (fifo_clear_read_flags),
      .I_clear_write_flags      (fifo_clear_write_flags),
      .I_clear_errors           (clear_errors),

      .O_data                   (fifo_out_data),
      .O_fifo_status            (fifo_status),
      .O_fifo_empty             (fifo_empty),
      .O_error_flag             (trace_fifo_error_flag),

      .I_custom_fifo_stat_flag  (synchronized)      
   );

`ifdef ILA_SHARED_FIFO
    ila_shared_fifo U_ila_shared_fifo (
       .clk            (clk_usb_buf),          // input wire clk
       .probe0         (fifo_wr),              // input wire [0:0]  probe0 
       .probe1         (fifo_full),            // input wire [0:0]  probe1 
       .probe2         (fifo_overflow_blocked),// input wire [0:0]  probe2 
       .probe3         (fifo_read),            // input wire [0:0]  probe3 
       .probe4         (fifo_flush),           // input wire [0:0]  probe4 
       .probe5         (trace_fifo_error_flag),// input wire [0:0]  probe5 
       .probe6         (fifo_source_sel)       // input wire [0:0]  probe6 
    );
`endif

`endif // SAD_ONLY

endmodule
`default_nettype wire
