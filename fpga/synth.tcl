#################################################
# Project setup
#################################################
create_project -in_memory -part "xc7a35tcpg236-1"

set build_type [lindex $argv 0]
set rope [lindex $argv 1]
set core [lindex $argv 2]

set src_dir [file normalize "./../fpga"]

read_verilog -sv \
    $src_dir/hdl/cmod_agc.v \
    $src_dir/hdl/agc/fpga_agc.v \
    [glob $src_dir/hdl/agc/components/*.v] \
    [glob $src_dir/hdl/monitor/*.v] \
    [glob $src_dir/hdl/third_party/*.v] \

add_files [glob ${src_dir}/roms/*.coe]

set_property verilog_define {TARGET_FPGA=1} [current_fileset]

if {$build_type in {CDU}} {
    set_property verilog_define {CDU_INTERFACE=1} [current_fileset]
}
if {$build_type in {DSKY DSKY_COMMS}} {
    set_property verilog_define {DSKY_INTERFACE=1} [current_fileset]
} 
if {$build_type in {DSKY_COMMS}} {
    set_property verilog_define {COMMS_INTERFACE=1} [current_fileset]
} 

#################################################
# IP creation
#################################################
file mkdir ip

# Propagation clocks
create_ip -name clk_wiz -vendor xilinx.com -library ip -module_name prop_clk_div -dir ip -force
set_property -dict [list \
    CONFIG.PRIM_IN_FREQ {12.000} \
    CONFIG.NUM_OUT_CLKS {2} \
    CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {51.200} \
    CONFIG.CLKOUT2_USED {true} \
    CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {128.000} \
] [get_ips prop_clk_div]

synth_ip [get_ips prop_clk_div]

# AGC memories
create_ip -name blk_mem_gen -vendor xilinx.com -library ip -module_name core_memory -dir ip -force
set_property -dict [list \
    CONFIG.Memory_Type {Single_Port_RAM} \
    CONFIG.Read_Width_A {16} \
    CONFIG.Write_Depth_A {2048} \
    CONFIG.Enable_A {Always_Enabled} \
    CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
    CONFIG.Load_Init_File {true} \
    CONFIG.Coe_File [file nativename ${src_dir}/cores/${core}.coe] \
    CONFIG.Fill_Remaining_Memory_Locations {true} \
    CONFIG.Remaining_Memory_Locations {4000} \
] [get_ips core_memory]

create_ip -name blk_mem_gen -vendor xilinx.com -library ip -module_name rope_memory -dir ip -force
set_property -dict [list \
    CONFIG.Memory_Type {Single_Port_ROM} \
    CONFIG.Read_Width_A {16} \
    CONFIG.Write_Depth_A {36864} \
    CONFIG.Enable_A {Always_Enabled} \
    CONFIG.Load_Init_File {true} \
    CONFIG.Coe_File [file nativename ${src_dir}/roms/${rope}.coe] \
] [get_ips rope_memory]

synth_ip [get_ips core_memory rope_memory]

# ADC
create_ip -name xadc_wiz -vendor xilinx.com -library ip -module_name mon_adc -dir ip -force
set_property -dict [list \
    CONFIG.XADC_STARUP_SELECTION {channel_sequencer} \
    CONFIG.DCLK_FREQUENCY {128} \
    CONFIG.ADC_CONVERSION_RATE {64} \
    CONFIG.SEQUENCER_MODE {Continuous} \
    CONFIG.CHANNEL_AVERAGING {256} \
    CONFIG.CHANNEL_ENABLE_VP_VN {false} \
    CONFIG.CHANNEL_ENABLE_TEMPERATURE {true} \
    CONFIG.AVERAGE_ENABLE_TEMPERATURE {true} \
    CONFIG.CHANNEL_ENABLE_VCCINT {true} \
    CONFIG.AVERAGE_ENABLE_VCCINT {true} \
    CONFIG.CHANNEL_ENABLE_VCCAUX {true} \
    CONFIG.AVERAGE_ENABLE_VCCAUX {true} \
    CONFIG.CHANNEL_ENABLE_VAUXP4_VAUXN4 {true} \
    CONFIG.AVERAGE_ENABLE_VAUXP4_VAUXN4 {true} \
    CONFIG.CHANNEL_ENABLE_VAUXP12_VAUXN12 {true} \
    CONFIG.AVERAGE_ENABLE_VAUXP12_VAUXN12 {true} \
    CONFIG.OT_ALARM {false} \
    CONFIG.USER_TEMP_ALARM {false} \
    CONFIG.VCCINT_ALARM {false} \
    CONFIG.VCCAUX_ALARM {false} \
] [get_ips mon_adc]

synth_ip [get_ips mon_adc]

# Monitor FIFOs
create_ip -name fifo_generator -vendor xilinx.com -library ip -module_name cmd_fifo -dir ip -force
set_property -dict [list \
    CONFIG.Fifo_Implementation {Common_Clock_Block_RAM} \
    CONFIG.Input_Data_Width {40} \
    CONFIG.Input_Depth {512} \
    CONFIG.Output_Data_Width {40} \
    CONFIG.Output_Depth {512} \
    CONFIG.Performance_Options {First_Word_Fall_Through} \
] [get_ips cmd_fifo]

create_ip -name fifo_generator -vendor xilinx.com -library ip -module_name read_fifo -dir ip -force
set_property -dict [list \
    CONFIG.Fifo_Implementation {Common_Clock_Block_RAM} \
    CONFIG.Input_Data_Width {40} \
    CONFIG.Input_Depth {512} \
    CONFIG.Output_Data_Width {40} \
    CONFIG.Output_Depth {512} \
    CONFIG.Performance_Options {First_Word_Fall_Through} \
] [get_ips read_fifo]

create_ip -name fifo_generator -vendor xilinx.com -library ip -module_name read_byte_fifo -dir ip -force
set_property -dict [list \
    CONFIG.Fifo_Implementation {Common_Clock_Block_RAM} \
    CONFIG.Input_Data_Width {8} \
    CONFIG.Input_Depth {8192} \
    CONFIG.Output_Data_Width {8} \
    CONFIG.Output_Depth {8192} \
    CONFIG.Performance_Options {First_Word_Fall_Through} \
    CONFIG.Almost_Empty_Flag {true} \
] [get_ips read_byte_fifo]

create_ip -name fifo_generator -vendor xilinx.com -library ip -module_name downlink_fifo -dir ip -force
set_property -dict [list \
    CONFIG.Fifo_Implementation {Common_Clock_Block_RAM} \
    CONFIG.Input_Data_Width {15} \
    CONFIG.Input_Depth {1024} \
    CONFIG.Output_Data_Width {15} \
    CONFIG.Output_Depth {1024} \
    CONFIG.Performance_Options {First_Word_Fall_Through} \
] [get_ips downlink_fifo]

create_ip -name fifo_generator -vendor xilinx.com -library ip -module_name inkl_cycles -dir ip -force
set_property -dict [list \
    CONFIG.Fifo_Implementation {Common_Clock_Block_RAM} \
    CONFIG.Input_Data_Width {1} \
    CONFIG.Input_Depth {65536} \
    CONFIG.Output_Data_Width {1} \
    CONFIG.Output_Depth {65536} \
    CONFIG.Performance_Options {First_Word_Fall_Through} \
] [get_ips inkl_cycles]

synth_ip [get_ips cmd_fifo read_fifo read_byte_fifo downlink_fifo inkl_cycles]

# Monitor memories
create_ip -name blk_mem_gen -vendor xilinx.com -library ip -module_name erasable_sim_mem -dir ip -force
set_property -dict [list \
    CONFIG.Memory_Type {True_Dual_Port_RAM} \
    CONFIG.Assume_Synchronous_Clk {true} \
    CONFIG.Write_Width_A {16} \
    CONFIG.Write_Depth_A {2048} \
    CONFIG.Enable_B {Always_Enabled} \
    CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
    CONFIG.Register_PortB_Output_of_Memory_Primitives {false} \
    CONFIG.Fill_Remaining_Memory_Locations {true} \
    CONFIG.Remaining_Memory_Locations {0} \
] [get_ips erasable_sim_mem]

create_ip -name blk_mem_gen -vendor xilinx.com -library ip -module_name rope_sim_mem -dir ip -force
set_property -dict [list \
    CONFIG.Memory_Type {True_Dual_Port_RAM} \
    CONFIG.Assume_Synchronous_Clk {true} \
    CONFIG.Write_Width_A {16} \
    CONFIG.Write_Depth_A {36864} \
    CONFIG.Enable_B {Always_Enabled} \
    CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
    CONFIG.Register_PortB_Output_of_Memory_Primitives {false} \
    CONFIG.Fill_Remaining_Memory_Locations {true} \
    CONFIG.Remaining_Memory_Locations {0} \
] [get_ips rope_sim_mem]

create_ip -name blk_mem_gen -vendor xilinx.com -library ip -module_name trace_memory -dir ip -force
set_property -dict [list \
    CONFIG.Memory_Type {Simple_Dual_Port_RAM} \
    CONFIG.Assume_Synchronous_Clk {true} \
    CONFIG.Write_Width_A {64} \
    CONFIG.Write_Depth_A {2048} \
    CONFIG.Register_PortA_Output_of_Memory_Primitives {false} \
    CONFIG.Register_PortB_Output_of_Memory_Primitives {false} \
] [get_ips trace_memory]

synth_ip [get_ips erasable_sim_mem rope_sim_mem trace_memory]

#################################################
# Design synthesis
#################################################
synth_design -top "cmod_agc"
write_checkpoint -force post_synth.dcp
report_utilization -file post_synth_util.rpt
