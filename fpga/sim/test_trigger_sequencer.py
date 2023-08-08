import cocotb
from cocotb.triggers import RisingEdge, Edge, ClockCycles, Join, Lock, Event, with_timeout
from cocotb.clock import Clock
from cocotb.queue import Queue
from cocotb.handle import Force, Release
from cocotb.log import SimLogFormatter
from cocotb.result import SimTimeoutError
#from cocotb.regression import TestFactory
import random
import math
import logging
import os

# Note: this could also be place in individual test functions by replacing root_logger by dut._log.
root_logger = logging.getLogger()
logfile = os.getenv('LOGFILE', 'make.log')
print('Logfile = %s' % logfile)
fh = logging.FileHandler(logfile, 'w')
fh.setFormatter(SimLogFormatter())
root_logger.addHandler(fh)

class Harness(object):
    def __init__(self, dut, reps):
        self.dut = dut
        self.reps = reps
        self.tests = []
        self.errors = 0
        # Actual seed is obtained only if SEED is defined on vvp command line (otherwise you get 0)
        # regress.py always specifies the seed so this is fine.
        self.dut._log.info("SEED: %d" % int(os.getenv('RANDOM_SEED', '0')))
        self.period = 10
        clk_thread = cocotb.start_soon(Clock(dut.clk, self.period, units="ns").start())
        #  initialize all DUT input values:
        self.dut.armed_and_ready.value = 1 # TODO: randomize dynamically!
        self.dut.I_bypass.value = 0
        self.dut.I_trigger.value = 0
        self.dut.I_min_wait.value = 0
        self.dut.I_max_wait.value = 0
        self.dut.I_last_trigger.value = 0

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
        await ClockCycles(self.dut.clk, 10) # to give time for fifo_watch errors to be seen

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


