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
from cocotb.triggers import RisingEdge, FallingEdge, Edge, ClockCycles, Join, Lock, Event, with_timeout, First
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

# What this test covers:
# The following scope.bitbanger attributes are randomized (and verified) on each run:
# - pattern_data
# - pattern_en
# - pattern_hiz
# - record_en
# - trigger_en
# - recorded_data
# - num_bits
#
# Every combination of drive_edge and check_edge is used on each run.
#
# The following attributes are NOT checked:
# - clk_div
# - continuous_clk = 1
# - trigger_when_matched = 0
# - clock_inactive_state = 1
# - enable_glitch_output (and anything with glitches)
#
# Additionally, since this is a block-level testbench, data_pin and clock_pin can't be covered.


# Note: this could also be place in individual test functions by replacing root_logger by dut._log.
root_logger = logging.getLogger()
logfile = os.getenv('LOGFILE', 'make.log')
print('Logfile = %s' % logfile)
fh = logging.FileHandler(logfile, 'w')
fh.setFormatter(SimLogFormatter())
root_logger.addHandler(fh)

timeout_time = int(os.getenv('TIMEOUT_TIME', '800'))

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
        self.reps = self.harness.reps

        self.trigger_error = self.dut.trigger_error
        self.data_error = self.dut.data_error
        self.hiz_error = self.dut.hiz_error
        self.clk_error = self.dut.clk_error

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
        if self.harness.errors:
            self.dut._log.error("%6s test done, failed with %d errors" % (self.name, self.harness.errors))
        else:
            self.dut._log.info("%6s test done: passed!" % self.name)


    async def go(self, go=True):
        # Most properties of this module are only written out to the hardware when this
        # method is called; by setting the "go" argument to False, the properties get
        # pushed out without making it "go".
        if go:
            writes = 7
        else:
            writes = 6
        raw = [0]*writes
        raw[0] = (self.trigger_en << 7)
        raw[1] = (self.continuous_clk << 7) + \
                 (self.inactive_data << 6) + \
                 (self.inactive_state << 5) + \
                 (self.clock_inactive_state << 4) + \
                 (self.trigger_when_matched << 3) + \
                 (self.enable_glitch_output << 2) + \
                 (self.drive_edge << 1) + \
                 (self.check_edge << 0)
        raw[2] = self.clk_div & 0xFF
        raw[3] = self.clk_div >> 8
        raw[4] = self.num_bits & 0xFF
        raw[5] = self.num_bits >> 8
        await self.registers.write(self.reg_addr['BB_TRIG_CTRL_STAT'], raw)


    async def dut_setup(self):
        await self.harness.reset()
        self.dut.in_to_out.value = 1
        self.dut.tb_data_in.value = 0
        raw = (await self.registers.read(self.reg_addr["BB_TRIG_CTRL_STAT"], 5))
        self.pattern_depth = raw[1] + (raw[2] << 8)
        self.save_depth = raw[3] + (raw[4] << 8)
        self.dut._log.info('pattern depth: %d' % self.pattern_depth)
        self.dut._log.info('save depth: %d' % self.save_depth)

        if (self.save_depth % 8 != 0):
            self.dut._log.error('ERROR: pSAVE_DEPTH not a multiple of 8!')

        self.trigger_en = 1
        self.continuous_clk = 0
        #self.inactive_data = random.randint(0,1)
        #self.inactive_state = random.randint(0,1)
        #self.clock_inactive_state = 0 # note: not covered

        #self.inactive_data = 1
        self.inactive_data = 1
        self.inactive_state = 1
        self.clock_inactive_state = 1 # note: not covered

        self.trigger_when_matched = 0 # note: not covered
        self.enable_glitch_output = 0 # note: not covered
        self.drive_edge = 1
        self.check_edge = 1
        self.clk_div = 8 # note: not covered; also, hw_bb_cocowrapper assumes this to be 8
        self.num_bits = 24
        await self.go(False)
        self.set_expected_defaults()


    def A2bits(self, address):
        x = []
        for i in range(16):
            bitpos = 15-i
            if address & 2**bitpos:
                x.append(1)
            else:
                x.append(0)
        # insert space for ACK bit:
        x.insert(8,0)
        return x

    def D2bits(self, data):
        x = []
        for i in range(8):
            bitpos = 7-i
            if data & 2**bitpos:
                x.append(1)
            else:
                x.append(0)
        return x


    async def _dispatch_thread(self):
        # simple directed test -- modify as needed:
        pattern_data = [0,1,0,0,0,1]*1
        pattern_en = [1]*len(pattern_data)
        record_en = [1,1,0,0,0,1]*1
        trigger_en = [1,1,0,0,0,1]*1
        hiz = [0]*len(pattern_data)
        hiz[2] = 1
        clk_en = [1]*len(pattern_data)
        clk_en[0] = 0
        clk_en[2] = 0
        clk_en[-1] = 0
        #clk_en[1] = 0
        self.num_bits = len(pattern_data)

        #              start dev address   W  ACK  word addresses: 0xFF00             ACK   STOP (temp)
        #pattern_data = [0,0, 1,0,1,0,1,1,1,0, 0,   1,1,1,1,1,1,1,1, 1,1,1,1,0,0,0,0,  0,    0,0]
        #hiz          = [0,0, 0,0,0,0,0,0,0,0, 1,   0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0,  1,    0,0]
        #clk_en       = [1]*len(pattern_data)
        #pattern_en   = [1]*len(pattern_data)
        #record_en    = [0]*len(pattern_data)
        #trigger_en   = [0]*len(pattern_data)
        #clk_en[0] = 0
        #clk_en[-1] = 0
        #self.num_bits = len(pattern_data)

        #address = 0xFFF0
        #abits = self.A2bits(address)
        #dev_addr = [1,0,1,0,0,0,0]
        #pattern_data = [0,0, 1,0,1,0,0,0,0, 0, 0,   0,0,0,0,0,0,0,0, 0, 0,0,0,0,0,0,0,0,  0,    1,0,   1,0,1,0,0,0,0, 1,  1,  0,0,0,0,0,0,0,0, 1,  0]
        #hiz          = [0,0, 0,0,0,0,0,0,0, 0, 1,   0,0,0,0,0,0,0,0, 1, 0,0,0,0,0,0,0,0,  1,    0,0,   0,0,0,0,0,0,0, 0,  1,  1,1,1,1,1,1,1,1, 0,  0]
        #clk_en       = [0,1, 1,1,1,1,1,1,1, 1, 1,   1,1,1,1,1,1,1,1, 1, 1,1,1,1,1,1,1,1,  1,    0,1,   1,1,1,1,1,1,1, 1,  1,  1,1,1,1,1,1,1,1, 1,  0]
        #pattern_data[2:9] = dev_addr
        #pattern_data[11:11+len(abits)] = abits
        #pattern_en   = [1]*len(pattern_data)
        #trigger_en   = [0]*len(pattern_data)
        #record_en    = [0]*len(pattern_data)
        #record_en[40:48] = [1]*8
        #self.num_bits = len(pattern_data)

        #pattern_data = [0,0, 1,0,1,0,0,0,0, 1,  1,  0,0,0,0,0,0,0,0, 1,  0, 1]
        #hiz          = [0,0, 0,0,0,0,0,0,0, 0,  1,  1,1,1,1,1,1,1,1, 0,  0, 0]
        #clk_en       = [0,0, 1,1,1,1,1,1,1, 1,  1,  1,1,1,1,1,1,1,1, 1,  1, 0]
        #pattern_en   = [1]*len(pattern_data)
        #trigger_en   = [0]*len(pattern_data)
        #record_en    = [0]*len(pattern_data)
        #self.num_bits = len(pattern_data)

        pattern_data = [0,1,1,0,0]
        hiz          = [0,0,0,0,0]
        clk_en       = [1,1,1,0,1]
        pattern_en   = [0,0,0,0,0]
        trigger_en   = [0,1,0,0,0]
        record_en    = [1]*len(pattern_data)
        self.num_bits = len(pattern_data)



        #self.drive_edge = 0
        #self.check_edge = 0
        self.inactive_data = 1
        self.clock_inactive_state = 0

        in_to_out = 0
        self.dut.in_to_out.value = in_to_out
        data_in = pattern_data.copy()
        data_in[2] = not data_in[2]
        pattern_en[2] = 0

        for check_edge in [0,1]:
            for drive_edge in [1,0]:
                for clock_inactive_state in [0]: #[0,0]:

                    self.drive_edge = drive_edge
                    self.check_edge = check_edge
                    self.clock_inactive_state = clock_inactive_state

                    await self.set_bb_data(pattern_data, hiz, pattern_en, trigger_en, record_en, clk_en)
                    await self.go(True)
                    await self._generate_expected_outputs(pattern_data, hiz, pattern_en, trigger_en, clk_en, data_in)
                    await self.wait_done()

                    matched = await self.matched()
                    if not matched:
                        self.dut._log.error('Matched status bit is not set.')
                        self.harness.inc_error()


        # Randomized tests:
        # Randomize the number of bits, the pattern data, the triggers, and hiz.
        # Run with these settings for each of the 4 drive/check edge combinations.
        # And for each of these, pattern_en is tested by checking for the "matched" status when:
        # a) expected data is sent correctly with pattern_en set to all ones
        # b) pattern_en is randomized and one of the enabled bits is inverted ("matched" is false)
        # c) pattern_en is randomized and all disabled bits are inverted ("matched" is True)
        # So in total, 12 patterns are issued.
        for rep in range(self.reps):
            # randomize start time WRT bit-bang clock phase to ensure there is no dependency there:
            await ClockCycles(self.dut.clk_adc, random.randint(0, self.clk_div))
            num_bits = random.randint(self.save_depth, self.pattern_depth)
            self.num_bits = num_bits
            pattern_data = []
            trigger_en = []
            hiz = []
            clk_en = []
            record_en = [0]*num_bits
            for i in range(num_bits):
                pattern_data.append(random.randint(0,1))
                clk_en.append(random.randint(0,1))
                hiz.append(random.randint(0,1))
                # triggers are less frequent so we'll get better effective coverage if the test reflects that:
                if random.randint(0,10):
                    trigger_en.append(0)
                else:
                    trigger_en.append(1)

            # TODO: randomize clk_en?
            #clk_en = [1]*num_bits
            #clk_en[0] = 0
            #clk_en[1] = 0
            #clk_en[2] = 0

            # randomly choose which bits to record:
            for i in range(self.save_depth):
                j = random.randint(0, num_bits-1)
                k = 0
                while record_en[j]:
                    j = random.randint(0, num_bits-1)
                    k += 1
                    if k == num_bits*10:
                        self.dut._log.error('testbench bug: stuck! num_bits=%d, i=%d, record_en=%s' % (num_bits, i, record_en))
                        break
                record_en[j] = 1
                val = pattern_data[j]

            self.dut._log.info('Randomized job data:')
            self.dut._log.info('    num_bits=%d' % num_bits)
            self.dut._log.info('    pattern_data=%s' % pattern_data)
            self.dut._log.info('    trigger_en  =%s' % trigger_en)
            self.dut._log.info('    record_en   =%s' % record_en)
            self.dut._log.info('    hiz         =%s' % hiz)
            self.dut._log.info('    clk_en      =%s' % clk_en)
            if num_bits > 16:
                self.dut._log.info('First 8 bits of job data:')
                self.dut._log.info('    pattern_data=%s' % pattern_data[:8])
                self.dut._log.info('    trigger_en  =%s' % trigger_en[:8])
                self.dut._log.info('    record_en   =%s' % record_en[:8])
                self.dut._log.info('    hiz         =%s' % hiz[:8])
                self.dut._log.info('    clk_en      =%s' % clk_en[:8])
                self.dut._log.info('Last 8 bits of job data:')
                self.dut._log.info('    pattern_data=%s' % pattern_data[-8:])
                self.dut._log.info('    trigger_en  =%s' % trigger_en[-8:])
                self.dut._log.info('    record_en   =%s' % record_en[-8:])
                self.dut._log.info('    hiz         =%s' % hiz[-8:])
                self.dut._log.info('    clk_en      =%s' % clk_en[-8:])
            for drive_edge in [0,1]:
                for check_edge in [0,1]:
                    for pattern_en_case in range(3):
                        self.dut._log.info('...running with drive=%d, check=%d, pattern_en case: %d' % (drive_edge, check_edge, pattern_en_case))
                        self.drive_edge = drive_edge
                        self.check_edge = check_edge

                        if pattern_en_case == 0:
                            # loop back, no errors:
                            expect_match = True
                            self.dut.in_to_out.value = 1
                            data_in = pattern_data.copy()
                            pattern_en = [1]*num_bits
                            expected_rdata = self.get_expected_rdata(record_en, pattern_data)

                        elif pattern_en_case == 1:
                            # feed in a single error that will get caught:
                            expect_match = False
                            self.dut.in_to_out.value = 0
                            pattern_en = []
                            for i in range(num_bits):
                                pattern_en.append(random.randint(0,1))
                            bitflip = random.randint(0, num_bits-1)
                            data_in[bitflip] = not data_in[bitflip]
                            pattern_en[bitflip] = 1
                            expected_rdata = self.get_expected_rdata(record_en, data_in)

                        elif pattern_en_case == 2:
                            # feed in errors everytime pattern_en is False:
                            expect_match = True
                            self.dut.in_to_out.value = 0
                            data_in = pattern_data.copy()
                            pattern_en = []
                            for i in range(num_bits):
                                pattern_en_bit = random.randint(0,1)
                                pattern_en.append(pattern_en_bit)
                                if not pattern_en_bit:
                                    data_in[i] = not data_in[i]
                            expected_rdata = self.get_expected_rdata(record_en, data_in)

                        await self.set_bb_data(pattern_data, hiz, pattern_en, trigger_en, record_en, clk_en)
                        await self.go(True)
                        await self._generate_expected_outputs(pattern_data, hiz, pattern_en, trigger_en, clk_en, data_in)
                        await self.wait_done()
                        matched = await self.matched()
                        if matched != expect_match:
                            self.dut._log.error('Expected matched status %d, got %d' % (expect_match, matched))
                            self.harness.inc_error()

                        rdata = await self.saved_data()
                        if rdata != expected_rdata:
                            self.dut._log.error('Expected %x\nGot      %x\nXOR      %x' % (expected_rdata, rdata, expected_rdata ^ rdata))
                            self.harness.inc_error()
                        else:
                            self.dut._log.info('Received expected data (%x)' % rdata)

        self.dut._log.info('job done!')

    def get_expected_rdata(self, record_en, pattern_data):
        j = 0
        expected_rdata = 0
        for i in range(self.num_bits):
            if record_en[i]:
                expected_rdata += (pattern_data[i] << j)
                j += 1
        return expected_rdata

    async def _generate_expected_clock(self, clk_en):
        # when driving on a negative edge, an extra clock gets put out:
        clk_en_copy = clk_en.copy()
        if not self.drive_edge:
            clk_en_copy.append(clk_en_copy[-1])
            #self.dut._log.info('Extended clk_en: %s' % clk_en_copy)
        for cen in clk_en_copy:
            await RisingEdge(self.dut.clock_out_debug)
            if cen:
                self.dut.expected_clk.value = 1
            else:
                self.dut.expected_clk.value = 0
            await FallingEdge(self.dut.clock_out_debug)
            self.dut.expected_clk.value = 0


    async def _generate_expected_outputs(self, pattern_data, hiz, pattern_en, trigger_en, clk_en, data_in):
        b = 0
        cocotb.start_soon(self._generate_expected_clock(clk_en)) # clock checking is easier to handle in a separate thread
        for expected_data, expected_hiz, expected_en, expected_trigger, tb_data_in in zip(pattern_data, hiz, pattern_en, trigger_en, data_in):
            # drive-edge driven I/O's:
            #self.dut._log.info('awaiting drive edge %d...' % b)
            await self._next_drive_edge()
            #self.dut._log.info('got it')
            self.dut.expected_data.value = expected_data
            self.dut.expected_hiz.value = expected_hiz

            # check-edge driven I/O's:
            if self.drive_edge != self.check_edge:
                #self.dut._log.info('awaiting check edge %d...' % b)
                await self._next_check_edge()
                #self.dut._log.info('got it')
            self.dut.tb_data_in.value = tb_data_in
            self.dut.expected_trigger.value = expected_trigger
            # trigger is a single fast clock cycle:
            await ClockCycles(self.dut.clk_adc, 1)
            self.dut.expected_trigger.value = 0

            b += 1

        # count with fast clock here because target-driven clock won't be there
        if self.drive_edge != self.check_edge:
            #await self._next_drive_edge()
            await ClockCycles(self.dut.clk_adc, self.clk_div//2 - 1)
        else:
            await ClockCycles(self.dut.clk_adc, self.clk_div - 1)

        self.set_expected_defaults()


    def set_expected_defaults(self):
        self.dut.expected_data.value = self.inactive_data
        self.dut.expected_hiz.value = not self.inactive_state


    async def _next_drive_edge(self):
        if self.drive_edge:
            await RisingEdge(self.dut.clock_out_debug)
        else:
            await FallingEdge(self.dut.clock_out_debug)


    async def _next_check_edge(self):
        if self.check_edge:
            await RisingEdge(self.dut.clock_out_debug)
        else:
            await FallingEdge(self.dut.clock_out_debug)


    async def set_bb_data(self, pattern_data, hiz, pattern_en, trigger_en, record_en, clk_en):
        bb_data = []
        if not(len(pattern_data) == len(hiz) == len(pattern_en) == len(trigger_en) == len(record_en) == len(clk_en)):
            self.dut._log.error('Internal error: unequal lengths (%d, %d, %d, %d, %d, %d)' % (len(pattern_data), len(hiz), len(pattern_en), len(trigger_en), len(record_en), len(clk_en)))
            assert False
        for a,b,c,d,e,f in zip(pattern_data, hiz, pattern_en, trigger_en, record_en, clk_en):
            #bb_data.append(a + (b<<1) + (c<<2) + (d<<3) + (e<<4))
            bb_data.append(a + (b<<1) + (c<<2) + (d<<3) + (e<<4) + (f<<5))
        await self.registers.write(self.reg_addr['BB_TRIG_DATA'], bb_data)


    async def saved_data(self, return_word=True):
        size = self.save_depth // 8
        raw = await self.registers.read(self.reg_addr['BB_TRIG_DATA'], size)
        final = []
        for b in raw:
            # swap nibbles *and* bit order:
            fixed = 0
            for bit in range(8):
                if b & 2**bit:
                    fixed += 2**(7-bit)
            lo = fixed & 0x0F
            hi = fixed & 0xF0
            bswap = (hi >> 4) + (lo << 4)
            final.append(fixed)
        if return_word:
            return int.from_bytes(final, byteorder='big')
        else:
            return final[::-1]


    async def wait_done(self):
        await ClockCycles(self.dut.clk_usb, 100) # allow for CDC delays, for it to actually start
        while True:
            if not await self.active():
                break
        await self.fifo_errors()


    async def active(self):
        """ Whether the bitbanger module is still currently active (i.e. still bit-banging).
        """
        raw = (await self.registers.read(self.reg_addr["BB_TRIG_CTRL_STAT"]))[0]
        if raw & 0x02:
            return True
        else:
            return False


    async def matched(self):
        raw = (await self.registers.read(self.reg_addr["BB_TRIG_CTRL_STAT"]))[0]
        if raw & 0x01:
            return True
        else:
            return False

    async def fifo_errors(self):
        errors = False
        raw = (await self.registers.read(self.reg_addr["BB_TRIG_CTRL_STAT"]))[0]
        if raw & 2**5:
            self.dut._log.error('Internal FIFO error (likely underflow)')
            self.harness.inc_error()
        if raw & 2**6:
            self.dut._log.error('FIFO underflow error')
            self.harness.inc_error()
        if raw & 2**7:
            self.dut._log.error('FIFO overflow error')
            self.harness.inc_error()


    async def _run(self):
        self.dut._log.debug('_run starting')
        await self.dut_setup()

        cocotb.start_soon(self._trigger_watch_thread())
        cocotb.start_soon(self._data_watch_thread())
        cocotb.start_soon(self._hiz_watch_thread())
        cocotb.start_soon(self._clk_watch_thread())

        #self._dispatch_coro = cocotb.start_soon(self._dispatch_thread())
        await self._dispatch_thread()
        await ClockCycles(self.dut.clk_adc, 100)


    async def _trigger_watch_thread(self) -> None:
        """ Checks for trigger errors
        """
        while True:
            await Edge(self.trigger_error)
            self.harness.inc_error()
            self.dut._log.error('ERROR: unexpected trigger value!')

    async def _data_watch_thread(self) -> None:
        """ Checks for data errors
        """
        while True:
            await Edge(self.data_error)
            self.harness.inc_error()
            self.dut._log.error('ERROR: unexpected data value!')

    async def _hiz_watch_thread(self) -> None:
        """ Checks for hiz errors
        """
        while True:
            await Edge(self.hiz_error)
            self.harness.inc_error()
            self.dut._log.error('ERROR: unexpected hiz value!')

    async def _clk_watch_thread(self) -> None:
        """ Checks for clk errors
        """
        while True:
            await Edge(self.clk_error)
            self.harness.inc_error()
            self.dut._log.error('ERROR: unexpected clk value!')




@cocotb.test(timeout_time=timeout_time, timeout_unit="us")
async def hw_bb_test(dut):
    reps = int(os.getenv('REPS', '1'))

    dut._log.info("reps: %d" % reps)

    registers = Registers(dut)
    harness = Harness(dut, registers, reps)

    hw_bbtest = HW_BB_Test(dut, harness, registers, "hw_bb_test")

    harness.register_test(hw_bbtest)


    harness.start_tests()
    await harness.all_tests_done()
    assert harness.errors == 0


