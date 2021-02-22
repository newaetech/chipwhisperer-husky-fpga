`timescale 1 ns / 1 ps
`default_nettype none

module cwhusky_tb();


   parameter pCLK_PERIOD = 10;
   parameter pTIMEOUT_CYCLES = 50000;
   parameter pADDR_WIDTH = 8;
   parameter pADC_LOW_RES = 1;
   parameter pFIFO_SAMPLES = 90;

   reg                  clk_usb;
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
   reg  setup_done;
   reg  target_io4_reg;
   int i, j;
   int good_reads, bad_reads, errors;


   // initialization thread:
   initial begin
      $dumpfile("results/cwhusky_tb.fst");
      $dumpvars(0, cwhusky_tb);
      setup_done = 0;
      errors = 0;
      clk_usb = 0;
      usb_addr = 0;
      usb_rdn = 1;
      usb_wrn = 1;
      usb_cen = 1;
      target_io4_reg = 0;

      #(pCLK_PERIOD*100);

      // manually reset with new register:
      write_1byte('d28, 8'h1);
      write_1byte('d28, 8'h0);
      //write_1byte('h1, 8'h1);
      //write_1byte('h1, 8'h0);

      write_1byte('h4, 8'ha5);
      read_1byte('h0, rdata);
      read_1byte('h4, rdata);
      $display("Got %h", rdata);

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
      #(pCLK_PERIOD*1000);

      write_1byte('d61, 'hff);
      write_1byte('d0, 'h7f);

      write_1byte('d27, 8'h0); // data source select
      if (pADC_LOW_RES)
         write_1byte('d29, 3);
      else
         write_1byte('d29, 0);

      write_1byte('h1, 8'hc); // arm, trigger level = high
      #(pCLK_PERIOD*20);
      target_io4_reg = 1'b1;
      #(pCLK_PERIOD*1000);
      //write_1byte('h1, 8'h48); // trigger now

      setup_done = 1;

   end


   // read thread:
   initial begin
      #1 wait (setup_done);
      #(pCLK_PERIOD * 100);
      good_reads = 0;
      bad_reads = 0;
      rw_lots_bytes('d3);

      if (pADC_LOW_RES) begin // 8 bits per sample
         for (i = 0; i < pFIFO_SAMPLES; i = i + 1) begin
            read_next_byte(rdata);
            if (i == 0)
               last_sample = rdata;
            else begin
               if (rdata == (last_sample + 1) % 256)
                  good_reads += 1;
               else begin
                  bad_reads += 1;
                  errors += 1;
                  $display("%2d: expected %2h, got %2h", i, (last_sample + 1)%256, rdata);
               end
               //$display("%2d: last=%2h, read %2h", i, last_sample, rdata);
               last_sample = rdata;
            end
         end
      end

      else begin // 12 bits per sample
         for (i = 0; i < pFIFO_SAMPLES/6; i = i + 1) begin
            for (j = 0; j < 9; j = j + 1) begin
               rdata_r = rdata;
               read_next_byte(rdata);
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
               if (j == 0)
                  comp = (i==0)? (sample[0]-1) % 2**12 : last_sample;
               else
                  comp = sample[j-1];
               if (sample[j] == (comp + 1) % 2**12)
                  good_reads += 1;
               else begin
                  bad_reads += 1;
                  errors += 1;
                  $display("%2d: expected %2h, got %2h", i, (comp + 1) % 2**12, sample[j]);
               end
            end
            last_sample = sample[5];
            //$display("%2d: %2h", i*3+0, sample[0]);
            //$display("%2d: %2h", i*3+1, sample[1]);
            //$display("%2d: %2h", i*3+2, sample[2]);
            //$display("%2d: %2h", i*3+3, sample[3]);
            //$display("%2d: %2h", i*3+4, sample[4]);
            //$display("%2d: %2h", i*3+5, sample[5]);
         end
      end

      $display("Done reading.");
      $display("Good reads: %d", good_reads);
      $display("Bad reads: %d", bad_reads);
      if (errors)
         $display("Simulation FAILED");
      else
         $display("Simulation passed");
      $finish;
   end


   // timeout thread:
   initial begin
      #(pCLK_PERIOD*pTIMEOUT_CYCLES);
      $display("Timeout reached.");
      $finish;
   end

   always #(pCLK_PERIOD/2) clk_usb = !clk_usb;

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

cwhusky_top U_dut (  
    .clk_usb            (clk_usb      ),
    .ADC_clk_fbp        (clk_usb      ),
    .ADC_clk_fbn        (clk_usb      ),
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
