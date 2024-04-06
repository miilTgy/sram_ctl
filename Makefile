MOD_NAME = fifo

MOD_PATH = src
TB_PATH = csrc

VERILATOR = verilator
VERILATOR_FLAGS = --Wall --lint-only
VERILATOR_TFLAGS = --Wall --cc --exe --build -j 0
VERILATOR_BFLAGS = --Wall --cc --build -j 0 -MMD -O3 --x-assign fast --x-initial fast --noassert
					
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

.PHONY: default check build clean run show wave