`timescale 1 ns / 1 ps
`default_nettype none

module cwhusky_tb();
   parameter pCLK_USB_PERIOD = 10;
   parameter pCLK_ADC_FAST_PERIOD = 5.5;
   parameter pCLK_ADC_SLOW_PERIOD = 21.0;
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
   parameter pSEGMENT_CYCLES = 0;
   parameter pSEGMENT_CYCLE_COUNTER_EN = 0;
   parameter pSLOP = 10;
   parameter pSEED = 1;
   parameter pTIMEOUT_CYCLES = 50000;
   parameter pDUMP = 0;


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
   reg                  USB_SPARE0;
   reg                  USB_SPARE1;

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
   reg  [11:0] sample[0:5];
   reg  [11:0] last_sample;
   reg  [11:0] comp;
   reg  [11:0] trigger_counter_value;
   int comp_min;
   int comp_max;
   int signed_sample;
   reg  setup_done;
   reg  trigger_done;
   reg  read_done;
   reg  target_io4_reg;
   int i, j;
   int trigger_gen_index;
   int segment_read_index;
   int good_reads, bad_reads, errors, warnings;
   int seed;


   // initialization thread:
   initial begin
      seed = pSEED;
      $display("Running with seed=%0d", seed);
      rdata = $urandom(seed);
      $display("pPRESAMPLES = %d", pPRESAMPLES);
      $display("pFIFO_SAMPLES = %d", pFIFO_SAMPLES);
      $display("pADC_LOW_RES = %d", pADC_LOW_RES);
      $display("pTRIGGER_NOW = %d", pTRIGGER_NOW);
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
      write_next_byte((pFIFO_SAMPLES & 32'h0000_00FF));
      write_next_byte((pFIFO_SAMPLES & 32'h0000_FF00)>>8);
      write_next_byte((pFIFO_SAMPLES & 32'h00FF_0000)>>16);
      write_next_byte((pFIFO_SAMPLES & 32'hFF00_0000)>>24);


      write_1byte('h1, 8'hc); // arm, trigger level = high

      // random delay before trigger:
      //#($urandom_range(0, 100)*pCLK_USB_PERIOD);

      if (pTRIGGER_DELAY) begin
         //wait (U_dut.oadc.U_fifo.fast_fifo_full);
         //wait (U_dut.oadc.U_fifo.fast_fifo_empty == 1'b0);
         repeat (pTRIGGER_DELAY) @(posedge clk_adc);
      end

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

      // it takes up to ~700 clock cycles after reset for things to get going again:
      #(pCLK_USB_PERIOD*900);

      setup_done = 1;

   end


   /* trigger thread:
   initial begin
      trigger_done = 0;
      #1 wait (setup_done);
      // randomly choose to use trigger pin or "trigger now"
      for (trigger_gen_index = 0; trigger_gen_index <= pNUM_SEGMENTS; trigger_gen_index += 1) begin
         @(posedge clk_adc);
         trigger_done = 0;
         if (pSEGMENT_CYCLE_COUNTER_EN && (trigger_gen_index > 0))
            repeat (pSEGMENT_CYCLES) @(posedge clk_adc);
         else begin
            if (pTRIGGER_NOW) begin
               // TRIGGER_NOW doesn't support segments, but we handle it in this loop for convenience
               $display("Using 'trigger now'.");
               write_1byte('h1, 8'h48);
            end
            else begin
               $display("Using trigger pin.");
               target_io4_reg = 1'b1;
            end
         end
         trigger_counter_value = U_dut.oadc.U_fifo.adc_datain - pPRESAMPLES;
         #(pCLK_USB_PERIOD*20);
         target_io4_reg = 1'b0;
         trigger_done = 1;
         if (pSEGMENT_CYCLE_COUNTER_EN == 0)
            wait (read_done);
      end
   end
   */


   // trigger thread:
   initial begin
      trigger_done = 0;
      #1 wait (setup_done);
      if (pTRIGGER_NOW) begin
         write_1byte('h1, 8'h48);
         trigger_counter_value = U_dut.oadc.U_fifo.adc_datain - pPRESAMPLES;
         #(pCLK_USB_PERIOD*20);
         trigger_done = 1;
         // trigger now doesn't support segments, so we're done here
      end

      else begin
         for (trigger_gen_index = 0; trigger_gen_index <= pNUM_SEGMENTS; trigger_gen_index += 1) begin
            // If capture is triggered by the testbench, we carefully handshake between this trigger thread and the read thread, to keep them
            // in sync. If segments are triggered by fixed cycle counts, then we just count cycles - can't have any waits to sync with the read thread, 
            // otherwise we'll actually be out of sync from what the hardware's doing!
            if (pSEGMENT_CYCLE_COUNTER_EN) begin
               if (trigger_gen_index == 0) begin
                  target_io4_reg = 1'b1;
                  trigger_counter_value = U_dut.oadc.U_fifo.adc_datain - pPRESAMPLES;
                  repeat (10) @(posedge clk_adc);
                  trigger_done = 1;
               end
               else begin
                  @(posedge clk_adc);
                  trigger_done = 0;
                  repeat (pSEGMENT_CYCLES-11) @(posedge clk_adc);
                  trigger_counter_value = U_dut.oadc.U_fifo.adc_datain - pPRESAMPLES;
                  trigger_done = 1;
               end
            end

            else begin // pSEGMENT_CYCLE_COUNTER_EN == 0
               @(posedge clk_adc);
               trigger_done = 0;
               repeat ($urandom_range(0, 200)) @(posedge clk_adc);
               target_io4_reg = 1'b1;
               trigger_counter_value = U_dut.oadc.U_fifo.adc_datain - pPRESAMPLES;
               #(pCLK_USB_PERIOD*20);
               target_io4_reg = 1'b0;
               trigger_done = 1;
               wait (read_done);
            end
         end
      end
   end



   // read thread:
   initial begin
      read_done = 0;
      for (segment_read_index = 0; segment_read_index <= pNUM_SEGMENTS; segment_read_index += 1) begin
         #1 wait (trigger_done == 0);
         #1 wait (trigger_done);
         repeat (10) @(posedge clk_adc);
         good_reads = 0;
         bad_reads = 0;
         read_done = 0;
         //wait (U_dut.oadc.U_fifo.slow_fifo_full);
         //#(pCLK_USB_PERIOD*1000);
         if (pREAD_DELAY) begin
            repeat (pREAD_DELAY) @(posedge clk_adc);
         end

         rw_lots_bytes('d3);
         if (pADC_LOW_RES) begin // 8 bits per sample
            for (i = 0; i < pFIFO_SAMPLES; i = i + 1) begin
               if (i%1000 == 0)
                  $display("heartbeat: read %d samples", i);
               read_next_byte(rdata);
               if (i == 0)
                  last_sample = rdata;
               else begin
                  if (rdata == (last_sample + 1) % 256)
                     good_reads += 1;
                  else begin
                     bad_reads += 1;
                     errors += 1;
                     $display("ERROR %2d: expected %2h, got %2h", i, (last_sample + 1)%256, rdata);
                  end
                  //$display("%2d: last=%2h, read %2h", i, last_sample, rdata);
                  last_sample = rdata;
               end
            end
         end

         else begin // 12 bits per sample
            for (i = 0; i < pFIFO_SAMPLES/6; i = i + 1) begin
               if (i%100 == 0)
                  $display("heartbeat: read %d samples", i*6);
               for (j = 0; j < 9; j = j + 1) begin
                  rdata_r = rdata;
                  read_next_byte(rdata);
                  //$display("XXX: read %2h", rdata);
                  case (j)
                     1: sample[0] = {rdata_r, rdata[7:4]};
                     2: sample[1] = {rdata_r[3:0], rdata};
                     4: sample[2] = {rdata_r, rdata[7:4]};
                     5: sample[3] = {rdata_r[3:0], rdata};
                     7: sample[4] = {rdata_r, rdata[7:4]};
                     8: sample[5] = {rdata_r[3:0], rdata};
                  endcase
               end
               for (j = 0; j < 6; j += 1) begin

                  // for the very first sample, we check against what we peeked when we applied the trigger, with some slop to account for CDCs:
                  if ((i == 0) && (j == 0)) begin
                     // dealing with signed numbers in Verilog is always really fun!
                     comp_min = {1'b0, trigger_counter_value} - pSLOP; // signed
                     comp_max = {1'b0, trigger_counter_value} + pSLOP; // signed
                     signed_sample = {1'b0, sample[0]};
                     if ( ($signed(signed_sample) >= $signed(comp_min)) && ($signed(signed_sample) <= $signed(comp_max)) ) begin
                        good_reads += 1;
                        $display("Good first read: expected min=%3h, max=%3h, got %3h", comp_min, comp_max, sample[0]);
                     end
                     else begin
                        bad_reads += 1;
                        errors += 1;
                        $display("ERROR on first read: expected min=%3h, max=%3h, got %3h", comp_min, comp_max, sample[0]);
                     end
                  end
                  
                  else begin
                     if (j == 0)
                        comp = last_sample;
                     else
                        comp = sample[j-1];
                     if (sample[j] == (comp + 1) % 2**12)
                        good_reads += 1;
                     else begin
                        bad_reads += 1;
                        errors += 1;
                        $display("ERROR %2d: expected %3h, got %3h", i*6+j, (comp + 1) % 2**12, sample[j]);
                     end
                  end

               end
               last_sample = sample[5];
            end
         end
         read_done = 1;
      end // for segment_read_index loop

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

   always #(pCLK_USB_PERIOD/2) clk_usb = !clk_usb;
   always #(pCLK_ADC_FAST_PERIOD/2) clk_adc_fast = !clk_adc_fast;
   always #(pCLK_ADC_SLOW_PERIOD/2) clk_adc_slow = !clk_adc_slow;
   always #(pCLK_ADC_NOM_PERIOD/2) clk_adc_nom = !clk_adc_nom;

   wire #1 usb_rdn_out = usb_rdn;
   wire #1 usb_wrn_out = usb_wrn;
   wire #1 usb_cen_out = usb_cen;
   wire [7:0] #1 usb_addr_out = usb_addr;

   reg read_select;

   wire usb_clk = clk_usb;
   `include "tb_reg_tasks.v"

   assign usb_data = read_select? 8'bz : usb_wdata;

   always @(*) begin
      if (usb_wrn == 1'b0)
         read_select = 1'b0;
      else if (usb_rdn == 1'b0)
         read_select = 1'b1;
   end

assign target_io4 = target_io4_reg;

assign adc_clocks = {clk_adc_slow, clk_adc_fast, clk_adc_nom};

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
    .USB_SPARE0         (USB_SPARE0   ),
    .USB_SPARE1         (USB_SPARE1   ),
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
    .FPGA_CDOUT         (1'b0         )

);


endmodule
`default_nettype wire
