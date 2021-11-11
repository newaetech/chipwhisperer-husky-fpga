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
   parameter pBYTECNT_SIZE = 7,
   parameter pCAPTURE_DEPTH = 1024
)(
   input  wire         reset,
   input  wire         clk_usb,
   input  wire [7:0]   reg_address,  // Address of register
   input  wire [pBYTECNT_SIZE-1:0]  reg_bytecnt,  // Current byte count
   input  wire [7:0]   reg_datai,    // Data to write
   output wire [7:0]   reg_datao,    // Data to read
   input  wire         reg_read,     // Read flag
   input  wire         reg_write,    // Write flag

   input wire          target_hs1,
   input wire          clkgen,
   input wire          pll_fpga_clk,

   input wire          mmcm_shutdown, // triggered by XADC error

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


   input  wire         glitch_go,
   input  wire         glitch_trigger_sourceclock,
   input  wire         adc_capture_go
);


    wire [15:0] la_exists_code = 16'h4c41;
    wire [15:0] capture_depth = pCAPTURE_DEPTH;
    wire [6:0] drp_observer_addr;
    wire [15:0] drp_observer_din;
    wire [15:0] drp_observer_dout;
    wire drp_observer_den;
    wire drp_observer_dwe;
    wire drp_observer_reset;

    wire observer_clk;
    wire source_clk;

    reg [1:0] clock_source_reg;
    reg [2:0] trigger_source_reg;
    reg [1:0] capture_group_reg;
    reg [3:0] read_select_reg;
    reg observer_powerdown;
    wire observer_locked;

    reg [7:0] reg_datao_reg;
    wire [7:0] reg_datao_drp_observer;
    assign reg_datao = reg_datao_reg | reg_datao_drp_observer;

`ifdef __ICARUS__
   assign source_clk = (clock_source_reg == 2'b01) ? clkgen : 
                       (clock_source_reg == 2'b10) ? pll_fpga_clk :
                       (clock_source_reg == 2'b00) ? target_hs1   : target_hs1;
`else
    wire mux1out;
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
       .O    (source_clk),
       .I0   (mux1out),
       .I1   (clkgen),
       .S    (clock_source_reg[0])
    ); 
