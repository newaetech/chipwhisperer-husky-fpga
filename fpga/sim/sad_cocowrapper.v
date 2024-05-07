`timescale 1 ns / 1 ps
`default_nettype none

/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more
details, or the codebase at http://www.chipwhisperer.com

Copyright (c) 2024, NewAE Technology Inc. All rights reserved.
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

module sad_cocowrapper #(
    parameter pREF_SAMPLES = 8
)(
    // DUT things:
    input wire         clk_usb,
    input wire         clk_adc,
    input wire         reset,

    inout wire [7:0]    USB_Data,
    input wire [7:0]    USB_Addr,
    input wire          USB_RDn,
    input wire          USB_WRn,
    input wire          USB_CEn,
    input wire          USB_ALEn,

    input wire [11:0]   adc_datain,
    input wire          armed_and_ready,
    output wire         trigger,

    // testbench things:
    input  wire [31:0]  errors,
    input  wire [5:0]   latency,
    input  wire [15:0]  model_counter[0:pREF_SAMPLES-1],
    input  wire [pREF_SAMPLES/2-1:0]  model_extended_mode,
    input  wire [31:0]  model_ready2trigger,
    input  wire         under_threshold,
    input  wire         long_enough,
    input  wire         expected_trigger,
    input  wire         multiple_triggers,
    output reg          trigger_error,
    output reg          debug_emode_mismatch

);

    parameter pDUMP = 0;
    parameter pBYTECNT_SIZE = 7;
    parameter pBITS_PER_SAMPLE = 12;

    parameter pINTERVAL_MATCHING = 0;
    parameter pCOUNTER_WIDTH = 12;
    parameter pEMODE = 0;


    initial begin
       if (pDUMP) begin
           $dumpfile("results/sad_coco.fst");
           $dumpvars(0, sad_cocowrapper);
       end
    end

    wire trigger_presync;
    assign trigger = trigger_presync_r;

    reg [18:0] trigger_expected_pipe;
    always @(posedge clk_adc)
        trigger_expected_pipe <= {trigger_expected_pipe[17:0], expected_trigger};
    wire trigger_expected_delayed = trigger_expected_pipe[latency-4];

    reg trigger_presync_r;
    always @(posedge clk_adc) begin
        trigger_presync_r <= trigger_presync;
        if ((trigger_expected_delayed != trigger_presync) && ~(~multiple_triggers && trigger_presync_r))
            trigger_error <= 1'b1;
        else
            trigger_error <= 1'b0;
    end

    wire [pREF_SAMPLES/2-1:0] debug_emode;
    reg [pREF_SAMPLES/2-1:0] model_extended_mode_r1, model_extended_mode_r2, model_extended_mode_r3, model_extended_mode_r4, model_extended_mode_r5;
    always @(posedge clk_adc) begin
        model_extended_mode_r1 <= model_extended_mode;
        model_extended_mode_r2 <= model_extended_mode_r1;
        model_extended_mode_r3 <= model_extended_mode_r2;
        model_extended_mode_r4 <= model_extended_mode_r3;
        model_extended_mode_r5 <= model_extended_mode_r4;
        debug_emode_mismatch <= (debug_emode !== model_extended_mode_r5);
    end


    sad_wrapper #(
        .pBYTECNT_SIZE      (7),
        .pREF_SAMPLES       (pREF_SAMPLES),
        .pBITS_PER_SAMPLE   (pBITS_PER_SAMPLE)
    ) U_dut (
        .reset              (reset),
        .clk_usb            (clk_usb),
        .clk_adc            (clk_adc),
        .adc_datain         (adc_datain),
        .armed_and_ready    (armed_and_ready),
        .USB_Data           (USB_Data     ),
        .USB_Addr           (USB_Addr     ),
        .USB_RDn            (USB_RDn      ),
        .USB_WRn            (USB_WRn      ),
        .USB_CEn            (USB_CEn      ),
        .USB_ALEn           (USB_ALEn     ),
        .trigger            (trigger_presync),
        .debug_emode        (debug_emode  )
    );

    // debug only:
    wire [15:0] sad_model0  = model_counter[0 ];
    wire [15:0] sad_model1  = model_counter[1 ];
    wire [15:0] sad_model2  = model_counter[2 ];
    wire [15:0] sad_model3  = model_counter[3 ];
    wire [15:0] sad_model4  = model_counter[4 ];
    wire [15:0] sad_model5  = model_counter[5 ];
    wire [15:0] sad_model6  = model_counter[6 ];
    wire [15:0] sad_model7  = model_counter[7 ];
    wire [15:0] sad_model8  = model_counter[8 ];
    wire [15:0] sad_model9  = model_counter[9 ];
    wire [15:0] sad_model10 = model_counter[10];
    wire [15:0] sad_model11 = model_counter[11];
    wire [15:0] sad_model12 = model_counter[12];
    wire [15:0] sad_model13 = model_counter[13];
    wire [15:0] sad_model14 = model_counter[14];
    wire [15:0] sad_model15 = model_counter[15];
    wire [15:0] sad_model16 = model_counter[16];
    wire [15:0] sad_model17 = model_counter[17];
    wire [15:0] sad_model18 = model_counter[18];
    wire [15:0] sad_model19 = model_counter[19];
    wire [15:0] sad_model20 = model_counter[20];
    wire [15:0] sad_model21 = model_counter[21];
    wire [15:0] sad_model22 = model_counter[22];
    wire [15:0] sad_model23 = model_counter[23];
    wire [15:0] sad_model24 = model_counter[24];
    wire [15:0] sad_model25 = model_counter[25];
    wire [15:0] sad_model26 = model_counter[26];
    wire [15:0] sad_model27 = model_counter[27];
    wire [15:0] sad_model28 = model_counter[28];
    wire [15:0] sad_model29 = model_counter[29];
    wire [15:0] sad_model30 = model_counter[30];
    wire [15:0] sad_model31 = model_counter[31];

endmodule
`default_nettype wire
