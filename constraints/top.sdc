create_clock -name clk_50mhz -period 20ns [get_ports clk]
create_clock -name clk_300mhz -period 3.33ns [get_ports clk_300mhz]

derive_pll_clocks
derive_clock_uncertainty

set_false_path -from [get_ports {key_sw[*]}] -to [all_clocks]

set_false_path -from * -to [get_ports {led[*]}]
set_false_path -from * -to [get_ports {abcdefgh[*]}]
set_false_path -from * -to [get_ports {digit[*]}]
set_false_path -from * -to buzzer
set_false_path -from * -to hsync
set_false_path -from * -to vsync
set_false_path -from * -to [get_ports {rgb[*]}]
