# Overview
Husky uses a Xilinx XC7A35 FPGA; Husky Plus uses an XC7A100. 

The exact parts are:
* Husky: `xc7a35tftg256-1`
* Husky Plus: `xc7a100tftg256-3`

Implementation is done with Vivado 2022.1. Newer versions of Vivado have proven
unstable.

Annoyingly, Vivado 2022.1 is not supported on Windows 11, or on recent Ubuntu
releases. We use a Lubuntu 22.04.5 VM.


## Missing ILAs
When opening the project in Vivado
([fpga/vivado/cwhusky.xpr](https://github.com/newaetech/chipwhisperer-husky-fpga/blob/develop/fpga/vivado/cwhusky.xpr),
[fpga/vivado/cwhusky\_plus.xpr](https://github.com/newaetech/chipwhisperer-husky-fpga/blob/develop/fpga/vivado/cwhusky_plus.xpr)),
Vivado will report some "errors" about missing IP that are not actually errors
and can be safely ignored (these relate to ILA modules used in development
which are not included in the repository, because they're not used in the
production bitfile).


## Meeting Timing
Implementation should run cleanly (no setup or hold timing violations) but
timing is tight and small timing failures can occur if you're unlucky. The
objective is to not have *any* timing violations. It will sometimes be
necessary to change the synthesis and/or implementation strategies to achieve
timing closure. If the changes to the source code were minor or
inconsequential, this should be sufficient.

If not, you'll have to dig a little deeper. The three main stressors for the
implementation are:
1. Almost all of the block RAM is used (for ADC, LA, and trace sample
   storage).
2. Overall resource utilization is very high (except for Husky Plus).
3. The SAD module is particularly large, runs on a fast clock, and can have
   long routing delays due to its large size and interconnected logic.

There should be no violations at all on inter-clock paths. Husky's
implementation constraints
([fpga/vivado/cwhusky.xdc](https://github.com/newaetech/chipwhisperer-husky-fpga/blob/develop/fpga/vivado/cwhusky.xdc), 
[fpga/vivado/cwhusky\_100.xdc](https://github.com/newaetech/chipwhisperer-husky-fpga/blob/develop/fpga/vivado/cwhusky_100.xdc))
makes liberal use of `set_clock_groups -asynchronous` exceptions, and so great
care must be taken when dealing with logic which uses multiple clocks (of which
there are *many!*).


## Resource Utilization
Resource utilization is *very* high for Husky, for both BRAMs and LUTs.

If you are customizing the design, you can reduce block RAM usage by
reducing the size of the associated FIFOs (for an example, see what happens
when `TINYFIFO` is defined). 

You can reduce LUT utilization by removing
modules that you do not need (e.g. SAD, glitch, trace, LA). By far the
biggest bang for your buck here is the SAD module, which is huge. Its size
can be controlled via the `pREF_SAMPLES` parameter in
[`fpga/hdl/openadc_interface.v`](https://github.com/newaetech/chipwhisperer-husky-fpga/blob/develop/fpga/hdl/openadc_interface.v).
Refer to the source code for more details about the SAD parameters that can
be adjusted. (You'll also find several different SAD implementations;
[`fpga/hdl/esad.v`](https://github.com/newaetech/chipwhisperer-husky-fpga/blob/develop/fpga/hdl/esad.v)
was chosen for having the best results -- smallest size for the most SAD
samples -- but feel free to experiment.)

Be aware that if you go the *other* way on SAD and *increase* its size (i.e.
on Husky Plus where there are sufficient FPGA resources to do so), this can
drive up power consumption to the point where the current draw might be too
great at higher clock frequencies, and/or the FPGA overheats (yes, this can
actually happen). The `scope.XADC` VCC and temperature alarms can be used to
protect the FPGA, but this limits usability.

<!-- TODO: add table showing current resource utilization -->

<!-- TODO: move this to a separate page where issues of this type are listed -->
Occasionally, a bitfile can be obtained where FPGA register reads/writes
are unreliable (i.e. [`test_husky_dev.py`'s](../Testing/ontarget) `test_reg_rw()`
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
inconsequential missing IP modules (e.g. ILAs as noted above) and the the last
three `dbg_hub` commands.

After any modifications to the Husky source, thorough testing should be
done, both in simulation and on-target, as explained in the
[testing](../Testing/testing) chapter.


