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
PDK_ROOT ?= $(MAKEFILE_DIR)/gf180mcu
PDK ?= gf180mcuD
PDK_COMMIT ?= f6eeac7dad085ffcc829ccfd721f7b4ce39edcf7
PRECHECK_ROOT = $(MAKEFILE_DIR)/gf180mcu-precheck
PRECHECK_TAG = 1.7.3
ID = G803TRIV

all: clean analyze sim convert sim_converted clone_pdk sim_with_io cell_replacement build_macros erase_macro_rtl build_design sim_postlayout waferspace_precheck

clean:
	rm -rf $(WORKDIR)
	rm -rf $(PDK_ROOT)
	rm -rf $(PRECHECK_ROOT)
	rm -rf $(MAKEFILE_DIR)/runs
	rm -rf $(MACROPATH)/*/runs
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
	ghdl synth --latches --out=verilog $(GHDL_FLAGS) $(TOPLEVEL) > $(TOPLEVEL).v
	
sim_converted:
	iverilog -o $(TESTBENCHPATH)/$(TOPTESTBENCH)_verilog $(TESTBENCHPATH)/$(TOPTESTBENCH)_verilog.v $(TOPLEVEL).v
	vvp $(TESTBENCHPATH)/$(TOPTESTBENCH)_verilog

clone_pdk:
	rm -rf $(MAKEFILE_DIR)/gf180mcu
	ciel enable $(PDK_COMMIT) --pdk-root $(PDK_ROOT) --pdk-family $(PDK) --include-libraries all
	
sim_with_io:	
	iverilog -g2012 -o $(TESTBENCHPATH)/$(IOTOPTESTBENCH) $(TESTBENCHPATH)/$(IOTOPTESTBENCH).v $(PDK_ROOT)/$(PDK)/libs.ref/gf180mcu_fd_io/verilog/gf180mcu_fd_io.v $(MACROPATH)/gf180mcu_ws_ip__logo/vh/gf180mcu_ws_ip__logo.v $(MACROPATH)/gf180mcu_ws_ip__marker/vh/gf180mcu_ws_ip__marker.v $(MACROPATH)/gf180mcu_ws_ip__project_id/vh/gf180mcu_ws_ip__project_id.v $(MACROPATH)/gf180mcu_ws_ip__qrcode_id/vh/gf180mcu_ws_ip__qrcode_id.v $(MACROPATH)/gf180mcu_ws_ip__shuttle_id/vh/gf180mcu_ws_ip__shuttle_id.v ${TOPLEVEL}.v ${IOTOPLEVEL}.sv
	vvp $(TESTBENCHPATH)/$(IOTOPTESTBENCH)

build_design:
	librelane $(IOTOPLEVEL).yaml --pdk $(PDK) --pdk-root $(PDK_ROOT) --manual-pdk

sim_postlayout:	
	iverilog -o $(TESTBENCHPATH)/$(IOTOPTESTBENCH) $(PDK_ROOT)/$(PDK)/libs.ref/gf180mcu_fd_sc_mcu7t5v0/verilog/gf180mcu_fd_sc_mcu7t5v0.v $(PDK_ROOT)/$(PDK)/libs.ref/gf180mcu_fd_sc_mcu7t5v0/verilog/primitives.v $(PDK_ROOT)/$(PDK)/libs.ref/gf180mcu_fd_io/verilog/gf180mcu_fd_io.v $(MACROPATH)/gf180mcu_ws_ip__logo/vh/gf180mcu_ws_ip__logo.v $(MACROPATH)/gf180mcu_ws_ip__marker/vh/gf180mcu_ws_ip__marker.v $(MACROPATH)/gf180mcu_ws_ip__project_id/vh/gf180mcu_ws_ip__project_id.v $(MACROPATH)/gf180mcu_ws_ip__qrcode_id/vh/gf180mcu_ws_ip__qrcode_id.v $(MACROPATH)/gf180mcu_ws_ip__shuttle_id/vh/gf180mcu_ws_ip__shuttle_id.v $(MAKEFILE_DIR)/runs/RUN*/final/nl/$(IOTOPLEVEL).nl.v $(TESTBENCHPATH)/$(IOTOPTESTBENCH).v
	vvp $(TESTBENCHPATH)/$(IOTOPTESTBENCH)

waferspace_precheck:
	git clone https://github.com/wafer-space/gf180mcu-precheck --branch $(PRECHECK_TAG)
	python3 $(PRECHECK_ROOT)/precheck.py --input runs/RUN*/final/gds/$(IOTOPLEVEL).gds --top $(IOTOPLEVEL)