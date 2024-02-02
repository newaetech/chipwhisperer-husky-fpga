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
parameter pINPUTS_FROM_FILE = 0;
parameter pREF_SAMPLES = 8;
parameter pBITS_PER_SAMPLE = 12;
parameter pTHRESHOLD = 0;
parameter pADDR_WIDTH = 8;
parameter pTIMEOUT_CYCLES = 5000;
parameter pSLOP = 2;
parameter pTHRESHOLD_MARGIN = 20;
parameter pVERBOSE = 0;
parameter pTRIGGERS = 2;
parameter pFLUSH = 0;

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
wire trigger;
reg [11:0] adc_datain;

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

reg [pBITS_PER_SAMPLE-1:0] adcin [0:128];
reg [pBITS_PER_SAMPLE-1:0] pattern [0:pREF_SAMPLES-1];
reg [pREF_SAMPLES-1:0] refen;
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
reg trigger_expected_delayed;
reg expect_fail;
integer unexpected;
integer itrig;
wire [3:0] trigger_cycles;

`ifdef SAD_X2
    integer sad_x2 = 1;
    integer sad_x4 = 0;
    assign trigger_cycles = 2;
`else
    integer sad_x2 = 0;
    `ifdef SAD_X4
        integer sad_x4 = 1;
        assign trigger_cycles = 4;
    `else
        integer sad_x4 = 0;
        assign trigger_cycles = 1;
    `endif
`endif


