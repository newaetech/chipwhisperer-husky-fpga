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
    input  wire                         ADC_slow_clk_even,      // used by sad_x2_slowclock only
    input  wire                         ADC_slow_clk_odd,       // used by sad_x2_slowclock only
    output wire                         reset_o,
    input  wire                         xadc_error,

    output reg                          LED_armed, // Armed LED
    output reg                          LED_capture, // Capture in Progress LED (only illuminate during capture, very quick)
    output reg                          freq_measure,
    output wire                         O_disable_adc_error,

    // OpenADC Interface Pins
    input  wire [11:0]                  ADC_data,
    input  wire                         ADC_clk_feedback, // Feedback path for ADC Clock. If unused connect to ADC_clk_out
    input  wire                         pll_fpga_clk,
    input  wire                         PLL_STATUS,
    input  wire                         DUT_CLK_i, // target_hs1
    input  wire                         DUT_trigger_i,
    input  wire                         trigger_io4_i, // debug only
    input  wire                         sad_active,
    input  wire                         edge_trigger_active,
    input  wire                         adc_trigger_active,
    output reg                          trigger_adc,
    output wire                         trigger_sad,
    output wire                         trigger_edge_counter,
    output wire                         amp_gain,
    output wire [7:0]                   fifo_dout,
    input  wire                         trace_flushing,
    input  wire                         la_flushing,
    input  wire                         shared_fifo_empty,

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
    input  wire                         trigger_in,

    output reg                          flash_pattern,

    // for UART triggering:
    output wire                         cmd_arm_usb,

`ifdef PRO
    // DDR3 (Pro) stuff:
    output wire                         O_xo_en,
    output wire                         O_vddr_enable,
    input  wire                         I_vddr_pgood,

    output wire [15:0]                  ddr3_addr,
    output wire [2:0]                   ddr3_ba,
    output wire                         ddr3_cas_n,
    output wire                         ddr3_ck_n,
    output wire                         ddr3_ck_p,
    output wire                         ddr3_cke,
    output wire                         ddr3_ras_n,
    output wire                         ddr3_reset_n,
    output wire                         ddr3_we_n,
    inout  wire [7:0]                   ddr3_dq,
    inout  wire                         ddr3_dqs_n,
    inout  wire                         ddr3_dqs_p,
    output wire                         ddr3_dm,
    output wire                         ddr3_cs_n,
    output wire                         ddr3_odt,
    input  wire [11:0]                  temp_out,

    // for LA and trace in Pro:
    output wire                         ui_clk,
    output wire                         preddr_trace_rd,
    input  wire [63:0]                  preddr_trace_data,
    input  wire                         preddr_trace_empty,
    output wire                         preddr_la_rd,
    input  wire [63:0]                  preddr_la_data,
    input  wire                         preddr_la_empty,
    input  wire                         capture_go_trace,
    input  wire                         capture_go_la,
    input  wire                         write_done_trace,
    input  wire                         write_done_la,
    output wire                         clear_fifo_errors,
    input  wire [1:0]                   trace_fifo_errors,
    input  wire [1:0]                   la_fifo_errors,
    input  wire                         tb_ui_clk,
    `ifdef CW310
        input wire                      ADC_clk_fbp,
        input wire                      ADC_clk_fbn,
    `endif
`endif

    // for trigger sequencing:
    output wire                         armed_and_ready,

    // for debug only:
    output wire                         slow_fifo_wr,
    output wire                         slow_fifo_rd,
    output wire [8:0]                   la_debug,
    output wire [7:0]                   la_debug2,
    output wire [7:0]                   fifo_debug,
    output wire [7:0]                   edge_trigger_debug

);

    wire        ADC_clk_sample;
    wire        armed;

    wire       capture_go;
    wire       adc_capture_done;
    wire       reset;

    wire       fast_fifo_empty;
    wire       fifo_stream;
    wire [15:0] num_segments;
    wire [19:0] segment_cycles;
    wire        segment_cycle_counter_en;
    wire [1:0]  led_select;
    wire       data_source_select;
    wire [13:0] fifo_error_stat;
    wire [13:0] fifo_first_error_stat;
    wire [2:0] fifo_first_error_state;
    wire       no_clip_errors;
    wire       no_gain_errors;
    wire       capture_done;
    wire [2:0] fifo_state;
    wire [2:0] ddr_state;
    wire       trigger_too_soon;
    wire       adc_flushing;
    wire       postddr_flush;

    wire         single_write;
    wire         single_read;
    wire [29:0]  single_address;
    wire [63:0]  single_write_data;
    wire [63:0]  single_read_data;
    wire         ddr_read_data_done;
    wire [29:0]  ddr_la_start_address;
    wire [29:0]  ddr_trace_start_address;
    wire         ddr_start_la_read;
    wire         ddr_start_trace_read;
    wire         ddr_start_adc_read;
    wire         ddr_single_done;
    wire         ddr_write_data_done;

    wire [6:0] ddr_stat;
    wire       ddr_test_pass;
    wire       ddr_test_fail;
    wire       ddr_test_clear_fail;
    wire       ddr_rwtest_en;
    wire       use_ddr;

    assign reset_o = reset;

   reg extclk_change;
   reg extclk_change_usb;
   wire extclk_monitor_disabled;
   wire [31:0] extclk_limit;

