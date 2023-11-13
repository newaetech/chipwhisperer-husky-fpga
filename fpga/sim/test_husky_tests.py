import cocotb
from cocotb.triggers import RisingEdge, ClockCycles, Join, Lock, Event, with_timeout
from cocotb.clock import Clock
from cocotb.queue import Queue
from cocotb.handle import Force, Release
from cocotb.result import SimTimeoutError
from test_husky_captures import ADCCapture, LACapture, TraceCapture, GlitchCapture
import random
import math
import numpy as np

class GenericTest(object):
    def __init__(self, dut, harness, registers):
        self.reg_addr = harness.reg_addr
        self.clk = dut.clk_usb
        self.dut = dut
        self.harness = harness
        self.registers = registers
        self.num_captures = None
        self.capture_min = None
        self.capture_max = None
        self.max_presamples = None
        self.max_offset = None
        self.max_downsample = None
        self.checker = None
        self.dut_job_signal = None
        self._coro = None
        self.dispatch_id = 0
        self.name = None
        self.errors = 0
        self.downstream_triggers = []
        self.downstream_triggers_pending = 0
        self.trigger_event = Event()
        self.external_jobs = Queue() # queue for jobs received from other sources
        self.can_be_externally_triggered = True
        self.allowed_downstream_triggers = []

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

    def running(self) -> bool:
        if self._coro is None or self._coro.done():
            return False
        else:
            return True

    async def done(self) -> None:
        """ wait for _run() to complete """
        await Join(self._coro)
        if self.errors:
            self.dut._log.error("%6s test done, failed with %d errors" % (self.name, self.errors))
        else:
            self.dut._log.info("%6s test done: passed!" % self.name)

    async def _job_setup(self) -> dict:
        """ Generate and program properties of the job that will be run.
        Dictionary of values which will be passed to the corresponding
        checker(GenericCapture) instance.
        """
        self.dut._log.error("%12s: _job_setup() must be implemented in child class." % self.name)

    async def _job_external_source_mods(self, source, job) -> dict:
        """ Change job properties when driven by some external source.
        Takes in the job, modifies the job, takes any required action, and
        returns the modified job.
        """
        self.dut._log.error("%12s: _job_external_source_mods() must be implemented in child class." % self.name)

    async def _post_job(self) -> None:
        """ Runs after the job completes.
        """
        pass


    async def _dispatch_delay(self) -> None:
        """ Random delay before starting first job, so that ordering of initial
        jobs is random.
        """
        await ClockCycles(self.clk, random.randint(0,100))

    async def _arm(self) -> None:
        """ Arm the DUT prior to capture.
        """
        self.dut._log.error("%12s: _arm() must be implemented in child class." % self.name)

    async def _trigger(self, job) -> None:
        """ Trigger the DUT capture.
        """
        self.dut._log.error("%12s: _trigger() must be implemented in child class." % self.name)

    def _untrigger(self, job) -> None:
        """ De-assert trigger, if needed.
        """
        pass

    async def _idlecheck(self) -> None:
        """ Check whether DUT is idle, if necessary.
        """
        pass

    async def _initial_setup(self) -> None:
        """ Initial DUT setup to do prior to the main dispatch loop.
        """
        self.dut._log.error("%12s: _initial_setup() must be implemented in child class." % self.name)

    async def _pretrigger_wait(self, job) -> None:
        """ After arming, before triggering: allow for things like presamples, if needed.
        """
        pass

    def _capture_cycles(self, cycles) -> int:
        """ How many USB clock cycles it takes for "cycles" capture clock cycles.
        """
        self.dut._log.error("%12s: _capture_cycles() must be implemented in child class." % self.name)

    def _capture_time_us(self, samples) -> int:
        # assumes 1ns timeunit, which should be specified in makefile via COCOTB_HDL_TIMEUNIT
        usb_cycles = self._capture_cycles(samples)
        time = math.ceil(usb_cycles * self.harness.usb_period * 10**-9 / 10**-6)
        return time

    def max_job_time(self) -> int:
        """ Longest possible time for a job in us, given randomization limits. Can be pessimistic but not
        optimistic. Used to set timeouts.
        """
        self.dut._log.error("%12s: max_job_time() must be implemented in child class." % self.name)


    async def _wait_capture_done(self, job: dict) -> None:
        """ Wait for DUT to finish capturing the job we just dispatched, so
        that we can remove our entry from the harness queue (which is used to
        prevent read attempts during capture).
        """
        samples = job['samples']
        if self.name == 'ADC':
            if job['segments'] > 1 and job['segment_counter_en']:
                samples = job['segments'] * job['segment_cycles'] + job['offset']
            else:
                samples += job['offset']
        await ClockCycles(self.clk, self._capture_cycles(samples)) # UI clock is USB clock, so that's the dominant portion of the capture delay
        # then, wait for DDR to be done writing:
        if self.harness.is_pro:
            self.dut._log.info("%12s waiting for DDR writing to be done..." % job['name'])
            not_done_writing = True
            while not_done_writing:
                await ClockCycles(self.clk, 50)
                not_done_writing = not await self.harness.ddr_done_writing()
            self.dut._log.info("%12s DDR write done" % job['name'])

    def get_downstream_trigger(self, job) -> list:
        """ If a job triggers another job, returns that second job's Test
        class; otherwise, returns None.
        """
        return []

    @staticmethod
    def valid_external_trigger_combo(choice, job) -> bool:
        """ Whether the trigger used by job can be used to trigger choice
        """
        return False

    async def _run(self) -> None:
        """ Main run loop. """
        self.dut_job_signal.value = cocotb.binary.BinaryValue("xxxxxxxx")
        await self._initial_setup()
        await self._dispatch_delay()
        for cap in range(self.num_captures):
            await self._idlecheck()
            job_name = self.name + "_job_" + str(self.dispatch_id)
            self.dut_job_signal.value = self.dispatch_id
            job = await self._job_setup()
            job['name'] = job_name

            # this job might be triggered from a different GenericTest instance, in which case we 
            # may have to change some of its properties: (example: LA job triggered by ADC capture)
            if cap == self.num_captures - 1:
                self.can_be_externally_triggered = False
            if not self.external_jobs.empty():
                source = self.external_jobs.get_nowait()
                self.dut._log.info("%12s using external job from %s" % (job_name, source.name))
                job = await self._job_external_source_mods(source, job)
                self.dut._log.debug("%12s returned from external source mods" % job_name)
                externally_triggered = True
            else:
                self.dut._log.debug("%12s not externally triggered" % job_name)
                externally_triggered = False

            # see comments around queue definition in Harness for how this queue and lock mechanism works:
            self.dut._log.info("%12s trying to trigger job (waiting for read_lock to be freed)..." % job_name)
            while self.harness.read_lock.locked:
                await ClockCycles(self.clk, 10)

            self.dut._log.info("%12s trying to trigger job: read_lock freed" % job_name)
            # decide whether this job also triggers a downstream job:
            downstream_triggers = self.get_downstream_trigger(job)
            if downstream_triggers:
                self.trigger_event.clear()
                self.downstream_triggers_pending = len(downstream_triggers)
                for downstream_trigger in downstream_triggers:
                    self.dut._log.info("%12s sending downstream trigger to %s" % (job_name, downstream_trigger.name))
                    downstream_trigger.external_jobs.put_nowait(self)
                # wait for downstream job to be ready to capture
                while self.downstream_triggers_pending:
                    self.dut._log.debug("%12s waiting for downstream triggers to get set up (%d left)..." % (job_name, self.downstream_triggers_pending))
                    await ClockCycles(self.clk, 10)
                self.dut._log.debug("%12s all downstream triggers are good to go!" % job_name)

            # since some time may have passed, check for read_lock again, and this time set a trigger lock to prevent a read lock from "sneaking in"
            # What we're trying to prevent is that arming and triggering a job entails flushing the post-DDR FIFO and this can mess up a read thread on
            # a different job. And add a trigger_lock, which the capture _run() thread will check, to be 100% sure that no jobs will be triggered
            # while the capture thread sets up and executes its read.
            if not self.harness.trigger_lock.locked:
                await self.harness.trigger_lock.acquire()
            self.dut._log.info("%12s waiting for read_lock to be freed: second check" % job_name)
            while self.harness.read_lock.locked:
                await ClockCycles(self.clk, 10)

            # now we can trigger *this* job:
            if not externally_triggered:
                # harness.queue tracks the number of currently active capture jobs; if a job
                # is externally triggered, then it will get accounted for by the *externally triggering job*,
                # otherwise there's a (small) chance for unfortunate timing where everything locks up.
                #self.harness.queue.put_nowait(self.name)
                self.harness.queue_push(self.name)
                for downstream_trigger in downstream_triggers:
                    #self.harness.queue.put_nowait(downstream_trigger.name)
                    self.harness.queue_push(downstream_trigger.name)
                self.dut._log.info("%12s pushed to job queue (count = %d, contents: %s)" % (job_name, self.harness.queue.qsize(), self.harness._queue_contents))

            await self._arm()
            await self._pretrigger_wait(job)
            self.dut._log.info("%12s Triggering: %s" %(job_name, job))
            self.dut.current_action.value = self.harness.hexstring("%12s Triggering" % job_name)
            await self._trigger(job)
            if self.harness.trigger_lock.locked:
                self.harness.trigger_lock.release()
            self.trigger_event.set()
            if externally_triggered:
                # let the parent triggering job know that we're good to go:
                source.downstream_triggers_pending -= 1
                self.dut._log.info("%12s ready and waiting for external trigger (decremented source's downstream trigger count wait)!" % job_name)
                await source.trigger_event.wait()
                self.dut._log.info("%12s done waiting for external trigger" % job_name)
            # Careful! once the job is pushed to the checker.jobs queue, the checker will try to acquire read_lock, 
            # which can block activity in other concurrently running instances of this _run method.
            self.checker.jobs.put_nowait(job)
            timeout = self.harness.max_job_times()
            self.dut._log.info('%12s kicking off _wait_capture_done() timer for %d us...' % (job_name, timeout))
            try:
                await with_timeout(self._wait_capture_done(job), timeout, 'us')
            except:
                raise SimTimeoutError('%12s timed out on _wait_capture_done()' % job_name)
            self._untrigger(job) # TODO: could be moved up?
            #self.harness.queue.get_nowait()
            self.harness.queue_get(self.name)
            self.dut._log.info("%12s popped from job queue (count = %d, contents: %s)" % (job_name, self.harness.queue.qsize(), self.harness._queue_contents))
            result = await self.checker.results.get()
            await self._post_job()
            #assert result['errors'] == 0 # TODO: optionally assert here, to stop test as soon as errors are found?
            self.errors += result['errors']
            self.dispatch_id += 1



