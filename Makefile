MOD_TOP=top

MOD_PATH=src

.PHONY: check

check: $(MOD_PATH)/$(MOD_TOP).v
	@echo mod top exist!
	verilator --lint-only $(MOD_PATH)/$(MOD_TOP).v