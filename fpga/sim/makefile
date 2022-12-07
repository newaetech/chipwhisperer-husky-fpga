ADC_LOW_RES=0
SLOW_ADC=0
FAST_ADC=0
NOM_ADC=0
FIFO_SAMPLES=90
PRESAMPLES=0
OFFSET_ENABLE = 0
OFFSET_MIN = 0
OFFSET_MAX = 1000
SHORT_TRIGGER = 0
TRIGGER_DELAY=1500
READ_DELAY=100
NUM_SEGMENTS = 1
NUM_GLITCHES = 1
MAX_GLITCH_REPEATS = 0
MAX_GLITCH_OFFSET = 0
SEGMENT_CYCLES = 100
SEGMENT_CYCLE_COUNTER_EN = 0
TRIGGER_NOW=0
STREAM=0
STREAM_SEGMENT_THRESHOLD=512
LOGFILE=make.log
EXEFILE=a.out
WAVEFORMAT=fst
SEED=1
TIMEOUT_CYCLES=50000
DUMP=0
FIFOSIZE=REGULARFIFO
DDR_MODEL_WRITES=REGULAR_DDR_WRITES
FAST_FIFO_SIM=NOFASTFIFO
ERRORS_OK=0
PRESAMP_ERROR=0
DOWNSAMPLE=0
LINEAR_RAMP=1
INPUTS_FROM_FILE=0
REF_SAMPLES=8
BITS_PER_SAMPLE=12
EDGES=0
TRIGGERS=1
FLUSH=0
THRESHOLD=0
VERBOSE=0
COCOTB_LOG_LEVEL=INFO
NUM_CAPTURES=3
LA_CAPTURE=1
TRACE_CAPTURE=1
ADC_CAPTURE=1
MIN_SIZE=30
MAX_SIZE=100
NO_DOWNSTREAM_TRIGGERS=0

ifdef IVERILOG10
    IPATH=/usr/bin/
else
    IPATH=/usr/local/bin/
endif

all: compile run
all_sad: compile_sad run
all_edge: compile_edge run
coco: compile_coco run_coco

compile_sad:
	$(IPATH)iverilog \
	../hdl/sad.v \
	../hdl/sad_wrapper.v \
	../hdl/usb_reg_main.v \
	../hdl/cdc_pulse.v \
	sad_tb.v \
	vivado/sad_fifo_sim_netlist.v \
	-y/tools/Xilinx/Vivado/2020.2/ids_lite/ISE/verilog/src/unisims/ \
	-g2005-sv \
	-I../hdl \
	-Wportbind \
	-Wselect-range \
	-P sad_tb.pLINEAR_RAMP=$(LINEAR_RAMP) \
	-P sad_tb.pINPUTS_FROM_FILE=$(INPUTS_FROM_FILE) \
	-P sad_tb.pREF_SAMPLES=$(REF_SAMPLES) \
	-P sad_tb.pBITS_PER_SAMPLE=$(BITS_PER_SAMPLE) \
	-P sad_tb.pTHRESHOLD=$(THRESHOLD) \
	-P sad_tb.pTRIGGERS=$(TRIGGERS) \
	-P sad_tb.pFLUSH=$(FLUSH) \
	-P sad_tb.pDUMP=$(DUMP) \
	-P sad_tb.pSEED=$(SEED) \
	-P sad_tb.pVERBOSE=$(VERBOSE) \
	-P sad_tb.pTIMEOUT_CYCLES=$(TIMEOUT_CYCLES) \
	-o $(EXEFILE) \

sad_nofifo:
	$(IPATH)iverilog \
	../hdl/sad.v \
	../hdl/sad_wrapper.v \
	../hdl/usb_reg_main.v \
	../hdl/cdc_pulse.v \
	sad_tb.v \
	-g2005-sv \
	-DNOFIFO \
	-I../hdl \
	-Wportbind \
	-Wselect-range \
	-P sad_tb.pLINEAR_RAMP=$(LINEAR_RAMP) \
	-P sad_tb.pREF_SAMPLES=$(REF_SAMPLES) \
	-P sad_tb.pBITS_PER_SAMPLE=$(BITS_PER_SAMPLE) \
	-P sad_tb.pDUMP=$(DUMP) \
	-P sad_tb.pSEED=$(SEED) \
	-o $(EXEFILE) \

