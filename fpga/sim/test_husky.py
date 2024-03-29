import cocotb
from cocotb.triggers import RisingEdge, ClockCycles, Join, Lock, Event
from cocotb.clock import Clock
from cocotb.queue import Queue
from cocotb.handle import Force, Release
from cocotb.log import SimLogFormatter
#from cocotb.regression import TestFactory
import random
import math
from test_husky_tests import ADCTest, LATest, TraceTest, GlitchTest
import numpy as np
import logging
import os
import re
import io

if int(os.getenv('CW310', '0')):
    from cw310_registers import Registers
else:
    from husky_registers import Registers

# Note: this could also be place in individual test functions by replacing root_logger by dut._log.
root_logger = logging.getLogger()
logfile = os.getenv('LOGFILE', 'make.log')
print('Logfile = %s' % logfile)
fh = logging.FileHandler(logfile, 'w')
fh.setFormatter(SimLogFormatter())
root_logger.addHandler(fh)

timeout_time = int(os.getenv('TIMEOUT_TIME', '2000'))

class Harness(object):
    def __init__(self, dut, registers, stream, is_pro, stop_first_error):
        self.dut = dut
        self.registers = registers
        self.is_pro = is_pro
        self.stop_first_error = stop_first_error
        self.slurp_defines(['../hdl/registers.v', '../tracewhisperer/hdl/defines_trace.v', '../tracewhisperer/hdl/defines_pw.v'])
        self.tests = []
        self.errors = 0
        self.allow_downstream_triggers = True
        self.active_jobs = {}
        self.queue = Queue(maxsize=4)   # maxsize represents the number of concurrent capture sources: ADC, LA, trace, glitch
                                        # The purpose of this queue is to enforce concurrency rules, which are a bit tricky:
                                        # 1. Each capture source can be active concurrently.
                                        # 2. No read can occur while another read is occuring or when a capture is occuring.
                                        # Queue entries carry no information other than their presence.
                                        # When a capture source wishes to issue a capture trigger, it first verifies that the
                                        # global read lock is not locked. It then pushes an entry into this queue; it pops the
                                        # queue when the capture is done.
                                        # On the read side, a global read lock is first acquired, and then we must wait until
                                        # this queue is empty (meaning no active captures) before starting the read.
        self._queue_contents = []
        self.read_lock = Lock()
        self.trigger_lock = Lock()
        self.shared_fifo_lock = Lock()  # used by regular Husky, which has shared storage for LA+trace, which means
                                        # trace+LA can't be simultaneously active; this lock manages that
        # Actual seed is obtained only if RANDOM_SEED is defined on vvp command line (otherwise you get 0)
        # regress.py always specifies the seed so this is fine.
        self.dut._log.info("seed: %d" % int(os.getenv('RANDOM_SEED', '0')))
        #cocotb.start_soon(Clock(dut.clk_usb, 1, units='ns').start())
        self.usb_period = 10
        if stream: # slow ADC clock *way* down in order to allow for slow FIFO reads to (usually) outpace writes, like IRL:
            self.adc_period = random.randint(50, 200)
        else:
            self.adc_period = random.randint(4, 25)
        self.dut._log.info("ADC clock randomized to %5.1f MHz" % (1/self.adc_period*1000))
        usb_clock_thread = cocotb.start_soon(Clock(dut.clk_usb, self.usb_period, units="ns").start())
        adc_clock_thread = cocotb.start_soon(Clock(dut.PLL_CLK1, self.adc_period, units="ns").start())
        ui_clock_thread = cocotb.start_soon(Clock(dut.ui_clk, 6, units="ns").start())
        self.dut.errors.value = 0

    def queue_push(self, job) -> None:
        """ Wrapper around queue.put_nowait() so we can track what's actually in the queue, to help debugging.
        """
        self.queue.put_nowait(job)
        self._queue_contents.append(job)
        self.dut._log.debug("queue contents after addition: %s" % self._queue_contents)

    def queue_get(self, job) -> None:
        """ Wrapper around queue.get_nowait() so we can track what's actually in the queue, to help debugging.
        """
        self.queue.get_nowait()
        self._queue_contents.remove(job)
        self.dut._log.debug("queue contents after removal: %s" % self._queue_contents)

    async def read_lock_acquire(self, job_name) -> None:
        """ Wrapper around read_lock.acquire() to track who has acquired it on the sim waveform
        """
        self.dut._log.info("%12s trying to acquire read_lock..." % job_name)
        await self.read_lock.acquire()
        self.dut._log.info("%12s read_lock acquired" % job_name)
        self.dut.current_read_lock.value = self.hexstring("%12s" % job_name)

    def read_lock_release(self) -> None:
        """ Wrapper around read_lock.release() to track who has acquired it on the sim waveform
        """
        self.read_lock.release()
        #self.dut.current_read_lock.value = self.hexstring("released")
        self.dut.current_read_lock.value = 0


    def slurp_defines(self, defines_files=None) -> None:
        """ Parse Verilog defines file so we can access register and bit
        definitions by name and avoid 'magic numbers'.

        Args:
            defines_files (list): list of Verilog define files to parse

        """
        self.verilog_define_matches = 0
        self.reg_addr = {} # dictionary where all the register addresses go

        if (defines_files is None) or (type(defines_files) != list):
            raise ValueError('defines_files must be provided as a list (even if it contains a single element)')

        for i,defines_file in enumerate(defines_files):
            if type(defines_file) == io.BytesIO:
                defines = io.TextIOWrapper(defines_file)
            else:
                if not os.path.isfile(defines_file):
                    self.dut._log.error('Cannot find %s.' % defines_files)
                defines = open(defines_file, 'r', encoding='utf-8')
            define_regex_comment = re.compile(r'\s*?/[/*]')
            define_regex_base  =   re.compile(r'`define')
            define_regex_reg   =   re.compile(r'`define\s+?REG_')
            define_regex_radix =   re.compile(r'`define\s+?(\w+).+?\'([bdh])([0-9a-fA-F]+)')
            define_regex_noradix = re.compile(r'`define\s+?(\w+?)\s+?(\d+)')
            if 'defines_trace.v' in defines_file:
                block_offset = self.reg_addr['TW_TRACE_REG_SELECT'] << 6
            elif 'defines_pw.v' in defines_file:
                block_offset = self.reg_addr['TW_MAIN_REG_SELECT'] << 6
            else:
                block_offset = 0
            for define in defines:
                if define_regex_comment.search(define):
                    continue
                if define_regex_base.search(define):
                    reg = define_regex_reg.search(define)
                    match = define_regex_radix.search(define)
                    if match:
                        self.verilog_define_matches += 1
                        if match.group(2) == 'b':
                            radix = 2
                        elif match.group(2) == 'h':
                            radix = 16
                        else:
                            radix = 10
                        self.dut._log.debug("REG %s:\t%d" % (match.group(1), int(match.group(3),radix)))
                        name = match.group(1)
                        value = int(match.group(3),radix) + block_offset
                    else:
                        match = define_regex_noradix.search(define)
                        if match:
                            self.verilog_define_matches += 1
                            self.dut._log.debug("REG %s:\t%d (%s)" % (match.group(1), int(match.group(2),10), match.group(2)))
                            name = match.group(1)
                            value = int(match.group(2),10) + block_offset
                        else:
                            self.dut._log.warning("Couldn't parse line: %s", define)
                    if match:
                        if ('defines_trace.v' in defines_file or 'defines_pw.v' in defines_file) and not name.startswith('REG_'):
                            continue
                        if name in self.reg_addr:
                            self.dut._log.warning("Register slurp warning: key %s already exists; replacing old value (%d) with %d" % (name, self.reg_addr[name], value))
                        if value in self.reg_addr.values() and name not in ['REGISTER_VERSION', 'TW_MAIN_REG_SELECT', 'TW_TRACE_REG_SELECT']:
                            old_key = list(self.reg_addr.keys())[list(self.reg_addr.values()).index(value)]
                            self.dut._log.warning("Register slurp warning: address %s already exists on key %s; new key %s getting the same address" % (value, old_key, name))
                        self.reg_addr[name] = value
            defines.close()
        self.dut._log.debug("Slurped %d defines." % self.verilog_define_matches)
        self.dut._log.debug("Register addresses: %s" % self.reg_addr)


    async def initialize_dut(self) -> None:
        self.dut.target_io4.value = 0
        await self.reset()
        # the reset will cause target_io4 to "lose" the 0 we'd assigned to it... possibly a simulator/cocotb bug?
        self.dut.target_io4.value = 0
        self.dut.USERIO_D.value = 0
        await self.registers.write(self.reg_addr['CLOCKGLITCH_SETTINGS'], [0,0,0,0,0,0xcc,0,1])  # set source to clk_usb (otherwise, X's propagate)
        #await self.registers.write(self.reg_addr['CLOCKGLITCH_SETTINGS'], [0,0,0,0,0,0x4c,0,1])  # set source to clk_usb (otherwise, X's propagate)
        self.dut.U_dut.reg_clockglitch.U_clockglitch.glitch_go.value = Force(0)
        await ClockCycles(self.dut.clk_usb, 10)
        self.dut.U_dut.reg_clockglitch.U_clockglitch.glitch_go.value = Release()
        await self.registers.write(self.reg_addr['NO_CLIP_ERRORS'], [3]) # disable gain errors

    async def reset(self):
        # NOTE: the Xilinx FIFO simulation models are quite sensitive to the reset timing. They can misbehave and refuse
        # to reset properly. Logfile will contain complaints of "RST must be held high for at least...", even if the stated
        # rules are followed, and the empty/full status flags may remain at X. Sometimes just changing the time when the
        # reset begins, and how long it is held for, can return correct behaviour.
        await ClockCycles(self.dut.clk_usb, 30)
        await self.registers.write(self.reg_addr['RESET'], [1])
        await ClockCycles(self.dut.clk_usb, 20)
        await self.registers.write(self.reg_addr['RESET'], [0])

    async def ddr_done_writing(self) -> bool:
        raw = await self.registers.read(self.reg_addr['REG_DDR_START_READ'])
        if raw[0] >> 7:
            return True
        else:
            return False

    async def wait_flush(self, source) -> None:
        if source == 'ADC':
            bitmask = 16
        elif source == 'LA':
            bitmask = 32
        elif source == 'trace':
            bitmask = 64
        flushing = True
        await ClockCycles(self.dut.clk_usb, 5) # give time for flushing to begin
        while flushing:
            self.dut._log.info("...waiting for %s flush to complete..." % source)
            flushing = (await self.registers.read(self.reg_addr['FIFO_STAT'], 3))[2] & bitmask

    def register_test(self, test) -> None:
        """ Add to list of running tests, so that we can later wait for all of
        them to complete via all_tests_done().
        """
        self.tests.append(test)

    async def all_tests_done(self) -> None:
        """ Wait for all tests which were registered via register_test() to finish.
        """
        for test in self.tests:
            await test.done()
        await ClockCycles(self.dut.clk_usb, 10) # to give time for fifo_watch errors to be seen

    def init_tests(self) -> None:
        """ Call after all tests have been defined and registered.
        """
        # Populate each test's downstream_triggers list, according to the
        # defined tests and each test's allowed_downstream_triggers list:
        for test in self.tests:
            for downstream in test.allowed_downstream_triggers:
                found = False
                for test2 in self.tests:
                    if test2.name == downstream:
                        found = True
                        test.downstream_triggers.append(test2)
                        break
        for test in self.tests:
            self.dut._log.debug("%s downstream_triggers: %s" % (test.name, test.downstream_triggers))

    def start_tests(self) -> None:
        """ Wait for all tests which were registered via register_test() to finish.
        """
        for test in self.tests:
            test.start()

    def inc_error(self) -> None:
        self.errors += 1
        self.dut.errors.value = self.errors
        if self.stop_first_error:
            assert False

    async def register_rw_thread(self, address, size) -> None:
        while True:
            wdata = random.randint(1,2**(size*8)-1)
            #self.dut._log.info("Writing to %d at time %s" % (address, cocotb.utils.get_sim_time('ns')))
            await self.registers.write(address, self.registers.to_bytes(wdata, size))
            await ClockCycles(self.dut.clk_usb, random.randint(0, 50))
            #self.dut._log.info("Reading from %d at time %s" % (address, cocotb.utils.get_sim_time('ns')))
            rdata = self.registers.from_bytes(await self.registers.read(address, size))
            assert rdata == wdata, "Wrote %x but read %x" % (wdata, rdata)

    @staticmethod
    def hexstring(string, max_chars=24) -> int:
        """ Convenience function to put a string onto the simulation waveform."""
        data = 0
        for i,j in enumerate(string[:max_chars]):
            data += (ord(j) << ((max_chars-1-i)*8))
        return data

    # the idea here was to track which jobs are currently active, in order to estimate the worst-case finish time for any
    # job (and set timeouts accordingly), however this doesn't account for jobs that can be created after currently in-flight jobs
    # and still impact them, and so this isn't used; saving it in case there's another need for it later
    def add_job(self, job) -> None:
        self.active_jobs[job['name']] = job
    def remove_job(self, job) -> None:
        self.active_jobs.pop(job['name'])
    def active_job_times(self) -> int:
        total = 0
        for k,j in self.active_jobs.items(): 
            total += j['capture_time_us']
        return total * 4 # 4 is fudge factor

    # all registered tests report their maximum job time; here we add them up in order to estimate the worst-case time for
    # processing a job, in order to set timeouts.
    def max_job_times(self) ->  int:
        time = 0
        for test in self.tests:
            time += test.max_job_time()
        return math.ceil(time*1.5) # 1.5 is fudge factor


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
    reg_thread1 = cocotb.start_soon(harness.register_rw_thread(harness.reg_addr['ECHO_ADDR'], 8))
    reg_thread2 = cocotb.start_soon(harness.register_rw_thread(harness.reg_addr['SAMPLES_ADDR'], 4))
    reg_thread4 = cocotb.start_soon(harness.register_rw_thread(harness.reg_addr['GAIN_ADDR'], 1))
    await ClockCycles(dut.clk_usb, wait_cycles)


