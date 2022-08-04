set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]


create_clock -period 10.400 -name clk_usb -waveform {0.000 5.200} [get_nets clk_usb]
#create_clock -period 3.300 -name ADC_clk_fb -waveform {0.000 1.650} [get_nets ADC_clk_fb]
#create_clock -period 3.300 -name pll_fpga_clk -waveform {0.000 1.650} [get_nets pll_fpga_clk]
create_clock -period 4.000 -name ADC_clk_fb -waveform {0.000 2.000} [get_nets ADC_clk_fb]
create_clock -period 4.000 -name pll_fpga_clk -waveform {0.000 2.000} [get_nets pll_fpga_clk]

create_clock -period 20.000 -name target_hs1 -waveform {0.000 10.000} [get_nets target_hs1]
create_clock -period 20.000 -name AUXIO -waveform {0.000 10.500} [get_nets AUXIO]

create_clock -period 40.000 -name TRACECLOCK -waveform {0.000 20.000} [get_nets USERIO_CLK_IBUF]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {USERIO_CLK_IBUF}]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {U_trace_top/VCC_2}]
set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets U_trace_top/fe_clk_pre]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets {U_trace_top/U_trace_clock_drp/SR[0]}]
set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_nets reg_clockglitch/U_clockglitch/glitch_mmcm1_clk_out]
set_property CLOCK_DEDICATED_ROUTE ANY_CMT_COLUMN [get_nets U_trace_top/trace_clk_selected]

set_case_analysis 1 [get_pins reg_clockglitch/sourceclk_mux1/S]
set_case_analysis 0 [get_pins reg_clockglitch/sourceclk_mux2/S]

set_case_analysis 1 [get_pins reg_la/sourceclk_mux1/S]
set_case_analysis 0 [get_pins reg_la/sourceclk_mux2/S]
set_case_analysis 0 [get_pins reg_la/sourceclk_mux3/S]

create_generated_clock -name fe_clk -source [get_pins U_trace_top/U_fe_clock_mux2/I1] -combinational [get_pins U_trace_top/U_fe_clock_mux2/O]
create_generated_clock -name trace_clk_selected -source [get_pins U_trace_top/U_traceclk_sel/I0] -combinational [get_pins U_trace_top/U_traceclk_sel/O]
create_generated_clock -name trace_clk_shifted [get_pins U_trace_top/U_trace_clock_mmcm/CLKOUT0]
#set_case_analysis 0 [get_pins U_trace_top/U_fe_clock_mux1/S]
set_case_analysis 1 [get_pins U_trace_top/U_fe_clock_mux2/S]

set_case_analysis 1 [get_pins U_fifo_clk_mux/S]

#set_clock_groups -logically_exclusive -group clk_usb -group TRACECLOCK -group target_hs1
#set_clock_groups -logically_exclusive -group pll_fpga_clk -group glitchclk


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
                 -group [get_clocks AUXIO]

set_clock_groups -asynchronous \
                 -group [get_clocks {target_hs1 fe_clk} ] \
                 -group [get_clocks AUXIO]

set_clock_groups -asynchronous \
                 -group [get_clocks {clk_usb target_hs1 AUXIO} ] \
                 -group [get_clocks ADC_clk_fb]


set_clock_groups -asynchronous \
                 -group [get_clocks {clk_usb target_hs1 AUXIO} ] \
                 -group [get_clocks pll_fpga_clk]

set_clock_groups -asynchronous \
                 -group [get_clocks pll_fpga_clk] \
                 -group [get_clocks glitch_mmcm1_clk_out*]

set_clock_groups -asynchronous \
                 -group [get_clocks {clk_usb target_hs1 AUXIO} ] \
                 -group [get_clocks glitch_mmcm1_clk_out*]

set_clock_groups -asynchronous \
                 -group [get_clocks {clk_usb target_hs1 AUXIO} ] \
                 -group [get_clocks glitch_mmcm2_clk_out*]

set_clock_groups -asynchronous \
                 -group [get_clocks observer_clk*] \
                 -group [get_clocks {clk_usb target_hs1 AUXIO} ]

set_clock_groups -asynchronous \
                 -group [get_clocks observer_clk*] \
                 -group [get_clocks pll_fpga_clk]

