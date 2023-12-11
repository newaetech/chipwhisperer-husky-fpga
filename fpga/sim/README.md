# Testbench Architecture Notes
A combination of block-level and top-level testbenches is used to validate
Husky in simulation. "Husky" refers to several variants: the [original
(regular) Husky](https://rtfm.newae.com/Capture/ChipWhisperer-Husky/), the
"Plus" variant (same as original Husky except larger FPGA), and the "Pro"
variant (in very early development). The same set of testbenches is used for
all variants.

This page explains the testbench architecture and is intended for
developers.  For instructions on simply *running* simulations, see
[here](../../README.md#verilog-simulation).

## Top-Level Testbench
The top-level Husky testbench uses [cocotb](https://github.com/cocotb/cocotb).

### Improvements over legacy Verilog testbench:
Verification for original Husky development was done with a simpler 
[Verilog testbench](cwhusky_tb.v) which is no longer used or maintained. The
new cocotb testbench is a big step up and brings the following improvements:

- Concurrent captures from multiple sources, triggered at the same
  time and/or independently. This is the most significant improvement, and
  the impetus for moving to cocotb; it would have been hard and messy to do
  this in Verilog.
- Multiple (back-to-back) captures, each with distinct capture parameters
- Proper trace and LA captures.
- No loss of coverage: there is nothing covered by the Verilog testbench
  but not by the cocotb testbench (one exception is multiple glitches:
  see ["What's not covered"](#whats-not-covered) below for justification).
- More complete glitch testing.


### What's not covered:
- The pattern-matching side of TraceWhisperer is not exercised here; this is
  covered at the block level in the [TraceWhisperer repository](https://github.com/newaetech/tracewhisperer/tree/master/sim).
- `ext_continuous` glitches when ADC is active. To do this
  properly would likely require a different job <-> trigger interface.
- Not all possible triggering mechanisms are covered -- there are simply too
  many to do this efficiently. Additional coverage is obtained from
  [on-target testing](https://github.com/newaetech/chipwhisperer/blob/develop/tests/test_husky.py).
- Multiple glitches (`scope.glitch.num_glitches > 1`), because:
    - it's well covered by [on-target testing](https://github.com/newaetech/chipwhisperer/blob/develop/tests/test_husky.py);
    - it's isolated logic (not affected by changes to other parts of the
      code base);
    - it's stable code that is not expected to be touched.


### Testbench Components
The cocotb testbench is comprised of the following files:

#### 1. `test_husky.py`
Contains the `Harness` class which does the following:
- initialize DUT inputs, including clocks and reset
- registers "tests" and launches them (e.g. LA\_CAPTURE, ADC\_CAPTURE,
  etc...)
- notable components:
    - `queue`: used to enforce concurrency rules:
        - each capture can be active concurrently with other captures
        - no read can occur when another read *or* capture is occurring
    - `read_lock`: used to ensure only one source can be read at a time
    - `trigger_lock`: an extra layer of locking to ensure no reading is
      initiated while triggering
    - `inc_error`: maintains the global error counter

It also contains two `@cocotb.test` methods, which define and execute the
actual tests that are run:
1. `reg_rw()`
    - basic register R/W test
    - starts three threads, each randomly writes and reads back a separate register
    - validates basic R/W operation (e.g. at the USB interface level)
    - validates the testbench USB interface lock mechanism

2. `capture()`
    - This is the main testcase which covers "everything else"; it is used
      to test ADC, LA, trace, and glitch captures.
    - Instantiates `LATest`, `ADCTest`, `TraceTest`, `GlitchTest` objects as
      per command-line options and registers them with the `Harness`, which
      will then kick off each test's `_run()` method.


#### 2. `test_husky_tests.py`
Contains the `GenericTest` class, as well as extension classes for each
of the "sources" (`LATest`, `ADCTest`, `TraceTest`, and `GlitchTest`). The
general idea is that the main `GenericTest._run()` method runs each source
capture in a generic fashion by calling source-specific methods from the
extension classes.

`_run()` is the main routine that runs the input side of the test (i.e.
      triggering and driving the capture).

The `_run()` instances for each of the ADC, LA, trace and glitch test
objects generate their own jobs, including arming and triggering,
independently of one another.

Much of the complexity in `_run()` stems from the capability of allowing one
capture to (optionally) trigger another capture (e.g. an `ADCTest` trigger
can also trigger a `TraceTest`). This is called "downstream triggering" in
the source; it represents the scenario where multiple sources are triggered
by the same trigger event simultaneously.  One source will be the "master"
and generate the trigger; the `_run()` instance for that source checks if
any other source could also be triggered by trigger event, and if so that
other source(s) becomes a "downstream triggered" job, by adding to that
source's `external_jobs` queue.  This is all relatively easy to follow in
`_run()`; the complexity comes from doing everything in the right order to
avoid deadlock.

This level of complexity may not have been warranted for the regular Husky
since each of its captures is managed independently; however with the Pro
this is no longer true: all captures go to DDR memory via the
[ddr.v](../hdl/ddr.v) module and contend for access to store incoming
samples, so it's very important to properly test multiple captures in flight
simultaneously.

Husky offers a huge number of triggering mechanism, and they are not all
covered. The supported triggers for each source are as follows:
- ADC can be triggered manually or by IO4.
- LA, trace, glitch can be triggered manually or "downstreamed" from ADC
  (which could be manual or IO4).
- LA can also be triggered from USERIO.
- There is no other "convenient" triggering mechanism for glitch or trace,
  so they are only covered manually or downstreamed from the ADC (IO4).  The
  cost/complexity of improving this is high, and other triggering mechanisms
  are tested on-target by
  [test\_husky.py](https://github.com/newaetech/chipwhisperer/blob/develop/tests/test_husky.py),
  and so this is considered an acceptable coverage hole.

Once a job is triggered, it's sent over to the corresponding checker (the
associated `GenericCapture` object) for verification.


#### 3. `test_husky_captures.py`
Contains the `GenericCapture` class. As with `GenericTest`, the idea is that
the `GenericCapture._run()` method runs the verification for each source in
a source-agnostic way by calling source-specific methods from the extension
classes (`LACapture`, `ADCCapture`, `TraceCapture` and `GlitchCapture`). The
exception to this is `GlitchCapture`, which is sufficiently different to
merit its own custom `_run()` method.

In order to validate the captured data, the first write for each source is
"caught" by peaking inside the DUT with `_catch_first_write()`. All
captures use a ramp (count-up) pattern, so only the first write needs to be
"caught".


#### 4. `husky_registers.py`
Provides the `Registers` class for doing reads and writes over Husky's
USB interface. A lock mechanism is employed to allow all of the `*Test` and
`*Capture` instances to talk to Husky simultaneously without conflicting
with each other.

(Note: `cw310_registers.py` is a variant with slightly different timing, to
validate the development build that uses the CW310 platform.)


## Block-Level Testbenches

### SAD
Basic but careful testing of SAD Verilog modules (there have been multiple
in the development history of Husky), implemented by
[sad\_tb.v](../sim/sad_tb.v):
- generates a random SAD reference;
- verifies that an input sequence that is close to the reference, but just
  over the threshold, does not generate a trigger;
- verifies that an input sequence that is under the threshold does generate
  a trigger at the correct time. 

Since advanced SAD implementations can be tricky to debug, this can be
useful in simulating a "normal" SAD implementation alongside a more advanced
implementation (i.e. driving both implementations identically, and seeing
where their outputs diverge).

### Edge
Implemented by [edge\_tb.v](edge_tb.v). Tests the
[edge\_trigger.v](../hdl/edge_trigger.v) trigger module
(`scope.trigger.module = 'edge_counter'`), which triggers when a specified
number of rising and falling edges are seen on a trigger line.

### Trigger Sequencer
Implemented by [test\_trigger\_sequencer.py](test_trigger_sequencer.py).
Exhaustive cocotb-driven verification of
[trigger\_sequencer.v](../hdl/trigger_sequencer.v), with a parameterizable
number of input triggers, with randomized sequences and time windows.

### TraceWhisperer
See the [TraceWhisperer repository](https://github.com/newaetech/tracewhisperer/tree/master/sim).

