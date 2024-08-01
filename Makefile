TOOLS = $(HOME)/.apio/packages/tools-oss-cad-suite/bin

.PHONY: all test_hcount

all :
	@echo "Use 'test_XXX' target to run the test for the XXX module"
	@echo "E.g., 'make test_hcount'"

hcount_tb.vvp : hcount_tb.v hcount.v
	$(TOOLS)/iverilog -o $@ $^

test_hcount : hcount_tb.vvp
	$(TOOLS)/vvp $^
