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
    //input wire          USB_ALEn,
    input wire          USB_SPARE0,
    input wire          USB_SPARE1,

    input wire          FPGA_BONUS1,
    input wire          FPGA_BONUS2,
    input wire          FPGA_BONUS3,
    input wire          FPGA_BONUS4,

    //input wire          ADC_clk_fb,

    /* ADC Interface TODO-later
    input wire [9:0]    ADC_Data,
    input wire          ADC_OR,         // XXX unused
    output wire         ADC_clk_out,
    output wire         amp_gain,
    output wire         amp_hilo,

    TODO: 
    VMAG_Dx
    USERIO
    VDBSPWM (to AD8330)
    */

    output wire         ADC_SCLK,
    output wire         ADC_SDATA,
    output wire         ADC_SEN,
    output wire         ADC_RESET,
    output wire         ADC_DFS,
    output wire         ADC_OE,
    input wire          ADC_OVR_SDOUT,

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
    output wire         target_npower,
    */

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
   wire [11:0]  ADC_DDR_data;
   wire         ADC_clk_out;
   wire         amp_gain;
   wire         amp_hilo;
   wire         glitchout_highpwr;
   wire         glitchout_lowpwr;
   wire         target_npower;
   wire         USB_treset_i; // ? came from SAM3U

   wire         reg_rst;

   // TODO: cleaup
   wire reset_i;
   assign reset_i = 0;

   wire reset_intermediate;
   wire clk_usb_buf;

   `ifdef __ICARUS__
   assign clk_usb_buf = clk_usb;
   `else
   IBUFG IBUFG_inst (
        .O(clk_usb_buf),
        .I(clk_usb) );
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
   wire [7:0] read_data_glitch;
   assign read_data = read_data_openadc | read_data_cw | read_data_glitch;

   wire ext_trigger;
   wire extclk_mux;
   wire clkgen, glitchclk;
   wire enable_avrprog;

   usb_reg_main #(
      .pBYTECNT_SIZE    (pBYTECNT_SIZE)
   ) U_usb_reg_main (
      .clk_usb          (clk_usb_buf), 
      .cwusb_din        (cmdfifo_din), 
      .cwusb_dout       (cmdfifo_dout), 
      .cwusb_rdn        (USB_RDn), 
      .cwusb_wrn        (USB_WRn),
      .cwusb_cen        (USB_CEn),
      .cwusb_addr       (USB_Addr),
      .cwusb_isout      (cmdfifo_isout), 
      .I_drive_data     (1'b0),         // TODO?
      .reg_address      (reg_address), 
      .reg_bytecnt      (reg_bytecnt), 
      .reg_datao        (write_data), 
      .reg_datai        (read_data),
      .reg_read         (reg_read), 
      .reg_write        (reg_write), 
      .reg_addrvalid    (reg_addrvalid)
   );

   assign USB_Data = cmdfifo_isout ? cmdfifo_dout : 8'bZ;
   assign cmdfifo_din = USB_Data;


   // TODO: more hearbeats for initial bringup
   reg [24:0] usb_hearbeat;
   always @(posedge clk_usb_buf) usb_hearbeat <= usb_hearbeat +  25'd1;

   reg [24:0] clkgen_heartbeat;
   always @(posedge clkgen) clkgen_heartbeat <= clkgen_heartbeat +  25'd1;

   assign LED_ARMED = usb_hearbeat[24];
   assign LED_CAP = clkgen_heartbeat[24];

   //assign LED_CLK1FAIL = usb_hearbeat[23];
   //assign LED_CLK2FAIL = clkgen_heartbeat[23];
   wire ADC_clk_fb;

   openadc_interface #(
        .pBYTECNT_SIZE  (pBYTECNT_SIZE)
   ) oadc (
        .reset_i(reset_i),
        .clk_usb(clk_usb_buf),
        .reset_o(reg_rst),

        //.LED_hbeat(LED_CAP),
        //.LED_armed(LED_ARMED),
        .LED_hbeat(),
        .LED_armed(),
        .LED_ADCDCMUnlock(LED_CLK1FAIL),
        .LED_CLKGENDCMUnlock(LED_CLK2FAIL),
        //.LED_ADCDCMUnlock(),
        //.LED_CLKGENDCMUnlock(),
        .ADC_DDR_data(ADC_DDR_data),
        .ADC_clk_out(ADC_clk_out),
        .ADC_clk_feedback(ADC_clk_fb),
        .DUT_CLK_i(extclk_mux),
        .DUT_trigger_i(ext_trigger),
        .amp_gain(amp_gain),
        .amp_hilo(amp_hilo),
        .clkgen(clkgen),

        .reg_address(reg_address),
        .reg_bytecnt(reg_bytecnt), 
        .reg_datao(read_data_openadc), 
        .reg_datai(write_data), 
        .reg_read(reg_read), 
        .reg_write(reg_write), 
        .reg_addrvalid(reg_addrvalid) 
   );

   wire enable_output_nrst;
   wire output_nrst;
   wire enable_output_pdid;
   wire output_pdid;
   wire enable_output_pdic;
   wire output_pdic;

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
        .adc_sample_clk(1'b0), // XXX TODO? this came from openadc_interface, but it wasn't defined
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

        .uart_tx_i(1'b0),
        .uart_rx_o(),
        .usi_out_i(1'b0),
        .usi_in_o(),
        .targetpower_off(target_npower),

        //.trigger_o(ext_trigger)
        .trigger_o()
   );
   // TODO-TEMPORARY: otherwise comb loop error?
   assign ext_trigger = 1'b0;


   reg_clockglitch #(
        .pBYTECNT_SIZE  (pBYTECNT_SIZE)
   ) reg_clockglitch (
        .reset_i(reg_rst),
        .clk_usb(clk_usb_buf),
        .reg_address(reg_address[5:0]), 
        .reg_bytecnt(reg_bytecnt), 
        .reg_datao(read_data_glitch), 
        .reg_datai(write_data), 
        .reg_read(reg_read), 
        .reg_write(reg_write), 
        .reg_addrvalid(reg_addrvalid), 
        .target_hs1(target_hs1),
        .clkgen(clkgen),
        .glitchclk(glitchclk),
        .exttrigger(ext_trigger)
   );

   assign FPGA_TRIGOUT = ext_trigger;

   wire target_highz = target_npower;

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


   /*
   assign ila_trigbus[7:0] = USB_D;
   assign ila_trigbus[15:8] = USB_Addr;
   assign ila_trigbus[16] = USB_RDn;
   assign ila_trigbus[17] = USB_WRn;
   assign ila_trigbus[18] = USB_ALEn;
   assign ila_trigbus[19] = USB_CEn;

   coregen_icon csicon (
    .CONTROL0(cs_control0) // INOUT BUS [35:0]
   );

   coregen_ila csila (
    .CONTROL(cs_control0), // INOUT BUS [35:0]
    .CLK(clk_usb), // IN
    .TRIG0(ila_trigbus) // IN BUS [63:0]
   );
   */

endmodule
`default_nettype wire
