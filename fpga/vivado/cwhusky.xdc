set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]


create_clock -period 10.400 -name clk_usb -waveform {0.000 5.200} [get_nets clk_usb]
create_clock -period 5.000 -name ADC_clk_fb -waveform {0.000 2.500} [get_nets ADC_clk_fb]
create_clock -period 5.000 -name pll_fpga_clk -waveform {0.000 2.500} [get_nets pll_fpga_clk]

create_clock -period 20.000 -name target_hs1 -waveform {0.000 10.000} [get_nets target_hs1]
create_clock -period 20.000 -name USBIOHS2 -waveform {0.000 10.500} [get_nets USBIOHS2]

create_clock -period 40.000 -name TRACECLOCK -waveform {0.000 20.000} [get_nets USERIO_CLK_IBUF]

# avoid multiple_clock analysis problems: 
# (these are critical to avoiding HUGE increase in implementation runtime; 5 minutes becomes 24 hours!)
set_case_analysis 0 [get_pins oadc/genclocks/clkdcm_mux/S]
set_case_analysis 0 [get_pins oadc/genclocks/clkgenfx_mux/S]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets oadc/genclocks/U_clkgen/inst/clk_out1]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {USERIO_CLK_IBUF}]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {U_trace_top/VCC_2}]
set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets U_trace_top/fe_clk_pre]

# TODO - needed if putting IDELAY on TRACECLOCK:
#set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets reg_clockglitch/mux1out]
#set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets reg_la/mux1out]

set_case_analysis 1 [get_pins reg_clockglitch/sourceclk_mux1/S]
set_case_analysis 0 [get_pins reg_clockglitch/sourceclk_mux2/S]

set_case_analysis 1 [get_pins reg_la/sourceclk_mux1/S]
set_case_analysis 0 [get_pins reg_la/sourceclk_mux2/S]

create_generated_clock -name fe_clk -source [get_pins U_trace_top/U_fe_clock_mux2/I1] -combinational [get_pins U_trace_top/U_fe_clock_mux2/O]
set_case_analysis 1 [get_pins U_trace_top/U_fe_clock_mux2/S]

set_case_analysis 1 [get_pins U_fifo_clk_mux/S]

# These are needed to meet timing on USB_Data:
set_max_delay 15 -through [get_pins USB_Data_IOBUF*inst/T]
set_max_delay 15 -through [get_pins U_usb_reg_main/reg_address_reg*/Q]
set_max_delay 15 -through [get_pins oadc/U_fifo/fifo_read_count_reg*/Q]
set_max_delay 15 -through [get_pins oadc/U_reg_openadc_adcfifo/fast_fifo_read_mode_reg/Q]

set_clock_groups -asynchronous \
                 -group [get_clocks clk_usb ] \
                 -group [get_clocks target_hs1]

set_clock_groups -asynchronous \
                 -group [get_clocks clk_usb ] \
                 -group [get_clocks USBIOHS2]

set_clock_groups -asynchronous \
                 -group [get_clocks target_hs1 ] \
                 -group [get_clocks USBIOHS2]

set_clock_groups -asynchronous \
                 -group [get_clocks {clk_usb target_hs1 USBIOHS2} ] \
                 -group [get_clocks ADC_clk_fb]


set_clock_groups -asynchronous \
                 -group [get_clocks {clk_usb target_hs1 USBIOHS2} ] \
                 -group [get_clocks pll_fpga_clk]

set_clock_groups -asynchronous \
                 -group [get_clocks pll_fpga_clk] \
                 -group [get_clocks glitch_mmcm1_clk_out*]

set_clock_groups -asynchronous \
                 -group [get_clocks {clk_usb target_hs1 USBIOHS2} ] \
                 -group [get_clocks glitch_mmcm1_clk_out*]

set_clock_groups -asynchronous \
                 -group [get_clocks {clk_usb target_hs1 USBIOHS2} ] \
                 -group [get_clocks glitch_mmcm2_clk_out*]