set_clock_groups -asynchronous \
                 -group [get_clocks ADC_clk_fb] \
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
                 -group [get_clocks {clk_usb AUXIO observer_clk* target_hs1 fe_clk}]

set_clock_groups -asynchronous \
                 -group [get_clocks fe_clk ] \
                 -group [get_clocks {clk_usb observer_clk* ADC_clk_fb pll_fpga_clk}]

set_clock_groups -asynchronous \
                 -group [get_clocks {fe_clk ADC_clk_fb} ] \
                 -group [get_clocks glitch_mmcm1_clk_out]

set_clock_groups -asynchronous \
                 -group [get_clocks {trace_clk_selected trace_clk_shifted}] \
                 -group [get_clocks {clk_usb observer_clk*}]

set_clock_groups -asynchronous \
                 -group [get_clocks trace_clk_shifted] \
                 -group [get_clocks fe_clk]



# *****************************************************************************

# LEDs: DONE
set_property -dict { PACKAGE_PIN M26 DRIVE 8  IOSTANDARD LVCMOS33 } [get_ports LED_ADC]
set_property -dict { PACKAGE_PIN M25 DRIVE 8  IOSTANDARD LVCMOS33 } [get_ports LED_GLITCH]
set_property -dict { PACKAGE_PIN M24 DRIVE 8  IOSTANDARD LVCMOS33 } [get_ports LED_ARMED]
set_property -dict { PACKAGE_PIN M19 DRIVE 8  IOSTANDARD LVCMOS33 } [get_ports LED_CAP]
set_property -dict { PACKAGE_PIN L25 DRIVE 8  IOSTANDARD LVCMOS33 } [get_ports LED_UNUSED]
set_property -dict { PACKAGE_PIN K26 DRIVE 8  IOSTANDARD LVCMOS33 } [get_ports LED_GLITCHOUT_HIGHPWR]
set_property -dict { PACKAGE_PIN L24 DRIVE 8  IOSTANDARD LVCMOS33 } [get_ports LED_GLITCHOUT_LOWPWR]

#set_property -dict { PACKAGE_PIN  M26  IOSTANDARD   LVCMOS33 } [get_ports { USRLED[0] }]; #IO_L5N_T0_13
#set_property -dict { PACKAGE_PIN  M25  IOSTANDARD   LVCMOS33 } [get_ports { USRLED[1] }]; #IO_L3P_T0_DQS_13
#set_property -dict { PACKAGE_PIN  M24  IOSTANDARD   LVCMOS33 } [get_ports { USRLED[2] }]; #IO_L8P_T1_13
#set_property -dict { PACKAGE_PIN  M19  IOSTANDARD   LVCMOS33 } [get_ports { USRLED[3] }]; #IO_L22N_T3_13
#set_property -dict { PACKAGE_PIN  L25  IOSTANDARD   LVCMOS33 } [get_ports { USRLED[4] }]; #IO_L3N_T0_DQS_13
#set_property -dict { PACKAGE_PIN  K26  IOSTANDARD   LVCMOS33 } [get_ports { USRLED[5] }]; #IO_L1N_T0_13
#set_property -dict { PACKAGE_PIN  L24  IOSTANDARD   LVCMOS33 } [get_ports { USRLED[6] }]; #IO_L8N_T1_13
#set_property -dict { PACKAGE_PIN  K25  IOSTANDARD   LVCMOS33 } [get_ports { USRLED[7] }]; #IO_L1P_T0_13

set_property -dict { PACKAGE_PIN  AB7  IOSTANDARD   LVCMOS18 } [get_ports { xo_en }]; #IO_L10P_T1_33
set_property -dict { PACKAGE_PIN  N24  IOSTANDARD   LVCMOS33 } [get_ports { vddr_enable }]; #IO_L10P_T1_33
set_property -dict { PACKAGE_PIN  R18  IOSTANDARD   LVCMOS33 } [get_ports { vddr_pgood }]; #IO_L10P_T1_33


