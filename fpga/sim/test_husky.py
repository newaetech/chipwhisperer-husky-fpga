import cocotb
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles, Join
from cocotb.clock import Clock
from cocotb.queue import Queue
#from cocotb.regression import TestFactory
import random
import math
from cw310_registers import Registers
import numpy as np

class ADCTest(object):
    def __init__(self, dut, harness, registers, num_captures=5):
        self.clk = dut.clk_usb
        self.dut = dut
        self.harness = harness
        self.registers = registers
        self.num_captures = num_captures
        self._coro = None
        self.checker = CaptureRead(dut, harness)

    def start(self) -> None:
        """Start monitor"""
        if self._coro is not None:
            raise RuntimeError("Capture already started")
        self._coro = cocotb.start_soon(self._run())
        self.checker.start()

    def stop(self) -> None:
        """Stop monitor"""
        if self._coro is None:
            raise RuntimeError("Capture never started")
        self._coro.kill()
        self._coro = None

    async def done(self) -> None:
        await Join(self._coro)

    async def _run(self) -> None:
        for cap in range(self.num_captures):
            samples = random.randint(300, 600)
            await self.registers.write(16, self.registers.to_bytes(samples, 4))
            await self.trigger_now()
            await ClockCycles(self.clk, random.randint(0,1000)) # allow other jobs to sneak in here
            self.checker.jobs.put_nowait({"samples": samples, "bits_per_sample": 12})
            result = await self.checker.results.get()
            assert result['errors'] == 0

    async def trigger_now(self) -> None:
        await self.registers.write(1, [0x24])
        await self.registers.write(1, [0x0c])
        await self.registers.write(1, [0x4c])


