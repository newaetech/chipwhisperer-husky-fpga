# Copyright (c) 2025, NewAE Technology Inc
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
        self.dut.errors.value = 0
        self.dut.expected_trigger.value = 0
        #self.dut.bb_data_in.value = 0
        self.dut.glitchclk.value = 0


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
    def bytes_from_bits(bits):
        pad = len(bits)%8
        if pad:
            pad = 8 - pad
            pad_value = bits[-1]
            bits.extend([pad_value]*pad)
        sum = 0
        for i,j in enumerate(bits):
            if j: sum += 2**i
        return list(int.to_bytes(sum, len(bits)//8, byteorder='little'))

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



class HW_BB_Test(object):
    def __init__(self, dut, harness, registers, name):

        self.dut = dut
        self.harness = harness
        self.registers = registers
        self.reg_addr = self.harness.reg_addr
        self.name = name

        self.trigger_error = self.dut.trigger_error

        self._coro = None


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

    async def go(self, go=True):
        # Most properties of this module are only written out to the hardware when this
        # method is called; by setting the "go" argument to False, the properties get
        # pushed out without making it "go".
        if go:
            writes = 6
        else:
            writes = 5
        raw = [0]*writes
        raw[0] = (self.trigger_en << 7) + \
                 (self.clear_matched << 6)
        raw[1] = (self.continuous_clk << 7) + \
                 (self.inactive_data << 6) + \
                 (self.inactive_state << 5) + \
                 (self.trigger_when_matched << 3) + \
                 (self.enable_glitch_output << 2) + \
                 (self.drive_edge << 1) + \
                 (self.check_edge << 0)
        raw[2] = self.clk_div
        raw[3] = self.num_bits & 0xFF
        raw[4] = self.num_bits >> 8
        await self.registers.write(self.reg_addr['BB_TRIG_CTRL_STAT'], raw)


    async def dut_setup(self):
        await self.harness.reset()
        #await self.registers.write(self.reg_addr['SAD_TRIGGER_TIME'], self.registers.to_bytes(triggerer_init, size))
        #self.dut._log.info('Expected trigger latency: %d' % latency)

        pattern_data = [1,0,0,0,0,1]*4
        await self.registers.write(self.reg_addr['BB_TRIG_REG_SELECT'], [self.reg_addr['BB_TRIG_PATTERN_DATA']])
        await self.registers.write(self.reg_addr['BB_TRIG_DATA'], self.harness.bytes_from_bits(pattern_data))

        pattern_en = [1]*len(pattern_data)
        await self.registers.write(self.reg_addr['BB_TRIG_REG_SELECT'], [self.reg_addr['BB_TRIG_PATTERN_EN']])
        await self.registers.write(self.reg_addr['BB_TRIG_DATA'], self.harness.bytes_from_bits(pattern_data))

        record_en = [1,0,0,0,0,1]*4
        await self.registers.write(self.reg_addr['BB_TRIG_REG_SELECT'], [self.reg_addr['BB_TRIG_RECORD_EN']])
        await self.registers.write(self.reg_addr['BB_TRIG_DATA'], self.harness.bytes_from_bits(record_en))

        clk_en = [1,1,1,0,0,0]*4
        await self.registers.write(self.reg_addr['BB_TRIG_REG_SELECT'], [self.reg_addr['BB_TRIG_CLK_EN']])
        await self.registers.write(self.reg_addr['BB_TRIG_DATA'], self.harness.bytes_from_bits(clk_en))

        trigger_en = [1,0,0,0,0,1]*4
        await self.registers.write(self.reg_addr['BB_TRIG_REG_SELECT'], [self.reg_addr['BB_TRIG_BITS']])
        await self.registers.write(self.reg_addr['BB_TRIG_DATA'], self.harness.bytes_from_bits(trigger_en))



        self.trigger_en = 1
        self.clear_matched = 0
        self.continuous_clk = 0
        self.inactive_data = 0
        self.inactive_state = 0
        self.trigger_when_matched = 0
        self.enable_glitch_output = 0
        self.drive_edge = 0
        self.check_edge = 1
        self.clk_div = 2
        self.num_bits = 24

        await self.go(True)


    # STRATEGY:
    # 1. TODO
    # 2. ...
    # 3. ...
    # 4. ...
    async def _run(self):
        self.dut._log.debug('_run starting')
        await self.dut_setup()

        self._trigger_watch_coro = cocotb.start_soon(self._trigger_watch_thread())
        await self.wait_for_triggers() # wait for expected number of triggers
        await ClockCycles(self.dut.clk_adc, 1000) # TODO: decide how long to wait



    async def _trigger_watch_thread(self) -> None:
        """ Checks for trigger errors
        """
        while True:
            await Edge(self.trigger_error)
            self.harness.inc_error()
            self.dut._log.error('ERROR: unexpected trigger value!')


    async def wait_for_triggers(self):
        # blocks until the requested number of triggers have been observed
        triggers_seen = 0
        while True:
            await RisingEdge(self.dut.expected_trigger)
            triggers_seen += 1
            if triggers_seen == self.triggers:
                break



@cocotb.test(timeout_time=timeout_time, timeout_unit="us")
async def hw_bb_test(dut):
    reps              = int(os.getenv('REPS', '1'))
    #bits_per_sample   = int(os.getenv('BITS_PER_SAMPLE', '8'))

    dut._log.info("reps: %d" % reps)
    #dut._log.info("bits_per_sample: %d" % bits_per_sample)

    registers = Registers(dut)
    harness = Harness(dut, registers, reps)

    hw_bbtest = HW_BB_Test(dut, harness, registers, "hw_bb_test"
                          )

    harness.register_test(hw_bbtest)


    harness.start_tests()
    await harness.all_tests_done()
    assert harness.errors == 0


