set_property IOSTANDARD LVCMOS33 [get_ports *]
set_property IOSTANDARD LVCMOS25 [get_ports ADC*]
set_property IOSTANDARD LVDS_25 [get_ports ADC_clk_fb*]
set_property IOSTANDARD LVDS_25 [get_ports ADC_CLK*]
set_property IOSTANDARD LVDS_25 [get_ports ADC_D*]
set_property IOSTANDARD LVCMOS25 [get_ports ADC_DFS]
set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]
#set_property CONFIG_VOLTAGE 2.5 [current_design]


create_clock -period 10.400 -name clk_usb -waveform {0.000 5.200} [get_nets clk_usb]
create_clock -period 5.000 -name ADC_clk_fb -waveform {0.000 2.500} [get_nets ADC_clk_fb]

# TODO: these are temporary
set_clock_groups -asynchronous \
                 -group [get_clocks clk_usb] \
                 -group [get_clocks ADC_clk_times4]

set_clock_groups -asynchronous \
                 -group [get_clocks clk_usb] \
                 -group [get_clocks ADC_clk_fb]

set_clock_groups -asynchronous \
                 -group [get_clocks clk_usb] \
                 -group [get_clocks ADC_clk]

set_clock_groups -asynchronous \
                 -group [get_clocks ADC_clk] \
                 -group [get_clocks ADC_clk_times4]



# *****************************************************************************

# LEDs
set_property DRIVE 8 [get_ports LED_CLK1FAIL]
set_property DRIVE 8 [get_ports LED_CLK2FAIL]
set_property DRIVE 8 [get_ports LED_ARMED]
set_property DRIVE 8 [get_ports LED_CAP]

set_property PACKAGE_PIN C7 [get_ports LED_CLK1FAIL]
set_property PACKAGE_PIN C6 [get_ports LED_CLK2FAIL]
set_property PACKAGE_PIN D3 [get_ports LED_ARMED]
set_property PACKAGE_PIN C3 [get_ports LED_CAP]

# USB:
set_property PACKAGE_PIN D4 [get_ports clk_usb]
set_property PACKAGE_PIN L3 [get_ports {USB_Data[7]}]
set_property PACKAGE_PIN L2 [get_ports {USB_Data[6]}]
set_property PACKAGE_PIN B6 [get_ports {USB_Data[5]}]
set_property PACKAGE_PIN G2 [get_ports {USB_Data[4]}]
set_property PACKAGE_PIN G1 [get_ports {USB_Data[3]}]
set_property PACKAGE_PIN E2 [get_ports {USB_Data[2]}]
set_property PACKAGE_PIN A7 [get_ports {USB_Data[1]}]
set_property PACKAGE_PIN B7 [get_ports {USB_Data[0]}]

#set_property PACKAGE_PIN H1 [get_ports {USB_Addr[7]}]
#set_property PACKAGE_PIN K3 [get_ports {USB_Addr[6]}]
#set_property PACKAGE_PIN K1 [get_ports {USB_Addr[5]}]
#set_property PACKAGE_PIN E1 [get_ports {USB_Addr[4]}]
#set_property PACKAGE_PIN D1 [get_ports {USB_Addr[3]}]
#set_property PACKAGE_PIN C1 [get_ports {USB_Addr[2]}]
#set_property PACKAGE_PIN K2 [get_ports {USB_Addr[1]}]
#set_property PACKAGE_PIN J1 [get_ports {USB_Addr[0]}]

set_property PACKAGE_PIN K2 [get_ports {USB_Addr[7]}]
set_property PACKAGE_PIN J1 [get_ports {USB_Addr[6]}]
set_property PACKAGE_PIN H1 [get_ports {USB_Addr[5]}]
set_property PACKAGE_PIN K3 [get_ports {USB_Addr[4]}]
set_property PACKAGE_PIN K1 [get_ports {USB_Addr[3]}]
set_property PACKAGE_PIN E1 [get_ports {USB_Addr[2]}]
set_property PACKAGE_PIN D1 [get_ports {USB_Addr[1]}]
set_property PACKAGE_PIN C1 [get_ports {USB_Addr[0]}]


set_property PACKAGE_PIN A5 [get_ports USB_RDn]
set_property PACKAGE_PIN A4 [get_ports USB_WRn]
set_property PACKAGE_PIN B4 [get_ports USB_CEn]
set_property PACKAGE_PIN B5 [get_ports USB_ALEn]

set_property PACKAGE_PIN H2 [get_ports USB_SPARE0]

set_property PACKAGE_PIN R1 [get_ports FPGA_BONUS1]
set_property PACKAGE_PIN P1 [get_ports FPGA_BONUS2]
set_property PACKAGE_PIN N1 [get_ports FPGA_BONUS3]
set_property PACKAGE_PIN N2 [get_ports FPGA_BONUS4]

# 20-pin connector:
set_property PACKAGE_PIN T2 [get_ports target_PDID]
set_property PACKAGE_PIN N3 [get_ports target_SCK]
set_property PACKAGE_PIN R2 [get_ports target_io2]
set_property PACKAGE_PIN B2 [get_ports target_MISO]
set_property PACKAGE_PIN B1 [get_ports target_io1]
set_property PACKAGE_PIN A3 [get_ports target_hs2]
set_property PACKAGE_PIN T4 [get_ports target_io4]
set_property PACKAGE_PIN T3 [get_ports target_io3]
set_property PACKAGE_PIN P3 [get_ports target_PDIC]
set_property PACKAGE_PIN C2 [get_ports target_MOSI]
set_property PACKAGE_PIN A2 [get_ports target_nRST]
set_property PACKAGE_PIN F5 [get_ports target_hs1]

