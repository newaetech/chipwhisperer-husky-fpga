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
* `clk_usb` clock
* setup and/or hold violations on the `ADC_DP` inputs.

Violations on these clocks came and went during development. Since Vivado is
deterministic (e.g. if you re-run implementation without any changes, you'll
get the same violations), the best way to get rid of timing violations is to
change the synthesis and/or implementation strategies and try again.

There should be no violations on inter-clock paths. Husky's [implementation
constraints](fpga/vivado/cwhusky.xdc) makes liberal use of `set_clock_groups
-asynchronous` exceptions, and so great care must be taken when dealing with
logic which uses multiple clocks (of which there are *many!*).

Occasionally, a bitfile can be obtained where  FPGA register reads/writes
are unreliable (i.e. [`test_husky.py`'s](#on-target-testing) `test_reg_rw()`
test will fail), which makes the bitfile useless. Again, the solution is to
re-compile with a different synthesis or implementation strategy. If this
occurs, connecting to the scope object usually returns this error message:
"Failed to update the MMCM secondary divider(...)". This message is a
symptom, not a cause -- it occurs because read/writes are not working
correctly.  (The root cause of this issue is likely incorrect constraints on
the SAM3U/FPGA interface; this is hard to correct because Husky uses the
SAM3U SMC interface out-of-spec to squeeze as much throughput out of it as
possible in streaming mode.)

The only critical warnings in the implementation log file should relate to
inconsequential missing IP modules (e.g. ILAs) and the the last three
`dbg_hub` commands.

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

For simulations, all of the Vivado IP (MMCMs, XADC, clock and I/O
primitives) is bypassed with the exception of the FIFOs. This is done with
`` `ifndef __ICARUS__`` in the Verilog source. This means that simulations
can't fully cover all scenarios, especially with regards to different clock
rates and their interactions. Different clock rates are covered extensively
by [on-target testing](#on-target-testing).

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
* whether triggering from trace works correctly;
* whether different clock rates works correctly.

# Debugging

Simulation is always best, but sometimes bugs don't show up in simulation
because the simulation environment isn't a perfect reconstruction of
reality.

To hunt down bugs on the FPGA, you can either:
* route signals of interest to the front 20-pin header and use an external
  logic analyzer (`scope.userio` already has a few options for this, and can
  be extended to add additional signals);
* use the internal `scope.LA` logic analyzer (again, several groups of
  internal signals are already routed to it, and more can be added);
* use Xilinx ILAs.

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

