MOD_NAME=top

MOD_PATH=src

.PHONY: check

check: $(MOD_PATH)/$(MOD_NAME).v
	@echo mod $(MOD_NAME) exist!
	verilator --lint-only $(MOD_PATH)/$(MOD_NAME).v