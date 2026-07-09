set_property -dict {PACKAGE_PIN G17 IOSTANDARD LVCMOS33 PULLTYPE PULLDOWN} [get_ports {upl0_in}]
set_property -dict {PACKAGE_PIN G19 IOSTANDARD LVCMOS33 PULLTYPE PULLDOWN} [get_ports {upl1_in}]

set_property -dict {PACKAGE_PIN H19 IOSTANDARD LVCMOS33 PULLTYPE PULLDOWN} [get_ports {dkbsnc_in}]
set_property -dict {PACKAGE_PIN J19 IOSTANDARD LVCMOS33 PULLTYPE PULLDOWN} [get_ports {dkend_in}]
set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS33 PULLTYPE PULLDOWN} [get_ports {dkstrt_in}]

set_property -dict {PACKAGE_PIN K18 IOSTANDARD LVCMOS33} [get_ports {DKDATA}]