# USB: DONE
set_property -dict { PACKAGE_PIN  Y23 IOSTANDARD LVCMOS33 } [get_ports clk_usb]
set_property -dict { PACKAGE_PIN  Y26 IOSTANDARD LVCMOS33 } [get_ports {USB_Data[7]}]
set_property -dict { PACKAGE_PIN  W25 IOSTANDARD LVCMOS33 } [get_ports {USB_Data[6]}]
set_property -dict { PACKAGE_PIN  W26 IOSTANDARD LVCMOS33 } [get_ports {USB_Data[5]}]
set_property -dict { PACKAGE_PIN  V26 IOSTANDARD LVCMOS33 } [get_ports {USB_Data[4]}]
set_property -dict { PACKAGE_PIN  V24 IOSTANDARD LVCMOS33 } [get_ports {USB_Data[3]}]
set_property -dict { PACKAGE_PIN AC21 IOSTANDARD LVCMOS33 } [get_ports {USB_Data[2]}]
set_property -dict { PACKAGE_PIN  U26 IOSTANDARD LVCMOS33 } [get_ports {USB_Data[1]}]
set_property -dict { PACKAGE_PIN  U25 IOSTANDARD LVCMOS33 } [get_ports {USB_Data[0]}]

set_property -dict { PACKAGE_PIN  U22 IOSTANDARD LVCMOS33 } [get_ports {USB_Addr[7]}]
set_property -dict { PACKAGE_PIN  U24 IOSTANDARD LVCMOS33 } [get_ports {USB_Addr[6]}]
set_property -dict { PACKAGE_PIN  Y21 IOSTANDARD LVCMOS33 } [get_ports {USB_Addr[5]}]
set_property -dict { PACKAGE_PIN  V23 IOSTANDARD LVCMOS33 } [get_ports {USB_Addr[4]}]
set_property -dict { PACKAGE_PIN  W23 IOSTANDARD LVCMOS33 } [get_ports {USB_Addr[3]}]
set_property -dict { PACKAGE_PIN AB25 IOSTANDARD LVCMOS33 } [get_ports {USB_Addr[2]}]
set_property -dict { PACKAGE_PIN AB26 IOSTANDARD LVCMOS33 } [get_ports {USB_Addr[1]}]
set_property -dict { PACKAGE_PIN AD23 IOSTANDARD LVCMOS33 } [get_ports {USB_Addr[0]}]

set_property -dict { PACKAGE_PIN AD24 IOSTANDARD LVCMOS33 } [get_ports {USB_Addr_Bytecount[6]}]
set_property -dict { PACKAGE_PIN AC24 IOSTANDARD LVCMOS33 } [get_ports {USB_Addr_Bytecount[5]}]
set_property -dict { PACKAGE_PIN AB24 IOSTANDARD LVCMOS33 } [get_ports {USB_Addr_Bytecount[4]}]
set_property -dict { PACKAGE_PIN AE26 IOSTANDARD LVCMOS33 } [get_ports {USB_Addr_Bytecount[3]}]
set_property -dict { PACKAGE_PIN AD25 IOSTANDARD LVCMOS33 } [get_ports {USB_Addr_Bytecount[2]}]
set_property -dict { PACKAGE_PIN AD26 IOSTANDARD LVCMOS33 } [get_ports {USB_Addr_Bytecount[1]}]
set_property -dict { PACKAGE_PIN AC26 IOSTANDARD LVCMOS33 } [get_ports {USB_Addr_Bytecount[0]}]

