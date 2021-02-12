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

run:
	vvp -lsim.log a.out -fst

clean:
	rm -f a.out
