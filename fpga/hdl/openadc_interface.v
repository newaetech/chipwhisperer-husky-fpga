`include "includes.v"
`timescale 1 ns / 1 ps
`default_nettype none
/***********************************************************************
This file is part of the OpenADC Project. See www.newae.com for more details,
or the codebase at http://www.assembla.com/spaces/openadc .

This file is the main interface.

Copyright (c) 2012-2021, Colin O'Flynn <coflynn@newae.com>. All rights reserved.
This project (and file) is released under the 2-Clause BSD License:

Redistribution and use in source and binary forms, with or without 
modification, are permitted provided that the following conditions are met:

   * Redistributions of source code must retain the above copyright notice,
     this list of conditions and the following disclaimer.
   * Redistributions in binary form must reproduce the above copyright
     notice, this list of conditions and the following disclaimer in the
     documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.
*************************************************************************/
module openadc_interface(
   input         reset_i,
   input         clk_usb, // 96 MHz

   inout wire [7:0]     USB_D,
   input wire [7:0]     USB_Addr,
   input wire   USB_RDn,
   input wire   USB_WRn,
   input wire   USB_CEn,
   input wire   USB_ALEn,

/* LEDs. Connect up any you wish. */
    output        LED_hbeat, /* Heartbeat LED */
    output        LED_armed, /* Armed LED */
    output        LED_capture, /* Capture in Progress LED (only illuminate during capture, very quick) */
    output        LED_ADCDCMUnlock, /* DCM for ADC is unlocked */
    output        LED_CLKGENDCMUnlock, /* DCM for CLKGEN is unlocked */

    /* OpenADC Interface Pins */
    input [9:0]   ADC_Data,
    input         ADC_OR,
    output        ADC_clk,
    /* Feedback path for ADC Clock. If unused connect to ADC_clk */
    input         ADC_clk_feedback,
    input         DUT_CLK_i, // target_hs1
    input         DUT_trigger_i,
    output        amp_gain,
    output        amp_hilo,

    /* Generated Clock for other uses */
    output        clkgen,

    /* Connections to external registers */
    output              reg_reset_o,
    output [5:0]        reg_address_o,
    output [15:0]       reg_bytecnt_o,
    output [7:0]        reg_datao_o,
    input  [7:0]        reg_datai_i,
    output [15:0]       reg_size_o,
    output              reg_read_o,
    output              reg_write_o,
    output              reg_addrvalid_o,
    input               reg_stream_i,
    output [5:0]        reg_hypaddress_o,
    input  [15:0]       reg_hyplen_i
    );

    wire        dcm_locked;

    wire [8:0] phase_requested;
    wire [8:0] phase_actual;
    wire       phase_load;
    wire       phase_done;

    wire       adc_capture_go;
    wire       adc_capture_done;
    wire       armed;
    wire       reset;

    wire       dcm_gen_locked;
    wire       trigger_source;
    wire       fifo_stream;

   //Divide clock by 2^24 for heartbeat LED
   //Divide clock by 2^23 for frequency measurement
   reg [24:0] timer_heartbeat;
   always @(posedge clk_usb)
      if (reset) begin
         timer_heartbeat <= 25'b0;
      end else begin
         timer_heartbeat <= timer_heartbeat +  25'd1;
      end

   //Blink heartbeat LED
   assign LED_hbeat = timer_heartbeat[24];
   assign LED_armed = armed;
   assign LED_capture = adc_capture_go;
   assign LED_ADCDCMUnlock = ~dcm_locked;
   assign LED_CLKGENDCMUnlock = ~dcm_gen_locked;

   //Frequency Measurement
   wire freq_measure;
   //BUFG buf_freqmeasure (.I(timer_heartbeat[25]), .O(freq_measure));
   assign freq_measure = timer_heartbeat[23];

   wire extmeasure_clk;
   wire extmeasure_src;
   assign extmeasure_clk = (extmeasure_src) ? clkgen : DUT_CLK_i;

   reg [31:0] extclk_frequency_int;
   always @(posedge extmeasure_clk or negedge freq_measure) begin
      if (freq_measure == 1'b0) begin
         extclk_frequency_int <= 32'd0;
      end else begin
         extclk_frequency_int <= extclk_frequency_int + 32'd1;
      end
   end

   reg [31:0] adcclk_frequency_int;
   always @(posedge ADC_clk_sample or negedge freq_measure) begin
      if (freq_measure == 1'b0) begin
         adcclk_frequency_int <= 32'd0;
      end else begin
         adcclk_frequency_int <= adcclk_frequency_int + 32'd1;
      end
   end

   reg [31:0] extclk_frequency;
   always @(negedge freq_measure) begin
      extclk_frequency <= extclk_frequency_int;
   end

   reg [31:0] adcclk_frequency;
   always @(negedge freq_measure) begin
      adcclk_frequency <= adcclk_frequency_int;
   end

   wire ADC_clk_sample;

   wire chipscope_clk;

   wire [9:0] ADC_Data_delayed;
   genvar index;
   generate
   for (index=0; index < 10; index=index+1)
      begin: gen_iodelay_adcdata
`ifdef ADCCLK_FEEDBACK
         //If we have feedback clock shouldn't need IODELAY2
         assign ADC_Data_delayed[index] = ADC_Data[index];
