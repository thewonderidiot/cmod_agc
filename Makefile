BUILD_DIR=$(shell pwd)/build/
SRC_DIR = $(shell pwd)/fpga/

# Supported build types: AGC, CDU, DSKY, DSKY_COMMS
BUILD_TYPE = AGC
ROPE = Luminary099
CORE = l99_p63

AGC_FILES = fpga_agc.v \
	    components/nor_1.v \
	    components/nor_2.v \
	    components/nor_3.v \
	    components/nor_4.v \
	    components/od_buf.v \
	    components/tri_buf.v \
	    components/MR0A16A.v \
	    components/SST39VF200A.v \
	    components/U74HC02.v \
	    components/U74HC04.v \
	    components/U74HC244.v \
	    components/U74HC27.v \
	    components/U74HC4002.v \
	    components/U74LVC06.v \
	    components/U74LVC07.v \

MONITOR_FILES = agc_channels.v \
		agc_clk_div.v \
		agc_erasable.v \
		agc_fixed.v \
		channel.v \
		clear_timer.v \
		cmd_controller.v \
		cmd_receiver.v \
		control_regs.v \
		core_rope_sim.v \
		debounce.v \
		edit.v \
		erasable_addr_decoder.v \
		erasable_addr_encoder.v \
		erasable_mem_sim.v \
		fixed_addr_decoder.v \
		fixed_addr_encoder.v \
		instruction_trace.v \
		monitor_channels.v \
		monitor_defs.v \
		monitor_dsky.v \
		monitor_regs.v \
		monitor.v \
		msg_sender.v \
		nassp_bridge.v \
		ones_comp_adder.v \
		output_counter.v \
		peripheral_instructions.v \
		register2.v \
		register.v \
		restart_monitor.v \
		rupt_injector.v \
		start_stop.v \
		status_regs.v \
		unedit.v \
		usb_interface.v \

THIRD_PARTY_FILES = uart_rx.v \
		    uart_tx.v \

AGC_SOURCES = $(addprefix $(SRC_DIR)/hdl/agc/, $(AGC_FILES))
MONITOR_SOURCES = $(addprefix $(SRC_DIR)/hdl/monitor/, $(MONITOR_FILES))
THIRD_PARTY_SOURCES = $(addprefix $(SRC_DIR)/hdl/third_party/, $(THIRD_PARTY_FILES))
FPGA_SOURCES = $(SRC_DIR)/hdl/cmod_agc.v $(AGC_SOURCES) $(MONITOR_SOURCES) $(THIRD_PARTY_SOURCES)

.phony: fpga
fpga: $(BUILD_DIR)/cmod_agc.bit

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/cmod_agc.bit : $(SRC_DIR)/impl.tcl $(SRC_DIR)/constr/cmod_agc.xdc $(BUILD_DIR)/post_synth.dcp | $(BUILD_DIR)
	cd $(BUILD_DIR) && vivado -mode batch -source $(SRC_DIR)/impl.tcl -tclargs $(BUILD_TYPE)

$(BUILD_DIR)/post_synth.dcp : $(SRC_DIR)/synth.tcl $(FPGA_SOURCES) | $(BUILD_DIR)
	cd $(BUILD_DIR) && vivado -mode batch -source $(SRC_DIR)/synth.tcl -tclargs $(BUILD_TYPE) $(ROPE) $(CORE)

.phony: load
load: $(BUILD_DIR)/cmod_agc.bit
	openFPGALoader -b cmoda7_35t -f $(BUILD_DIR)/cmod_agc.bit

.phony: clean
clean:
	rm -rf build
