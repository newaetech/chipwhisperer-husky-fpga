`include "includes.v"
`timescale 1 ns / 1 ps
`default_nettype none
/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more
details, or the codebase at http://www.chipwhisperer.com

Copyright (c) 2024, NewAE Technology Inc. All rights reserved.
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


Adapted from cwhusky_top.v, retaining only the minimum needed for the SAD
module(s) to be functionally useful, for size/speed exploration of different
SAD architectures.

*************************************************************************/

module sad_top(  
    input wire         clk_usb,

    /* FPGA - USB Interface */
    inout wire [7:0]    USB_Data,
    input wire [7:0]    USB_Addr,
    input wire          USB_RDn,
    input wire          USB_WRn,
    input wire          USB_CEn,
    input wire          USB_ALEn,                   // USB_SPARE1

    // ADC
    input wire          ADC_clk_fbp,
    input wire          ADC_clk_fbn,
    output wire         ADC_CLKP,
    output wire         ADC_CLKN,
    input wire [5:0]    ADC_DP,
    input wire [5:0]    ADC_DN,

    input wire          target_hs1, // Clock from victim device

    output wire         TRIG_GLITCHOUT  //trigger/glitch out MCX
);

   localparam pBYTECNT_SIZE = 7;
   localparam pREF_SAMPLES  = 144;
   localparam pSAD_COUNTER_WIDTH = 12;

   wire         reset;

   wire clk_usb_buf;
   wire ADC_clk_fb;

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

   wire [7:0] read_data_sad;

   always @(posedge clk_usb_buf) read_data_reg <= read_data_sad;
   assign read_data = read_data_reg;

   wire [11:0] ADC_data;

   usb_reg_main #(
      .pBYTECNT_SIZE    (pBYTECNT_SIZE)
   ) U_usb_reg_main (
      .clk_usb          (clk_usb_buf), 
      .reset            (reset),
      .cwusb_din        (cmdfifo_din), 
      .cwusb_dout       (cmdfifo_dout), 
      .cwusb_rdn        (USB_RDn), 
      .cwusb_wrn        (USB_WRn),
      .cwusb_cen        (USB_CEn),
      .cwusb_alen       (USB_ALEn),
      .cwusb_addr       (USB_Addr),
      .cwusb_isout      (cmdfifo_isout), 
      .fast_fifo_read   (1'b0),
      .reg_address      (reg_address), 
      .reg_bytecnt      (reg_bytecnt), 
      .reg_datao        (write_data), 
      .reg_datai        (read_data),
      .reg_read         (reg_read), 
      .reg_write        (reg_write) 
   );

   wire armed_and_ready;
   wire sad_active;
   wire xadc_error;

   reg_sad_control #(
      .pBYTECNT_SIZE            (pBYTECNT_SIZE)
   ) U_reg_sad_control (
      .clk_usb                      (clk_usb_buf),
      .reg_address                  (reg_address  ),
      //.reg_bytecnt                  (reg_bytecnt  ),
      .reg_datai                    (write_data   ),
      //.reg_datao                    (read_data_control),
      //.reg_read                     (reg_read     ),
      .reg_write                    (reg_write    ),

      .reset_o                      (reset),
      .armed_and_ready              (armed_and_ready),
      .sad_active                   (sad_active),
      .xadc_error                   (xadc_error)
   );


   assign USB_Data = cmdfifo_isout ? cmdfifo_dout : 8'bZ;
   assign cmdfifo_din = USB_Data;


   // generate ADC output differential clock
   `ifdef __ICARUS__
      assign ADC_CLKP = target_hs1;
      assign ADC_CLKN = target_hs1;

   `else
      wire adc_clk_out_oddr;
      ODDR  #(
         .DDR_CLK_EDGE     ("OPPOSITE_EDGE"),
         .INIT             (1'b0),
         .SRTYPE           ("SYNC")
      ) U_ODDR_adc_clk_out (
         .Q                (adc_clk_out_oddr),
         .C                (target_hs1),
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

      reg ADC_slow_clk1 = 0;
      reg ADC_slow_clk2 = 0;
      reg ADC_slow_clk3 = 1;
      reg ADC_slow_clk4 = 1;
      always @(posedge ADC_slow_clk_even) ADC_slow_clk1 <= ~ADC_slow_clk1;
      always @(posedge ADC_slow_clk_even) ADC_slow_clk3 <= ~ADC_slow_clk3;
      always @(posedge ADC_slow_clk_odd) ADC_slow_clk2 <= ~ADC_slow_clk2;
      always @(posedge ADC_slow_clk_odd) ADC_slow_clk4 <= ~ADC_slow_clk4;

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

      `ifdef SAD_X4
          wire ADC_slow_clk1;
          wire ADC_slow_clk2;
          wire ADC_slow_clk3;
          wire ADC_slow_clk4;
          reg [1:0] bufgce_count2 = 2'b0;
          always @(posedge ADC_clk_fb) bufgce_count2 <= bufgce_count2 + 1;
          BUFGCE U_slow_adc1 (
              .I    (ADC_clk_fb),
              .CE   (~bufgce_count2[1]),
              .O    (ADC_slow_clk1)
          );
          BUFGCE U_slow_adc2 (
              .I    (ADC_clk_fb),
              .CE   (bufgce_count2[0] ^ bufgce_count2[1]),
              .O    (ADC_slow_clk2)
          );
          BUFGCE U_slow_adc3 (
              .I    (ADC_clk_fb),
              .CE   (bufgce_count2[1]),
              .O    (ADC_slow_clk3)
          );
          BUFGCE U_slow_adc4 (
              .I    (ADC_clk_fb),
              .CE   (~(bufgce_count2[0] ^ bufgce_count2[1])),
              .O    (ADC_slow_clk4)
          );

      `else
          wire ADC_slow_clk1 = 1'b0;
          wire ADC_slow_clk2 = 1'b0;
          wire ADC_slow_clk3 = 1'b0;
          wire ADC_slow_clk4 = 1'b0;
      `endif

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


   wire ADC_clk_sample = ADC_clk_fb;
   wire trigger_sad;
   assign TRIG_GLITCHOUT = trigger_sad;