class ADCTest(GenericTest):
    def __init__(self, dut, harness, registers, dut_job_signal, dut_reading_signal, num_captures=5):
        super().__init__(dut, harness, registers)
        self.dut_job_signal = dut_job_signal
        self.checker = ADCCapture(dut, harness, dut_reading_signal)
        self.name = 'ADC'
        self.max_segments = None
        self.max_segment_cycles = None
        self.segment_time_factor = 4
        fifo_watch_thread = cocotb.start_soon(self.fifo_watch())
        if harness.is_pro:
            ddr_watch_thread = cocotb.start_soon(self.ddr_model_watch())
        trigger_watch_thread = cocotb.start_soon(self.trigger_ready_watch())
        self.allowed_downstream_triggers = ['LA', 'trace', 'glitch']

    async def _job_setup(self) -> dict:
        samples = random.randint(self.capture_min, self.capture_max)
        if random.randint(0,3) == 0 or self.max_presamples == 0:
            presamples = 0  # no presamples a quarter of the time
        else:
            presamples = random.randint(8, min(self.max_presamples, samples-2)) # DUT doesn't allow for 1-7 presamples, and samples must be at least 2 more than presamples
        if random.randint(0,3) == 0:
            offset = 0  # no offset a quarter of the time
        else:
            offset = random.randint(0, self.max_offset)
        segments = random.randint(1, self.max_segments)
        segment_cycles = 0
        segment_counter_en = 0
        segment_times = []
        capture_samples_time = samples + offset
        if segments > 1:
            segment_counter_en = random.randint(0,1)
            if segment_counter_en:
                # TODO: this is pessimistic (one segment doesn't last samples+offset+presamples); may want to tighten this?
                if samples+1+offset+presamples >= samples+self.max_segment_cycles:
                    segments = 1
                else:
                    segment_cycles = random.randint(samples+1+offset+presamples, samples+self.max_segment_cycles)
                    capture_samples_time = segment_cycles * segments
            else:
                for i in range(segments-1):
                    min_wait_samples = samples + presamples + offset + 1
                    wait_samples = random.randint(min_wait_samples, min_wait_samples*self.segment_time_factor)
                    segment_times.append(wait_samples)
                    capture_samples_time += wait_samples
            if presamples > 0 and not self.harness.is_pro and samples % 3:
                if samples < 3:
                    samples = 3
                else:
                    samples -= (samples %3)
        if random.randint(0,1) or presamples or segments > 1:
            downsample = 1  # downsamples with presamples or segments is not allowed
        else:
            downsample = random.randint(1, self.max_downsample)

        await self.registers.write(self.reg_addr['DECIMATE_ADDR'], self.registers.to_bytes(0, 2)) # clear this first because setting e.g. presamples when the previous job had this non-zero will cause an error
        await self.registers.write(self.reg_addr['SAMPLES_ADDR'], self.registers.to_bytes(samples, 4))
        await self.registers.write(self.reg_addr['PRESAMPLES_ADDR'], self.registers.to_bytes(presamples, 2))
        await self.registers.write(self.reg_addr['OFFSET_ADDR'], self.registers.to_bytes(offset, 4))
        await self.registers.write(self.reg_addr['NUM_SEGMENTS'], self.registers.to_bytes(segments, 2))
        await self.registers.write(self.reg_addr['SEGMENT_CYCLE_COUNTER_EN'], [segment_counter_en])
        await self.registers.write(self.reg_addr['SEGMENT_CYCLES'], self.registers.to_bytes(segment_cycles, 3))
        await self.registers.write(self.reg_addr['DECIMATE_ADDR'], self.registers.to_bytes(downsample-1, 2))
        bits_per_sample = 12 # TODO
        if random.randint(0,1) or (segments > 1 and segment_counter_en == 0):
            trigger_type = 'io4'
        else:
            trigger_type = 'manual'
        job = {"samples": samples, "presamples": presamples, "offset": offset, "downsample": downsample, "bits_per_sample": bits_per_sample, "trigger_type": trigger_type}
        job['segments'] = segments
        job['segment_counter_en'] = segment_counter_en
        job['segment_cycles'] = segment_cycles
        job['segment_times'] = segment_times
        job['capture_time_us'] = self._capture_time_us(capture_samples_time)
        job['limited_reads'] = False
        return job

    def max_job_time(self) -> int:
        if self.max_segments > 1:
            max_sample_time = max((self.capture_max + self.max_offset + self.max_presamples) * self.max_downsample * self.max_segments * self.segment_time_factor,
                                  self.max_segment_cycles * self.max_segments)
        else:
            max_sample_time = (self.capture_max + self.max_offset) * self.max_downsample
        return self._capture_time_us(max_sample_time)

    async def _initial_setup(self) -> None:
        await self.registers.write(self.reg_addr['FIFO_CONFIG'], [1]) # use DDR and set ADC ramp mode

    async def _arm(self) -> None:
        await self.registers.write(self.reg_addr['SETTINGS_ADDR'], [0x24]) # disarm
        await self.registers.write(self.reg_addr['SETTINGS_ADDR'], [0x0c]) # arm
        await self.harness.wait_flush('ADC')  # allow for any flushes (triggered by arming) to complete before triggering

    async def _trigger(self, job) -> None:
        if job['segment_counter_en'] == 0:
            iterations = job['segments']
        else:
            iterations = 1
        for i in range(iterations):
            if job['trigger_type'] == 'manual':
                await self.trigger_now()
            elif job['trigger_type'] == 'io4':
                await self.trigger_io4()
            # TODO: code more trigger options
            else:
                raise ValueError
            if iterations > 1:
                self.dut._log.info('%12s issued trigger %d' % (job['name'], i))
                if i < iterations - 1:
                    untrigger_wait = self._capture_cycles(random.randint(1, job['segment_times'][i]-2))
                    untrigger_thread = cocotb.start_soon(self._untrigger_thread(job, untrigger_wait))
                    await ClockCycles(self.clk, self._capture_cycles(job['segment_times'][i]))

    async def trigger_now(self) -> None:
        await self.registers.write(self.reg_addr['SETTINGS_ADDR'], [0x4c]) # trigger

    async def trigger_io4(self) -> None:
        self.dut.target_io4.value = 1

    async def _untrigger_thread(self, job, untrigger_wait) -> None:
        await ClockCycles(self.clk, untrigger_wait)
        self._untrigger(job)

    async def _idlecheck(self) -> None:
        self.dut._log.info('waiting for DUT to be idle before setting up next job')
        idle = False
        while not idle:
            raw = (await self.registers.read(self.reg_addr['FIFO_STATE'], 1))[0]
            idle = (raw & 0x03) == 0


    def _untrigger(self, job) -> None:
        if job['trigger_type'] == 'io4':
            self.dut.target_io4.value = 0

    async def _pretrigger_wait(self, job) -> None:
        presamples = job['presamples']
        if presamples > 0:
            min_cycles = self._capture_cycles(presamples + 1)
            wait_cycles = random.randint(min_cycles, min_cycles*4)
            self.dut._log.info('%12s pre-trigger waiting %d cycles' % (job['name'], wait_cycles))
            await ClockCycles(self.dut.PLL_CLK1, wait_cycles) # note: Pro used self.clk (USB clock), why did that work?!?
        if not self.harness.is_pro:
            # on Husky the FIFO flushing can be *slow*, so explicitely check on FIFO empty flag:
            #await ClockCycles(self.clk, 100)
            empty = False
            while not empty:
                await ClockCycles(self.clk, 50)
                empty = (await self.harness.registers.read(self.reg_addr['FIFO_STAT'], 2))[1] & 32
            await ClockCycles(self.clk, 5) # bit more time for armed_and_ready to rise


    def _capture_cycles(self, cycles) -> int:
        return math.ceil(self.harness.adc_period / self.harness.usb_period * cycles)

    async def fifo_watch(self) -> None:
        while True:
            await RisingEdge(self.dut.U_dut.oadc.U_fifo.error_flag)
            self.harness.inc_error()
            error_message = 'Internal FIFO/DDR error(s): '
            await ClockCycles(self.clk, 2) # Note: without this, error_value comes back as 0, even though it changes on the same cycle as error_flag
            error_value = self.dut.U_dut.oadc.U_fifo.error_stat.value
            # accessing vector bits requires iverilog >= 10.3:
            if error_value & 2**12: error_message += "ddr_full "
            if error_value & 2**11: error_message += "reading_too_soon  "
            if error_value & 2**10: error_message += "preddr_fifo_overflow "
            if error_value & 2**9 : error_message += "preddr_fifo_underflow "
            if error_value & 2**8 : error_message += "gain_error "
            if error_value & 2**7 : error_message += "segment_error "
            if error_value & 2**6 : error_message += "downsample_error "
            if error_value & 2**5 : error_message += "clip_error "
            if error_value & 2**4 : error_message += "presamp_error "
            if error_value & 2**3 : error_message += "fast_fifo_overflow"
            if error_value & 2**2 : error_message += "fast_fifo_underflow "
            if error_value & 2**1 : error_message += "postddr_fifo_overflow "
            if error_value & 2**0 : error_message += "postddr_fifo_underflow_masked "
            self.dut._log.error(error_message)

    async def ddr_model_watch(self) -> None:
        while True:
            await RisingEdge(self.dut.U_dut.oadc.U_ddr.U_ddr3_model.dropped_read_request)
            self.harness.inc_error()
            self.dut._log.error('Internal FIFO/DDR error(s): DDR dropped read request')

    async def trigger_ready_watch(self) -> None:
        while True:
            await RisingEdge(self.dut.U_dut.oadc.tu_inst.trigger_level_match)
            if not self.dut.U_dut.oadc.tu_inst.armed_and_ready.value:
                self.harness.inc_error()
                self.dut._log.error('Trigger before armed_and_ready! (testbench error)')


    def get_downstream_trigger(self, job) -> list:
        # Randomly choose the number of *potential* downstream triggers, up to and including all possible downstream triggers.
        # Since potential downstream triggers can get discarded for many reasons (via can_be_externally_triggered and 
        # valid_external_trigger_combo), we skew the random choice heavily towards the maximum.
        if len(self.downstream_triggers):
            weights=[1]*(len(self.downstream_triggers)+1)
            weights[-1] = 4
            num_potential_triggers = random.choices(range(len(self.downstream_triggers)+1), weights)[0]
        else:
            num_potential_triggers = 0
        if (num_potential_triggers == 0) or (not self.harness.allow_downstream_triggers):
            choices = []
        else:
            choices = []
            for i in range(num_potential_triggers):
                choice = random.choice(self.downstream_triggers)
                if choice.can_be_externally_triggered and self.valid_external_trigger_combo(choice, job) and choice not in choices:
                    choices.append(choice)
        self.dut._log.info("%12s choosing %d downstream triggers: %s" % (job['name'], len(choices), choices))
        return choices

    def valid_external_trigger_combo(self, choice, job) -> bool:
        result = False # default response
        if (job['trigger_type'] == 'io4' and ((choice.name == 'trace') or (choice.name == 'glitch'))) or (choice.name == 'LA'):
            result = True
        return result