`ifndef PRO
    wire       clear_fifo_errors;
    wire       preddr_trace_empty = 1'b1;
    wire       preddr_la_empty = 1'b1;
`endif

   //Divide clock by 2^24 for heartbeat LED
   //Divide clock by 2^23 for frequency measurement
   reg [25:0] timer_heartbeat;
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
   always @(posedge clk_usb) clkgen_heartbeat <= clkgen_heartbeat +  25'd1;

   reg [24:0] adc_fb_heartbeat;
   always @(posedge ADC_clk_feedback) adc_fb_heartbeat <= adc_fb_heartbeat +  25'd1;

   reg [24:0] adc_out_heartbeat;
   always @(posedge DUT_CLK_i) adc_out_heartbeat <= adc_out_heartbeat +  25'd1;

   reg [24:0] pll_fpga_clk_heartbeat;
   always @(posedge pll_fpga_clk) pll_fpga_clk_heartbeat <= pll_fpga_clk_heartbeat +  25'd1;

   always @(posedge clk_usb) begin
       if (timer_heartbeat[25])
           flash_pattern <= ~timer_heartbeat[23];
   end


   always @(*) begin
      if (extclk_change_usb) begin
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
         LED_capture = extclk_change_usb;
      end
      else begin
         LED_armed = armed;
         LED_capture = capture_active;
      end
   end

   wire freq_measure_adc;
   wire freq_measure_ui;
   wire freq_measure_pll;
   wire freq_measure_ext;
   wire freq_measure_back;
   cdc_pulse U_freq_measure_adc (
      .reset_i       (reset),
      .src_clk       (clk_usb),
      .src_pulse     (freq_measure),
      .dst_clk       (ADC_clk_sample),
      .dst_pulse     (freq_measure_adc)
   );

   cdc_pulse U_freq_measure_pll (
      .reset_i       (reset),
      .src_clk       (clk_usb),
      .src_pulse     (freq_measure),
      .dst_clk       (pll_fpga_clk),
      .dst_pulse     (freq_measure_pll)
   );

   cdc_pulse U_freq_measure_ext (
      .reset_i       (reset),
      .src_clk       (clk_usb),
      .src_pulse     (freq_measure),
      .dst_clk       (DUT_CLK_i),
      .dst_pulse     (freq_measure_ext)
   );

   // by going back to USB clock we'll know if DUT_CLK_i is alive
   cdc_pulse U_freq_measure_ext_back (
      .reset_i       (reset),
      .src_clk       (DUT_CLK_i),
      .src_pulse     (freq_measure_ext),
      .dst_clk       (clk_usb),
      .dst_pulse     (freq_measure_back)
   );


   reg [31:0] extclk_frequency_int;
   reg [31:0] adcclk_frequency_int;
   reg [31:0] pllclk_frequency_int;
   reg [31:0] extclk_frequency;
   reg [31:0] adcclk_frequency;
   reg [31:0] pllclk_frequency;

   always @(posedge DUT_CLK_i) begin
      if (freq_measure_ext) begin
         extclk_frequency_int <= 32'd1;
         extclk_frequency <= extclk_frequency_int;
      end 
      else begin
         extclk_frequency_int <= extclk_frequency_int + 32'd1;
      end

      if (extclk_monitor_disabled)
         extclk_change <= 1'b0;
      else if (freq_measure_ext && (extclk_frequency_int > 0) &&
               ( (extclk_frequency > extclk_frequency_int)?  ((extclk_frequency - extclk_frequency_int) > extclk_limit) :
                                                             ((extclk_frequency_int - extclk_frequency) > extclk_limit) )
              )
         extclk_change <= 1'b1;
   end

   // replicate some of the logic above in clk_usb domain so that clearing the error works when DUT_CLK_i goes away:
   always @(posedge clk_usb) begin
       if (extclk_monitor_disabled)
           extclk_change_usb <= 1'b0;
       else if (freq_measure_back)
           extclk_change_usb <= extclk_change;
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

