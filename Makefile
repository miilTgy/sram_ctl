# Created and maintanced by Zeng GuangYi(miil)
MOD_NAME = channel_selecter

MOD_PATH = src
TB_PATH = csrc

MOD = $(shell find $(abspath $(MOD_PATH)) -name $(MOD_NAME).v)
iMOD = $(MOD)
TB = $(shell find $(abspath $(TB_PATH)) -name $(MOD_NAME)_tb.cpp)
iTB = $(shell find $(abspath $(TB_PATH)) -name $(MOD_NAME)_tb.v)

VERILATOR = verilator
VERILATOR_FLAGS = --Wall --lint-only
VERILATOR_TFLAGS = --Wall --cc --exe --build -j 0
VERILATOR_BFLAGS = --Wall --cc --build -j 0 -MMD -O3 --x-assign fast --x-initial fast --noassert

IVERILOG = iverilog
					
BUILD_DIR = ./build
OBJ_DIR = $(BUILD_DIR)/obj_dir
BIN = $(BUILD_DIR)/$(MOD_NAME)

all: default
default: $(BIN)

$(BIN): $(MOD) $(TB)
	rm -rf $(OBJ_DIR)
	$(VERILATOR) $(VERILATOR_TFLAGS) \
		--top-module $(MOD_NAME) \
		--Mdir $(abspath $(OBJ_DIR)) --trace \
		$(abspath $(TB)) $(abspath $(MOD))

build: $(MOD)
	rm -rf $(OBJ_DIR)
	echo $(MOD) $(TB)
	$(VERILATOR) $(VERILATOR_BFLAGS) \
		--top-module $(MOD_NAME) \
		--Mdir $(abspath $(OBJ_DIR)) --trace -o $(abspath $(BIN)) \
		$(abspath $(MOD))


check: $(MOD)
	@echo mod $(MOD_NAME) exist!
	$(VERILATOR) $(VERILATOR_FLAGS) $(MOD)

run: $(OBJ_DIR)/V$(MOD_NAME)
	$(OBJ_DIR)/V$(MOD_NAME)

show: dump.vcd
	gtkwave dump.vcd

wave: all run show

clean: $(OBJ_DIR)
	rm -rf $(OBJ_DIR)

ibuild: $(MOD)
	$(IVERILOG) $(MOD)

itest: $(MOD) $(iTB)
	$(IVERILOG) $(iTB) $(MOD)

irun: ./a.out
	./a.out

ishow: ./waveform.vcd
	gtkwave waveform.vcd

iwave: itest irun ishow

iclean: a.out
	rm a.out

.PHONY: default check build clean run show wave ibuild itest irun ishow iwave

sram:
	iverilog -o wave ./src/sram_testbench.v ./src/sram/sim/blk_mem_gen_0.v ./src/sram/simulation/blk_mem_gen_v8_4.v
	vvp -n wave -lxt2
	gtkwave wave.vcd