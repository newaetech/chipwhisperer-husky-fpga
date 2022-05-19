# ChipWhisperer-Husky
This repository contains the FPGA design and test files for
ChipWhisperer-Husky.

# Implementation
Husky uses a Xilinx XC7A35 FPGA. Implementation is done with Vivado 2020.2.

Implementation should run cleanly (no setup or hold timing violations) but
timing is tight and small timing failures can occur if you're unlucky. The
usual culprits are:
* `ADC_clk_fb` clock: in `fifo_top_husky.v` for logic around counting
  samples and segments, or writing data from the fast FIFO to the slow FIFO.
* `oberver_clk` clock: logic in the TraceWhisperer UART receiver, or in
  `reg_la.v`.
* setup and/or hold violations on the `ADC_DP` inputs.

# Testing

CW-Husky is tested in two ways:
1. Verilog simulation
2. On-target testing

## Verilog Simulation

### Requirements
* [Icarus Verilog](http://iverilog.icarus.com)
* [gtkwave](http://gtkwave.sourceforge.net)
* **no commercial tools!**

While it should be possible to simulate using Vivado, the current setup uses
iverilog and gtkwave. Try it, you'll like it!

### Running Simulations
Testcases are defined in the `regress.py` script. Run `regress.py --list` to
lists available testcases. 

To run a particular testcase: `regress.py --test <testcase>`. 

Many things are randomized when a testcase is run. To re-run a testcase with
the same randomizations, specify a `--seed <integer>`. 

Add `--dump` to generate a simulation waveform.

To run the full test suite: `regress.py --runs <number of runs>`. This
launches all simulations in parallel, so start with a smaller number to
avoid making your computer totally unresponsive for a few minutes.

Use `--tests` to regress a subset of the regression suite. For example,
`regress.py --tests glitches --runs 10` will run only the testcases which
contain "glitches" in their name.

### TraceWhisperer
Husky's Verilog testbench does not cover trace. For this, run the
TraceWhisperer testbench in its
[submodule](https://github.com/newaetech/chipwhisperer-husky-fpga/tree/main/fpga).
Verification of trace within Husky is covered by on-target testing (see
below).


## On-Target Testing
Some things can't be verified in simulation; they must be verified on the
FPGA itself.
[`test_husky.py`](https://github.com/newaetech/chipwhisperer/blob/develop/tests/test_husky.py)
runs a comprehensive series of tests automatically. Invoke it like this:
`pytest test_husky.py`.

Many of the tests can run without a target attached; others require a target
running simpleserial firmware. In particular, the trace tests require a
specific firmware to succeed; the target should be programmed with the
firmware included in `hardware/victims/firmware/simpleserial-trace/`.

Among the things covered by `test_husky.py`:
* whether reading/writing the FPGA works reliably;
* whether data from the ADC is sampled correctly by the FPGA;
* whether the advertised streaming rates can be achieved;
* whether the generated glitches have the expected shape;
* whether triggering from trace works correctly.

# Debugging

Simulation is always best, but sometimes bugs don't show up in simulation
because the simulation environment isn't a perfect reconstruction of
reality.

To hunt down bugs on the FPGA, you can either:
* route signals of interest to the front 20-pin header and use an external
  logic analyzer;
* use the internal `scope.LA` logic analyzer;
* use ILAs.

ILAs require BRAM, and Husky uses 48 of the 50 available BRAMs for storage
of ADC samples, trace samples, and `scope.LA` samples. To free up more, you
can rebuild Husky with `TINYFIFO` defined: this reduces the size of the
sample, trace, and logic analyzer FIFOs. Just be aware that you won't be
able to do long captures. 

If your issue involves streaming, things are a bit more complicated, since
streaming requires deep storage to function properly (the SAM3U reads in
bursts of 64K samples when streaming). You'll have to get creative. One
option is to build without the trace and logic analyzer, by removing the
corresponding defines in `setup.v`.