class LATest(GenericTest):
    def __init__(self, dut, harness, registers, dut_job_signal, dut_reading_signal, num_captures=5):
        super().__init__(dut, harness, registers)
        self.dut_job_signal = dut_job_signal
        self.checker = LACapture(dut, harness, dut_reading_signal)
        self.name = 'LA'
        if harness.is_pro:
            preddr_watch_thread = cocotb.start_soon(self.preddr_watch())

    async def _job_setup(self) -> dict:
        samples = random.randint(self.capture_min, self.capture_max)
        if samples % 2: 
            # in both 4- and 9-bit mode, samples are collected two at a time, so enforce it to be an even number
            samples -= 1
        if random.randint(0,1):
            bits_per_sample = 8 # not a typo: in four-bit mode the ramp pattern is 8 bits long
        else:
            bits_per_sample = 9
        trigger_type = 'manual'
        if random.randint(0,3) == 0:
            downsample = random.randint(1, self.max_downsample)
        else:
            downsample = 1  # no downsample most of the time
        await self.registers.write(self.reg_addr['LA_CAPTURE_DEPTH'], self.registers.to_bytes(samples, 4))
        await self.registers.write(self.reg_addr['LA_DOWNSAMPLE'], [downsample-1])
        if bits_per_sample == 8:
            await self.registers.write(self.reg_addr['LA_CAPTURE_GROUP'], [0x87])   # group 7 in 4-bit capture mode
        else:
            await self.registers.write(self.reg_addr['LA_CAPTURE_GROUP'], [0x07])   # group 7 in 9-bit capture mode
        job = {"samples": samples, "bits_per_sample": bits_per_sample, "trigger_type": trigger_type, "downsample": downsample}
        job['capture_time_us'] = self._capture_time_us(samples)
        return job

    def max_job_time(self) -> int:
        return self._capture_time_us(self.capture_max * self.max_downsample)

    async def _job_external_source_mods(self, source, job) -> dict:
        if source.name == 'ADC':
            job['trigger_type'] = 'ADC'
            await self.registers.write(self.reg_addr['LA_TRIGGER_SOURCE'], [1])
        else:
            raise ValueError
        return job

    async def _post_job(self) -> None:
        """ reset LA_TRIGGER_SOURCE to something that won't fire so it doesn't inadvertently trigger later!
        """
        await self.registers.write(self.reg_addr['LA_TRIGGER_SOURCE'], [0])

    async def _initial_setup(self) -> None:
        await self.registers.write(self.reg_addr['LA_CLOCK_SOURCE'], [1])   # select USB clock
        await self.registers.write(self.reg_addr['LA_ENABLED'], [1])

    async def _arm(self) -> None:
        await self.registers.write(self.reg_addr['LA_ARM'], [0])   # disarm
        await self.registers.write(self.reg_addr['LA_ARM'], [1])   # arm
        await self.harness.wait_flush('LA')   # allow for any flushes (triggered by arming) to complete before triggering

    async def _trigger(self, job) -> None:
        if job['trigger_type'] == 'manual':
            await self.trigger_now()
        elif job['trigger_type'] == 'ADC':
            pass # nothing to do!
        else:
            raise ValueError
        # TODO: code more trigger options

    async def trigger_now(self) -> None:
        await self.registers.write(self.reg_addr['LA_MANUAL_CAPTURE'], [1])
        await self.registers.write(self.reg_addr['LA_MANUAL_CAPTURE'], [0])

    def _capture_cycles(self, cycles) -> int:
        # TODO: currently using USB clock to capture; when this changes, this needs to be updated!
        return cycles

    async def preddr_watch(self) -> None:
        while True:
            await RisingEdge(self.dut.U_dut.U_la_converter.error_flag)
            self.harness.inc_error()
            error_message = 'Pre-DDR FIFO error(s): '
            await ClockCycles(self.clk, 2)
            if self.dut.U_dut.U_la_converter.fifo_overflow_sticky.value:     error_message += "U_la_converter overflow "
            if self.dut.U_dut.U_la_converter.fifo_underflow_sticky.value:    error_message += "U_la_converter underflow "
            self.dut._log.error(error_message)


