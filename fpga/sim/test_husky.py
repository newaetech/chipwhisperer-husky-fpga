import cocotb
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles, Join
from cocotb.clock import Clock
from cocotb.queue import Queue
from cocotb.handle import Force, Release
#from cocotb.regression import TestFactory
import random
import math
from cw310_registers import Registers
import numpy as np


class GenericTest(object):
    def __init__(self, dut, harness, registers, num_captures):
        self.clk = dut.clk_usb
        self.dut = dut
        self.harness = harness
        self.registers = registers
        self.num_captures = num_captures
        self.checker = None
        self.dut_job_signal = None
        self._coro = None
        self.dispatch_id = 0
        self.name = None

    def start(self) -> None:
        """Start test thread"""
        if self._coro is not None:
            raise RuntimeError("Capture already started")
        self._coro = cocotb.start_soon(self._run())
        if self.checker is None:
            raise RuntimeError("checker not defined")
        self.checker.start()

    def stop(self) -> None:
        """Stop test thread"""
        if self._coro is None:
            raise RuntimeError("Capture never started")
        self._coro.kill()
        self._coro = None

    async def done(self) -> None:
        """ wait for _run() to complete """
        await Join(self._coro)

    async def _job_setup(self) -> dict:
        """ Generate and program properties of the job that will be run.
        Dictionary of values which will be passed to the corresponding
        checker(GenericCapture) instance.
        """
        self.dut._log.error("This must be implemented in child class.")

    async def _dispatch_delay(self) -> None:
        """ Allow for a delay between the job being dispatched and the
        corresponding checker(GenericCapture) instance being notified of it.
        """
        self.dut._log.error("This must be implemented in child class.")

    async def _trigger(self) -> None:
        """ Trigger the DUT capture.
        """
        self.dut._log.error("This must be implemented in child class.")

    async def _initial_setup(self) -> None:
        """ Initial DUT setup to do prior to the main dispatch loop.
        """
        self.dut._log.error("This must be implemented in child class.")

    async def _run(self) -> None:
        """ Main run loop. """
        self.dut_job_signal.value = cocotb.binary.BinaryValue("xxxxxxxx")
        await self._initial_setup()
        for cap in range(self.num_captures):
            self.dut_job_signal.value = self.dispatch_id
            job = await self._job_setup()
            self.dut._log.info("%6s Triggering  job number %d: %s" %(self.name, self.dispatch_id, job))
            await self._trigger()
            await self._dispatch_delay()
            self.checker.jobs.put_nowait(job)
            result = await self.checker.results.get()
            assert result['errors'] == 0
            self.dispatch_id += 1



class GenericCapture(object):
    def __init__(self, dut, harness, dut_reading_signal):
        self.clk = dut.clk_usb
        self.dut = dut
        self.harness = harness
        self.dut_reading_signal = dut_reading_signal
        self.jobs = Queue()
        self.results = Queue()
        self._coro = None
        self.job_id = 0
        self.name = None

    def start(self) -> None:
        """Start capture thread"""
        if self._coro is not None:
            raise RuntimeError("Capture already started")
        self._coro = cocotb.start_soon(self._run())

    def stop(self) -> None:
        """Stop capture thread"""
        if self._coro is None:
            raise RuntimeError("Capture never started")
        self._coro.kill()
        self._coro = None

    async def _pre_read_wait(self, job) -> None:
        """ Wait time after job is received. Intended to be used to account for
        the DUT to process the job, before we can go obtain the job result.
        """
        self.dut._log.error("This must be implemented in child class.")

    async def _initiate_read(self) -> None:
        """ Set up the read and ensure that data is available to be read.
        """
        self.dut._log.error("This must be implemented in child class.")

    async def _read_samples(self, job) -> list:
        """ Read all the samples from DUT. Should return actual samples, not
        raw read data (e.g. a list of 12-bit samples, not a list of bytes that
        encode 12-bit samples)
        """
        self.dut._log.error("This must be implemented in child class.")

    def _check_samples(self, job, data) -> int:
        """ Check <data> for errors. Return the number of errors seen.
        """
        self.dut._log.error("This must be implemented in child class.")

    async def _run(self) -> None:
        """ Main run loop. """
        self.dut_reading_signal.value = 0
        self.job_id = 0
        while True:
            job = await self.jobs.get()
            await self._pre_read_wait(job)
            await self._initiate_read()
            self.dut_reading_signal.value = 1
            self.dut._log.info("%6s Starting read for job  %d: %s" % (self.name, self.job_id, job))
            data = await self._read_samples(job)
            self.dut._log.info("%6s Done read (job %d)" % (self.name, self.job_id))
            self.dut_reading_signal.value = 0
            errors = self._check_samples(job, data)
            self.results.put_nowait ({"errors": errors})
            self.job_id += 1



