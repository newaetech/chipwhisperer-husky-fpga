import cocotb
from cocotb.triggers import RisingEdge, ClockCycles, Join, Lock, Event
from cocotb.clock import Clock
from cocotb.queue import Queue
from test_husky_captures import ADCCapture, LACapture, TraceCapture
import random
import numpy as np

class GenericTest(object):
    def __init__(self, dut, harness, registers):
        self.clk = dut.clk_usb
        self.dut = dut
        self.harness = harness
        self.registers = registers
        self.num_captures = None
        self.capture_min = None
        self.capture_max = None
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
        self.dut._log.error("This must be implemented in child class.")

    async def _job_external_source_mods(self, source, job) -> dict:
        """ Change job properties when driven by some external source.
        Takes in the job, modifies the job, takes any required action, and
        returns the modified job.
        """
        self.dut._log.error("This must be implemented in child class.")

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
        self.dut._log.error("This must be implemented in child class.")

    async def _trigger(self, job) -> None:
        """ Trigger the DUT capture.
        """
        self.dut._log.error("This must be implemented in child class.")

    def _untrigger(self, job) -> None:
        """ De-assert trigger, if needed.
        """
        pass

    async def _initial_setup(self) -> None:
        """ Initial DUT setup to do prior to the main dispatch loop.
        """
        self.dut._log.error("This must be implemented in child class.")

    async def _wait_capture_done(self, job: dict) -> None:
        """ Wait for DUT to finish capturing the job we just dispatched, so
        that we can remove our entry from the harness queue (which is used to
        prevent read attempts during capture).
        """
        self.dut._log.error("This must be implemented in child class.")

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
            job_name = self.name + "_job_" + str(self.dispatch_id)
            self.dut_job_signal.value = self.dispatch_id
            job = await self._job_setup()
            job['job_name'] = job_name

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
            self.dut._log.debug("%12s trying to trigger job (waiting for read_lock to be freed)..." % job_name)
            while self.harness.read_lock.locked:
                await ClockCycles(self.clk, 10)
            self.dut._log.debug("%12s trying to trigger job: read_lock freed" % job_name)
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

            # now we can trigger *this* job:
            if not externally_triggered:
                # harness.queue tracks the number of currently active capture jobs; if a job
                # is externally triggered, then it will get accounted for by the *externally triggering job*,
                # otherwise there's a (small) chance for unfortunate timing where everything locks up.
                self.harness.queue.put_nowait(self.name)
                for downstream_trigger in downstream_triggers:
                    self.harness.queue.put_nowait(downstream_trigger.name)
            self.dut._log.debug("%12s pushing to job queue (count = %d)" % (job_name, self.harness.queue.qsize()))
            self.dut._log.info("%12s Triggering: %s" %(job_name, job))
            self.dut.current_action.value = self.harness.hexstring("%12s Triggering" % job_name)
            await self._arm()
            await self._trigger(job)
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
            await self._wait_capture_done(job)
            self._untrigger(job)
            self.harness.queue.get_nowait()
            self.dut._log.debug("%12s popped from job queue (count = %d)" % (job_name, self.harness.queue.qsize()))
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
        fifo_watch_thread = cocotb.start_soon(self.fifo_watch())
        preddr_watch_thread = cocotb.start_soon(self.preddr_watch())
        self.allowed_downstream_triggers = ['LA', 'trace']

    async def _job_setup(self) -> dict:
        samples = random.randint(self.capture_min, self.capture_max)
        await self.registers.write(16, self.registers.to_bytes(samples, 4))
        bits_per_sample = 12
        if random.randint(0,1):
            trigger_type = 'manual'
        else:
            trigger_type = 'io4'
        return {"samples": samples, "bits_per_sample": bits_per_sample, "trigger_type": trigger_type}

    async def _initial_setup(self) -> None:
        await self.registers.write(121, [1]) # use DDR and set ADC ramp mode

    async def _wait_capture_done(self, job: dict) -> None:
        samples = job['samples']
        await ClockCycles(self.clk, samples) # UI clock is USB clock, so that's the dominant portion of the capture delay
        # then, wait for DDR to be done writing:
        #self.dut._log.info("waiting for DDR writing to be done...")
        not_done_writing = True
        while not_done_writing:
            await ClockCycles(self.clk, 50)
            not_done_writing = not await self.harness.ddr_done_writing()

    async def _arm(self) -> None:
        await self.registers.write(1, [0x24]) # disarm
        await self.registers.write(1, [0x0c]) # arm
        await self.harness.wait_flush('ADC')  # allow for any flushes (triggered by arming) to complete before triggering

    async def _trigger(self, job) -> None:
        if job['trigger_type'] == 'manual':
            await self.trigger_now()
        elif job['trigger_type'] == 'io4':
            await self.trigger_io4()
        else:
            raise ValueError
        # TODO: code more trigger options

    async def trigger_now(self) -> None:
        await self.registers.write(1, [0x4c]) # trigger

    async def trigger_io4(self) -> None:
        self.dut.target_io4.value = 1

    def _untrigger(self, job) -> None:
        if job['trigger_type'] == 'io4':
            self.dut.target_io4.value = 0

    async def fifo_watch(self) -> None:
        while True:
            await RisingEdge(self.dut.U_dut.oadc.U_fifo.error_flag or self.dut.U_dut.oadc.U_ddr.U_ddr3_model.dropped_read_request)
            self.harness.inc_error()
            error_message = 'Internal FIFO/DDR error(s): '
            if self.dut.U_dut.oadc.U_ddr.U_ddr3_model.dropped_read_request.value: error_message += "DDR dropped read request "
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

    async def preddr_watch(self) -> None:
        while True:
            await RisingEdge(self.dut.U_dut.U_trace_converter.error_flag or self.dut.U_dut.U_la_converter.error_flag)
            self.harness.inc_error()
            error_message = 'Pre-DDR FIFO error(s): '
            await ClockCycles(self.clk, 2)
            if self.dut.U_dut.U_trace_converter.fifo_overflow_sticky.value:  error_message += "U_trace_converter overflow "
            if self.dut.U_dut.U_trace_converter.fifo_underflow_sticky.value: error_message += "U_trace_converter underflow "
            if self.dut.U_dut.U_la_converter.fifo_overflow_sticky.value:     error_message += "U_la_converter overflow "
            if self.dut.U_dut.U_la_converter.fifo_underflow_sticky.value:    error_message += "U_la_converter underflow "
            self.dut._log.error(error_message)

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
        self.dut._log.info("%12s choosing %d downstream triggers" % (job['job_name'], len(choices)))
        return choices

    @staticmethod
    def valid_external_trigger_combo(choice, job) -> bool:
        result = False # default response
        if (job['trigger_type'] == 'io4' and choice.name == 'trace') or (choice.name == 'LA'):
            result = True
        return result