wire usb_clk = clk_usb;
`include "tb_reg_tasks.v"

integer pattern_samples = pREF_SAMPLES;

// initialization thread:
initial begin
    seed = pSEED;
    $display("Running with seed=%0d", seed);
    rdata = $urandom(seed);

    $display("SAD_X2            = %d", sad_x2);
    $display("SAD_X4            = %d", sad_x4);
    $display("pTRIGGERS         = %d", pTRIGGERS);
    $display("pFLUSH            = %d", pFLUSH);
    $display("pLINEAR_RAMP      = %d", pLINEAR_RAMP);    
    $display("pINPUTS_FROM_FILE = %d", pINPUTS_FROM_FILE);    
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
    armed_and_ready = 1'b0;
    usb_addr = 0;
    usb_rdn = 1;
    usb_wrn = 1;
    usb_cen = 1;
    usb_alen = 1;

    // generate pattern:
    if (pINPUTS_FROM_FILE) begin
        $readmemh("pattern.memh", pattern);
        $readmemh("adcin.memh", adcin);
    end
    else if (pLINEAR_RAMP) begin
        // randomly pick starting value, increment:
        pattern[0] = $urandom_range(0, 2**pBITS_PER_SAMPLE-1);
        linear_increment = $urandom_range(1, 2**pBITS_PER_SAMPLE-4);
        for (i = 1; i < pattern_samples; i = i + 1) begin
            pattern[i] = pattern[i-1] + linear_increment;
        end
    end
    else begin
        for (i = 0; i < pattern_samples; i = i + 1) begin
            pattern[i] = $urandom_range(0, 2**pBITS_PER_SAMPLE-1);
        end
    end
    if (pTHRESHOLD == 0)
        threshold = $urandom_range(1, 500);
    else
        threshold = pTHRESHOLD;

    for (i = 0; i < pattern_samples; i = i + 1) begin
        // turn off comparison for a quarter of the samples
        if ($urandom_range(0, 4))
            refen[i] = 1;
        else
            refen[i] = 0;
    end

    #(pCLK_USB_PERIOD*10) reset = 1'b1;
    #(pCLK_USB_PERIOD*10) reset = 1'b0;
    #(pCLK_USB_PERIOD*10);

    //write_1byte(`ECHO_ADDR, 155);
    //read_1byte(`ECHO_ADDR, rdata);
    //$display("Read %d", rdata);

    // TODO: assuming 8-bit width for now (12 is cumbersome!)
    rw_lots_bytes(`SAD_REFERENCE);
    for (i = 0; i < pattern_samples; i = i + 1) begin
        write_next_byte(pattern[i]);
        //$display("Reference byte %d: %x", i, pattern[i]);
    end

    // TODO: assuming 8-bit width for now
    rw_lots_bytes(`SAD_REFEN);
    for (i = 0; i < pattern_samples/8; i = i + 1)
        write_next_byte(refen[i*8 +: 8]);


    rw_lots_bytes(`SAD_THRESHOLD);
    write_next_byte((threshold & 32'h0000_00FF));
    write_next_byte((threshold & 32'h0000_FF00)>>8);
    write_next_byte((threshold & 32'h00FF_0000)>>16);
    write_next_byte((threshold & 32'hFF00_0000)>>24);

    if (pFLUSH)
        write_1byte(`SAD_MULTIPLE_TRIGGERS, 0);
    else
        write_1byte(`SAD_MULTIPLE_TRIGGERS, 1);

    #(pCLK_USB_PERIOD*10) setup_done = 1;
end

// apply data thread:
initial begin
    total_delta = 0;
    trigger_expected = 0;
    expect_fail = 0;
    #1;
    while (armed_and_ready == 1'b0)
        @(posedge clk_adc) adc_datain = $urandom_range(0, 2**pBITS_PER_SAMPLE-1);
    repeat($urandom_range(1,4*pattern_samples))
        @(posedge clk_adc) adc_datain = $urandom_range(0, 2**pBITS_PER_SAMPLE-1);

    if (pINPUTS_FROM_FILE == 0) begin
    // apply a pattern that's close, but (probably) over the threshold:
    for (i = 0; i < pattern_samples; i = i + 1) begin
        @(posedge clk_adc);
        if (refen[i] && ($urandom_range(0, pattern_samples/8) == 0)) begin // deviate from pattern or not
            if ($urandom_range(0,1)) begin // positive delta
                delta = $urandom_range(0, 2**pBITS_PER_SAMPLE-1 - pattern[i]);
                total_delta += delta;
            end

            else begin // negative delta
                delta = -$urandom_range(0, pattern[i]);
                total_delta -= delta;
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
    repeat(2+$urandom_range(32,10*pattern_samples))
        @(posedge clk_adc) adc_datain = $urandom_range(0, 2**pBITS_PER_SAMPLE-1);

    // now apply a pattern that's definitely under the threshold:
    repeat (pTRIGGERS) begin // do it more than once to make sure we recover after the first
        done_altering = 0;
        total_delta = 0;
        for (i = 0; i < pattern_samples; i = i + 1) begin
            @(posedge clk_adc);
            if ((done_altering == 0) && ($urandom_range(0, pattern_samples/2) == 0)) begin // deviate from pattern or not
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
                end
                total_delta = total_delta + abs_delta;
                if (total_delta*2 > threshold)
                    done_altering = 1;
            end
            else
                delta = 0;
            if (refen[i])
                adc_datain = pattern[i] + delta;
            else
                // when comparison is disabled for a particular sample, throw random data at it:
                adc_datain = $urandom_range(0, 2**pBITS_PER_SAMPLE-1);
                //adc_datain = {pBITS_PER_SAMPLE{1'b1}};
        end
        @(posedge clk_adc)
        #1 trigger_expected = 1'b1;
        adc_datain = $urandom_range(0, 2**pBITS_PER_SAMPLE-1);
        repeat(trigger_cycles)
            @(posedge clk_adc) adc_datain = $urandom_range(0, 2**pBITS_PER_SAMPLE-1);
        #1 trigger_expected = 1'b0;
        if (pVERBOSE) begin
            $display("Total delta: %d", total_delta);
            $display("Threshold:   %d", threshold);
        end
        repeat($urandom_range(3*pattern_samples, 5*pattern_samples))
            @(posedge clk_adc) adc_datain = $urandom_range(0, 2**pBITS_PER_SAMPLE-1);
    end

    end

    else begin // pINPUTS_FROM_FILE case
        done_altering = 0;
        total_delta = 0;
        for (i = 0; i < 129; i = i + 1) begin
            @(posedge clk_adc);
            adc_datain = adcin[i];
        end
        trigger_expected = 1'b1;
        repeat($urandom_range(8,4*pattern_samples))
            @(posedge clk_adc) adc_datain = $urandom_range(0, 2**pBITS_PER_SAMPLE-1);
        trigger_expected = 1'b0;
    end


end

reg [13:0] trigger_expected_pipe;
always @(posedge clk_adc)
    trigger_expected_pipe <= {trigger_expected_pipe[12:0], trigger_expected};
`ifdef SAD_X2
    assign trigger_expected_delayed = trigger_expected_pipe[7];
`else
    `ifdef SAD_X4
        assign trigger_expected_delayed = trigger_expected_pipe[13];
    `else
        assign trigger_expected_delayed = trigger_expected_pipe[5];
    `endif
`endif

// trigger check thread:
initial begin
    wait (setup_done);
    @(posedge clk_usb) armed_and_ready = 1'b1;
    for (itrig = 0; itrig < pTRIGGERS; itrig += 1) begin
        if (pFLUSH) begin
            repeat(pattern_samples) @(posedge clk_adc);
            armed_and_ready = 1'b0;
            repeat(pattern_samples) @(posedge clk_adc);
            armed_and_ready = 1'b1;
        end

        wait (trigger || trigger_expected_delayed);
        #1;
        if (trigger && trigger_expected_delayed) begin
            if (pVERBOSE)
                $display("Got trigger %0d at time %t.", itrig, $time);
        end
        else begin
            unexpected = $time;
            errors += 1;
            if (trigger) begin // got trigger when it wasn't expected
                wait (trigger_expected_delayed);
                delta = ($time-unexpected+1)/pCLK_ADC_PERIOD;
                $display("ERROR: got trigger #%0d %d cycles early at time %t", itrig, delta, $time);
            end
            else begin // expected trigger but it's not there
                wait (trigger);
                delta = ($time-unexpected+1)/pCLK_ADC_PERIOD;
                $display("ERROR: got trigger #%0d %d cycles late at time %t", itrig, delta, $time);
            end
        end

        #(pCLK_ADC_PERIOD*2);
        wait (~(trigger || trigger_expected_delayed));
    end

    repeat(pattern_samples*2) #(pCLK_ADC_PERIOD);

    rw_lots_bytes(`SAD_STATUS);
    read_next_byte(rdata);
    if (rdata != 8'd1) begin
        $display("ERROR: SAD_STATUS.triggered is not set.");
        errors += 1;
    end
    read_next_byte(rdata);
    if (rdata != ((pFLUSH)? 1 : pTRIGGERS)) begin
        $display("ERROR: incorrect number of triggers reported (%d).", rdata);
        errors += 1;
    end

    if (errors)
       $display("SIMULATION FAILED (%0d errors)", errors);
    else
       $display("Simulation passed (%0d warnings)", warnings);
    $finish;
end

always @(trigger_expected_delayed)
    if (trigger_expected_delayed != trigger) begin
        errors += 1;
        $display("ERROR: trigger/expected mismatch at time %t", $time);
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
//wire [11:0] #1 adc_datain_out = adc_datain_ramp; // TEMP: easier debugging!

reg [11:0] adc_datain_ramp = 0;
always @(posedge clk_adc)
    adc_datain_ramp <= adc_datain_ramp + 1;


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
    .armed_and_ready    (armed_and_ready),
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

