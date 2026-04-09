`include "includes.v"
`timescale 1 ns / 1 ps
`default_nettype none
/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more
details, or the codebase at http://www.chipwhisperer.com

Copyright (c) 2026, NewAE Technology Inc. All rights reserved.
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

module cwhusky_fifoonly(  
    input wire         clk_usb,

    output wire        LED_ADC, //  LED_CLK1FAIL on schematic,
    output wire        LED_GLITCH, // LED_CLK2FAIL on schematic
    output wire        LED_ARMED,
    output wire        LED_CAP,

`ifdef __ICARUS__
    // simulation only:
    output wire         glitch_out,
    output wire         glitch_clk,
`endif


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

    input  wire [7:0]   USERIO_D,
    input  wire         USERIO_CLK,

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

    //output wire         glitchout_highpwr, // high-speed glitch output
    //output wire         glitchout_lowpwr, // high-speed glitch output 

    output wire         target_poweron,

    //output wire         TRIG_GLITCHOUT, //trigger/glitch out MCX
    inout  wire         AUXIO // AUX I/O MCX
);

    parameter pBYTECNT_SIZE = 7;
    parameter pUSERIO_WIDTH = 8;
    parameter pSEQUENCER_NUM_TRIGGERS = 2;
    parameter pSEQUENCER_COUNTER_WIDTH = 16;


`ifdef __ICARUS__
   assign glitch_out = 1'b0;
   assign glitch_clk = 1'b0;