class LATest(GenericTest):
    def __init__(self, dut, harness, registers, dut_job_signal, dut_reading_signal, num_captures=5):
        super().__init__(dut, harness, registers)
        self.dut_job_signal = dut_job_signal
        self.checker = LACapture(dut, harness, dut_reading_signal)
        self.name = 'LA'

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
        downsample = 0 # TODO: randomize later
        await self.registers.write(77, self.registers.to_bytes(samples, 4))
        await self.registers.write(78, [downsample])
        if bits_per_sample == 8:
            await self.registers.write(76, [0x86])   # LA_CAPTURE_GROUP: group 6 in 4-bit capture mode
        else:
            await self.registers.write(76, [0x06])   # LA_CAPTURE_GROUP: group 6 in 9-bit capture mode
        return {"samples": samples, "bits_per_sample": bits_per_sample, "trigger_type": trigger_type, "downsample": downsample}

    async def _job_external_source_mods(self, source, job) -> dict:
        if source.name == 'ADC':
            job['trigger_type'] = 'ADC'
            await self.registers.write(72, [1]) # LA_TRIGGER_SOURCE
        else:
            raise ValueError
        return job

    async def _post_job(self) -> None:
        """ reset LA_TRIGGER_SOURCE to something that won't fire so it doesn't inadvertently trigger later!
        """
        await self.registers.write(72, [0]) # LA_TRIGGER_SOURCE

    async def _initial_setup(self) -> None:
        await self.registers.write(71, [1])   # LA_CLOCK_SOURCE: select USB clock
        await self.registers.write(99, [1])   # LA_ENABLED

    async def _wait_capture_done(self, job: dict) -> None:
        samples = job['samples']
        await ClockCycles(self.clk, samples) # UI clock is USB clock, so that's the dominant portion of the capture delay
        # then, wait for DDR to be done writing:
        #self.dut._log.info("waiting for DDR writing to be done...")
        not_done_writing = True
        while not_done_writing:
            await ClockCycles(self.clk, 50)
            not_done_writing = not await self.harness.ddr_done_writing()

    async def _arm(self) -> None:
        await self.registers.write(98, [0])   # LA disarm
        await self.registers.write(98, [1])   # LA arm
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
        await self.registers.write(75, [1])   # LA_MANUAL_CAPTURE
        await self.registers.write(75, [0])   # LA_MANUAL_CAPTURE