`endif


    wire capture_go_async = (trigger_source_reg == 3'b000)? adc_capture_go : 
                            (trigger_source_reg == 3'b001)? glitch_go : 
                            (trigger_source_reg == 3'b010)? glitch_trigger_sourceclock :
                            (trigger_source_reg == 3'b011)? hs1 :
                            (trigger_source_reg == 3'b100)? tu_la_debug[0] : 1'b0;


   `ifndef __ICARUS__
      wire observer_clkfb;
      wire observer_clk_prebuf;
      MMCME2_ADV #(
         .BANDWIDTH                    ("OPTIMIZED"), // Jitter programming (OPTIMIZED, HIGH, LOW)
         .CLKFBOUT_MULT_F              (3.0), // Multiply value for all CLKOUT (2.000-64.000)
         .CLKOUT0_DIVIDE_F             (2.0),
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

      BUFR #(
         .BUFR_DIVIDE   (1)
      ) U_observer_clk (
         .I             (observer_clk_prebuf),
         .O             (observer_clk),
         .CE            (~(observer_powerdown || mmcm_shutdown)),
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
   wire capture_go = capture_go_r & ~capture_go_r2;

   // Do the capture.
   reg [9:0] capture_count;
   reg capturing;
   reg [pCAPTURE_DEPTH-1:0] capture0_reg;
   reg [pCAPTURE_DEPTH-1:0] capture1_reg;
   reg [pCAPTURE_DEPTH-1:0] capture2_reg;
   reg [pCAPTURE_DEPTH-1:0] capture3_reg;
   reg [pCAPTURE_DEPTH-1:0] capture4_reg;
   reg [pCAPTURE_DEPTH-1:0] capture5_reg;
   reg [pCAPTURE_DEPTH-1:0] capture6_reg;
   reg [pCAPTURE_DEPTH-1:0] capture7_reg;
   reg [pCAPTURE_DEPTH-1:0] capture8_reg;

   reg capture0_source;
   reg capture1_source;
   reg capture2_source;
   reg capture3_source;
   reg capture4_source;
   reg capture5_source;
   reg capture6_source;
   reg capture7_source;
   reg capture8_source;

   //always @(*) begin
   always @(posedge observer_clk) begin
       case (capture_group_reg)
           0: begin
               capture0_source <= glitchclk;
               capture1_source <= source_clk;
               capture2_source <= glitch_mmcm1_clk_out;
               capture3_source <= glitch_mmcm2_clk_out;
               capture4_source <= glitch_go;
               capture5_source <= adc_capture_go;
               capture6_source <= glitch_enable;
               capture7_source <= glitch_trigger_sourceclock;
               capture8_source <= 1'b0;
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


   reg [pCAPTURE_DEPTH-1:0] observer_data;

   always @ (posedge observer_clk) begin
      if (reset) begin
         capture_count <= 0;
         capture0_reg <= 0;
         capture1_reg <= 0;
         capture2_reg <= 0;
         capture3_reg <= 0;
         capture4_reg <= 0;
         capture5_reg <= 0;
         capture6_reg <= 0;
         capture7_reg <= 0;
         capture8_reg <= 0;
      end

      else begin
         if (capture_go) begin
            capture_count <= 0;
            capturing <= 1;
            capture0_reg <= {capture0_source, {(pCAPTURE_DEPTH-1){1'b0}}};
            capture1_reg <= {capture1_source, {(pCAPTURE_DEPTH-1){1'b0}}};
            capture2_reg <= {capture2_source, {(pCAPTURE_DEPTH-1){1'b0}}};
            capture3_reg <= {capture3_source, {(pCAPTURE_DEPTH-1){1'b0}}};
            capture4_reg <= {capture4_source, {(pCAPTURE_DEPTH-1){1'b0}}};
            capture5_reg <= {capture5_source, {(pCAPTURE_DEPTH-1){1'b0}}};
            capture6_reg <= {capture6_source, {(pCAPTURE_DEPTH-1){1'b0}}};
            capture7_reg <= {capture7_source, {(pCAPTURE_DEPTH-1){1'b0}}};
            capture8_reg <= {capture8_source, {(pCAPTURE_DEPTH-1){1'b0}}};
         end

         else if (capturing) begin
            capture0_reg <= {capture0_source, capture0_reg[pCAPTURE_DEPTH-1:1]};
            capture1_reg <= {capture1_source, capture1_reg[pCAPTURE_DEPTH-1:1]};
            capture2_reg <= {capture2_source, capture2_reg[pCAPTURE_DEPTH-1:1]};
            capture3_reg <= {capture3_source, capture3_reg[pCAPTURE_DEPTH-1:1]};
            capture4_reg <= {capture4_source, capture4_reg[pCAPTURE_DEPTH-1:1]};
            capture5_reg <= {capture5_source, capture5_reg[pCAPTURE_DEPTH-1:1]};
            capture6_reg <= {capture6_source, capture6_reg[pCAPTURE_DEPTH-1:1]};
            capture7_reg <= {capture7_source, capture7_reg[pCAPTURE_DEPTH-1:1]};
            capture8_reg <= {capture8_source, capture8_reg[pCAPTURE_DEPTH-1:1]};

            if (capture_count < pCAPTURE_DEPTH-1)
               capture_count <= capture_count + 1;
            else
               capturing <= 0;
         end
      end
   end


   always @(posedge clk_usb) begin
   //always @(*) begin
       case (read_select_reg)
           0: observer_data <= capture0_reg;
           1: observer_data <= capture1_reg;
           2: observer_data <= capture2_reg;
           3: observer_data <= capture3_reg;
           4: observer_data <= capture4_reg;
           5: observer_data <= capture5_reg;
           6: observer_data <= capture6_reg;
           7: observer_data <= capture7_reg;
           8: observer_data <= capture8_reg;
           default: observer_data <= 'b11111111111111111100; // just some unusual pattern
       endcase
   end

   //always @(posedge clk_usb) begin
   always @(*) begin
      if (reg_read) begin
         case (reg_address)
             `LA_READ_SELECT:   reg_datao_reg = observer_data[reg_bytecnt*8 +: 8];
             `LA_CAPTURE_GROUP: reg_datao_reg = {6'b0, capture_group_reg};
             `LA_STATUS:        reg_datao_reg = {6'b0, capturing, observer_locked};
             `LA_CLOCK_SOURCE:  reg_datao_reg = {6'b0, clock_source_reg};
             `LA_TRIGGER_SOURCE:reg_datao_reg = {5'b0, trigger_source_reg};
             `LA_POWERDOWN:     reg_datao_reg = {7'b0, observer_powerdown};
             `LA_EXISTS:        reg_datao_reg = la_exists_code[reg_bytecnt*8 +: 8];
             `LA_CAPTURE_DEPTH: reg_datao_reg = capture_depth[reg_bytecnt*8 +: 8];
             default:           reg_datao_reg = 0;
         endcase
      end
      else
         reg_datao_reg = 0;
   end

   always @(posedge clk_usb) begin
      if (reset) begin
         clock_source_reg <= 2'b10; // default to PLL
         trigger_source_reg <= 3'b000; // default to glitch
         capture_group_reg <= 0;
         read_select_reg <= 0;
         observer_powerdown <= 1;
      end 

      else if (reg_write) begin
         case (reg_address)
             `LA_CLOCK_SOURCE:  clock_source_reg <= reg_datai[1:0];
             `LA_TRIGGER_SOURCE:trigger_source_reg <= reg_datai[2:0];
             `LA_CAPTURE_GROUP: capture_group_reg <= reg_datai[1:0];
             `LA_READ_SELECT:   read_select_reg <= reg_datai[3:0];
             `LA_POWERDOWN:     observer_powerdown <= reg_datai[0];
         endcase
      end
   end

endmodule

`default_nettype wire