set_clock_groups -asynchronous \
                 -group [get_clocks observer_clk*] \
                 -group [get_clocks {clk_usb target_hs1 USBIOHS2} ]

set_clock_groups -asynchronous \
                 -group [get_clocks observer_clk*] \
                 -group [get_clocks pll_fpga_clk]

set_clock_groups -asynchronous \
                 -group [get_clocks observer_clk*] \
                 -group [get_clocks glitch_mmcm1_clk_out*]

set_clock_groups -asynchronous \
                 -group [get_clocks observer_clk*] \
                 -group [get_clocks glitch_mmcm2_clk_out*]

set_clock_groups -asynchronous \
                 -group [get_clocks observer_clk*] \
                 -group [get_clocks ADC_clk_fb]

set_clock_groups -asynchronous \
                 -group [get_clocks TRACECLOCK ] \
                 -group [get_clocks {clk_usb USBIOHS2 observer_clk target_hs1 fe_clk}]

set_clock_groups -asynchronous \
                 -group [get_clocks fe_clk ] \
                 -group [get_clocks {clk_usb observer_clk ADC_clk_fb pll_fpga_clk}]


# include below if FPGA_CLKGEN:

set_clock_groups -asynchronous \
                 -group [get_clocks {clk_usb target_hs1 USBIOHS2} ] \
                 -group [get_clocks ADC_clk_times4]

set_clock_groups -asynchronous \
                 -group [get_clocks {clk_usb target_hs1 USBIOHS2} ] \
                 -group [get_clocks ADC_clk]

set_clock_groups -asynchronous \
                 -group [get_clocks ADC_clk] \
                 -group [get_clocks ADC_clk_times4]

set_clock_groups -asynchronous \
                 -group [get_clocks clk_out1_MMCM_clkgen] \
                 -group [get_clocks {clk_usb target_hs1 USBIOHS2} ]

set_clock_groups -asynchronous \
                 -group [get_clocks clk_out1_MMCM_clkgen] \
                 -group [get_clocks pll_fpga_clk]

set_clock_groups -asynchronous \
                 -group [get_clocks observer_clk] \
                 -group [get_clocks clk_out1_MMCM_clkgen]

set_clock_groups -asynchronous \
                 -group [get_clocks glitch_mmcm1_clk_out*] \
                 -group [get_clocks clk_out1_MMCM_clkgen]


# *****************************************************************************

# LEDs
set_property -dict { PACKAGE_PIN C7  DRIVE 8  IOSTANDARD LVCMOS33 } [get_ports LED_ADC]
set_property -dict { PACKAGE_PIN C6  DRIVE 8  IOSTANDARD LVCMOS33 } [get_ports LED_GLITCH]
set_property -dict { PACKAGE_PIN D3  DRIVE 8  IOSTANDARD LVCMOS33 } [get_ports LED_ARMED]
set_property -dict { PACKAGE_PIN C3  DRIVE 8  IOSTANDARD LVCMOS33 } [get_ports LED_CAP]

# USB:
set_property -dict { PACKAGE_PIN D4  IOSTANDARD LVCMOS33 } [get_ports clk_usb]
set_property -dict { PACKAGE_PIN L3  IOSTANDARD LVCMOS33 } [get_ports {USB_Data[7]}]
set_property -dict { PACKAGE_PIN L2  IOSTANDARD LVCMOS33 } [get_ports {USB_Data[6]}]
set_property -dict { PACKAGE_PIN B6  IOSTANDARD LVCMOS33 } [get_ports {USB_Data[5]}]
set_property -dict { PACKAGE_PIN G2  IOSTANDARD LVCMOS33 } [get_ports {USB_Data[4]}]
set_property -dict { PACKAGE_PIN G1  IOSTANDARD LVCMOS33 } [get_ports {USB_Data[3]}]
set_property -dict { PACKAGE_PIN E2  IOSTANDARD LVCMOS33 } [get_ports {USB_Data[2]}]
set_property -dict { PACKAGE_PIN A7  IOSTANDARD LVCMOS33 } [get_ports {USB_Data[1]}]
set_property -dict { PACKAGE_PIN B7  IOSTANDARD LVCMOS33 } [get_ports {USB_Data[0]}]

