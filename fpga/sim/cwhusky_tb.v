`timescale 1 ns / 1 ps
`default_nettype none

module cwhusky_tb();


   parameter pCLK_PERIOD = 10;
   parameter pTIMEOUT_CYCLES = 2000;
   parameter pADDR_WIDTH = 8;

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
   int i;


   // initialization thread:
   initial begin
      $dumpfile("results/cwhusky_tb.fst");
      $dumpvars(0, cwhusky_tb);
      clk_usb = 0;
      usb_addr = 0;
      usb_rdn = 1;
      usb_wrn = 1;
      usb_cen = 1;

      #(pCLK_PERIOD*100);

      // manually reset:
      write_1byte('h1, 8'h0);
      write_1byte('h1, 8'h1);
      write_1byte('h1, 8'h0);
      
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

      write_1byte('h1, 8'h8); // arm
      write_1byte('h1, 8'h48); // trigger now

      #(pCLK_PERIOD*1000);
      rw_lots_bytes('d3);
      for (i = 0; i < 20; i = i + 1) begin
         read_next_byte(rdata);
         $display("%2d: %2h", i, rdata);
      end

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
