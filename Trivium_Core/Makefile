MAKEFILE_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

TOPLEVEL = Trivium
WORKDIR = $(MAKEFILE_DIR)/work
GHDL_FLAGS = --workdir=$(WORKDIR)
GHDL_SIM_FLAGS = --stop-time=10us --ieee-asserts=disable-at-0
PDK_ROOT ?= $(MAKEFILE_DIR)/gf180mcu
PDK ?= gf180mcuD
PDK_COMMIT ?= f6eeac7dad085ffcc829ccfd721f7b4ce39edcf7

all: clean analyze convert clone_pdk build_design

clean:
	rm -rf $(WORKDIR)
	rm -rf $(PDK_ROOT)
	rm -rf $(MAKEFILE_DIR)/runs
	rm -rf $(MACROPATH)/*/runs
	rm -rf $(MAKEFILE_DIR)/*.v
	ghdl --clean
	
analyze:
	mkdir -p $(WORKDIR)
	ghdl -a $(GHDL_FLAGS) $(TOPLEVEL).vhd
	
convert:
	ghdl synth --out=verilog $(GHDL_FLAGS) $(TOPLEVEL) > $(TOPLEVEL).v

clone_pdk:
	ciel enable $(PDK_COMMIT) --pdk-root $(PDK_ROOT) --pdk-family $(PDK) --include-libraries gf180mcu_fd_sc_mcu7t5v0
	
build_design:
	librelane $(TOPLEVEL).yaml --pdk $(PDK) --pdk-root $(PDK_ROOT) --manual-pdk