set_property -dict { PACKAGE_PIN K2  IOSTANDARD LVCMOS33 } [get_ports {USB_Addr[7]}]
set_property -dict { PACKAGE_PIN J1  IOSTANDARD LVCMOS33 } [get_ports {USB_Addr[6]}]
set_property -dict { PACKAGE_PIN H1  IOSTANDARD LVCMOS33 } [get_ports {USB_Addr[5]}]
set_property -dict { PACKAGE_PIN K3  IOSTANDARD LVCMOS33 } [get_ports {USB_Addr[4]}]
set_property -dict { PACKAGE_PIN K1  IOSTANDARD LVCMOS33 } [get_ports {USB_Addr[3]}]
set_property -dict { PACKAGE_PIN E1  IOSTANDARD LVCMOS33 } [get_ports {USB_Addr[2]}]
set_property -dict { PACKAGE_PIN D1  IOSTANDARD LVCMOS33 } [get_ports {USB_Addr[1]}]
set_property -dict { PACKAGE_PIN C1  IOSTANDARD LVCMOS33 } [get_ports {USB_Addr[0]}]


set_property -dict { PACKAGE_PIN A5  IOSTANDARD LVCMOS33 } [get_ports USB_RDn]
set_property -dict { PACKAGE_PIN A4  IOSTANDARD LVCMOS33 } [get_ports USB_WRn]
set_property -dict { PACKAGE_PIN B4  IOSTANDARD LVCMOS33 } [get_ports USB_CEn]
set_property -dict { PACKAGE_PIN B5  IOSTANDARD LVCMOS33 } [get_ports USB_ALEn]

set_property -dict { PACKAGE_PIN H2  IOSTANDARD LVCMOS33 } [get_ports USB_SPARE0]

set_property -dict { PACKAGE_PIN R1  IOSTANDARD LVCMOS33 } [get_ports FPGA_BONUS1]
set_property -dict { PACKAGE_PIN P1  IOSTANDARD LVCMOS33 } [get_ports FPGA_BONUS2]
set_property -dict { PACKAGE_PIN N1  IOSTANDARD LVCMOS33 } [get_ports FPGA_BONUS3]
set_property -dict { PACKAGE_PIN N2  IOSTANDARD LVCMOS33 } [get_ports FPGA_BONUS4]

# 20-pin connector:
set_property -dict { PACKAGE_PIN T2  IOSTANDARD LVCMOS33 } [get_ports target_PDID]
set_property -dict { PACKAGE_PIN N3  IOSTANDARD LVCMOS33 } [get_ports target_SCK]
set_property -dict { PACKAGE_PIN R2  IOSTANDARD LVCMOS33 } [get_ports target_io2]
set_property -dict { PACKAGE_PIN B2  IOSTANDARD LVCMOS33 } [get_ports target_MISO]
set_property -dict { PACKAGE_PIN B1  IOSTANDARD LVCMOS33 } [get_ports target_io1]
set_property -dict { PACKAGE_PIN A3  IOSTANDARD LVCMOS33 } [get_ports target_hs2]
set_property -dict { PACKAGE_PIN T4  IOSTANDARD LVCMOS33 } [get_ports target_io4]
set_property -dict { PACKAGE_PIN T3  IOSTANDARD LVCMOS33 } [get_ports target_io3]
set_property -dict { PACKAGE_PIN P3  IOSTANDARD LVCMOS33 } [get_ports target_PDIC]
set_property -dict { PACKAGE_PIN C2  IOSTANDARD LVCMOS33 } [get_ports target_MOSI]
set_property -dict { PACKAGE_PIN A2  IOSTANDARD LVCMOS33 } [get_ports target_nRST]
set_property -dict { PACKAGE_PIN F5  IOSTANDARD LVCMOS33 } [get_ports target_hs1]
set_property -dict { PACKAGE_PIN H3  IOSTANDARD LVCMOS33 } [get_ports target_poweron]

