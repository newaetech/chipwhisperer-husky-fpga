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

    // currently unused:
    input wire          FPGA_BONUS1,
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
    input  wire         USERIO_CLK,

    input wire          FPGA_CDOUT, /* Input FROM SAM3U */
    output wire         FPGA_CDIN, /* Output TO SAM3U */

    input  wire         SAM_MOSI,
    output wire         SAM_MISO,
    input  wire         SAM_SPCK,
    input  wire         SAM_CS, // TODO: why not using this?

    /* XMEGA Programming - not used, but need to ensure line is floating */
    output wire         target_PDID,
    output wire         target_PDIC,

    /* Spare Lines - AVR Programming */
    inout  wire         target_nRST,
    input wire          target_MISO,
    output wire         target_MOSI,
    output wire         target_SCK,

    /* Target IO Interfaces */
    inout wire          target_io4, // Normally trigger
    inout wire          target_io3, // Normally Spare / SmartCard Comms
    inout wire          target_io2, // Normally RXD
    inout wire          target_io1, // Normally TXD / SmartCard Reset
    input wire          target_hs1, // Clock from victim device
    inout wire          target_hs2, // Clock to victim device

    output wire         glitchout_highpwr, // high-speed glitch output
    output wire         glitchout_lowpwr, // high-speed glitch output 

    output wire         target_poweron,

    output wire         FPGA_TRIGOUT, //trigger out MCX
    input  wire         USBIOHS2 //clock MCX
);

    parameter pBYTECNT_SIZE = 7;
    parameter pLA_CAPTURE_DEPTH = 512;
    parameter pUSERIO_WIDTH = 8;
    parameter pTRACE_BUFFER_SIZE = 64;
    parameter pTRACE_MATCH_RULES = 8;

   wire         ADC_clk_out;
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

   wire ext_trigger;
   wire extclk_mux;
   wire target_clk;
   wire clkgen, glitchclk;
   wire glitch_mmcm1_clk_out;
   wire glitch_mmcm2_clk_out;
   wire glitch_enable;
   wire glitch_go;
   wire glitch_trigger;
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

   wire flash_pattern;

   wire userio_debug_driven;
   wire [pUSERIO_WIDTH-1:0] userio_cwdriven;
   wire [pUSERIO_WIDTH-1:0] userio_drive_data;
   wire [pUSERIO_WIDTH-1:0] userio_debug_data;

   wire trace_trig_out;

   wire la_exists;
   wire trace_exists;

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

      assign userio_debug_data[0] = stream_segment_available;
      assign userio_debug_data[1] = slow_fifo_wr_slow;
      assign userio_debug_data[2] = slow_fifo_rd_slow;
      assign userio_debug_data[3] = reg_read_slow;
      assign userio_debug_data[4] = fast_fifo_read;
      assign userio_debug_data[5] = fifo_error_flag;
      assign userio_debug_data[6] = glitchclk;
      assign userio_debug_data[7] = 1'bz;

   `else
      assign userio_debug_data[7:0] = 8'bz;
   `endif

   assign USB_Data = cmdfifo_isout ? cmdfifo_dout : 8'bZ;
   assign cmdfifo_din = USB_Data;


   wire led_glitch;
   wire cw_led_cap;
   wire cw_led_armed;
   wire trace_en;
   wire [7:0] trace_userio_dir;

   // fast-flash red LEDs when some internal error has occurred:
   assign LED_ADC = error_flag? flash_pattern : ~PLL_STATUS;
   assign LED_GLITCH = error_flag? flash_pattern : led_glitch;
   assign LED_CAP = cw_led_cap; // TODO: mux trace LEDs
   assign LED_ARMED = cw_led_armed;


   openadc_interface #(
        .pBYTECNT_SIZE  (pBYTECNT_SIZE)
   ) oadc (
        .clk_usb                (clk_usb_buf),
        .reset_o                (reg_rst),
        .mmcm_shutdown          (xadc_error_flag),

        .LED_capture            (cw_led_cap),
        .LED_armed              (cw_led_armed),
        .ADC_data               (ADC_data),
        .ADC_clk_out            (ADC_clk_out),
        .ADC_clk_feedback       (ADC_clk_fb),
        .pll_fpga_clk           (pll_fpga_clk),
        .PLL_STATUS             (PLL_STATUS),
        .DUT_CLK_i              (extclk_mux),
        .DUT_trigger_i          (ext_trigger),
        .amp_gain               (VDBSPWM),
        .fifo_dout              (fifo_dout),
        .clkgen                 (clkgen),

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

        .flash_pattern          (flash_pattern),

        .slow_fifo_wr           (slow_fifo_wr),
        .slow_fifo_rd           (slow_fifo_rd),
        .la_debug               (tu_la_debug)

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
        .pBYTECNT_SIZE  (pBYTECNT_SIZE),
        .pUSERIO_WIDTH  (pUSERIO_WIDTH)
   ) reg_chipwhisperer (
        .reset_i                (reg_rst),
        .clk_usb                (clk_usb_buf),
        .reg_address            (reg_address),
        .reg_bytecnt            (reg_bytecnt), 
        .reg_datao              (read_data_cw), 
        .reg_datai              (write_data), 
        .reg_read               (reg_read), 
        .reg_write              (reg_write), 

        .usbiohs2               (USBIOHS2),
        .target_hs1             (target_hs1),
        .target_hs2             (target_hs2),
        .extclk_o               (extclk_mux),
        .target_clk             (target_clk),
        .trigger_io1_i          (target_io1),
        .trigger_io2_i          (target_io2),
        .trigger_io3_i          (target_io3),
        .trigger_io4_i          (target_io4),
        .trigger_nrst_i         (target_nRST),
        .trigger_ext_o          (),
        .trigger_advio_i        (1'b0),
        .trigger_anapattern_i   (1'b0),
        .trigger_decodedio_i    (1'b0),
        .trigger_trace_i        (trace_trig_out),
        .pll_fpga_clk           (pll_fpga_clk),
        .glitchclk              (glitchclk),

        .targetio1_io           (target_io1),
        .targetio2_io           (target_io2),
        .targetio3_io           (target_io3),
        .targetio4_io           (target_io4),

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
        .userio_drive_data      (userio_drive_data),
        .userio_debug_driven    (userio_debug_driven),

        .trace_exists           (trace_exists),
        .la_exists              (la_exists),

        .trigger_o              (ext_trigger)
   );

   userio #(
      .pWIDTH                   (pUSERIO_WIDTH)
   ) U_userio (
      .usb_clk                  (clk_usb_buf),
      .userio_d                 (USERIO_D),
      .userio_clk               (USERIO_CLK),
      .I_userio_cwdriven        (userio_cwdriven),
      .I_userio_debug_driven    (userio_debug_driven),
      .I_userio_drive_data      (userio_drive_data),
      .I_userio_debug_data      (userio_debug_data)
   );


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
        .target_hs1     (target_hs1),
        .clkgen         (clkgen),
        .pll_fpga_clk   (pll_fpga_clk),
        .glitchclk      (glitchclk),
        .glitch_mmcm1_clk_out (glitch_mmcm1_clk_out),
        .glitch_mmcm2_clk_out (glitch_mmcm2_clk_out),
        .glitch_enable  (glitch_enable),
        .exttrigger     (ext_trigger),
        .glitch_go      (glitch_go),
        .glitch_trigger (glitch_trigger),
        .led_glitch     (led_glitch)
   );

   `ifdef LOGIC_ANALYZER
   assign la_exists = 1;
   reg_la #(
        .pBYTECNT_SIZE  (pBYTECNT_SIZE),
        .pCAPTURE_DEPTH (pLA_CAPTURE_DEPTH)
   ) reg_la (
        .reset                  (reg_rst),
        .clk_usb                (clk_usb_buf),
        .reg_address            (reg_address),
        .reg_bytecnt            (reg_bytecnt), 
        .reg_datao              (read_data_la), 
        .reg_datai              (write_data), 
        .reg_read               (reg_read), 
        .reg_write              (reg_write), 
        .target_hs1             (target_hs1),
        .clkgen                 (clkgen),
        .pll_fpga_clk           (pll_fpga_clk),
        .observer_clk           (observer_clk),
        .observer_locked        (observer_locked),
        .mmcm_shutdown          (xadc_error_flag),

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
        .aux_mcx                (USBIOHS2),
        .trig_mcx               (FPGA_TRIGOUT),
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

        .tu_la_debug            (tu_la_debug),
        .trace_data             (trace_data_sdr),
        .trace_fe_clk           (fe_clk),

        .glitch_go              (glitch_go),
        .glitch_trigger_sourceclock (glitch_trigger),
        .capture_active         (capture_active)
   );
   `else
       assign read_data_la = 0;
       assign la_exists = 0;
   `endif

   assign FPGA_TRIGOUT = ext_trigger;

   wire target_highz = target_npower;
   assign target_poweron = ~target_npower;

   assign target_PDID = (target_highz) ? 1'bZ :
                        (enable_output_pdid) ? output_pdid : 1'bZ;

   assign target_PDIC = (target_highz) ? 1'bZ:
                        (enable_output_pdic) ? output_pdic : 1'bZ;

   assign target_nRST = (target_highz) ? 1'bZ :
                        (enable_avrprog) ? USB_SPARE0 :
                        (enable_output_nrst) ? output_nrst : 1'bZ;

   assign target_MOSI = (target_highz) ? 1'bZ :
                        (enable_avrprog) ? SAM_MOSI : 1'bZ;

   assign target_SCK = (target_highz) ? 1'bZ :
                       (enable_avrprog) ? SAM_SPCK : 1'bZ;

   assign SAM_MISO = (enable_avrprog) ? target_MISO : 1'bZ;


   // generate ADC output differential clock
   `ifdef __ICARUS__
      assign ADC_CLKP = ADC_clk_out;
      assign ADC_CLKN = ADC_clk_out;

   `else
      wire adc_clk_out_oddr;
      ODDR  #(
         .DDR_CLK_EDGE     ("OPPOSITE_EDGE"),
         .INIT             (1'b0),
         .SRTYPE           ("SYNC")
      ) U_ODDR_adc_clk_out (
         .Q                (adc_clk_out_oddr),
         .C                (ADC_clk_out),
         .CE               (1'b1),
         .D1               (1'b1),
         .D2               (1'b0),
         .R                (1'b0),
         .S                (1'b0)
      );

      OBUFDS #(
         // TODO: are these the best settings?
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
      IBUFDS #(
         .DIFF_TERM        ("FALSE"),
         .IBUF_LOW_PWR     ("FALSE"),
         .IOSTANDARD       ("LVDS_25")
      ) U_IBUFDS_adc_clk_fb (
         .I                (ADC_clk_fbp),
         .IB               (ADC_clk_fbn),
         .O                (ADC_clk_fb)
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

         IDDR #(
            .DDR_CLK_EDGE     ("OPPOSITE_EDGE"),
            .INIT_Q1          (0),
            .INIT_Q2          (0),
            .SRTYPE           ("SYNC")
         ) U_adc_iddr (
            .Q1               (ADC_data[adc_index*2]),
            .Q2               (ADC_data[adc_index*2+1]),
            .D                (ADC_D[adc_index]),
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
          .xadc_error       (xadc_error_flag)
       ); 

   `else
      assign read_data_xadc = 0;
      assign xadc_error_flag = 0;
   `endif

   wire [7:0] trace_data_sdr;
   wire fe_clk;

   `ifdef TRACE
       wire TRACECLOCK = USERIO_CLK;
       wire [3:0] TRACEDATA  = USERIO_D[7:4];
       wire swo = USERIO_D[2];

       reg [22:0] count_fe_clock;
       always @(posedge fe_clk) count_fe_clock <= count_fe_clock + 1;
       assign trace_exists = 1;

       trace_top #(
          .pBYTECNT_SIZE                (pBYTECNT_SIZE),
          .pBUFFER_SIZE                 (pTRACE_BUFFER_SIZE),
          .pMATCH_RULES                 (pTRACE_MATCH_RULES),
          .pUSERIO_WIDTH                (pUSERIO_WIDTH),
          .pMAIN_REG_SELECT             (`TW_MAIN_REG_SELECT),
          .pTRACE_REG_SELECT            (`TW_TRACE_REG_SELECT),
          .pREGISTERED_READ             (0)
       ) U_trace_top (
          .trace_clk_in                 (TRACECLOCK),
          .fe_clk                       (fe_clk),
          .usb_clk                      (clk_usb_buf),
          .reset_pin                    (1'b0),
          .fpga_reset                   (),
          .flash_pattern                (),
          .buildtime                    (32'b0),
          .O_trace_en                   (trace_en),
          .O_trace_userio_dir           (trace_userio_dir),

          .trace_data                   (TRACEDATA),
          .swo                          (swo),
          .O_trace_trig_out             (trace_trig_out),
          .m3_trig                      (ext_trigger),
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

          // TODO-maybe later: for CW610-style faster FIFO reading:
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
          .userio_d                     ({pUSERIO_WIDTH{1'b0}}),
          .O_userio_pwdriven            (),
          .O_userio_drive_data          (),

          .arm                          (),
          .capturing                    (),

          .trace_data_sdr               (trace_data_sdr),
          .synchronized                 ()
       );

   `else
      assign read_data_trace = 0;
      assign trace_error_flag = 0;
      assign trace_trig_out = 0;
      assign trace_exists = 0;
      assign trace_data_sdr = 0;
      assign fe_clk = 0;

   `endif


endmodule
`default_nettype wire
