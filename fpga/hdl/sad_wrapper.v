`include "includes.v"
`timescale 1 ns / 1 ps
`default_nettype none
/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more
details, or the codebase at http://www.chipwhisperer.com

Copyright (c) 2022-2024, NewAE Technology Inc. All rights reserved.
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

module sad_wrapper #(  
    parameter pBYTECNT_SIZE = 7,
    parameter pREF_SAMPLES = 8, 
    parameter pBITS_PER_SAMPLE = 12,
    parameter pSAD_COUNTER_WIDTH = 12,
    parameter pNUM_GROUPS = 4
)(
    input wire         clk_usb,
    input wire         clk_adc,
    input wire         reset,

    inout wire [7:0]    USB_Data,
    input wire [7:0]    USB_Addr,
    input wire          USB_RDn,
    input wire          USB_WRn,
    input wire          USB_CEn,
    input wire          USB_ALEn,

    input wire [11:0]   adc_datain,
    input wire          armed_and_ready,
    output wire         trigger,

    // debug only:
    output wire [pREF_SAMPLES/2-1:0] debug_emode
);

   wire cmdfifo_isout;
   wire [7:0] cmdfifo_din;
   wire [7:0] cmdfifo_dout;
   wire [pBYTECNT_SIZE-1:0]  reg_bytecnt;
   wire [7:0]   write_data;
   reg  [7:0]   read_data;
   reg  [7:0]   read_data_reg;
   wire         reg_read;
   wire         reg_write;
   wire [7:0]   reg_address;
   reg [11:0] adc_datain_r;

   wire [7:0] read_data_sad_base;
   wire [7:0] read_data_sad_x2;
   wire [7:0] read_data_sad_x2b;
   wire [7:0] read_data_sad_x4;
   wire [7:0] read_data_sad_single;
   wire [7:0] read_data_esad;
`ifdef SAD_X2
   always @(posedge clk_usb) read_data <= read_data_sad_x2;
`elsif SAD_X4
   always @(posedge clk_usb) read_data <= read_data_sad_x4;
`elsif SAD_X2B
   always @(posedge clk_usb) read_data <= read_data_sad_x2b;
`elsif SAD_SINGLE
   always @(posedge clk_usb) read_data <= read_data_sad_single;
`elsif ESAD
   always @(posedge clk_usb) read_data <= read_data_esad;