`endif


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
   wire [7:0] read_data_xadc;
   always @(posedge clk_usb_buf) read_data_reg <= read_data_openadc | read_data_cw | read_data_adc | read_data_xadc;
   assign read_data = (reg_address == `ADCREAD_ADDR)? fifo_dout : read_data_reg;

   wire trigger_capture;
   wire trigger_glitch;
   wire trigger_bb;
   wire extclk_mux;
   wire target_clk;
   wire capture_active;
   wire enable_avrprog;
   wire [11:0] ADC_data;

   wire fifo_error_flag;
   wire xadc_error_flag;
   wire error_flag = fifo_error_flag | xadc_error_flag;
   wire fast_fifo_read;

   wire slow_fifo_wr;
   wire slow_fifo_rd;
   wire [7:0] fifo_dout;

   wire flash_pattern;

   wire uart_trigger_line;
   wire edge_trigger_line;
   wire decodeio_active;
   wire edge_trigger_active;
   wire adc_trigger_active;
   wire bb_trigger_active;
   wire trigger_adc;
   wire trigger_edge_counter;

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


   assign USB_Data = cmdfifo_isout ? cmdfifo_dout : 8'bZ;
   assign cmdfifo_din = USB_Data;


   wire cw_led_cap;
   wire cw_led_armed;
   wire disable_adc_error;
   reg PLL_STATUS_reg = 1'b1;

   // fast-flash red LEDs when some internal error has occurred:
   assign LED_ADC = (error_flag)? flash_pattern : ~PLL_STATUS_reg;
   assign LED_GLITCH = flash_pattern;
   assign LED_CAP = cw_led_cap;
   assign LED_ARMED = cw_led_armed;

   always @(posedge clk_usb_buf) begin
       if (disable_adc_error)
           PLL_STATUS_reg <= 1'b1;
       else if (~PLL_STATUS) // make it sticky!
           PLL_STATUS_reg <= 1'b0;
   end

   openadc_interface #(
        .pBYTECNT_SIZE  (pBYTECNT_SIZE)
   ) oadc (
        .clk_usb                (clk_usb_buf),
        .ADC_slow_clk_even      (1'b0),
        .ADC_slow_clk_odd       (1'b0),
        .ADC_slow_clk1          (1'b0),
        .ADC_slow_clk2          (1'b0),
        .ADC_slow_clk3          (1'b0),
        .ADC_slow_clk4          (1'b0),
        .reset_o                (reg_rst),
        .xadc_error             (xadc_error_flag),

        .LED_capture            (cw_led_cap),
        .LED_armed              (cw_led_armed),
        .O_disable_adc_error    (disable_adc_error),
        .ADC_data               (ADC_data),
        .ADC_clk_feedback       (ADC_clk_fb),
        .pll_fpga_clk           (pll_fpga_clk),
        .PLL_STATUS             (PLL_STATUS),
        .DUT_CLK_i              (extclk_mux),
        .DUT_trigger_i          (trigger_capture),
        .trigger_io4_i          (target_io4),
        .trigger_adc            (trigger_adc),
        .trigger_sad            (),
        .trigger_edge_counter   (trigger_edge_counter),
        .sad_active             (1'b0),
        .sad_trigger_in_use     (1'b0),
        .edge_trigger_active    (edge_trigger_active),
        .adc_trigger_active     (adc_trigger_active),
        .amp_gain               (VDBSPWM),
        .fifo_dout              (fifo_dout),
        .cmd_arm_usb            (cmd_arm_usb),
        .armed_and_ready        (armed_and_ready),
        .freq_measure           (),
        .trace_flushing         (1'b0),
        .la_flushing            (1'b0),
        .shared_fifo_empty      (1'b1),

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

        .slow_fifo_wr           (slow_fifo_wr),
        .slow_fifo_rd           (slow_fifo_rd),
        .la_debug2              (),
        .la_debug               (),
        .sad_debug              (),
        .edge_trigger_debug     (),
        .fifo_debug             ()

   );

   wire enable_output_nrst;
   wire output_nrst;
   wire nrst_ignore_highz;
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
        .trace_active           (),
        .trace_trigger_in_use   (),
        .sad_trigger_in_use     (),
        .sad_active             (),
        .edge_trigger_active    (edge_trigger_active),
        .adc_trigger_active     (adc_trigger_active),
        .bb_trigger_active      (),
        .trigger_advio_i        (1'b0),
        .trigger_decodedio_i    (1'b0),
        .trigger_trace_i        (1'b0),
        .trigger_adc_i          (trigger_adc),
        .trigger_bb_i           (1'b0),
        .trigger_sad_i          (1'b0),
        .trigger_edge_i         (trigger_edge_counter),
        .pll_fpga_clk           (pll_fpga_clk),
        .glitchclk              (1'b0),
        .glitch_mmcm1_clk_out   (1'b0),
        .adc_sample_clk         (ADC_clk_fb),
        .trace_fe_clk           (1'b0),

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

        .hsglitcha_o            (),
        .hsglitchb_o            (),

        .enable_avrprog         (enable_avrprog),

        .enable_output_nrst     (enable_output_nrst),
        .output_nrst            (output_nrst),
        .nrst_ignore_highz      (nrst_ignore_highz),
        .enable_output_pdid     (enable_output_pdid),
        .output_pdid            (output_pdid),
        .enable_output_pdic     (enable_output_pdic),
        .output_pdic            (output_pdic),

        .uart_tx_i              (FPGA_CDOUT),
        .uart_rx_o              (FPGA_CDIN),
        .targetpower_off        (target_npower),

        .userio_d               (8'b0),
        .userio_ck              (1'b0),

        .bb_trig_select         (),
        .bb_data_in             (),
        .bb_data_out            (1'b0),
        .bb_data_drive          (1'b0),
        .bb_clock_out           (1'b0),

        .trace_exists           (1'b0),
        .la_exists              (1'b0),

        .cw310_adc_clk_sel      (), // CW310 only

        .sequencer_debug        (),
        .sequencer_debug2       (),
        .seq_trace_sad_debug    (),

        .armed_and_ready        (armed_and_ready),
        .trigger_capture        (trigger_capture),
        .trigger_glitch         (),
        .trigger_trace          (),
        .trig_glitch_o_mcx      ()
   );



   wire target_highz = target_npower;
   assign target_poweron = ~target_npower;

   assign target_PDID = (target_highz) ? 1'bZ :
                        (enable_output_pdid) ? output_pdid : 1'bZ;

   assign target_PDIC = (target_highz) ? 1'bZ:
                        (enable_output_pdic) ? output_pdic : 1'bZ;

   assign target_nRST = (target_highz && ~nrst_ignore_highz) ? 1'bZ :
                        (enable_avrprog) ? ( (USB_SPARE0)? 1'bz : 1'b0 )  :
                        (enable_output_nrst) ? output_nrst : 1'bZ;

   assign target_MOSI = (target_highz) ? 1'bZ :
                        (enable_avrprog) ? SAM_MOSI : 1'bZ;

   assign target_SCK = (target_highz) ? 1'bZ :
                       (enable_avrprog) ? SAM_SPCK : 1'bZ;

   assign SAM_MISO = (enable_avrprog) ? target_MISO : 1'bZ;


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


endmodule
`default_nettype wire