class TriggerSequencerTest(object):
    def __init__(self, dut, harness, name, num_triggers, counter_width, test_type):
        self.dut = dut
        self.harness = harness
        self.name = name
        self.num_triggers = num_triggers
        self.counter_width = counter_width
        self.test_type = test_type
        self.trigger_queue = Queue(maxsize=num_triggers)
        self.min_waits = [0]*num_triggers
        self.max_waits = [0]*num_triggers
        self.trigger_error = self.dut.trigger_error
        self.trigger_allowed = True
        self.trigger_expected = False

        self._coro = None
        self._checkcoro = None
        self._trigger_coros = []
        self._trigger_watch_coro = None
        self.errors = 0

        self.min_idle_time = 1
        self.max_idle_time = 100 # TODO: tweak?

        self.min_active_time = 1
        self.max_active_time = 50 # TODO: tweak?

        self.dut_min_wait = 10
        self.dut_max_wait = 100

        self.dut.I_last_trigger.value = num_triggers-1 # TODO: randomize?
        self.expect_trigger(0)


    def start(self):
        """Start test thread"""
        if self._coro is not None:
            raise RuntimeError("Capture already started")
        self._coro = cocotb.start_soon(self._run_wrapper())

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

    async def _run_wrapper(self):
        # this is a bit janky but to accomodate the random case where sometimes we're just not lucky, and to not have a huge timeout value, instead
        # we catch just before the testcase timeout, and if there are no errors, and if at least one trigger has occured, then that's ok:
        try:
            await with_timeout(self._run(), 999, 'us')
        except:
            if self.trigger_expected:
                self.dut._log.info("Caught the timeout! Trigger(s) occured, all good.")
            else:
                self.dut._log.warning("Caught the timeout but no trigger has occured :-/")

    async def _run(self):
        self.dut._log.debug('_run starting')
        await self.set_min_maxes()
        self._checkcoro = cocotb.start_soon(self._check_thread())
        self._trigger_watch_coro = cocotb.start_soon(self._trigger_watch_thread())
        if self.test_type == 'rand':
            # randomize everything!
            for t in range(self.num_triggers):
                self._trigger_coros.append(cocotb.start_soon(self._trigger_thread(t)))

        else:
            # sane and simple sequence for checking basic life:
            for r in range(self.harness.reps):
                for t in range(self.num_triggers):
                    self.set_trigger(t, True)
                    await ClockCycles(self.dut.clk, 1)
                    self.set_trigger(t, False)
                    if t < self.num_triggers-1:
                        if self.test_type == 'pass' or random.randint(0,1):
                            cycles = random.randint(self.min_waits[t], self.max_waits[t]-2)
                        else:
                            # for test_type == 'fail'; this will guarantee failure, but there is an escape hatch above which *could* lead to a trigger
                            cycles = random.randint(self.max_waits[t], self.max_waits[t]*2)
                        await ClockCycles(self.dut.clk, cycles)
                await ClockCycles(self.dut.clk, random.randint(1, 20))

        await ClockCycles(self.dut.clk, 100)
        if self.test_type != 'fail':
            # _checkcoro will complete for 'pass' and 'rand', but not 'fail'
            # TODO: some 'fail' runs may actually result in a trigger; those should be checked!
            await Join(self._checkcoro)


    async def _trigger_thread(self, num):
        # randomly sets triggers:
        self.dut._log.debug('_trigger_thread %d starting' % num)
        while True:
            await ClockCycles(self.dut.clk, random.randint(self.min_idle_time, self.max_idle_time))
            while not self.trigger_allowed:
                await ClockCycles(self.dut.clk, 1)
            self.set_trigger(num, True)
            await ClockCycles(self.dut.clk, random.randint(self.min_active_time, self.max_active_time))
            self.set_trigger(num, False)


    # TODO: add randomization of dut.armed_and_ready!

    async def _check_thread(self):
        # looks at the randomly sets triggers and figures out whether the DUT should issue a trigger;
        # this is essentially a behavioural model of the DUT!
        triggers_done = 0
        scores = [0]*self.num_triggers
        timestamps = [0]*self.num_triggers
        slot = 0
        self.dut.expected_slot.value = 0
        while triggers_done < self.harness.reps:
            if slot == 0:
                trigger_ids = [await self.trigger_queue.get()]
            else:
                try:
                    timeout = timeout_cycles * self.harness.period
                    self.dut._log.info('Waiting for trigger with timeout: %d' % timeout)
                    trigger_ids = [await with_timeout(self.trigger_queue.get(), timeout, 'ns')]
                except SimTimeoutError:
                    self.dut._log.info('Timed out! Sequence restarted')
                    slot = 0
                    self.dut.expected_slot.value = 0
                    # prevent triggers from coming in right now, because DUT doesn't handle a trigger coming in at the same time as a timeout:
                    self.trigger_allowed = False
                    await ClockCycles(self.dut.clk, 2)
                    self.trigger_allowed = True
                    # ignore any triggers that come at the same time as we time out, because DUT won't handle them:
                    while not self.trigger_queue.empty():
                        trigger_id = self.trigger_queue.get_nowait()
                        self.dut._log.info('..emptying (trigger %d)..' % trigger_id)
                    continue
            while not self.trigger_queue.empty():
                trigger_ids.append(self.trigger_queue.get_nowait())
            if slot > 0:
                prev_timestamp = timestamp
            timestamp = cocotb.utils.get_sim_time(units='ns')/self.harness.period
            if slot > 0:
                timeout_cycles -= (timestamp - prev_timestamp)
                self.dut._log.info('Updating timeout_cycles by to: %d' % timeout_cycles)
            self.dut._log.info('Checker got triggers: %s at clock cycle: %d; active slot=%d' % (trigger_ids, timestamp, slot))
            if slot in trigger_ids:
                if slot == 0:
                    # the first trigger is always accepted
                    timestamps[0] = timestamp
                    slot += 1
                    self.dut.expected_slot.value = slot
                    timeout_cycles = self.max_waits[0]
                    self.dut._log.info('Setting timeout_cycles: %d' % timeout_cycles)
                else:
                    # check if this trigger came within the allowed time range to continue building the sequence:
                    cycles_since_last_trigger = timestamp - timestamps[slot-1]
                    if cycles_since_last_trigger < self.min_waits[slot-1]:
                        # too soon, but maybe another trigger will come along so keep going
                        self.dut._log.info('Trigger too soon; sequence is still alive')
                        pass
                    elif cycles_since_last_trigger > self.max_waits[slot-1]:
                        # too late: start over
                        self.dut._log.info('Trigger too late! Sequence restarted.')
                        slot = 0
                        self.dut.expected_slot.value = slot
                    else:
                        # good trigger!
                        if slot == self.num_triggers - 1:
                            # sequence is done! trigger expected
                            self.dut._log.info('Expecting trigger at clock cycle: %d' % timestamp)
                            await ClockCycles(self.dut.clk, 1)
                            self.expect_trigger(1)
                            await ClockCycles(self.dut.clk, 1)
                            self.expect_trigger(0)
                            slot = 0
                            self.dut.expected_slot.value = slot
                            triggers_done += 1
                        else:
                            # keep advancing in the trigger sequence
                            self.dut._log.info('Good trigger %d; moving on' % slot)
                            timestamps[slot] = timestamp
                            timeout_cycles = self.max_waits[slot]
                            self.dut._log.info('Setting timeout_cycles: %d' % timeout_cycles)
                            slot += 1
                            self.dut.expected_slot.value = slot


    def expect_trigger(self, value) -> None:
        if value:
            self.trigger_expected = True
        self.dut.expected_trigger.value = value

    async def _trigger_watch_thread(self) -> None:
        """ Checks for trigger errors
        """
        while True:
            await Edge(self.trigger_error)
            self.harness.inc_error()
            self.dut._log.error('ERROR: unexpected trigger value!')


    def set_trigger(self, num, val):
        current = self.dut.I_trigger.value
        if val:
            self.dut._log.info('Setting trigger %d' % num)
            self.dut.I_trigger[num].value = 1
            self.trigger_queue.put_nowait(num)
        else:
            self.dut._log.debug('clearing trigger %d' % num)
            self.dut.I_trigger[num].value = 0


    async def set_min_maxes(self):
        mins = 0
        maxs = 0
        for i in range(self.num_triggers-1):
            imin = random.randint(self.dut_min_wait, self.dut_max_wait-2) # TODO: can make this tighter, but conflicts with await ClockCycles(self.dut.clk, random.randint(self.min_waits[t], self.max_waits[t]-2))
            imax = random.randint(imin+2, self.dut_max_wait) # TODO: tighten (but watch for failures as above)
            mins += imin << (i*self.counter_width)
            maxs += imax << (i*self.counter_width)
            self.min_waits[i] = imin
            self.max_waits[i] = imax
            self.dut._log.info('Trigger %d min wait: %4d, max wait: %4d' % (i, imin, imax))
        self.dut.I_min_wait.value = mins
        self.dut.I_max_wait.value = maxs
        await ClockCycles(self.dut.clk, 10)


@cocotb.test(timeout_time=1000, timeout_unit="us")
async def trigger_sequencer_test(dut):
    reps  = int(os.getenv('REPS', '3'))
    test_pass = int(os.getenv('PASS', '0'))
    test_fail = int(os.getenv('FAIL', '0'))
    test_rand = int(os.getenv('RAND', '1'))

    if test_pass:
        test_type = 'pass'
    elif test_fail:
        test_type = 'fail'
    else:
        test_type = 'rand'

    dut._log.info("NUM_TRIGGERS: %d" % dut.pNUM_TRIGGERS.value)
    dut._log.info("COUNTER_WIDTH: %d" % dut.pCOUNTER_WIDTH.value)
    dut._log.info("REPS: %d" % reps)

    harness = Harness(dut, reps)

    triggertest = TriggerSequencerTest(dut, harness, "trigger_test",
                                       num_triggers = dut.pNUM_TRIGGERS.value,
                                       counter_width = dut.pCOUNTER_WIDTH.value,
                                       test_type = test_type
                                      )
    harness.register_test(triggertest)


    harness.start_tests()
    await harness.all_tests_done()
    assert harness.errors == 0


