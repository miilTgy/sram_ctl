MOD_NAME = top

MOD_PATH = src
TB_PATH = csrc

VERILATOR = verilator
VERILATOR_FLAGS = --Wall --lint-only
VERILATOR_CFLAGS += -MMD --build -cc  \
				-O3 --x-assign fast --x-initial fast --noassert

BUILD_DIR = ./build
OBJ_DIR = $(BUILD_DIR)/obj_dir
BIN = $(BUILD_DIR)/$(MOD_NAME)

build: $(MOD_PATH)/$(MOD_NAME).v
	@rm -rf $(OBJ_DIR)
	$(VERILATOR) $(VERILATOR_CFLAGS) \
		--top-module $(MOD_NAME) \
		--Mdir $(abspath $(OBJ_DIR)) --trace -o $(abspath $(BIN)) \
		$(MOD_PATH)/$(MOD_NAME).v


check: $(MOD_PATH)/$(MOD_NAME).v
	@echo mod $(MOD_NAME) exist!
	$(VERILATOR) $(VERILATOR_FLAGS) $(MOD_PATH)/$(MOD_NAME).v

.PHONY: check build