# full CW310 USB address line pin listing:
#set_property -dict { PACKAGE_PIN  W20  IOSTANDARD   LVCMOS33 } [get_ports { USB_A[19] }]; #IO_L15P_T2_DQS_12
#set_property -dict { PACKAGE_PIN  W21  IOSTANDARD   LVCMOS33 } [get_ports { USB_A[18] }]; #IO_L6N_T0_VREF_12
#set_property -dict { PACKAGE_PIN  V21  IOSTANDARD   LVCMOS33 } [get_ports { USB_A[17] }]; #IO_L6P_T0_12
#set_property -dict { PACKAGE_PIN  U21  IOSTANDARD   LVCMOS33 } [get_ports { USB_A[16] }]; #IO_0_12
#set_property -dict { PACKAGE_PIN  V22  IOSTANDARD   LVCMOS33 } [get_ports { USB_A[15] }]; #IO_L1N_T0_12
#set_property -dict { PACKAGE_PIN  U22  IOSTANDARD   LVCMOS33 } [get_ports { USB_A[14] }]; #IO_L1P_T0_12
#set_property -dict { PACKAGE_PIN  U24  IOSTANDARD   LVCMOS33 } [get_ports { USB_A[13] }]; #IO_L2P_T0_12
#set_property -dict { PACKAGE_PIN  Y21  IOSTANDARD   LVCMOS33 } [get_ports { USB_A[12] }]; #IO_L15N_T2_DQS_12
#set_property -dict { PACKAGE_PIN  V23  IOSTANDARD   LVCMOS33 } [get_ports { USB_A[11] }]; #IO_L3P_T0_DQS_12
#set_property -dict { PACKAGE_PIN  W23  IOSTANDARD   LVCMOS33 } [get_ports { USB_A[10] }]; #IO_L8P_T1_12
#set_property -dict { PACKAGE_PIN AB25  IOSTANDARD   LVCMOS33 } [get_ports { USB_A[9]  }]; #IO_L7N_T1_12
#set_property -dict { PACKAGE_PIN AB26  IOSTANDARD   LVCMOS33 } [get_ports { USB_A[8]  }]; #IO_L9P_T1_DQS_12
#set_property -dict { PACKAGE_PIN AD23  IOSTANDARD   LVCMOS33 } [get_ports { USB_A[7]  }]; #IO_L16P_T2_12
#set_property -dict { PACKAGE_PIN AD24  IOSTANDARD   LVCMOS33 } [get_ports { USB_A[6]  }]; #IO_L16N_T2_12
#set_property -dict { PACKAGE_PIN AC24  IOSTANDARD   LVCMOS33 } [get_ports { USB_A[5]  }]; #IO_L14N_T2_SRCC_12
#set_property -dict { PACKAGE_PIN AB24  IOSTANDARD   LVCMOS33 } [get_ports { USB_A[4]  }]; #IO_L11N_T1_SRCC_12
#set_property -dict { PACKAGE_PIN AE26  IOSTANDARD   LVCMOS33 } [get_ports { USB_A[3]  }]; #IO_L21N_T3_DQS_12
#set_property -dict { PACKAGE_PIN AD25  IOSTANDARD   LVCMOS33 } [get_ports { USB_A[2]  }]; #IO_L23P_T3_12
#set_property -dict { PACKAGE_PIN AD26  IOSTANDARD   LVCMOS33 } [get_ports { USB_A[1]  }]; #IO_L21P_T3_DQS_12
#set_property -dict { PACKAGE_PIN AC26  IOSTANDARD   LVCMOS33 } [get_ports { USB_A[0]  }]; #IO_L9N_T1_DQS_12

set_property -dict { PACKAGE_PIN AC23 IOSTANDARD LVCMOS33 } [get_ports USB_RDn]
set_property -dict { PACKAGE_PIN AA25 IOSTANDARD LVCMOS33 } [get_ports USB_WRn]
set_property -dict { PACKAGE_PIN AA23 IOSTANDARD LVCMOS33 } [get_ports USB_CEn]
#set_property -dict { PACKAGE_PIN B5  IOSTANDARD LVCMOS33 } [get_ports USB_ALEn]

#set_property -dict { PACKAGE_PIN H2  IOSTANDARD LVCMOS33 } [get_ports USB_SPARE0]

#set_property -dict { PACKAGE_PIN R1  IOSTANDARD LVCMOS33 } [get_ports FPGA_BONUS1]
#set_property -dict { PACKAGE_PIN P1  IOSTANDARD LVCMOS33 } [get_ports FPGA_BONUS2]
#set_property -dict { PACKAGE_PIN N1  IOSTANDARD LVCMOS33 } [get_ports FPGA_BONUS3]
#set_property -dict { PACKAGE_PIN N2  IOSTANDARD LVCMOS33 } [get_ports FPGA_BONUS4]

