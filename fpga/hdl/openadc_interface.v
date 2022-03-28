`include "includes.v"
`timescale 1 ns / 1 ps
`default_nettype none
/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more
details, or the codebase at http://www.chipwhisperer.com

Copyright (c) 2012-2021, NewAE Technology Inc. All rights reserved.
Author: Colin O'Flynn <coflynn@newae.com>

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

module openadc_interface #(
   parameter pBYTECNT_SIZE = 7
)(
    input  wire                         clk_usb, // 96 MHz
    output wire                         reset_o,

    output reg                          LED_armed, // Armed LED
    output reg                          LED_capture, // Capture in Progress LED (only illuminate during capture, very quick)

    input  wire                         mmcm_shutdown,

    // OpenADC Interface Pins
    input  wire [11:0]                  ADC_data,
    output wire                         ADC_clk_out,
    input  wire                         ADC_clk_feedback, // Feedback path for ADC Clock. If unused connect to ADC_clk_out
    input  wire                         pll_fpga_clk,
    input  wire                         PLL_STATUS,
    input  wire                         DUT_CLK_i, // target_hs1
    input  wire                         DUT_trigger_i,
    output reg                          trigger_adc,
    output wire                         trigger_sad,
    output wire                         amp_gain,
    output wire [7:0]                   fifo_dout,

    // Generated Clock for other uses
    output wire                         clkgen,

    // register interface
    input  wire [7:0]                   reg_address,
    input  wire [pBYTECNT_SIZE-1:0]     reg_bytecnt,
    input  wire [7:0]                   reg_datai,
    output wire [7:0]                   reg_datao,
    input  wire                         reg_read,
    input  wire                         reg_write,
    output wire                         fast_fifo_read,

    output wire                         fifo_error_flag,
    output wire                         stream_segment_available,

    output wire                         capture_active,

    output reg                          flash_pattern,

    // for debug only:
    output wire                         slow_fifo_wr,
    output wire                         slow_fifo_rd,
    output wire [8:0]                   la_debug

);

    wire        dcm_locked;
    wire        ADC_clk_sample;


    wire [15:0] phase_requested;
    wire       phase_load;
    wire       phase_done;

    wire       capture_go;
    wire       adc_capture_done;
    wire       armed;
    wire       reset;

    wire       dcm_gen_locked;
    wire       fifo_stream;
    wire [15:0] num_segments;
    wire [19:0] segment_cycles;
    wire        segment_cycle_counter_en;
    wire [1:0]  led_select;
    wire       data_source_select;
    wire [8:0] fifo_error_stat;
    wire [8:0] fifo_first_error_stat;
    wire [2:0] fifo_first_error_state;
    wire       no_clip_errors;
    wire       no_gain_errors;
    wire       clip_test;
    wire       clear_fifo_errors;
    wire       capture_done;
    wire       armed_and_ready;
    wire       fifo_rst;

    assign reset_o = reset;

   reg extclk_change;
   wire extclk_monitor_disabled;
   wire [31:0] extclk_limit;


   //Divide clock by 2^24 for heartbeat LED
   //Divide clock by 2^23 for frequency measurement
   reg [25:0] timer_heartbeat;
   reg freq_measure;
   reg timer_heartbeat22r;
   always @(posedge clk_usb)
      if (reset) begin
         timer_heartbeat <= 26'b0;
         timer_heartbeat22r <= 1'b0;
         freq_measure <= 1'b0;
      end 
      else begin
         timer_heartbeat <= timer_heartbeat +  26'd1;
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

   reg [24:0] pll_fpga_clk_heartbeat;
   always @(posedge pll_fpga_clk) pll_fpga_clk_heartbeat <= pll_fpga_clk_heartbeat +  25'd1;

   always @(posedge clk_usb) begin
       if (timer_heartbeat[25])
           flash_pattern <= ~timer_heartbeat[23];
   end


   always @(*) begin
      if (extclk_change) begin
         LED_armed = flash_pattern;
         LED_capture = flash_pattern;
      end
      else if (led_select == 2'b01) begin
         LED_armed = timer_heartbeat[24];
         LED_capture = clkgen_heartbeat[24];
      end
      else if (led_select == 2'b10) begin
         LED_armed = adc_fb_heartbeat[24];
         LED_capture = adc_out_heartbeat[24];
      end
      else if (led_select == 2'b11) begin
         LED_armed = pll_fpga_clk_heartbeat[24];
         LED_capture = extclk_change;
      end
      else begin
         LED_armed = armed;
         LED_capture = capture_active;
      end
   end

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

      if (extclk_monitor_disabled)
         extclk_change <= 1'b0;
      else if (freq_measure_ext && extclk_frequency_int &&
               ( (extclk_frequency > extclk_frequency_int)?  ((extclk_frequency - extclk_frequency_int) > extclk_limit) :
                                                             ((extclk_frequency_int - extclk_frequency) > extclk_limit) )
              )
         extclk_change <= 1'b1;
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
   wire [11:0] trigger_adclevel;

   always @(posedge ADC_clk_sample) begin
      ADC_data_tofifo <= data_source_select? ADC_data : datacounter;
      datacounter <= datacounter + 1;
   end

   wire [7:0] reg_status;
   wire fifo_overflow;

   //1 = trigger on high, 0 = trigger on low
   wire trigger_mode;

   //1 = wait for trigger to be INACTIVE before arming (e.g.: avoid triggering immediatly)
   //0 = arm as soon as cmd_arm goes high (e.g.: if trigger is already in active state, trigger)
   wire trigger_wait;
   wire cmd_arm_adc;
   wire cmd_arm_usb;
   wire trigger_now;
   wire [31:0] trigger_offset;
   wire [31:0] trigger_length;

   trigger_unit tu_inst(
      .reset                (reset),
      .adc_clk              (ADC_clk_sample),

      .trigger              (DUT_trigger_i),
      .trigger_level_i      (trigger_mode),
      .trigger_now_i        (trigger_now),
      .trigger_wait_i       (trigger_wait),
      .arm_i                (cmd_arm_adc),
      .arm_o                (armed),
      .trigger_offset_i     (trigger_offset),
      .trigger_length_o     (trigger_length),
      .capture_active_o     (capture_active),
      .capture_go_o         (capture_go),
      .capture_done_i       (adc_capture_done),
      .armed_and_ready      (armed_and_ready),

      .fifo_rst             (fifo_rst),
      .la_debug             (la_debug)
   );
   
   reg trigger_adc_allowed;
   reg cmd_arm_adc_r;
   // ADC trigger is simple except that we only want a single trigger generated:
   always @(posedge ADC_clk_sample) begin
       if (reset) begin
           trigger_adc_allowed <= 1'b0;
           trigger_adc <= 1'b0;
           cmd_arm_adc_r <= 1'b0;
       end
       else begin
           cmd_arm_adc_r <= cmd_arm_adc;

           if (trigger_adc_allowed)
               trigger_adc <= trigger_adclevel[11]? ADC_data_tofifo > trigger_adclevel:
                                                    ADC_data_tofifo < trigger_adclevel;
           else
               trigger_adc <= 1'b0;

           if (trigger_adc)
               trigger_adc_allowed <= 1'b0;
           else if (cmd_arm_adc && ~cmd_arm_adc_r)
               trigger_adc_allowed <= 1'b1;
       end
   end


   assign reg_status[0] = armed;
   assign reg_status[1] = ~capture_active;
   assign reg_status[2] = DUT_trigger_i;
   assign reg_status[3] = dcm_locked;
   assign reg_status[4] = PLL_STATUS;
   assign reg_status[5] = 1'b0;
   assign reg_status[6] = 1'b0;
   assign reg_status[7] = fifo_overflow;

   wire [7:0] PWM_incr;

   wire [2:0] ADC_clk_selection; //0=internal, 1=external
   wire clkgen_selection;

   wire fifo_empty;
   wire fifo_rd_en;
   wire low_res;
   wire low_res_lsb;
   wire [16:0] stream_segment_threshold;

   wire [14:0] presamples;
   wire [31:0] maxsamples_limit;
   wire [31:0] maxsamples;

   wire clockreset;

   wire clkgen_reset;

   wire [12:0] downsample;
   wire [7:0] reg_datao_oadc;
   wire [7:0] reg_datao_fifo;
   wire [7:0] reg_datao_mmcm_drp;
   wire [7:0] reg_datao_sad;

   wire [31:0] fifo_read_count;
   wire [31:0] fifo_read_count_error_freeze;

   wire adc_clkgen_power_down;
   wire clkgen_power_down;

   wire [7:0] underflow_count;
   wire no_underflow_errors;

   assign reg_datao = reg_datao_oadc | reg_datao_fifo | reg_datao_mmcm_drp | reg_datao_sad;

   sad #(
       .pBYTECNT_SIZE           (pBYTECNT_SIZE),
       .pREF_SAMPLES            (128),
       .pBITS_PER_SAMPLE        (8)
   ) U_sad (
       .reset                   (reset        ),
       .adc_datain              (ADC_data_tofifo),
       .adc_sampleclk           (ADC_clk_sample),
       .arm_i                   (armed        ),
       .clk_usb                 (clk_usb      ),
       .reg_address             (reg_address  ),
       .reg_bytecnt             (reg_bytecnt  ),
       .reg_datai               (reg_datai    ),
       .reg_datao               (reg_datao_sad),
       .reg_read                (reg_read     ),
       .reg_write               (reg_write    ),
       .trigger                 (trigger_sad  )
   );

   reg_openadc #(
      .pBYTECNT_SIZE    (pBYTECNT_SIZE)
   ) U_reg_openadc (
      .reset_i                      (1'b0),
      .reset_o                      (reset),
      .clk_usb                      (clk_usb),
      .adc_sampleclk                (ADC_clk_sample),
      .reg_address                  (reg_address), 
      .reg_bytecnt                  (reg_bytecnt), 
      .reg_datao                    (reg_datao_oadc), 
      .reg_datai                    (reg_datai), 
      .reg_read                     (reg_read), 
      .reg_write                    (reg_write), 

      .gain                         (PWM_incr),
      .status                       (reg_status),         
      .cmd_arm_adc                  (cmd_arm_adc),
      .cmd_arm_usb                  (cmd_arm_usb),
      .trigger_mode                 (trigger_mode),
      .trigger_wait                 (trigger_wait),  
      .trigger_adclevel             (trigger_adclevel),
      .trigger_now                  (trigger_now),
      .trigger_offset               (trigger_offset),
      .trigger_length               (trigger_length),
      .extclk_frequency             (extclk_frequency),
      .extclk_measure_src           (extmeasure_src),
      .adcclk_frequency             (adcclk_frequency),
      .phase_o                      (phase_requested),
      .phase_ld_o                   (phase_load),
      .presamples_o                 (presamples),
      .maxsamples_i                 (maxsamples_limit),
      .maxsamples_o                 (maxsamples),
      .downsample_o                 (downsample),
      .data_source_select           (data_source_select),
      .adc_clk_src_o                (ADC_clk_selection),
      .clkgen_src_o                 (clkgen_selection),
      .clkblock_dcm_reset_o         (clockreset),
      .clkblock_gen_reset_o         (clkgen_reset),
      .clkblock_dcm_locked_i        (dcm_locked),
      .clkblock_gen_locked_i        (dcm_gen_locked),
      .fifo_stream                  (fifo_stream),
      .num_segments                 (num_segments),
      .segment_cycles               (segment_cycles),
      .segment_cycle_counter_en     (segment_cycle_counter_en),
      .led_select                   (led_select),
      .no_clip_errors               (no_clip_errors),
      .no_gain_errors               (no_gain_errors),
      .clip_test                    (clip_test),

      .extclk_change                (extclk_change),
      .extclk_monitor_disabled      (extclk_monitor_disabled),
      .extclk_limit                 (extclk_limit),

      .adc_clkgen_power_down        (adc_clkgen_power_down),
      .clkgen_power_down            (clkgen_power_down    )
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
      .fifo_empty           (fifo_empty),
      .fifo_rd_en           (fifo_rd_en),
      .low_res              (low_res),
      .low_res_lsb          (low_res_lsb),
      .fast_fifo_read_mode  (fast_fifo_read),
      .stream_segment_threshold (stream_segment_threshold),
      .fifo_error_stat      (fifo_error_stat),
      .fifo_first_error_stat(fifo_first_error_stat),
      .fifo_first_error_state (fifo_first_error_state),
      .fifo_read_count      (fifo_read_count),
      .fifo_read_count_error_freeze (fifo_read_count_error_freeze),
      .underflow_count      (underflow_count),
      .no_underflow_errors  (no_underflow_errors),
      .clear_fifo_errors    (clear_fifo_errors),
      .capture_done         (capture_done)
   );


`ifdef FPGA_CLKGEN
   clock_managment_advanced genclocks(
      .reset                (reset | clockreset),
      .clk_usb              (clk_usb),
      .clk_ext              (DUT_CLK_i),   
      .adc_clk_out          (ADC_clk_out),
      .adc_clk_feedback     (ADC_clk_feedback),
      .clkgen               (clkgen),
      .clkadc_source        (ADC_clk_selection),
      .clkgen_source        (clkgen_selection),
      .systemsample_clk     (ADC_clk_sample),
      .phase_requested      (phase_requested),
      .phase_load           (phase_load),
      .phase_done           (phase_done),
      .clkgen_reset         (reset | clkgen_reset),
      .dcm_adc_locked       (dcm_locked),
      .dcm_gen_locked       (dcm_gen_locked),

      .reg_address          (reg_address),
      .reg_bytecnt          (reg_bytecnt), 
      .reg_datao            (reg_datao_mmcm_drp), 
      .reg_datai            (reg_datai), 
      .reg_read             (reg_read), 
      .reg_write            (reg_write), 

      .adc_clkgen_power_down(adc_clkgen_power_down),
      .clkgen_power_down    (clkgen_power_down),
      .mmcm_shutdown        (mmcm_shutdown)
    );