`ifdef PRO
   reg [31:0] uiclk_frequency_int;
   reg [31:0] uiclk_frequency;
   always @(posedge ui_clk) begin
      if (freq_measure_ui) begin
         uiclk_frequency_int <= 32'd1;
         uiclk_frequency <= uiclk_frequency_int;
      end 
      else begin
         uiclk_frequency_int <= uiclk_frequency_int + 32'd1;
      end
   end
   cdc_pulse U_freq_measure_ui (
      .reset_i       (reset),
      .src_clk       (clk_usb),
      .src_pulse     (freq_measure),
      .dst_clk       (ui_clk),
      .dst_pulse     (freq_measure_ui)
   );
`else
   wire [31:0] uiclk_frequency = 32'b0;
`endif // PRO

   always @(posedge pll_fpga_clk) begin
      if (freq_measure_pll) begin
         pllclk_frequency_int <= 32'd1;
         pllclk_frequency <= pllclk_frequency_int;
      end 
      else begin
         pllclk_frequency_int <= pllclk_frequency_int + 32'd1;
      end
   end


   reg [11:0] ADC_data_tofifo_pre;
   reg [11:0] ADC_data_tofifo;
   reg [11:0] datacounter = 0;
   wire [11:0] trigger_adclevel;

   always @(posedge ADC_clk_sample) begin
      ADC_data_tofifo <= ADC_data_tofifo_pre; // resample to account for delay in fifo_top_husky.v
      ADC_data_tofifo_pre <= data_source_select? ADC_data : datacounter;
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
      .trigger_too_soon     (trigger_too_soon),

      .cmd_arm_usb          (cmd_arm_usb),
      .debug2               (la_debug2),
      .la_debug             (la_debug)
   );
   
   reg triggered;
   reg armed_and_ready_r;
   // ADC trigger is simple except that we only want a single trigger generated:
   always @(posedge ADC_clk_sample) begin
       if (reset) begin
           triggered <= 1'b0;
           trigger_adc <= 1'b0;
           armed_and_ready_r <= 1'b0;
       end
       else begin
           armed_and_ready_r <= armed_and_ready;

           if (~triggered && adc_trigger_active && armed_and_ready_r)
               trigger_adc <= trigger_adclevel[11]? ADC_data_tofifo > trigger_adclevel:
                                                    ADC_data_tofifo < trigger_adclevel;
           else
               trigger_adc <= 1'b0;

           if (trigger_adc)
               triggered <= 1'b1;
           else if (armed_and_ready && ~armed_and_ready_r)
               triggered <= 1'b0;

       end
   end

   `ifdef ILA_ADC_TRIG
       ila_adc_trig U_ila_adc_trig (
          .clk            (clk_usb),              // input wire clk
          .probe0         (trigger_adc),          // input wire [0:0]  probe0 
          .probe1         (triggered),            // input wire [0:0]  probe1 
          .probe2         (trigger_adclevel),     // input wire [11:0]  probe2 
          .probe3         (ADC_data_tofifo),      // input wire [11:0]  probe3 
          .probe4         (armed_and_ready)       // input wire [0:0]  probe4 
       );
   `endif


   assign reg_status[0] = armed;
   assign reg_status[1] = ~capture_active;
   assign reg_status[2] = DUT_trigger_i;
   assign reg_status[3] = 1'b0;
   assign reg_status[4] = PLL_STATUS;
   assign reg_status[5] = 1'b0;
   assign reg_status[6] = 1'b0;
   assign reg_status[7] = fifo_overflow;

   wire [7:0] PWM_incr;

   wire fifo_empty;
   wire fifo_rd_en;
   wire low_res;
   wire low_res_lsb;
   wire [16:0] stream_segment_threshold;

   wire [14:0] presamples;
   wire [31:0] maxsamples_limit;
   wire [31:0] maxsamples;


   wire [12:0] downsample;
   wire [7:0] reg_datao_oadc;
   wire [7:0] reg_datao_fifo;
   wire [7:0] reg_datao_sad;
   wire [7:0] reg_datao_edge;

   wire [31:0] fifo_read_count;
   wire [31:0] fifo_read_count_error_freeze;

   wire [7:0] underflow_count;
   wire no_underflow_errors;

   wire [15:0]  ddr_test_iteration;
   wire [7:0]   ddr_test_errors;
   wire [31:0]  ddr_read_read;
   wire [31:0]  ddr_read_idle;
   wire [31:0]  ddr_write_write;
   wire [31:0]  ddr_write_idle;
   wire [15:0]  ddr_max_read_stall_count;
   wire [15:0]  ddr_max_write_stall_count;

   assign reg_datao = reg_datao_oadc | reg_datao_fifo | reg_datao_sad | reg_datao_edge;

`ifdef SAD_X2
       sad_x2_slowclock #(
           .pBYTECNT_SIZE           (pBYTECNT_SIZE),
    `ifdef PLUS
           .pREF_SAMPLES            (384),
           .pSAD_COUNTER_WIDTH      (14),
    `elsif PRO
           .pREF_SAMPLES            (512),
           .pSAD_COUNTER_WIDTH      (15),
    `else
           .pREF_SAMPLES            (192),
           .pSAD_COUNTER_WIDTH      (12),
    `endif
           .pBITS_PER_SAMPLE        (8)
       ) U_sad (
           .reset                   (reset        ),
           .xadc_error              (xadc_error   ),
           .adc_datain              (ADC_data_tofifo[11:4]),
           .adc_sampleclk           (ADC_clk_sample),
           .slow_clk_even           (ADC_slow_clk_even),
           .slow_clk_odd            (ADC_slow_clk_odd),
           .armed_and_ready         (armed_and_ready),
           .active                  (sad_active   ),
           .clk_usb                 (clk_usb      ),
           .reg_address             (reg_address  ),
           .reg_bytecnt             (reg_bytecnt  ),
           .reg_datai               (reg_datai    ),
           .reg_datao               (reg_datao_sad),
           .reg_read                (reg_read     ),
           .reg_write               (reg_write    ),
           .ext_trigger             (DUT_trigger_i),
           .io4                     (trigger_io4_i),
           .trigger                 (trigger_sad  )
       );