class TraceTest(GenericTest):
    def __init__(self, dut, harness, registers, dut_job_signal, dut_reading_signal, num_captures=5):
        super().__init__(dut, harness, registers)
        self.dut_job_signal = dut_job_signal
        self.checker = TraceCapture(dut, harness, dut_reading_signal)
        self.name = 'trace'
        if harness.is_pro:
            preddr_watch_thread = cocotb.start_soon(self.preddr_watch())

    async def _job_setup(self) -> dict:
        samples = random.randint(self.capture_min, self.capture_max)
        await self.registers.write(0x8a, self.registers.to_bytes(samples, 3))
        bits_per_sample = 18
        trigger_type = 'manual'
        job = {"samples": samples, "bits_per_sample": bits_per_sample, "trigger_type": trigger_type}
        job['capture_time_us'] = self._capture_time_us(samples)
        return job

    def max_job_time(self) -> int:
        return self._capture_time_us(self.capture_max)

    async def _job_external_source_mods(self, source, job) -> dict:
        if source.name == 'ADC':
            job['trigger_type'] = 'ADC'
            await self.registers.write(self.reg_addr['REG_SOFT_TRIG_PASSTHRU'], [1])
            await self.registers.write(self.reg_addr['REG_SOFT_TRIG_ENABLE'], [1])
        else:
            raise ValueError
        return job

    async def _initial_setup(self) -> None:
        await self.registers.write(self.reg_addr['REG_RESET_REG'], [1])
        await self.registers.write(self.reg_addr['REG_RESET_REG'], [0]) 
        await self.registers.write(self.reg_addr['REG_TRACE_EN'], [1]) # enable trace
        await self.registers.write(self.reg_addr['REG_FE_CLOCK_SEL'], [2]) # select USB clock
        await self.registers.write(self.reg_addr['REG_COUNT_WRITES'], [1]) 
        await self.registers.write(self.reg_addr['REG_TRACE_TEST'], [1])
        await self.registers.write(self.reg_addr['REG_SOFT_TRIG_ENABLE'], [0])

    async def _arm(self) -> None:
        await self.registers.write(self.reg_addr['REG_ARM'], [0])   # disarm
        await self.registers.write(self.reg_addr['REG_ARM'], [1])   # arm
        await self.harness.wait_flush('trace')# allow for any flushes (triggered by arming) to complete before triggering

    async def _trigger(self, job) -> None:
        if job['trigger_type'] == 'manual':
            await self.trigger_now()
        elif job['trigger_type'] == 'ADC':
            pass # nothing to do!
        else:
            raise ValueError
        # TODO: code more trigger options

    async def trigger_now(self) -> None:
        await self.registers.write(self.reg_addr['REG_ARM'], [3])   # capture now

    async def _post_job(self) -> None:
        """ reset trigger settings to something that won't fire so it doesn't inadvertently trigger later!
        """
        await self.registers.write(self.reg_addr['REG_SOFT_TRIG_PASSTHRU'], [0])
        await self.registers.write(self.reg_addr['REG_SOFT_TRIG_ENABLE'], [0])

    def _capture_cycles(self, cycles) -> int:
        # TODO: currently using USB clock to capture; when this changes, this needs to be updated!
        return cycles

    async def preddr_watch(self) -> None:
        while True:
            await RisingEdge(self.dut.U_dut.U_trace_converter.error_flag)
            self.harness.inc_error()
            error_message = 'Pre-DDR FIFO error(s): '
            await ClockCycles(self.clk, 2)
            if self.dut.U_dut.U_trace_converter.fifo_overflow_sticky.value:  error_message += "U_trace_converter overflow "
            if self.dut.U_dut.U_trace_converter.fifo_underflow_sticky.value: error_message += "U_trace_converter underflow "
            self.dut._log.error(error_message)



