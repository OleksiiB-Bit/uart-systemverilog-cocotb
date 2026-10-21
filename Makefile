TOPLEVEL_LANG = verilog
SIM = icarus
VERILOG_SOURCES = $(shell pwd)/baud_gen.sv \
	$(shell pwd)/uart_tx.sv \
	$(shell pwd)/uart_rx.sv \
	$(shell pwd)/uart_top.sv
COMPILE_ARGS += -g2012
TOP_LEVEL = uart_top
MODULE = test_uart
include $(shell cocotb-config --makefiles)/Makefile.sim