# USERIO:
set_property -dict { PACKAGE_PIN T15 IOSTANDARD LVCMOS33 }  [get_ports {USERIO_D[0]}]
set_property -dict { PACKAGE_PIN T14 IOSTANDARD LVCMOS33 }  [get_ports {USERIO_D[1]}]
set_property -dict { PACKAGE_PIN R13 IOSTANDARD LVCMOS33 }  [get_ports {USERIO_D[2]}]
set_property -dict { PACKAGE_PIN T13 IOSTANDARD LVCMOS33 }  [get_ports {USERIO_D[3]}]
set_property -dict { PACKAGE_PIN R12 IOSTANDARD LVCMOS33 }  [get_ports {USERIO_D[4]}]
set_property -dict { PACKAGE_PIN T12 IOSTANDARD LVCMOS33 }  [get_ports {USERIO_D[5]}]
set_property -dict { PACKAGE_PIN R11 IOSTANDARD LVCMOS33 }  [get_ports {USERIO_D[6]}]
set_property -dict { PACKAGE_PIN T10 IOSTANDARD LVCMOS33 }  [get_ports {USERIO_D[7]}]
set_property -dict { PACKAGE_PIN N12 IOSTANDARD LVCMOS33 }  [get_ports USERIO_CLK]


# MCX:
set_property -dict { PACKAGE_PIN R15 IOSTANDARD LVCMOS33 }  [get_ports FPGA_TRIGOUT]
set_property -dict { PACKAGE_PIN N14 IOSTANDARD LVCMOS33 }  [get_ports USBIOHS2]

# SAM3U - SPI
set_property -dict { PACKAGE_PIN T7  IOSTANDARD LVCMOS33 }  [get_ports SAM_MOSI]
set_property -dict { PACKAGE_PIN R7  IOSTANDARD LVCMOS33 }  [get_ports SAM_MISO]
set_property -dict { PACKAGE_PIN T8  IOSTANDARD LVCMOS33 }  [get_ports SAM_SPCK]
set_property -dict { PACKAGE_PIN T9  IOSTANDARD LVCMOS33 }  [get_ports SAM_CS]

#SAM3U - USART (config pins)
set_property -dict { PACKAGE_PIN J13  IOSTANDARD LVCMOS33 }  [get_ports FPGA_CDIN]
set_property -dict { PACKAGE_PIN J14  IOSTANDARD LVCMOS33 }  [get_ports FPGA_CDOUT]

#ADC - control
set_property -dict { PACKAGE_PIN A9   IOSTANDARD LVCMOS25 }  [get_ports ADC_SCLK]
set_property -dict { PACKAGE_PIN B9   IOSTANDARD LVCMOS25 }  [get_ports ADC_SDATA]
set_property -dict { PACKAGE_PIN A8   IOSTANDARD LVCMOS25 }  [get_ports ADC_SEN]
set_property -dict { PACKAGE_PIN A10  IOSTANDARD LVCMOS25 }  [get_ports ADC_RESET]
set_property -dict { PACKAGE_PIN G12  IOSTANDARD LVCMOS25 }  [get_ports ADC_DFS]
set_property -dict { PACKAGE_PIN H12  IOSTANDARD LVCMOS25 }  [get_ports ADC_OE]
set_property -dict { PACKAGE_PIN G16  IOSTANDARD LVCMOS25 }  [get_ports ADC_OVR_SDOUT]