# USERIO:
set_property PACKAGE_PIN T15 [get_ports {USERIO_D[0]}]
set_property PACKAGE_PIN T14 [get_ports {USERIO_D[1]}]
set_property PACKAGE_PIN R13 [get_ports {USERIO_D[2]}]
set_property PACKAGE_PIN T13 [get_ports {USERIO_D[3]}]
set_property PACKAGE_PIN R12 [get_ports {USERIO_D[4]}]
set_property PACKAGE_PIN T12 [get_ports {USERIO_D[5]}]
set_property PACKAGE_PIN R11 [get_ports {USERIO_D[6]}]
set_property PACKAGE_PIN T10 [get_ports {USERIO_D[7]}]
set_property PACKAGE_PIN N12 [get_ports USERIO_CLK]


# MCX:
set_property PACKAGE_PIN R15 [get_ports FPGA_TRIGOUT]
set_property PACKAGE_PIN N14 [get_ports USBIOHS2]

# SAM3U - SPI
set_property PACKAGE_PIN T7 [get_ports SAM_MOSI]
set_property PACKAGE_PIN R7 [get_ports SAM_MISO]
set_property PACKAGE_PIN T8 [get_ports SAM_SPCK]
set_property PACKAGE_PIN T9 [get_ports SAM_CS]

#SAM3U - USART (config pins)
set_property PACKAGE_PIN J13 [get_ports FPGA_CDIN]
set_property PACKAGE_PIN J14 [get_ports FPGA_CDOUT]

#ADC - control
set_property PACKAGE_PIN A9 [get_ports ADC_SCLK]
set_property PACKAGE_PIN B9 [get_ports ADC_SDATA]
set_property PACKAGE_PIN A8 [get_ports ADC_SEN]
set_property PACKAGE_PIN A10 [get_ports ADC_RESET]
set_property PACKAGE_PIN G12 [get_ports ADC_DFS]
set_property PACKAGE_PIN H12 [get_ports ADC_OE]
set_property PACKAGE_PIN G16 [get_ports ADC_OVR_SDOUT]

#set_property PACKAGE_PIN B12 [get_ports ADC_D0P]
#set_property PACKAGE_PIN A12 [get_ports ADC_D0N]
#set_property PACKAGE_PIN A13 [get_ports ADC_D2P]
#set_property PACKAGE_PIN A14 [get_ports ADC_D2N]
#set_property PACKAGE_PIN B15 [get_ports ADC_D4P]
#set_property PACKAGE_PIN A15 [get_ports ADC_D4N]
#set_property PACKAGE_PIN C16 [get_ports ADC_D6P]
#set_property PACKAGE_PIN B16 [get_ports ADC_D6N]
#set_property PACKAGE_PIN D14 [get_ports ADC_D8P]
#set_property PACKAGE_PIN D15 [get_ports ADC_D8N]
#set_property PACKAGE_PIN F15 [get_ports ADC_D10P]
#set_property PACKAGE_PIN E15 [get_ports ADC_D10N]

set_property PACKAGE_PIN B12 [get_ports ADC_DP[0]]
set_property PACKAGE_PIN A12 [get_ports ADC_DN[0]]
set_property PACKAGE_PIN A13 [get_ports ADC_DP[1]]
set_property PACKAGE_PIN A14 [get_ports ADC_DN[1]]
set_property PACKAGE_PIN B15 [get_ports ADC_DP[2]]
set_property PACKAGE_PIN A15 [get_ports ADC_DN[2]]
set_property PACKAGE_PIN C16 [get_ports ADC_DP[3]]
set_property PACKAGE_PIN B16 [get_ports ADC_DN[3]]
set_property PACKAGE_PIN D14 [get_ports ADC_DP[4]]
set_property PACKAGE_PIN D15 [get_ports ADC_DN[4]]
set_property PACKAGE_PIN F15 [get_ports ADC_DP[5]]
set_property PACKAGE_PIN E15 [get_ports ADC_DN[5]]

#VGA:
set_property PACKAGE_PIN L15 [get_ports VMAG_D[4]]
set_property PACKAGE_PIN M16 [get_ports VMAG_D[3]]
set_property PACKAGE_PIN M15 [get_ports VMAG_D[2]]
set_property PACKAGE_PIN N16 [get_ports VMAG_D[1]]
set_property PACKAGE_PIN P16 [get_ports VMAG_D[0]]
set_property PACKAGE_PIN R16 [get_ports VDBSPWM]


# output from FPGA:
set_property PACKAGE_PIN J15 [get_ports ADC_CLKP]
set_property PACKAGE_PIN J16 [get_ports ADC_CLKN]

# input to FPGA:
set_property PACKAGE_PIN E12 [get_ports ADC_clk_fbp]
set_property PACKAGE_PIN E13 [get_ports ADC_clk_fbn]


# No spec for these, seems sensible:
set_input_delay -clock clk_usb 2.000 [get_ports USB_ALEn]
set_input_delay -clock clk_usb 2.000 [get_ports USB_CEn]
set_input_delay -clock clk_usb 2.000 [get_ports USB_RDn]
set_input_delay -clock clk_usb 2.000 [get_ports USB_WRn]
set_input_delay -clock clk_usb 2.000 [get_ports USB_Data]
set_input_delay -clock clk_usb 2.000 [get_ports USB_Addr]

# Not from any spec, but the result is no timing violations and reads work:
set_output_delay -clock clk_usb -1.200 [get_ports USB_Data]

# TODO: lots of constraints missing still


set_property BITSTREAM.CONFIG.USR_ACCESS TIMESTAMP [current_design]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk_usb_buf_BUFG]
