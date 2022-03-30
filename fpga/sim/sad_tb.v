`timescale 1 ns / 1 ps
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

module sad_tb();
parameter pCLK_USB_PERIOD = 10;
parameter pCLK_ADC_PERIOD = 6;
parameter pSEED = 1;
parameter pDUMP = 0;
parameter pLINEAR_RAMP = 0;
parameter pREF_SAMPLES = 8;
parameter pBITS_PER_SAMPLE = 12;
parameter pTHRESHOLD = 0;
parameter pADDR_WIDTH = 8;
parameter pTIMEOUT_CYCLES = 5000;
parameter pSLOP = 2;
parameter pTHRESHOLD_MARGIN = 20;
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
reg arm;
wire trigger;
reg [11:0] adc_datain;

reg setup_done;
reg [7:0] rdata;

wire [7:0] usb_data;
reg  [7:0] usb_wdata;
reg  [7:0] usb_addr;
reg        usb_rdn;
reg        usb_wrn;
reg        usb_cen;
reg        usb_alen;

reg [pBITS_PER_SAMPLE-1:0] pattern [0:pREF_SAMPLES-1];
reg [pBITS_PER_SAMPLE-4:0] linear_increment;
reg [31:0] threshold;

integer errors;
integer warnings;
integer i;
integer seed;
integer delta;
integer abs_delta;
integer total_delta;
reg done_altering;
reg trigger_expected;
reg expect_fail;
integer unexpected;

wire usb_clk = clk_usb;
`include "tb_reg_tasks.v"