`else
    // TODO-IMPORTANT NOTE! for some unknown reason, simulations fail without
    // FPGA_CLKGEN. There seems to be some problem with the fast FIFO in
    // fifo_top_husky: all its inputs appear to be correctly driven, but its
    // "empty" flag always remains set.
    assign ADC_clk_out = clk_usb;
    assign ADC_clk_sample = ADC_clk_feedback;
    assign clkgen = clk_usb;
    assign phase_done = 1'b0;
    assign dcm_locked = 1'b0;
    assign dcm_gen_locked = 1'b0;
    assign reg_datao_mmcm_drp = 8'b0;

`endif


   reg [8:0] PWM_accumulator;
   always @(posedge clk_usb) begin
      if (reset)
         PWM_accumulator <= 0;
      else
         PWM_accumulator <= PWM_accumulator[7:0] + PWM_incr;
   end

   assign amp_gain = PWM_accumulator[8];


   fifo_top_husky U_fifo(
      .reset                    (reset),

      .adc_datain               (ADC_data_tofifo),
      .adc_sampleclk            (ADC_clk_sample),
      .capture_active           (capture_active),
      .capture_go               (capture_go),
      .adc_capture_stop         (adc_capture_done),
      .arm_i                    (armed),
      .arm_usb                  (cmd_arm_usb),
      .num_segments             (num_segments),
      .segment_cycles           (segment_cycles),
      .segment_cycle_counter_en (segment_cycle_counter_en),

      .clk_usb                  (clk_usb),
      .fifo_read_fifoen         (fifo_rd_en),
      .fifo_read_fifoempty      (fifo_empty),
      .fifo_read_data           (fifo_dout),
      .low_res                  (low_res),
      .low_res_lsb              (low_res_lsb),
      .fast_fifo_read_mode      (fast_fifo_read),
      .stream_segment_threshold (stream_segment_threshold),

      .presample_i              (presamples),
      .max_samples_i            (maxsamples),
      .max_samples_o            (maxsamples_limit),
      .downsample_i             (downsample),

      .fifo_overflow            (fifo_overflow),
      .stream_mode              (fifo_stream),
      .error_flag               (fifo_error_flag),
      .error_stat               (fifo_error_stat),
      .first_error_stat         (fifo_first_error_stat),
      .first_error_state        (fifo_first_error_state),
      .clear_fifo_errors        (clear_fifo_errors),
      .stream_segment_available (stream_segment_available),
      .no_clip_errors           (no_clip_errors),
      .no_gain_errors           (no_gain_errors),
      .clip_test                (clip_test),
      .underflow_count          (underflow_count),
      .no_underflow_errors      (no_underflow_errors),
      .capture_done             (capture_done),
      .armed_and_ready          (armed_and_ready),

      .slow_fifo_wr             (slow_fifo_wr),
      .slow_fifo_rd             (slow_fifo_rd),
      .fifo_read_count          (fifo_read_count),
      .fifo_read_count_error_freeze (fifo_read_count_error_freeze),
      .fifo_rst                 (fifo_rst)
   );


endmodule
`default_nettype wire
