onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib cwlite_shallow_fifo_opt

do {wave.do}

view wave
view structure
view signals

do {cwlite_shallow_fifo.udo}

run -all

quit -force