// initialization thread:
initial begin
    seed = pSEED;
    $display("Running with seed=%0d", seed);
    rdata = $urandom(seed);

    $display("pLINEAR_RAMP      = %d", pLINEAR_RAMP);    
    $display("pREF_SAMPLES      = %d", pREF_SAMPLES);   
    $display("pBITS_PER_SAMPLE  = %d", pBITS_PER_SAMPLE);
    $display("pTHRESHOLD        = %d", pTHRESHOLD);
    $display("pVERBOSE          = %d", pVERBOSE);
    
    if (pDUMP) begin
       $dumpfile("results/sad_tb.fst");
       $dumpvars(0, sad_tb);
    end
    setup_done = 0;
    errors = 0;
    warnings = 0;
    clk_usb = 1'b0;
    clk_adc = 1'b0;
    reset = 1'b0;
    arm = 1'b0;
    usb_addr = 0;
    usb_rdn = 1;
    usb_wrn = 1;
    usb_cen = 1;
    usb_alen = 1;

    // generate pattern:
    if (pLINEAR_RAMP) begin
        // randomly pick starting value, increment:
        pattern[0] = $urandom_range(0, 2**pBITS_PER_SAMPLE-1);
        linear_increment = $urandom_range(1, 2**pBITS_PER_SAMPLE-4);
        for (i = 1; i < pREF_SAMPLES; i = i + 1) begin
            pattern[i] = pattern[i-1] + linear_increment;
        end
    end
    else begin
        for (i = 0; i < pREF_SAMPLES; i = i + 1) begin
            pattern[i] = $urandom_range(0, 2**pBITS_PER_SAMPLE-1);
        end
    end
    if (pTHRESHOLD == 0)
        threshold = $urandom_range(1, 500);
    else
        threshold = pTHRESHOLD;

    #(pCLK_USB_PERIOD*10) reset = 1'b1;
    #(pCLK_USB_PERIOD*10) reset = 1'b0;
    #(pCLK_USB_PERIOD*10);

    //write_1byte(`ECHO_ADDR, 155);
    //read_1byte(`ECHO_ADDR, rdata);
    //$display("Read %d", rdata);

    // TODO: assuming 8-bit width for now (12 is cumbersome!)
    rw_lots_bytes(`SAD_REFERENCE);
    for (i = 0; i < pREF_SAMPLES; i = i + 1) begin
        write_next_byte(pattern[i]);
    end

    rw_lots_bytes(`SAD_THRESHOLD);
    write_next_byte((threshold & 32'h0000_00FF));
    write_next_byte((threshold & 32'h0000_FF00)>>8);
    write_next_byte((threshold & 32'h00FF_0000)>>16);
    write_next_byte((threshold & 32'hFF00_0000)>>24);

    #(pCLK_USB_PERIOD*10) setup_done = 1;
end

// apply data thread:
initial begin
    total_delta = 0;
    trigger_expected = 0;
    expect_fail = 0;
    #1;
    while (arm == 1'b0)
        @(posedge clk_adc) adc_datain = $urandom_range(0, 2**pBITS_PER_SAMPLE-1);
    repeat($urandom_range(1,4*pREF_SAMPLES))
        @(posedge clk_adc) adc_datain = $urandom_range(0, 2**pBITS_PER_SAMPLE-1);

    // apply a pattern that's close, but (probably) over the threshold:
    for (i = 0; i < pREF_SAMPLES; i = i + 1) begin
        @(posedge clk_adc);
        if ($urandom_range(0, pREF_SAMPLES/8) == 0) begin // deviate from pattern or not
            if ($urandom_range(0,1)) begin // positive delta
                delta = $urandom_range(0, 2**pBITS_PER_SAMPLE-1 - pattern[i]);
                total_delta += delta;
            end

            else begin // negative delta
                delta = -$urandom_range(0, pattern[i]);
                total_delta -= delta;
                //$display("NEGATIVE!");
            end
        end
        else
            delta = 0;
        adc_datain = pattern[i] + delta;
    end
    if (total_delta <= threshold + pTHRESHOLD_MARGIN) begin
        delta = (threshold - total_delta + pTHRESHOLD_MARGIN);
        if (adc_datain + delta >= 2**pBITS_PER_SAMPLE) begin
            $display("WARNING!: didn't exceed threshold! Will expect simulation to fail. Time=%t", $time);
            expect_fail = 1;
            warnings += 1;
        end
        else begin
            total_delta += delta;
            adc_datain += delta;
            if (pVERBOSE)
                $display("extra delta = %d", delta);
        end
    end


    if (pVERBOSE) begin
        $display("Total delta: %d", total_delta);
        $display("Threshold:   %d", threshold);
    end
    // more random stuff to make sure we don't get a trigger from the end of the last modified pattern + start
    // of the next less-modified pattern:
    repeat(2+$urandom_range(4,10*pREF_SAMPLES))
        @(posedge clk_adc) adc_datain = $urandom_range(0, 2**pBITS_PER_SAMPLE-1);

    // now apply a pattern that's definitely under the threshold:
    done_altering = 0;
    total_delta = 0;
    for (i = 0; i < pREF_SAMPLES; i = i + 1) begin
        @(posedge clk_adc);
        if ((done_altering == 0) && ($urandom_range(0, pREF_SAMPLES/2) == 0)) begin // deviate from pattern or not
            if (pVERBOSE)
                $display("Deviating for sample %d", i);
            abs_delta = threshold;
            while (total_delta + abs_delta >= threshold) begin
                if ($urandom_range(0,1)) begin // positive delta
                    delta = $urandom_range(0, 2**pBITS_PER_SAMPLE-1 - pattern[i]);
                    abs_delta = delta;
                end
                else begin // negative delta
                    delta = -$urandom_range(0, pattern[i]);
                    abs_delta = -delta;
                end
                //$display("Trying delta=%d...", delta);
            end
            total_delta = total_delta + abs_delta;
            if (total_delta*2 > threshold)
                done_altering = 1;
        end
        else
            delta = 0;
        //if (delta < 0)
        //    $display("NEGATIVE!");
        adc_datain = pattern[i] + delta;
    end
    repeat (5) @(posedge clk_adc);
    trigger_expected = 1'b1;
    if (pVERBOSE) begin
        $display("Total delta: %d", total_delta);
        $display("Threshold:   %d", threshold);
    end
end

// trigger check thread:
initial begin
    wait (setup_done);
    @(posedge clk_usb) arm = 1'b1;
    //@(posedge clk_usb) arm = 1'b0;
    wait (trigger);
    while (~trigger_expected) begin
        if (trigger && !expect_fail) begin
            $display("Warning: unexpected trigger at time %t", $time);
            unexpected = $time;
            wait (trigger_expected);
            delta = ($time-unexpected)/pCLK_ADC_PERIOD;
            $display("Trigger was expected %d cycles later", delta);
            if (delta <= pSLOP)
                warnings += 1;
            else begin
                $display("ERROR: trigger delta exceeds margin");
                errors += 1;
            end
        end
    end

    if (~trigger && ~expect_fail) begin
        $display("Warning: not getting expected trigger at time %t", $time);
        unexpected = $time;
        wait (trigger);
        delta = ($time-unexpected)/pCLK_ADC_PERIOD;
        $display("Trigger received %d cycles later", delta);
        if (delta <= pSLOP)
            warnings += 1;
        else begin
            $display("ERROR: trigger delta exceeds margin");
            errors += 1;
        end
    end

    else if (pVERBOSE)
        $display("Got trigger at time %t.", $time);
    repeat(pREF_SAMPLES*2) #(pCLK_ADC_PERIOD);

    read_1byte(`SAD_STATUS, rdata);
    if (rdata == 8'd1)
        $display("SAD_STATUS ok.");
    else begin
        if (~rdata[0]) begin
            errors += 1;
            $display("ERROR: SAD_STATUS shows that no trigger occured!");
        end
        if (rdata[1]) begin
            errors += 1;
            $display("ERROR: SAD_STATUS shows that FIFO underflow occured!");
        end
        if (rdata[2]) begin
            errors += 1;
            $display("ERROR: SAD_STATUS shows that FIFO overflow occured!");
        end
        if (rdata[3]) begin
            errors += 1;
            $display("ERROR: SAD_STATUS shows that FIFO is not empty when it should be!");
        end
    end

    if (errors)
       $display("SIMULATION FAILED (%0d errors)", errors);
    else
       $display("Simulation passed (%0d warnings)", warnings);
    $finish;
end

// quicker exit if testbench screwed up:
initial begin
    wait (setup_done);
    wait (expect_fail);
    $display("Aborting due to expected failure!");
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
wire [11:0] #1 adc_datain_out = adc_datain;

reg read_select;

assign usb_data = read_select? 8'bz : usb_wdata;

always @(*) begin
   if (usb_wrn == 1'b0)
      read_select = 1'b0;
   else if (usb_rdn == 1'b0)
      read_select = 1'b1;
end


sad_wrapper #(
    .pBYTECNT_SIZE      (7),
    .pREF_SAMPLES       (pREF_SAMPLES),
    .pBITS_PER_SAMPLE   (pBITS_PER_SAMPLE)
) U_dut (
    .reset              (reset),
    .clk_usb            (clk_usb),
    .clk_adc            (clk_adc),
    .adc_datain         (adc_datain_out),
    .arm_i              (arm),
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