class CaptureRead(object):
    def __init__(self, dut, harness):
        self.clk = dut.clk_usb
        self.dut = dut
        self.harness = harness
        self.jobs = Queue()
        self.results = Queue()
        self._coro = None

    def start(self) -> None:
        """Start monitor"""
        if self._coro is not None:
            raise RuntimeError("Capture already started")
        self._coro = cocotb.start_soon(self._run())

    def stop(self) -> None:
        """Stop monitor"""
        if self._coro is None:
            raise RuntimeError("Capture never started")
        self._coro.kill()
        self._coro = None

    async def _run(self) -> None:
        while True:
            dats = await self.jobs.get()
            samples = dats['samples']

            await ClockCycles(self.clk, samples*4) # UI clock is USB clock, so that's the dominant portion of the capture delay

            # Read capture:
            # 1. wait for DDR to be done writing:
            self.dut._log.info("waiting for writing to be done...")
            not_done_writing = True
            while not_done_writing:
                await ClockCycles(self.clk, 50)
                not_done_writing = not await self.harness.ddr_done_writing()

            #self.dut._log.info("issuing initiate read command...")
            # 2. initiate the read:
            await self.harness.registers.write(105, [0])
            await self.harness.registers.write(105, [1])
            await ClockCycles(self.clk, 50)

            # 2. wait for FIFO to not be empty:
            self.dut._log.info("waiting for FIFO to not be empty...")
            #from remote_pdb import RemotePdb; rpdb = RemotePdb("127.0.0.1", 4000)
            # (then: telnet 127.0.0.1 4000)

            # wait for read FIFO to be not empty:
            empty = True
            while empty:
                await ClockCycles(self.clk, 50)
                empty = (await self.harness.registers.read(44, 2))[1] & 16

            self.dut._log.info("starting the read (%0d samples)" % samples)
            raw = await self.read_adc_data(samples)

            data = self.processHuskyData(samples, bytearray(raw))
            errors = self.check_ramp(data, stop=False, verbose=True)
            self.results.put_nowait ({"errors": errors})


    async def read_adc_data(self, samples, bits_per_sample=12):
        # do the read:
        if bits_per_sample == 12:
            bytes_to_read = math.ceil(samples*1.5)
        else:
            bytes_to_read = samples
            dut._log.error("Unsupported! (yet)")
        bytes_read = 0
        bytes_remaining = bytes_to_read
        while (bytes_read < bytes_to_read):
            #new_bytes = list(target.fpga_read(3, min(bytes_remaining, 128)))
            new_bytes = list(await self.harness.registers.read(3, min(bytes_remaining, 64)))
            #dut._log.info('Reading %d bytes' % len(new_bytes))
            if bytes_read > 0:
                raw.extend(new_bytes)
            else:
                raw = new_bytes
            bytes_read += len(new_bytes)
            bytes_remaining -= len(new_bytes)
        return raw


    def processHuskyData(self, NumberPoints, data, bits_per_sample=12):
        if bits_per_sample == 12:
            if len(data)%3:
                data.extend([0]*(3-len(data)%3))
            data = np.frombuffer(data, dtype=np.uint8)
            fst_uint8, mid_uint8, lst_uint8 = np.reshape(data, (data.shape[0] // 3, 3)).astype(np.uint16).T
            fst_uint12 = (fst_uint8 << 4) + (mid_uint8 >> 4)
            snd_uint12 = ((mid_uint8 % 16) << 8) + lst_uint8
            data = np.reshape(np.concatenate((fst_uint12[:, None], snd_uint12[:, None]), axis=1), 2 * fst_uint12.shape[0])
        else:
            raise ValueError("unsupported")
        return data[:NumberPoints]


    def check_ramp(self, raw, bits_per_sample=12, segment_cycles=0, verbose=True, stop=True):
        MOD = 2**bits_per_sample
        samples = len(raw)
        current_count = raw[0]
        errors = 0
        first_error = None
        self.dut._log.info("Checking ramp (%0d samples)" % len(raw))
        for i, byte in enumerate(raw[1:]):
            if byte != (current_count+1)%MOD:
                if verbose: self.dut._log.error("Sample %d: expected %d got %d" % (i, (current_count+1)%MOD, byte))
                errors += 1
                if stop:
                    return errors
                if not first_error:
                    first_error = i
                current_count = byte
            else:
                #self.dut._log.info("Good sample! (%d)" % byte)
                current_count += 1
                if (i+2) % samples == 0:
                    current_count = (current_count + segment_cycles - samples) % MOD
        return errors



class Harness(object):
    def __init__(self, dut, registers):
        self.dut = dut
        self.registers = registers
        #cocotb.start_soon(Clock(dut.clk_usb, 1, units='ns').start())
        adc_period = random.randint(4, 20)
        self.dut._log.info("ADC clock randomized to %5.1f MHz" % (1/adc_period*1000))
        usb_clock_thread = cocotb.start_soon(Clock(dut.clk_usb, 10, units="ns").start())
        adc_clock_thread = cocotb.start_soon(Clock(dut.PLL_CLK1, adc_period, units="ns").start())
        # TODO: initialize all DUT input values

    async def reset(self):
        await self.registers.write(28, [1])
        #await ClockCycles(self.dut.clk_usb, 10)
        await self.registers.write(28, [0])

    async def ddr_done_writing(self):
        raw = await self.registers.read(105)
        if raw[0] >> 7:
            return True
        else:
            return False

    async def register_rw_thread(self, address, size):
        while True:
            wdata = random.randint(1,2**(size*8)-1)
            #self.dut._log.info("Writing to %d at time %s" % (address, cocotb.utils.get_sim_time('ns')))
            await self.registers.write(address, self.registers.to_bytes(wdata, size))
            await ClockCycles(self.dut.clk_usb, random.randint(0, 50))
            #self.dut._log.info("Reading from %d at time %s" % (address, cocotb.utils.get_sim_time('ns')))
            rdata = self.registers.from_bytes(await self.registers.read(address, size))
            assert rdata == wdata, "Wrote %x but read %x" % (wdata, rdata)


@cocotb.test(skip=True)
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
    dut._log.info("Read: %x", rdata[0])
    await registers.write(4, [241])
    rdata = await registers.read(4)
    dut._log.info("Read: %x", rdata[0])
    await Timer(100, units="ns")  # wait a bit

    wdata = 0x12345678
    await registers.write(16, registers.to_bytes(0x12345678, 4))
    await registers.write(4, [95])
    rdata = registers.from_bytes(await registers.read(16, 4))
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


@cocotb.test()
async def basic_capture(dut, samples=301, bits_per_sample=12, timeout_time=10000):
    """Basic ADC capture."""
    if 'samples' in cocotb.plusargs.keys():
        samples = int(cocotb.plusargs['samples'])
    registers = Registers(dut)
    harness = Harness(dut, registers)
    adctest = ADCTest(dut, harness, registers, num_captures=3)
    dut.target_io4.value = 0
    await harness.reset()
    await registers.write(121, [1]) # use DDR and set ADC ramp mode
    adctest.start()
    await adctest.done()