compile_edge:
	$(IPATH)iverilog \
	../hdl/edge_trigger.v \
	../hdl/edge_wrapper.v \
	../hdl/usb_reg_main.v \
	../hdl/cdc_pulse.v \
	edge_tb.v \
	-y/tools/Xilinx/Vivado/2020.2/ids_lite/ISE/verilog/src/unisims/ \
	-g2005-sv \
	-I../hdl \
	-Wportbind \
	-Wselect-range \
	-P edge_tb.pEDGES=$(EDGES) \
	-P edge_tb.pDUMP=$(DUMP) \
	-P edge_tb.pSEED=$(SEED) \
	-P edge_tb.pVERBOSE=$(VERBOSE) \
	-P edge_tb.pTIMEOUT_CYCLES=$(TIMEOUT_CYCLES) \
	-o $(EXEFILE) \


compile:
	$(IPATH)iverilog -ccmdfile \
	cwhusky_tb.v \
	-g2005-sv \
	-I../hdl \
	-I../tracewhisperer/hdl/ \
	-Wportbind \
	-Wselect-range \
	-D$(FIFOSIZE) \
	-DTRACE \
	-P cwhusky_tb.pADC_LOW_RES=$(ADC_LOW_RES) \
	-P cwhusky_tb.pSLOW_ADC=$(SLOW_ADC) \
	-P cwhusky_tb.pFAST_ADC=$(FAST_ADC) \
	-P cwhusky_tb.pNOM_ADC=$(NOM_ADC) \
	-P cwhusky_tb.pFIFO_SAMPLES=$(FIFO_SAMPLES) \
	-P cwhusky_tb.pPRESAMPLES=$(PRESAMPLES) \
	-P cwhusky_tb.pOFFSET_ENABLE=$(OFFSET_ENABLE) \
	-P cwhusky_tb.pOFFSET_MIN=$(OFFSET_MIN) \
	-P cwhusky_tb.pOFFSET_MAX=$(OFFSET_MAX) \
	-P cwhusky_tb.pTRIGGER_DELAY=$(TRIGGER_DELAY) \
	-P cwhusky_tb.pREAD_DELAY=$(READ_DELAY) \
	-P cwhusky_tb.pNUM_SEGMENTS=$(NUM_SEGMENTS) \
	-P cwhusky_tb.pNUM_GLITCHES=$(NUM_GLITCHES) \
	-P cwhusky_tb.pMAX_GLITCH_OFFSET=$(MAX_GLITCH_OFFSET) \
	-P cwhusky_tb.pMAX_GLITCH_REPEATS=$(MAX_GLITCH_REPEATS) \
	-P cwhusky_tb.pSHORT_TRIGGER=$(SHORT_TRIGGER) \
	-P cwhusky_tb.pSEGMENT_CYCLES=$(SEGMENT_CYCLES) \
	-P cwhusky_tb.pSEGMENT_CYCLE_COUNTER_EN=$(SEGMENT_CYCLE_COUNTER_EN) \
	-P cwhusky_tb.pTRIGGER_NOW=$(TRIGGER_NOW) \
	-P cwhusky_tb.pSTREAM=$(STREAM) \
	-P cwhusky_tb.pSTREAM_SEGMENT_THRESHOLD=$(STREAM_SEGMENT_THRESHOLD) \
	-P cwhusky_tb.pTIMEOUT_CYCLES=$(TIMEOUT_CYCLES) \
	-P cwhusky_tb.pERRORS_OK=$(ERRORS_OK) \
	-P cwhusky_tb.pPRESAMP_ERROR=$(PRESAMP_ERROR) \
	-P cwhusky_tb.pDOWNSAMPLE=$(DOWNSAMPLE) \
	-P cwhusky_tb.pDUMP=$(DUMP) \
	-P cwhusky_tb.pSEED=$(SEED) \
	-o $(EXEFILE) \

