TOOLS = $(HOME)/.apio/packages/tools-oss-cad-suite/bin

.PHONY: all test_hcount

all :
	@echo "Use 'test_XXX' target to run the test for the XXX module"
	@echo "E.g., 'make test_hcount'"

hcount_tb.vvp : hcount_tb.v hcount.v timing.vh testbench.vh
	$(TOOLS)/iverilog -s hcount_tb -o $@ hcount_tb.v hcount.v

vcount_tb.vvp : vcount_tb.v vcount.v hcount.v timing.vh testbench.vh
	$(TOOLS)/iverilog -s vcount_tb -o $@ vcount_tb.v vcount.v hcount.v

test_hcount : hcount_tb.vvp
	$(TOOLS)/vvp $^

test_vcount : vcount_tb.vvp
	$(TOOLS)/vvp $^

clean :
	rm -f *.vvp *.vcd