# 20-pin connector: DONE
set_property -dict { PACKAGE_PIN AE23 IOSTANDARD LVCMOS33 } [get_ports target_PDID]
set_property -dict { PACKAGE_PIN AE22 IOSTANDARD LVCMOS33 } [get_ports target_SCK]
set_property -dict { PACKAGE_PIN AF25 IOSTANDARD LVCMOS33 } [get_ports target_io2]
set_property -dict { PACKAGE_PIN AE21 IOSTANDARD LVCMOS33 } [get_ports target_MISO]
set_property -dict { PACKAGE_PIN AE25 IOSTANDARD LVCMOS33 } [get_ports target_io1]
set_property -dict { PACKAGE_PIN  Y22 IOSTANDARD LVCMOS33 } [get_ports target_hs2]
set_property -dict { PACKAGE_PIN AF24 IOSTANDARD LVCMOS33 } [get_ports target_io4]
set_property -dict { PACKAGE_PIN AF23 IOSTANDARD LVCMOS33 } [get_ports target_io3]
set_property -dict { PACKAGE_PIN AD21 IOSTANDARD LVCMOS33 } [get_ports target_PDIC]
set_property -dict { PACKAGE_PIN AF22 IOSTANDARD LVCMOS33 } [get_ports target_MOSI]
set_property -dict { PACKAGE_PIN  Y20 IOSTANDARD LVCMOS33 } [get_ports target_nRST]
set_property -dict { PACKAGE_PIN AB21 IOSTANDARD LVCMOS33 } [get_ports target_hs1]
#set_property -dict { PACKAGE_PIN H3  IOSTANDARD LVCMOS33 } [get_ports target_poweron]


# USERIO: D0-7 to PMOD1_1-8, CLK to PMOD2_1 DONE
set_property -dict { PACKAGE_PIN N17 IOSTANDARD LVCMOS33 }  [get_ports {USERIO_D[0]}]
set_property -dict { PACKAGE_PIN R26 IOSTANDARD LVCMOS33 }  [get_ports {USERIO_D[1]}]
set_property -dict { PACKAGE_PIN R23 IOSTANDARD LVCMOS33 }  [get_ports {USERIO_D[2]}]
set_property -dict { PACKAGE_PIN T22 IOSTANDARD LVCMOS33 }  [get_ports {USERIO_D[3]}]
set_property -dict { PACKAGE_PIN R25 IOSTANDARD LVCMOS33 }  [get_ports {USERIO_D[4]}]
set_property -dict { PACKAGE_PIN P24 IOSTANDARD LVCMOS33 }  [get_ports {USERIO_D[5]}]
set_property -dict { PACKAGE_PIN P23 IOSTANDARD LVCMOS33 }  [get_ports {USERIO_D[6]}]
set_property -dict { PACKAGE_PIN T23 IOSTANDARD LVCMOS33 }  [get_ports {USERIO_D[7]}]
set_property -dict { PACKAGE_PIN M22 IOSTANDARD LVCMOS33 }  [get_ports USERIO_CLK]


# MCX:
#set_property -dict { PACKAGE_PIN R15 IOSTANDARD LVCMOS33 }  [get_ports TRIG_GLITCHOUT]
#set_property -dict { PACKAGE_PIN N14 IOSTANDARD LVCMOS33 }  [get_ports AUXIO]

# SAM3U - SPI
#set_property -dict { PACKAGE_PIN T7  IOSTANDARD LVCMOS33 }  [get_ports SAM_MOSI]
#set_property -dict { PACKAGE_PIN R7  IOSTANDARD LVCMOS33 }  [get_ports SAM_MISO]
#set_property -dict { PACKAGE_PIN T8  IOSTANDARD LVCMOS33 }  [get_ports SAM_SPCK]
#set_property -dict { PACKAGE_PIN T9  IOSTANDARD LVCMOS33 }  [get_ports SAM_CS]

#SAM3U - USART (config pins)
#set_property -dict { PACKAGE_PIN J13  IOSTANDARD LVCMOS33 }  [get_ports FPGA_CDIN]
#set_property -dict { PACKAGE_PIN J14  IOSTANDARD LVCMOS33 }  [get_ports FPGA_CDOUT]

#ADC - control
#set_property -dict { PACKAGE_PIN A9   IOSTANDARD LVCMOS25 }  [get_ports ADC_SCLK]
#set_property -dict { PACKAGE_PIN B9   IOSTANDARD LVCMOS25 }  [get_ports ADC_SDATA]
#set_property -dict { PACKAGE_PIN A8   IOSTANDARD LVCMOS25 }  [get_ports ADC_SEN]
#set_property -dict { PACKAGE_PIN A10  IOSTANDARD LVCMOS25 }  [get_ports ADC_RESET]
#set_property -dict { PACKAGE_PIN G12  IOSTANDARD LVCMOS25 }  [get_ports ADC_DFS]
#set_property -dict { PACKAGE_PIN H12  IOSTANDARD LVCMOS25 }  [get_ports ADC_OE]
#set_property -dict { PACKAGE_PIN G16  IOSTANDARD LVCMOS25 }  [get_ports ADC_OVR_SDOUT]

