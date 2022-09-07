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
DDR_TEST=0
DDR_TEST_LOOPS=2

all: compile run

nofifo:
	iverilog -ccmdfile \
	../../beh/ddr3_app_model.v \
	-g2005-sv \
	-I../../hdl \
	-I../../tracewhisperer/hdl/ \
	-Wportbind \
	-Wselect-range \
	-DNOMIG \
	-DCW310 \
	-DPRO \
	-DNOFIFO \
	-DTRACE \

compile:
	iverilog -ccmdfile_fifo \
	../../sim/cwhusky_pro_tb.v \
	../../beh/ddr3_app_model.v \
	-g2005-sv \
	-I../../hdl \
	-I../../sim \
	-I../../tracewhisperer/hdl/ \
	-Wportbind \
	-Wselect-range \
	-DNOMIG \
	-DCW310 \
	-DPRO \
	-DTRACE \
	-P cwhusky_tb.pDUMP=$(DUMP) \
	-P cwhusky_tb.pSEED=$(SEED) \
	-P cwhusky_tb.pDDR_TEST=$(DDR_TEST) \
	-P cwhusky_tb.pDDR_TEST_LOOPS=$(DDR_TEST_LOOPS) \
	-o $(EXEFILE) \

lint:
	verilator --lint-only -Wall \
	--error-limit 0 \
	-Wno-PINCONNECTEMPTY \
	-Wno-ASSIGNDLY \
	-f cmdfile \
	-I../../hdl/ \
	-I../../tracewhisperer/hdl/ \
	-D__ICARUS__ \
	-DNOMIG \
	-DCW310 \
	-DPRO \
	-DNOFIFO \
	-DTRACE \
	--top-module cwhusky_cw310_top \
	2>&1 | tee lint.out \

run:
	vvp -l$(LOGFILE) $(EXEFILE) -$(WAVEFORMAT)

clean:
	rm -f a.out results/*.vvp
