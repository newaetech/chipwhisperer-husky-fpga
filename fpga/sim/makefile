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
READ_DELAY=150
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
SHORT_SAD=0
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
GLITCH_CAPTURE=0
GLITCH_EXT_CONTINUOUS=0
MIN_SIZE=30
MAX_SIZE=100
NO_DOWNSTREAM_TRIGGERS=0
VIVADO_VERSION=2020.2
VARIANT=REGULAR
SAD=SAD_X2
FIFO_TYPE=NOXILINXFIFO
NUM_TRIGGERS=4
COUNTER_WIDTH=16
COCOTB_LOG_LEVEL=INFO

all: compile run
all_sad: compile_sad run
all_edge: compile_edge run
all_trigger_sequencer: compile_trigger_sequencer run_trigger_sequencer
coco: compile_coco run_coco

ifeq ($(VIVADO_PATH),)
  ifeq ($(OS), Windows_NT)
    VIVADO_PATH=/mnt/c/Xilinx/Vivado/
  else
    UNAME_S := $(shell uname -s)
    ifeq ($(UNAME_S),Linux)
      VIVADO_PATH=/tools/Xilinx/Vivado/
    endif
    ifeq ($(UNAME_S),Darwin)
      VIVADO_PATH=$(HOME)/tools/Xilinx/Vivado/
    endif
  endif
endif

ifeq ($(VARIANT),PRO)
    TOP=cwhusky_cw310_cocowrapper
    CMDFILE=cmdfile_cw310_pro
    EXTRARGS=-DCW310 -DPRO -DREGULARDDR -D$(DDR_MODEL_WRITES)
    CW310=1
    PRO=1
else
    TOP=cwhusky_top_cocowrapper
    CMDFILE=cmdfile
    EXTRARGS=
    CW310=0
    PRO=0
endif

compile_sad:
	iverilog \
	../hdl/sad.v \
	../hdl/sad_x2_slowclock.v \
	../hdl/sad_wrapper.v \
	../hdl/usb_reg_main.v \
	../fpga-common/hdl/cdc_pulse.v \
	../fpga-common/hdl/cdc_simple.v \
	sad_tb.v \
	vivado/sad_fifo_sim_netlist.v \
	-y/$(VIVADO_PATH)/$(VIVADO_VERSION)/ids_lite/ISE/verilog/src/unisims/ \
	-g2005-sv \
	-I../hdl \
	-Wportbind \
	-Wselect-range \
	-D$(VARIANT) \
	-D$(SAD) \
	-P sad_tb.pLINEAR_RAMP=$(LINEAR_RAMP) \
	-P sad_tb.pINPUTS_FROM_FILE=$(INPUTS_FROM_FILE) \
	-P sad_tb.pREF_SAMPLES=$(REF_SAMPLES) \
	-P sad_tb.pSHORT_SAD=$(SHORT_SAD) \
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
	iverilog \
	../hdl/sad.v \
	../hdl/sad_x2_slowclock.v \
	../hdl/sad_wrapper.v \
	../hdl/usb_reg_main.v \
	../fpga-common/hdl/cdc_pulse.v \
	sad_tb.v \
	-g2005-sv \
	-DNOFIFO \
	-D$(VARIANT) \
	-D$(SAD) \
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
	iverilog \
	../hdl/edge_trigger.v \
	../hdl/edge_wrapper.v \
	../hdl/usb_reg_main.v \
	../fpga-common/hdl/cdc_pulse.v \
	../fpga-common/hdl/cdc_simple.v \
	edge_tb.v \
	-y/$(VIVADO_PATH)/$(VIVADO_VERSION)/ids_lite/ISE/verilog/src/unisims/ \
	-g2005-sv \
	-I../hdl \
	-Wportbind \
	-Wselect-range \
	-D$(VARIANT) \
	-D$(SAD) \
	-P edge_tb.pEDGES=$(EDGES) \
	-P edge_tb.pDUMP=$(DUMP) \
	-P edge_tb.pSEED=$(SEED) \
	-P edge_tb.pVERBOSE=$(VERBOSE) \
	-P edge_tb.pTIMEOUT_CYCLES=$(TIMEOUT_CYCLES) \
	-o $(EXEFILE) \

