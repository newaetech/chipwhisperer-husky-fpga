`timescale 1 ns / 1 ps
`default_nettype none
`include "includes.v"
`include "defines_trace.v"
`include "defines_pw.v"

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

module cwhusky_tb();
   parameter pCLK_USB_PERIOD = 10;
   parameter pCLK_ADC_FAST_PERIOD = 5.5;
   //parameter pCLK_ADC_SLOW_PERIOD = 16.0;
   parameter pCLK_ADC_SLOW_PERIOD = 31.0;
   parameter pCLK_ADC_NOM_PERIOD = 11.0;
   parameter pADDR_WIDTH = 8;
   parameter pADC_LOW_RES = 1;
   parameter pSLOW_ADC = 0;
   parameter pFAST_ADC = 0;
   parameter pNOM_ADC = 0;
   parameter pFIFO_SAMPLES = 90;
   parameter pPRESAMPLES = 0;
   parameter pOFFSET_ENABLE = 0;
   parameter pOFFSET_MIN = 0;
   parameter pOFFSET_MAX = 0;
   parameter pSHORT_TRIGGER = 0;
   parameter pTRIGGER_DELAY = 0;
   parameter pTRIGGER_NOW = 0;
   parameter pREAD_DELAY = 0;
   parameter pNUM_SEGMENTS = 0;
   parameter pNUM_GLITCHES = 1;
   parameter pMAX_GLITCH_OFFSET= 0;
   parameter pMAX_GLITCH_REPEATS= 0;
   parameter pSEGMENT_CYCLES = 1;
   parameter pSEGMENT_CYCLE_COUNTER_EN = 0;
   parameter pSTREAM = 0;
   parameter pSTREAM_SEGMENT_THRESHOLD = 0;
   parameter pSLOP = 6;
   parameter pTRIGGER_ADJUST = pTRIGGER_NOW? 2 : 0;
   parameter pSEED = 1;
   parameter pTIMEOUT_CYCLES = 50000;
   parameter pDUMP = 0;
   parameter pSLOW_READS = 0;
   parameter pERRORS_OK = 0;
   parameter pPRESAMP_ERROR = 0;
   parameter pDOWNSAMPLE = 0;
   parameter pDDR_TEST = 0;
   parameter pBYPASS_DDR = 0;
   parameter pDDR_TEST_LOOPS = 1;

   `include "tb_reg_tasks.v"

   reg                  clk_usb;
   reg                  clk_adc_slow;
   reg                  clk_adc_fast;
   reg                  clk_adc_nom;
   wire                 clk_adc;
   wire [2:0]           adc_clocks;
   reg  [1:0]           chosen_clock;
   wire [7:0]           usb_data;
   reg  [7:0]           usb_wdata;
   reg  [7:0]           usb_addr;
   reg  [7:0]           usb_bytecount;
   reg                  usb_rdn;
   reg                  usb_wrn;
   reg                  usb_cen;
   reg                  usb_alen;
   wire                 stream_segment_available;

   wire                 FPGA_BONUS1;
   wire                 FPGA_BONUS2;
   wire                 FPGA_BONUS3;
   wire                 FPGA_BONUS4;
   wire                 SAM_MOSI;
   wire                 SAM_MISO;
   wire                 SAM_SPCK;
   wire                 SAM_CS;
   wire                 target_PDID;
   wire                 target_PDIC;
   wire                 target_nRST;
   wire                 target_MISO;
   wire                 target_MOSI;
   wire                 target_SCK;
   wire                 target_io4;
   wire                 target_io3;
   wire                 target_io2;
   wire                 target_io1;
   wire                 target_hs1;
   wire                 target_hs2;
   wire                 TRIG_GLITCHOUT;
   wire                 AUXIO;
   wire                 LED_ADC;
   wire                 LED_GLITCH;
   wire                 LED_ARMED;
   wire                 LED_CAP;

   reg  [7:0] rdata;
   reg  [7:0] rdata_r;
   reg  [7:0] ddr_loops;
   reg  [11:0] sample;
   reg  [11:0] last_sample;
   reg  [11:0] expected;
   reg  [11:0] trigger_counter_value[0:15];
   wire [11:0] trigger_counter_value0 = trigger_counter_value[0];
   wire [11:0] trigger_counter_value1 = trigger_counter_value[1];
   wire [11:0] trigger_counter_value2 = trigger_counter_value[2];
   int comp_min;
   int comp_max;
   int signed_sample;
   reg  setup_done;
   reg  trigger_done;
   reg  trigger_event;
   reg  trigger2_done;
   reg  target_io4_reg;
   int i, j, k;
   reg i12BitReadCount;
   int trigger_gen_index;
   int segment_read_index;
   int good_reads, bad_reads, errors, warnings;
   reg fifo_error;
   reg ddr_read_started;
   int seed;

   real prFIFO_SAMPLES;
   int fifo_samples;
   int FIFO_SAMPLES_MUL6;
   int samples_to_read;
   int offset;
   int trigger_cycles;
   reg [12:0] reps;
   reg [13*31-1:0] remaining_reps = 0;      // allow for up to 32 glitches
   reg [31:0] ext_offset;
   reg glitches_done;

   int all_reps[0:31];
   int all_offs[0:31];

   // initialization thread:
   initial begin
      seed = pSEED;
      $display("Running with seed=%0d", seed);
      rdata = $urandom(seed);

      if (pOFFSET_ENABLE)
          offset = $urandom_range(pOFFSET_MIN, pOFFSET_MAX);
      else
          offset = 0;

      $display("pPRESAMPLES = %d", pPRESAMPLES);
      $display("pFIFO_SAMPLES = %d", pFIFO_SAMPLES);
      $display("OFFSET_ENABLE = %d", pOFFSET_ENABLE);
      $display("OFFSET = %d", offset);
      $display("SHORT_TRIGGER = %d", pSHORT_TRIGGER);
      $display("pDOWNSAMPLE = %d", pDOWNSAMPLE);
      if ((pNUM_SEGMENTS > 1) && (pPRESAMPLES > 0) && (pFIFO_SAMPLES %3)) begin
         fifo_samples = pFIFO_SAMPLES - (pFIFO_SAMPLES%3);
         $display("Info: when using segments with presamples, the number of samples per segment must be a multiple of 3; adjusting from %0d to %0d", pFIFO_SAMPLES, fifo_samples);
      end
      else
         fifo_samples = pFIFO_SAMPLES;
      prFIFO_SAMPLES = fifo_samples;
      $display("pADC_LOW_RES = %d", pADC_LOW_RES);
      $display("pTRIGGER_NOW = %d", pTRIGGER_NOW);
      $display("pREAD_DELAY = %d", pREAD_DELAY);
      $display("pNUM_SEGMENTS = %d", pNUM_SEGMENTS);
      $display("pSEGMENT_CYCLES = %d", pSEGMENT_CYCLES);
      $display("pSEGMENT_CYCLE_COUNTER_EN = %d", pSEGMENT_CYCLE_COUNTER_EN);
      $display("pBYPASS_DDR = %d", pBYPASS_DDR);
      if ((pSLOW_ADC == 0) && (pFAST_ADC == 0) && (pNOM_ADC == 0)) begin
         chosen_clock = $urandom_range(0, 2);
         case (chosen_clock)
            0: $display("Chose slow ADC clock.");
            1: $display("Chose fast ADC clock.");
            2: $display("Chose nominal ADC clock.");
         endcase
      end
      if (pDUMP) begin
         $dumpfile("results/cwhusky_tb.fst");
         $dumpvars(0, cwhusky_tb);
      end
      setup_done = 0;
      errors = 0;
      fifo_error = 0;
      warnings = 0;
      clk_usb = 0;
      clk_adc_slow = 0;
      clk_adc_fast = 0;
      clk_adc_nom = 0;
      usb_addr = 0;
      usb_rdn = 1;
      usb_wrn = 1;
      usb_cen = 1;
      usb_alen = 1;
      target_io4_reg = 0;

      #(pCLK_USB_PERIOD*100);

      // manually reset with new register:
      write_1byte(`RESET, 8'h1);
      #(pCLK_USB_PERIOD*20);
      write_1byte(`RESET, 8'h0);

      #(pCLK_USB_PERIOD*1000);

      if (pBYPASS_DDR)
         write_1byte(`FIFO_CONFIG, 8'h0); // this also clears the bit which controls the use of ramp pattern
      else
         write_1byte(`FIFO_CONFIG, 8'h1); // (as above)
      if (pADC_LOW_RES)
         write_1byte(`ADC_LOW_RES, 3);
      else
         write_1byte(`ADC_LOW_RES, 0);

      write_1byte(`NO_CLIP_ERRORS, 8'h3);

      // program number of samples:
      rw_lots_bytes(`PRESAMPLES_ADDR);
      write_next_byte((pPRESAMPLES & 32'h0000_00FF));
      write_next_byte((pPRESAMPLES & 32'h0000_FF00)>>8);
      write_next_byte((pPRESAMPLES & 32'h00FF_0000)>>16);
      write_next_byte((pPRESAMPLES & 32'hFF00_0000)>>24);

      rw_lots_bytes(`SAMPLES_ADDR);
      write_next_byte((fifo_samples & 32'h0000_00FF));
      write_next_byte((fifo_samples & 32'h0000_FF00)>>8);
      write_next_byte((fifo_samples & 32'h00FF_0000)>>16);
      write_next_byte((fifo_samples & 32'hFF00_0000)>>24);

      rw_lots_bytes(`OFFSET_ADDR);
      write_next_byte((offset & 32'h0000_00FF));
      write_next_byte((offset & 32'h0000_FF00)>>8);
      write_next_byte((offset & 32'h00FF_0000)>>16);
      write_next_byte((offset & 32'hFF00_0000)>>24);

      rw_lots_bytes(`DECIMATE_ADDR);
      write_next_byte((pDOWNSAMPLE & 16'h00FF));
      write_next_byte((pDOWNSAMPLE & 16'hFF00)>>8);

      // number of segments - 1 (0 = 1 segment, 1 = 2 segments,...)
      write_1byte(`NUM_SEGMENTS, pNUM_SEGMENTS);
      if (pSEGMENT_CYCLE_COUNTER_EN) begin
         // number of cycles between segments:
         rw_lots_bytes(`SEGMENT_CYCLES);
         write_next_byte((pSEGMENT_CYCLES & 32'h0000_00FF));
         write_next_byte((pSEGMENT_CYCLES & 32'h0000_FF00)>>8);
         write_next_byte((pSEGMENT_CYCLES & 32'h00FF_0000)>>16);
         write_1byte(`SEGMENT_CYCLE_COUNTER_EN, 8'h1);
      end

      if (pSTREAM) begin
         rw_lots_bytes(`STREAM_SEGMENT_THRESHOLD);
         write_next_byte((pSTREAM_SEGMENT_THRESHOLD & 32'h0000_00FF));
         write_next_byte((pSTREAM_SEGMENT_THRESHOLD & 32'h0000_FF00)>>8);
         write_next_byte((pSTREAM_SEGMENT_THRESHOLD & 32'h00FF_0000)>>16);
         write_next_byte((pSTREAM_SEGMENT_THRESHOLD & 32'hFF00_0000)>>24);
      end

      // yes this is also done in the trigger thread, this seems redundant but it's necessary:
      write_1byte(`SETTINGS_ADDR, 8'hc); // arm, trigger level = high

      // random delay before trigger:
      //#($urandom_range(0, 100)*pCLK_USB_PERIOD);

      // setup glitches:
      if (pNUM_GLITCHES) begin
          $display("pNUM_GLITCHES = %d", pNUM_GLITCHES);
          $display("pMAX_GLITCH_REPEATS = %d", pMAX_GLITCH_REPEATS);
          $display("pMAX_GLITCH_OFFSET = %d", pMAX_GLITCH_OFFSET);
          // choose the first reps:
          reps = $urandom_range(0, pMAX_GLITCH_REPEATS);
          all_reps[0] = reps;

          // first set clock source, otherwise other settings won't take (like the manual bit):
          rw_lots_bytes(`CLOCKGLITCH_SETTINGS);
          write_next_byte(8'h00); // byte 0
          write_next_byte(8'h00); // byte 1
          write_next_byte(8'h00); // byte 2
          write_next_byte(8'h00); // byte 3
          write_next_byte(8'h00); // byte 4
          write_next_byte(8'h00); // byte 5
          write_next_byte(8'h00); // byte 6
          write_next_byte(8'h01); // byte 7 source=clkgen

          // simulation artifact: prevent glitch output being X
          force U_dut.reg_clockglitch.U_clockglitch.glitch_go = 1'b0;
          #10 release U_dut.reg_clockglitch.U_clockglitch.glitch_go;

          // setup ext_single glitch, type=enable only
          //
          rw_lots_bytes(`CLOCKGLITCH_SETTINGS);
          write_next_byte(8'h00); // byte 0
          write_next_byte(8'h00); // byte 1
          write_next_byte(8'h00); // byte 2
          write_next_byte(8'h00); // byte 3
          write_next_byte(8'h00); // byte 4
          write_next_byte(8'hcc); // byte 5: ext_single, enable only, manual go (manual is required for ext_single)
          write_next_byte(reps[7:0]); // byte 6: LSB of reps
          write_next_byte({1'b0, reps[12:8], 2'b01}); // byte 7: MSB of reps, source=clkgen
          //

          // first ext_offset can be anything:
          rw_lots_bytes(`CLOCKGLITCH_OFFSET);
          ext_offset = $urandom_range(0, pMAX_GLITCH_OFFSET);
          all_offs[0] = ext_offset;
          $display("\tglitch  0: offset = %4d, rep = %4d", ext_offset, reps);
          for (j = 0; j < 4; j = j + 1)
              write_next_byte(ext_offset[j*8 +: 8]); // byte 0
          // set up remaining reps; at the same time, randomize the
          // ext_offsets and ensure we have legal combinations:
          for (i = 1; i < pNUM_GLITCHES; i = i + 1) begin
              if (pMAX_GLITCH_OFFSET < reps) begin
                  $display("CONFIGURATION ERROR: can't randomize ext_offset legally");
                  errors += 1;
              end
              ext_offset = $urandom_range(reps, pMAX_GLITCH_OFFSET);
              reps = $urandom_range(0, pMAX_GLITCH_REPEATS);
              all_offs[i] = ext_offset;
              all_reps[i] = reps;
              remaining_reps[(i-1)*13 +: 13] = reps;
              $display("\tglitch %2d: offset = %4d, rep = %4d", i, ext_offset, reps);
              for (j = 0; j < 4; j = j + 1)
                  write_next_byte(ext_offset[j*8 +: 8]); // byte 0
          end
          rw_lots_bytes(`CLOCKGLITCH_REPEATS);
          // up to 31 glitches; program all reps for simplicity, so that's 31*13/8 = 51 bytes:
          for (i = 0; i < 51; i = i + 1)
              write_next_byte(remaining_reps[i*8 +: 8]);

          // set number of glitches:
          write_1byte(`CLOCKGLITCH_NUM_GLITCHES, pNUM_GLITCHES-1);

          // enable glitching
          write_1byte(`CLOCKGLITCH_POWERDOWN, 8'h00);

          /* to debug manual glitch:
          rw_lots_bytes(`CLOCKGLITCH_SETTINGS);
          write_next_byte(8'h00); // byte 0
          write_next_byte(8'h00); // byte 1
          write_next_byte(8'h00); // byte 2
          write_next_byte(8'h00); // byte 3
          write_next_byte(8'h00); // byte 4
          write_next_byte(8'h80); // byte 5: manual go
          //write_next_byte(8'h01); // byte 6: reps=1
          //write_next_byte(8'h01); // byte 7: source=clkgen
          write_next_byte(all_reps[0][7:0]); // byte 6: LSB of reps
          write_next_byte({1'b0, all_reps[0][12:8], 2'b01}); // byte 7: MSB of reps, source=clkgen
          rw_lots_bytes(`CLOCKGLITCH_SETTINGS);
          write_next_byte(8'h00); // byte 0
          write_next_byte(8'h00); // byte 1
          write_next_byte(8'h00); // byte 2
          write_next_byte(8'h00); // byte 3
          write_next_byte(8'h00); // byte 4
          write_next_byte(8'h00); // byte 5: manual go done
          //write_next_byte(8'h01); // byte 6: reps=1
          //write_next_byte(8'h01); // byte 7: source=clkgen
          write_next_byte(all_reps[0][7:0]); // byte 6: LSB of reps
          write_next_byte({1'b0, all_reps[0][12:8], 2'b01}); // byte 7: MSB of reps, source=clkgen
          #(pCLK_USB_PERIOD*100);
          rw_lots_bytes(`CLOCKGLITCH_SETTINGS);
          write_next_byte(8'h00); // byte 0
          write_next_byte(8'h00); // byte 1
          write_next_byte(8'h00); // byte 2
          write_next_byte(8'h00); // byte 3
          write_next_byte(8'h00); // byte 4
          write_next_byte(8'h80); // byte 5: manual go
          //write_next_byte(8'h01); // byte 6: reps=1
          //write_next_byte(8'h01); // byte 7: source=clkgen
          write_next_byte(all_reps[0][7:0]); // byte 6: LSB of reps
          write_next_byte({1'b0, all_reps[0][12:8], 2'b01}); // byte 7: MSB of reps, source=clkgen
          rw_lots_bytes(`CLOCKGLITCH_SETTINGS);
          write_next_byte(8'h00); // byte 0
          write_next_byte(8'h00); // byte 1
          write_next_byte(8'h00); // byte 2
          write_next_byte(8'h00); // byte 3
          write_next_byte(8'h00); // byte 4
          write_next_byte(8'h00); // byte 5: manual go done
          //write_next_byte(8'h01); // byte 6: reps=1
          //write_next_byte(8'h01); // byte 7: source=clkgen
          write_next_byte(all_reps[0][7:0]); // byte 6: LSB of reps
          write_next_byte({1'b0, all_reps[0][12:8], 2'b01}); // byte 7: MSB of reps, source=clkgen
          */


          /* debug exiting continuous mode
          rw_lots_bytes(`CLOCKGLITCH_SETTINGS);
          write_next_byte(8'h00); // byte 0
          write_next_byte(8'h00); // byte 1
          write_next_byte(8'h00); // byte 2
          write_next_byte(8'h00); // byte 3
          write_next_byte(8'h00); // byte 4
          write_next_byte(8'h08); // byte 5: continuous
          write_next_byte(reps[7:0]); // byte 6: LSB of reps
          write_next_byte({1'b0, reps[12:8], 2'b01}); // byte 7: MSB of reps, source=clkgen

          rw_lots_bytes(`CLOCKGLITCH_SETTINGS);
          write_next_byte(8'h00); // byte 0
          write_next_byte(8'h00); // byte 1
          write_next_byte(8'h00); // byte 2
          write_next_byte(8'h00); // byte 3
          write_next_byte(8'h00); // byte 4
          write_next_byte(8'h0c); // byte 5: single-shot
          write_next_byte(reps[7:0]); // byte 6: LSB of reps
          write_next_byte({1'b0, reps[12:8], 2'b01}); // byte 7: MSB of reps, source=clkgen
          */


      end

      if (pTRIGGER_DELAY) begin
         //wait (U_dut.oadc.U_fifo.fast_fifo_full);
         //wait (U_dut.oadc.U_fifo.fast_fifo_empty == 1'b0);
         repeat (pTRIGGER_DELAY) @(posedge clk_adc);
      end

      // it takes up to ~700 clock cycles after reset for things to get going again:
      #(pCLK_USB_PERIOD*900);

      /* test register access to different blocks
      rdata[7:6] = `TW_TRACE_REG_SELECT;
      rdata[5:0] = `REG_NAME;
      $display("AAA %h", rdata);
      rw_lots_bytes(rdata);
      for (i = 0; i < 8; i = i + 1) begin
          read_next_byte(rdata);
          $display("XXX %h", rdata);
      end

      read_1byte(8'hc0, rdata);
      $display("YYY %h", rdata);
      */

     // manually test LA capture
  if (pBYPASS_DDR == 0) begin // TODO: LA capture doesn't work yet when DDR is bypassed
      //write_1byte(`RESET, 8'd1);
      //write_1byte(`RESET, 8'd0);
      rdata[7:6] = `TW_TRACE_REG_SELECT;
      rdata[5:0] = `REG_TRACE_EN;
      write_1byte(rdata, 8'd0);
      //rdata[5:0] = `REG_FE_CLOCK_SEL;
      //write_1byte(rdata, 8'd2); // USB clock
      //write_1byte(`LA_CLOCK_SOURCE, 8'd0); // target clock
      write_1byte(`LA_CLOCK_SOURCE, 8'd1); // USB clock
      write_1byte(`LA_ENABLED, 8'd1);
      write_1byte(`LA_ARM, 8'd1);

      rw_lots_bytes(`LA_CAPTURE_DEPTH);
      write_next_byte((128 & 32'h0000_00FF));
      write_next_byte((128 & 32'h0000_FF00)>>8);

      write_1byte(`LA_CAPTURE_GROUP, 8'h86); // group 6 in 4-bit capture mode
      write_1byte(`LA_DOWNSAMPLE, 8'd0);
      write_1byte(`LA_MANUAL_CAPTURE, 8'd1);
      #(pCLK_USB_PERIOD * 10);
      write_1byte(`LA_MANUAL_CAPTURE, 8'd0);
      //for (i = 0; i < 10; i = i + 1) begin
      //    target_io4_reg <= ~target_io4_reg;
      //    repeat(20) @(posedge clk_adc);
      //end
      #(pCLK_USB_PERIOD * 200);
      //
  end

      if (pDDR_TEST)
          write_1byte(`REG_DDR3_STAT, 1);
      if (pBYPASS_DDR) begin
          read_1byte(`FIFO_CONFIG, rdata);
          rdata[0] = 1'b0;
          write_1byte(`FIFO_CONFIG, rdata);
      end

      // test single DDR R/W:
  if (pBYPASS_DDR == 0) begin // TODO: doesn't work yet when DDR is bypassed
      rw_lots_bytes(`REG_DDR_SINGLE_RW_DATA);
      write_next_byte((64'h12345678_a1b2c3d4 & 64'h0000_0000_0000_00FF));
      write_next_byte((64'h12345678_a1b2c3d4 & 64'h0000_0000_0000_FF00)>>8);
      write_next_byte((64'h12345678_a1b2c3d4 & 64'h0000_0000_00FF_0000)>>16);
      write_next_byte((64'h12345678_a1b2c3d4 & 64'h0000_0000_FF00_0000)>>24);
      write_next_byte((64'h12345678_a1b2c3d4 & 64'h0000_00FF_0000_0000)>>32);
      write_next_byte((64'h12345678_a1b2c3d4 & 64'h0000_FF00_0000_0000)>>40);
      write_next_byte((64'h12345678_a1b2c3d4 & 64'h00FF_0000_0000_0000)>>48);
      write_next_byte((64'h12345678_a1b2c3d4 & 64'hFF00_0000_0000_0000)>>56);

      rw_lots_bytes(`REG_DDR_SINGLE_RW_ADDR);
      // use a low address that's covered by the memory model!
      write_next_byte((32'h8000_0000 & 32'h0000_00FF));
      write_next_byte((32'h8000_0000 & 32'h0000_FF00)>>8);
      write_next_byte((32'h8000_0000 & 32'h00FF_0000)>>16);
      write_next_byte((32'h8000_0000 & 32'hFF00_0000)>>24);

      repeat (100) @(posedge clk_usb);
      rw_lots_bytes(`REG_DDR_SINGLE_RW_ADDR);
      write_next_byte((32'h0000_0000 & 32'h0000_00FF));
      write_next_byte((32'h0000_0000 & 32'h0000_FF00)>>8);
      write_next_byte((32'h0000_0000 & 32'h00FF_0000)>>16);
      write_next_byte((32'h0000_0000 & 32'hFF00_0000)>>24);

      repeat (500) @(posedge clk_usb);
      rw_lots_bytes(`REG_DDR_SINGLE_RW_DATA);
      read_next_byte(rdata);
      read_next_byte(rdata);
      read_next_byte(rdata);
      read_next_byte(rdata);
      read_next_byte(rdata);
      read_next_byte(rdata);
      read_next_byte(rdata);
      read_next_byte(rdata);
      //
  end

      setup_done = 1;

   end



   // trigger thread:
   /* Capture options:
    * 1. pTRIGGER_NOW: use register write mechanism (1) vs IO4 (0) to initiate capture.
    * 2. pNUM_SEGMENTS: number of segments to capture
    * 3. pSEGMENT_CYCLE_COUNTER_EN: if set, after the initial trigger, start a new segment every pSEGMENT_CYCLES cycles;
    *    otherwise, start a new segment when IO4 transitions from 0 to 1; this is done for pNUM_SEGMENTS segments. Note that
    *    when pSEGMENT_CYCLE_COUNTER_EN = 0, by convenience the testbench still waits for pSEGMENT_CYCLES in between trigger
    *    assertions (however pSEGMENT_CYCLES is not programmed to the DUT!)
    * 4. In all cases, capture stops when the *total* requested number of samples (pFIFO_SAMPLES) have been collected.
   */
   reg [7:0] settings = 0;
   initial begin
      trigger_done = 0;
      trigger2_done = 0;
      trigger_event = 0;
      #1 wait (setup_done);
      for (trigger_gen_index = 0; trigger_gen_index < pNUM_SEGMENTS; trigger_gen_index += 1) begin

         settings[3] = 1'b1; // keep arm bit set
         if (trigger_gen_index == 0) begin
            settings[4] = pSTREAM;
            settings[2] = 1'b1; // high trigger polarity
            if (pTRIGGER_NOW) begin
               settings[3] = 1'b1; // arm
               settings[6] = 1'b1; // trigger now
               write_1byte(`SETTINGS_ADDR, settings);
               glitches_done = 1'b1; // glitch stuff won't happen with TRIGGER_NOW so don't wait for it
            end
            else begin
               write_1byte(`SETTINGS_ADDR, settings);
               target_io4_reg = 1'b1;
            end
            trigger_event = 1'b1;
         end
         else if (pSEGMENT_CYCLE_COUNTER_EN == 0)
            target_io4_reg = 1'b1;

         trigger_counter_value[trigger_gen_index] = U_dut.oadc.U_fifo.adc_datain - pPRESAMPLES + offset + 1;

         if (pSHORT_TRIGGER)
             trigger_cycles = 5;
         else begin
             if (pNUM_SEGMENTS > 1)
                 trigger_cycles = $urandom_range(3, fifo_samples-2);
             else
                 trigger_cycles = $urandom_range(3, 2*fifo_samples+offset); // to cover the case where trigger is held longer than the capture
         end

         repeat (trigger_cycles) @(posedge clk_adc);
         target_io4_reg = 1'b0;

         if (pNUM_SEGMENTS > 1) begin
             if (pSEGMENT_CYCLES > trigger_cycles)
                repeat (pSEGMENT_CYCLES-trigger_cycles) @(posedge clk_adc);
             else begin
                $display("ERROR: pSEGMENT_CYCLES (%d) too small! trigger_cycles=%d", pSEGMENT_CYCLES, trigger_cycles);
                errors += 1;
             end
         end
      end
      trigger_done = 1;

      /* rough 2nd ADC capture:
      repeat (5000) @(posedge clk_adc);
      write_1byte(`SETTINGS_ADDR, 0);
      repeat (20) @(posedge clk_usb);
      settings[3] = 1'b1; // keep arm bit set
      settings[4] = pSTREAM;
      settings[2] = 1'b1; // high trigger polarity
      if (pTRIGGER_NOW) begin
         settings[3] = 1'b1; // arm
         settings[6] = 1'b1; // trigger now
         write_1byte(`SETTINGS_ADDR, settings);
         glitches_done = 1'b1; // glitch stuff won't happen with TRIGGER_NOW so don't wait for it
      end
      else begin
         write_1byte(`SETTINGS_ADDR, settings);
         repeat (1000) @(posedge clk_adc);
         target_io4_reg = 1'b1;
      end
      repeat (500) @(posedge clk_adc);
      trigger2_done = 1;
      */

   end


initial begin
    ddr_read_started = 0;
    wait (setup_done);
    wait (U_dut.oadc.U_ddr.ddr_reading);
    ddr_read_started = 1;
end

// read thread:
initial begin
  if (pDDR_TEST == 0) begin
      good_reads = 0;
      bad_reads = 0;
      i12BitReadCount = 0;

      // Figure out the total number of samples to read.
      // It's the total number of samples, accounting for segments, rounded up to a multiple of 3.
      //samples_to_read = $ceil(prFIFO_SAMPLES*pNUM_SEGMENTS/3)*3;
      samples_to_read = prFIFO_SAMPLES*pNUM_SEGMENTS;

      if (pSTREAM) begin
         wait (setup_done);
         repeat (pREAD_DELAY) @(posedge clk_adc);
         write_1byte(`FAST_FIFO_READ_MODE, 1);
         wait (stream_segment_available);
      end
      
      else begin
         // ugh this is messy... replaced trigger_done by trigger_event for
         // Pro, but that will likely break segmented testcases?
         #1 wait (trigger_event == 0);
         #1 wait (trigger_event);
         // wait for the last segment's samples to get captured:
         $display("waiting 1...");
         if (pBYPASS_DDR == 0) begin
             wait (U_dut.oadc.U_ddr.ddr_write_data_done == 1'b0);
             wait (U_dut.oadc.U_ddr.ddr_write_data_done == 1'b1);
             write_1byte(`REG_DDR_START_READ, 8'd1);
             $display("waiting 2...");
             wait (ddr_read_started);
             repeat (300) @(posedge clk_adc);
         end
         else // bypass DDR case
             repeat((fifo_samples+2)*(pDOWNSAMPLE+1)) @(posedge clk_adc);
         repeat (pREAD_DELAY+offset) @(posedge clk_adc);
      end

      rw_lots_bytes(`ADCREAD_ADDR);
      $display("XXX samples_to_read: %d", samples_to_read);
      segment_read_index = 0;

      for (i = 0; i < samples_to_read; i = i + 1) begin
         if (pSTREAM)
            // TODO: technically we shouldn't be checking before every single read...
            wait (stream_segment_available);
         read_next_sample(sample);
         //$display("Read %h", sample);

         if ((i % fifo_samples == 0) && (i < fifo_samples*pNUM_SEGMENTS)) begin
            //$display("Checking first segment index (i=%d)", i);
            check_first_sample(trigger_counter_value[segment_read_index]);
            segment_read_index += 1;
         end

         else begin
            expected = (last_sample + (pDOWNSAMPLE+1)) % (pADC_LOW_RES? 2**8:2**12);
            if (sample == expected) begin
               good_reads += 1;
               $display("good read %d: %2h", i, sample);
            end
            else begin
               bad_reads += 1;
               if (!pERRORS_OK) errors += 1;
               $display("ERROR %2d: expected %2h, got %2h", i, expected, sample);
            end
            //$display("%2d: last=%2h, read %2h", i, last_sample, rdata);
         end
         last_sample = sample;
      end

      #1;
      if (U_dut.oadc.U_fifo.fast_fifo_empty == 0) begin
         if (!pERRORS_OK) errors += 1;
         $display("ERROR at t=%0t: fast FIFO not empty at the end of a read cycle", $time);
      end
      /* TODO: temporarily commented out because last word is left unread, due
         to the first word fallthrough nature of the FIFO.
      if (U_dut.oadc.U_fifo.postddr_fifo_empty == 0) begin
         if (!pERRORS_OK) errors += 1;
         $display("ERROR at t=%0t: post-DDR FIFO not empty at the end of a read cycle", $time);
      end
      */
      if (U_dut.oadc.U_fifo.preddr_fifo_empty == 0) begin
         if (!pERRORS_OK) errors += 1;
         $display("ERROR at t=%0t: pre-DDR FIFO not empty at the end of a read cycle", $time);
      end


      // TODO-temporary to manually verify if fast reads get disabled: (clean up later)
      write_1byte(`ECHO_ADDR, 155);
      read_1byte(`ECHO_ADDR, rdata);
      if (rdata != 155) begin
          errors += 1;
          $display("ERROR: reading after fast reads");
      end

      if (pSTREAM)
         // clear stream mode:
         write_1byte(`FAST_FIFO_READ_MODE, 0);

      //#(pCLK_USB_PERIOD*20);
      #(pCLK_USB_PERIOD*500);
      
      // check no errors:
      read_1byte(`FIFO_STAT, rdata);
      if (pPRESAMP_ERROR) begin
         if (rdata[4] != 1'b1) begin
            errors += 1;
            $display("ERROR: FIFO status error (%d).", rdata[4:0]);
         end
      end
      else if (rdata[4:0] != 5'b0) begin
         errors += 1;
         $display("ERROR: FIFO status error (%d).", rdata[4:0]);
      end

      wait(glitches_done);

      $display("Done reading.");
      $display("Good reads: %d", good_reads);
      $display("Bad reads: %d", bad_reads);

      /* now read the LA data and check it:
      write_1byte(`REG_DDR_START_READ, 8'd2);
      repeat(100) @(posedge clk_usb);   // CRITICAL: postddr FIFO must not be empty! 
                                        // while writing REG_DDR_START_READ above kicks off filling the postddr FIFO,
                                        // there is a lag for the first DDR reads to come in.
      rw_lots_bytes(`ADCREAD_ADDR);
      for (i = 0; i < 64; i += 1) begin
          read_next_byte(rdata);
          $display("LA read byte: %2x", rdata);
          // primitive error checking
          if (((8'ha1 + (2*i)) % 256) != rdata) begin
              $display("ERROR on LA read");
              errors += 1;
          end
      end
      */

      if (errors)
         $display("SIMULATION FAILED (%0d errors)", errors);
      else
         $display("Simulation passed (%0d warnings)", warnings);

     /* rough check on 2nd capture:
      wait(trigger2_done);
      write_1byte(`REG_DDR_START_READ, 8'd1);
      //repeat(100) @(posedge clk_usb);
      rw_lots_bytes(`ADCREAD_ADDR);
      $display("XXX samples_to_read: %d", samples_to_read);
      segment_read_index = 0;

      for (i = 0; i < 10; i = i + 1) begin
         read_next_sample(sample);
         $display("Read %h", sample);
      end
     */

      $finish;
   end
end


   // check glitch output thread:
   // First we generate the expected glitch enable:
   reg expected_glitch;
   wire glitch_clock = U_dut.reg_clockglitch.U_clockglitch.glitch_mmcm1_clk_out_buf;
   int glitch_errors;
   reg glitch_compare;
   initial begin
       expected_glitch = 1'b0;
       glitch_errors = 0;
       glitch_compare = 0;
       //glitches_done = 0;
       glitches_done = 1; // TODO- temporary: no TRIG_GLITCHOUT on CW310 build
       wait (TRIG_GLITCHOUT);
       glitch_compare = 1;
       repeat (6 + all_offs[0]) @(negedge glitch_clock);
       for (k = 1; k < pNUM_GLITCHES; k = k + 1) begin
           expected_glitch = 1'b1;
           repeat(all_reps[k-1]+1) @(negedge glitch_clock);
           expected_glitch = 1'b0;
           repeat(all_offs[k] - all_reps[k-1] + 1) @(negedge glitch_clock);
       end
       expected_glitch = 1'b1;
       repeat(all_reps[pNUM_GLITCHES-1]+1) @(negedge glitch_clock);
       expected_glitch = 1'b0;
       repeat(100) @(negedge glitch_clock);
       glitch_compare = 0;
       if (glitch_errors) begin
           errors += glitch_errors;
           $display("ERROR: %0d glitch comparison failures", glitch_errors);
       end
       wait (~target_io4);
       repeat(10) @(posedge clk_adc);
       if (~U_dut.reg_clockglitch.resync.idle) begin
           errors += 1;
           $display("ERROR: glitch trigger_resync FSM not in idle when it should be done.");
       end
       glitches_done = 1;
   end

   // Then we flag any differences:
   wire glitch_enable = U_dut.reg_clockglitch.U_clockglitch.glitch_enable;
   wire glitch_error = (glitch_enable ^ expected_glitch);
   always @(glitch_clock) begin
       if (glitch_compare & glitch_error)
           glitch_errors += 1;
   end

   // DDR test thread:
   initial begin
       if (pDDR_TEST) begin
           wait (setup_done);
           force U_dut.oadc.U_ddr.U_simple_ddr3_rwtest.ddrtest_stop = 32'h0000_3ff8;
           repeat(100) @(posedge clk_usb);
           ddr_loops = 0;
           while (ddr_loops < pDDR_TEST_LOOPS) begin
               read_1byte(`REG_DDR3_TEST_LOOPS, ddr_loops);
               repeat(1000) @(posedge clk_usb);
           end
           // check for errors:
           rw_lots_bytes(`REG_DDR3_STAT);
           read_next_byte(ddr_loops);
           read_next_byte(ddr_loops);
           if (ddr_loops != 1) begin
               errors += 1;
               $display("ERROR: DDR stat = %d", ddr_loops);
           end
           read_next_byte(ddr_loops);
           if (ddr_loops > 0) begin
               errors += 1;
               $display("ERROR: %d DDR errors", ddr_loops);
           end

           if (errors)
              $display("SIMULATION FAILED (%0d errors)", errors);
           else
              $display("Simulation passed (%0d warnings)", warnings);
           $finish;
       end
   end

   // timeout thread:
   initial begin
      if (pTIMEOUT_CYCLES > 0) begin
          #(pCLK_USB_PERIOD*pTIMEOUT_CYCLES);
          errors += 1;
          $display("ERROR: global timeout.");
          $display("SIMULATION FAILED (%0d errors)", errors);
          $finish;
      end
   end


   // monitor internal errors to help debug:
   always @(posedge (U_dut.oadc.U_fifo.error_flag || U_dut.oadc.U_ddr.U_ddr3_model.dropped_read_request)) begin
      if (!pERRORS_OK) begin
         errors += 1;
         $display("ERROR: internal FIFO at t = %t (error_stat = %d)", $time, U_dut.oadc.U_fifo.error_stat);
         if (U_dut.oadc.U_fifo.error_stat[10]) $display("(preddr_fifo_overflow)");
         if (U_dut.oadc.U_fifo.error_stat[9] ) $display("(preddr_fifo_underflow)");
         if (U_dut.oadc.U_fifo.error_stat[8] ) $display("(gain_error)");
         if (U_dut.oadc.U_fifo.error_stat[7] ) $display("(segment_error)");
         if (U_dut.oadc.U_fifo.error_stat[6] ) $display("(downsample_error)");
         if (U_dut.oadc.U_fifo.error_stat[5] ) $display("(clip_error)");
         if (U_dut.oadc.U_fifo.error_stat[4] ) $display("(presamp_error)");
         if (U_dut.oadc.U_fifo.error_stat[3] ) $display("(fast_fifo_overflow");
         if (U_dut.oadc.U_fifo.error_stat[2] ) $display("(fast_fifo_underflow)");
         if (U_dut.oadc.U_fifo.error_stat[1] ) $display("(postddr_fifo_overflow)");
         if (U_dut.oadc.U_fifo.error_stat[0] ) $display("(postddr_fifo_underflow_masked)");
         $display("SIMULATION FAILED (%0d errors)", errors);
         fifo_error = 1; // don't die right away - see initial block below
      end
   end

   initial begin
       wait (fifo_error);
       repeat(20) @(posedge clk_usb);
       $finish;
   end


   always #(pCLK_USB_PERIOD/2) clk_usb = !clk_usb;
   always #(pCLK_ADC_FAST_PERIOD/2) clk_adc_fast = !clk_adc_fast;
   always #(pCLK_ADC_SLOW_PERIOD/2) clk_adc_slow = !clk_adc_slow;
   always #(pCLK_ADC_NOM_PERIOD/2) clk_adc_nom = !clk_adc_nom;

   wire #1 usb_rdn_out = usb_rdn;
   wire #1 usb_wrn_out = usb_wrn;
   wire #1 usb_cen_out = usb_cen;
   wire #1 usb_alen_out = usb_alen;
   wire [7:0] #1 usb_addr_out = usb_addr;

   reg read_select;

   wire usb_clk = clk_usb;

   assign usb_data = read_select? 8'bz : usb_wdata;

   always @(*) begin
      if (usb_wrn == 1'b0)
         read_select = 1'b0;
      else if (usb_rdn == 1'b0)
         read_select = 1'b1;
   end

//assign #1 target_io4 = target_io4_reg;
assign target_io4 = target_io4_reg;

assign adc_clocks = {clk_adc_nom, clk_adc_fast, clk_adc_slow};

assign clk_adc = pSLOW_ADC? clk_adc_slow :
                 pFAST_ADC? clk_adc_fast : 
                 pNOM_ADC? clk_adc_nom :
                 adc_clocks[chosen_clock];

cwhusky_cw310_top U_dut (  
    .clk_usb            (clk_usb      ),
    .ADC_clk_fbp        (clk_adc      ),
    .ADC_clk_fbn        (1'b0         ),
    .PLL_CLK1           (clk_adc      ),
    //.ADC_DP             (6'b0         ),
    //.ADC_DN             (6'b0         ),
    //.ADC_CLKP           (             ),
    //.ADC_CLKN           (             ),
    .LED_ADC            (LED_ADC      ),
    .LED_GLITCH         (LED_GLITCH   ),
    .LED_ARMED          (LED_ARMED    ),
    .LED_CAP            (LED_CAP      ),
    .USB_Data           (usb_data     ),
    .USB_Addr           (usb_addr_out ),
    .USB_RDn            (usb_rdn_out  ),
    .USB_WRn            (usb_wrn_out  ),
    .USB_CEn            (usb_cen_out  ),
    .USB_Addr_Bytecount (usb_bytecount),
    //.USB_ALEn           (usb_alen_out ),
    //.USB_SPARE0         (stream_segment_available),
    //.FPGA_BONUS1        (FPGA_BONUS1  ),
    //.FPGA_BONUS2        (FPGA_BONUS2  ),
    //.FPGA_BONUS3        (FPGA_BONUS3  ),
    //.FPGA_BONUS4        (FPGA_BONUS4  ),
    //.SAM_MOSI           (SAM_MOSI     ),
    //.SAM_MISO           (SAM_MISO     ),
    //.SAM_SPCK           (SAM_SPCK     ),
    //.SAM_CS             (SAM_CS       ),
    .target_PDID        (target_PDID  ),
    .target_PDIC        (target_PDIC  ),
    .target_nRST        (target_nRST  ),
    .target_MISO        (target_MISO  ),
    .target_MOSI        (target_MOSI  ),
    .target_SCK         (target_SCK   ),
    .target_io4         (target_io4   ),
    .target_io3         (target_io3   ),
    .target_io2         (target_io2   ),
    .target_io1         (target_io1   ),
    .target_hs1         (target_hs1   ),
    .target_hs2         (target_hs2   ),
    //.TRIG_GLITCHOUT     (TRIG_GLITCHOUT),
    .AUXIO              (AUXIO        ),
    //.ADC_OVR_SDOUT      (1'b0         ),
    //.FPGA_CDOUT         (1'b0         ),
    .USERIO_D           (             ),
    .USERIO_CLK         (             )
    //.PLL_STATUS         (1'b0         ),
    //.PLLFPGAP           (clk_adc      ),
    //.PLLFPGAN           (1'b0         )
);



task check_first_sample;
   input [11:0] expected_value;
   begin
      if (pADC_LOW_RES)
         expected_value = {4'b0, expected_value[7:0]};
      // dealing with signed numbers in Verilog is always really fun!
      comp_min = {1'b0, expected_value} - pSLOP + pTRIGGER_ADJUST; // signed
      comp_max = {1'b0, expected_value} + pSLOP + pTRIGGER_ADJUST + pDOWNSAMPLE; // signed
      signed_sample = {1'b0, sample};

      // adjust MSB if we went past the sample range:
      if ($signed(signed_sample) < $signed(comp_min)) begin
         if (pADC_LOW_RES)
            signed_sample[8] = comp_max[8];
         else
            signed_sample[12] = comp_max[12];
      end

      if ( ($signed(signed_sample) >= $signed(comp_min)) && ($signed(signed_sample) <= $signed(comp_max)) ) begin
         good_reads += 1;
         $display("\nGood first read: expected min=%3h, max=%3h, got %3h", comp_min, comp_max, sample);
      end
      else begin
         bad_reads += 1;
         if (!pERRORS_OK) errors += 1;
         $display("\nERROR on first read: expected min=%3h, max=%3h, got %3h, signed=%h", comp_min, comp_max, sample, signed_sample);
      end
   end
endtask


endmodule
`default_nettype wire
