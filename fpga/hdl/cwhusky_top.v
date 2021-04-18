`include "includes.v"
`timescale 1 ns / 1 ps
`default_nettype none

module cwhusky_top(  
    input wire         clk_usb,

    output wire        LED_CLK1FAIL,
    output wire        LED_CLK2FAIL,
    output wire        LED_ARMED,
    output wire        LED_CAP,

    /* FPGA - USB Interface */
    inout wire [7:0]    USB_Data,
    input wire [7:0]    USB_Addr,
    input wire          USB_RDn,
    input wire          USB_WRn,
    input wire          USB_CEn,
    input wire          USB_ALEn,
    output wire         USB_SPARE0,

    input wire          FPGA_BONUS1,
    input wire          FPGA_BONUS2,
    input wire          FPGA_BONUS3,
    input wire          FPGA_BONUS4,

    // ADC
    input wire          ADC_clk_fbp,
    input wire          ADC_clk_fbn,
    output wire         ADC_CLKP,
    output wire         ADC_CLKN,
    output wire         ADC_SCLK,
    output wire         ADC_SDATA,
    output wire         ADC_SEN,
    output wire         ADC_RESET,
    output wire         ADC_DFS,
    output wire         ADC_OE,
    input wire          ADC_OVR_SDOUT,
    input wire [5:0]    ADC_DP,
    input wire [5:0]    ADC_DN,

    // VGA
    output wire [4:0]   VMAG_D,
    output wire         VDBSPWM,

    // PLL
    input wire          PLL_STATUS,
    input wire          PLLFPGAP,
    input wire          PLLFPGAN,

    output wire [7:0]   USERIO_D,
    input  wire         USERIO_CLK,

    //input wire          FPGA_CCLK,
    input wire          FPGA_CDOUT, /* Input FROM SAM3U */
    output wire         FPGA_CDIN, /* Output TO SAM3U */

    input  wire         SAM_MOSI,
    output wire         SAM_MISO,
    input  wire         SAM_SPCK,
    input  wire         SAM_CS,

    /* XMEGA Programming - not used, but need to ensure line is floating */
    inout wire       target_PDID,
    inout wire       target_PDIC,

    /* Spare Lines - AVR Programming */
    output wire         target_nRST,
    input wire          target_MISO,
    output wire         target_MOSI,
    output wire         target_SCK,

    /* Target IO Interfaces */
    inout wire          target_io4, // Normally trigger
    inout wire          target_io3, // Normally Spare / SmartCard Comms
    inout wire          target_io2, // Normally RXD
    inout wire          target_io1, // Normally TXD / SmartCard Reset
    inout wire          target_hs1, // Clock from victim device
    inout wire          target_hs2, // Clock to victim device

    /*
    output wire         glitchout_highpwr, // high-speed glitch output
    output wire         glitchout_lowpwr, // high-speed glitch output 
    */
    output wire         target_poweron,

    output wire         FPGA_TRIGOUT, //trigger out MCX
    inout  wire         USBIOHS2  //clock MCX

    /* Various connections to USB Chip 
    input wire          USB_ser0_tx_i,
    output wire         USB_ser0_rx_o,

    input wire          USB_spi0_sck_i,
    input wire          USB_spi0_mosi_i,
    output wire         USB_spi0_miso_o,
    input wire          USB_spi0_cs0,
    input wire          USB_treset_i,
    
    input wire          USB_sc_rst,
    input wire          USB_sc_clk,
    input wire          USB_sc_aux1,
    input wire          USB_sc_aux2,
    input wire          USB_spi2_txd2,
    output wire         USB_spi2_rxd2,
    
    output wire         ext_mosi, //Pin 4 of external header
    input wire          ext_miso, //Pin 3 of external header
    output wire         ext_sck,  //Pin 2 of external header
    output wire         lcd_cs,
    output wire         lcd_dc,
    output wire         avr_cs
    */
    );

    parameter pBYTECNT_SIZE = 7;

   /* PDI Programming done from SAM, must float these wires
      or programming will fail from weak pull-down on FPGA */
   //assign XMEGA_PDID = 1'bZ;
   //assign XMEGA_PDIC = 1'bZ;
   
   //wire [35:0] cs_control0;
   //wire [63:0] ila_trigbus;

   // TEMPORARY, until I/Os are added / cleaned up:
   wire         ADC_clk_out;
   wire         glitchout_highpwr;
   wire         glitchout_lowpwr;
   wire         target_npower;
   wire         USB_treset_i; // ? came from SAM3U

   wire         reg_rst;

   wire reset_i = 0;

   wire clk_usb_buf;
   wire ADC_clk_fb;
   wire pll_fpga_clk;

   `ifdef __ICARUS__
      assign clk_usb_buf = clk_usb;
   `else
      IBUFG IBUFG_usb_inst (
         .O(clk_usb_buf),
         .I(clk_usb)
      );
   `endif

   wire cmdfifo_isout;
   wire [7:0] cmdfifo_din;
   wire [7:0] cmdfifo_dout;
   wire [pBYTECNT_SIZE-1:0]  reg_bytecnt;
   wire [7:0]   write_data;
   wire [7:0]   read_data;
   wire         reg_read;
   wire         reg_write;
   wire         reg_addrvalid;
   wire [7:0]   reg_address;

   wire [7:0] read_data_openadc;
   wire [7:0] read_data_cw;
   wire [7:0] read_data_adc;
   wire [7:0] read_data_glitch;
   assign read_data = read_data_openadc | read_data_cw | read_data_adc | read_data_glitch;

   wire ext_trigger;
   wire extclk_mux;
   wire clkgen, glitchclk;
   wire enable_avrprog;
   wire [11:0] ADC_data;

   wire fifo_error_flag;
   wire error_flag = fifo_error_flag; // TODO: add other sources as they get created
   wire fast_fifo_read;

   usb_reg_main #(
      .pBYTECNT_SIZE    (pBYTECNT_SIZE)
   ) U_usb_reg_main (
      .clk_usb          (clk_usb_buf), 
      .reset            (reg_rst),
      .cwusb_din        (cmdfifo_din), 
      .cwusb_dout       (cmdfifo_dout), 
      .cwusb_rdn        (USB_RDn), 
      .cwusb_wrn        (USB_WRn),
      .cwusb_cen        (USB_CEn),
      .cwusb_alen       (USB_ALEn),
      .cwusb_addr       (USB_Addr),
      .cwusb_isout      (cmdfifo_isout), 
      .fast_fifo_read   (fast_fifo_read),
      .reg_address      (reg_address), 
      .reg_bytecnt      (reg_bytecnt), 
      .reg_datao        (write_data), 
      .reg_datai        (read_data),
      .reg_read         (reg_read), 
      .reg_write        (reg_write), 
      .reg_addrvalid    (reg_addrvalid)
   );

   // TODO: temporary, for debug:
   assign USERIO_D[0] = reg_read;
   // synthesize a half-rate register read signal, so that my logic analyzer
   // can catch it:
   reg reg_read_half = 1'b0;
   reg reg_read_r;
   always @ (posedge clk_usb_buf) begin
      reg_read_r <= reg_read;
      if (reg_read & ~reg_read_r)
         reg_read_half <= ~reg_read_half;
   end
   assign USERIO_D[1] = reg_read_half;
   assign USERIO_D[7:2] = 7'bz;

   assign USB_Data = cmdfifo_isout ? cmdfifo_dout : 8'bZ;
   assign cmdfifo_din = USB_Data;


   reg [24:0] usb_hearbeat;
   always @(posedge clk_usb_buf) usb_hearbeat <= usb_hearbeat +  25'd1;

   wire LED_ADCDCMUnlock;
   wire LED_CLKGENDCMUnlock;

   // fast-flash red LEDs when some internal error has occurred:
   assign LED_CLK1FAIL = error_flag? usb_hearbeat[22] : LED_ADCDCMUnlock;
   assign LED_CLK2FAIL = error_flag? usb_hearbeat[22] : LED_CLKGENDCMUnlock;

   openadc_interface #(
        .pBYTECNT_SIZE  (pBYTECNT_SIZE)
   ) oadc (
        .reset_i                (reset_i),
        .clk_usb                (clk_usb_buf),
        .reset_o                (reg_rst),

        .LED_capture            (LED_CAP),
        .LED_armed              (LED_ARMED),
        .LED_ADCDCMUnlock       (LED_ADCDCMUnlock),
        .LED_CLKGENDCMUnlock    (LED_CLKGENDCMUnlock),
        .ADC_data               (ADC_data),
        .ADC_clk_out            (ADC_clk_out),
        .ADC_clk_feedback       (ADC_clk_fb),
        .pll_fpga_clk           (pll_fpga_clk),
        .PLL_STATUS             (PLL_STATUS),
        .DUT_CLK_i              (extclk_mux),
        .DUT_trigger_i          (ext_trigger),
        .amp_gain               (VDBSPWM),
        .amp_hilo               (),
        .clkgen                 (clkgen),

        .reg_address            (reg_address),
        .reg_bytecnt            (reg_bytecnt), 
        .reg_datao              (read_data_openadc), 
        .reg_datai              (write_data), 
        .reg_read               (reg_read), 
        .reg_write              (reg_write), 
        .reg_addrvalid          (reg_addrvalid),
        .fast_fifo_read         (fast_fifo_read),

        .fifo_error_flag        (fifo_error_flag),
        .stream_segment_available (USB_SPARE0)
   );

   wire enable_output_nrst;
   wire output_nrst;
   wire enable_output_pdid;
   wire output_pdid;
   wire enable_output_pdic;
   wire output_pdic;

   reg_husky_adc #(
        .pBYTECNT_SIZE  (pBYTECNT_SIZE)
   ) U_reg_husky_adc (
        .reset_i        (reg_rst),
        .clk_usb        (clk_usb_buf),
        .reg_address    (reg_address[5:0]), 
        .reg_bytecnt    (reg_bytecnt), 
        .reg_datao      (read_data_adc), 
        .reg_datai      (write_data), 
        .reg_read       (reg_read), 
        .reg_write      (reg_write), 
        .reg_addrvalid  (reg_addrvalid), 

        .ADC_RESET      (ADC_RESET    ),
        .ADC_SDATA      (ADC_SDATA    ),
        .ADC_SEN        (ADC_SEN      ),
        .ADC_DFS        (ADC_DFS      ),
        .ADC_OE         (ADC_OE       ),
        .ADC_SCLK       (ADC_SCLK     ),
        .ADC_OVR_SDOUT  (ADC_OVR_SDOUT),
        .VMAG_D         (VMAG_D)
   );


   reg_chipwhisperer  #(
        .pBYTECNT_SIZE  (pBYTECNT_SIZE)
   ) reg_chipwhisperer (
        .reset_i(reg_rst),
        .clk_usb(clk_usb_buf),
        .reg_address(reg_address[5:0]), 
        .reg_bytecnt(reg_bytecnt), 
        .reg_datao(read_data_cw), 
        .reg_datai(write_data), 
        .reg_read(reg_read), 
        .reg_write(reg_write), 
        .reg_addrvalid(reg_addrvalid), 

        .target_hs1(target_hs1),
        .target_hs2(target_hs2),
        .extclk_o(extclk_mux),
        .trigger_io1_i(target_io1),
        .trigger_io2_i(target_io2),
        .trigger_io3_i(target_io3),
        .trigger_io4_i(target_io4),
        //.trigger_ext_o(advio_trigger_line), // XXX TODO?: cw1200 has this
        .trigger_advio_i(1'b0),
        .trigger_anapattern_i(1'b0),
        .trigger_decodedio_i(1'b0),
        .clkgen(clkgen),
        .glitchclk(glitchclk),

        .targetio1_io(target_io1),
        .targetio2_io(target_io2),
        .targetio3_io(target_io3),
        .targetio4_io(target_io4),

        .hsglitcha_o(glitchout_highpwr),
        .hsglitchb_o(glitchout_lowpwr),

        .enable_avrprog(enable_avrprog),

        .enable_output_nrst(enable_output_nrst),
        .output_nrst(output_nrst),
        .enable_output_pdid(enable_output_pdid),
        .output_pdid(output_pdid),
        .enable_output_pdic(enable_output_pdic),
        .output_pdic(output_pdic),

        .uart_tx_i(FPGA_CDOUT),
        .uart_rx_o(FPGA_CDIN),
        .usi_out_i(1'b0),
        .usi_in_o(),
        .targetpower_off(target_npower),

        .trigger_o(ext_trigger)
   );


   reg_clockglitch #(
        .pBYTECNT_SIZE  (pBYTECNT_SIZE)
   ) reg_clockglitch (
        .reset_i        (reg_rst),
        .clk_usb        (clk_usb_buf),
        .reg_address    (reg_address[5:0]), 
        .reg_bytecnt    (reg_bytecnt), 
        .reg_datao      (read_data_glitch), 
        .reg_datai      (write_data), 
        .reg_read       (reg_read), 
        .reg_write      (reg_write), 
        .reg_addrvalid  (reg_addrvalid), 
        .target_hs1     (target_hs1),
        //.clkgen         (clkgen),
        .clkgen         (pll_fpga_clk),
        //.glitchclk      (glitchclk),
        .glitchclk      (), // TODO-temp
        .exttrigger     (ext_trigger)
   );
   assign glitchclk = 1'b0; // TODO-temp

   assign FPGA_TRIGOUT = ext_trigger;
   //assign FPGA_TRIGOUT = 1'b0;

   wire target_highz = target_npower;
   assign target_poweron = ~target_npower;

   assign target_PDID = (target_highz) ? 1'bZ :
                        (enable_output_pdid) ? output_pdid : 1'bZ;

   assign target_PDIC = (target_highz) ? 1'bZ:
                        (enable_output_pdic) ? output_pdic : 1'bZ;

   assign target_nRST = (target_highz) ? 1'bZ :
                        (enable_avrprog) ? 1'b0 : // USB_treset_i : TODO?
                        (enable_output_nrst) ? output_nrst : 1'bZ;

   assign target_MOSI = (target_highz) ? 1'bZ :
                        (enable_avrprog) ? SAM_MOSI : 1'bZ;

   assign target_SCK = (target_highz) ? 1'bZ :
                       (enable_avrprog) ? SAM_SPCK : 1'bZ;

   assign SAM_MISO = (enable_avrprog) ? target_MISO : 1'bZ; //ext_miso;


   // generate ADC output differential clock
   `ifdef __ICARUS__
      assign ADC_CLKP = ADC_clk_out;
      assign ADC_CLKN = ADC_clk_out;

   `else
      wire adc_clk_out_oddr;
      ODDR  #(
         .DDR_CLK_EDGE     ("OPPOSITE_EDGE"),
         .INIT             (1'b0),
         .SRTYPE           ("SYNC")
      ) U_ODDR_adc_clk_out (
         .Q                (adc_clk_out_oddr),
         .C                (ADC_clk_out),
         .CE               (1'b1),
         .D1               (1'b1),
         .D2               (1'b0),
         .R                (1'b0),
         .S                (1'b0)
      );

      OBUFDS #(
         // TODO: are these the best settings?
         .IOSTANDARD       ("LVDS_25"),
         .SLEW             ("FAST")
      ) U_OBUFDS_adc_clk_out (
         .O                (ADC_CLKP),
         .OB               (ADC_CLKN),
         .I                (adc_clk_out_oddr)
      );
   `endif


   // take in ADC input differential clock
   `ifdef __ICARUS__
      assign ADC_clk_fb = ADC_clk_fbp;

   `else
      IBUFDS #(
         .DIFF_TERM        ("FALSE"),
         .IBUF_LOW_PWR     ("FALSE"),
         .IOSTANDARD       ("LVDS_25")
      ) U_IBUFDS_adc_clk_fb (
         .I                (ADC_clk_fbp),
         .IB               (ADC_clk_fbn),
         .O                (ADC_clk_fb)
      );
   `endif


   // take in PLL input differential clock
   `ifdef __ICARUS__
      assign pll_fpga_clk = PLLFPGAP;

   `else
      IBUFDS #(
         .DIFF_TERM        ("FALSE"),
         .IBUF_LOW_PWR     ("FALSE"),
         .IOSTANDARD       ("LVDS_25")
      ) U_IBUFDS_pll_fpga_clk (
         .I                (PLLFPGAP),
         .IB               (PLLFPGAN),
         .O                (pll_fpga_clk)
      );
   `endif



   `ifdef __ICARUS__
      assign ADC_data = {ADC_DP, ADC_DN};
   `else
   wire [5:0] ADC_D;
   genvar adc_index;
   generate 
      for (adc_index = 0; adc_index < 6; adc_index = adc_index + 1) begin: gen_adc_data
         // TODO: are these the best settings?
         IBUFDS #(
            .DIFF_TERM          ("FALSE"),
            .IBUF_LOW_PWR       ("FALSE"),
            .IOSTANDARD         ("LVDS_25")
         ) U_adc_ibufds (
            .O                  (ADC_D[adc_index]),
            .I                  (ADC_DP[adc_index]),
            .IB                 (ADC_DN[adc_index])
         );

         IDDR #(
            .DDR_CLK_EDGE     ("OPPOSITE_EDGE"),
            .INIT_Q1          (0),
            .INIT_Q2          (0),
            .SRTYPE           ("SYNC")
         ) U_adc_iddr (
            .Q1               (ADC_data[adc_index*2]),
            .Q2               (ADC_data[adc_index*2+1]),
            .D                (ADC_D[adc_index]),
            .CE               (1'b1),
            .C                (ADC_clk_fb),
            .S                (1'b0),
            .R                (1'b0)
         );
      end
   endgenerate
   `endif



endmodule
`default_nettype wire
