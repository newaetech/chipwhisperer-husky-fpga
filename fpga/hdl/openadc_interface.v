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
module openadc_interface #(
   parameter pBYTECNT_SIZE = 7
)(
    input  wire                         reset_i,
    input  wire                         clk_usb, // 96 MHz
    output wire                         reset_o,

    output wire                         LED_hbeat, // Heartbeat LED
    output wire                         LED_armed, // Armed LED
    output wire                         LED_capture, // Capture in Progress LED (only illuminate during capture, very quick)
    output wire                         LED_ADCDCMUnlock, // MMCM for ADC is unlocked
    output wire                         LED_CLKGENDCMUnlock, // MMCM for CLKGEN is unlocked

    // OpenADC Interface Pins
    input  wire [11:0]                  ADC_data,
    output wire                         ADC_clk_out,
    input  wire                         ADC_clk_feedback, // Feedback path for ADC Clock. If unused connect to ADC_clk_out
    input  wire                         DUT_CLK_i, // target_hs1
    input  wire                         DUT_trigger_i,
    output wire                         amp_gain,
    output wire                         amp_hilo,

    // Generated Clock for other uses
    output wire                         clkgen,

    // register interface
    input  wire [7:0]                   reg_address,
    input  wire [pBYTECNT_SIZE-1:0]     reg_bytecnt,
    input  wire [7:0]                   reg_datai,
    output wire [7:0]                   reg_datao,
    input  wire                         reg_read,
    input  wire                         reg_write,
    input  wire                         reg_addrvalid
);

    wire        dcm_locked;
    wire        ADC_clk_sample;


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
    wire       data_source_select;

    assign reset_o = reset;

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


   reg [11:0] ADC_data_tofifo;
   reg [11:0] datacounter = 0;
   wire [9:0] trigger_level; // TODO: 12 bits

   always @(posedge ADC_clk_sample) begin
      ADC_data_tofifo <= data_source_select? ADC_data : datacounter;
      datacounter <= datacounter + 1;
      //ADC_data_tofifo <= ADC_data;

      //Input Validation Test #1: Uncomment the following
      //ADC_data_tofifo <= 12'h3AA;

      //Input Validation Test #2: uncomment following, which should
      //put a perfect ramp. Tests FIFO & USB interface for proper
      //syncronization
      //ADC_data_tofifo <= ADC_data_tofifo + 12'd1;

      //Input Validation Test #3: used for checking trigger location
      //if (DUT_trigger_i == 0)
      //   ADC_data_tofifo <= 12'd512;
      //else
      //   ADC_data_tofifo <= ADC_data_tofifo + 12'd1;
   end

   wire [7:0] reg_status;

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
      .adc_data(ADC_data_tofifo[9:0]), // TODO

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
   wire low_res;
   wire low_res_lsb;

   wire [31:0] presamples;
   wire [31:0] samples_cnt;
   wire [31:0] maxsamples_limit;
   wire [31:0] maxsamples;

   wire clockreset;

   wire [7:0] clkgen_mul;
   wire [7:0] clkgen_div;
   wire clkgen_load;
   wire clkgen_done;
   wire clkgen_reset;

   wire [12:0] downsample;
   wire [1:0] fifo_mode;
   wire [7:0] reg_datao_oadc;
   wire [7:0] reg_datao_fifo;

   assign reg_datao = reg_datao_oadc | reg_datao_fifo;

   reg_openadc #(
      .pBYTECNT_SIZE    (pBYTECNT_SIZE)
   ) U_reg_openadc (
      .reset_i(reset_i),
      .reset_o(reset),
      .clk_usb(clk_usb),
      .adc_sampleclk(ADC_clk_sample),
      .reg_address(reg_address), 
      .reg_bytecnt(reg_bytecnt), 
      .reg_datao(reg_datao_oadc), 
      .reg_datai(reg_datai), 
      .reg_read(reg_read), 
      .reg_write(reg_write), 
      .reg_addrvalid(reg_addrvalid), 

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
      .data_source_select(data_source_select),
      .adc_clk_src_o(ADC_clk_selection),
      .clkgen_src_o(clkgen_selection),
      .clkblock_dcm_reset_o(clockreset),
      .clkblock_gen_reset_o(clkgen_reset),
      .clkblock_dcm_locked_i(dcm_locked),
      .clkblock_gen_locked_i(dcm_gen_locked),
      .fifo_stream(fifo_stream)
   );

   reg_openadc_adcfifo #(
      .pBYTECNT_SIZE    (pBYTECNT_SIZE)
   ) U_reg_openadc_adcfifo (
      .reset_i(reset_i),
      .clk_usb(clk_usb),
      .reg_address(reg_address), 
      .reg_bytecnt(reg_bytecnt), 
      .reg_datao(reg_datao_fifo), 
      .reg_datai(reg_datai), 
      .reg_read(reg_read), 
      .reg_write(reg_write), 
      .reg_addrvalid(reg_addrvalid), 
      .fifo_empty(ddrfifo_empty),
      .fifo_data(ddrfifo_dout),
      .fifo_rd_en(ddrfifo_rd_en),
      .low_res(low_res),
      .low_res_lsb(low_res_lsb)
   );


   clock_managment_advanced genclocks(
      .reset(reset | clockreset),
      .clk_usb(clk_usb),
      .clk_ext(DUT_CLK_i),   
      .adc_clk_out(ADC_clk_out),
      .adc_clk_feedback(ADC_clk_feedback),
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

   // TODO - clean this up:
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


   fifo_top_husky U_fifo(
      .reset                    (reset),

      .adc_datain               (ADC_data_tofifo),
      .adc_sampleclk            (ADC_clk_sample),
      .adc_write_mask           (adc_write_mask),
      .adc_capture_go           (adc_capture_go), //Set to '1' to start capture, keep at 1 until adc_capture_stop goes high
      .adc_capture_stop         (adc_capture_done),
      .arm_i                    (armed),

      .clk_usb                  (clk_usb),
      .fifo_read_fifoen         (ddrfifo_rd_en),
      .fifo_read_fifoempty      (ddrfifo_empty),
      .fifo_read_data           (ddrfifo_dout),
      .low_res                  (low_res),
      .low_res_lsb              (low_res_lsb),

      .presample_i              (presamples),
      .max_samples_i            (maxsamples),
      .max_samples_o            (maxsamples_limit),
      .samples_o                (samples_cnt),
      .downsample_i             (downsample),

      .fifo_overflow            (reg_status[7]),
      .stream_mode              (fifo_stream)
   );


endmodule
`default_nettype wire
