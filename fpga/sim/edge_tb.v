`timescale 1 ns / 1 ps
`default_nettype none
`include "includes.v"

/***********************************************************************
This file is part of the ChipWhisperer Project. See www.newae.com for more
details, or the codebase at http://www.chipwhisperer.com

Copyright (c) 2022, NewAE Technology Inc. All rights reserved.
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

module edge_tb();
parameter pCLK_USB_PERIOD = 10;
parameter pCLK_ADC_PERIOD = 6;
parameter pSEED = 1;
parameter pDUMP = 0;
parameter pEDGES = 2;
parameter pMAX_WAIT = 10;
parameter pADDR_WIDTH = 8;
parameter pTIMEOUT_CYCLES = 2000;
parameter pITERATIONS = 3;
parameter pVERBOSE = 0;

// we don't actually use these but tb_reg_tasks.v needs them to exist:
parameter pSTREAM = 0;
parameter pADC_LOW_RES = 0;
parameter pSLOW_READS = 0;
reg i12BitReadCount;
reg  [7:0] rdata_r;

reg clk_usb;
reg clk_adc;
reg reset;
reg armed_and_ready;
wire armed_and_ready_out;
reg trigger_expected;
wire trigger_expected_delayed;
wire trigger;

integer unexpected;
integer delta;

reg setup_done;
reg [7:0] rdata;

wire [7:0] usb_data;
reg  [7:0] usb_wdata;
reg  [7:0] usb_addr;
reg  [7:0] usb_bytecount;
reg        usb_rdn;
reg        usb_wrn;
reg        usb_cen;
reg        usb_alen;

reg trigger_in;
reg [15:0] edges;
reg [15:0] redges;

integer errors;
integer warnings;
integer i, j, k;
integer seed;

wire usb_clk = clk_usb;

wire #1 trigger_in_out = trigger_in;
`include "tb_reg_tasks.v"

