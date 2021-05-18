`include "includes.v"
`timescale 1 ns / 1 ps
`default_nettype none

/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more
details, or the codebase at http://www.chipwhisperer.com

Copyright (c) 2014-2021, NewAE Technology Inc. All rights reserved.
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

module reg_chipwhisperer #(
   parameter pBYTECNT_SIZE = 7
)(
   input  wire         reset_i,
   input  wire         clk_usb,
   input  wire [5:0]   reg_address,  // Address of register
   input  wire [pBYTECNT_SIZE-1:0]  reg_bytecnt,  // Current byte count
   input  wire [7:0]   reg_datai,    // Data to write
   inout  wire [7:0]   reg_datao,    // Data to read
   input  wire         reg_read,     // Read flag
   input  wire         reg_write,    // Write flag
   input  wire         reg_addrvalid,// Address valid flag

   /* External Clock */
   input  wire        usbiohs2,
   input  wire        target_hs1,
   output wire        target_hs2,
   output wire        extclk_o,

   /* Extern Trigger Connections */
   input  wire        trigger_io1_i,
   input  wire        trigger_io2_i,
   input  wire        trigger_io3_i,
   input  wire        trigger_io4_i,

   /* Advanced IO Trigger Connections */
   output wire        trigger_ext_o,
   input  wire        trigger_advio_i, 
   input  wire        trigger_decodedio_i,
   input  wire        trigger_anapattern_i,

   /* Clock Sources */
   input  wire        pll_fpga_clk,
   input  wire        glitchclk,

   /* GPIO Pins & Routing */
   inout  wire        targetio1_io,
   inout  wire        targetio2_io,
   inout  wire        targetio3_io,
   inout  wire        targetio4_io,

   output wire        hsglitcha_o,
   output wire        hsglitchb_o,

   output wire        enable_avrprog,

   output wire        enable_output_nrst,
   output wire        output_nrst,
   output wire        enable_output_pdid,
   output wire        output_pdid,
   output wire        enable_output_pdic,
   output wire        output_pdic,

   input  wire        uart_tx_i,
   output wire        uart_rx_o,

   // TODO: no longer exists
   input  wire        usi_out_i,
   output wire        usi_in_o,

   output wire        targetpower_off,

   /* Main trigger connections */
   output wire        trigger_o /* Trigger signal to capture system */
); 

   wire reset;
   assign reset = reset_i;

   `define CW_EXTCLK_ADDR       38
   `define CW_TRIGSRC_ADDR      39
   `define CW_TRIGMOD_ADDR      40
   `define CW_IOROUTE_ADDR      55
   `define CW_IOREAD_ADDR       59

 /*  
CW_EXTCLK_ADDR, address 38 (0x26) - External Clock Connections (One Byte)

    [  X RO RO FA FA S  S  S ]
    
    [2:0]
    S S S = 000: AUX MCX
            011: HS1
    [4:3]
    FA = 00 Front Panel A: High-Z (REQUIRED if using as input)
         01 Front Panel A: CLKGEN
         10 Front Panel A: Glitch Module
    [6:5]
    RO = (Bit 6/Bit 5) Rear Clock Out Source
         00 : Disabled (constant)
         10 : CLKGEN
         11 : Glitch Module

CW_TRIGSRC_ADDR, address 39 (0x27) - External Trigger Connections (One Byte)
    [  M  M  R4  R3  R2  R1  FB FA ]
    All external triggers are combined into a single
    trigger signal, which can then be passed into one
    of the enabled 'trigger modules'
    FA = Front Panel Channel A / Aux SMA
    FB = Front Panel Channel B
    R1 = Rear TargetIO - Line 1
    R2 = Rear TargetIO - Line 2
    R3 = Rear TargetIO - Line 3
    R4 = Rear TargetIO - Line 4
    MM = Mode to combine multiple channels
        00 = OR
        01 = AND

CW_TRIGMOD_ADDR, address 40 (0x28) - Trigger Module Enabled
    [ X  X  X  FB FA M  M  M ]
    M M M = 000 Normal Edge-Mode Trigger
            001 Advanced IO Pattern Trigger
            010 Advanced SAD Trigger
    FA = Output trigger to Front Panel A / Aux SMA
    FB = Output trigger to Front Panel B

CW_IOROUTE_ADDR, address 55 (0x37) - GPIO Pin Routing [8 bytes]
    IMPORTANT: Only a single IO can be assigned
               to any input. e.g. you can't assign
               both GPIO1 and GPIO3 to 'RX'. 
               The system assigns priority to lower
               numbered GPIOs.
               Similarly if you attempt to assign multiple
               outputs to a single TargetIO it will use the
               lowest bit as the actual output.
    GPIO1:
    [ E G   X     X  USII USIO RX TX ]

    GPIO2:
    [ E G   X     X  USII USIO RX TX ]

    GPIO3:
    [ E G  TXO USOC  USII USIO RX TX ]  --> USOC means USIO but with Open Collector drive

    GPIO4:
    [ X X   X     X    X    X  X   X ]

    GLITCH:
    [ X X   X     X    X    X  B   A ]

    A  = (Bit 0) Glitch Output A
        0  : Disabled
        1  : Glitch Module
    B  = (Bit 1) Glitch Output B
        0  : Disabled
        1  : Glitch Module

    EXTRA:
    [ X X   SC    SC    X    S  P   A ]

    A = (Bit 0) AVR Programming Enable
        0  : Disabled (High-Z)
        1  : Enabled (Connected to SAM3U)

    P = (Bit 1) Target Power Disable
        0  : Power On
        1  : Power Off

    S = (Bit 2) Target Power Switch Type
        0  : Slow-Start (safer)
        1  : Fast-Start

    SC = (Bit 5 - 4) Smart-Card Interface Setup (CW1200 Only)
        00  : High-Z (Not Used)
        01  : 
        10  :
        11  :

    EXTRA GPIO:
    [ X X   PC  PCE   PD   PDE  N  NE ]
        NE  =  nRST Enable as GPIO
        N   =   nRST state
        PDE = PDID Enable as GPIO
        PD  = PDID State
        PCE = PDIC Enable as GPIO
        PC  = PDIC State

    RESERVED:
    [ X X   X     X    X    X  X   X ]

 */

   reg [7:0] registers_cwextclk;
   reg [7:0] registers_cwtrigsrc;
   reg [7:0] registers_cwtrigmod;
   reg [63:0] registers_iorouting;
   reg [3:0] registers_ioread;

   wire targetio_highz;

   //Do to no assumed phase relationship we use regular old fabric for switching
   assign extclk_o = (registers_cwextclk[2:0] == 3'b000) ? usbiohs2 :
                     (registers_cwextclk[2:0] == 3'b011) ? target_hs1 : 
                     1'b0;

   //TODO: Should use a mux?
   //The glitch-clock comes from the fabric anyway, but the clkgen comes from the DCM. Either way we are jumping back
   //and forth a lot.



   wire rearclk;

`ifdef __ICARUS__
   assign rearclk = registers_cwextclk[5]? pll_fpga_clk : glitchclk;
`else
   BUFGMUX #(
      .CLK_SEL_TYPE     ("ASYNC")               // Glitchles ("SYNC") or fast ("ASYNC") clock switch-over
   )
   clkgenfx_mux (
      .O                (rearclk),              // 1-bit output: Clock buffer output
      .I0               (pll_fpga_clk),         // 1-bit input: Clock buffer input (S=0)
      .I1               (glitchclk),            // 1-bit input: Clock buffer input (S=1)
      .S                (registers_cwextclk[5]) // 1-bit input: Clock buffer select
   );
`endif
   

   //NB: Normally ODDR used for clock output. This won't work as this clock
   //can have glitches, which screws up the ODDR2 block. Because we don't care
   //about variations in synchronization of this clock to source clock, this
   //should be OK.
   assign target_hs2 = (registers_cwextclk[6] & (~targetio_highz)) ? rearclk : 1'bZ;


`ifdef __ICARUS__
   assign hsglitcha_o = registers_iorouting[32]? glitchclk : 1'b0;
   assign hsglitchb_o = registers_iorouting[33]? glitchclk : 1'b0;

`else
   ODDR #(
      .DDR_CLK_EDGE ("OPPOSITE_EDGE"),
      .INIT         (1'b0),
      .SRTYPE       ("ASYNC")
   )
   ODDR_hsglitcha (
      .Q            (hsglitcha_o),
      .C            (glitchclk),
      .CE           (registers_iorouting[32]),
      .D1           (1'b1),
      .D2           (1'b0),
      .R            (~registers_iorouting[32]),
      .S            (1'b0)
   );

   ODDR #(
      .DDR_CLK_EDGE ("OPPOSITE_EDGE"),
      .INIT         (1'b0),
      .SRTYPE       ("ASYNC")
   )
   ODDR_hsglitchb (
      .Q            (hsglitchb_o),
      .C            (glitchclk),
      .CE           (registers_iorouting[33]),
      .D1           (1'b1),
      .D2           (1'b0),
      .R            (~registers_iorouting[33]),
      .S            (1'b0)
   );

`endif


   assign enable_avrprog = registers_iorouting[40];

   /* Target Power */
   reg reg_targetpower_off;
   reg reg_targetpower_off_prev;
   always @(posedge clk_usb) begin
      reg_targetpower_off <= registers_iorouting[41];
      reg_targetpower_off_prev <= reg_targetpower_off;
   end

   /* Target power switched ON from OFF state using PWM for programmable soft-start.
       Only in CW1200 currently. */
`ifdef SUPPORT_SOFTPOWER
   reg targetpower_soft_on;
   always @(posedge clk_usb) begin
          if ((reg_targetpower_off == 1'b0) && (reg_targetpower_off_prev == 1'b1)) begin
             targetpower_soft_on <= 1'b1;
          end else if (reg_targetpower_off == 1'b1) begin
             targetpower_soft_on <= 1'b0;
          end
   end

   reg [10:0] soft_start_pwm;
   always @(posedge clk_usb) begin
          soft_start_pwm <= soft_start_pwm + 11'd1;
   end

   reg output_src_pwm;
   reg [13:0] soft_start_cnt;
   always @(posedge clk_usb) begin
          if (targetpower_soft_on == 1'b0) begin
             soft_start_cnt <= 0;
             output_src_pwm <= 1'b0;
          end else if (soft_start_cnt == 14'd16383) begin
             output_src_pwm <= 1'b0;
          end else if (soft_start_pwm == 0) begin
             soft_start_cnt <= soft_start_cnt + 14'd1;
             output_src_pwm <= 1'b1;
          end
   end

   wire targetpower_slow = ~registers_iorouting[42];
   assign targetpower_off_pwm = (soft_start_pwm < 1400) ? 1'b1 : 1'b0; 
   assign targetpower_off = (output_src_pwm & targetpower_slow) ? targetpower_off_pwm : reg_targetpower_off;

`else
   assign targetpower_off = reg_targetpower_off;

`endif

   assign targetio_highz = reg_targetpower_off;

   wire trigger_and;
   wire trigger_or;
   wire trigger_ext;
   
   assign trigger_and = ((registers_cwtrigsrc[2] & trigger_io1_i) | ~registers_cwtrigsrc[2]) &
                        ((registers_cwtrigsrc[3] & trigger_io2_i) | ~registers_cwtrigsrc[3]) &
                        ((registers_cwtrigsrc[4] & trigger_io3_i) | ~registers_cwtrigsrc[4]) &
                        ((registers_cwtrigsrc[5] & trigger_io4_i) | ~registers_cwtrigsrc[5]);

   assign trigger_or  = (registers_cwtrigsrc[2] & trigger_io1_i) |
                        (registers_cwtrigsrc[3] & trigger_io2_i) |
                        (registers_cwtrigsrc[4] & trigger_io3_i) |
                        (registers_cwtrigsrc[5] & trigger_io4_i);

   assign trigger_ext =  (registers_cwtrigsrc[7:6] == 2'b00) ? trigger_or :
                         (registers_cwtrigsrc[7:6] == 2'b01) ? trigger_and : 
                         (registers_cwtrigsrc[7:6] == 2'b10) ? (~trigger_and) :
                         1'b0;

   wire trigger;
   assign trigger = (registers_cwtrigmod[2:0] == 3'b000) ? trigger_ext :
                    (registers_cwtrigmod[2:0] == 3'b001) ? trigger_advio_i : 
                    (registers_cwtrigmod[2:0] == 3'b010) ? trigger_anapattern_i :
                    (registers_cwtrigmod[2:0] == 3'b011) ? trigger_decodedio_i
                    : 1'b0;

   assign trigger_ext_o = trigger_ext;

   assign trigger_o = trigger;



/* IO Routing */

   assign targetio1_io = targetio_highz ? 1'bZ :
                         registers_iorouting[0 + 0] ? uart_tx_i :
                         registers_iorouting[0 + 2] ? usi_out_i :
                         registers_iorouting[0 + 7] ? registers_iorouting[0 + 6] :
                         1'bZ;

   assign targetio2_io = targetio_highz ? 1'bZ :
                         registers_iorouting[8 + 0] ? uart_tx_i :
                         registers_iorouting[8 + 2] ? usi_out_i :
                         registers_iorouting[8 + 7] ? registers_iorouting[8 + 6] :
                         1'bZ;

   assign targetio3_io = targetio_highz ? 1'bZ :
                         registers_iorouting[16 + 0] ? uart_tx_i :
                         registers_iorouting[16 + 2] ? usi_out_i :
                         registers_iorouting[16 + 4] ? (usi_out_i ? 1'bZ : 1'b0) :
                         registers_iorouting[16 + 5] ? (uart_tx_i ? 1'bZ : 1'b0) :
                         registers_iorouting[16 + 7] ? registers_iorouting[16 + 6] :
                         1'bZ;

   assign targetio4_io = targetio_highz ? 1'bZ :
                         registers_iorouting[24 + 0] ? uart_tx_i :
                         registers_iorouting[24 + 7] ? registers_iorouting[24 + 6] :
                         1'bZ;
 
   assign uart_rx_o = registers_iorouting[0 + 1] ? targetio1_io :
                      registers_iorouting[8 + 1] ? targetio2_io :
                      registers_iorouting[16 + 1] ? targetio3_io :
                      registers_iorouting[24 + 1] ? targetio3_io :
                      1'b1;

   assign usi_in_o = registers_iorouting[0 + 3] ? targetio1_io :
                     registers_iorouting[8 + 3] ? targetio2_io :
                     registers_iorouting[16 + 3] ? targetio3_io :
                     1'b1; 


   assign enable_output_nrst = registers_iorouting[48];
   assign output_nrst = registers_iorouting[49];
   assign enable_output_pdid = registers_iorouting[50];
   assign output_pdid = registers_iorouting[51];
   assign enable_output_pdic = registers_iorouting[52];
   assign output_pdic = registers_iorouting[53];
  
   always @(posedge clk_usb) begin
      if (reset) begin
         registers_ioread <= 4'b0000;
      end else begin
         registers_ioread[3:0] <= {targetio4_io, targetio3_io, targetio2_io, targetio1_io};
      end
   end
  

   reg [7:0] reg_datao_reg;
   assign reg_datao = reg_datao_reg;

   always @(posedge clk_usb) begin
      if (reg_read) begin
         case (reg_address)
           `CW_EXTCLK_ADDR: reg_datao_reg <= registers_cwextclk; 
           `CW_TRIGSRC_ADDR: reg_datao_reg <= registers_cwtrigsrc; 
           `CW_TRIGMOD_ADDR: reg_datao_reg <= registers_cwtrigmod; 
           `CW_IOROUTE_ADDR: reg_datao_reg <= registers_iorouting[reg_bytecnt*8 +: 8];
           `CW_IOREAD_ADDR: reg_datao_reg <= {4'b0000, registers_ioread};
           default: reg_datao_reg <= 0;
         endcase
      end
      else
         reg_datao_reg <= 0;
   end  

   always @(posedge clk_usb) begin
      if (reset) begin
         registers_cwextclk <= 8'b00000011;
         registers_cwtrigsrc <= 8'b00100000;
         registers_cwtrigmod <= 0;
         registers_iorouting <= 64'b00000010_00000001;
      end else if (reg_write) begin
         case (reg_address)
           `CW_EXTCLK_ADDR: registers_cwextclk <= reg_datai;
           `CW_TRIGSRC_ADDR: registers_cwtrigsrc <= reg_datai;
           `CW_TRIGMOD_ADDR: registers_cwtrigmod <= reg_datai;
           `CW_IOROUTE_ADDR: registers_iorouting[reg_bytecnt*8 +: 8] <= reg_datai;
           default: ;
         endcase
      end
   end


 `ifdef CHIPSCOPE
   assign cs_data[5:0] = reg_address;
   assign cs_data[21:6] = reg_bytecnt;
   assign cs_data[29:22] = reg_datai;
   assign cs_data[37:30] = reg_datao;
   assign cs_data[38] = reg_read;
   assign cs_data[39] = reg_write;
   assign cs_data[40] = reg_addrvalid;
   assign cs_data[46:41] = reg_hypaddress;
   assign cs_data[62:47] = reg_hyplen;
 `endif
 
endmodule
`default_nettype wire
