# On-Target Testing
Some things can't be verified in simulation; they must be verified on the
FPGA itself.
[`test_husky_dev.py`](https://github.com/newaetech/chipwhisperer/blob/develop/tests/test_husky_dev.py) 
(in the main chipwhisperer repository) runs a comprehensive series of tests
automatically. Invoke it like this:
`pytest test_husky_dev.py`.

Many of the tests can run without a target attached; others require a target
running simpleserial firmware. In particular, the trace tests require a
specific firmware to succeed; the target should be programmed with the
firmware included in
[`firmware/mcu/simpleserial-trace/`](https://github.com/newaetech/chipwhisperer/blob/develop/firmware/mcu/simpleserial-trace/).

Among the things covered by `test_husky_dev.py`:
* whether reading/writing the FPGA works reliably;
* whether data from the ADC is sampled correctly by the FPGA;
* whether the advertised streaming rates can be achieved;
* whether the generated glitches have the expected shape;
* whether triggering from trace works correctly;
* whether different clock rates works correctly;
* whether temperature and voltage rails remain within recommended operating
  conditions when pushed to the limit.

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

