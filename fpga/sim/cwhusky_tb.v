`timescale 1 ns / 1 ps
`default_nettype none

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
   parameter pTRIGGER_DELAY = 0;
   parameter pTRIGGER_NOW = 0;
   parameter pREAD_DELAY = 0;
   parameter pNUM_SEGMENTS = 0;
   parameter pSEGMENT_CYCLES = 1;
   parameter pSEGMENT_CYCLE_COUNTER_EN = 0;
   parameter pSTREAM = 0;
   parameter pSTREAM_SEGMENT_SIZE = 0;
   parameter pSLOP = 5;
   parameter pTRIGGER_ADJUST = pTRIGGER_NOW? 2 : 0;
   parameter pSEED = 1;
   parameter pTIMEOUT_CYCLES = 50000;
   parameter pDUMP = 0;
   parameter pSLOW_READS = 0;

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
   wire                 FPGA_TRIGOUT;
   wire                 USBIOHS2;
   wire                 LED_CLK1FAIL;
   wire                 LED_CLK2FAIL;
   wire                 LED_ARMED;
   wire                 LED_CAP;

   reg  [7:0] rdata;
   reg  [7:0] rdata_r;
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
   reg  target_io4_reg;
   int i, j;
   reg i12BitReadCount;
   int trigger_gen_index;
   int segment_read_index;
   int good_reads, bad_reads, errors, warnings;
   int seed;

   real prFIFO_SAMPLES;
   int fifo_samples;
   int FIFO_SAMPLES_MUL6;
   int samples_to_read;


   // initialization thread:
   initial begin
      seed = pSEED;
      $display("Running with seed=%0d", seed);
      rdata = $urandom(seed);
      $display("pPRESAMPLES = %d", pPRESAMPLES);
      $display("pFIFO_SAMPLES = %d", pFIFO_SAMPLES);
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
      write_1byte('d28, 8'h1);
      write_1byte('d28, 8'h0);
      //write_1byte('h1, 8'h1);
      //write_1byte('h1, 8'h0);

      write_1byte('d60, 'h41);
      write_1byte('d60, 'h01);
      write_1byte('d60, 'h00);
      write_1byte('d60, 'h11);
      write_1byte('d60, 'h10);
      write_1byte('d60, 'h01);
      write_1byte('d60, 'h00);
      write_1byte('d60, 'h11);
      write_1byte('d60, 'h10);
      write_1byte('d60, 'h41);

      // reset again:
      write_1byte('d28, 8'h1);
      write_1byte('d28, 8'h0);
      //write_1byte('h1, 8'h1);
      //write_1byte('h1, 8'h0);
      #(pCLK_USB_PERIOD*1000);

      write_1byte('d61, 'hff);
      write_1byte('d0, 'h7f);

      write_1byte('d27, 8'h0); // data source select
      if (pADC_LOW_RES)
         write_1byte('d29, 3);
      else
         write_1byte('d29, 0);

      // program number of samples:
      rw_lots_bytes('h11);
      write_next_byte((pPRESAMPLES & 32'h0000_00FF));
      write_next_byte((pPRESAMPLES & 32'h0000_FF00)>>8);
      write_next_byte((pPRESAMPLES & 32'h00FF_0000)>>16);
      write_next_byte((pPRESAMPLES & 32'hFF00_0000)>>24);

      rw_lots_bytes('h10);
      write_next_byte((fifo_samples & 32'h0000_00FF));
      write_next_byte((fifo_samples & 32'h0000_FF00)>>8);
      write_next_byte((fifo_samples & 32'h00FF_0000)>>16);
      write_next_byte((fifo_samples & 32'hFF00_0000)>>24);


      write_1byte('h1, 8'hc); // arm, trigger level = high

      // random delay before trigger:
      //#($urandom_range(0, 100)*pCLK_USB_PERIOD);

      if (pTRIGGER_DELAY) begin
         //wait (U_dut.oadc.U_fifo.fast_fifo_full);
         //wait (U_dut.oadc.U_fifo.fast_fifo_empty == 1'b0);
         repeat (pTRIGGER_DELAY) @(posedge clk_adc);
      end

      // TODO: what's this?!? enabling external clock? cleanup required
      write_1byte(38, 8'h63);

      // number of segments - 1 (0 = 1 segment, 1 = 2 segments,...)
      write_1byte(32, pNUM_SEGMENTS);
      if (pSEGMENT_CYCLE_COUNTER_EN) begin
         // number of cycles between segments:
         rw_lots_bytes(33);
         write_next_byte((pSEGMENT_CYCLES & 32'h0000_00FF));
         write_next_byte((pSEGMENT_CYCLES & 32'h0000_FF00)>>8);
         write_next_byte((pSEGMENT_CYCLES & 32'h00FF_0000)>>16);
      end

      if (pSTREAM) begin
         rw_lots_bytes(35);
         write_next_byte((pSTREAM_SEGMENT_SIZE & 32'h0000_00FF));
         write_next_byte((pSTREAM_SEGMENT_SIZE & 32'h0000_FF00)>>8);
         write_next_byte((pSTREAM_SEGMENT_SIZE & 32'h00FF_0000)>>16);
         write_next_byte((pSTREAM_SEGMENT_SIZE & 32'hFF00_0000)>>24);
      end

      // it takes up to ~700 clock cycles after reset for things to get going again:
      #(pCLK_USB_PERIOD*900);

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
   initial begin
      trigger_done = 0;
      #1 wait (setup_done);
      for (trigger_gen_index = 0; trigger_gen_index < pNUM_SEGMENTS; trigger_gen_index += 1) begin

         if (trigger_gen_index == 0) begin
            if (pTRIGGER_NOW)
               write_1byte('h1, 8'h48);
            else
               target_io4_reg = 1'b1;
         end
         else if (pSEGMENT_CYCLE_COUNTER_EN == 0)
            target_io4_reg = 1'b1;

         trigger_counter_value[trigger_gen_index] = U_dut.oadc.U_fifo.adc_datain - pPRESAMPLES;
         repeat (10) @(posedge clk_adc);
         target_io4_reg = 1'b0;
         if (pSEGMENT_CYCLES > 10)
            repeat (pSEGMENT_CYCLES-10) @(posedge clk_adc);
         else begin
            $display("ERROR: pSEGMENT_CYCLES too small!");
            errors += 1;
         end
      end
      trigger_done = 1;
   end



   // NEW read thread:
   initial begin
      good_reads = 0;
      bad_reads = 0;
      i12BitReadCount = 0;

      // Figure out the total number of samples to read.
      // It's the total number of samples, accounting for segments, rounded up to a multiple of 6.
      samples_to_read = $ceil(prFIFO_SAMPLES*pNUM_SEGMENTS/3)*3;

      if (pSTREAM) begin
         wait (setup_done);
         repeat (pREAD_DELAY) @(posedge clk_adc);
         write_1byte('d36, 1);
         wait (stream_segment_available);
      end
      

      else begin
         #1 wait (trigger_done == 0);
         #1 wait (trigger_done);
         // wait for the last segment's samples to get captured:
         repeat(fifo_samples) @(posedge clk_adc);
      end

      rw_lots_bytes('d3);
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
            expected = (last_sample + 1) % (pADC_LOW_RES? 2**8:2**12);
            if (sample == expected)
               good_reads += 1;
            else begin
               bad_reads += 1;
               errors += 1;
               $display("ERROR %2d: expected %2h, got %2h", i, expected, sample);
            end
            //$display("%2d: last=%2h, read %2h", i, last_sample, rdata);
         end
         last_sample = sample;
      end

      #1;
      if (U_dut.oadc.U_fifo.fast_fifo_empty == 0) begin
         errors += 1;
         $display("ERROR at t=%0t: fast FIFO not empty at the end of a read cycle", $time);
      end
      if (U_dut.oadc.U_fifo.slow_fifo_empty == 0) begin
         errors += 1;
         $display("ERROR at t=%0t: slow FIFO not empty at the end of a read cycle", $time);
      end

      // TODO-temporary to manually verify if fast reads get disabled: (clean up later)
      write_1byte(4, 155);
      read_1byte(4, rdata);
      //$display("Read %d", rdata);

      if (pSTREAM)
         // clear stream mode:
         write_1byte('d36, 0);

      //#(pCLK_USB_PERIOD*20);
      #(pCLK_USB_PERIOD*500);

      $display("Done reading.");
      $display("Good reads: %d", good_reads);
      $display("Bad reads: %d", bad_reads);
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


   // monitor internal errors to help debug:
   always @(posedge U_dut.oadc.U_fifo.error_flag) begin
      errors += 1;
      $display("ERROR: internal FIFO at t = %t", $time);
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

assign #1 target_io4 = target_io4_reg;

assign adc_clocks = {clk_adc_nom, clk_adc_fast, clk_adc_slow};

assign clk_adc = pSLOW_ADC? clk_adc_slow :
                 pFAST_ADC? clk_adc_fast : 
                 pNOM_ADC? clk_adc_nom :
                 adc_clocks[chosen_clock];

cwhusky_top U_dut (  
    .clk_usb            (clk_usb      ),
    .ADC_clk_fbp        (clk_adc      ),
    .ADC_clk_fbn        (1'b0         ),
    .ADC_DP             (6'b0         ),
    .ADC_DN             (6'b0         ),
    .ADC_CLKP           (             ),
    .ADC_CLKN           (             ),
    .LED_CLK1FAIL       (LED_CLK1FAIL ),
    .LED_CLK2FAIL       (LED_CLK2FAIL ),
    .LED_ARMED          (LED_ARMED    ),
    .LED_CAP            (LED_CAP      ),
    .USB_Data           (usb_data     ),
    .USB_Addr           (usb_addr_out ),
    .USB_RDn            (usb_rdn_out  ),
    .USB_WRn            (usb_wrn_out  ),
    .USB_CEn            (usb_cen_out  ),
    .USB_ALEn           (usb_alen_out ),
    .USB_SPARE0         (stream_segment_available),
    .FPGA_BONUS1        (FPGA_BONUS1  ),
    .FPGA_BONUS2        (FPGA_BONUS2  ),
    .FPGA_BONUS3        (FPGA_BONUS3  ),
    .FPGA_BONUS4        (FPGA_BONUS4  ),
    .SAM_MOSI           (SAM_MOSI     ),
    .SAM_MISO           (SAM_MISO     ),
    .SAM_SPCK           (SAM_SPCK     ),
    .SAM_CS             (SAM_CS       ),
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
    .FPGA_TRIGOUT       (FPGA_TRIGOUT ),
    .USBIOHS2           (USBIOHS2     ),
    .ADC_OVR_SDOUT      (1'b0         ),
    .FPGA_CDOUT         (1'b0         ),
    .USERIO_D           (             ),
    .USERIO_CLK         (1'b0         ),
    .PLL_STATUS         (1'b0         ),
    .PLLFPGAP           (1'b0         ),
    .PLLFPGAN           (1'b0         )
);



task check_first_sample;
   input [11:0] expected_value;
   begin
      if (pADC_LOW_RES)
         expected_value = {4'b0, expected_value[7:0]};
      // dealing with signed numbers in Verilog is always really fun!
      comp_min = {1'b0, expected_value} - pSLOP + pTRIGGER_ADJUST; // signed
      comp_max = {1'b0, expected_value} + pSLOP + pTRIGGER_ADJUST; // signed
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
         errors += 1;
         $display("\nERROR on first read: expected min=%3h, max=%3h, got %3h, signed=%h", comp_min, comp_max, sample, signed_sample);
      end
   end
endtask


endmodule
`default_nettype wire
