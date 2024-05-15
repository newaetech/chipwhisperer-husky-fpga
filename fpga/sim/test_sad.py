# Copyright (c) 2024, NewAE Technology Inc
# All rights reserved.
#
# Find this and more at newae.com - this file is part of the chipwhisperer
# project, http://www.chipwhisperer.com . ChipWhisperer is a registered
# trademark of NewAE Technology Inc in the US & Europe.
#
#    This file is part of chipwhisperer.
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

import cocotb
from cocotb.triggers import RisingEdge, Edge, ClockCycles, Join, Lock, Event, with_timeout, First
from cocotb.clock import Clock
from cocotb.queue import Queue
from cocotb.handle import Force, Release
from cocotb.log import SimLogFormatter
from cocotb.result import SimTimeoutError
import random
import math
import logging
import os
import io
import re

from husky_registers import Registers
from sad_model import Counter, SAD


# Note: this could also be place in individual test functions by replacing root_logger by dut._log.
root_logger = logging.getLogger()
logfile = os.getenv('LOGFILE', 'make.log')
print('Logfile = %s' % logfile)
fh = logging.FileHandler(logfile, 'w')
fh.setFormatter(SimLogFormatter())
root_logger.addHandler(fh)

timeout_time = int(os.getenv('TIMEOUT_TIME', '300'))

class Harness(object):
    def __init__(self, dut, registers, reps):
        self.dut = dut
        self.registers = registers
        self.slurp_defines(['../hdl/registers.v'])
        self.reps = reps
        self.tests = []
        self.errors = 0
        # Actual seed is obtained only if SEED is defined on vvp command line (otherwise you get 0)
        # regress.py always specifies the seed so this is fine.
        self.dut._log.info("SEED: %d" % int(os.getenv('RANDOM_SEED', '0')))
        self.usb_period = 10
        self.adc_period = random.randint(5, 20) # cover both slower and faster than USB clock
        usb_clk_thread   = cocotb.start_soon(Clock(dut.clk_usb, self.usb_period, units="ns").start())
        adc_clock_thread = cocotb.start_soon(Clock(dut.clk_adc, self.adc_period, units="ns").start())
        self.dut._log.info("ADC clock randomized to %5.1f MHz" % (1/self.adc_period*1000))
        #  initialize all DUT input values:
        self.dut.reset.value = 0
        self.dut.armed_and_ready.value = 0
        self.dut.adc_datain.value = 0
        self.dut.errors.value = 0
        self.dut.expected_trigger.value = 0

    async def reset(self):
        await ClockCycles(self.dut.clk_usb, 30)
        self.dut.reset.value = 1
        await ClockCycles(self.dut.clk_usb, 10)
        self.dut.reset.value = 0


    def register_test(self, test):
        """ Add to list of running tests, so that we can later wait for all of
        them to complete via all_tests_done().
        """
        self.tests.append(test)

    async def all_tests_done(self):
        """ Wait for all tests which were registered via register_test() to finish.
        """
        for test in self.tests:
            await test.done()
        await ClockCycles(self.dut.clk_usb, 2) # let last trigger disappear (but don't wait too long or the next trigger may occur!)

    def start_tests(self):
        """ Wait for all tests which were registered via register_test() to finish.
        """
        for test in self.tests:
            test.start()

    def inc_error(self):
        self.errors += 1
        self.dut.errors.value = self.errors

    @staticmethod
    def hexstring(string, max_chars=24):
        """ Convenience function to put a string onto the simulation waveform."""
        data = 0
        for i,j in enumerate(string[:max_chars]):
            data += (ord(j) << ((max_chars-1-i)*8))
        return data

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
                        value = int(match.group(3),radix)
                    else:
                        match = define_regex_noradix.search(define)
                        if match:
                            self.verilog_define_matches += 1
                            self.dut._log.debug("REG %s:\t%d (%s)" % (match.group(1), int(match.group(2),10), match.group(2)))
                            name = match.group(1)
                            value = int(match.group(2),10)
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



