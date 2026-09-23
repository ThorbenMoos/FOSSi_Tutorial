MAKEFILE_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

SOURCES = $(MAKEFILE_DIR)/src/*.vhd
TOPLEVEL = Trivium_Chip
TOPTESTBENCH = TB_$(TOPLEVEL)
IOTOPLEVEL = chip_top
IOTOPTESTBENCH = TB_$(IOTOPLEVEL)
TESTBENCHPATH = $(MAKEFILE_DIR)/src/Testbenches
MACROPATH = $(MAKEFILE_DIR)/macros
WORKDIR = $(MAKEFILE_DIR)/work
GHDL_FLAGS = --workdir=$(WORKDIR)
GHDL_SIM_FLAGS = --stop-time=10us --ieee-asserts=disable-at-0
PDK_ROOT ?= $(MAKEFILE_DIR)/../gf180mcu
PDK ?= gf180mcuD
PDK_COMMIT ?= f6eeac7dad085ffcc829ccfd721f7b4ce39edcf7

all: clean analyze sim convert sim_converted clone_pdk sim_with_io annotate_power_pins erase_macro_rtl build_design sim_postlayout

clean:
	rm -rf $(WORKDIR)
	rm -rf $(MAKEFILE_DIR)/runs
	rm -rf $(MAKEFILE_DIR)/*.v
	ghdl --clean
	
analyze:
	mkdir -p $(WORKDIR)
	ghdl -a $(GHDL_FLAGS) $(SOURCES)
	ghdl -a $(GHDL_FLAGS) $(TESTBENCHPATH)/$(TOPTESTBENCH).vhd
	ghdl -e $(GHDL_FLAGS) $(TOPTESTBENCH)

sim:
	ghdl -r $(GHDL_FLAGS) $(TOPTESTBENCH) $(GHDL_SIM_FLAGS)
	
convert:
	ghdl synth --out=verilog $(GHDL_FLAGS) $(TOPLEVEL) > $(TOPLEVEL).v
	
sim_converted:
	iverilog -o $(TESTBENCHPATH)/$(TOPTESTBENCH)_verilog $(TESTBENCHPATH)/$(TOPTESTBENCH)_verilog.v $(TOPLEVEL).v
	vvp $(TESTBENCHPATH)/$(TOPTESTBENCH)_verilog

clone_pdk:
	ciel enable $(PDK_COMMIT) --pdk-root $(PDK_ROOT) --pdk-family $(PDK) --include-libraries gf180mcu_fd_io --include-libraries gf180mcu_fd_sc_mcu7t5v0
	
sim_with_io:
	iverilog -g2012 -o $(TESTBENCHPATH)/$(IOTOPTESTBENCH) $(TESTBENCHPATH)/$(IOTOPTESTBENCH).v $(PDK_ROOT)/$(PDK)/libs.ref/gf180mcu_fd_io/verilog/gf180mcu_fd_io.v $(MACROPATH)/gf180mcu_ws_ip__logo/vh/gf180mcu_ws_ip__logo.v $(MACROPATH)/gf180mcu_ws_ip__marker/vh/gf180mcu_ws_ip__marker.v $(MACROPATH)/gf180mcu_ws_ip__project_id/vh/gf180mcu_ws_ip__project_id.v $(MACROPATH)/gf180mcu_ws_ip__qrcode_id/vh/gf180mcu_ws_ip__qrcode_id.v $(MACROPATH)/gf180mcu_ws_ip__shuttle_id/vh/gf180mcu_ws_ip__shuttle_id.v ${TOPLEVEL}.v ${IOTOPLEVEL}.sv
	vvp $(TESTBENCHPATH)/$(IOTOPTESTBENCH)

annotate_power_pins:
	sed -i 's/(input/(\n   `ifdef USE_POWER_PINS\n   inout wire VSS,\n   inout wire VDD,\n   `endif\n   input/g' $(TOPLEVEL).v
	sed -z -i 's/(\n    \./(\n    `ifdef USE_POWER_PINS\n    \.VSS(VSS),\n    \.VDD(VDD),\n    `endif\n    \./g' $(TOPLEVEL).v
	
erase_macro_rtl:
	sed -z -i 's/module trivium_4.*n73};\nendmodule\n\n//g' ${TOPLEVEL}.v
	sed -i 's/trivium_4/Trivium/g' ${TOPLEVEL}.v
	
build_design:
	librelane $(IOTOPLEVEL).yaml --pdk $(PDK) --pdk-root $(PDK_ROOT) --manual-pdk

sim_postlayout:
	iverilog -o $(TESTBENCHPATH)/$(IOTOPTESTBENCH) $(PDK_ROOT)/$(PDK)/libs.ref/gf180mcu_fd_sc_mcu7t5v0/verilog/gf180mcu_fd_sc_mcu7t5v0.v $(PDK_ROOT)/$(PDK)/libs.ref/gf180mcu_fd_sc_mcu7t5v0/verilog/primitives.v $(PDK_ROOT)/$(PDK)/libs.ref/gf180mcu_fd_io/verilog/gf180mcu_fd_io.v $(MACROPATH)/gf180mcu_ws_ip__logo/vh/gf180mcu_ws_ip__logo.v $(MACROPATH)/gf180mcu_ws_ip__marker/vh/gf180mcu_ws_ip__marker.v $(MACROPATH)/gf180mcu_ws_ip__project_id/vh/gf180mcu_ws_ip__project_id.v $(MACROPATH)/gf180mcu_ws_ip__qrcode_id/vh/gf180mcu_ws_ip__qrcode_id.v $(MACROPATH)/gf180mcu_ws_ip__shuttle_id/vh/gf180mcu_ws_ip__shuttle_id.v $(MACROPATH)/Trivium/runs/RUN*/final/nl/Trivium.nl.v $(MAKEFILE_DIR)/runs/RUN*/final/nl/$(IOTOPLEVEL).nl.v $(TESTBENCHPATH)/$(IOTOPTESTBENCH).v
	vvp $(TESTBENCHPATH)/$(IOTOPTESTBENCH)