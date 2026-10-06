# ADC Storage Details
*or "How to make a **really** big FIFO go **really** fast on a **really** big FPGA!"*


## Summary
Storing lots of high-speed power samples in an FPGA can be tricky. FPGAs like
the Artix7 that's at the heart of the ChipWhisperer Huskies have a substantial
amount of on-board storage, but using all of that storage at a high sample rate
can run into limitations. In this write-up we'll explain Husky's original
sample storage architecture, the limitations that were encountered when trying
to scale up speed and storage, and how the architecture was modified to
overcome these limitations.


In this post I'll explain the original approach to collecting ADC samples in
ChipWhisperer and why it was chosen, why we eventually ran into its
limitations, and what we did to overcome those limitations.

The target audience for this post are experienced FPGA designers. We will
try to keep this sufficiently high-level that less-experienced FPGA
designers can still follow along and get something out of this; if goes into
more detail than you care for, you'll likely prefer our a lighter
take on the same topic: [ADC Storage
Update](adc_highlevel_update).

For potential future ChipWhisperer contributors, we explain how the ADC
storage logic functions and the considerations, trade-offs and restrictions
that led to this design.

For the broader open-source FPGA design community, we aim to give a useful
deep dive into the variables at play when storing lots of fast data inside
an FPGA.

The source code for what's discussed here lives in
[`fpga/hdl/fifo_top_husky.v`](https://github.com/newaetech/chipwhisperer-husky-fpga/blob/develop/fpga/hdl/fifo_top_husky.v)
and its submodules.


## Background

### ChipWhisperer and FPGA storage
All ChipWhisperer devices that exist today (except for the ChipWhisperer
Nano, which does not have an FPGA) use the same architecture for storing
power traces. There is no separate memory chip: traces are stored in the
FPGA's internal storage elements.

The life of a power trace goes like this: first, the scope is armed. When
the scope is triggered, the power trace is collected and stored entirely in
FPGA memory. After the capture is complete, the host PC retrieves the power
trace. The FPGA is then ready for the next power trace.

ChipWhisperer Pro and Husky also support a "streaming" capture mode where
the power trace is sent to the host PC while it's being collected; to allows
collecting power traces that exceed the FPGA's internal storage. In
streaming mode, the bandwidth limitation of the USB 2.0 link between the
host PC and ChipWhisperer restricts the maximum sampling rate. Streaming
still requires substantial FPGA-based storage: a large enough "chunk" of
power trace data needs to be stored in the FPGA in order to efficiently send
large bursts of data over the USB interface. This is all we'll say about
streaming here; for the rest of this post, we will only concern ourselves
with the non-streaming case, where the full power trace must be stored in
the FPGA.

By far the most efficient FPGA resources for storing the power trace are
block RAMs (BRAMs). While we could use lookup tables (LUTs) instead, BRAMs
offer far more storage capacity. We use up virtually *all* the BRAMs for ADC
sample storage (in the Husky family, a small number of the BRAMs are set
aside for `scope.LA` and `scope.trace` data storage).


### Original Storage Architecture
If you've ever used a ChipWhisperer Lite, Pro, or Husky, you know that
`scope.adc` has *many* configuration options. `scope.adc.presamples` and
`scope.adc.segments` in particular impose somewhat tricky requirements on
power trace storage. 

Let's start backwards with the most simple scenario and build up from there:
if `scope.adc.samples` was the only configuration parameter, a simple solution
would be to store incoming power samples into a single large FIFO. Why a
FIFO? For one thing, we don't need the random access feature of an
addressable memory block: samples will always be stored in order, and they
will always be read back in order. Another reason for using a FIFO is that
a FIFO naturally supports our streaming mode (but we promised to not
talk about streaming, so we'll stop now).

#### Presamples
Now let's think about how `scope.adc.presamples` can be implemented. Just like
with a "normal" oscilloscope, sometimes we want to capture data *before* the
trigger event. How can we go back in time and capture those power samples?
We don't have infinite storage capacity; in fact we have *very* limited
storage capacity. Consider ChipWhisperer-Lite, which can capture up to 24573
samples; a full capture at its maximum 105 MS/s sampling rate lasts only 234
microseconds. There could be orders of magnitude more time than this elapsed
between arming the scope and the trigger event, and we have no idea when
this trigger can occur. Capturing everything between the arm event and the
trigger event, in order to catch the requested `scope.adc.presamples`, is
totally out of the question.

Fortunately, there is a simple, efficient and elegant solution. As soon as
the scope is armed, we start storing samples, until we have stored
`scope.adc.presamples` samples. From that point on, we store *and* discard
samples at the same rate, so that we keep the FIFO's fill level constant and
equal to `scope.adc.presamples`. Using a FIFO makes this dead simple: each
time we push a new sample into the FIFO, we pop and discard the oldest
sample out of it. This way, the FIFO always contains the last
`scope.adc.presamples samples`. When the trigger occurs, we keep storing
samples (up to `scope.adc.samples`) but stop discarding them, and voila- at
the end of the capture, we have our presamples and our samples. With this
mechanism, there is no additional storage required beyond what is required
to store the power trace that will be sent back to the host PC.

#### Segments
The second parameter that's a bit tricky to implement is `scope.adc.segments`.
The requirement is this: there are multiple triggers after a single arm
event and we want to store `scope.adc.samples` at every trigger (*without*
re-arming the scope and transferring data to the host PC between triggers).
If you're curious about the practical reasons for wanting to have segments,
have a look at the segments entry in our [readthedocs tips and tricks
page](https://chipwhisperer.readthedocs.io/en/latest/cw_tips_tricks/advanced_usage/segmented.html).

Segments by themselves are easy to implement; segments in conjunction with
presamples is a bit more tricky. To support both, we must split our single
large FIFO into two smaller FIFOs.

In Husky, we refer to the first FIFO as the "fast" FIFO (because it must
operate in the fast ADC sampling clock domain, in order to keep up with the
incoming samples without overflowing) and the second FIFO as the "slow" FIFO
(because it is read from the fixed 96 MHz USB clock domain). There are other
important reasons for having the slow and fast parts, but we need to explain
the functioning of these FIFOs before we get to those. The figure below
illustrates the dual-FIFO architecture. FIFO sizes are for the regular
Husky; for Husky Plus, the slow FIFO is deeper (and is actually split into
two FIFO, because the empty/full status flags on a single sufficiently deep
FIFO would have unacceptably high latency).

```{figure} ../Images/original_architecture.png
:width: 40%
:align: center
Original Husky FIFO Architecture
```


The presample storage phase uses only the fast FIFO. Once the trigger
occurs, the collected samples are emptied from the fast FIFO into the slow
FIFO. Some time after the capture is complete, all of the collected
samples are in the slow FIFO and the fast FIFO is empty; we are now ready to
start collecting the next segment's presamples into the fast FIFO, in
anticipation of the next trigger. It is crucial that the fast FIFO be empty
at this point: this allows collecting presamples ahead of the next segment
(trigger), without discarding anything from the segment just collected.

A picture helps understand how this works. In the illustrated example below
we have 4 segments, a "small" number of presamples (represented by two
rectangles), and a larger number of samples (represented by three
rectangles).

In step 1, we have collected all of segment 1's presamples. The trigger
event has not occurred yet, and so only presamples have been collected, and
these are held in the fast FIFO.

In step 2, the trigger event has occurred. The requested number of samples
for segment 1 have been collected; while this was happening, we've begun
moving segment 1 samples from the fast FIFO to the slow FIFO.

Once all segment 1 samples are in the slow FIFO, the next trigger can safely
occur; when it does, we begin collecting presamples for segment 2 (step 3).
If segment 2's trigger should occur before all of segment 2's presamples are
collected, a segmenting error would be flagged.

This process continues in an identical fashion for the remaining segments,
until, at the end, the collected samples for all segments are in the slow
FIFO and ready to be read by the host PC (step 4).

```{figure} ../Images/presamples_and_segments_operation.png
:width: 100%
:align: center
Presamples and Segments in the New Architecture
```


Now we can finish explaining why there is a "fast" and a "slow" FIFO. The fast
FIFO operates at the ADC sampling rate on both its read and write ports.
This makes it easy to support the presample mechanism, where for every
sample that is written, one is discarded.

The interface used by the host PC to read the power trace operates on a
fixed 96 MHz clock, which is below Husky's maximum ADC sampling rate.
Therefore, the slow FIFO's read port operates at this fixed 96 MHz.
Meanwhile, the fast FIFO operates at the user-specified ADC sampling
frequency. While it's handy to operate the slow FIFO at 96 MHz, it's also
very beneficial for FPGA implementation: having this large storage clocked
at a reduced rate makes timing easier to meet and provides placement
flexibility to the FPGA implementation tools (remember that we aim to use
*all* the available BRAMs).

It's important that the slow FIFO be able to "keep up" with the fast FIFO:
it must also be able to move either 200 MS/s (Husky) or 250 MS/s (Husky
Plus). This is why it must be wider than the fast FIFO. It must be able to
take in at least 250/96 = 2.6 samples per 96 MHz clock cycle; we chose to
make the slow FIFO 36 bits wide (3 samples wide) to match the underlying
Xilinx block RAM (BRAM) width of 36 bits. This maximizes memory usage,
ensuring no BRAM bits go to waste. (Note that if the maximum sampling rate
were to exceed 3x96 = 288 MS/s, then some architectural changes would be
required.)

The size of the fast FIFO limits the maximum number of presamples. However,
it should be clear from the description above that supporting both
presamples and segments requires a trade-off, because maximizing the number
of presamples would not allow for segmented captures. In the original Husky
implementation, the depth of the fast FIFO was set to 32K samples (thus
supporting up to 32K presamples).

The architecture described above is what's in Husky up to and including the 6.0
release (and on develop branch commits with `scope.fpga_buildtime` timestamps
prior to August 2026).

### Implementation Challenges
Our sample storage architecture looks great on paper, but how does it fare
in real life? In FPGA design, this theory vs practice divide usually comes
up when running the "implementation" step of generating an FPGA bitfile:
this is where the FPGA tools must figure out how to map all the design's
logic into the available FPGA resources (LUTs, BRAMs, etc...) while also
taking into account routing delays. This means both having enough resources
(i.e. we can't use more BRAMs than are available), but also physically
placing all these resources in a way that "meets timing". If you are new to
hardware design, "meeting timing" refers a signal propagating from the
output of the source flip-flip to the input of the destination flip-flop
ahead of the next clock edge. There is a maximum achievable clock rate that
depends on the physical distance between the source and destination. In the
case of Husky, all logic that is in the ADC sampling clock domain must be
able to meet 200 MHz (250 MHz for the Husky Plus)

For Husky, the sample storage architecture we've described works well.
With the slowest speed grade (-1) of the XC7A35 FPGA, we are able to use
using *almost all* of the BRAMs (49 out of 50!), reach very high LUT
utilization (over 80%) and still meet timing.

Husky Plus uses the significantly larger XC7A100 from the same family. It
has 135 BRAMs instead of 50, and a similar increase in LUTs. This larger
FPGA and its additional resources is what allows us to level up Husky's
capabilities in the Plus. (The Plus also uses a higher-performing ADC chip
that can go to 250 MS/s. See
<https://chipwhisperer.readthedocs.io/en/latest/Capture/overview.html> for a
comprehensive list of differences.)

This larger FPGA combined the bump in maximum sampling rate reveals the
limits of Husky's original sample storage architecture. Husky Plus uses the
same Verilog code as the regular Husky, except that the extra BRAM is put to
use to increase the storage capacities. So, BRAM utilization remains very
high (126 out of 135), while LUT utilization falls drastically to around
30%. Despite this, Vivado struggles to meet timing on the slower
-1 speed grade: large setup violations in excess of 1ns are seen in the ADC
sampling clock domain (timing *is* met against the fastest -3 speed grade,
but recall that the regular Husky uses the slower XC7A35-1).

Even with a custom top-level Verilog file which retains the ADC sample
storage and as little as possible as the rest of Husky, the same timing
violations are seen. The culprit? Too-long routing delays between BRAMs that
make up the FIFOs. Since the XC7A100 die is larger, some of the BRAMs are
further apart; it appears that using almost all of the BRAMs, with many of
them operating at a fast clock speed, is asking too much.

Here is an example of a failing timing path (the same shown in the companion
[higher-level writeup](adc_highlevel_update.md#the-broader-picture)).

```{figure} ../Images/semipro_bad_fifo_timing.png
:width: 50%
:align: center
Long routing delay between BRAM elements with the original architecture.
```

This particular failing path is between BRAMs of the *slow* FIFO -- which,
recall, is a dual-clock FIFO, meaning that its write side is operating at
the fast ADC rate. 

## Fixing the Problem
Several experiments were done in an attempt with an eye towards minimizing
architectural changes:

1. Reducing the size of the fast FIFO.
2. Adding "flop stages" between FIFOs.
3. Splitting the fast and slow FIFO into multiple FIFOs

None of these appeared to be very helpful in avoiding long routing delays.
Reducing the depth of the fast FIFO drastically to 4096 or less did help,
but this would have been a significant de-feature and therefore not a
viable solution. But this pointed us in the direction that we ended up
taking: is there a way to minimize the size of the fast FIFO without
impacting the maximum number of presamples?

Conceptually, the solution is quite simple. Recognize that we stated at the
outset that the FIFO that's receiving the incoming ADC samples must
operate at the ADC sampling rate. But by making this FIFO wider by a factor
X, we can reduce its operating clock speed by the same factor X. At a high
level, this is essentially what we did (however the details are a little
bit more complicated!). Some small amount of logic and storage still must
operate at the ADC sampling rate (in order to take in the incoming samples
and assemble them into the wider words). This could be done in flops; in our
case we decided to use a very small FIFO, which now makes up the first
portion of our original singular "fast FIFO". This small first FIFO then
feeds a second FIFO that is wider, with a fast write port and a slower read
port. Together, these two FIFOs replace our original "fast FIFO".

We want to retain the concept of having a "fast FIFO" and a "slow FIFO"
because there is a significant amount of logic in `fifo_top_husky.v` that is
written around the assumption that storage is divided between these two
FIFOs (in particular, in the support of presamples and segments), and we
wanted to avoid a full re-write.

For the slow FIFO, things are pretty simple and not so different from our
original architecture, except in one small but very important way:
the original slow FIFO had a fast write port (ADC sampling rate) and a
slow read port; now it operates fully in the slow (96 MHz) clock domain.
Since this is where the bulk of our storage lives, this change can make a
big difference when it comes time to place and route (recall that this is
where timing couldn't be met).

All of this is likely easier to understand with a picture:

```{figure} ../Images/new_architecture.png
:width: 70%
:align: center
New FIFO Architecture
```

### Why 72 Bits?
One of the things that should stand out from this architecture is the wider
width of the wide FIFOs. Why go from 36 to 72? We explained above that a
FIFO width that is a multiple of 36 is required to avoid "wasting" bits.
However, a 36-bit-wide FIFO at 96 MHz tops out a 288 MS/s; to avoid
additional re-architecturing in the future, it seemed wise to future-proof
the design. 72 also has the advantage of dividing both 12 and 8, thus
allowing waste-free storage for both sample sizes. With 72 bits, the *FIFOs*
can now support sampling at up to 864 MS/s in 8-bit mode, or 576 MS/s in
12-bit mode.

Now, only the very small (2K x 12) `U_fast_fifo` memory is not 36-bit
aligned. This wastes much less storage than the fast FIFO in the original
architecture (32K x 12) and is the reason this architecture increases the
maximum `scope.adc.samples` in 12-bit mode.

Changing the FIFO width to some other value is relatively easy. During
development, 48 bits was originally used. The switch from 48 to 72 was done
mostly on this commit: 
<https://github.com/newaetech/chipwhisperer-husky-fpga/commit/7c9512a>.


### Why 4 FIFOs?

It should already be clear why the fast FIFO wrapper contains 2 FIFOs; why
does the slow FIFO wrapper also have two? Both FIFOs in the slow FIFO
wrapper use the same clock and width; what gives?

One reason is that in the Xilinx FIFOs, the latency of status flags
increases with the FIFO depth. Prior to this re-architecture, Husky Plus's
slow FIFO was already split into 2 FIFOs for this reason (i.e. it was deemed
easier to split the FIFO and get faster status flag updates, than to deal
with the high latency of a single FIFO).

The other reason is that the depth of a Xilinx FIFO must be a power of 2. If
we wish to maximize sample storage and BRAM usage, having more smaller FIFOs
gives us more options.

Four FIFOs may seem overkill for this, until you remember that:
1. We wish to keep `U_fast_fifo` small (to prevent wastage and to make
   timing easier).
2. The fast FIFO wrapper determines the maximum number of presamples and
   also controls limitations on segmented captures.

For all these reasons, using two FIFOs to implement the slow FIFO wrapper is
a must.


### The Devil is in the Details: Presamples and Segments
The changes described so far take us 90% of the way to a complete solution.
At this point, it's possible to do trial implementations to validate that
these changes give us the improvements in timing that we are looking for.
But as they say, the last 10% takes 90% of the time... Here, the
complications are two-fold: how to support presamples and segments? Much
like in the original architecture, this is where things get a bit more
complicated.

We want to take the same approach to supporting presamples and segments. The
difference here is that the read port of the composite fast FIFO is 72 bits
wide and operates at the slow USB clock. So how do we achieve:
* keeping it filled at `scope.adc.presamples` before the trigger event?
* keeping exactly the last `scope.adc.presamples` when the trigger event
  occurs?

We use a very small dual-clock FIFO (which we'll call the presample FIFO) to
help us count the fast FIFO writes in the slow clock domain. Each time that
6 or 9 samples (for 12- or 8-bit mode) have been written to the fast FIFO,
we write a '1' to the presample FIFO. In the slow clock domain, when we see
that the presample FIFO is not empty, we read from it, and read from the
fast FIFO (and discard) at the same time. When the trigger occurs, we:

1. stop writing to the presample FIFO;
2. fully empty the presample FIFO (again, for every read of this FIFO we do
   a read + discard of the fast FIFO);

This ensures that all samples captured before our first desired presample
are discarded, *modulo 6 or 9*. To fix this last part, we simply note the
value of our 6 or 9 sample counter at the time of the trigger. This value
indicates where in the wide 6 or 9 sample fast FIFO output is the actual
first sample of the capture, i.e. the "offset" of the capture. We call this
value the trigger offset.

This is very simple to implement and does not cost many resources; the
presample FIFO can be quite shallow since its depth is only needed to cover
clock-domain-crossing delays; in practice, we find that 16 works for the
range of ADC clocks that are supported. And since it stores only "write
events" (not actual data), it only needs to be one bit wide (and in practice,
good synthesis tools should realize that no storage is needed at all; all
that should remain post-synthesis are read and write pointers and status
flags!).

If we did not have segments, we would be essentially done: we simply need to
store the trigger offset, so that any extra presamples are trimmed off by
the host PC. But adding segments is problematic: each segment has its own
trigger offset. Where and how should we store all these offsets? If we use a
separate FIFO to store all the per-segment offsets, we will have to limit
the maximum number of segments. The original Husky did not have any
limitation on this. (In our ECC Jupyter demos 
([sca204](https://github.com/newaetech/chipwhisperer-jupyter/tree/main/courses/sca204), 
[sca205](https://github.com/newaetech/chipwhisperer-jupyter/tree/main/courses/sca205)), 
we use 256 segments because the target is doing 256-bit ECDSA. Much more
segments than that can be useful for e.g. large-key RSA, or newer
post-quantum algorithms.)

A better solution is to store the offset alongside the ADC sample data, at
the end of each segment. This overhead will reduce the total storage
capacity, but it avoids having to put a hard limit on the number of
segments.

Implementation-wise, this is fairly simple in theory; in practice there are
some tricky and unexpected corner cases around when the per-segment offset
can be saved. We chose to inject the per-segment offset directly into the
slow FIFO; this must be done after the fast FIFO has emptied. However,
because of the behaviour and latency of Xilinx FIFO status flags, it can be
surprisingly hard to know when the fast FIFO is empty. Waiting an "extra
generous" amount of time after the segment capture is complete would
restrict how close segments can be to each other. In hindsight, it may have
been preferable to inject per-segment offsets into the fast FIFO (though
unexpected corner cases may well have popped up there too).


## Implications
While conceptually simple, these changes complicate the control logic a fair
bit.

Having to save the per-segment offset word in-line with the sample data led to
a number of tricky corner cases. Many of these corner cases are due to the
Xilinx FIFO's high status latencies. This made basic questions like "is the
FIFO actually empty?" surprisingly tricky to answer.

The design was also complicated by a desire to keep the minimum time required
between segments as small as possible (without this design goal, many things
could be simplified).

Debugging is also harder: data now has to be followed through four stages of
FIFOs, which tends to complicate finding the root cause of issues.

On the flip side, one advantage of this work that hasn't been explicitly
mentioned yet is that it should be possible to significantly increase the
maximum number of presamples without suffering timing penalties (or wasting
BRAM bits).


## Future Updates
We have written our own FIFOs (found in the [`fpga-common`
submodule](https://github.com/newaetech/fpga-common).
We use these in simulation because the Xilinx FIFO simulation models
periodically cause grief by not coming out of reset properly. However we
still use the Xilinx FIFOs for implementation because they result in
superior timing performance.

Issues can arise because our FIFO implementations do not behave identically
to the Xilinx FIFOs; in particular the latency in status flag updates are
different. It is not a simple matter to make them equal because the Xilinx
FIFO's latencies depends on their depth.

It would be great to eventually use our FIFOs for both simulation and
implementation; in addition to the simulation/implementation mismatch, the
Xilinx FIFO status behaviour has led to some complications (as discussed in
the sections above); some simplifications to the control logic could likely
be done if/when this change is made.