#set_property -dict { PACKAGE_PIN B12  IOSTANDARD LVDS_25 }  [get_ports ADC_DP[0]]
#set_property -dict { PACKAGE_PIN A12  IOSTANDARD LVDS_25 }  [get_ports ADC_DN[0]]
#set_property -dict { PACKAGE_PIN A13  IOSTANDARD LVDS_25 }  [get_ports ADC_DP[1]]
#set_property -dict { PACKAGE_PIN A14  IOSTANDARD LVDS_25 }  [get_ports ADC_DN[1]]
#set_property -dict { PACKAGE_PIN B15  IOSTANDARD LVDS_25 }  [get_ports ADC_DP[2]]
#set_property -dict { PACKAGE_PIN A15  IOSTANDARD LVDS_25 }  [get_ports ADC_DN[2]]
#set_property -dict { PACKAGE_PIN C16  IOSTANDARD LVDS_25 }  [get_ports ADC_DP[3]]
#set_property -dict { PACKAGE_PIN B16  IOSTANDARD LVDS_25 }  [get_ports ADC_DN[3]]
#set_property -dict { PACKAGE_PIN D14  IOSTANDARD LVDS_25 }  [get_ports ADC_DP[4]]
#set_property -dict { PACKAGE_PIN D15  IOSTANDARD LVDS_25 }  [get_ports ADC_DN[4]]
#set_property -dict { PACKAGE_PIN F15  IOSTANDARD LVDS_25 }  [get_ports ADC_DP[5]]
#set_property -dict { PACKAGE_PIN E15  IOSTANDARD LVDS_25 }  [get_ports ADC_DN[5]]

# output from FPGA:
#set_property -dict { PACKAGE_PIN J15  IOSTANDARD LVDS_25 }  [get_ports ADC_CLKP]
#set_property -dict { PACKAGE_PIN J16  IOSTANDARD LVDS_25 }  [get_ports ADC_CLKN]

# input to FPGA:
set_property -dict { PACKAGE_PIN AC9 IOSTANDARD LVDS }  [get_ports ADC_clk_fbp]
set_property -dict { PACKAGE_PIN AD9 IOSTANDARD LVDS }  [get_ports ADC_clk_fbn]


#PLL:
#set_property -dict { PACKAGE_PIN C11  IOSTANDARD LVCMOS25 }  [get_ports PLL_STATUS]
#set_property -dict { PACKAGE_PIN D13  IOSTANDARD LVDS_25 }  [get_ports PLLFPGAP]
#set_property -dict { PACKAGE_PIN C13  IOSTANDARD LVDS_25 }  [get_ports PLLFPGAN]

#VGA:
#set_property -dict { PACKAGE_PIN L15  IOSTANDARD LVCMOS33 }  [get_ports VMAG_D[4]]
#set_property -dict { PACKAGE_PIN M16  IOSTANDARD LVCMOS33 }  [get_ports VMAG_D[3]]
#set_property -dict { PACKAGE_PIN M15  IOSTANDARD LVCMOS33 }  [get_ports VMAG_D[2]]
#set_property -dict { PACKAGE_PIN N16  IOSTANDARD LVCMOS33 }  [get_ports VMAG_D[1]]
#set_property -dict { PACKAGE_PIN P16  IOSTANDARD LVCMOS33 }  [get_ports VMAG_D[0]]
#set_property -dict { PACKAGE_PIN R16  IOSTANDARD LVCMOS33 }  [get_ports VDBSPWM]

#set_property -dict { PACKAGE_PIN C4   IOSTANDARD LVCMOS33 }  [get_ports glitchout_highpwr]
#set_property -dict { PACKAGE_PIN E3   IOSTANDARD LVCMOS33 }  [get_ports glitchout_lowpwr]