compile_trigger_sequencer:
	iverilog -g2005-sv \
	-gsupported-assertions \
	-s trigger_sequencer_cocowrapper \
	-Wportbind \
	-Wselect-range \
	-DCOCOTB_SIM=1 \
	-P trigger_sequencer_cocowrapper.pDUMP=$(DUMP) \
	-P trigger_sequencer_cocowrapper.pNUM_TRIGGERS=$(NUM_TRIGGERS) \
	-P trigger_sequencer_cocowrapper.pCOUNTER_WIDTH=$(COUNTER_WIDTH) \
	-o $(EXEFILE) \
	../hdl/trigger_sequencer.v \
	trigger_sequencer_cocowrapper.v \

compile:
	iverilog -ccmdfile \
	-y/$(VIVADO_PATH)/$(VIVADO_VERSION)/ids_lite/ISE/verilog/src/unisims/ \
	-g2005-sv \
	-gsupported-assertions \
	-I../hdl \
	-I../tracewhisperer/hdl/ \
	-Wportbind \
	-Wselect-range \
	-D$(FIFOSIZE) \
	-D$(FAST_FIFO_SIM) \
	-D$(SAD) \
	-DTRACE \
	-D$(VARIANT) \
	-D$(FIFO_TYPE) \
	-I../tracewhisperer/hdl/ \
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
	cwhusky_tb.v \

compile_coco:
	iverilog -c$(CMDFILE) \
	-I../hdl/ \
	-I../tracewhisperer/hdl/ \
	-g2005-sv \
	-gsupported-assertions \
	-y/$(VIVADO_PATH)/$(VIVADO_VERSION)/ids_lite/ISE/verilog/src/unisims/ \
	-s $(TOP) \
	-s glbl \
	-Wportbind \
	-Wselect-range \
	-D$(FIFOSIZE) \
	$(EXTRARGS) \
	-DTRACE \
	-DNOMIG \
	-DNOXILINXFIFO \
	-D$(VARIANT) \
	-D$(FAST_FIFO_SIM) \
	-DCOCOTB_SIM=1 \
	-P $(TOP).pDUMP=$(DUMP) \
	-o $(EXEFILE) \
	../hdl/$(TOP).v \


cwlite:
	iverilog -ccmdfile_cwlite \
	-g2005-sv \
	-I../hdl \
	-y/$(VIVADO_PATH)/$(VIVADO_VERSION)/ids_lite/ISE/verilog/src/unisims/ \
	-Wportbind \
	-Wselect-range \

nofifo:
	iverilog -ccmdfile_nofifo \
	-I../hdl/ \
	-I../tracewhisperer/hdl/ \
	-g2005-sv \
	-Wportbind \
	-Wselect-range \
	-DNOFIFO \
	-DNOXILINXFIFO \
	-DLINT \
	-DTRACE \
	cwhusky_tb.v 

lint:
	verilator --lint-only -Wall \
	--error-limit 0 \
	-Wno-PINCONNECTEMPTY \
	-Wno-ASSIGNDLY \
	-f cmdfile_nofifo \
	-I../hdl/ \
	-I../tracewhisperer/hdl/ \
	-D__ICARUS__ \
	-DNOXILINXFIFO \
	-DFASTFIFOSIM \
	-DLINT \
	-DNOFIFO \
	-DNOXILINXFIFO \
	-DTRACE \
	-D$(VARIANT) \
	-D$(SAD) \
	--top-module cwhusky_top \
	2>&1 | tee lint.out \

