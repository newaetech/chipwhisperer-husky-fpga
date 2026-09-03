# ADC Storage Update

August 2026 updates on the develop branch 
([chipwhisperer repository](https://github.com/newaetech/chipwhisperer/commit/26764281f007a90bc0d0b9369a95789a73ecaf81), 
[husky repository](https://github.com/newaetech/chipwhisperer-husky-fpga/commit/1d7fc4a4d27574ea2ae7b61d5fefc6980b27fdf7))
bring a substantial upgrade to the ADC storage capabilities of Husky and
Husky Plus. In this write-up we'll briefly explain what these upgrades are
and why we made them.

Until now, documentation around Husky’s open-sourced FPGA code has been
sparse, but that is something we want to change. We are going to be adding
FPGA code documentation for two main reasons:
1. to make it easier for contributors outside of NewAE to participate in its
   development;
2. to make it easier for users to build FPGA bitfiles customized to their
   needs (for example: redistributing storage between ADC, trace, and logic
   analyzer).

This write-up is not a full technical deep-dive (one will be written soon),
but it does get a fair bit into why and how the changes discussed here were
made. If you're not interested in those details, here's what you need to
know about this update as a Husky user:

* There's a small increase in the number of ADC samples in 12-bit mode.

* There's a *large* increase in the number of ADC samples in 8-bit mode.

* There are changes to the maximum number of presamples.

* There are changes to how many samples can be collected in a segmented
  capture.

* It's now possible to downsample with segments.

* There are fewer limitations on the number of presamples, at the extremes
  of very few or very many presamples. Previously, `scope.adc.presamples`
  needed to be at least 8, and `scope.adc.samples` needed to be at least
  `scope.adc.presamples + 2`. Now, the only limitation is that presamples
  cannot be 1.

* The number of samples no longer needs to be a multiple of 3 when using
  segments.

* Previously, `scope.adc.samples` needed to be at least 7; this is no longer
  the case.

The table below lists the increase in samples, presamples, and segmented
capture sizes for Husky:

| Feature                              | Old     | New     | % Change |
|--------------------------------------|---------|---------|----------|
| max samples, 12 bits                 | 131,124 | 137,209 | **+5**   |
| max samples, 8 bits                  | 131,124 | 204,796 | **+56**  |
| max presamples, 12 bits              | 32,767  | 26,605  | -19      |
| max presamples, 8 bits               | 32,767  | 38,890  | **+19**  |
| max total segmented samples, 12 bits | 98,357  | 110,604 | **+12**  |
| max total segmented samples, 8 bits  | 98,357  | 165,906 | **+69**  |


and for Husky Plus:

| Feature                              | Old     | New     | % Change |
|--------------------------------------|---------|---------|----------|
| max samples, 12 bits                 | 327,828 | 346,246 | **+6**   |
| max samples, 8 bits                  | 327,828 | 518,344 | **+58**  |
| max presamples, 12 bits              | 32,767  | 51,163  | **+56**  |
| max presamples, 8 bits               | 32,767  | 75,745  | **+131** |
| max total segmented samples, 12 bits | 295,061 | 295,083 | negligible |
| max total segmented samples, 8 bits  | 295,061 | 442,599 | **+50**  |

Everything is improved except for the maximum number of presamples in 12-bit
mode on the regular Husky. To understand why requires a much more in-depth
discussion of Husky's storage architecture (which will be written up soon).
Without getting into such details, know that there is a trade-off between
the number of presamples and the size of segmented captures; additionally,
FIFO depths must be a power of 2, which places restrictions on the possible
landing points. The configuration we've settled on was chosen as a best
compromise. If you need more presamples, you can use the 8-bit mode. We are
also planning to soon make it easier for users to build their own customized
FPGA bitfiles.


## Details and Rationale
These changes come from a substantial re-work of Husky's ADC sample storage
architecture. Husky has always had the ability to record power samples in
either 12-bit or 8-bit resolution. However, traces were always captured at
the full resolution, regardless of the setting. The least significant bits
were dropped only when transferring the power traces back to the host PC –
this allows for a 50% faster sampling rate when streaming. But, using 8-bit
mode did not have any benefits if you were not streaming (other than reduced
storage/processing requirements on your computer).

With this update, when `scope.adc.bits_per_sample` is set to 8, Husky now
only stores 8 bits per sample; this gives approximately (but not exactly!
details below) 50% more sample storage in non-streaming mode. There is also
a more modest but not insignificant storage increase in 12-bit mode.

To understand why, we need to take a little dive into the arcane of FPGA
memory elements. By far the most efficient FPGA memory is called "block RAM"
(BRAM); on the Xilinx family that we use for Husky and Husky Plus, these
have a native width of 36 bits (why such an unusual number? because it's 32
bits, plus 4 bits that can be used either for error correction or for
additional storage). To store incoming power traces that are coming in at a
fast sampling rate, the natural storage mechanism is a FIFO (because FIFOs
don't have to allow for random access, like a more general RAM does). Now
you can create FIFOs of any width you desire; Vivado (the tool which
transforms Verilog source code into an FPGA bitfile - if you write software,
think of it as "gcc" for FPGA design) will happily map your FIFO to BRAM
elements. But it will only do so without wasting any BRAM bits if the width
is a multiple of 36 (sometimes 18 is fine too).  

In the original Husky design (up to and including the 6.0 release, as well
as on develop branch commits with `scope.fpga_buildtime`
timestamps prior to August 2026), while most of the BRAM storage was 36-bits
wide, a significant portion was not: there was a 32768 x 12 FIFO (to support
up to 32768 presamples; the reason for this will be explained in a
forthcoming in-depth architectural write-up). In this new architecture,
we've found a way to reduce the size of this FIFO down to 2048 x 12 while
still supporting a similar number of presamples. The TL;DR is that Husky can
now store more samples because there are much fewer wasted BRAM bits. This
small 2048 x 12 FIFO is now the only FIFO where bits are wasted due to not
using 36-bit-aligned storage.


## The Broader Picture
The architectural changes required to make this happen were substantial. For
the user, the immediate benefit is more samples. But the primary driver for
this change was something else: the old and wasteful 32768 x 12 presample
FIFO was clocked at the maximum sampling rate (whereas the rest of the FIFO
storage ran at a much lower, fixed 96 MHz clock). And while this worked very
well in Husky, with Husky Plus we saw that Vivado was actually struggling to
"meet timing" on the fast FIFOs. There were two reasons for this:

1. Husky Plus supports a higher maximum sampling rate (250 MHz vs 200 MHz). In
   digital hardware design, the clock speed dictates how much time a digital
   signal can take to travel from the output of one flip-flop to the input of
   the next. Going up from 200 MHz to 250 MHz means that all of the internal
   Husky logic that is clocked at the fast sampling rate has 500ps less time to
   travel from flop to flop. 

2. Husky Plus's FPGA is considerably larger than Husky's FPGA (over 3 times
   larger). BRAMs are at fixed locations on the die, and some of them are
   physically further apart than on a smaller FPGA; this leads to longer
   routing delays, which makes it harder to meet timing. The screenshot below
   from Vivado's device view of the original architecture illustrates the
   issue:

```{figure} ../Images/semipro_bad_fifo_timing.png
:width: 50%
:align: center
Long routing delay between BRAM elements with the original architecture.
```

The blocks highlighted green, purple, and yellow are the BRAM elements
recruited for the ADC sample storage FIFOs. The green blocks are a FIFO that
is written and read at the fastest clock, while the purple blocks are a FIFO
that is written at the fastest clock but read at a slower clock. The white
line (near the middle, between the two purple BRAM rows) illustrates a
critical timing path that is failing by 500ps, in large part because of the
distance between the two BRAM elements. This is in spite of using the
fastest -3 speed grade for Husky Plus (while Husky gets away with the slower
-1 speed grade).

In contrast, with the improved architecture, Vivado is able to meet timing
on all paths. The fast green FIFO is *much* smaller, which gives the tool
more flexibility in placing the BRAM elements that make up the hybrid (fast
write / slow read) purple FIFO. Even though the purple FIFO still has BRAM
elements that are fairly distant from one another, the significantly reduced
fast (green) FIFO appears to give Vivado more flexibility to place the BRAMs
that "talk" to each other closer together. The (very short) white lines
shows the critical path (the timing path that is closest to not meeting
timing) in this design.

```{figure} ../Images/new_arch_meets_timing.png
:width: 50%
:align: center
Improved routing between BRAM elements with the new architecture.
```

By making timing closure easier to achieve, we've made it easier to add more
features to Husky in the future (this applies more to Husky Plus than to
Husky, since the latter is pretty maxed-out on the FPGA side; its LUT
utilization is very high at over 80%). It also allows for more  capabilities
for whatever will come after Husky Plus.


## More Tweaks
While we had the hood up, it made sense to make the additional enhancements
that are listed at the start of this article; these were all relatively
“low-hanging fruits”.

You may notice that one limitation remains: it's not possible to combine
downsampling with presamples. There is a good reason for that! It's not
actually possible to do this (other than by collecting all the samples and
downsampling in post-processing, i.e. on the host PC) while maintaining
alignment across multiple power traces. The reason is simple: when there are
presamples, Husky must start collecting samples ahead of the trigger. But
which samples are kept and which are thrown away relative to the trigger
event that hasn't happened yet cannot be consistent across captures. So,
while it would be technically possible to combine downsampling and
presamples, it doesn't make sense in the context of ChipWhisperer.

If you want to learn more about Husky's internal FPGA architecture, look for
future updates on this site.