class ADCTest(GenericTest):
    def __init__(self, dut, harness, registers, dut_job_signal, dut_reading_signal, num_captures=5):
        super().__init__(dut, harness, registers, num_captures)
        self.dut_job_signal = dut_job_signal
        self.checker = ADCCapture(dut, harness, dut_reading_signal)
        self.capture_min = None
        self.capture_max = None
        self.name = 'ADC'

    async def _job_setup(self) -> dict:
        samples = random.randint(self.capture_min, self.capture_max)
        await self.registers.write(16, self.registers.to_bytes(samples, 4))
        bits_per_sample = 12
        return {"samples": samples, "bits_per_sample": bits_per_sample}

    async def _initial_setup(self) -> None:
        await self.registers.write(121, [1]) # use DDR and set ADC ramp mode

    async def _dispatch_delay(self) -> None:
            await ClockCycles(self.clk, random.randint(0,1000)) # allow other jobs to sneak in here

    async def _trigger(self) -> None:
        await self.trigger_now()
        # TODO: code more trigger options

    async def trigger_now(self) -> None:
        await self.registers.write(1, [0x24])
        await self.registers.write(1, [0x0c])
        await self.registers.write(1, [0x4c])



class ADCCapture(GenericCapture):
    def __init__(self, dut, harness, dut_reading_signal):
        super().__init__(dut, harness, dut_reading_signal)
        self.name = 'ADC'

    async def read_adc_data(self, samples, bits_per_sample=12):
        # do the read:
        if bits_per_sample == 12:
            bytes_to_read = math.ceil(samples*1.5)
        else:
            bytes_to_read = samples
            dut._log.error("Unsupported! (yet)")
        raw = list(await self.harness.registers.read(3, bytes_to_read))
        return raw

    async def _pre_read_wait(self, job) -> None:
        samples = job['samples']
        await ClockCycles(self.clk, samples*4) # UI clock is USB clock, so that's the dominant portion of the capture delay
        # then, wait for DDR to be done writing:
        #self.dut._log.info("waiting for DDR writing to be done...")
        not_done_writing = True
        while not_done_writing:
            await ClockCycles(self.clk, 50)
            not_done_writing = not await self.harness.ddr_done_writing()

    async def _initiate_read(self) -> None:
        #self.dut._log.info("issuing initiate read command...")
        # 1. initiate the read:
        await self.harness.registers.write(105, [0])
        await self.harness.registers.write(105, [1])
        await ClockCycles(self.clk, 50)
        # wait for read FIFO to be not empty:
        #self.dut._log.info("waiting for FIFO to not be empty...")
        empty = True
        while empty:
            await ClockCycles(self.clk, 50)
            empty = (await self.harness.registers.read(44, 2))[1] & 16

    async def _read_samples(self, job) -> list:
        samples = job['samples']
        #self.dut._log.info("starting the read (%0d samples)" % samples)
        raw = await self.read_adc_data(samples)
        data = self.processHuskyData(samples, bytearray(raw))
        return data

    def _check_samples(self, job, data) -> int:
        errors = self.check_ramp(data, stop=False, verbose=True)
        return errors

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
        #self.dut._log.info("Checking ramp (%0d samples)" % len(raw))
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



class LATest(GenericTest):
    def __init__(self, dut, harness, registers, dut_job_signal, dut_reading_signal, num_captures=5):
        super().__init__(dut, harness, registers, num_captures)
        self.dut_job_signal = dut_job_signal
        self.checker = LACapture(dut, harness, dut_reading_signal)
        self.capture_min = None
        self.capture_max = None
        self.name = 'LA'

    async def _job_setup(self) -> dict:
        samples = random.randint(self.capture_min, self.capture_max)
        if samples % 2:
            samples -= 1
        # TODO: randomize these too:
        capture_width = 4
        downsample = 0
        await self.registers.write(77, self.registers.to_bytes(samples, 4))
        await self.registers.write(78, [downsample])
        if capture_width == 4:
            await self.registers.write(76, [0x86])   # LA_CAPTURE_GROUP: group 6 in 4-bit capture mode
        else:
            await self.registers.write(76, [0x06])   # LA_CAPTURE_GROUP: group 6 in 9-bit capture mode
        return {"samples": samples, "capture_width": capture_width, "downsample": downsample}

    async def _initial_setup(self) -> None:
        await self.registers.write(0xed, [0]) # REG_TRACE_EN: disable trace
        await self.registers.write(71, [1])   # LA_CLOCK_SOURCE: select USB clock
        await self.registers.write(99, [1])   # LA_ENABLED

    async def _dispatch_delay(self) -> None:
            await ClockCycles(self.clk, random.randint(0,1000)) # allow other jobs to sneak in here

    async def _trigger(self) -> None:
        await self.trigger_now()
        # TODO: code more trigger options

    async def trigger_now(self) -> None:
        await self.registers.write(98, [0])   # LA_ARM
        await self.registers.write(98, [1])   # LA_ARM
        await self.registers.write(75, [1])   # LA_MANUAL_CAPTURE
        await ClockCycles(self.clk, 10)
        await self.registers.write(75, [0])   # LA_MANUAL_CAPTURE