`ifdef SAD_X2
   sad_x2_slowclock #(
       .pBYTECNT_SIZE           (pBYTECNT_SIZE),
       .pREF_SAMPLES            (pREF_SAMPLES),
       .pSAD_COUNTER_WIDTH      (pSAD_COUNTER_WIDTH),
       .pBITS_PER_SAMPLE        (8)
   ) U_sad (
       .reset                   (reset        ),
       .xadc_error              (xadc_error   ),
       .adc_datain              (ADC_data[11:4]),
       .adc_sampleclk           (ADC_clk_sample),
       .slow_clk_even           (ADC_slow_clk_even),
       .slow_clk_odd            (ADC_slow_clk_odd),
       .armed_and_ready         (armed_and_ready),
       .active                  (sad_active   ),
       .clk_usb                 (clk_usb_buf  ),
       .reg_address             (reg_address  ),
       .reg_bytecnt             (reg_bytecnt  ),
       .reg_datai               (write_data   ),
       .reg_datao               (read_data_sad),
       .reg_read                (reg_read     ),
       .reg_write               (reg_write    ),
       .ext_trigger             (),
       .io4                     (),
       .trigger                 (trigger_sad  )
   );

`elsif SAD_X4
   sad_x4_slowclock #(
       .pBYTECNT_SIZE           (pBYTECNT_SIZE),
       .pREF_SAMPLES            (pREF_SAMPLES),
       .pSAD_COUNTER_WIDTH      (pSAD_COUNTER_WIDTH),
       .pBITS_PER_SAMPLE        (8)
   ) U_sad (
       .reset                   (reset        ),
       .xadc_error              (xadc_error   ),
       .adc_datain              (ADC_data[11:4]),
       .adc_sampleclk           (ADC_clk_sample),
       .slow_clk1               (ADC_slow_clk1),
       .slow_clk2               (ADC_slow_clk2),
       .slow_clk3               (ADC_slow_clk3),
       .slow_clk4               (ADC_slow_clk4),
       .armed_and_ready         (armed_and_ready),
       .active                  (sad_active   ),
       .clk_usb                 (clk_usb_buf  ),
       .reg_address             (reg_address  ),
       .reg_bytecnt             (reg_bytecnt  ),
       .reg_datai               (write_data   ),
       .reg_datao               (read_data_sad),
       .reg_read                (reg_read     ),
       .reg_write               (reg_write    ),
       .ext_trigger             (),
       .io4                     (),
       .trigger                 (trigger_sad  )
   );

`elsif SAD_X2B
   //sad_x2_og #(
   sad_x2 #(
       .pBYTECNT_SIZE           (pBYTECNT_SIZE),
       .pREF_SAMPLES            (pREF_SAMPLES),
       .pSAD_COUNTER_WIDTH      (pSAD_COUNTER_WIDTH),
       .pBITS_PER_SAMPLE        (8)
   ) U_sad (
       .reset                   (reset        ),
       .xadc_error              (xadc_error   ),
       .adc_datain              (ADC_data[11:4]),
       .adc_sampleclk           (ADC_clk_sample),
       .armed_and_ready         (armed_and_ready),
       .active                  (sad_active   ),
       .clk_usb                 (clk_usb_buf  ),
       .reg_address             (reg_address  ),
       .reg_bytecnt             (reg_bytecnt  ),
       .reg_datai               (write_data   ),
       .reg_datao               (read_data_sad),
       .reg_read                (reg_read     ),
       .reg_write               (reg_write    ),
       .ext_trigger             (),
       .io4                     (),
       .trigger                 (trigger_sad  )
   );

`else
   sad #(
       .pBYTECNT_SIZE           (pBYTECNT_SIZE),
       .pREF_SAMPLES            (pREF_SAMPLES),
       .pSAD_COUNTER_WIDTH      (pSAD_COUNTER_WIDTH),
       .pBITS_PER_SAMPLE        (8)
   ) U_sad (
       .reset                   (reset        ),
       .xadc_error              (xadc_error   ),
       .adc_datain              (ADC_data[11:4]),
       .adc_sampleclk           (ADC_clk_sample),
       .armed_and_ready         (armed_and_ready),
       .active                  (sad_active   ),
       .clk_usb                 (clk_usb_buf  ),
       .reg_address             (reg_address  ),
       .reg_bytecnt             (reg_bytecnt  ),
       .reg_datai               (write_data   ),
       .reg_datao               (read_data_sad),
       .reg_read                (reg_read     ),
       .reg_write               (reg_write    ),
       .ext_trigger             (),
       .io4                     (),
       .trigger                 (trigger_sad  )
   );

`endif


endmodule
`default_nettype wire
