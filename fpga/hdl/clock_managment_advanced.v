`timescale 1ns / 1ps
`default_nettype none
`include "includes.v"
/***********************************************************************
This file is part of the OpenADC Project. See www.newae.com for more details,
or the codebase at http://www.assembla.com/spaces/openadc .

This file is the clock managment, which deals with selecting the ADC clock and
required phase shifts. This file will be very implementation-specific, since
different chips & vendors offer different features.

Copyright (c) 2012-2021, Colin O'Flynn <coflynn@newae.com>. All rights reserved.
This project is released under the Modified FreeBSD License. See LICENSE
file which should have came with this code.
*************************************************************************/
module clock_managment_advanced(
    input  wire           reset, //Does NOT reset CLKGEN block

    /* Clock sources */
    input  wire           clk_usb,     //System clock
    input  wire           clk_ext,     //External clock, aka HS1

    /* Clock to ADC */
    output wire           adc_clk_out, //Output clock to ADC
`ifdef ADCCLK_FEEDBACK
    input  wire           adc_clk_feedback,
`endif

    /* Clock to DUT */
    output wire           clkgen,

    /* Clock selection */
    input  wire [2:0]     clkadc_source,
    input  wire           clkgen_source,
    
    /* Clock to System compensates for wire delay of ADC clock */
    output wire           systemsample_clk,
    
    /* Mul/Div Control for Generated clock */
    input  wire           clkgen_reset,
    input  wire [7:0]     clkgen_mul,
    input  wire [7:0]     clkgen_div,
    input  wire           clkgen_load,
    output wire           clkgen_done,
    
    /* Phase shift control for external clock (clock: clk_usb) */
    input  wire [8:0]     phase_requested,
    output wire [8:0]     phase_actual,
    input  wire           phase_load,
    output wire           phase_done, 
    /* Is Selected DCM Locked? */
    output wire           dcm_adc_locked,
    output wire           dcm_gen_locked 
    );
 
    wire ADC_clk_extsrc;
    wire ADC_clk_sample;
    
    wire dcm_psen;
    wire dcm_psincdec;
    wire dcm_psdone;
    wire [7:0] dcm_status;

    dcm_phaseshift_interface dcmps(.clk_usb(clk_usb),
                                   .reset_i(reset),
                                   .default_value_i(9'd0),
                                   .value_i(phase_requested),
                                   .load_i(phase_load),
                                   .value_o(phase_actual),
                                   .done_o(phase_done),
                                   .dcm_psen_o(dcm_psen),
                                   .dcm_psincdec_o(dcm_psincdec),
                                   .dcm_psdone_i(dcm_psdone),
                                   .dcm_status_i(dcm_status));

    wire clkgen_progdone;
    wire clkgen_progdata;
    wire clkgen_progen;

    dcm_clkgen_load clkgenload(
       .clk_usb(clk_usb),
       .reset_i(clkgen_reset),
       .mult(clkgen_mul),
       .div(clkgen_div),
       .load(clkgen_load),
       .done(clkgen_done),
       .PROGDONE(clkgen_progdone),
       .PROGDATA(clkgen_progdata),
       .PROGEN(clkgen_progen)
    );


    wire clkb;
    wire clkgenfx_in;

    wire dcm_clk_in;
    wire clkgenfx_out;
     
    `ifdef __ICARUS__
       assign dcm_clk_in = clkadc_source[2]? clk_ext : clkgenfx_out;
       assign clkgenfx_in = clkgen_source? clk_ext : clk_usb;
    `else
       BUFGMUX #(
       .CLK_SEL_TYPE("ASYNC") // Glitchles ("SYNC") or fast ("ASYNC") clock switch-over
       )
       clkdcm_mux (
       .O(dcm_clk_in), // 1-bit output: Clock buffer output
       .I0(clkgenfx_out), // 1-bit input: Clock buffer input (S=0)
       .I1(clk_ext), // 1-bit input: Clock buffer input (S=1)
       .S(clkadc_source[2]) // 1-bit input: Clock buffer select
       );  


       BUFGMUX #(
       .CLK_SEL_TYPE("ASYNC") // Glitchles ("SYNC") or fast ("ASYNC") clock switch-over
       )
       clkgenfx_mux (
       .O(clkgenfx_in), // 1-bit output: Clock buffer output
       .I0(clk_usb), // 1-bit input: Clock buffer input (S=0)
       .I1(clk_ext), // 1-bit input: Clock buffer input (S=1)
       .S(clkgen_source) // 1-bit input: Clock buffer select
       ); 
    `endif

    wire dcm_locked_int;
    wire dcm_clk;

    //dcm_locked_int may be high if clock is removed, so also check clkfx output is toggling
    assign dcm_adc_locked = dcm_locked_int & (~dcm_status[2]);

    wire ADC_clk_times4;
    wire ADC_clk;

    `ifdef __ICARUS__
       assign ADC_clk_times4 = dcm_clk_in;
       assign ADC_clk = dcm_clk_in;
    `else
    wire adcfb;
    MMCM_adc_clock_gen U_adc_clock_gen (
       // Clock out ports
       .reset           (reset),
       .clk_in1         (dcm_clk_in),
       .clk_out1        (ADC_clk),
       .clk_out2        (ADC_clk_times4),
       .locked          (dcm_locked_int),
       .clkfb_in        (adcfb),
       .clkfb_out       (adcfb),
       .psclk           (clk_usb),
       .psen            (dcm_psen),
       .psincdec        (dcm_psincdec),
       .psdone          (dcm_psdone)
    );
    /* OG DCM_SP: Digital Clock Manager
    // Spartan-6
    // Xilinx HDL Libraries Guide, version 13.2
    DCM_SP #(
    .CLKFX_DIVIDE(1), // Divide value on CLKFX outputs - D - (1-32)
    .CLKFX_MULTIPLY(4), // Multiply value on CLKFX outputs - M - (2-32)
    .CLKIN_DIVIDE_BY_2("FALSE"), // CLKIN divide by two (TRUE/FALSE)
    //.CLKIN_PERIOD(10.0), // Input clock period specified in nS
    .CLKOUT_PHASE_SHIFT("VARIABLE"), // Output phase shift (NONE, FIXED, VARIABLE)
    .CLK_FEEDBACK("2X"), // Feedback source (NONE, 1X, 2X)
    .DESKEW_ADJUST("SYSTEM_SYNCHRONOUS"), // SYSTEM_SYNCHRNOUS or SOURCE_SYNCHRONOUS
    .PHASE_SHIFT(0), // Amount of fixed phase shift (-255 to 255)
    .STARTUP_WAIT("FALSE") // Delay config DONE until DCM_SP LOCKED (TRUE/FALSE)
    )
    DCM_extclock_gen (
    .CLK2X(dcm_clk),
    .CLK0(ADC_clk),
    .CLK2X180(),
    .CLK90(),
    .CLK180(),
    .CLK270(),
    .CLKFX(ADC_clk_times4), // 1-bit output: Digital Frequency Synthesizer output (DFS)
    .CLKFX180(),
    .CLKDV(), //TODO: Use this output for additional options
    .LOCKED(dcm_locked_int), // 1-bit output: DCM_SP Lock Output
    .PSDONE(dcm_psdone), // 1-bit output: Phase shift done output
    .STATUS(dcm_status), // 8-bit output: DCM_SP status output
    .CLKFB(dcm_clk), // 1-bit input: Clock feedback input
    .CLKIN(dcm_clk_in), // 1-bit input: Clock input
    .PSCLK(clk_usb), // 1-bit input: Phase shift clock input
    .PSEN(dcm_psen), // 1-bit input: Phase shift enable
    .PSINCDEC(dcm_psincdec), // 1-bit input: Phase shift increment/decrement input
    .RST(reset) // 1-bit input: Active high reset input
    );
    */
    `endif

    wire clkgenfx_dev_out;
    wire dcm2_locked_int;
    wire [2:1] dcm2_status;
    assign dcm_gen_locked = dcm2_locked_int & (~dcm2_status[2]);

    `ifdef __ICARUS__
       assign clkgenfx_out = clkgenfx_in;

    `else
    MMCM_clkgen U_clkgen (
       .reset           (reset),
       .clk_in1         (clkgenfx_in),
       .clk_out1        (clkgenfx_out),
       .locked          (dcm2_locked_int), // TODO: rename more descriptively
       // Dynamic reconfiguration ports - TODO
       .daddr           (7'b0),        // input [6:0] daddr
       .dclk            (clk_usb),         // input dclk
       .den             (1'b0),          // input den
       .din             (16'b0),          // input [15:0] din
       .dout            (),         // output [15:0] dout
       .drdy            (),         // output drdy
       .dwe             ()           // output dwe
    );
    /* OG: DCM_CLKGEN: Frequency Aligned Digital Clock Manager
    // Spartan-6
    // Xilinx HDL Libraries Guide, version 14.3
    DCM_CLKGEN #(
    .CLKFXDV_DIVIDE(4), // CLKFXDV divide value (2, 4, 8, 16, 32)
    .CLKFX_DIVIDE(2), // Divide value - D - (1-256)
    .CLKFX_MULTIPLY(2), // Multiply value - M - (2-256)
    .CLKFX_MD_MAX(1.0), // Specify maximum M/D ratio for timing anlysis
    //.CLKIN_PERIOD(10.0), // Input clock period specified in nS
    .SPREAD_SPECTRUM("NONE"), // Spread Spectrum mode "NONE"
    .STARTUP_WAIT("FALSE") // Delay config DONE until DCM_CLKGEN LOCKED
    )
    DCM_CLKGEN_inst (
    .CLKFX(clkgenfx_out), // 1-bit output: Generated clock output
    .CLKFX180(), // 1-bit output: Generated clock output 180 degree out of phase from CLKFX.
    .CLKFXDV(), // 1-bit output: Divided clock output
    .LOCKED(dcm2_locked_int), // 1-bit output: Locked output
    .PROGDONE(clkgen_progdone), // 1-bit output: Active high output to indicate the successful re-programming
    .STATUS(dcm2_status), // 2-bit output: DCM_CLKGEN status
    .CLKIN(clkgenfx_in), // 1-bit input: Input clock
    .FREEZEDCM(1'b0), // 1-bit input: Prevents frequency adjustments to input clock
    .PROGCLK(clk_usb), // 1-bit input: Clock input for M/D reconfiguration
    .PROGDATA(clkgen_progdata), // 1-bit input: Serial data input for M/D reconfiguration
    .PROGEN(clkgen_progen), // 1-bit input: Active high program enable
    .RST(clkgen_reset) // 1-bit input: Reset input pin
    );
    */
    `endif

    assign clkgen = clkgenfx_out;

    //Output buffers
    wire out_from_dcmmux;
    `ifdef __ICARUS__
       assign ADC_clk_sample = clkadc_source[0]? clk_ext : out_from_dcmmux;
       assign out_from_dcmmux = clkadc_source[1]? ADC_clk : ADC_clk_times4;
    `else
       BUFGMUX #(
       .CLK_SEL_TYPE("ASYNC") // Glitchles ("SYNC") or fast ("ASYNC") clock switch-over
       )
       adcclk_mux (
       .O(ADC_clk_sample), // 1-bit output: Clock buffer output
       .I0(out_from_dcmmux), // 1-bit input: Clock buffer input (S=0)
       .I1(clk_ext), // 1-bit input: Clock buffer input (S=1)
       .S(clkadc_source[0]) // 1-bit input: Clock buffer select
       );

        BUFGMUX #(
       .CLK_SEL_TYPE("ASYNC") // Glitchles ("SYNC") or fast ("ASYNC") clock switch-over
       )
       adcclk_0_mux (
       .O(out_from_dcmmux), // 1-bit output: Clock buffer output
       .I0(ADC_clk_times4), // 1-bit input: Clock buffer input (S=0)
       .I1(ADC_clk), // 1-bit input: Clock buffer input (S=1)
       .S(clkadc_source[1]) // 1-bit input: Clock buffer select
       );
    `endif


`ifdef ADCCLK_FEEDBACK
        `ifdef __ICARUS__
            //assign systemsample_clk = adc_clk_feedback;
            assign systemsample_clk = ADC_clk_sample; //TODO-temp! YYY
        `else
            IBUFG IBUFG_inst (
            .O(systemsample_clk),
            //.I(adc_clk_feedback) );
            .I(ADC_clk_sample) ); // YYY
        `endif
`else
        assign systemsample_clk = ADC_clk_sample;
`endif

        `ifdef __ICARUS__
           assign adc_clk_out = ADC_clk_sample;
        `else
           //Output clock using DDR2 block (recommended for Spartan-6 device)
           // TODO XXX is this also needed for Artix7?
           ODDR2 #(
              // The following parameters specify the behavior
              // of the component.
              .DDR_ALIGNMENT("NONE"), // Sets output alignment to "NONE", "C0" or "C1"
              .INIT(1'b0),    // Sets initial state of the Q output to 1'b0 or 1'b1
              .SRTYPE("SYNC") // Specifies "SYNC" or "ASYNC" set/reset
           )
           ODDR2_inst (
              .Q(adc_clk_out),   // 1-bit DDR output data
              .C0(ADC_clk_sample), // 1-bit clock input
              .C1(~ADC_clk_sample), // 1-bit clock input
              .CE(1'b1), // 1-bit clock enable input
              .D0(1'b1), // 1-bit data input (associated with C0)
              .D1(1'b0), // 1-bit data input (associated with C1)
              .R(1'b0),   // 1-bit reset input
              .S(1'b0)    // 1-bit set input
           );
        `endif

endmodule
`default_nettype wire
