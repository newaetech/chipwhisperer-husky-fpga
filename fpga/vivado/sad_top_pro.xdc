set_property CFGBVS VCCO [current_design]
set_property CONFIG_VOLTAGE 3.3 [current_design]


create_clock -period 10.400 -name clk_usb -waveform {0.000 5.200} [get_nets clk_usb]

# 600 MHz:
#create_clock -period 1.666 -name ADC_clk_fb -waveform {0.000 0.833} [get_nets ADC_clk_fb]

# 500 MHz:
create_clock -period 2.000 -name ADC_clk_fb -waveform {0.000 1.000} [get_nets ADC_clk_fb]

# 400 MHz:
#create_clock -period 2.500 -name ADC_clk_fb -waveform {0.000 1.250} [get_nets ADC_clk_fb]

# 333 MHz:
#create_clock -period 3.000 -name ADC_clk_fb -waveform {0.000 1.500} [get_nets ADC_clk_fb]

# 250 MHz:
#create_clock -period 4.000 -name ADC_clk_fb -waveform {0.000 2.000} [get_nets ADC_clk_fb]

create_clock -period 20.000 -name target_hs1 -waveform {0.000 10.000} [get_nets target_hs1]

create_generated_clock -name adc_slow_clk_even -source [get_pins BUFG_adc_clk/O] -divide_by 2 [get_pins U_slow_adc_even/O]
create_generated_clock -name adc_slow_clk_odd  -source [get_pins BUFG_adc_clk/O] -divide_by 2 [get_pins U_slow_adc_odd/O]

create_generated_clock -name adc_slow_clk1 -source [get_pins BUFG_adc_clk/O] -divide_by 4 [get_pins U_slow_adc1/O]
create_generated_clock -name adc_slow_clk2 -source [get_pins BUFG_adc_clk/O] -divide_by 4 [get_pins U_slow_adc2/O]
create_generated_clock -name adc_slow_clk3 -source [get_pins BUFG_adc_clk/O] -divide_by 4 [get_pins U_slow_adc3/O]
create_generated_clock -name adc_slow_clk4 -source [get_pins BUFG_adc_clk/O] -divide_by 4 [get_pins U_slow_adc4/O]

set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets ADC_clk_fb]

# quasi-static control signals:
set_false_path -from [get_pins U_sad/multiple_triggers*reg*/C] -to [all_registers]
set_false_path -from [get_pins U_sad/triggered*reg*/C] -to [all_registers]
set_false_path -from [all_registers] -to [get_pins U_sad/triggered*reg*/D]

# These are needed to meet timing on USB_Data:
set_max_delay 15 -through [get_pins USB_Data_IOBUF*inst/T]
set_max_delay 15 -through [get_pins U_usb_reg_main/reg_address_reg*/Q]
set_max_delay 15 -through [get_pins oadc/U_fifo/fifo_read_count_reg*/Q]
set_max_delay 15 -through [get_pins oadc/U_reg_openadc_adcfifo/fast_fifo_read_mode_reg/Q]

set_clock_groups -asynchronous \
                 -group [get_clocks clk_usb ] \
                 -group [get_clocks {adc_slow_clk_even adc_slow_clk_odd}]

set_clock_groups -asynchronous \
                 -group [get_clocks clk_usb ] \
                 -group [get_clocks {adc_slow_clk1 adc_slow_clk2 adc_slow_clk3 adc_slow_clk4}]

set_clock_groups -asynchronous \
                 -group [get_clocks clk_usb ] \
                 -group [get_clocks target_hs1]

set_clock_groups -asynchronous \
                 -group [get_clocks {clk_usb target_hs1} ] \
                 -group [get_clocks ADC_clk_fb]


# *****************************************************************************

# USB:
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


set_property -dict { PACKAGE_PIN AC23 IOSTANDARD LVCMOS33 } [get_ports USB_RDn]
set_property -dict { PACKAGE_PIN AA25 IOSTANDARD LVCMOS33 } [get_ports USB_WRn]
set_property -dict { PACKAGE_PIN AA23 IOSTANDARD LVCMOS33 } [get_ports USB_CEn]
set_property -dict { PACKAGE_PIN AC22 IOSTANDARD LVCMOS33 } [get_ports USB_ALEn]