class LACapture(GenericCapture):
    def __init__(self, dut, harness, dut_reading_signal):
        super().__init__(dut, harness, dut_reading_signal)
        self.name = 'LA'

    async def read_la_data(self, samples, capture_width=4):
        # do the read:
        if capture_width == 4:
            bytes_to_read = math.ceil(samples/2)
        else:
            # TODO (9)
            dut._log.error("Unsupported! (yet)")
        raw = list(await self.harness.registers.read(3, bytes_to_read))
        return raw

    # TODO: I think this is ok?
    async def _pre_read_wait(self, job) -> None:
        samples = job['samples']
        await ClockCycles(self.clk, samples*4) # UI clock is USB clock, so that's the dominant portion of the capture delay
        # then, wait for DDR to be done writing:
        #self.dut._log.info("waiting for DDR writing to be done...")
        not_done_writing = True
        while not_done_writing:
            await ClockCycles(self.clk, 50)
            not_done_writing = not await self.harness.ddr_done_writing()

    async def _initiate_read(self) -> None:
        #self.dut._log.info("issuing initiate read command...")
        # 1. initiate the read:
        await self.harness.registers.write(105, [0])
        await self.harness.registers.write(105, [2])
        await ClockCycles(self.clk, 50)
        # wait for read FIFO to be not empty:
        #self.dut._log.info("waiting for FIFO to not be empty...")
        empty = True
        while empty:
            await ClockCycles(self.clk, 50)
            empty = (await self.harness.registers.read(44, 2))[1] & 16

    async def _read_samples(self, job) -> list:
        samples = job['samples']
        data = await self.read_la_data(samples)
        return data

    def _check_samples(self, job, data) -> int:
        errors = 0
        for i,byte in enumerate(data[:len(data)-8]): # TODO: for now, avoid checking the last few bytes...
            expected = (0xa1 + 2*i) % 256
            if expected != byte:
                errors += 1
                self.dut._log.error("Sample %d: expected %0x, got %0x" % (i, expected, byte))
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

    async def initialize_dut(self):
        self.dut.target_io4.value = 0
        await self.reset()
        await self.registers.write(51, [0,0,0,0,0,0xcc,0,1])  # CLOCKGLITCH_SETTINGS: set source to clk_usb (otherwise, X's propagate)
        self.dut.U_dut.reg_clockglitch.U_clockglitch.glitch_go.value = Force(0)
        await ClockCycles(self.dut.clk_usb, 10)
        self.dut.U_dut.reg_clockglitch.U_clockglitch.glitch_go.value = Release()

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
async def adc_capture(dut, samples=301, bits_per_sample=12, timeout_time=10000):
    """Basic ADC capture."""
    if 'samples' in cocotb.plusargs.keys():
        samples = int(cocotb.plusargs['samples'])
    registers = Registers(dut)
    harness = Harness(dut, registers)
    adctest = ADCTest(dut, harness, registers, dut.adc_job, dut.adc_reading, num_captures=3)
    adctest.capture_min = 300
    adctest.capture_max = 600

    await harness.initialize_dut()
    adctest.start()
    await adctest.done()

@cocotb.test()
async def la_capture(dut, timeout_time=10000):
    """Basic LA capture."""
    registers = Registers(dut)
    harness = Harness(dut, registers)
    latest = LATest(dut, harness, registers, dut.la_job, dut.la_reading, num_captures=3)
    latest.capture_min = 300
    latest.capture_max = 600

    await harness.initialize_dut()
    latest.start()
    await latest.done()

@cocotb.test()
async def all_capture(dut, timeout_time=10000):
    """Concurrent captures of ADC and LA."""
    registers = Registers(dut)
    harness = Harness(dut, registers)

    latest = LATest(dut, harness, registers, dut.la_job, dut.la_reading, num_captures=3)
    latest.capture_min = 30
    latest.capture_max = 60

    adctest = ADCTest(dut, harness, registers, dut.adc_job, dut.adc_reading, num_captures=3)
    adctest.capture_min = 30
    adctest.capture_max = 60

    await harness.initialize_dut()
    latest.start()
    adctest.start()
    await latest.done()
    await adctest.done()