# No spec for these, seems sensible:
#set_input_delay -clock clk_usb 2.000 [get_ports USB_ALEn]
set_input_delay -clock clk_usb 2.000 [get_ports USB_CEn]
set_input_delay -clock clk_usb 2.000 [get_ports USB_RDn]
set_input_delay -clock clk_usb 2.000 [get_ports USB_WRn]
set_input_delay -clock clk_usb 2.000 [get_ports USB_Data]
set_input_delay -clock clk_usb 2.000 [get_ports USB_Addr]
set_input_delay -clock clk_usb 2.000 [get_ports USB_Addr_Bytecount]

#set_output_delay -clock clk_usb 0.000 [get_ports USB_SPARE0]
#set_false_path -to [get_ports USB_SPARE0]

# from spec - sort of:
#set_input_delay -clock ADC_clk_fb -max 1.450 [get_ports ADC_DP]
#set_input_delay -clock ADC_clk_fb -max 1.450 [get_ports ADC_DP] -clock_fall -add_delay
# 0.350 is the spec but it tends to fail (hold violations) so let's increase it a wee bit...
#set_input_delay -clock ADC_clk_fb -min 0.350 [get_ports ADC_DP]
#set_input_delay -clock ADC_clk_fb -min 0.350 [get_ports ADC_DP] -clock_fall -add_delay
#set_input_delay -clock ADC_clk_fb -min 1.000 [get_ports ADC_DP]
#set_input_delay -clock ADC_clk_fb -min 1.000 [get_ports ADC_DP] -clock_fall -add_delay


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
#set_output_delay -clock clk_usb 0.000 [get_ports target_poweron]
set_false_path -to [get_ports target_io1]
set_false_path -to [get_ports target_io2]
set_false_path -to [get_ports target_io3]
set_false_path -to [get_ports target_io4]
#set_false_path -to [get_ports target_poweron]


#set_input_delay -clock clk_usb 0.000 [get_ports ADC_OVR_SDOUT]
#set_false_path -from [get_ports ADC_OVR_SDOUT]

set_output_delay -clock clk_usb 0.000 [get_ports LED_ADC]
set_output_delay -clock clk_usb 0.000 [get_ports LED_GLITCH]
set_output_delay -clock clk_usb 0.000 [get_ports LED_ARMED]
set_output_delay -clock clk_usb 0.000 [get_ports LED_CAP]
set_false_path -to [get_ports LED_ADC]
set_false_path -to [get_ports LED_GLITCH]
set_false_path -to [get_ports LED_ARMED]
set_false_path -to [get_ports LED_CAP]

#set_output_delay -clock clk_usb 0.000 [get_ports VMAG_D[0]]
#set_output_delay -clock clk_usb 0.000 [get_ports VMAG_D[1]]
#set_output_delay -clock clk_usb 0.000 [get_ports VMAG_D[2]]
#set_output_delay -clock clk_usb 0.000 [get_ports VMAG_D[3]]
#set_output_delay -clock clk_usb 0.000 [get_ports VMAG_D[4]]
#set_output_delay -clock clk_usb 0.000 [get_ports VDBSPWM]
#set_false_path -to [get_ports VMAG_D[0]]
#set_false_path -to [get_ports VMAG_D[1]]
#set_false_path -to [get_ports VMAG_D[2]]
#set_false_path -to [get_ports VMAG_D[3]]
#set_false_path -to [get_ports VMAG_D[4]]
#set_false_path -to [get_ports VDBSPWM]


set_input_delay -clock [get_clocks clk_usb] -add_delay 0.000 [get_ports {USERIO_CLK}]
set_output_delay -clock [get_clocks clk_usb] -add_delay 0.000 [get_ports {USERIO_CLK}]
set_false_path -to [get_ports {USERIO_CLK}]
set_false_path -from [get_ports {USERIO_CLK}]

#set_input_delay -clock [get_clocks clk_usb] -add_delay 0.000 [get_ports {AUXIO}]
#set_output_delay -clock [get_clocks clk_usb] -add_delay 0.000 [get_ports {AUXIO}]
#set_false_path -to [get_ports {AUXIO}]
#set_false_path -from [get_ports {AUXIO}]


#set_input_delay -clock [get_clocks TRACECLOCK] 0.0 [get_ports USERIO_D]
set_input_delay -clock [get_clocks TRACECLOCK] 2.0 [get_ports USERIO_D]
set_output_delay -clock [get_clocks TRACECLOCK] 0.0 [get_ports USERIO_D]
set_false_path -to [get_ports USERIO_D]
set_false_path -from [get_ports USERIO_D]

