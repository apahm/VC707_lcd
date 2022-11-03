# SYSCLK 200MHz
set_property PACKAGE_PIN E19 [get_ports clk_in_p]
set_property IOSTANDARD LVDS [get_ports clk_in_p]
set_property PACKAGE_PIN E18 [get_ports clk_in_n]
set_property IOSTANDARD LVDS [get_ports clk_in_n]

set_property PACKAGE_PIN AV40 [get_ports rst]
set_property IOSTANDARD LVCMOS18 [get_ports rst]

# LEDs
set_property PACKAGE_PIN AM39 [get_ports led]
set_property IOSTANDARD LVCMOS18 [get_ports led]

################################################################################
# LCD Display (2x15 5x8 Dot display) (DisplayTech 162D) (ST7066U Driver)
################################################################################
set_property PACKAGE_PIN AT42 [get_ports {lcd_data[0]}]
set_property IOSTANDARD LVCMOS18 [get_ports {lcd_data[0]}]
set_property PACKAGE_PIN AR38 [get_ports {lcd_data[1]}]
set_property IOSTANDARD LVCMOS18 [get_ports {lcd_data[1]}]
set_property PACKAGE_PIN AR39 [get_ports {lcd_data[2]}]
set_property IOSTANDARD LVCMOS18 [get_ports {lcd_data[2]}]
set_property PACKAGE_PIN AN40 [get_ports {lcd_data[3]}]
set_property IOSTANDARD LVCMOS18 [get_ports {lcd_data[3]}]
set_property PACKAGE_PIN AN41 [get_ports lcd_rs]
set_property IOSTANDARD LVCMOS18 [get_ports lcd_rs]
set_property PACKAGE_PIN AR42 [get_ports lcd_rw]
set_property IOSTANDARD LVCMOS18 [get_ports lcd_rw]
set_property PACKAGE_PIN AT40 [get_ports lcd_e]
set_property IOSTANDARD LVCMOS18 [get_ports lcd_e]

create_clock -period 5.000 -name sys_clk -waveform {0.000 2.500} [get_ports clk_in_p]