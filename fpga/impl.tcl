#################################################
# Constraint setup
#################################################
open_checkpoint post_synth.dcp

set build_type [lindex $argv 0]

set constr_dir [file normalize "./../fpga/constr"]
read_xdc $constr_dir/cmod_agc.xdc

if {$build_type in {CDU}} {
    read_xdc $constr_dir/cdu.xdc
}
if {$build_type in {DSKY DSKY_COMMS}} {
    read_xdc $constr_dir/dsky.xdc
}
if {$build_type in {DSKY_COMMS}} {
    read_xdc $constr_dir/comms.xdc
}

#################################################
# Implementation
#################################################
opt_design
place_design
phys_opt_design
route_design
phys_opt_design

write_bitstream -force "cmod_agc.bit"

report_route_status -file post_route_status.rpt
report_utilization -file post_route_util.rpt
report_timing_summary -file post_route_timing_summary.rpt