`elsif __ICARUS__
         assign ADC_Data_delayed[index] = ADC_Data[index];
`else
         // XXX remove?
         IODELAY2 #(
            .COUNTER_WRAPAROUND("WRAPAROUND"), // "STAY_AT_LIMIT" or "WRAPAROUND"
            .DATA_RATE("SDR"), // "SDR" or "DDR"
            .DELAY_SRC("IDATAIN"), // "IO", "ODATAIN" or "IDATAIN"
            .IDELAY2_VALUE(0), // Delay value when IDELAY_MODE="PCI" (0-255)
            .IDELAY_MODE("NORMAL"), // "NORMAL" or "PCI"
            .IDELAY_TYPE("DEFAULT"), // "FIXED", "DEFAULT", "VARIABLE_FROM_ZERO", "VARIABLE_FROM_HALF_MAX"
            .IDELAY_VALUE(20), // Amount of taps for fixed input delay (0-255)
            .ODELAY_VALUE(0), // Amount of taps fixed output delay (0-255)
            .SERDES_MODE("NONE"), // "NONE", "MASTER" or "SLAVE"
            .SIM_TAPDELAY_VALUE(75) // Per tap delay used for simulation in ps
         )
         IODELAY2_inst (
            //.BUSY(), // 1-bit output: Busy output after CAL
            .DATAOUT(), // 1-bit output: Delayed data output to ISERDES/input register
            .DATAOUT2(ADC_Data_delayed[index]), // 1-bit output: Delayed data output to general FPGA fabric
            .DOUT(), // 1-bit output: Delayed data output
            .TOUT(), // 1-bit output: Delayed 3-state output
            //.CAL(), // 1-bit input: Initiate calibration input
            //.CE(), // 1-bit input: Enable INC input
            //.CLK(), // 1-bit input: Clock input
            .IDATAIN(ADC_Data[index]), // 1-bit input: Data input (connect to top-level port or I/O buffer)
            //.INC(), // 1-bit input: Increment / decrement input
            //.IOCLK0(), // 1-bit input: Input from the I/O clock network
            //.IOCLK1(), // 1-bit input: Input from the I/O clock network
            .ODATAIN() // 1-bit input: Output data input from output register or OSERDES2.
            //RST(), // 1-bit input: Reset to zero or 1/2 of total delay period
            //.T() // 1-bit input: 3-state input signal
         );
`endif
      end
   endgenerate

   reg [9:0] ADC_Data_tofifo;
   wire [9:0] trigger_level;

   always @(posedge ADC_clk_sample) begin
      ADC_Data_tofifo <= ADC_Data_delayed;

      //Input Validation Test #1: Uncomment the following
      //ADC_Data_tofifo <= 10'hAA;

      //Input Validation Test #2: uncomment following, which should
      //put a perfect ramp. Tests FIFO & USB interface for proper
      //syncronization
      //ADC_Data_tofifo <= ADC_Data_tofifo + 10'd1;

      //Input Validation Test #3: used for checking trigger location
      //if (DUT_trigger_i == 0)
      //   ADC_Data_tofifo <= 10'd512;
      //else
      //   ADC_Data_tofifo <= ADC_Data_tofifo + 10'd1;
   end

   wire [7:0] reg_status;

`ifdef CHIPSCOPE
// XXX ILA
  wire [35:0]                          chipscope_control;
  coregen_icon icon (
    .CONTROL0(chipscope_control) // INOUT BUS [35:0]
   );

   wire [127:0] cs_data;

   coregen_ila ila (
    .CONTROL(chipscope_control), // INOUT BUS [35:0]
    .CLK(ADC_clk_sample), // IN
    .TRIG0(cs_data) // IN BUS [127:0]
   );
