MOD_NAME=top

MOD_PATH=src

.PHONY: check

check: $(MOD_PATH)/$(MOD_NAME).v
	@echo mod top exist!
	verilator --lint-only $(MOD_PATH)/$(MOD_NAME).v