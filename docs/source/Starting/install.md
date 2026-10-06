# Installation
1. Install Vivado. Development is done with Vivado 2022.1, which is **not**
   supported on Windows 11 or on recent Ubuntu LTS releases. We use Ubuntu 22.04.
   We hope to move to a more recent Vivado version "soon", but have run into
   stability issues with Vivado 2023 onwards.

2. Clone the main [`chipwhisper-husky-fpga` repository](https://github.com/newaetech/chipwhisperer-husky-fpga) 
   and its submodules: 

       git clone --recurse-submodules https://github.com/newaetech/chipwhisperer-husky-fpga.git

3. Install [Icarus Verilog](https://github.com/steveicarus/iverilog) aka
   `iverilog`. On Ubuntu this can be done with `apt install iverilog`.
   Development is done with version 12.0 (which is available with Ubuntu 24).

4. Install the `cocotb` Python package (recommend via `pip`). Development is done with version 1.9.2.
   (We plan to move to `cocotb 2.x` "soon").

5. Install the `numpy` Python package (recommend via `pip`). Development is done with version 2.5.3.

6. Install `chipwhisperer` (instructions [here](https://chipwhisperer.readthedocs.io/en/latest/installation.html)).

7. (optional) Install a waveform viewer. We really like
   [`Surfer`](https://surfer-project.org/) but
   [`gtkwave`](https://github.com/gtkwave/gtkwave) also works.


## First Compilations
In your `chipwhisperer-husky-fpga` repository, go to `fpga/sim` and run:

    make compile

Next let's add the `cocotb` testbench to the mix:

    make compile_coco

Finally let's run an actual simulation:

    regress.py --test adc_capture --dump

The testcase should "pass"; you will have a simulation logfile: `results/adc_capture0.log`.

You should also get a waveform that you can open with either `gtkwave` or `surfer`: `results/cwhusky_coco.fst`.


## First Implementations
See [here](../Implementation/implementation).