`endif

   //1 = trigger on high, 0 = trigger on low
   wire trigger_mode;

   //1 = wait for trigger to be INACTIVE before arming (e.g.: avoid triggering immediatly)
   //0 = arm as soon as cmd_arm goes high (e.g.: if trigger is already in active state, trigger)
   wire trigger_wait;
   wire cmd_arm;
   wire trigger_now;
   wire [31:0] trigger_offset;
   wire [31:0] trigger_length;

   trigger_unit tu_inst(
      .reset(reset),
      .adc_clk(ADC_clk_sample),
      .adc_data(ADC_Data_tofifo),

       .ext_trigger_i(DUT_trigger_i),
      .trigger_level_i(trigger_mode),
      .trigger_wait_i(trigger_wait),
      .trigger_adclevel_i(trigger_level),
      .trigger_source_i(trigger_source),
      .trigger_now_i(trigger_now),
      .arm_i(cmd_arm),
      .arm_o(armed),
      .trigger_offset_i(trigger_offset),
      .trigger_length_o(trigger_length),
      .capture_go_o(adc_capture_go),
      .capture_done_i(adc_capture_done)
   );

   assign reg_status[0] = armed;
   assign reg_status[1] = ~adc_capture_go;
   assign reg_status[2] = DUT_trigger_i;
   assign reg_status[3] = dcm_locked;
   //reg_status[4]
   //reg_status[5]
   // XXX TODO: collapse, or keep same for backwards compatibility?
   assign reg_status[6] = 1'b0;

   wire [7:0] PWM_incr;

   wire [2:0] ADC_clk_selection; //0=internal, 1=external
   wire clkgen_selection;

   wire ddr_read_req;
   wire ddr_read_done;
   wire [31:0] ddr_read_address;
   wire [7:0]  ddrfifo_dout;
   wire ddrfifo_empty;
   wire ddrfifo_rd_en;

   wire cmdfifo_rxf;
   wire cmdfifo_txe;
   wire cmdfifo_rd;
   wire cmdfifo_wr;
   wire cmdfifo_isout;
   wire [7:0] cmdfifo_din;
   wire [7:0] cmdfifo_dout;

   wire [31:0] presamples;
   wire [31:0] samples_cnt;
   wire [31:0] maxsamples_limit;
   wire [31:0] maxsamples;



   wire [5:0] reg_address;
   wire [15:0] reg_bytecnt;
   wire [7:0] reg_datao;
   wire [15:0] reg_size;
   wire reg_read;
   wire reg_write;
   wire reg_addrvalid;
   wire [5:0] reg_hypaddress;
   wire reg_stream;
   wire [7:0] reg_datai_fifo;
   wire [7:0] reg_datai_oadc;
   wire [15:0] reg_hyplen;

   assign USB_D = cmdfifo_isout ? cmdfifo_dout : 8'bZ;
   assign cmdfifo_din = USB_D;

   reg_main_cwlite registers_mainctl_cwlite (
      .reset_i(reset_i), 
      .clk_usb(clk_usb), 
      .cwusb_din(cmdfifo_din), 
      .cwusb_dout(cmdfifo_dout), 
      .cwusb_rdn(USB_RDn), 
      .cwusb_wrn(USB_WRn),
      .cwusb_cen(USB_CEn),
      .cwusb_alen(USB_ALEn),
      .cwusb_addr(USB_Addr),
      .cwusb_isout(cmdfifo_isout), 
      .reg_address(reg_address), 
      .reg_bytecnt(reg_bytecnt), 
      .reg_datao(reg_datao), 
      .reg_datai(reg_datai_fifo | reg_datai_oadc | reg_datai_i), 
      .reg_size(reg_size), 
      .reg_read(reg_read), 
      .reg_write(reg_write), 
      .reg_addrvalid(reg_addrvalid), 
      .reg_stream(reg_stream),
      .reg_hypaddress(reg_hypaddress), 
      .reg_hyplen(reg_hyplen)
   );

   wire reg_stream_openadc;
   wire [15:0] reg_hyplen_openadc;
   wire clockreset;

   wire [7:0] clkgen_mul;
   wire [7:0] clkgen_div;
   wire clkgen_load;
   wire clkgen_done;
   wire clkgen_reset;

   wire [12:0] downsample;
   wire [1:0] fifo_mode;

   reg_openadc registers_openadc (
      .reset_i(reset_i),
      .reset_o(reset),
      .clk_usb(clk_usb),
      .reg_address(reg_address), 
      .reg_bytecnt(reg_bytecnt), 
      .reg_datao(reg_datai_oadc), 
      .reg_datai(reg_datao), 
      .reg_size(reg_size), 
      .reg_read(reg_read), 
      .reg_write(reg_write), 
      .reg_addrvalid(reg_addrvalid), 
      .reg_stream(reg_stream_openadc),
      .reg_hypaddress(reg_hypaddress), 
      .reg_hyplen(reg_hyplen_openadc),

      .gain(PWM_incr),
      .hilow(amp_hilo),
      .status(reg_status),         
      .cmd_arm(cmd_arm),
      .trigger_mode(trigger_mode),
      .trigger_wait(trigger_wait),  
      .trigger_source(trigger_source),
      .trigger_level(trigger_level),
      .trigger_now(trigger_now),
      .trigger_offset(trigger_offset),
      .trigger_length(trigger_length),
      .fifo_mode(fifo_mode),
      .extclk_frequency(extclk_frequency),
      .extclk_measure_src(extmeasure_src),
      .adcclk_frequency(adcclk_frequency),
      .phase_o(phase_requested),
      .phase_ld_o(phase_load),
      .phase_i(phase_actual),
      .phase_done_i(phase_done),
      .clkgen_mul(clkgen_mul),
      .clkgen_div(clkgen_div),
      .clkgen_load(clkgen_load),
      .clkgen_done(clkgen_done),
      .presamples_o(presamples),
      .maxsamples_i(maxsamples_limit),
      .maxsamples_o(maxsamples),
      .samples_i(samples_cnt),
      .downsample_o(downsample),
      .adc_clk_src_o(ADC_clk_selection),
      .clkgen_src_o(clkgen_selection),
      .clkblock_dcm_reset_o(clockreset),
      .clkblock_gen_reset_o(clkgen_reset),
      .clkblock_dcm_locked_i(dcm_locked),
      .clkblock_gen_locked_i(dcm_gen_locked),
      .fifo_stream(fifo_stream)
   );

   wire reg_stream_fifo;
   wire [15:0] reg_hyplen_fifo;
   reg_openadc_adcfifo registers_fiforead(
      .reset_i(reset_i),
      .clk_usb(clk_usb),
      .reg_address(reg_address), 
      .reg_bytecnt(reg_bytecnt), 
      .reg_datao(reg_datai_fifo), 
      .reg_datai(reg_datao), 
      .reg_size(reg_size), 
      .reg_read(reg_read), 
      .reg_write(reg_write), 
      .reg_addrvalid(reg_addrvalid), 
      .reg_stream(reg_stream_fifo),
      .reg_hypaddress(reg_hypaddress), 
      .reg_hyplen(reg_hyplen_fifo),
      .fifo_empty(ddrfifo_empty),
      .fifo_data(ddrfifo_dout),
      .fifo_rd_en(ddrfifo_rd_en)
   );

   assign reg_stream = reg_stream_fifo | reg_stream_openadc | reg_stream_i;
   assign reg_hyplen = reg_hyplen_fifo | reg_hyplen_openadc | reg_hyplen_i; 

   assign reg_reset_o = reset;
   assign reg_address_o = reg_address;
   assign reg_bytecnt_o = reg_bytecnt;
   assign reg_datao_o = reg_datao;
   assign reg_read_o = reg_read;
   assign reg_size_o = reg_size;
   assign reg_write_o = reg_write;
   assign reg_addrvalid_o = reg_addrvalid;
   assign reg_hypaddress_o = reg_hypaddress;


   clock_managment_advanced genclocks(
      .reset(reset | clockreset),
      .clk_usb(clk_usb),
      .clk_ext(DUT_CLK_i),   
      .adc_clk(ADC_clk),
`ifdef ADCCLK_FEEDBACK
      .adc_clk_feedback(ADC_clk_feedback),
