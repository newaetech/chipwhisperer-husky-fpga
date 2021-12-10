ADC_LOW_RES=0
SLOW_ADC=0
FAST_ADC=0
NOM_ADC=0
FIFO_SAMPLES=90
PRESAMPLES=0
OFFSET_ENABLE = 0
OFFSET_MIN = 0
OFFSET_MAX = 1000
TRIGGER_DELAY=1500
READ_DELAY=100
NUM_SEGMENTS = 1
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
ERRORS_OK=0
PRESAMP_ERROR=0
DOWNSAMPLE=0

all: compile run

compile:
	iverilog -ccmdfile \
	cwhusky_tb.v \
	-g2005-sv \
	-I../hdl \
	-Wportbind \
	-Wselect-range \
	-D$(FIFOSIZE) \
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

cwlite:
	iverilog -ccmdfile_cwlite \
	-g2005-sv \
	-I../hdl \
	-Wportbind \
	-Wselect-range \

nofifo:
	iverilog -ccmdfile_nofifo \
	cwhusky_tb.v \
	-g2005-sv \
	-I../hdl \
	-Wportbind \
	-Wselect-range \
	-DNOFIFO \

lint:
	verilator --lint-only -Wall \
	-f cmdfile_nofifo \
	-I../hdl \
	-D__ICARUS__ \
	-DNOFIFO \
	--top-module cwhusky_top \
	2>&1 | tee lint.out \

fifo:
	iverilog \
	../hdl/fifo_top_husky.v \
        ../vivado/cwhusky.srcs/sources_1/ip/adc_fast_fifo/adc_fast_fifo_sim_netlist.v \
        ../vivado/cwhusky.srcs/sources_1/ip/usb_slow_fifo/usb_slow_fifo_sim_netlist.v \
        -y/mnt/c/Xilinx/Vivado/2019.2/ids_lite/ISE/verilog/src/unisims/ \
	-I../hdl \
	-g2005-sv \
	-Wportbind \
	-Wselect-range \


run:
	vvp -l$(LOGFILE) $(EXEFILE) -$(WAVEFORMAT)

clean:
	rm -f a.out results/*.vvp
