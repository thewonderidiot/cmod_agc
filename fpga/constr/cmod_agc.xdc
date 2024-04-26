set_property PACKAGE_PIN J18 [get_ports txd]
set_property PACKAGE_PIN A18 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rxd]
set_property IOSTANDARD LVCMOS33 [get_ports txd]

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]

set_property PACKAGE_PIN A17 [get_ports led0]
set_property IOSTANDARD LVCMOS33 [get_ports led0]

set_property PACKAGE_PIN J17 [get_ports rxd]

set_property PACKAGE_PIN U8 [get_ports upl0in]
set_property IOSTANDARD LVCMOS33 [get_ports upl0in]
set_property IOSTANDARD LVCMOS33 [get_ports upl1in]
set_property PACKAGE_PIN V8 [get_ports upl1in]