`else
   always @(posedge clk_usb) read_data <= read_data_sad_base;
`endif

   assign USB_Data = cmdfifo_isout ? cmdfifo_dout : 8'bZ;
   assign cmdfifo_din = USB_Data;

   always @(posedge clk_adc)
       adc_datain_r <= adc_datain;

   usb_reg_main #(
      .pBYTECNT_SIZE    (pBYTECNT_SIZE)
   ) U_usb_reg_main (
      .clk_usb          (clk_usb), 
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


// always instantiate base SAD implementation since it can be useful
// to compare against other implementations
wire trigger_base;
sad #(
    .pBYTECNT_SIZE      (7),
    .pREF_SAMPLES       (pREF_SAMPLES),
    .pBITS_PER_SAMPLE   (pBITS_PER_SAMPLE),
    .pSAD_COUNTER_WIDTH (pSAD_COUNTER_WIDTH),
    .pNUM_GROUPS        (pNUM_GROUPS)
) U_base_dut (
    .reset              (reset),
    .xadc_error         (1'b0),
    .adc_datain         (adc_datain_r[pBITS_PER_SAMPLE-1:0]),
    .adc_sampleclk      (clk_adc),
    .armed_and_ready    (armed_and_ready),
    .active             (1'b1),
    .clk_usb            (clk_usb),
    .reg_address        (reg_address),
    .reg_bytecnt        (reg_bytecnt),
    .reg_datai          (write_data),
    .reg_datao          (read_data_sad_base),
    .reg_read           (reg_read),
    .reg_write          (reg_write),
    .ext_trigger        (1'b0), // debug only
    .io4                (1'b0), // debug only
    .trigger            (trigger_base)
);



`ifdef ESAD
    wire trigger_esad;
    esad #(
        .pBYTECNT_SIZE      (7),
        .pREF_SAMPLES       (pREF_SAMPLES),
        .pBITS_PER_SAMPLE   (pBITS_PER_SAMPLE),
        .pSAD_COUNTER_WIDTH (pSAD_COUNTER_WIDTH),
        .pNUM_GROUPS        (pNUM_GROUPS)
    ) U_edut (
        .reset              (reset),
        .xadc_error         (1'b0),
        .adc_datain         (adc_datain_r[pBITS_PER_SAMPLE-1:0]),
        .adc_sampleclk      (clk_adc),
        .armed_and_ready    (armed_and_ready),
        .active             (1'b1),
        .clk_usb            (clk_usb),
        .reg_address        (reg_address),
        .reg_bytecnt        (reg_bytecnt),
        .reg_datai          (write_data),
        .reg_datao          (read_data_esad),
        .reg_read           (reg_read),
        .reg_write          (reg_write),
        .ext_trigger        (1'b0), // debug only
        .io4                (1'b0), // debug only
        .debug_emode        (debug_emode),
        .trigger            (trigger_esad)
    );
`endif


`ifdef SAD_SINGLE
    wire trigger_single;
    sad_single_counter #(
        .pBYTECNT_SIZE      (7),
        .pREF_SAMPLES       (pREF_SAMPLES),
        .pBITS_PER_SAMPLE   (pBITS_PER_SAMPLE),
        .pSAD_COUNTER_WIDTH (pSAD_COUNTER_WIDTH)
    ) U_single_dut (
        .reset              (reset),
        .xadc_error         (1'b0),
        .adc_datain         (adc_datain_r[pBITS_PER_SAMPLE-1:0]),
        .adc_sampleclk      (clk_adc),
        .armed_and_ready    (armed_and_ready),
        .active             (1'b1),
        .clk_usb            (clk_usb),
        .reg_address        (reg_address),
        .reg_bytecnt        (reg_bytecnt),
        .reg_datai          (write_data),
        .reg_datao          (read_data_sad_single),
        .reg_read           (reg_read),
        .reg_write          (reg_write),
        .ext_trigger        (1'b0), // debug only
        .io4                (1'b0), // debug only
        .trigger            (trigger_single)
    );
`endif


`ifdef SAD_X2B
    wire trigger_x2b;
    sad_x2 #(
        .pBYTECNT_SIZE      (7),
        .pREF_SAMPLES       (pREF_SAMPLES),
        .pBITS_PER_SAMPLE   (pBITS_PER_SAMPLE),
        .pSAD_COUNTER_WIDTH (pSAD_COUNTER_WIDTH)
    ) U_x2b_dut (
        .reset              (reset),
        .xadc_error         (1'b0),
        .adc_datain         (adc_datain_r[pBITS_PER_SAMPLE-1:0]),
        .adc_sampleclk      (clk_adc),
        .armed_and_ready    (armed_and_ready),
        .active             (1'b1),
        .clk_usb            (clk_usb),
        .reg_address        (reg_address),
        .reg_bytecnt        (reg_bytecnt),
        .reg_datai          (write_data),
        .reg_datao          (read_data_sad_x2b),
        .reg_read           (reg_read),
        .reg_write          (reg_write),
        .ext_trigger        (1'b0), // debug only
        .io4                (1'b0), // debug only
        .trigger            (trigger_x2b)
    );
`endif

// needed by both SAD_X2 and SAD_X4:
reg ADC_slow_clk_even = 1'b0;
reg ADC_slow_clk_odd  = 1'b1;
always @(posedge clk_adc) ADC_slow_clk_even <= ~ADC_slow_clk_even;
always @(posedge clk_adc) ADC_slow_clk_odd  <= ~ADC_slow_clk_odd;


`ifdef SAD_X2
    wire trigger_x2;
    reg trigger_x2_r;
    always @(posedge clk_adc) trigger_x2_r <= trigger_x2;
    wire trigger_x2_1cycle = trigger_x2_r && trigger_x2;

    sad_x2_slowclock #(
        .pBYTECNT_SIZE      (7),
        .pREF_SAMPLES       (pREF_SAMPLES),
        .pBITS_PER_SAMPLE   (pBITS_PER_SAMPLE),
        .pSAD_COUNTER_WIDTH (pSAD_COUNTER_WIDTH)
    ) U_x2_dut (
        .reset              (reset),
        .xadc_error         (1'b0),
        .adc_datain         (adc_datain_r[pBITS_PER_SAMPLE-1:0]),
        .adc_sampleclk      (clk_adc),
        .slow_clk_even      (ADC_slow_clk_even),
        .slow_clk_odd       (ADC_slow_clk_odd),
        .armed_and_ready    (armed_and_ready),
        .active             (1'b1),
        .clk_usb            (clk_usb),
        .reg_address        (reg_address),
        .reg_bytecnt        (reg_bytecnt),
        .reg_datai          (write_data),
        .reg_datao          (read_data_sad_x2),
        .reg_read           (reg_read),
        .reg_write          (reg_write),
        .ext_trigger        (1'b0), // debug only
        .io4                (1'b0), // debug only
        .trigger            (trigger_x2)
    );
`endif


`ifdef SAD_X4
    reg ADC_slow_clk1 = 0;
    reg ADC_slow_clk2 = 0;
    reg ADC_slow_clk3 = 1;
    reg ADC_slow_clk4 = 1;

    always @(posedge ADC_slow_clk_even) ADC_slow_clk1 <= ~ADC_slow_clk1;
    always @(posedge ADC_slow_clk_even) ADC_slow_clk3 <= ~ADC_slow_clk3;

    always @(posedge ADC_slow_clk_odd) ADC_slow_clk2 <= ~ADC_slow_clk2;
    always @(posedge ADC_slow_clk_odd) ADC_slow_clk4 <= ~ADC_slow_clk4;

    wire trigger_x4;
    wire always_armed_x4;
    sad_x4_slowclock #(
        .pBYTECNT_SIZE      (7),
        .pREF_SAMPLES       (pREF_SAMPLES),
        .pBITS_PER_SAMPLE   (pBITS_PER_SAMPLE),
        .pSAD_COUNTER_WIDTH (pSAD_COUNTER_WIDTH)
    ) U_x4_dut (
        .reset              (reset),
        .xadc_error         (1'b0),
        .adc_datain         (adc_datain_r[pBITS_PER_SAMPLE-1:0]),
        .adc_sampleclk      (clk_adc),
        .slow_clk1          (ADC_slow_clk1),
        .slow_clk2          (ADC_slow_clk2),
        .slow_clk3          (ADC_slow_clk3),
        .slow_clk4          (ADC_slow_clk4),
        .armed_and_ready    (armed_and_ready),
        .active             (1'b1),
        .clk_usb            (clk_usb),
        .reg_address        (reg_address),
        .reg_bytecnt        (reg_bytecnt),
        .reg_datai          (write_data),
        .reg_datao          (read_data_sad_x4),
        .reg_read           (reg_read),
        .reg_write          (reg_write),
        .ext_trigger        (1'b0), // debug only
        .io4                (1'b0), // debug only
        .always_armed       (always_armed_x4),
        .trigger            (trigger_x4)
    );

    reg [1:0] trigger_x4_r;
    always @(posedge clk_adc) trigger_x4_r <= {trigger_x4_r[0], trigger_x4};
    // NOTE: conditioning on armed_and_ready is cheating; it's the easy way to
    // deal with the fact that armed_and_ready is delayed in getting through
    // to the slow clock domains in sad_x4_slowclock:
    wire trigger_x4_1cycle = trigger_x4_r[0] && ~trigger_x4_r[1] && (armed_and_ready || always_armed_x4);

`endif


`ifdef SAD_X2
    assign trigger = trigger_x2_1cycle;
`elsif SAD_X4
    assign trigger = trigger_x4_1cycle;
`elsif SAD_X2B
    assign trigger = trigger_x2b;
`elsif SAD_SINGLE
    assign trigger = trigger_single;
`elsif ESAD
    assign trigger = trigger_esad;
`else
    assign trigger = trigger_base;
`endif


endmodule
`default_nettype wire