compile_coco:
	$(IPATH)iverilog -ccmdfile_coco \
	../vivado/cw310/cwhusky_cw310_cocowrapper.v \
	-g2005-sv \
	-gsupported-assertions \
	-I../hdl \
	-I../tracewhisperer/hdl/ \
	-s glbl \
	-s cwhusky_cw310_cocowrapper \
	-Wportbind \
	-Wselect-range \
	-D$(FIFOSIZE) \
	-D$(DDR_MODEL_WRITES) \
	-DTRACE \
	-DNOMIG \
	-DCW310 \
	-DPRO \
	-DNOXILINXFIFO \
	-D$(FAST_FIFO_SIM) \
	-DREGULARDDR \
	-DCOCOTB_SIM=1 \
	-P cwhusky_cw310_cocowrapper.pDUMP=$(DUMP) \
	-o $(EXEFILE) \

cwlite:
	$(IPATH)iverilog -ccmdfile_cwlite \
	-g2005-sv \
	-I../hdl \
	-Wportbind \
	-Wselect-range \

nofifo:
	$(IPATH)iverilog -ccmdfile_nofifo \
	cwhusky_tb.v \
	-g2005-sv \
	-I../hdl \
	-I../tracewhisperer/hdl/ \
	-Wportbind \
	-Wselect-range \
	-DNOFIFO \
	-DTRACE \

lint:
	verilator --lint-only -Wall \
	--error-limit 0 \
	-Wno-PINCONNECTEMPTY \
	-Wno-ASSIGNDLY \
	-f cmdfile_nofifo \
	-I../hdl/ \
	-I../tracewhisperer/hdl/ \
	-D__ICARUS__ \
	-DNOFIFO \
	-DTRACE \
	--top-module cwhusky_top \
	2>&1 | tee lint.out \

fifo:
	$(IPATH)iverilog \
	../hdl/fifo_top_husky.v \
        ../vivado/cwhusky.srcs/sources_1/ip/adc_fast_fifo/adc_fast_fifo_sim_netlist.v \
        ../vivado/cwhusky.srcs/sources_1/ip/usb_slow_fifo/usb_slow_fifo_sim_netlist.v \
        -y/mnt/c/Xilinx/Vivado/2019.2/ids_lite/ISE/verilog/src/unisims/ \
	-I../hdl \
	-DTRACE \
	-g2005-sv \
	-Wportbind \
	-Wselect-range \


run:
	$(IPATH)vvp -l$(LOGFILE) $(EXEFILE) -$(WAVEFORMAT)

# note that -M and -m arguments must immediately follow vvp, otherwise Python doesn't start!
run_coco:
	COCOTB_RESOLVE_X=RANDOM \
	TOPLEVEL=cwhusky_cw310_cocowrapper \
	TOPLEVEL_LANG=verilog \
	NUM_CAPTURES=$(NUM_CAPTURES) \
	LA_CAPTURE=$(LA_CAPTURE) \
	TRACE_CAPTURE=$(TRACE_CAPTURE) \
	ADC_CAPTURE=$(ADC_CAPTURE) \
	MIN_SIZE=$(MIN_SIZE) \
	MAX_SIZE=$(MAX_SIZE) \
	NO_DOWNSTREAM_TRIGGERS=$(NO_DOWNSTREAM_TRIGGERS) \
	MODULE=test_husky \
	COCOTB_LOG_LEVEL=$(COCOTB_LOG_LEVEL) \
	LIBPYTHON_LOC=$(shell cocotb-config --libpython) \
	$(IPATH)vvp -M $(shell cocotb-config --lib-dir) \
	-m $(shell cocotb-config --lib-name vpi icarus) \
	-l$(LOGFILE) $(EXEFILE) -$(WAVEFORMAT) \


clean:
	rm -f a.out results/*.vvp
