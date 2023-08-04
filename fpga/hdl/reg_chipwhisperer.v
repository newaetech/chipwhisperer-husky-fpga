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
   parameter pBYTECNT_SIZE = 7,
   parameter pUSERIO_WIDTH = 8,
   parameter pSEQUENCER_NUM_TRIGGERS = 4,
   parameter pSEQUENCER_COUNTER_WIDTH = 16

)(
   input  wire         reset_i,
   input  wire         clk_usb,
   input  wire [7:0]   reg_address,  // Address of register
   input  wire [pBYTECNT_SIZE-1:0]  reg_bytecnt,  // Current byte count
   input  wire [7:0]   reg_datai,    // Data to write
   output wire [7:0]   reg_datao,    // Data to read
   input  wire         reg_read,     // Read flag
   input  wire         reg_write,    // Write flag

   /* External Clock */
   inout  wire        auxio,
   input  wire        target_hs1,
   output wire        target_hs2,
   output wire        extclk_o,         // for frequency measurement and ADC_CLKP/N to PLL
   output wire        target_clk,       // for trace

   /* Extern Trigger Connections */
   input  wire        trigger_io1_i,
   input  wire        trigger_io2_i,
   input  wire        trigger_io3_i,
   input  wire        trigger_io4_i,
   input  wire        trigger_nrst_i,

   /* Advanced IO Trigger Connections */
   output wire        uart_trigger_line,
   output wire        edge_trigger_line,
   output wire        decodeio_active,
   output wire        sad_active,
   output wire        edge_trigger_active,
   input  wire        trigger_advio_i, 
   input  wire        trigger_decodedio_i,
   input  wire        trigger_trace_i,
   input  wire        trigger_adc_i,
   input  wire        trigger_sad_i,
   input  wire        trigger_edge_i,

   /* Clock Sources */
   input  wire        pll_fpga_clk,
   input  wire        glitchclk,
   input  wire        glitch_mmcm1_clk_out,
   input  wire        adc_sample_clk,
   input  wire        trace_fe_clk,

   /* GPIO Pins & Routing */
   inout  wire        targetio1_io,
   inout  wire        targetio2_io,
   inout  wire        targetio3_io,
   inout  wire        targetio4_io,

   /* solely for the ability to read their state: */
   input  wire        target_PDID,
   input  wire        target_PDIC,
   input  wire        target_nRST,
   input  wire        target_MISO,
   input  wire        target_MOSI,
   input  wire        target_SCK,

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

   output wire        targetpower_off,

   input  wire        trace_en,
   input  wire [7:0]  trace_userio_dir,
   output wire [pUSERIO_WIDTH-1:0] userio_cwdriven,
   output reg  [pUSERIO_WIDTH-1:0] userio_drive_data,
   output reg                      userio_fpga_debug,
   output reg                      userio_target_debug,
   output reg                      userio_target_debug_swd,
   output reg [3:0]                userio_fpga_debug_select,
   input  wire [pUSERIO_WIDTH-1:0] userio_d,
   input  wire                     userio_clk,

   /* Main trigger connections */
   input  wire        armed_and_ready,
   output wire        trigger_capture,  // Trigger signal to capture system
   output wire        trigger_glitch,   // Trigger signal to glitch system
   output wire        trigger_trace,    // Trigger signal to trace
   output wire        trig_glitch_o_mcx,// trig/glitch MCX 

   input  wire        trace_exists,
   input  wire        la_exists
); 

   wire reset;
   assign reset = reset_i;

 /*  
CW_EXTCLK_ADDR, address 38 (0x26) - External Clock Connections (One Byte)

    [  X RO RO FA FA S  S  S ]
    
    [2:0]
    S S S = 000: AUX I/O MCX
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
    [  M  M  R4  R3  R2  R1  NR FA ]
    All external triggers are combined into a single
    trigger signal, which can then be passed into one
    of the enabled 'trigger modules'
    FA = Front Panel Channel A / Aux SMA
    NR = nRESET Pin
    R1 = Rear TargetIO - Line 1
    R2 = Rear TargetIO - Line 2
    R3 = Rear TargetIO - Line 3
    R4 = Rear TargetIO - Line 4
    MM = Mode to combine multiple channels
        00 = OR
        01 = AND

CW_TRIGMOD_ADDR, address 40 (0x28) - Trigger Module Enabled
    [ X  X  X  X  FA M  M  M ]
    M M M = 000 Normal Edge-Mode Trigger
            001 Advanced IO Pattern Trigger
            010 Advanced SAD Trigger
            011 Decoded IO Trigger
            100 Trace Trigger
            101 ADC level trigger
    FA = Output trigger to Front Panel A / Aux SMA

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

   reg [2:0] registers_cwauxio;
   reg [7:0] registers_cwextclk;
   reg [pSEQUENCER_NUM_TRIGGERS*16-1:0] registers_cwtrigsrc; // note: for CW-Lite/Pro, this is an 8-bit register
   reg [pSEQUENCER_NUM_TRIGGERS*8-1:0] registers_cwtrigmod;  // note: for CW-Lite/Pro, this is an 8-bit register
   reg [63:0] registers_iorouting;
   reg [9:0] registers_ioread;
   reg reg_external_clock;
   reg [pUSERIO_WIDTH-1:0] reg_userio_cwdriven;
   reg [63:0] reg_softpower_control;

   wire targetio_highz;

   //Do to no assumed phase relationship we use regular old fabric for switching
   assign extclk_o = (registers_cwextclk[2:0] == 3'b000) ? auxio :
                     (registers_cwextclk[2:0] == 3'b011) ? target_hs1 : 
                     1'b0;

   assign target_clk = reg_external_clock? extclk_o : target_hs2;

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


   assign auxio = (registers_cwauxio[0])? rearclk : 1'bZ;


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

   // Target Power: switched ON from OFF state using PWM for programmable soft-start.
   // Soft-start is enabled by default via registers_iorouting[42].
   // PWM parameters are from reg_softpower_control:
   // - softpower_pwm_cycles1 + softpower_pwm_cycles2: number of PWM on/off cycles before power is fully on
   // - softpower_pwm_period: number of cycles in PWM period
   // - softpower_pwm_off_time1: number of cycles in PWM period where power is off, for the first softpower_pwm_cycles1
   // - softpower_pwm_off_time2: number of cycles in PWM period where power is off, for the next softpower_pwm_cycles2
   //
   wire targetpower_slow = ~registers_iorouting[42];
   wire reg_targetpower_off = registers_iorouting[41];
   wire [7:0] softpower_pwm_cycles1 = reg_softpower_control[7:0];
   wire [7:0] softpower_pwm_cycles2 = reg_softpower_control[15:8];
   wire [15:0] softpower_pwm_period = reg_softpower_control[31:16];
   wire [15:0] softpower_pwm_off_time1 = reg_softpower_control[47:32];
   wire [15:0] softpower_pwm_off_time2 = reg_softpower_control[63:48];
   reg  [15:0] softpower_pwm_off_time;

   reg targetpower_soft_on;
   reg reg_targetpower_off_prev;
   always @(posedge clk_usb) begin
       reg_targetpower_off_prev <= reg_targetpower_off;
       if ((reg_targetpower_off == 1'b0) && (reg_targetpower_off_prev == 1'b1))
           targetpower_soft_on <= 1'b1;
       else if (reg_targetpower_off == 1'b1)
           targetpower_soft_on <= 1'b0;
   end

   reg [15:0] soft_start_pwm = 0;
   always @(posedge clk_usb) begin
       if ((soft_start_pwm == softpower_pwm_period) || ~targetpower_soft_on)
           soft_start_pwm <= 0;
       else
           soft_start_pwm <= soft_start_pwm + 16'd1;
   end

   reg output_src_pwm;
   reg [15:0] soft_start_cnt;
   always @(posedge clk_usb) begin
       if (targetpower_soft_on == 1'b0) begin
           soft_start_cnt <= 0;
           output_src_pwm <= 1'b0;
           softpower_pwm_off_time <= softpower_pwm_off_time1;
       end
       else begin
           if (soft_start_cnt == softpower_pwm_cycles1) begin
               softpower_pwm_off_time <= softpower_pwm_off_time2;
               soft_start_cnt <= soft_start_cnt + 16'd1;
           end
           else if (soft_start_cnt == softpower_pwm_cycles1 + softpower_pwm_cycles2)
               output_src_pwm <= 1'b0;
           else begin
               output_src_pwm <= 1'b1;
               if (soft_start_pwm == 0)
                   soft_start_cnt <= soft_start_cnt + 16'd1;
           end
       end
   end

   wire targetpower_off_pwm = (soft_start_pwm < softpower_pwm_off_time) ? 1'b1 : 1'b0; 
   assign targetpower_off = (output_src_pwm & targetpower_slow) ? targetpower_off_pwm : reg_targetpower_off;

   assign targetio_highz = reg_targetpower_off;

   wire [pSEQUENCER_NUM_TRIGGERS-1:0] tc_decodeio_active;
   wire [pSEQUENCER_NUM_TRIGGERS-1:0] tc_sad_active;
   wire [pSEQUENCER_NUM_TRIGGERS-1:0] tc_edge_trigger_active;
   wire [pSEQUENCER_NUM_TRIGGERS-1:0] trigger_chooser;
   wire [pSEQUENCER_NUM_TRIGGERS-1:0] trigger_ext;

   genvar i;
   generate 
       for (i = 0; i < pSEQUENCER_NUM_TRIGGERS; i = i + 1) begin
           trigger_chooser U_trigger_chooser (
               .I_trigsrc               (registers_cwtrigsrc[i*16 +: 16]),
               .I_trigmod               (registers_cwtrigmod[i*8 +: 8]),
                                                              
               .auxio                   (auxio                     ),
               .trigger_nrst_i          (trigger_nrst_i            ),
               .trigger_io1_i           (trigger_io1_i             ),
               .trigger_io2_i           (trigger_io2_i             ),
               .trigger_io3_i           (trigger_io3_i             ),
               .trigger_io4_i           (trigger_io4_i             ),
               .userio_d                (userio_d                  ),
                                                              
               .trigger_advio_i         (trigger_advio_i           ),
               .trigger_sad_i           (trigger_sad_i             ),
               .trigger_decodedio_i     (trigger_decodedio_i       ),
               .trigger_trace_i         (trigger_trace_i           ),
               .trigger_adc_i           (trigger_adc_i             ),
               .trigger_edge_i          (trigger_edge_i            ),
                                                              
               .O_decodeio_active       (tc_decodeio_active[i]     ),
               .O_sad_active            (tc_sad_active[i]          ),
               .O_edge_trigger_active   (tc_edge_trigger_active[i] ),
               .O_trigger               (trigger_chooser[i]        ),
               .trigger_ext             (trigger_ext[i]            )
           );
       end
   endgenerate

   wire trigger_sequencer_out;
   trigger_sequencer #(
       .pNUM_TRIGGERS                  (pSEQUENCER_NUM_TRIGGERS),
       .pCOUNTER_WIDTH                 (pSEQUENCER_COUNTER_WIDTH)
   ) U_trigger_sequencer (
       .adc_clk                        (adc_sample_clk),
       .armed_and_ready                (armed_and_ready),
       .I_bypass                       (~trigger_sequencer_on),
       .I_trigger                      (trigger_chooser),
       .I_min_wait                     (reg_seq_triggers_minmax[(pSEQUENCER_NUM_TRIGGERS-1)*pSEQUENCER_COUNTER_WIDTH-1:0]),
       .I_max_wait                     (reg_seq_triggers_minmax[(pSEQUENCER_NUM_TRIGGERS-1)*pSEQUENCER_COUNTER_WIDTH*2-1:(pSEQUENCER_NUM_TRIGGERS-1)*pSEQUENCER_COUNTER_WIDTH]),
       .I_last_trigger                 (trigger_sequencer_num_triggers),
       .O_trigger                      (trigger_sequencer_out)
   );


   wire [3:0] uart_chooser = reg_uart_edge_chooser[7:4];
   wire [3:0] edge_chooser = reg_uart_edge_chooser[3:0];
   wire trigger_sequencer_on = reg_seq_triggers_config[7];
   wire [3:0] trigger_sequencer_num_triggers = reg_seq_triggers_config[3:0];

   assign uart_trigger_line = (trigger_sequencer_on)? trigger_ext[uart_chooser] : trigger_ext[0];
   assign edge_trigger_line = (trigger_sequencer_on)? trigger_ext[edge_chooser] : trigger_ext[0];

   wire trigger_glitch_pulse;
   wire trigger_trace_pulse;
   cdc_pulse U_trigger_pulse_glitch (
       .reset_i       (reset),
       .src_clk       (adc_sample_clk),
       .dst_clk       (glitch_mmcm1_clk_out),
       .src_pulse     ((trigger_sequencer_on)? trigger_sequencer_out : trigger_chooser[0] ),
       .dst_pulse     (trigger_glitch_pulse)
   );

   cdc_pulse U_trigger_pulse_trace (
       .reset_i       (reset),
       .src_clk       (adc_sample_clk),
       .dst_clk       (trace_fe_clk),
       .src_pulse     ((trigger_sequencer_on)? trigger_sequencer_out : trigger_chooser[0] ),
       .dst_pulse     (trigger_trace_pulse)
   );

   // Here we get a bit creative to miminize glitch latency when triggering
   // from trigger_ext. In CW-lite/pro, this signal was sampled
   // asynchronously, but we want to avoid that here. Moreover we need to
   // glitch only on the rising edge of trigger_ext. So we do this to avoid
   // adding latency:
   wire trigger_ext_glitch_pulse;
   (* ASYNC_REG = "TRUE" *) reg trigger_ext_pipe;
   reg trigger_ext_r;
   always @(negedge glitch_mmcm1_clk_out)
       {trigger_ext_r, trigger_ext_pipe} <= {trigger_ext_pipe, trigger_ext[0]};
   assign trigger_ext_glitch_pulse = trigger_ext & ~trigger_ext_r;

   assign trigger_glitch = (~trigger_sequencer_on && (registers_cwtrigmod[2:0] == 3'b000))? trigger_ext_glitch_pulse : trigger_glitch_pulse;
   assign trigger_trace  = (~trigger_sequencer_on && (registers_cwtrigmod[2:0] == 3'b000))? trigger_ext : trigger_trace_pulse;


   assign decodeio_active       = (trigger_sequencer_on)? |tc_decodeio_active : tc_decodeio_active[0];
   assign sad_active            = (trigger_sequencer_on)? |tc_sad_active : tc_sad_active[0];
   assign edge_trigger_active   = (trigger_sequencer_on)? |tc_edge_trigger_active : tc_edge_trigger_active[0];

   wire trig_glitch_pre = registers_cwauxio[1] ? glitchclk : trigger_capture;
   assign trig_glitch_o_mcx = registers_cwauxio[2] ? ~trig_glitch_pre : trig_glitch_pre;
   assign trigger_capture = trigger_sequencer_out;


/* IO Routing */

   assign targetio1_io = targetio_highz ? 1'bZ :
                         registers_iorouting[0 + 0] ? uart_tx_i :
                         registers_iorouting[0 + 7] ? registers_iorouting[0 + 6] :
                         1'bZ;

   assign targetio2_io = targetio_highz ? 1'bZ :
                         registers_iorouting[8 + 0] ? uart_tx_i :
                         registers_iorouting[8 + 7] ? registers_iorouting[8 + 6] :
                         1'bZ;

   assign targetio3_io = targetio_highz ? 1'bZ :
                         registers_iorouting[16 + 0] ? uart_tx_i :
                         registers_iorouting[16 + 4] ? 1'b0 :
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
         registers_ioread[9:8] <= {target_SCK, target_nRST};
         registers_ioread[7:4] <= {target_PDID, target_PDIC, target_MISO, target_MOSI};
         registers_ioread[3:0] <= {targetio4_io, targetio3_io, targetio2_io, targetio1_io};
      end
   end


   reg [7:0] reg_datao_reg;
   assign reg_datao = reg_datao_reg;
   wire [8:0] userio_read = {userio_clk, userio_d};

   always @(*) begin
      if (reg_read) begin
         case (reg_address)
           `CW_AUX_IO:                  reg_datao_reg = {5'b0, registers_cwauxio};
           `CW_EXTCLK_ADDR:             reg_datao_reg = registers_cwextclk; 
           `CW_TRIGSRC_ADDR:            reg_datao_reg = registers_cwtrigsrc[reg_bytecnt*8 +: 8]; 
           `CW_TRIGMOD_ADDR:            reg_datao_reg = registers_cwtrigmod[reg_bytecnt*8 +: 8];
           `CW_IOROUTE_ADDR:            reg_datao_reg = registers_iorouting[reg_bytecnt*8 +: 8];
           `CW_IOREAD_ADDR:             reg_datao_reg = registers_ioread[reg_bytecnt*8 +: 8];

           `USERIO_CW_DRIVEN:           reg_datao_reg = userio_cwdriven[reg_bytecnt*8 +: 8];
           `USERIO_DEBUG_DRIVEN:        reg_datao_reg = {5'b0, userio_target_debug_swd, userio_target_debug, userio_fpga_debug};
           `USERIO_DEBUG_SELECT:        reg_datao_reg = {4'b0, userio_fpga_debug_select};
           `USERIO_READ:                reg_datao_reg = userio_read[reg_bytecnt*8 +: 8];

           `EXTERNAL_CLOCK:             reg_datao_reg = reg_external_clock;
           `COMPONENTS_EXIST:           reg_datao_reg = {6'b0, trace_exists, la_exists};

           `SOFTPOWER_CONTROL:          reg_datao_reg = reg_softpower_control[reg_bytecnt*8 +: 8];

           `SEQ_TRIGGERS_CONFIG:        reg_datao_reg = reg_seq_triggers_config;
           `SEQ_TRIGGERS_MINMAX:        reg_datao_reg = reg_seq_triggers_minmax[reg_bytecnt*8 +: 8];
           `SEQ_TRIGGERS_UART_EDGE_CHOOSER: reg_datao_reg = reg_uart_edge_chooser;

           default: reg_datao_reg = 0;
         endcase
      end
      else
         reg_datao_reg = 0;
   end

   reg [7:0] reg_seq_triggers_config;
   reg [(pSEQUENCER_NUM_TRIGGERS-1)*pSEQUENCER_COUNTER_WIDTH*2 - 1:0]  reg_seq_triggers_minmax;
   reg [7:0] reg_uart_edge_chooser;

   always @(posedge clk_usb) begin
      if (reset) begin
         registers_cwextclk <= 8'b00000011;
         registers_cwtrigsrc <= 16'b00100000;
         registers_cwtrigmod <= 0;
         registers_iorouting <= 64'b00000010_00000001;
         reg_userio_cwdriven <= 8'b0;
         userio_fpga_debug <= 1'b0;
         userio_target_debug <= 1'b0;
         userio_target_debug_swd <= 1'b0;
         userio_drive_data <= 8'b0;
         userio_fpga_debug_select <= 4'b0;
         reg_external_clock <= 1'b0;
         registers_cwauxio <= 3'b0;
         reg_softpower_control <= {16'd0, 16'd1995, 16'd2000, 8'd0, 8'd35};
         reg_seq_triggers_config <= 0;
      end else if (reg_write) begin
         case (reg_address)
           `CW_AUX_IO: registers_cwauxio <= reg_datai[2:0];
           `CW_EXTCLK_ADDR: registers_cwextclk <= reg_datai;
           `CW_TRIGSRC_ADDR: registers_cwtrigsrc[reg_bytecnt*8 +: 8] <= reg_datai;
           `CW_TRIGMOD_ADDR: registers_cwtrigmod[reg_bytecnt*8 +: 8] <= reg_datai;
           `CW_IOROUTE_ADDR: registers_iorouting[reg_bytecnt*8 +: 8] <= reg_datai;

           `USERIO_CW_DRIVEN: reg_userio_cwdriven[reg_bytecnt*8 +: 8] <= reg_datai;
           `USERIO_DEBUG_DRIVEN: {userio_target_debug_swd, userio_target_debug, userio_fpga_debug} <= reg_datai[2:0];
           `USERIO_DEBUG_SELECT: userio_fpga_debug_select <= reg_datai[3:0];
           `USERIO_DRIVE_DATA: userio_drive_data[reg_bytecnt*8 +: 8] <= reg_datai;

           `EXTERNAL_CLOCK: reg_external_clock <= reg_datai[0];

           `SOFTPOWER_CONTROL: reg_softpower_control[reg_bytecnt*8 +: 8] <= reg_datai;

           `SEQ_TRIGGERS_CONFIG: reg_seq_triggers_config <= reg_datai;
           `SEQ_TRIGGERS_MINMAX: reg_seq_triggers_minmax[reg_bytecnt*8 +: 8] <= reg_datai;
           `SEQ_TRIGGERS_UART_EDGE_CHOOSER: reg_uart_edge_chooser <= reg_datai;

           default: ;
         endcase
      end
   end

   // USERIO drive direction can be set via USERIO_CW_DRIVEN, but this gets
   // overwritten by userio_fpga_debug, userio_target_debug,
   // userio_target_debug_swd  and trace_en:
   assign userio_cwdriven = trace_en? trace_userio_dir : 
                            userio_fpga_debug? {pUSERIO_WIDTH{1'b1}} :
                            (userio_target_debug && userio_target_debug_swd)? (~userio_clk? 8'b0010_0000 : 8'b0110_0000 ) :
                            (userio_target_debug && ~userio_target_debug_swd)?  8'b1110_0000  :
                            reg_userio_cwdriven;

endmodule
`default_nettype wire
