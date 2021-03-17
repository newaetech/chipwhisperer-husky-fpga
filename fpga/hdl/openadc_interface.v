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

    output reg                          LED_armed, // Armed LED
    output reg                          LED_capture, // Capture in Progress LED (only illuminate during capture, very quick)
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
    input  wire                         reg_addrvalid,
    output wire                         fast_fifo_read,

    output wire                         fifo_error_flag,
    output wire                         stream_segment_available
);

    wire        dcm_locked;
    wire        ADC_clk_sample;


    wire [8:0] phase_requested;
    wire [8:0] phase_actual;
    wire       phase_load;
    wire       phase_done;

    wire       adc_capture_go;
    wire       adc_segment_go;
    wire       adc_capture_done;
    wire       armed;
    wire       reset;

    wire       dcm_gen_locked;
    wire       trigger_source;
    wire       fifo_stream;
    wire [15:0] num_segments;
    wire [19:0] segment_cycles;
    wire [1:0]  led_select;
    wire       data_source_select;

    assign reset_o = reset;

   //Divide clock by 2^24 for heartbeat LED
   //Divide clock by 2^23 for frequency measurement
   reg [24:0] timer_heartbeat;
   reg freq_measure;
   reg timer_heartbeat22r;
   always @(posedge clk_usb)
      if (reset) begin
         timer_heartbeat <= 25'b0;
         timer_heartbeat22r <= 1'b0;
         freq_measure <= 1'b0;
      end 
      else begin
         timer_heartbeat <= timer_heartbeat +  25'd1;
         timer_heartbeat22r <= timer_heartbeat[22];
         if (timer_heartbeat[22] && ~timer_heartbeat22r)
            freq_measure <= 1'b1;
         else
            freq_measure <= 1'b0;
      end


   reg [24:0] clkgen_heartbeat;
   always @(posedge clkgen) clkgen_heartbeat <= clkgen_heartbeat +  25'd1;

   reg [24:0] adc_fb_heartbeat;
   always @(posedge ADC_clk_feedback) adc_fb_heartbeat <= adc_fb_heartbeat +  25'd1;

   reg [24:0] adc_out_heartbeat;
   always @(posedge ADC_clk_out) adc_out_heartbeat <= adc_out_heartbeat +  25'd1;

   always @(*) begin
      if (led_select == 2'b01) begin
         LED_armed = timer_heartbeat[24];
         LED_capture = clkgen_heartbeat[24];
      end
      else if (led_select == 2'b10) begin
         LED_armed = adc_fb_heartbeat[24];
         LED_capture = adc_out_heartbeat[24];
      end
      else begin
         LED_armed = armed;
         LED_capture = adc_capture_go;
      end
   end

   assign LED_ADCDCMUnlock = ~dcm_locked;
   assign LED_CLKGENDCMUnlock = ~dcm_gen_locked;

   wire freq_measure_adc;
   wire freq_measure_ext;
   cdc_pulse U_freq_measure_adc (
      .reset_i       (reset),
      .src_clk       (clk_usb),
      .src_pulse     (freq_measure),
      .dst_clk       (ADC_clk_sample),
      .dst_pulse     (freq_measure_adc)
   );

   cdc_pulse U_freq_measure_ext (
      .reset_i       (reset),
      .src_clk       (clk_usb),
      .src_pulse     (freq_measure),
      .dst_clk       (extmeasure_clk),
      .dst_pulse     (freq_measure_ext)
   );



   wire extmeasure_clk;
   wire extmeasure_src;
   assign extmeasure_clk = (extmeasure_src) ? clkgen : DUT_CLK_i;

   reg [31:0] extclk_frequency_int;
   reg [31:0] adcclk_frequency_int;
   reg [31:0] extclk_frequency;
   reg [31:0] adcclk_frequency;

   always @(posedge extmeasure_clk) begin
      if (freq_measure_ext) begin
         extclk_frequency_int <= 32'd1;
         extclk_frequency <= extclk_frequency_int;
      end 
      else begin
         extclk_frequency_int <= extclk_frequency_int + 32'd1;
      end
   end

   always @(posedge ADC_clk_sample) begin
      if (freq_measure_adc) begin
         adcclk_frequency_int <= 32'd1;
         adcclk_frequency <= adcclk_frequency_int;
      end 
      else begin
         adcclk_frequency_int <= adcclk_frequency_int + 32'd1;
      end
   end


   reg [11:0] ADC_data_tofifo;
   reg [11:0] datacounter = 0;
   wire [9:0] trigger_level; // TODO: 12 bits

   always @(posedge ADC_clk_sample) begin
      ADC_data_tofifo <= data_source_select? ADC_data : datacounter;
      datacounter <= datacounter + 1;
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
      .segment_go_o(adc_segment_go),
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

   wire [7:0]  fifo_dout;
   wire fifo_empty;
   wire fifo_rd_en;
   wire low_res;
   wire low_res_lsb;
   wire [31:0] stream_segment_size;

   wire [31:0] presamples;
   wire [31:0] samples_cnt;
   wire [31:0] maxsamples_limit;
   wire [31:0] maxsamples;

   wire clockreset;

   wire clkgen_reset;

   wire [12:0] downsample;
   wire [1:0] fifo_mode;
   wire [7:0] reg_datao_oadc;
   wire [7:0] reg_datao_fifo;
   wire [7:0] reg_datao_mmcm_drp;

   assign reg_datao = reg_datao_oadc | reg_datao_fifo | reg_datao_mmcm_drp;

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
      .hilow(amp_hilo), // TODO- obsolete
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
      .fifo_stream(fifo_stream),
      .num_segments(num_segments),
      .segment_cycles(segment_cycles),
      .led_select(led_select)
   );

   reg_openadc_adcfifo #(
      .pBYTECNT_SIZE    (pBYTECNT_SIZE)
   ) U_reg_openadc_adcfifo (
      .reset_i              (reset),
      .clk_usb              (clk_usb),
      .reg_address          (reg_address), 
      .reg_bytecnt          (reg_bytecnt), 
      .reg_datao            (reg_datao_fifo), 
      .reg_datai            (reg_datai), 
      .reg_read             (reg_read), 
      .reg_write            (reg_write), 
      .reg_addrvalid        (reg_addrvalid), 
      .fifo_empty           (fifo_empty),
      .fifo_data            (fifo_dout),
      .fifo_rd_en           (fifo_rd_en),
      .low_res              (low_res),
      .low_res_lsb          (low_res_lsb),
      .fast_fifo_read_mode  (fast_fifo_read),
      .stream_segment_size  (stream_segment_size)
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
      .dcm_adc_locked(dcm_locked),
      .dcm_gen_locked(dcm_gen_locked),

      .reg_address(reg_address),
      .reg_bytecnt(reg_bytecnt), 
      .reg_datao(reg_datao_mmcm_drp), 
      .reg_datai(reg_datai), 
      .reg_read(reg_read), 
      .reg_write(reg_write), 
      .reg_addrvalid(reg_addrvalid) 

    );

   reg [8:0] PWM_accumulator;
   always @(posedge clk_usb) begin
      if (reset)
         PWM_accumulator <= 0;
      else
         PWM_accumulator <= PWM_accumulator[7:0] + PWM_incr;
   end

   //assign amp_hilo = 1'b0;
   assign amp_gain = PWM_accumulator[8];

   assign reg_status[4] = 1'b0;
   assign reg_status[5] = 1'b0;

   /*
   wire adc_write_mask;
   wire adc_write_mask_int;
   
   assign adc_write_mask_int = (fifo_mode == 2'b00) ? 1'b1 :
                               (fifo_mode == 2'b01) ? DUT_trigger_i :
                               (fifo_mode == 2'b10) ? segment_trigger_go :
                               1'b1;

   assign adc_write_mask = adc_write_mask_int | trigger_now;
   */
   wire adc_write_mask = 1'b1; // TODO: clean up / remove if no longer required


   fifo_top_husky U_fifo(
      .reset                    (reset),

      .adc_datain               (ADC_data_tofifo),
      .adc_sampleclk            (ADC_clk_sample),
      .adc_write_mask           (adc_write_mask),
      .adc_capture_go           (adc_capture_go), //Set to '1' to start capture, keep at 1 until adc_capture_stop goes high
      .adc_segment_go           (adc_segment_go),
      .adc_capture_stop         (adc_capture_done),
      .arm_i                    (armed),
      .num_segments             (num_segments),
      .segment_cycles           (segment_cycles),

      .clk_usb                  (clk_usb),
      .fifo_read_fifoen         (fifo_rd_en),
      .fifo_read_fifoempty      (fifo_empty),
      .fifo_read_data           (fifo_dout),
      .low_res                  (low_res),
      .low_res_lsb              (low_res_lsb),
      .fast_fifo_read_mode      (fast_fifo_read),
      .stream_segment_size      (stream_segment_size),

      .presample_i              (presamples),
      .max_samples_i            (maxsamples),
      .max_samples_o            (maxsamples_limit),
      .samples_o                (samples_cnt),
      .downsample_i             (downsample),

      .fifo_overflow            (reg_status[7]),
      .stream_mode              (fifo_stream),
      .error_flag               (fifo_error_flag),
      .stream_segment_available (stream_segment_available)
   );


endmodule
`default_nettype wire