set_property -dict { PACKAGE_PIN B12  IOSTANDARD LVDS_25 }  [get_ports ADC_DP[0]]
set_property -dict { PACKAGE_PIN A12  IOSTANDARD LVDS_25 }  [get_ports ADC_DN[0]]
set_property -dict { PACKAGE_PIN A13  IOSTANDARD LVDS_25 }  [get_ports ADC_DP[1]]
set_property -dict { PACKAGE_PIN A14  IOSTANDARD LVDS_25 }  [get_ports ADC_DN[1]]
set_property -dict { PACKAGE_PIN B15  IOSTANDARD LVDS_25 }  [get_ports ADC_DP[2]]
set_property -dict { PACKAGE_PIN A15  IOSTANDARD LVDS_25 }  [get_ports ADC_DN[2]]
set_property -dict { PACKAGE_PIN C16  IOSTANDARD LVDS_25 }  [get_ports ADC_DP[3]]
set_property -dict { PACKAGE_PIN B16  IOSTANDARD LVDS_25 }  [get_ports ADC_DN[3]]
set_property -dict { PACKAGE_PIN D14  IOSTANDARD LVDS_25 }  [get_ports ADC_DP[4]]
set_property -dict { PACKAGE_PIN D15  IOSTANDARD LVDS_25 }  [get_ports ADC_DN[4]]
set_property -dict { PACKAGE_PIN F15  IOSTANDARD LVDS_25 }  [get_ports ADC_DP[5]]
set_property -dict { PACKAGE_PIN E15  IOSTANDARD LVDS_25 }  [get_ports ADC_DN[5]]

# output from FPGA:
set_property -dict { PACKAGE_PIN J15  IOSTANDARD LVDS_25 }  [get_ports ADC_CLKP]
set_property -dict { PACKAGE_PIN J16  IOSTANDARD LVDS_25 }  [get_ports ADC_CLKN]

# input to FPGA:
set_property -dict { PACKAGE_PIN E12  IOSTANDARD LVDS_25 }  [get_ports ADC_clk_fbp]
set_property -dict { PACKAGE_PIN E13  IOSTANDARD LVDS_25 }  [get_ports ADC_clk_fbn]

#PLL:
set_property -dict { PACKAGE_PIN C11  IOSTANDARD LVCMOS25 }  [get_ports PLL_STATUS]
set_property -dict { PACKAGE_PIN D13  IOSTANDARD LVDS_25 }  [get_ports PLLFPGAP]
set_property -dict { PACKAGE_PIN C13  IOSTANDARD LVDS_25 }  [get_ports PLLFPGAN]

#VGA:
set_property -dict { PACKAGE_PIN L15  IOSTANDARD LVCMOS33 }  [get_ports VMAG_D[4]]
set_property -dict { PACKAGE_PIN M16  IOSTANDARD LVCMOS33 }  [get_ports VMAG_D[3]]
set_property -dict { PACKAGE_PIN M15  IOSTANDARD LVCMOS33 }  [get_ports VMAG_D[2]]
set_property -dict { PACKAGE_PIN N16  IOSTANDARD LVCMOS33 }  [get_ports VMAG_D[1]]
set_property -dict { PACKAGE_PIN P16  IOSTANDARD LVCMOS33 }  [get_ports VMAG_D[0]]
set_property -dict { PACKAGE_PIN R16  IOSTANDARD LVCMOS33 }  [get_ports VDBSPWM]

set_property -dict { PACKAGE_PIN C4   IOSTANDARD LVCMOS33 }  [get_ports glitchout_highpwr]
set_property -dict { PACKAGE_PIN E3   IOSTANDARD LVCMOS33 }  [get_ports glitchout_lowpwr]


# No spec for these, seems sensible:
set_input_delay -clock clk_usb 2.000 [get_ports USB_ALEn]
set_input_delay -clock clk_usb 2.000 [get_ports USB_CEn]
set_input_delay -clock clk_usb 2.000 [get_ports USB_RDn]
set_input_delay -clock clk_usb 2.000 [get_ports USB_WRn]
set_input_delay -clock clk_usb 2.000 [get_ports USB_Data]
set_input_delay -clock clk_usb 2.000 [get_ports USB_Addr]

set_output_delay -clock clk_usb 0.000 [get_ports USB_SPARE0]
set_false_path -to [get_ports USB_SPARE0]

