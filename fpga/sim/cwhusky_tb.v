`timescale 1 ns / 1 ps
`default_nettype none

module cwhusky_tb();


   parameter pCLK_PERIOD = 10;
   parameter pTIMEOUT_CYCLES = 10000;
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


   // initialization thread:
   initial begin
      $dumpfile("results/cwhusky_tb.fst");
      $dumpvars(0, cwhusky_tb);
      clk_usb = 0;
      usb_addr = 0;
      usb_rdn = 1;
      usb_wrn = 1;
      usb_cen = 1;

      //#(pCLK_PERIOD*10) reset = 1;
      //#(pCLK_PERIOD*10) reset = 0;
      #(pCLK_PERIOD*100);
      write_1byte('h4, 8'ha5);
      read_1byte('h4, rdata);
      $display("Got %h", rdata);

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
    .LED_CLK1FAIL       (LED_CLK1FAIL ),
    .LED_CLK2FAIL       (LED_CLK2FAIL ),
    .LED_ARMED          (LED_ARMED    ),
    .LED_CAP            (LED_CAP      ),
    .USB_Data           (usb_data     ),
    .USB_Addr           (usb_addr     ),
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
    .USBIOHS2           (USBIOHS2     )
);


endmodule
`default_nettype wire