class SADTest(object):
    def __init__(self, dut, harness, registers, name, 
                 bits_per_sample, 
                 linear_ramp, 
                 ref_samples, 
                 triggers, 
                 multiple_triggers,  
                 emode,
                 interval_matching,
                 counter_width,
                 implementation):

        self.dut = dut
        self.harness = harness
        self.registers = registers
        self.reg_addr = self.harness.reg_addr
        self.name = name
        self.ref_samples = ref_samples
        self.bits_per_sample = bits_per_sample
        self.linear_ramp = linear_ramp
        self.triggers = triggers
        self.multiple_triggers = multiple_triggers
        self.emode = emode
        self.interval_matching = interval_matching
        self.counter_width = counter_width

        self.trigger_error = self.dut.trigger_error

        self.errors = 0

        self.blackout_request_queue = Queue()
        self.blackout_done_queue = Queue()

        self._coro = None

        # establish SAD reference (and which samples are enabled):
        self.pattern = []
        self.refen = []
        self.samples_enabled = 0
        for i in range(ref_samples):
            if (not linear_ramp) or (i == 0):
                sample = random.randint(0, 2**bits_per_sample-1)
            else:
                sample = (sample + 1) % 2**bits_per_sample
            self.pattern.append(sample)
            if implementation == 'SAD_SINGLE':
                # doesn't support disabled samples
                self.refen.append(1)
                self.samples_enabled += 1
            else:
                if random.randint(0, 10): # enable SAD for 1 out of 10 samples:
                    self.refen.append(1)
                    self.samples_enabled += 1
                else:
                    self.refen.append(0)

        self.dut._log.info('pattern = %s' % self.pattern)
        self.dut._log.info('refen = %s' % self.refen)

        # determine thresholds, with counter_width in mind:

        if interval_matching:
            self.threshold = random.randint(1, ref_samples/4-2)
            self.interval_threshold = random.randint(1, 2**(bits_per_sample-2))
            self.dut._log.info('SAD interval threshold randomized to: %d' % self.interval_threshold)
        else:
            # huge thresholds are not realistic and can lead to mismatch between DUT and model:
            self.threshold = random.randint(4, min(2**(counter_width-2), ref_samples*2))
            self.interval_threshold = 0

        if self.emode and interval_matching and self.threshold == 1:
            self.threshold = 2 # otherwise triggers are too rare for practical testing

        self.dut._log.info('SAD threshold randomized to: %d' % self.threshold)

        # instantiate SAD model which will tell us when triggers are expected:
        if emode:
            startup_latency = 2
        else:
            startup_latency = 3

        self.SAD_model = SAD(counter_width, self.pattern, self.refen, self.threshold//2, self.threshold, self.interval_threshold, startup_latency, multiple_triggers, emode, interval_matching, True)

    def start(self):
        """Start test thread"""
        if self._coro is not None:
            raise RuntimeError("Capture already started")
        self._coro = cocotb.start_soon(self._run())

    def stop(self):
        """Stop test thread"""
        if self._coro is None:
            raise RuntimeError("Capture never started")
        self._coro.kill()
        self._coro = None

    def running(self):
        if self._coro is None or self._coro.done():
            return False
        else:
            return True

    async def done(self):
        """ wait for _run() to complete """
        await Join(self._coro)
        if self.errors:
            self.dut._log.error("%6s test done, failed with %d errors" % (self.name, self.errors))
        else:
            self.dut._log.info("%6s test done: passed!" % self.name)


    async def dut_setup(self):
        await self.harness.reset()
        ## 1. simple sanity R/W:
        #for i in range(4):
        #    wdata = random.randint(0, 255)
        #    await self.registers.write(self.reg_addr['SAD_THRESHOLD'], [wdata])
        #    rdata = (await self.registers.read(self.reg_addr['SAD_THRESHOLD'], 1))[0]
        #    if rdata != wdata:
        #        self.dut._log.error('Wrote 0x%x, read 0x%x!' % (wdata, rdata))
        #        self.harness.inc_error()
        # 2. program SAD reference (128 bytes at a time):
        blocks = self.ref_samples//128
        if self.ref_samples % 128:
            blocks += 1
        for base in range(blocks):
            await self.registers.write(self.reg_addr['SAD_REFERENCE_BASE'], [base])
            await self.registers.write(self.reg_addr['SAD_REFERENCE'], self.pattern[base*128:(base+1)*128])
        # 3. program SAD_REFEN: translate into format used by DUT (one bit per sample)
        dut_refen_bignum = 0
        for i in range(self.ref_samples):
            if self.refen[i]:
                dut_refen_bignum += 2**i
        size = self.ref_samples//8
        if self.ref_samples % 8:
            size += 1
        await self.registers.write(self.reg_addr['SAD_REFEN'], self.registers.to_bytes(dut_refen_bignum, size))
        # 4. Rest of setup:
        await self.registers.write(self.reg_addr['SAD_THRESHOLD'], self.registers.to_bytes(self.threshold, 4))
        await self.registers.write(self.reg_addr['SAD_CONTROL'], [(self.emode << 2) + (self.multiple_triggers << 1)])
        await self.registers.write(self.reg_addr['SAD_INTERVAL_THRESHOLD'], [self.interval_threshold])
        # check selected DUT latency so we can adjust our expected triggers accordingly:
        latency = (await self.registers.read(self.reg_addr['SAD_VERSION'], 1))[0] & 0x1f
        assert latency < 23, "DUT's reported latency is too high! (%d)" % latency
        self.dut._log.info('Expected trigger latency: %d' % latency)
        self.dut.latency.value = latency
        self.dut.multiple_triggers.value = self.multiple_triggers



    # STRATEGY:
    # 1. randomly set armed_and_ready on/off
    # 2. sample-setting thread which alternates between applying data that's above and under the threshold
    #       (a) both above- and under-threshold run lenghts may be shorter or longer than the SAD reference
    #       (b) but there needs to be awareness of the SAD reference length so that it gets hit often enough
    # 3. this thread also feeds data to the SAD model, to learn when triggers are expected
    #       (a) the SAD model needs to be packaged so that can be re-used e.g. with on-target testing to verify
    #           on-target behaviour
    #       (b) the model is all that should need to change for different extended/probabilistic-SAD implementations
    # 4. trigger watch thread which checks that DUT triggers = expected triggers
    # 5. at the end, check that num_triggers is as expected
    async def _run(self):
        self.dut._log.debug('_run starting')
        await self.dut_setup()
        self._armed_generator = cocotb.start_soon(self._armed_generator_thread())
        self._sample_generator = cocotb.start_soon(self._sample_generator_thread())
        self._model_feeder = cocotb.start_soon(self._model_feeder_thread())
        self._trigger_watch_coro = cocotb.start_soon(self._trigger_watch_thread())
        if self.emode:
            self._emode_watch_coro = cocotb.start_soon(self._emode_watch_thread())
        await self.wait_for_triggers() # wait for expected number of triggers
        await ClockCycles(self.dut.clk_adc, self.ref_samples * 4) # wait a bit more to ensure no funny business



    async def _sample_generator_thread(self):
        # We don't concern ourselves with whether or not a trigger gets generated; we
        # generate runs of samples that are sometimes above, sometimes under the threshold;
        # sometimes these runs are too short, sometimes not. Note in particular that when
        # under_threshold is True, we may sometimes (randomly) end up over threshold (but that's
        # ok!).
        # We rely on SAD_model to known when triggers should occur.
        while True:
            if not self.blackout_request_queue.empty():
                # check whether _armed_generator_thread wants to change armed_and_ready;
                # see comments there to understand what we do here when this happend.
                self.blackout_request_queue.get_nowait()
                self.dut._log.info('sample generator: blackout request received')
                for i in range(self.ref_samples*4):
                    if self.interval_matching:
                        delta = random.randint(self.interval_threshold, 2**(self.bits_per_sample-1))
                    else:
                        delta = max(2, int(self.threshold / self.samples_enabled * 4))

                    if self.pattern[i % self.ref_samples] > delta:
                        value = self.pattern[i % self.ref_samples] - delta
                    else:
                        value = min(2**self.bits_per_sample-1, self.pattern[i % self.ref_samples] + delta)
                    self.dut.adc_datain.value = value
                    await ClockCycles(self.dut.clk_adc, 1)
                    if i == self.ref_samples*2:
                        self.blackout_done_queue.put_nowait(0)

            if random.randint(0, 4) > 0:
                under_threshold = 0
            else:
                under_threshold = 1
            if random.randint(0, 4) > 0:
                long_enough = 0
            else:
                long_enough = 1
            self.dut.under_threshold.value = under_threshold
            self.dut.long_enough.value = long_enough
            if long_enough:
                samples = self.ref_samples
            else:
                samples = random.randint(4, self.ref_samples-1)
            self.dut._log.info('sample generator: under_threshold=%d, long_enough=%d, num samples=%d' % (under_threshold, long_enough, samples))

            if not self.interval_matching:
                if under_threshold:
                    target_sad = random.randint(0, self.threshold-1)
                else:
                    target_sad = random.randint(self.threshold*2, self.threshold*4)
                average_deviation = target_sad / self.samples_enabled

            for i in range(samples):
                if self.interval_matching:
                    # first determine if the sample will be under or over the interval match
                    under_interval = random.randint(0, self.samples_enabled) < self.threshold
                    if not under_threshold:
                        under_interval = not under_interval
                    # then choose the delta accordingly:
                    if under_interval:
                        delta = random.randint(0, self.interval_threshold)
                    else:
                        delta = random.randint(self.interval_threshold, 2**(self.bits_per_sample-1))

                else:
                    delta = int(random.gauss(average_deviation, average_deviation/2))

                if self.refen[i]:
                    if random.randint(0,1):
                        value = self.pattern[i] + delta
                    else:
                        value = self.pattern[i] - delta
                    if value >= 2**self.bits_per_sample:
                        value = 2**self.bits_per_sample-1
                    elif value < 0:
                        value = 0
                else:
                    value = random.randint(0, 2**self.bits_per_sample-1)
                await ClockCycles(self.dut.clk_adc, 1)
                # feed the ADC sample to the DUT (a separate thread handles feeding the model)
                self.dut.adc_datain.value = value
                # TODO: log applied samples to file in a way that can be usefully copy/pasted to analyze/plot after the fact


    async def _model_feeder_thread(self):
        # feed self.dut.adc_datain inputs to SAD_model and generate expected_trigger:
        while True:
            match = self.SAD_model.step(int(self.dut.adc_datain), int(self.dut.armed_and_ready))
            self.dut.expected_trigger.value = match
            if match: 
                self.dut._log.info('Expecting trigger!')
            if self.emode:
                counters = self.ref_samples//2
            else:
                counters = self.ref_samples
            for j in range(min(32, counters)):
                self.dut.model_counter[j].value = self.SAD_model.counters[j].SAD
                if self.emode:
                    self.dut.model_extended_mode[j].value = self.SAD_model.counters[j].extended_mode
                if self.SAD_model.counters[j].ready2trigger:
                    self.dut.model_ready2trigger[j].value = 1;
                else:
                    self.dut.model_ready2trigger[j].value = 0;
            await ClockCycles(self.dut.clk_adc, 1)


    async def _trigger_watch_thread(self) -> None:
        """ Checks for trigger errors
        """
        while True:
            await Edge(self.trigger_error)
            self.harness.inc_error()
            self.dut._log.error('ERROR: unexpected trigger value!')


    async def _emode_watch_thread(self) -> None:
        """ Checks for mismatch between DUT and model counters' extended-mode status;
        intended to help debug trigger errors.
        """
        while True:
            await RisingEdge(self.dut.debug_emode_mismatch)
            if int(self.dut.armed_and_ready):
                self.dut._log.warning('WARNING: internal emode mismatch')


    async def _armed_generator_thread(self):
        # So... this could be simple, randomly arming and disarming, and that would work *most* of the time,
        # but not *all* of the time, because sad_model.py is not cycle-accurate -- it doesn't have the
        # Verilog implementations' latency. This means that it's possible for model and DUT triggering to
        # diverge near arming/disarming events. IRL this doesn't matter since precise triggering behaviour
        # so close to arming/disarming isnt't really important.
        # The objective here is to keep things simple, and avoid false failures. So, instead of going 
        # through the trouble of making the model cycle-accurate (for each of the many DUT 
        # implementations!), we put a "blackout" period before any change to armed_and_ready where we ensure
        # that no trigger can happen. We do this by sending a message over to the _sample_generator_thread
        # to tell it to avoid generating triggers; we wait for it to acknowledge receipt and carry out the
        # blackout period, and then we change the armed state.
        armed = False
        while True:
            # bias towards spending most of the time armed:
            if armed:
                if self.multiple_triggers:
                    min_wait = self.ref_samples*10
                    max_wait = self.ref_samples*20
                else:
                    min_wait = self.ref_samples*5
                    max_wait = self.ref_samples*10
            else:
                min_wait = self.ref_samples*2
                max_wait = self.ref_samples*4
            await ClockCycles(self.dut.clk_adc, random.randint(min_wait, max_wait))
            # put in request to change armed_and_ready
            self.dut._log.info('armed_and_ready: requesting to change...')
            self.blackout_request_queue.put_nowait(0)
            # wait for until we're allowed:
            await self.blackout_done_queue.get()
            #self.dut._log.info('armed_and_ready: request granted, running out blackout period')
            #await ClockCycles(self.dut.clk_adc, self.ref_samples*2)
            armed = not armed
            self.dut._log.info('armed_and_ready: blackout done, setting to %s' % armed)
            self.dut.armed_and_ready.value = armed
            #break


    async def wait_for_triggers(self):
        # blocks until the requested number of triggers have been observed
        triggers_seen = 0
        while True:
            await RisingEdge(self.dut.trigger_expected_delayed)
            triggers_seen += 1
            if triggers_seen == self.triggers:
                break



@cocotb.test(timeout_time=timeout_time, timeout_unit="us")
async def sad_test(dut):
    reps  = int(os.getenv('REPS', '3'))
    bits_per_sample   = int(os.getenv('BITS_PER_SAMPLE', '8'))
    linear_ramp       = int(os.getenv('LINEAR_RAMP', '0'))
    ref_samples       = int(os.getenv('REF_SAMPLES', '32'))
    counter_width     = int(os.getenv('SAD_COUNTER_WIDTH', '12'))
    triggers          = int(os.getenv('TRIGGERS', '4'))
    multiple_triggers = int(os.getenv('MULTIPLE_TRIGGERS', '0'))
    interval_matching = int(os.getenv('INTERVAL_MATCHING', '0'))
    emode             = int(os.getenv('EMODE', '0'))
    implementation    = os.getenv('SAD', 'SAD_BASE')

    if implementation == 'ESAD' and not emode:
        ref_samples = ref_samples//2

    if interval_matching:
        counter_width = math.ceil((math.log2(ref_samples)))-2

    dut._log.info("bits_per_sample: %d" % bits_per_sample)
    dut._log.info("linear_ramp: %d" % linear_ramp)
    dut._log.info("ref_samples: %d" % ref_samples)
    dut._log.info("counter_width: %d" % counter_width)
    dut._log.info("triggers: %d" % triggers)
    dut._log.info("multiple_triggers: %d" % multiple_triggers)
    dut._log.info("interval_matching: %d" % interval_matching)
    dut._log.info("emode: %d" % emode)
    dut._log.info("implementation: %s" % implementation)
    dut._log.info("reps: %d" % reps)

    registers = Registers(dut)
    harness = Harness(dut, registers, reps)

    sadtest = SADTest(dut, harness, registers, "sad_test",
                      bits_per_sample = bits_per_sample,
                      linear_ramp = linear_ramp,
                      ref_samples = ref_samples,
                      triggers = triggers,
                      multiple_triggers = multiple_triggers,
                      emode = emode,
                      interval_matching = interval_matching,
                      counter_width = counter_width,
                      implementation = implementation
                     )
    harness.register_test(sadtest)


    harness.start_tests()
    await harness.all_tests_done()
    assert harness.errors == 0