# from spec - sort of:
set_input_delay -clock ADC_clk_fb -max 1.450 [get_ports ADC_DP]
set_input_delay -clock ADC_clk_fb -max 1.450 [get_ports ADC_DP] -clock_fall -add_delay
# 0.350 is the spec but it tends to fail (hold violations) so let's increase it a wee bit...
#set_input_delay -clock ADC_clk_fb -min 0.350 [get_ports ADC_DP]
#set_input_delay -clock ADC_clk_fb -min 0.350 [get_ports ADC_DP] -clock_fall -add_delay
set_input_delay -clock ADC_clk_fb -min 1.000 [get_ports ADC_DP]
set_input_delay -clock ADC_clk_fb -min 1.000 [get_ports ADC_DP] -clock_fall -add_delay


set_input_delay -clock clk_usb 0.000 [get_ports target_io1]
set_input_delay -clock clk_usb 0.000 [get_ports target_io2]
set_input_delay -clock clk_usb 0.000 [get_ports target_io3]
set_input_delay -clock clk_usb 0.000 [get_ports target_io4]
set_false_path -from [get_ports target_io1]
set_false_path -from [get_ports target_io2]
set_false_path -from [get_ports target_io3]
set_false_path -from [get_ports target_io4]

set_output_delay -clock clk_usb 0.000 [get_ports target_io1]
set_output_delay -clock clk_usb 0.000 [get_ports target_io2]
set_output_delay -clock clk_usb 0.000 [get_ports target_io3]
set_output_delay -clock clk_usb 0.000 [get_ports target_io4]
set_output_delay -clock clk_usb 0.000 [get_ports target_poweron]
set_false_path -to [get_ports target_io1]
set_false_path -to [get_ports target_io2]
set_false_path -to [get_ports target_io3]
set_false_path -to [get_ports target_io4]
set_false_path -to [get_ports target_poweron]


set_input_delay -clock clk_usb 0.000 [get_ports ADC_OVR_SDOUT]
set_false_path -from [get_ports ADC_OVR_SDOUT]

set_output_delay -clock clk_usb 0.000 [get_ports LED_ADC]
set_output_delay -clock clk_usb 0.000 [get_ports LED_GLITCH]
set_output_delay -clock clk_usb 0.000 [get_ports LED_ARMED]
set_output_delay -clock clk_usb 0.000 [get_ports LED_CAP]
set_false_path -to [get_ports LED_ADC]
set_false_path -to [get_ports LED_GLITCH]
set_false_path -to [get_ports LED_ARMED]
set_false_path -to [get_ports LED_CAP]

set_output_delay -clock clk_usb 0.000 [get_ports VMAG_D[0]]
set_output_delay -clock clk_usb 0.000 [get_ports VMAG_D[1]]
set_output_delay -clock clk_usb 0.000 [get_ports VMAG_D[2]]
set_output_delay -clock clk_usb 0.000 [get_ports VMAG_D[3]]
set_output_delay -clock clk_usb 0.000 [get_ports VMAG_D[4]]
set_output_delay -clock clk_usb 0.000 [get_ports VDBSPWM]
set_false_path -to [get_ports VMAG_D[0]]
set_false_path -to [get_ports VMAG_D[1]]
set_false_path -to [get_ports VMAG_D[2]]
set_false_path -to [get_ports VMAG_D[3]]
set_false_path -to [get_ports VMAG_D[4]]
set_false_path -to [get_ports VDBSPWM]


set_input_delay -clock [get_clocks clk_usb] -add_delay 0.000 [get_ports {USERIO_CLK}]
set_false_path -from [get_ports {USERIO_CLK}]

#set_input_delay -clock [get_clocks TRACECLOCK] 0.0 [get_ports USERIO_D]
set_input_delay -clock [get_clocks TRACECLOCK] 2.0 [get_ports USERIO_D]
set_output_delay -clock [get_clocks TRACECLOCK] 0.0 [get_ports USERIO_D]
set_false_path -to [get_ports USERIO_D]
set_false_path -from [get_ports USERIO_D]