`endif
      .clkgen(clkgen),
      .clkadc_source(ADC_clk_selection),
      .clkgen_source(clkgen_selection),
      .systemsample_clk(ADC_clk_sample),
      .phase_requested(phase_requested),
      .phase_actual(phase_actual),
      .phase_load(phase_load),
      .phase_done(phase_done),
      .clkgen_reset(reset | clkgen_reset),
      .clkgen_mul(clkgen_mul),
      .clkgen_div(clkgen_div),
      .clkgen_load(clkgen_load),
      .clkgen_done(clkgen_done),
      .dcm_adc_locked(dcm_locked),
      .dcm_gen_locked(dcm_gen_locked)
    );

   reg [8:0] PWM_accumulator;
   always @(posedge clk_usb) PWM_accumulator <= PWM_accumulator[7:0] + PWM_incr;

   //assign amp_hilo = 1'b0;
   assign amp_gain = PWM_accumulator[8];

   assign reg_status[4] = 1'b0;
   assign reg_status[5] = 1'b0;

   /* Segment trigger counter - independant) */
   reg [17:0] segment_trigger_count;
   reg segment_trigger_go;

   //Used to detect trigger transition in segment mode (segment mode only supports rising edge)
   reg DUT_trigger_i_old;
   always @(posedge ADC_clk_sample) begin
      DUT_trigger_i_old <= DUT_trigger_i;
   end

   // Maxsamples will be limited to FIFO size. The addition of +18'd1 on the ending point
   // is because the initial version of this had an off-by-one, to avoid API changes we just
   // continue this. The returned segment size is still smaller than expected by 1 but we
   // just let it ride baby!
   always @(posedge ADC_clk_sample) begin
      if ((DUT_trigger_i == 1'b1) && (DUT_trigger_i_old == 1'b0)) begin
        segment_trigger_go <= 1'b1;
      end else if (segment_trigger_count == (maxsamples[17:0]+18'd1)) begin
        segment_trigger_go <= 1'b0;
      end
   end

   always @(posedge ADC_clk_sample)
      if (segment_trigger_go == 1'b0)
        segment_trigger_count <= 18'd0;
      else
        segment_trigger_count <= segment_trigger_count + 18'd1;

   wire adc_write_mask;
   wire adc_write_mask_int;
   
   assign adc_write_mask_int = (fifo_mode == 2'b00) ? 1'b1 :
                               (fifo_mode == 2'b01) ? DUT_trigger_i :
                               (fifo_mode == 2'b10) ? segment_trigger_go :
                               1'b1;

   assign adc_write_mask = adc_write_mask_int | trigger_now;


   `ifndef NOFIFO // for clean compilation
   fifo_top fifo_top_inst(
      .reset_i(reset),

      //ADC Sample Input
      .adc_datain(ADC_Data_tofifo),
      .adc_sampleclk(ADC_clk_sample),
      .adc_or(ADC_OR),
      .adc_write_mask(adc_write_mask),
      .adc_trig_status(DUT_trigger_i),
      .adc_capture_go(adc_capture_go), //Set to '1' to start capture, keep at 1 until adc_capture_stop goes high
      .adc_capture_stop(adc_capture_done),
      .arm_i(armed),

      //DDR to USB Read Interface
      .clk_usb(clk_usb),
      .fifo_read_fifoen(ddrfifo_rd_en),
      .fifo_read_fifoempty(ddrfifo_empty),
      .fifo_read_data(ddrfifo_dout),

      .presample_i(presamples),
      .max_samples_i(maxsamples),
      .max_samples_o(maxsamples_limit),
      .samples_o(samples_cnt),
      .downsample_i(downsample),

      .fifo_overflow(reg_status[7]),
      .stream_mode(fifo_stream)

`ifdef CHIPSCOPE
      ,.chipscope_control(chipscope_control)
`endif
   );
   `endif


endmodule
`default_nettype wire