class GlitchTest(GenericTest):
    def __init__(self, dut, harness, registers, dut_job_signal, dut_reading_signal, num_captures=5):
        super().__init__(dut, harness, registers)
        self.dut_job_signal = dut_job_signal
        self.checker = GlitchCapture(dut, harness, dut_reading_signal)
        self.name = 'glitch'

    async def _initial_setup(self) -> None:
        await self.registers.write(self.reg_addr['CLOCKGLITCH_POWERDOWN'], [0])
        await ClockCycles(self.dut.clk_usb, 20)
        self.checker._start_watch_threads()

    async def _job_setup(self) -> dict:
        trigger_type = 'manual'
        #glitches = random.randint(self.capture_min, self.capture_max)
        glitches = 1 # TODO: more glitches (not all triggers support multiple!)
        offset = random.randint(0, 10) # TODO: randomize over legal range
        repeats = random.randint(1, 10) # TODO: randomize over legal range
        await self.registers.write(self.reg_addr['CLOCKGLITCH_NUM_GLITCHES'], [glitches-1])
        await self.registers.write(self.reg_addr['CLOCKGLITCH_OFFSET'], self.registers.to_bytes(offset, 4))
        # setting the repeats value is messy:
        settings = [0]*8
        settings[5] = 0x4c
        if trigger_type == 'manual':
            settings[5] &= 0xf3 # clear bits 3:2
        else:
            raise ValueError('not supported yet')
        settings[6] = (repeats-1) & 0xff
        settings[7] = (((repeats-1)>>8) << 2) + 1   # use USB clock, otherwise there will be a +/- 1 cycle uncertainty on
                                                    # the glitch output timing, which would complicate verification
        await self.registers.write(self.reg_addr['CLOCKGLITCH_SETTINGS'], settings)
        job = {"glitches": glitches, "offset": offset, "repeats": repeats, "trigger_type": trigger_type}
        job['capture_time_us'] = 100 # TODO: calculate
        return job

    async def _job_external_source_mods(self, source, job) -> dict:
        if source.name == 'ADC':
            job['trigger_type'] = 'ADC'
            await self.set_glitch_trigger_type('ext_single')
            self.dut._log.info('%12s ready for external trigger!' % job['name'])
        else:
            raise ValueError
        return job

    async def set_glitch_trigger_type(self, ttype) -> None:
        if ttype == 'ext_single':
            ttype = 3
        elif ttype == 'continuous':
            ttype = 2
        elif ttype == 'ext_continuous':
            ttype = 1
        elif ttype == 'manual':
            ttype = 0
        else:
            raise ValueError('unsupported trigger type')
        settings = await self.registers.read(self.reg_addr['CLOCKGLITCH_SETTINGS'], 8)
        settings[5] = (settings[5] & ~(0x0C)) | (ttype << 2)
        await self.registers.write(self.reg_addr['CLOCKGLITCH_SETTINGS'], settings)
        settings[5] = settings[5] | (1 << 7)
        if ttype != 'ext_continuous': # in this case we don't need to re-arm:
            await self.registers.write(self.reg_addr['CLOCKGLITCH_SETTINGS'], settings)
            settings[5] = settings[5] & ~(1 << 7)
            await self.registers.write(self.reg_addr['CLOCKGLITCH_SETTINGS'], settings)


    def max_job_time(self) -> int:
        return 0 # TODO?

    async def _wait_capture_done(self, job: dict) -> None:
        pass

    async def _arm(self) -> None:
        pass

    async def _trigger(self, job) -> None:
        if job['trigger_type'] == 'manual':
            await self.trigger_now()
        elif job['trigger_type'] == 'ADC':
            pass # nothing to do! (because externally triggered; TODO!)
        else:
            raise ValueError
        # TODO: code more trigger options

    async def trigger_now(self) -> None:
        settings = await self.harness.registers.read(self.reg_addr['CLOCKGLITCH_SETTINGS'], 8)
        settings[5] |= 0x80 # set manual trigger bit
        await self.registers.write(self.reg_addr['CLOCKGLITCH_SETTINGS'], settings)

    def _capture_cycles(self, cycles) -> int:
        # TODO: currently using USB clock to capture; when this changes, this needs to be updated!
        return cycles

    async def _post_job(self) -> None:
        """ reset trigger settings to something that won't fire so it doesn't inadvertently trigger later!
        """
        settings = await self.harness.registers.read(self.reg_addr['CLOCKGLITCH_SETTINGS'], 8)
        settings[5] &= 0x7f # clear manual trigger bit in case it was set; no harm if it wasn't
        await self.registers.write(self.reg_addr['CLOCKGLITCH_SETTINGS'], settings[:6])


