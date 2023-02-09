###  -*-Makefile-*-

# called by (e.g.): make compile PROC=bluespec_p1

# ================================================================
# Definitions specific to the particular processor (needed only
# for compiling the boot-rom)

INCLUDED_FILE = ../procs/$(PROC)/Include.mk

ifneq ($(strip $(PROC)),)
include $(INCLUDED_FILE)
endif

# ================================================================
# RISC-V config macros passed into Bluespec 'bsc' compiler

WD_ID ?= 4

BSC_COMPILATION_FLAGS += \
	-D SHIFT_BARREL    \
	-D MULT_SYNTH    \
	-D Near_Mem_Caches    \
	-D FABRIC64    \
	-D WD_ID=$(WD_ID)    \
	-D SoC_Map=SoC_Map$(SOC_MAP_SUFFIX)    \
	-D SoC_Map_IFC=SoC_Map$(SOC_MAP_SUFFIX)_IFC    \
	-D mkSoC_Map=mkSoC_Map$(SOC_MAP_SUFFIX)    \
	-D INCLUDE_GDB_CONTROL  \
	-D ACTUAL_GDB -D JTAG_TAP \

INCLUDE_TANDEM_VERIF ?= yes

ifeq ($(INCLUDE_TANDEM_VERIF),yes)
BSC_COMPILATION_FLAGS += -D INCLUDE_TANDEM_VERIF
endif

.PHONY: all
all: compile

# ================================================================
# Search path for bsc for .bsv files

# NB this expects bsc-contrib libraries to be unpacked into the bsc install
BSC_PATH = -p src_BSV:%/Libraries/Bus:%/Libraries/AMBA_TLM3/TLM3:%/Libraries/AMBA_TLM3/Axi:%/Libraries/AMBA_TLM3/Axi4:procs/$(PROC):+

# ----------------
# Top-level file and module

TOPFILE   ?= src_BSV/Top_HW_Side.bsv
TOPMODULE ?= mkTop_HW_Side

# ================================================================
# bsc compilation flags

BSC_COMPILATION_FLAGS += \
	-aggressive-conditions -no-warn-action-shadowing -no-show-timestamps -check-assert \
	-suppress-warnings G0020    \
	+RTS -K128M -RTS  -show-range-conflict

# ================================================================

.PHONY: clean
clean:
	rm -r -f  *~ build_dir

.PHONY: full_clean
full_clean: clean
	rm -r -f ../Verilog_RTL

# ================================================================
# Generate Verilog RTL from BSV sources (needs Bluespec 'bsc' compiler)

RTL_GEN_DIRS = -vdir ../procs/$(PROC)  -bdir build_dir  -info-dir build_dir

build_dir:
	mkdir -p $@

Verilog_RTL:
	cd ..; mkdir -p $@

.PHONY: compile
compile:  build_dir  Verilog_RTL
ifeq ($(strip $(PROC)),)
	@echo "ERROR: Must specify a processor (e.g. PROC=bluespec_p1) for this target"
	exit 1
else
	@echo  "INFO: Verilog RTL generation ..."
	bsc -u -elab -verilog  $(RTL_GEN_DIRS)  $(BSC_COMPILATION_FLAGS)  $(BSC_PATH)  $(TOPFILE)
	rm -f ../procs/$(PROC)/mkP_Core.v ../procs/$(PROC)/mkJtagTap.v
	cp src_Verilog/* ../Verilog_RTL
	@echo  "INFO: Verilog RTL generation finished"
endif

# ================================================================