set_output_delay -clock [get_clocks clk_usb] 0.0 [get_ports ADC_DFS]
set_output_delay -clock [get_clocks clk_usb] 0.0 [get_ports ADC_OE]
set_output_delay -clock [get_clocks clk_usb] 0.0 [get_ports ADC_RESET]
set_output_delay -clock [get_clocks clk_usb] 0.0 [get_ports ADC_SCLK]
set_output_delay -clock [get_clocks clk_usb] 0.0 [get_ports ADC_SDATA]
set_output_delay -clock [get_clocks clk_usb] 0.0 [get_ports ADC_SEN]
set_false_path -to [get_ports ADC_DFS]
set_false_path -to [get_ports ADC_OE]
set_false_path -to [get_ports ADC_RESET]
set_false_path -to [get_ports ADC_SCLK]
set_false_path -to [get_ports ADC_SDATA]
set_false_path -to [get_ports ADC_SEN]

set_output_delay -clock [get_clocks clk_usb] 0.0 [get_ports SAM_MISO]
set_output_delay -clock [get_clocks clk_usb] 0.0 [get_ports target_MOSI]
set_output_delay -clock [get_clocks clk_usb] 0.0 [get_ports target_PDID]
set_output_delay -clock [get_clocks clk_usb] 0.0 [get_ports target_PDIC]
set_output_delay -clock [get_clocks clk_usb] 0.0 [get_ports target_SCK]
set_output_delay -clock [get_clocks clk_usb] 0.0 [get_ports target_nRST]
set_false_path -to [get_ports SAM_MISO]
set_false_path -to [get_ports target_MOSI]
set_false_path -to [get_ports target_PDID]
set_false_path -to [get_ports target_PDIC]
set_false_path -to [get_ports target_SCK]
set_false_path -to [get_ports target_nRST]

set_output_delay -clock [get_clocks clk_usb] 0.0 [get_ports FPGA_TRIGOUT]
set_false_path -to [get_ports FPGA_TRIGOUT]

set_input_delay -clock clk_usb 0.000 [get_ports PLL_STATUS]
set_input_delay -clock clk_usb 0.000 [get_ports target_nRST]
set_input_delay -clock clk_usb 0.000 [get_ports FPGA_CDOUT]
#set_input_delay -clock clk_usb 0.000 [get_ports USBIOHS2]
#set_input_delay -clock clk_usb 0.000 [get_ports target_hs1]
set_input_delay -clock clk_usb 0.000 [get_ports target_hs2]
set_input_delay -clock clk_usb 0.000 [get_ports ADC_clk_fbp]
set_input_delay -clock clk_usb 0.000 [get_ports PLLFPGAP]
set_false_path -from [get_ports PLL_STATUS]
set_false_path -from [get_ports target_nRST]
set_false_path -from [get_ports FPGA_CDOUT]
#set_false_path -from [get_ports USBIOHS2]
#set_false_path -from [get_ports target_hs1]
set_false_path -from [get_ports target_hs2]
set_false_path -from [get_ports ADC_clk_fbp]
set_false_path -from [get_ports PLLFPGAP]


set_output_delay -clock [get_clocks clk_usb] 0.0 [get_ports target_hs2]
set_output_delay -clock [get_clocks clk_usb] 0.0 [get_ports ADC_CLKP]
set_output_delay -clock [get_clocks clk_usb] 0.0 [get_ports glitchout_highpwr]
set_output_delay -clock [get_clocks clk_usb] 0.0 [get_ports glitchout_lowpwr]
set_output_delay -clock [get_clocks clk_usb] 0.0 [get_ports FPGA_CDIN]
set_false_path -to [get_ports target_hs2]
set_false_path -to [get_ports ADC_CLKP]
set_false_path -to [get_ports glitchout_highpwr]
set_false_path -to [get_ports glitchout_lowpwr]
set_false_path -to [get_ports FPGA_CDIN]

