# Husky vs Husky Plus
The same codebase supports both Husky and Husky Plus. The differences
between the two are summarized [here](https://chipwhisperer.readthedocs.io/en/latest/Capture/overview.html).

These differences are implemented via top-level defines which are declared in
the Vivado project files. These in turn lead to different FIFO depths and
configuration parameters.

Both Husky and Husky Plus have limitations that can make expanding their
feature set challenging.

For Husky, utilization and routing congestion are the main potential issues.
For example, supporting more USERIO clocks, or supporting more pins in
`scope.bitbanger`, should be essentially free, but the difficulty of routing
these signals leads to significant timing failures. Similarly, increasing
`pTRACE_MATCH_RULES` should only cost a relatively small number of LUTs, and
should not, from a pure logic point of view, make timing more difficult.
However in practice, it increases congestion which in turn leads to timing
failures.

For Husky Plus, utilization is significantly lower. We take advantage of this
to add more USERIO clocks and `scope.bitbanger` pin options. Power consumption
is what we have to watch for here. This is what keeps us, for example, from
increasing the SAD depth. In theory there are enough LUTs available to double
the SAD depth; in practice, if we do this, turning on the SAD module when it is
clocked at 250 MHz creates a large enough power draw that the voltage rails
(which are monitored by the FPGA's XADC module) exceed their recommended
operating limits. This is one of the reasons why it is important to do thorough
[testing](../Testing/testing).