`else
       sad #(
           .pBYTECNT_SIZE           (pBYTECNT_SIZE),
    `ifdef PLUS
           .pREF_SAMPLES            (256),
           .pSAD_COUNTER_WIDTH      (13),
    `else
           .pREF_SAMPLES            (128),
           .pSAD_COUNTER_WIDTH      (12),
    `endif
           .pBITS_PER_SAMPLE        (8)
       ) U_sad (
           .reset                   (reset        ),
           .xadc_error              (xadc_error   ),
           .adc_datain              (ADC_data_tofifo[11:4]),
           .adc_sampleclk           (ADC_clk_sample),
           .armed_and_ready         (armed_and_ready),
           .active                  (sad_active   ),
           .clk_usb                 (clk_usb      ),
           .reg_address             (reg_address  ),
           .reg_bytecnt             (reg_bytecnt  ),
           .reg_datai               (reg_datai    ),
           .reg_datao               (reg_datao_sad),
           .reg_read                (reg_read     ),
           .reg_write               (reg_write    ),
           .ext_trigger             (DUT_trigger_i),
           .io4                     (trigger_io4_i),
           .trigger                 (trigger_sad  )
       );

`endif

   edge_trigger #(
       .pBYTECNT_SIZE           (pBYTECNT_SIZE)
   ) U_edge_trigger (
       .reset                   (reset        ),
       .trigger_in              (trigger_in   ),
       .adc_sampleclk           (ADC_clk_sample),
       .armed_and_ready         (armed_and_ready),
       .active                  (edge_trigger_active),
       .clk_usb                 (clk_usb      ),
       .reg_address             (reg_address  ),
       .reg_bytecnt             (reg_bytecnt  ),
       .reg_datai               (reg_datai    ),
       .reg_datao               (reg_datao_edge),
       .reg_read                (reg_read     ),
       .reg_write               (reg_write    ),
       .trigger                 (trigger_edge_counter),
       .debug                   (edge_trigger_debug)
   );

   reg_openadc #(
      .pBYTECNT_SIZE            (pBYTECNT_SIZE),
      .pTRIGGER_FIFO_WIDTH      (32),
`ifdef PLUS
      .pTRIGGER_FIFO_DEPTH      (2048)  // TODO: TBD max size