// initialization thread:
initial begin
    seed = pSEED;
    $display("Running with seed=%0d", seed);
    rdata = $urandom(seed);

    $display("pEDGES            = %d", pEDGES);
    $display("pMAX_WAIT         = %d", pMAX_WAIT);
    $display("pVERBOSE          = %d", pVERBOSE);
    
    if (pDUMP) begin
       $dumpfile("results/edge_tb.fst");
       $dumpvars(0, edge_tb);
    end
    setup_done = 0;
    errors = 0;
    warnings = 0;
    clk_usb = 1'b0;
    clk_adc = 1'b0;
    reset = 1'b0;
    armed_and_ready = 1'b0;
    usb_addr = 0;
    usb_rdn = 1;
    usb_wrn = 1;
    usb_cen = 1;
    usb_alen = 1;

    if (pEDGES == 0)
        edges = $urandom_range(1, 1024);
    else
        edges = pEDGES;

    #(pCLK_USB_PERIOD*10) reset = 1'b1;
    #(pCLK_USB_PERIOD*10) reset = 1'b0;
    #(pCLK_USB_PERIOD*10);

    rw_lots_bytes(`EDGE_TRIGGER_COUNT);
    write_next_byte(((edges-1) & 16'h00FF));
    write_next_byte(((edges-1) & 16'hFF00)>>8);

    #(pCLK_USB_PERIOD*10) setup_done = 1;
end

// apply data thread:
initial begin
    trigger_expected = 0;
    #1;
    for (j = 0; j < pITERATIONS; j = j + 1) begin
        while (armed_and_ready == 1'b0)
            @(posedge clk_adc) trigger_in = $urandom_range(0, 1);

        repeat(5) @(posedge clk_adc); // prevent edges right around the arming event

        for (i = 0; i < pEDGES; i = i + 1) begin
            repeat($urandom_range(1,pMAX_WAIT)) @(posedge clk_adc);
            trigger_in <= ~trigger_in;
        end
        #1 trigger_expected = 1'b1;
        repeat(2) @(posedge clk_adc);
        trigger_expected = 1'b0;

        while (armed_and_ready) begin
            repeat($urandom_range(1,pMAX_WAIT)) @(posedge clk_adc);
            trigger_in <= ~trigger_in;
        end
    end
end


reg [4:0] trigger_expected_pipe;
always @(posedge clk_adc)
    trigger_expected_pipe <= {trigger_expected_pipe[3:0], trigger_expected};
assign trigger_expected_delayed = trigger_expected_pipe[4];

// so that no edges occur near arming:
reg [4:0] armed_and_ready_pipe;
always @(posedge clk_adc)
    armed_and_ready_pipe <= {armed_and_ready_pipe[3:0], armed_and_ready};
assign armed_and_ready_out = armed_and_ready_pipe[4];


// trigger check thread:
initial begin
    wait (setup_done);
    for (k = 0; k < pITERATIONS; k = k + 1) begin
        @(posedge clk_usb) armed_and_ready = 1'b1;

        wait (trigger || trigger_expected_delayed);
        #1;
        if (trigger && trigger_expected_delayed) begin
            if (pVERBOSE)
                $display("Got trigger at time %t.", $time);
        end
        else begin
            unexpected = $time;
            errors += 1;
            if (trigger) begin // got trigger when it wasn't expected
                wait (trigger_expected_delayed);
                delta = ($time-unexpected+1)/pCLK_ADC_PERIOD;
                $display("ERROR: iteration %d got trigger %d cycles early at time %t", k, delta, $time);
            end
            else begin // expected trigger but it's not there
                wait (trigger);
                delta = ($time-unexpected+1)/pCLK_ADC_PERIOD;
                $display("ERROR: iteration %d got trigger %d cycles late at time %t", k, delta, $time);
            end
        end
        wait (~(trigger || trigger_expected_delayed));
        @(posedge clk_usb) armed_and_ready = 1'b0;

        // if everything went well, count register read value should be reset to 0:
        rw_lots_bytes(`EDGE_TRIGGER_COUNT);
        read_next_byte(redges);
        read_next_byte(rdata);
        redges += (rdata << 8);
        if (redges != edges) begin
            errors += 1;
            $display("ERROR: EDGE_TRIGGER_COUNT register read back %0d (should be %0d)", redges, edges);
        end

        repeat(10) @(posedge clk_adc);
    end

    if (errors)
       $display("SIMULATION FAILED (%0d errors)", errors);
    else
       $display("Simulation passed (%0d warnings)", warnings);
    $finish;
end

// timeout thread:
initial begin
    #(pCLK_USB_PERIOD*pTIMEOUT_CYCLES);
    errors += 1;
    $display("ERROR: global timeout.");
    $display("SIMULATION FAILED (%0d errors)", errors);
    $finish;
end


always #(pCLK_USB_PERIOD/2) clk_usb = !clk_usb;
always #(pCLK_ADC_PERIOD/2) clk_adc = !clk_adc;

wire #1 usb_rdn_out = usb_rdn;
wire #1 usb_wrn_out = usb_wrn;
wire #1 usb_cen_out = usb_cen;
wire #1 usb_alen_out = usb_alen;
wire [7:0] #1 usb_addr_out = usb_addr;

reg read_select;

assign usb_data = read_select? 8'bz : usb_wdata;

always @(*) begin
   if (usb_wrn == 1'b0)
      read_select = 1'b0;
   else if (usb_rdn == 1'b0)
      read_select = 1'b1;
end

edge_wrapper #(
    .pBYTECNT_SIZE      (7)
) U_dut (
    .reset              (reset),
    .clk_usb            (clk_usb),
    .clk_adc            (clk_adc),
    .trigger_in         (trigger_in_out),
    .armed_and_ready    (armed_and_ready_out),
    .USB_Data           (usb_data     ),
    .USB_Addr           (usb_addr_out ),
    .USB_RDn            (usb_rdn_out  ),
    .USB_WRn            (usb_wrn_out  ),
    .USB_CEn            (usb_cen_out  ),
    .USB_ALEn           (usb_alen_out ),
    .trigger            (trigger)
);

endmodule
`default_nettype wire

