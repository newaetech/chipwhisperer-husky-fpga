# ChipWhisperer-Husky
This repository contains the FPGA design and test files for
ChipWhisperer-Husky.

# Implementation
Husky uses a Xilinx XC7A35 FPGA; Husky Plus uses an XC7A100.  Implementation is
done with Vivado 2022.1.

When opening the [Husky](fpga/vivado/cwhusky.xpr) or 
[Husky Plus](fpga/vivado/cwhusky_plus.xpr) project, Vivado will report some
"errors" about missing IP that are not actually errors and can be safely
ignored (these relate to ILA modules used in development which are not
included in the repository, because they're not used in the production
bitfile).

Implementation should run cleanly (no setup or hold timing violations) but
timing is tight and small timing failures can occur if you're unlucky. The
objective is to not have *any* timing violations. Sometimes this can be
achieved by re-running with different synthesis and/or implementation
strategies. If the changes to the source code were minor or inconsequential,
this is usually sufficient to achieve clean timing.

If not, you'll have to dig a little deeper. The three main stressors for the
implementation are:
1. Almost all of the block RAM is used (for ADC, LA, and trace sample
   storage).
2. Overall resource utilization is very high (except for Husky Plus).
3. The SAD module is particularly large, runs on a fast clock, and can have
   long routing delays due to its large size and interconnected logic.

If you are customizing the design, you can reduce block RAM usage by
reducing the size of the associated FIFOs (for an example, see what happens
when `TINYFIFO` is defined). You can reduce overall utilization by removing
modules that you do not need (e.g. SAD, glitch, trace, LA). By far the
biggest bang for your buck here is the SAD module, which is huge. Its size
can be controlled via the `pREF_SAMPLES` parameter in
[`openadc_interface.v`](fpga/hdl/openadc_interface.v).
Refer to the source code for more details about the SAD parameters that can
be adjusted. (You'll also find several different SAD implementations;
[`esad.v`](fpga/hdl/esad.v) was chosen for having the best results --
smallest size for the most SAD samples -- but feel free to experiment.)

Be aware that if you go the *other* way on SAD and *increase* its size (i.e.
on Husky Plus where there are sufficient FPGA resources to do so), this can
drive up power consumption to the point where the current draw might be too
great at higher clock frequencies, and/or the FPGA overheats (yes, this can
actually happen). The `scope.XADC` VCC and temperature alarms can be used to
protect the FPGA, but this limits useability.

There should be no violations at all on inter-clock paths. Husky's
[implementation constraints](fpga/vivado/cwhusky.xdc) makes liberal use of
`set_clock_groups -asynchronous` exceptions, and so great care must be taken
when dealing with logic which uses multiple clocks (of which there are
*many!*).

Occasionally, a bitfile can be obtained where FPGA register reads/writes
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

After any modifications to the Husky source, thorough testing should be
done, both in simulation and on-target, as explained in the next section.

# Testing

CW-Husky is tested in two ways:
1. Verilog simulation
2. On-target testing

## Verilog Simulation

### Requirements
* [Icarus Verilog](http://iverilog.icarus.com)
* [cocotb](https://github.com/cocotb/cocotb)
* [gtkwave](http://gtkwave.sourceforge.net)
* **no commercial tools!**

Note that the Vivado simulator is not supported. In theory [any simulator
supported by cocotb](https://docs.cocotb.org/en/stable/simulator_support.html)
should work; in practice, iverilog is what we use.


### Running Simulations
Testcases are defined in the `regress.py` script in `fpga/sim/`. Run
`regress.py --list` to lists available testcases. 

To run a particular testcase: `regress.py --test <testcase>`. 

Add the `--variant plus` argument to simulate the Husky Plus variant;
``--variant pro` for the Pro.

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

Simulation models for the Xilinx FIFOs are provided
[here](fpga/sim/vivado/), however these can sometimes be problematic as they
are quite finicky about how resets should be applied. The testbench applies
the reset in a way that should satisfy the Xilinx FIFO requirements but yet
somehow the FIFOs can sometimes misbehave (X's propagate, status flag remain
unvalid). 

For this reason, we developed [our own FIFOs](fpga/fpga-common/hdl). Their
behaviour is **not** idential to the Xilinx FIFOs; in particular status flag
latency is different (they also do not suffer from reset bugs 🤣), and while
they are fully functional and *can* be used for implementation, they are (a)
not guaranteed to be bug-free and (b) fare worse on timing closure. However,
in addition to not being picky about resets, they simulate *much* faster.
So, the Xilinx FIFOs are still used in implementation and remain the default
in simulation; to use the faster FIFOs in simulation, add `--fast_fifo_sim`
to `regress.py`.

More detailed notes about the testbench architecture and what it does and
doesn't cover can be found [here](fpga/sim/README.md).


### TraceWhisperer
Husky's top-level testbench does not cover trace. For this, run the
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

ILAs require BRAM, and Husky uses 49 of the 50 available BRAMs for storage
of ADC samples, trace samples, and `scope.LA` samples (on Husky Plus there
is a little bit more BRAM left to play with). To free up more, you can
rebuild Husky with `TINYFIFO` defined: this reduces the size of the sample,
trace, and logic analyzer FIFOs. Just be aware that you won't be able to do
long captures. 

If your issue involves streaming, things are a bit more complicated, since
streaming requires deep storage to function properly (the SAM3U reads in
bursts of 64K samples when streaming). You'll have to get creative. One
option is to build without the trace and logic analyzer, by removing the
corresponding defines in `setup.v`.

