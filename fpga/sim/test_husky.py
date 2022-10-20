import cocotb
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles
from cocotb.clock import Clock
#from cocotb.regression import TestFactory
import random
from cw310_registers import Registers

class Harness(object):
    def __init__(self, dut, registers):
        self.dut = dut
        self.registers = registers
        #cocotb.start_soon(Clock(dut.clk_usb, 1, units='ns').start())
        clock_thread = cocotb.start_soon(Clock(dut.clk_usb, 1, units="ns").start())
        # TODO: initialize all DUT input values

    async def reset(self):
        await self.registers.write(28, 1)
        await self.registers.write(28, 0)

    async def register_rw_thread(self, address, size):
        while True:
            wdata = random.randint(1,2**(size*8)-1)
            #self.dut._log.info("Writing to %d at time %s" % (address, cocotb.utils.get_sim_time('ns')))
            await self.registers.write(address, wdata, size)
            await ClockCycles(self.dut.clk_usb, random.randint(0, 50))
            #self.dut._log.info("Reading from %d at time %s" % (address, cocotb.utils.get_sim_time('ns')))
            rdata = await self.registers.read(address, size)
            assert rdata == wdata, "Wrote %x but read %x" % (wdata, rdata)


@cocotb.test()
async def my_test(dut, indelay=1):
    """Try accessing the design."""
    # note: indelay argument can be defined by TestFactory... but it can also be defined via the Makefile with PLUSARGS
    #indelay = int(cocotb.plusargs['indelay'])
    registers = Registers(dut)
    harness = Harness(dut, registers)

    await harness.reset()
    await Timer(5, units="ns")  # wait a bit

    #r1 = cocotb.start_soon(harness.register_rw_thread(16))
    #r2 = cocotb.start_soon(harness.register_rw_thread(17))

    dut._log.info("indelay is %d", indelay)
    await Timer(indelay, units="ns")  # wait a bit
    await Timer(random.randint(0, 20), units="ns")  # wait a bit
    #await FallingEdge(dut.clk_usb)  # wait for falling edge/"negedge"
    #dut._log.info("cmd_arm_usb is %s", dut.U_dut.cmd_arm_usb.value)
    #assert dut.U_dut.cmd_arm_usb.value[0] == 0, "cmd_arm_usb[0] is not 0!"
    #dut._log.info("Current time: %s", cocotb.utils.get_sim_time('ns'))

    rdata = await registers.read(4)
    dut._log.info("Read: %x", rdata)
    await registers.write(4, 241)
    rdata = await registers.read(4)
    dut._log.info("Read: %x", rdata)
    await Timer(100, units="ns")  # wait a bit

    wdata = 0x12345678
    await registers.write(16, 0x12345678, 4)
    await registers.write(4, 95)
    rdata = await registers.read(16, 4)
    assert rdata == wdata, "Wrote %x but read %x" % (wdata, rdata)

# skipped by default; to run, specify TESTCASE=reg_rw on command line
@cocotb.test(skip=True)
async def reg_rw(dut, wait_cycles=1000):
    """Register R/W test."""
    if 'wait_cycles' in cocotb.plusargs.keys():
        wait_cycles = int(cocotb.plusargs['wait_cycles'])
        print("Using waitcycles")
    registers = Registers(dut)
    harness = Harness(dut, registers)
    await harness.reset()
    await ClockCycles(dut.clk_usb, 10)
    reg_thread1 = cocotb.start_soon(harness.register_rw_thread(4, 8))
    reg_thread2 = cocotb.start_soon(harness.register_rw_thread(16, 4))
    reg_thread4 = cocotb.start_soon(harness.register_rw_thread(0, 1))
    await ClockCycles(dut.clk_usb, wait_cycles)


#tf = TestFactory(test_function=my_test)
#tf.add_option('indelay', range(3))
#tf.generate_tests(prefix='fac')


