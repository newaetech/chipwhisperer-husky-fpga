# Verilog Simulation

## Requirements
* [Icarus Verilog](http://iverilog.icarus.com)
* [cocotb](https://github.com/cocotb/cocotb)
* [gtkwave](http://gtkwave.sourceforge.net) or [surfer](https://surfer-project.org/)
* **no commercial tools!**

Note that the Vivado simulator is not supported. In theory [any simulator
supported by cocotb](https://docs.cocotb.org/en/stable/simulator_support.html)
should work; in practice, iverilog is what we use and support.

<!-- TODO: add versioning -->

### Why Not Verilator?
True, Verilator is lightning-fast when using compiled C++ testbenches. It's
possible to interface a cocotb testbech with Verilator, but some of
Verilator's speed-up over iverilog would be lost. In practice, we find
iverilog to be plenty fast, partly thanks to `regress.py`'s ability to
dispatch multiple simulations in parallel.


## Running Simulations
Testcases are defined in the `regress.py` script in `fpga/sim/`. Run
`regress.py --list` to lists available testcases. 

To run a particular testcase: `regress.py --test <testcase>`. 

Add the `--variant plus` argument to simulate the Husky Plus variant.

<!-- TODO: add --nofifo? -->

Many things are randomized when a testcase is run. To re-run a testcase with
the same randomizations, specify a `--seed <integer>`. 

Add `--dump` to generate a simulation waveform. This will create a
`cwhusky_coco.fst` file in `fpga/sim/results` which can be opened with
`gtkwave` or `surfer`.

To run the full test suite: `regress.py --runs <number of runs>`. This
launches simulations in parallel using all your CPU's cores; to avoid
potentially making your computer unresponsive for a few minutes, use `--proc`
to limit the number of processor cores that are used.

Use `--tests` to regress a subset of the regression suite. For example,
`regress.py --tests glitches --runs 10` will run only the testcases which
contain "glitches" in their name.

For simulations, all of the Vivado IP (MMCMs, XADC, clock and I/O
primitives) is bypassed with the exception of the FIFOs. This is done with
`` `ifndef __ICARUS__`` in the Verilog source. This means that simulations
can't fully cover all scenarios, especially with regards to different clock
rates and their interactions. Different clock rates are covered extensively
by [on-target testing](ontarget).

Simulation models for the Xilinx FIFOs are provided in
`fpga/sim/vivado/`, however these can sometimes be problematic as they
are quite finicky about how resets should be applied. The testbench applies
the reset in a way that should satisfy the Xilinx FIFO requirements but yet
somehow the FIFOs can sometimes misbehave (X's propagate, status flag remain
unvalid). 

For this reason, we developed our own FIFOs; these are in the `fpga-common`
submodule, located here: `fpga/fpga-common/hdl`. Their behaviour is **not**
idential to the Xilinx FIFOs; in particular status flag latency is different
(they also do not suffer from reset bugs 🤣), and while they are fully
functional and *can* be used for implementation, they are (a) not guaranteed to
be bug-free and (b) fare worse on timing closure. However, in addition to not
being picky about resets, they simulate *much* faster. So, the Xilinx FIFOs are
still used in implementation and remain the default in simulation; to use the
faster FIFOs in simulation, add `--fast_fifo_sim` to `regress.py`.

<!-- TODO: is last line above true? -->

For more detailed notes about the testbench architecture and what it does and
doesn't cover, go to the [Testbench Architecture](architecture) section.


### TraceWhisperer
Husky's top-level testbench does not cover trace. For this, run the
TraceWhisperer testbench in its submodule here: `fpga/tracewhisperer/sim`.
Verification of trace within Husky is covered by on-target testing (see below).

<!-- TODO: add more about trace simulation, e.g. from its README -->