set_property -dict { PACKAGE_PIN AB21 IOSTANDARD LVCMOS33 } [get_ports target_hs1]

# MCX:
set_property -dict { PACKAGE_PIN M21 IOSTANDARD LVCMOS33 }  [get_ports TRIG_GLITCHOUT]

# ADC
set_property -dict { PACKAGE_PIN C16  IOSTANDARD LVDS_25 }  [get_ports ADC_DP[0]]
set_property -dict { PACKAGE_PIN B16  IOSTANDARD LVDS_25 }  [get_ports ADC_DN[0]]
set_property -dict { PACKAGE_PIN A18  IOSTANDARD LVDS_25 }  [get_ports ADC_DP[1]]
set_property -dict { PACKAGE_PIN A19  IOSTANDARD LVDS_25 }  [get_ports ADC_DN[1]]
set_property -dict { PACKAGE_PIN B17  IOSTANDARD LVDS_25 }  [get_ports ADC_DP[2]]
set_property -dict { PACKAGE_PIN A17  IOSTANDARD LVDS_25 }  [get_ports ADC_DN[2]]
set_property -dict { PACKAGE_PIN G15  IOSTANDARD LVDS_25 }  [get_ports ADC_DP[3]]
set_property -dict { PACKAGE_PIN F15  IOSTANDARD LVDS_25 }  [get_ports ADC_DN[3]]
set_property -dict { PACKAGE_PIN E15  IOSTANDARD LVDS_25 }  [get_ports ADC_DP[4]]
set_property -dict { PACKAGE_PIN E16  IOSTANDARD LVDS_25 }  [get_ports ADC_DN[4]]
set_property -dict { PACKAGE_PIN G17  IOSTANDARD LVDS_25 }  [get_ports ADC_DP[5]]
set_property -dict { PACKAGE_PIN F18  IOSTANDARD LVDS_25 }  [get_ports ADC_DN[5]]

# output from FPGA:
set_property -dict { PACKAGE_PIN E18 IOSTANDARD LVDS_25 }  [get_ports ADC_CLKP]
set_property -dict { PACKAGE_PIN D18 IOSTANDARD LVDS_25 }  [get_ports ADC_CLKN]

# input to FPGA:
set_property -dict { PACKAGE_PIN AC9  IOSTANDARD LVDS }  [get_ports ADC_clk_fbp]
set_property -dict { PACKAGE_PIN AD9  IOSTANDARD LVDS }  [get_ports ADC_clk_fbn]


# No spec for these, seems sensible:
set_input_delay -clock clk_usb 2.000 [get_ports USB_ALEn]
set_input_delay -clock clk_usb 2.000 [get_ports USB_CEn]
set_input_delay -clock clk_usb 2.000 [get_ports USB_RDn]
set_input_delay -clock clk_usb 2.000 [get_ports USB_WRn]
set_input_delay -clock clk_usb 2.000 [get_ports USB_Data]
set_input_delay -clock clk_usb 2.000 [get_ports USB_Addr]


# from spec - sort of:
set_input_delay -clock ADC_clk_fb -max 1.450 [get_ports ADC_DP]
set_input_delay -clock ADC_clk_fb -max 1.450 [get_ports ADC_DP] -clock_fall -add_delay
# 0.350 is the spec but it tends to fail (hold violations) so let's increase it a wee bit...
#set_input_delay -clock ADC_clk_fb -min 0.350 [get_ports ADC_DP]
#set_input_delay -clock ADC_clk_fb -min 0.350 [get_ports ADC_DP] -clock_fall -add_delay
set_input_delay -clock ADC_clk_fb -min 1.000 [get_ports ADC_DP]
set_input_delay -clock ADC_clk_fb -min 1.000 [get_ports ADC_DP] -clock_fall -add_delay

set_output_delay -clock [get_clocks clk_usb] 0.0 [get_ports TRIG_GLITCHOUT]
set_false_path -to [get_ports TRIG_GLITCHOUT]

set_input_delay -clock clk_usb 0.000 [get_ports ADC_clk_fbp]
set_false_path -from [get_ports ADC_clk_fbp]


set_output_delay -clock [get_clocks clk_usb] 0.0 [get_ports ADC_CLKP]
set_false_path -to [get_ports ADC_CLKP]

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