`else
      .pTRIGGER_FIFO_DEPTH      (1024)
`endif
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
      .adcclk_frequency             (adcclk_frequency),
      .uiclk_frequency              (uiclk_frequency),
      .pllclk_frequency             (pllclk_frequency),
      .presamples_o                 (presamples),
      .maxsamples_i                 (maxsamples_limit),
      .maxsamples_o                 (maxsamples),
      .downsample_o                 (downsample),
      .clkblock_dcm_locked_i        (1'b0),
      .clkblock_gen_locked_i        (1'b0),
      .fifo_stream                  (fifo_stream),
      .num_segments                 (num_segments),
      .segment_cycles               (segment_cycles),
      .segment_cycle_counter_en     (segment_cycle_counter_en),
      .led_select                   (led_select),
      .no_clip_errors               (no_clip_errors),
      .no_gain_errors               (no_gain_errors),
      .trigger_event                (capture_go),

      .extclk_change                (extclk_change_usb),
      .extclk_monitor_disabled      (extclk_monitor_disabled),
      .extclk_limit                 (extclk_limit),
      .O_disable_adc_error          (O_disable_adc_error)
   );

`ifndef PRO
    wire ui_clk = 1'b0;
    wire [1:0] trace_fifo_errors = 2'b0;
    wire [1:0] la_fifo_errors = 2'b0;
    wire O_xo_en;
    wire O_vddr_enable;
    wire I_vddr_pgood = 1'b0;
`endif

   reg_openadc_adcfifo #(
      .pBYTECNT_SIZE    (pBYTECNT_SIZE)
   ) U_reg_openadc_adcfifo (
      .reset_i                          (reset),
      .clk_usb                          (clk_usb),
      .ui_clk                           (ui_clk),
      .reg_address                      (reg_address), 
      .reg_bytecnt                      (reg_bytecnt), 
      .reg_datao                        (reg_datao_fifo), 
      .reg_datai                        (reg_datai), 
      .reg_read                         (reg_read), 
      .reg_write                        (reg_write), 
      .state                            ({ddr_state, 1'b0, fifo_state}),
      .fifo_empty                       (fifo_empty),
      .fifo_rd_en                       (fifo_rd_en),
      .low_res                          (low_res),
      .low_res_lsb                      (low_res_lsb),
      .fast_fifo_read_mode              (fast_fifo_read),
      .stream_segment_threshold         (stream_segment_threshold),
      .fifo_error_stat                  (fifo_error_stat),
      .fifo_first_error_stat            (fifo_first_error_stat),
      .fifo_first_error_state           (fifo_first_error_state),
      .fifo_read_count                  (fifo_read_count),
      .fifo_read_count_error_freeze     (fifo_read_count_error_freeze),
      .underflow_count                  (underflow_count),
      .no_underflow_errors              (no_underflow_errors),
      .clear_fifo_errors                (clear_fifo_errors),
      .capture_done                     (capture_done),
      .O_data_source_select             (data_source_select),
      .trace_fifo_errors                (trace_fifo_errors),
      .la_fifo_errors                   (la_fifo_errors),
      .adc_flushing                     (adc_flushing),
      .la_flushing                      (la_flushing),
      .trace_flushing                   (trace_flushing),
      .postddr_flush                    (postddr_flush),

      .preddr_adc_fifo_empty            (preddr_adc_fifo_empty),
      .preddr_la_empty                  (preddr_la_empty),
      .preddr_trace_empty               (preddr_trace_empty),
      .fast_fifo_empty                  (fast_fifo_empty),
      .shared_fifo_empty                (shared_fifo_empty),

      .ddr_single_write                 (single_write      ),
      .ddr_single_read                  (single_read       ),
      .ddr_single_address               (single_address    ),
      .ddr_single_write_data            (single_write_data ),
      .ddr_single_read_data             (single_read_data  ),
      .ddr_read_data_done               (ddr_read_data_done),
      .ddr_single_done                  (ddr_single_done   ),
      .ddr_write_data_done              (ddr_write_data_done ),
      .ddr_la_start_address             (ddr_la_start_address    ),
      .ddr_trace_start_address          (ddr_trace_start_address ),
      .ddr_start_la_read                (ddr_start_la_read    ),
      .ddr_start_trace_read             (ddr_start_trace_read ),
      .ddr_start_adc_read               (ddr_start_adc_read   ),

      .O_use_ddr                        (use_ddr                    ),
      .O_ddr3_rwtest_en                 (ddr_rwtest_en             ),
      .O_xo_en                          (O_xo_en                    ),
      .O_vddr_enable                    (O_vddr_enable              ),
      .I_vddr_pgood                     (I_vddr_pgood               ),
      .I_ddr3_pass                      (ddr_test_pass             ),
      .I_ddr3_fail                      (ddr_test_fail             ),
      .O_ddr3_clear_fail                (ddr_test_clear_fail       ),
      .I_ddr3_stat                      (ddr_stat                  ),
      .I_ddr3_iteration                 (ddr_test_iteration        ),
      .I_ddr3_errors                    (ddr_test_errors           ),
      .I_ddr3_read_read                 (ddr_read_read             ),
      .I_ddr3_read_idle                 (ddr_read_idle             ),
      .I_ddr3_write_write               (ddr_write_write           ),
      .I_ddr3_write_idle                (ddr_write_idle            ),
      .I_ddr3_max_read_stall_count      (ddr_max_read_stall_count  ),
      .I_ddr3_max_write_stall_count     (ddr_max_write_stall_count )

   );


   clock_managment_advanced genclocks(
      .ADC_clk_feedback     (ADC_clk_feedback),
      .ADC_clk_sample       (ADC_clk_sample)
    );

   reg [8:0] PWM_accumulator;
   always @(posedge clk_usb) begin
      if (reset)
         PWM_accumulator <= 0;
      else
         PWM_accumulator <= PWM_accumulator[7:0] + PWM_incr;
   end

   assign amp_gain = PWM_accumulator[8];


`ifdef SAD_ONLY
   assign armed_and_ready = 1'b1;
   wire preddr_adc_fifo_empty = 1'b1;
`else

   `ifdef PRO
       wire         capture_go_adc;
       wire         write_done_adc;
       wire         preddr_adc_fifo_rd;
       wire [63:0]  preddr_adc_fifo_dout;
       wire         preddr_adc_fifo_empty;
       wire         preddr_adc_fifo_underflow;
       wire         postddr_fifo_overflow;
       wire         postddr_fifo_underflow_masked;
       wire         error_flag; // TODO: nothing driving this?
       wire         fifo_overflow_noddr;
       wire         arm_pulse_usb;
       wire         reading_too_soon_error;
       wire         ddr_full_error;
       wire         source_flushing = adc_flushing || la_flushing || trace_flushing;

       fifo_top_husky_pro U_fifo (
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

          .presample_i              (presamples),
          .max_samples_i            (maxsamples),
          .max_samples_o            (maxsamples_limit),
          .downsample_i             (downsample),

          .fifo_overflow            (fifo_overflow_noddr),
          .reading_too_soon_error   (reading_too_soon_error),
          .ddr_full_error           (ddr_full_error),
          .error_flag               (fifo_error_flag),
          .error_stat               (fifo_error_stat),
          .first_error_stat         (fifo_first_error_stat),
          .first_error_state        (fifo_first_error_state),
          .clear_fifo_errors        (clear_fifo_errors),
          .trigger_too_soon         (trigger_too_soon),
          .no_clip_errors           (no_clip_errors),
          .no_gain_errors           (no_gain_errors),
          .underflow_count          (underflow_count),
          .capture_done             (capture_done),
          .armed_and_ready          (armed_and_ready),
          .state                    (fifo_state),

          .ui_clk                   (ui_clk),

          .preddr_trace_empty       (preddr_trace_empty),
          .preddr_la_empty          (preddr_la_empty),

          // to DDR:
          .capture_go_ui            (capture_go_adc         ),
          .write_done_out           (write_done_adc         ),
          .I_preddr_fifo_rd         (preddr_adc_fifo_rd     ),
          .preddr_fifo_dout         (preddr_adc_fifo_dout   ),
          .preddr_fifo_empty        (preddr_adc_fifo_empty  ),

          .ddr_rwtest_en            (ddr_rwtest_en),

          .postddr_fifo_empty       (fifo_empty),
          .postddr_fifo_overflow    (postddr_fifo_overflow),
          .postddr_fifo_underflow_masked (postddr_fifo_underflow_masked),
          .flushing                 (adc_flushing),
          .fast_fifo_empty          (fast_fifo_empty),

          .preddr_fifo_wr           (slow_fifo_wr),
          .preddr_fifo_underflow    (preddr_adc_fifo_underflow ),
          .arm_pulse_usb            (arm_pulse_usb),
          .debug                    (fifo_debug)
       );

       wire fifo_overflow_ddr;


       ddr U_ddr (
          .reset                    (reset),
          .clk_usb                  (clk_usb),

          .postddr_fifo_empty       (fifo_empty),
          .stream_segment_available (stream_segment_available),

          .fifo_read_fifoen         (fifo_rd_en),
          .fifo_read_data           (fifo_dout),
          .low_res                  (low_res),
          .low_res_lsb              (low_res_lsb),
          .fast_fifo_read_mode      (fast_fifo_read),
          .stream_segment_threshold (stream_segment_threshold),
          .stream_mode              (fifo_stream),
          .no_underflow_errors      (no_underflow_errors),
          .max_samples_i            (maxsamples),
          .arm_pulse_usb            (arm_pulse_usb),

          // ADC signals:
          .capture_go_adc           (capture_go_adc         ),
          .write_done_adc           (write_done_adc         ),
          .preddr_adc_fifo_rd       (preddr_adc_fifo_rd     ),
          .preddr_adc_fifo_dout     (preddr_adc_fifo_dout   ),
          .preddr_adc_fifo_empty    (preddr_adc_fifo_empty  ),

          .capture_go_la            (capture_go_la     ),
          .write_done_la            (write_done_la     ),
          .preddr_la_fifo_rd        (preddr_la_rd      ),
          .preddr_la_fifo_dout      (preddr_la_data    ),
          .preddr_la_fifo_empty     (preddr_la_empty   ),

          .capture_go_trace         (capture_go_trace  ),
          .write_done_trace         (write_done_trace  ),
          .preddr_trace_fifo_rd     (preddr_trace_rd   ),
          .preddr_trace_fifo_dout   (preddr_trace_data ),
          .preddr_trace_fifo_empty  (preddr_trace_empty),

          .ddr3_addr                (ddr3_addr    ),
          .ddr3_ba                  (ddr3_ba      ),
          .ddr3_cas_n               (ddr3_cas_n   ),
          .ddr3_ck_n                (ddr3_ck_n    ),
          .ddr3_ck_p                (ddr3_ck_p    ),
          .ddr3_cke                 (ddr3_cke     ),
          .ddr3_ras_n               (ddr3_ras_n   ),
          .ddr3_reset_n             (ddr3_reset_n ),
          .ddr3_we_n                (ddr3_we_n    ),
          .ddr3_dq                  (ddr3_dq      ),
          .ddr3_dqs_n               (ddr3_dqs_n   ),
          .ddr3_dqs_p               (ddr3_dqs_p   ),
          .ddr3_dm                  (ddr3_dm      ),
          .ddr3_cs_n                (ddr3_cs_n    ),
          .ddr3_odt                 (ddr3_odt     ),
          .ddr3_stat                (ddr_stat    ),
          .ddr_test_pass            (ddr_test_pass    ),
          .ddr_test_fail            (ddr_test_fail    ),
          .ddr_test_clear_fail      (ddr_test_clear_fail),
          .ddr_rwtest_en            (ddr_rwtest_en),
          .use_ddr                  (use_ddr),

          .single_write             (single_write      ),
          .single_read              (single_read       ),
          .single_address           (single_address    ),
          .single_write_data        (single_write_data ),
          .single_read_data         (single_read_data  ),
          .ddr_read_data_done       (ddr_read_data_done),
          .ddr_single_done          (ddr_single_done   ),
          .ddr_write_data_done      (ddr_write_data_done ),
          .ddr_la_start_address     (ddr_la_start_address    ),
          .ddr_trace_start_address  (ddr_trace_start_address ),

          .ddr_start_la_read        (ddr_start_la_read    ),
          .ddr_start_trace_read     (ddr_start_trace_read ),
          .ddr_start_adc_read       (ddr_start_adc_read   ),

          .ddr_test_iteration       (ddr_test_iteration        ),
          .ddr_test_errors          (ddr_test_errors           ),
          .ddr_read_read            (ddr_read_read             ),
          .ddr_read_idle            (ddr_read_idle             ),
          .ddr_write_write          (ddr_write_write           ),
          .ddr_write_idle           (ddr_write_idle            ),
          .ddr_max_read_stall_count (ddr_max_read_stall_count  ),
          .ddr_max_write_stall_count(ddr_max_write_stall_count ),

          .postddr_fifo_overflow    (postddr_fifo_overflow),
          .fifo_overflow_ddr        (fifo_overflow_ddr),
          .postddr_fifo_underflow_masked (postddr_fifo_underflow_masked),
          .preddr_adc_fifo_underflow(preddr_adc_fifo_underflow ),
          .reading_too_soon_error   (reading_too_soon_error),
          .ddr_full_error           (ddr_full_error        ),
          .error_flag               (error_flag            ),
          .source_flushing          (source_flushing       ),
          .postddr_flush            (postddr_flush         ),

          .ddr_state                (ddr_state),

          .fifo_read_count          (fifo_read_count),
          .fifo_read_count_error_freeze (fifo_read_count_error_freeze),
          .postddr_fifo_rd          (slow_fifo_rd),

          .temp_out                 (temp_out),
          .ADC_clk_fbp              (ADC_clk_fbp ),
          .ADC_clk_fbn              (ADC_clk_fbn ),
          .ui_clk                   (ui_clk),
          .tb_ui_clk                (tb_ui_clk)
       );
       assign fifo_overflow = fifo_overflow_noddr || fifo_overflow_ddr;


   `else
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
          .error_stat               (fifo_error_stat[9:0]),
          .first_error_stat         (fifo_first_error_stat[9:0]),
          .first_error_state        (fifo_first_error_state),
          .clear_fifo_errors        (clear_fifo_errors),
          .trigger_too_soon         (trigger_too_soon),
          .stream_segment_available (stream_segment_available),
          .no_clip_errors           (no_clip_errors),
          .no_gain_errors           (no_gain_errors),
          .underflow_count          (underflow_count),
          .no_underflow_errors      (no_underflow_errors),
          .capture_done             (capture_done),
          .armed_and_ready          (armed_and_ready),
          .state                    (fifo_state),
          .flushing                 (adc_flushing),
          .fast_fifo_empty          (fast_fifo_empty),

          .slow_fifo_wr             (slow_fifo_wr),
          .slow_fifo_rd             (slow_fifo_rd),
          .fifo_read_count          (fifo_read_count),
          .fifo_read_count_error_freeze (fifo_read_count_error_freeze),
          .debug                    (fifo_debug)
       );

       assign ddr_test_pass = 0;
       assign ddr_test_fail = 0;
       assign ddr_stat = 0;
       assign ddr_test_iteration = 0;
       assign ddr_test_errors = 0;
       assign ddr_read_read = 0;
       assign ddr_read_idle = 0;
       assign ddr_write_write = 0;
       assign ddr_write_idle = 0;
       assign ddr_max_read_stall_count = 0;
       assign ddr_max_write_stall_count = 0;
       assign fifo_error_stat[13:10] = 0;
       assign fifo_first_error_stat[13:10] = 0;
       assign ddr_state = 0;
       assign single_read_data = 0;
       assign ddr_read_data_done = 0;
       assign ddr_single_done = 0;
       assign ddr_write_data_done = 0;
       assign postddr_flush = 0;
       wire preddr_adc_fifo_empty = 1'b0;

   `endif

`endif // SAD_ONLY


endmodule
`default_nettype wire
