all: compile run

compile:
	iverilog -ccmdfile \
	-g2005-sv \
	-I../hdl \
	-Wportbind \
	-Wselect-range \

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
	vvp -lsim.log a.out -fst

clean:
	rm -f a.out