# quasi-static control signals:
set_false_path -from [get_pins U_trace_top/U_reg_trace/O_swo_bitrate_div_reg*/C] -to [all_registers]
set_false_path -from [get_pins U_trace_top/U_reg_trace/O_uart_stop_bits_reg*/C] -to [all_registers]
set_false_path -from [get_pins U_trace_top/U_reg_trace/O_uart_data_bits_reg*/C] -to [all_registers]
set_false_path -from [get_pins U_trace_top/U_reg_main/reg_timestamps_disable_reg/C] -to [all_registers]

set_false_path -from [get_pins U_trace_top/U_reg_trace/O_trace_mask*_reg*/C] -to [all_registers]
set_false_path -from [get_pins U_trace_top/U_reg_trace/O_trace_pattern*_reg*/C] -to [all_registers]
set_false_path -from [get_pins U_trace_top/U_reg_trace/O_swo_enable_reg*/C] -to [all_registers]
set_false_path -from [get_pins U_trace_top/U_reg_trace/O_pattern_trig_enable_reg*/C] -to [all_registers]
set_false_path -from [get_pins U_trace_top/U_reg_trace/O_soft_trig_enable_reg*/C] -to [all_registers]
set_false_path -from [get_pins U_trace_top/U_reg_trace/O_pattern_enable_reg*/C] -to [all_registers]

set_false_path -from [get_pins U_trace_top/U_reg_main/reg_counter_quick_start_reg/C] -to [all_registers]
set_false_path -from [get_pins U_trace_top/U_reg_main/reg_trigger_delay_reg*/C] -to [all_registers]
set_false_path -from [get_pins U_trace_top/U_reg_main/reg_trigger_width_reg*/C] -to [all_registers]
set_false_path -from [get_pins U_trace_top/U_reg_main/reg_num_triggers_reg*/C] -to [all_registers]
set_false_path -from [get_pins U_trace_top/U_reg_main/reg_trigger_enable_reg/C] -to [all_registers]
set_false_path -from [get_pins U_trace_top/U_reg_main/reg_capture_len_reg*/C] -to [all_registers]
set_false_path -from [get_pins U_trace_top/U_reg_main/reg_count_writes_reg/C] -to [all_registers]
set_false_path -from [get_pins U_trace_top/U_reg_main/reg_capture_while_trig_reg/C] -to [all_registers]
set_false_path -from [get_pins U_trace_top/U_reg_main/reg_max_timestamp_reg*/C] -to [all_registers]
set_false_path -from [get_pins U_trace_top/U_reg_trace/O_trace_width_reg*/C] -to [all_registers]
set_false_path -from [get_pins U_trace_top/U_reg_trace/O_capture_raw_reg/C] -to [all_registers]
set_false_path -from [get_pins U_trace_top/U_reg_trace/O_record_syncs_reg/C] -to [all_registers]

set_false_path -from [get_pins U_trace_top/U_reg_main/reg_reset_reg/C] -to [all_registers]

# CDC related exceptions:
set_false_path -to [get_pins U_trace_top/U_reg_main/reg_arm_pipe_reg[0]/D]
set_false_path -from [get_pins U_trace_top/*/*_cdc/dst_req_reg/C] -to [get_pins U_trace_top/*/*_cdc/ack_pipe_reg[0]/D]
set_false_path -from [get_pins U_trace_top/*/*_cdc/src_req_reg/C] -to [get_pins U_trace_top/*/*_cdc/req_pipe_reg[0]/D]


# We're violating the SAM3U spec for fast reads, so these are not from spec...
# read data is provided 1 cycle earlier from when it *appears* to be required, and so
# we use negatives here to meet timing. Works in practice and meets timing.
set_output_delay -clock clk_usb -max -2.000 [get_ports USB_Data]
#set_output_delay -clock clk_usb -min -4.000 [get_ports USB_Data]

set_property BITSTREAM.CONFIG.USR_ACCESS TIMESTAMP [current_design]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
#connect_debug_port dbg_hub/clk [get_nets clk_usb_buf_BUFG]
