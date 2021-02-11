onbreak {quit -f}
onerror {quit -f}

vsim -voptargs="+acc" -t 1ps -L xpm -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -lib xil_defaultlib xil_defaultlib.cwlite_shallow_fifo xil_defaultlib.glbl

do {wave.do}

view wave
view structure
view signals

do {cwlite_shallow_fifo.udo}

run -all

quit -force
