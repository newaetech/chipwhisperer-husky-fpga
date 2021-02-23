ADC_LOW_RES=0
SLOW_ADC=0
FAST_ADC=0
LOGFILE=make.log
WAVEFORMAT=fst
SEED=1
TIMEOUT_CYCLES= 50000
DUMP=0

all: compile run

compile:
	iverilog -ccmdfile \
	-g2005-sv \
	-I../hdl \
	-Wportbind \
	-Wselect-range \
	-P cwhusky_tb.pADC_LOW_RES=$(ADC_LOW_RES) \
	-P cwhusky_tb.pSLOW_ADC=$(SLOW_ADC) \
	-P cwhusky_tb.pFAST_ADC=$(FAST_ADC) \
	-P cwhusky_tb.pTIMEOUT_CYCLES=$(TIMEOUT_CYCLES) \
	-P cwhusky_tb.pDUMP=$(DUMP) \
	-P cwhusky_tb.pSEED=$(SEED) \

cwlite:
	iverilog -ccmdfile_cwlite \
	-g2005-sv \
	-I../hdl \
	-Wportbind \
	-Wselect-range \

nofifo:
	iverilog -ccmdfile_nofifo \
	-g2005-sv \
	-I../hdl \
	-Wportbind \
	-Wselect-range \
	-DNOFIFO \

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
	vvp -l$(LOGFILE) a.out -$(WAVEFORMAT)

clean:
	rm -f a.out