@cocotb.test(timeout_time=timeout_time, timeout_unit="us")
async def capture(dut):
    """Concurrent captures of ADC, trace and LA."""


    num_captures = int(os.getenv('NUM_CAPTURES', '3'))
    min_size = int(os.getenv('MIN_SIZE', '30'))
    max_size = int(os.getenv('MAX_SIZE', '100'))
    max_presamples = int(os.getenv('MAX_PRESAMPLES', '100'))
    max_offset =  int(os.getenv('MAX_OFFSET', '100'))
    max_downsample =  int(os.getenv('MAX_DOWNSAMPLE', '1'))
    min_glitches = int(os.getenv('MIN_GLITCHES', '1'))
    max_glitches = int(os.getenv('MAX_GLITCHES', '5'))
    max_segments = int(os.getenv('MAX_SEGMENTS', '1'))
    max_segment_cycles = int(os.getenv('MAX_SEGMENT_CYCLES', '1'))
    stream = int(os.getenv('STREAM', '0'))
    is_pro = int(os.getenv('PRO', '0'))
    glitch_ext_continous = int(os.getenv('GLITCH_EXT_CONTINUOUS', '0'))
    stop_first_error = int(os.getenv('STOP_FIRST_ERROR', '1'))

    if is_pro:
        # actual limits are higher (depends on DDR model size); these are in the interest of simulation time:
        ADC_MAX = 16384
        LA_MAX = 16384
        TRACE_MAX = 16384
    else:
        LA_MAX = 4095
        TRACE_MAX = 2047
        if stream:
            ADC_MAX = 16384 # not the actual limit -- just in interest of simulation time
        else:
            ADC_MAX = 4095

    registers = Registers(dut)
    harness = Harness(dut, registers, stream, is_pro, stop_first_error)

    await harness.initialize_dut()
    if int(os.getenv('NO_DOWNSTREAM_TRIGGERS', 0)):
        harness.allow_downstream_triggers = False

    if int(os.getenv('LA_CAPTURE')):
        latest = LATest(dut, dut.clk_usb, harness, registers, dut.la_job, dut.la_reading)
        latest.num_captures = num_captures
        latest.capture_max = min(max_size, LA_MAX)
        latest.capture_min = min(min_size, latest.capture_max)
        latest.max_downsample = max_downsample
        harness.register_test(latest)

    if int(os.getenv('ADC_CAPTURE')):
        if glitch_ext_continous:
            dut._log.error('Cannot test ext_continuous glitches when ADC is active')
        adctest = ADCTest(dut, dut.PLL_CLK1, harness, registers, dut.adc_job, dut.adc_reading)
        adctest.num_captures = num_captures
        adctest.capture_max = min(max_size, ADC_MAX)
        adctest.capture_min = min(min_size, adctest.capture_max)
        adctest.max_presamples = max_presamples
        adctest.max_offset = max_offset
        adctest.max_downsample = max_downsample
        adctest.max_segments = max_segments
        adctest.max_segment_cycles = max_segment_cycles
        adctest.stream = stream
        adctest.checker.stream = stream
        harness.register_test(adctest)

    if int(os.getenv('TRACE_CAPTURE')):
        tracetest = TraceTest(dut, dut.clk_usb, harness, registers, dut.trace_job, dut.trace_reading)
        tracetest.num_captures = num_captures
        tracetest.capture_max = min(max_size, TRACE_MAX)
        tracetest.capture_min = min(min_size, tracetest.capture_max)
        harness.register_test(tracetest)

    if int(os.getenv('GLITCH_CAPTURE')):
        glitchtest = GlitchTest(dut, dut.U_dut.reg_clockglitch.glitch_mmcm1_clk_out, harness, registers, dut.glitch_job, dut.glitch_reading)
        glitchtest.num_captures = num_captures
        glitchtest.capture_min = min_glitches
        glitchtest.capture_max = max_glitches
        glitchtest.ext_continuous = glitch_ext_continous
        harness.register_test(glitchtest)
    else:
        # ensure glitch never fires:
        from test_husky_captures import GlitchCapture
        GC = GlitchCapture(dut, dut.clk_usb, harness, None)
        GC.expect_glitch(0)
        await ClockCycles(dut.clk_usb, 10)
        GC._start_watch_threads()


    harness.init_tests()
    harness.start_tests()
    await harness.all_tests_done()
    assert harness.errors == 0


