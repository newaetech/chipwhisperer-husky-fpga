onbreak {quit -force}
onerror {quit -force}

asim -t 1ps +access +r +m+cwlite_shallow_fifo -L xpm -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.cwlite_shallow_fifo xil_defaultlib.glbl

do {wave.do}

view wave
view structure

do {cwlite_shallow_fifo.udo}

run -all

endsim

quit -force