#set_output_delay -clock [get_clocks clk_usb] 0.0 [get_ports ADC_DFS]
#set_output_delay -clock [get_clocks clk_usb] 0.0 [get_ports ADC_OE]
#set_output_delay -clock [get_clocks clk_usb] 0.0 [get_ports ADC_RESET]
#set_output_delay -clock [get_clocks clk_usb] 0.0 [get_ports ADC_SCLK]
#set_output_delay -clock [get_clocks clk_usb] 0.0 [get_ports ADC_SDATA]
#set_output_delay -clock [get_clocks clk_usb] 0.0 [get_ports ADC_SEN]
#set_false_path -to [get_ports ADC_DFS]
#set_false_path -to [get_ports ADC_OE]
#set_false_path -to [get_ports ADC_RESET]
#set_false_path -to [get_ports ADC_SCLK]
#set_false_path -to [get_ports ADC_SDATA]
#set_false_path -to [get_ports ADC_SEN]

#set_output_delay -clock [get_clocks clk_usb] 0.0 [get_ports SAM_MISO]
set_output_delay -clock [get_clocks clk_usb] 0.0 [get_ports target_MOSI]
set_output_delay -clock [get_clocks clk_usb] 0.0 [get_ports target_PDID]
set_output_delay -clock [get_clocks clk_usb] 0.0 [get_ports target_PDIC]
set_output_delay -clock [get_clocks clk_usb] 0.0 [get_ports target_SCK]
set_output_delay -clock [get_clocks clk_usb] 0.0 [get_ports target_nRST]
#set_false_path -to [get_ports SAM_MISO]
set_false_path -to [get_ports target_MOSI]
set_false_path -to [get_ports target_PDID]
set_false_path -to [get_ports target_PDIC]
set_false_path -to [get_ports target_SCK]
set_false_path -to [get_ports target_nRST]

#set_output_delay -clock [get_clocks clk_usb] 0.0 [get_ports TRIG_GLITCHOUT]
#set_false_path -to [get_ports TRIG_GLITCHOUT]

#set_input_delay -clock clk_usb 0.000 [get_ports PLL_STATUS]
set_input_delay -clock clk_usb 0.000 [get_ports target_nRST]
#set_input_delay -clock clk_usb 0.000 [get_ports FPGA_CDOUT]
#set_input_delay -clock clk_usb 0.000 [get_ports target_hs1]
set_input_delay -clock clk_usb 0.000 [get_ports ADC_clk_fbp]
#set_input_delay -clock clk_usb 0.000 [get_ports PLLFPGAP]
#set_false_path -from [get_ports PLL_STATUS]
set_false_path -from [get_ports target_nRST]
#set_false_path -from [get_ports FPGA_CDOUT]
#set_false_path -from [get_ports target_hs1]
set_false_path -from [get_ports ADC_clk_fbp]
#set_false_path -from [get_ports PLLFPGAP]


set_output_delay -clock [get_clocks clk_usb] 0.0 [get_ports target_hs2]
#set_output_delay -clock [get_clocks clk_usb] 0.0 [get_ports ADC_CLKP]
#set_output_delay -clock [get_clocks clk_usb] 0.0 [get_ports glitchout_highpwr]
#set_output_delay -clock [get_clocks clk_usb] 0.0 [get_ports glitchout_lowpwr]
#set_output_delay -clock [get_clocks clk_usb] 0.0 [get_ports FPGA_CDIN]
set_false_path -to [get_ports target_hs2]
#set_false_path -to [get_ports ADC_CLKP]
#set_false_path -to [get_ports glitchout_highpwr]
#set_false_path -to [get_ports glitchout_lowpwr]
#set_false_path -to [get_ports FPGA_CDIN]

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
set_output_delay -clock clk_usb -min  6.000 [get_ports USB_Data]
#set_output_delay -clock clk_usb -min -4.000 [get_ports USB_Data]

set_property BITSTREAM.CONFIG.USR_ACCESS TIMESTAMP [current_design]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
#connect_debug_port dbg_hub/clk [get_nets clk_usb_buf_BUFG]