lint_pro:
	verilator --lint-only -Wall \
	--error-limit 0 \
        -Wno-PINCONNECTEMPTY \
        -Wno-ASSIGNDLY \
        -f cmdfile_coco_nofifo \
        -I../hdl/ \
        -I../tracewhisperer/hdl/ \
        -D__ICARUS__ \
        -DPRO \
	-DCW310 \
        -DNOXILINXFIFO \
        -DFASTFIFOSIM \
        -DLINT \
        -DTRACE \
	-D$(VARIANT) \
	-D$(SAD) \
        --top-module cwhusky_cw310_top \
        2>&1 | tee lint.out \

lint_sad:
	verilator --lint-only -Wall \
        --error-limit 0 \
        -Wno-PINCONNECTEMPTY \
        -Wno-ASSIGNDLY \
        -I../hdl/ \
        -D__ICARUS__ \
        -DNOFIFO \
        -DTRACE \
        ../hdl/sad.v \
        ../fpga-common/hdl/cdc_pulse.v \
        ../fpga-common/hdl/cdc_simple.v \
        --top-module sad \
        2>&1 | tee lint.sad \
        
fifo:
	iverilog \
	../hdl/fifo_top_husky.v \
        ../vivado/cwhusky.srcs/sources_1/ip/adc_fast_fifo/adc_fast_fifo_sim_netlist.v \
        ../vivado/cwhusky.srcs/sources_1/ip/usb_slow_fifo/usb_slow_fifo_sim_netlist.v \
	-y/$(VIVADO_PATH)/$(VIVADO_VERSION)/ids_lite/ISE/verilog/src/unisims/ \
	-I../hdl \
	-DTRACE \
	-D$(VARIANT) \
	-D$(SAD) \
	-g2005-sv \
	-Wportbind \
	-Wselect-range \


run:
	vvp -l$(LOGFILE) $(EXEFILE) -$(WAVEFORMAT)

# note that -M and -m arguments must immediately follow vvp, otherwise Python doesn't start!
run_coco:
	COCOTB_RESOLVE_X=RANDOM \
	TOPLEVEL=$(TOP) \
	TOPLEVEL_LANG=verilog \
	PRO=$(PRO) \
	CW310=$(CW310) \
	NUM_CAPTURES=$(NUM_CAPTURES) \
	LA_CAPTURE=$(LA_CAPTURE) \
	TRACE_CAPTURE=$(TRACE_CAPTURE) \
	ADC_CAPTURE=$(ADC_CAPTURE) \
	GLITCH_CAPTURE=$(GLITCH_CAPTURE) \
	GLITCH_EXT_CONTINUOUS=$(GLITCH_EXT_CONTINUOUS) \
	MIN_SIZE=$(MIN_SIZE) \
	MAX_SIZE=$(MAX_SIZE) \
	STREAM=$(STREAM) \
	NO_DOWNSTREAM_TRIGGERS=$(NO_DOWNSTREAM_TRIGGERS) \
	MODULE=test_husky \
	COCOTB_LOG_LEVEL=$(COCOTB_LOG_LEVEL) \
	COCOTB_HDL_TIMEUNIT=1ns \
	LIBPYTHON_LOC=$(shell cocotb-config --libpython) \
	vvp -M $(shell cocotb-config --lib-dir) \
	-m $(shell cocotb-config --lib-name vpi icarus) \
	-l$(LOGFILE) $(EXEFILE) -$(WAVEFORMAT) \

run_trigger_sequencer:
	COCOTB_RESOLVE_X=RANDOM \
	TOPLEVEL=trigger_sequencer_cocowrapper \
	TOPLEVEL_LANG=verilog \
	FIFOTEST=$(FIFOTEST) \
	MODULE=test_trigger_sequencer \
	COCOTB_LOG_LEVEL=$(COCOTB_LOG_LEVEL) \
	LIBPYTHON_LOC=$(shell cocotb-config --libpython) \
	vvp -M $(shell cocotb-config --lib-dir) \
	-m $(shell cocotb-config --lib-name vpi icarus) \
	-l$(LOGFILE) $(EXEFILE) -$(WAVEFORMAT) \

clean:
	rm -f a.out results/*.vvp
