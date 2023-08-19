TST			?= test_name
SIM			?= vsim

FLIST_DIR	:= filelist
TESTS_DIR	:= tests
LOG_DIR		?= $(TST)

TOP_NAME	:= tb
LOG_NAME	:= $(addsuffix .log,$(TST))

VLOG_OPT	+= -work work
VLOG_OPT	+= -sv -timescale 1ps/1ps -override_timescale 1ps/1ps
VLOG_OPT	+= -f $(FLIST_DIR)/TB.lst -f $(FLIST_DIR)/verilog.lst
VLOG_OPT	+= +incdir+./tb+./tests

RUNOPT		+= -L work
RUNOPT		+= -l $(LOG_NAME)
RUNOPT		+= +test_name=$(TST)

prep :
	vlib work
	vmap work

comp : prep
	vlog $(VLOG_OPT)

run :
	@$(SIM) -c -t ps $(TOP_NAME) $(RUNOPT) -do "do wave.do"

