`timescale 1ns / 1ps
`default_nettype none
`include "includes.v"

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

module reg_la #(
   parameter pBYTECNT_SIZE = 7
)(
   input  wire         reset,
   input  wire         clk_usb,
   input  wire [7:0]   reg_address,  // Address of register
   input  wire [pBYTECNT_SIZE-1:0]  reg_bytecnt,  // Current byte count
   input  wire [7:0]   reg_datai,    // Data to write
   output wire [7:0]   reg_datao,    // Data to read
   input  wire         reg_read,     // Read flag
   input  wire         reg_write,    // Write flag

   input  wire         I_trace_en,
   input  wire         target_hs1,
   input  wire         pll_fpga_clk,
   output wire         observer_clk,
   output wire         observer_locked,
   input  wire         freq_measure,

   input  wire         mmcm_shutdown, // triggered by XADC error

   input  wire         glitchclk,
   input  wire         glitch_mmcm1_clk_out,
   input  wire         glitch_mmcm2_clk_out,
   input  wire         glitch_enable,
   input  wire         io1,
   input  wire         io2,
   input  wire         io3,
   input  wire         io4,
   input  wire         hs1,
   input  wire         hs2,
   input  wire         aux_mcx,
   input  wire         trig_mcx,
   input  wire         adc_sample_clk,
   input  wire         userio0,
   input  wire         userio1,
   input  wire         userio2,
   input  wire         userio3,
   input  wire         userio4,
   input  wire         userio5,
   input  wire         userio6,
   input  wire         userio7,
   input  wire         userio_clk,

   input  wire [8:0]   tu_la_debug,

   input  wire [7:0]   trace_data,
   input  wire [8:0]   trace_debug,
   input  wire         trace_fe_clk,

   input  wire         glitch_go,
   input  wire         glitch_trigger_manual_sourceclock,
   input  wire         glitch_trigger,
   input  wire         capture_active,

   output reg          fifo_wr,
   output wire [17:0]  fifo_wr_data,
   output reg          fifo_flush,
   input  wire         fifo_empty,
   output wire         fifo_clear_write_flags,
   output wire         fifo_clear_read_flags
);


    reg  [15:0] capture_depth;
    wire [6:0] drp_observer_addr;
    wire [15:0] drp_observer_din;
    wire [15:0] drp_observer_dout;
    wire drp_observer_den;
    wire drp_observer_dwe;
    wire drp_observer_reset;

    wire source_clk;

    reg [1:0] clock_source_reg;
    reg [5:0] trigger_source_reg;
    reg [2:0] capture_group_reg;
    reg observer_powerdown;
    reg manual_capture;
    reg [15:0] downsample;
    reg reg_arm;
    reg reg_enabled;

    (* ASYNC_REG = "TRUE" *) reg [1:0] arm_pipe;
    reg  arm_r;
    reg  arm_r2;
    reg  armed;

    reg [7:0] reg_datao_reg;
    wire [7:0] reg_datao_drp_observer;
    assign reg_datao = reg_datao_reg | reg_datao_drp_observer;

    assign fifo_clear_write_flags = arm_r2;
    assign fifo_clear_read_flags = reg_arm;

`ifdef __ICARUS__
   assign source_clk = (I_trace_en) ?                trace_fe_clk :
                       (clock_source_reg == 2'b01) ? clk_usb : 
                       (clock_source_reg == 2'b10) ? pll_fpga_clk :
                       (clock_source_reg == 2'b00) ? target_hs1   : target_hs1;
`else
    wire mux1out;
    wire la_source_clk;
    BUFGMUX #(
       .CLK_SEL_TYPE("ASYNC")
    ) sourceclk_mux1 (
       .O    (mux1out),
       .I0   (target_hs1),
       .I1   (pll_fpga_clk),
       .S    (clock_source_reg[1])
    );  

    BUFGMUX #(
       .CLK_SEL_TYPE("ASYNC")
    ) sourceclk_mux2 (
       .O    (la_source_clk),
       .I0   (mux1out),
       .I1   (clk_usb),
       .S    (clock_source_reg[0])
    ); 

    BUFGMUX #(
       .CLK_SEL_TYPE("ASYNC")
    ) sourceclk_mux3 (
       .O    (source_clk),
       .I0   (la_source_clk),
       .I1   (trace_fe_clk),
       .S    (I_trace_en)
    ); 
`endif

   wire freq_measure_source_clk;
   reg [31:0] frequency_int;
   reg [31:0] frequency;

   cdc_pulse U_freq_measure (
      .reset_i       (reset),
      .src_clk       (clk_usb),
      .src_pulse     (freq_measure),
      .dst_clk       (source_clk),
      .dst_pulse     (freq_measure_source_clk)
   );

   always @(posedge source_clk) begin
      if (freq_measure_source_clk) begin
         frequency_int <= 32'd1;
         frequency <= frequency_int;
      end 
      else begin
         frequency_int <= frequency_int + 32'd1;
      end
   end

    wire capture_go_async = manual_capture | ( (trigger_source_reg == 6'b000_000)? glitch_go : 
                                               (trigger_source_reg == 6'b000_001)? capture_active : 
                                               (trigger_source_reg == 6'b000_010)? glitch_trigger_manual_sourceclock :
                                               (trigger_source_reg == 6'b000_011)? hs1 :
                                               (trigger_source_reg == 6'b000_100)? glitch_trigger :
                                               (trigger_source_reg == 6'b000_101)? tu_la_debug[0] : 
                                               (trigger_source_reg == 6'b000_110)? tu_la_debug[1] :
                                               (trigger_source_reg[5] && (trigger_source_reg[1:0] == 2'b00))? io1 ^ trigger_source_reg[3] :
                                               (trigger_source_reg[5] && (trigger_source_reg[1:0] == 2'b01))? io2 ^ trigger_source_reg[3] :
                                               (trigger_source_reg[5] && (trigger_source_reg[1:0] == 2'b10))? io3 ^ trigger_source_reg[3] :
                                               (trigger_source_reg[5] && (trigger_source_reg[1:0] == 2'b11))? io4 ^ trigger_source_reg[3] :
                                              (~trigger_source_reg[5] && (trigger_source_reg[3:0] == 4'b1_000))? userio0 ^ trigger_source_reg[4] :
                                              (~trigger_source_reg[5] && (trigger_source_reg[3:0] == 4'b1_001))? userio1 ^ trigger_source_reg[4] :
                                              (~trigger_source_reg[5] && (trigger_source_reg[3:0] == 4'b1_010))? userio2 ^ trigger_source_reg[4] :
                                              (~trigger_source_reg[5] && (trigger_source_reg[3:0] == 4'b1_011))? userio3 ^ trigger_source_reg[4] :
                                              (~trigger_source_reg[5] && (trigger_source_reg[3:0] == 4'b1_100))? userio4 ^ trigger_source_reg[4] :
                                              (~trigger_source_reg[5] && (trigger_source_reg[3:0] == 4'b1_101))? userio5 ^ trigger_source_reg[4] :
                                              (~trigger_source_reg[5] && (trigger_source_reg[3:0] == 4'b1_110))? userio6 ^ trigger_source_reg[4] :
                                              (~trigger_source_reg[5] && (trigger_source_reg[3:0] == 4'b1_111))? userio7 ^ trigger_source_reg[4] : 1'b0);

   `ifndef __ICARUS__
      wire observer_clkfb;
      wire observer_clk_prebuf;
      MMCME2_ADV #(
         .BANDWIDTH                    ("OPTIMIZED"), // Jitter programming (OPTIMIZED, HIGH, LOW)
         .CLKFBOUT_MULT_F              (5.0), // Multiply value for all CLKOUT (2.000-64.000)
         .CLKOUT0_DIVIDE_F             (4.0),
         .CLKFBOUT_PHASE               (0.0), // Phase offset in degrees of CLKFB (-360.000-360.000).
         .CLKIN1_PERIOD                (5.0),
         .CLKOUT0_DUTY_CYCLE           (0.5),
         .CLKOUT0_PHASE                (0.0),  // Phase offset for CLKOUT outputs (-360.000-360.000).
         .CLKOUT4_CASCADE              ("FALSE"), // Cascade CLKOUT4 counter with CLKOUT6 (FALSE, TRUE)
         .COMPENSATION                 ("INTERNAL"), // ZHOLD, BUF_IN, EXTERNAL, INTERNAL
         .DIVCLK_DIVIDE                (1), // Master division value (1-106)
         .STARTUP_WAIT                 ("FALSE"), // Delays DONE until MMCM is locked (FALSE, TRUE)
         .CLKFBOUT_USE_FINE_PS         ("FALSE"),
         .CLKOUT0_USE_FINE_PS          ("FALSE")
      ) U_mmcm2_observer (
         // Clock Outputs:
         .CLKOUT0                      (observer_clk_prebuf),
         .CLKOUT0B                     (),
         .CLKOUT1                      (),
         .CLKOUT1B                     (),
         .CLKOUT2                      (),
         .CLKOUT2B                     (),
         .CLKOUT3                      (),
         .CLKOUT3B                     (),
         .CLKOUT4                      (),
         .CLKOUT5                      (),
         .CLKOUT6                      (),
         // Feedback Clocks:
         .CLKFBOUT                     (observer_clkfb),
         .CLKFBOUTB                    (),
         // Status Ports: 1-bit (each) output: MMCM status ports
         .CLKFBSTOPPED                 (),
         .CLKINSTOPPED                 (),
         .LOCKED                       (observer_locked),
         // Clock Inputs:
         .CLKIN1                       (source_clk),
         .CLKIN2                       (1'b0),
         // Control Ports: 1-bit (each) input: MMCM control ports
         .CLKINSEL                     (1'b1),
         .PWRDWN                       (observer_powerdown || mmcm_shutdown),
         .RST                          (drp_observer_reset),
         // DRP Ports:
         .DADDR                        (drp_observer_addr),
         .DCLK                         (clk_usb),
         .DEN                          (drp_observer_den),
         .DI                           (drp_observer_din),
         .DWE                          (drp_observer_dwe),
         .DO                           (drp_observer_dout),
         .DRDY                         (),
         // Feedback Clocks
         .CLKFBIN                      (observer_clkfb)
      );

     wire observer_clk_mr;
      BUFMRCE #(
         .INIT_OUT      (0),
         .CE_TYPE       ("ASYNC")
      ) U_observer_clk1 (
         .I             (observer_clk_prebuf),
         .O             (observer_clk_mr),
         .CE            (~(observer_powerdown || mmcm_shutdown))
      );

      BUFR #(
         .BUFR_DIVIDE   (1)
      ) U_observer_clk2 (
         .I             (observer_clk_mr),
         .O             (observer_clk),
         .CE            (1'b1),
         .CLR           (1'b0)
      );


   `else
      assign observer_clk = source_clk;

   `endif // __ICARUS__

   reg_mmcm_drp #(
      .pBYTECNT_SIZE    (pBYTECNT_SIZE),
      .pDRP_ADDR        (`LA_DRP_ADDR),
      .pDRP_DATA        (`LA_DRP_DATA),
      .pDRP_RESET       (`LA_DRP_RESET)
   ) U_cg_observer_drp (
      .reset_i          (reset),
      .clk_usb          (clk_usb),
      .selected         (1'b1),
      .reg_address      (reg_address), 
      .reg_bytecnt      (reg_bytecnt), 
      .reg_datao        (reg_datao_drp_observer), 
      .reg_datai        (reg_datai), 
      .reg_read         (reg_read), 
      .reg_write        (reg_write), 
      .drp_addr         (drp_observer_addr ),
      .drp_den          (drp_observer_den  ),
      .drp_din          (drp_observer_din  ),
      .drp_dout         (drp_observer_dout ),
      .drp_dwe          (drp_observer_dwe  ),
      .drp_reset        (drp_observer_reset)
   ); 

   // CDC for capture enable:
   (* ASYNC_REG = "TRUE" *) reg[1:0] capture_go_pipe;
   reg capture_go_r;
   reg capture_go_r2;
   always @ (posedge observer_clk) begin
      if (reset) begin
         capture_go_pipe <= 0;
         capture_go_r <= 0;
         capture_go_r2 <= 0;
      end
      else begin
         {capture_go_r2, capture_go_r, capture_go_pipe} <= {capture_go_r, capture_go_pipe, capture_go_async};
      end
   end

   // ~capturing is so that we don't restart capturing over ourselves, which 
   // could otherwise happen e.g. in the case of a manually triggered capture:
   wire capture_go = capture_go_r & ~capture_go_r2 & ~capturing & armed;

   // Do the capture.
   reg [15:0] capture_count;
   reg capturing;
   wire capturing_usb_pulse;
   reg [1:0] capture0_reg;
   reg [1:0] capture1_reg;
   reg [1:0] capture2_reg;
   reg [1:0] capture3_reg;
   reg [1:0] capture4_reg;
   reg [1:0] capture5_reg;
   reg [1:0] capture6_reg;
   reg [1:0] capture7_reg;
   reg [1:0] capture8_reg;

   reg capture0_source;
   reg capture1_source;
   reg capture2_source;
   reg capture3_source;
   reg capture4_source;
   reg capture5_source;
   reg capture6_source;
   reg capture7_source;
   reg capture8_source;

   reg ticktock;

   //always @(*) begin
   always @(posedge observer_clk) begin
       case (capture_group_reg)
           0: begin
               capture0_source <= glitchclk;
               capture1_source <= source_clk;
               capture2_source <= glitch_mmcm1_clk_out;
               capture3_source <= glitch_mmcm2_clk_out;
               capture4_source <= glitch_go;
               capture5_source <= capture_active;
               capture6_source <= glitch_enable;
               capture7_source <= glitch_trigger_manual_sourceclock;
               capture8_source <= glitch_trigger;
           end

           1: begin
               capture0_source <= io1;
               capture1_source <= io2;
               capture2_source <= io3;
               capture3_source <= io4;
               capture4_source <= hs1;
               capture5_source <= hs2;
               capture6_source <= aux_mcx;
               capture7_source <= trig_mcx;
               capture8_source <= adc_sample_clk;
           end

           2: begin
               capture0_source <= userio0;
               capture1_source <= userio1;
               capture2_source <= userio2;
               capture3_source <= userio3;
               capture4_source <= userio4;
               capture5_source <= userio5;
               capture6_source <= userio6;
               capture7_source <= userio7;
               capture8_source <= userio_clk;
           end

           3: begin
               capture0_source <= tu_la_debug[0];
               capture1_source <= tu_la_debug[1];
               capture2_source <= tu_la_debug[2];
               capture3_source <= tu_la_debug[3];
               capture4_source <= tu_la_debug[4];
               capture5_source <= tu_la_debug[5];
               capture6_source <= tu_la_debug[6];
               capture7_source <= tu_la_debug[7];
               capture8_source <= tu_la_debug[8];
           end

           4: begin
               capture0_source <= trace_data[0];
               capture1_source <= trace_data[1];
               capture2_source <= trace_data[2];
               capture3_source <= trace_data[3];
               capture4_source <= trace_data[4];
               capture5_source <= trace_data[5];
               capture6_source <= trace_data[6];
               capture7_source <= trace_data[7];
               capture8_source <= trace_fe_clk;
           end

           5: begin
               capture0_source <= trace_debug[0];
               capture1_source <= trace_debug[1];
               capture2_source <= trace_debug[2];
               capture3_source <= trace_debug[3];
               capture4_source <= trace_debug[4];
               capture5_source <= trace_debug[5];
               capture6_source <= trace_debug[6];
               capture7_source <= trace_debug[7];
               capture8_source <= trace_debug[8];
           end


           default: begin
               capture0_source <= 1'b1;
               capture1_source <= 1'b0;
               capture2_source <= 1'b1;
               capture3_source <= 1'b0;
               capture4_source <= 1'b1;
               capture5_source <= 1'b0;
               capture6_source <= 1'b1;
               capture7_source <= 1'b0;
               capture8_source <= 1'b1;
           end
       endcase
   end


   always @ (posedge observer_clk) begin
      if (reset) begin
         capture_count <= 0;
         capturing <= 1'b0;
         capture0_reg <= 2'b0;
         capture1_reg <= 2'b0;
         capture2_reg <= 2'b0;
         capture3_reg <= 2'b0;
         capture4_reg <= 2'b0;
         capture5_reg <= 2'b0;
         capture6_reg <= 2'b0;
         capture7_reg <= 2'b0;
         capture8_reg <= 2'b0;
         ticktock <= 1'b0;
         fifo_wr <= 1'b0;
      end

      else begin
         if (capture_go) begin
            capture_count <= 0;
            capturing <= 1'b1;
            ticktock <= 1'b0;
            fifo_wr <= 1'b0;
         end

         else if (capturing && downsample_wr_en) begin
            ticktock <= ~ticktock;
            capture0_reg <= {capture0_reg[0], capture0_source};
            capture1_reg <= {capture1_reg[0], capture1_source};
            capture2_reg <= {capture2_reg[0], capture2_source};
            capture3_reg <= {capture3_reg[0], capture3_source};
            capture4_reg <= {capture4_reg[0], capture4_source};
            capture5_reg <= {capture5_reg[0], capture5_source};
            capture6_reg <= {capture6_reg[0], capture6_source};
            capture7_reg <= {capture7_reg[0], capture7_source};
            capture8_reg <= {capture8_reg[0], capture8_source};

            if (ticktock)
               fifo_wr <= 1'b1;
            else
               fifo_wr <= 1'b0;

            capture_count <= capture_count + 1;
            if (capture_count == capture_depth-1)
               capturing <= 1'b0;
         end

         else
             fifo_wr <= 1'b0;
      end
   end

   assign fifo_wr_data = {capture8_reg, 
                          capture7_reg, 
                          capture6_reg, 
                          capture5_reg, 
                          capture4_reg, 
                          capture3_reg, 
                          capture2_reg, 
                          capture1_reg, 
                          capture0_reg};

   //Counter for downsampling (NOT proper decimation)
   reg [15:0] downsample_ctr;
   wire downsample_max;
   reg downsample_wr_en;

   assign downsample_max = (downsample_ctr == downsample) ? 1'b1 : 'b0;

   always @(posedge observer_clk) begin
      if (capture_go) begin
         downsample_ctr <= 0;
         downsample_wr_en <= 0;
      end 
      else begin
         if (downsample_max) begin
            downsample_ctr <= 0;
            downsample_wr_en <= 1;
         end
         else begin
            downsample_ctr <= downsample_ctr + 1;
            downsample_wr_en <= 0;
         end
      end
   end


   //always @(posedge clk_usb) begin
   always @(*) begin
      if (reg_read) begin
         case (reg_address)
             `LA_CAPTURE_GROUP: reg_datao_reg = {5'b0, capture_group_reg};
             `LA_STATUS:        reg_datao_reg = {6'b0, capturing, observer_locked};
             `LA_CLOCK_SOURCE:  reg_datao_reg = {6'b0, clock_source_reg};
             `LA_TRIGGER_SOURCE:reg_datao_reg = {2'b0, trigger_source_reg};
             `LA_POWERDOWN:     reg_datao_reg = {7'b0, observer_powerdown};
             `LA_CAPTURE_DEPTH: reg_datao_reg = capture_depth[reg_bytecnt*8 +: 8];
             `LA_DOWNSAMPLE:    reg_datao_reg = downsample[reg_bytecnt*8 +: 8];
             `LA_ARM:           reg_datao_reg = reg_arm;
             `LA_ENABLED:       reg_datao_reg = reg_enabled;
             `LA_SOURCE_FREQ:   reg_datao_reg = frequency[reg_bytecnt*8 +: 8];
             default:           reg_datao_reg = 0;
         endcase
      end
      else
         reg_datao_reg = 0;
   end

   always @(posedge clk_usb) begin
      if (reset) begin
         clock_source_reg <= 2'b10; // default to PLL
         trigger_source_reg <= 6'b0; // default to glitch
         capture_group_reg <= 0;
         observer_powerdown <= 1;
         manual_capture <= 0;
         downsample <= 0;
         reg_arm <= 0;
         reg_enabled <= 0;
      end 

      else if (reg_write) begin
         case (reg_address)
             `LA_CLOCK_SOURCE:  clock_source_reg <= reg_datai[1:0];
             `LA_TRIGGER_SOURCE:trigger_source_reg <= reg_datai[5:0];
             `LA_CAPTURE_GROUP: capture_group_reg <= reg_datai[2:0];
             `LA_POWERDOWN:     observer_powerdown <= reg_datai[0];
             `LA_ENABLED:       reg_enabled <= reg_datai[0];
             `LA_CAPTURE_DEPTH: capture_depth[reg_bytecnt*8 +: 8] <= reg_datai;
             `LA_MANUAL_CAPTURE:manual_capture <= reg_datai[0];
             `LA_DOWNSAMPLE:    downsample[reg_bytecnt*8 +: 8] <= reg_datai;
         endcase
      end

      // ARM register is special:
      if (reg_write && (reg_address == `LA_ARM))
          reg_arm <= reg_datai[0];
      else if (capturing_usb_pulse)
          reg_arm <= 1'b0;

   end

   // Arm CDC:
   always @ (posedge observer_clk) begin
      if (reset) begin
         arm_pipe <= 0;
         arm_r <= 0;
         arm_r2 <= 0;
         armed <= 0;
      end
      else begin
         {arm_r2, arm_r, arm_pipe} <= {arm_r, arm_pipe, reg_arm};
         if (capturing)
             armed <= 0;
         else if (arm_r & ~arm_r2)
             armed <= 1;
      end
   end

   always @(posedge clk_usb) begin
      if (reset) begin
         fifo_flush <= 1'b0;
      end
      else begin
         if (fifo_empty)
            fifo_flush <= 1'b0;
         else if (reg_arm & ~fifo_flush)
            fifo_flush <= 1'b1;
      end
   end

   cdc_pulse U_capture_done_pulse (
      .reset_i       (reset),
      .src_clk       (observer_clk),
      .src_pulse     (capture_go),
      .dst_clk       (clk_usb),
      .dst_pulse     (capturing_usb_pulse)
   );

`ifdef ILA_LA
    ila_la U_ila_la (
       .clk            (clk_usb),              // input wire clk
       .probe0         (fifo_wr),              // input wire [0:0]  probe0 
       .probe1         (armed),                // input wire [0:0]  probe1 
       .probe2         (fifo_empty),           // input wire [0:0]  probe2 
       .probe3         (fifo_flush),           // input wire [0:0]  probe3 
       .probe4         (fifo_clear_write_flags),// input wire [0:0]  probe4 
       .probe5         (fifo_clear_read_flags),// input wire [0:0]  probe5 
       .probe6         (reg_arm),              // input wire [0:0]  probe6 
       .probe7         (capture_go_async),     // input wire [0:0]  probe7 
       .probe8         (capture_go),           // input wire [0:0]  probe8 
       .probe9         (capture_count),        // input wire [15:0] probe9 
       .probe10        (capturing)             // input wire [0:0]  probe10
    );
`endif


endmodule

`default_nettype wire