class TraceTest(GenericTest):
    def __init__(self, dut, harness, registers, dut_job_signal, dut_reading_signal, num_captures=5):
        super().__init__(dut, harness, registers)
        self.dut_job_signal = dut_job_signal
        self.checker = TraceCapture(dut, harness, dut_reading_signal)
        self.name = 'trace'

    async def _job_setup(self) -> dict:
        samples = random.randint(self.capture_min, self.capture_max)
        await self.registers.write(0x8a, self.registers.to_bytes(samples, 3))
        bits_per_sample = 18
        trigger_type = 'manual'
        return {"samples": samples, "bits_per_sample": bits_per_sample, "trigger_type": trigger_type}

    async def _job_external_source_mods(self, source, job) -> dict:
        if source.name == 'ADC':
            job['trigger_type'] = 'ADC'
            await self.registers.write(0xc7, [1]) # REG_SOFT_TRIG_PASSTHRU
            await self.registers.write(0xc8, [1]) # REG_SOFT_TRIG_ENABLE
        else:
            raise ValueError
        return job

    async def _initial_setup(self) -> None:
        await self.registers.write(0x91, [1]) # trace reset
        await self.registers.write(0x91, [0]) 
        await self.registers.write(0xed, [1]) # REG_TRACE_EN: enable trace
        await self.registers.write(0xe5, [2])   # REG_FE_CLOCK_SEL: select USB clock
        await self.registers.write(0x8b, [1])   # REG_COUNT_WRITES
        await self.registers.write(0xf6, [1])   # REG_TRACE_TEST
        await self.registers.write(0xc8, [0])   # REG_SOFT_TRIG_ENABLE: disable, X's otherwise

    async def _wait_capture_done(self, job: dict) -> None:
        samples = job['samples']
        await ClockCycles(self.clk, samples) # UI clock is USB clock, so that's the dominant portion of the capture delay
        # then, wait for DDR to be done writing:
        #self.dut._log.info("waiting for DDR writing to be done...")
        not_done_writing = True
        while not_done_writing:
            await ClockCycles(self.clk, 50)
            not_done_writing = not await self.harness.ddr_done_writing()

    async def _arm(self) -> None:
        await self.registers.write(0x84, [0])   # trace disarm
        await self.registers.write(0x84, [1])   # trace arm
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
        await self.registers.write(0x84, [3])   # capture now

    async def _post_job(self) -> None:
        """ reset trigger settings to something that won't fire so it doesn't inadvertently trigger later!
        """
        await self.registers.write(0xc7, [0]) # REG_SOFT_TRIG_PASSTHRU
        await self.registers.write(0xc8, [0]) # REG_SOFT_TRIG_ENABLE

