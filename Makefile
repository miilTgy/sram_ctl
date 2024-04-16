MOD_NAME = write_arbiter_sub/channel_selecter

MOD_PATH = src
TB_PATH = csrc

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

$(BIN): $(MOD_PATH)/$(MOD_NAME).v $(TB_PATH)/$(MOD_NAME)_tb.cpp
	rm -rf $(OBJ_DIR)
	$(VERILATOR) $(VERILATOR_TFLAGS) \
		--top-module $(MOD_NAME) \
		--Mdir $(abspath $(OBJ_DIR)) --trace \
		$(abspath $(TB_PATH)/$(MOD_NAME)_tb.cpp) $(abspath $(MOD_PATH)/$(MOD_NAME).v)

build: $(MOD_PATH)/$(MOD_NAME).v
	rm -rf $(OBJ_DIR)
	$(VERILATOR) $(VERILATOR_BFLAGS) \
		--top-module $(MOD_NAME) \
		--Mdir $(abspath $(OBJ_DIR)) --trace -o $(abspath $(BIN)) \
		$(abspath $(MOD_PATH)/$(MOD_NAME).v)


check: $(MOD_PATH)/$(MOD_NAME).v
	@echo mod $(MOD_NAME) exist!
	$(VERILATOR) $(VERILATOR_FLAGS) $(MOD_PATH)/$(MOD_NAME).v

run: $(OBJ_DIR)/V$(MOD_NAME)
	$(OBJ_DIR)/V$(MOD_NAME)

show: dump.vcd
	gtkwave dump.vcd

wave: all run show

clean: $(OBJ_DIR)
	rm -rf $(OBJ_DIR)

ibuild: $(MOD_PATH)/$(MOD_NAME).v
	rm a.out
	$(IVERILOG) $(MOD_PATH)/$(MOD_NAME).v

itest: $(MOD_PATH)/$(MOD_NAME).v $(TB_PATH)/$(MOD_NAME)_tb.v
	rm a.out
	$(IVERILOG) $(TB_PATH)/$(MOD_NAME)_tb.v $(MOD_PATH)/$(MOD_NAME).v

irun: ./a.out
	./a.out

ishow: ./waveform.vcd
	gtkwave waveform.vcd

iwave: itest irun ishow

.PHONY: default check build clean run show wave ibuild itest irun ishow iwave