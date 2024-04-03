MOD_TOP=top

MOD_TOP_PATH=src/

.PHONY: check

check: $(MOD_TOP_PATH)/$(MOD_TOP).v
	@echo mod top exist!
	verilator --lint-only $(MOD_TOP_PATH)/$(MOD_TOP).v