import cocotb
from cocotb.triggers import RisingEdge, FallingEdge, Timer, ClockCycles, Join, Lock, Event
from cocotb.clock import Clock
from cocotb.queue import Queue
from cocotb.handle import Force, Release
from cocotb.log import SimLogFormatter
#from cocotb.regression import TestFactory
import random
import math
from cw310_registers import Registers
import numpy as np
import logging
import os

# Note: this could also be place in individual test functions by replacing root_logger by dut._log.
root_logger = logging.getLogger()
logfile = os.getenv('LOGFILE', 'make.log')
print('Logfile = %s' % logfile)
fh = logging.FileHandler(logfile, 'w')
fh.setFormatter(SimLogFormatter())
root_logger.addHandler(fh)

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
        self.downstream_triggers = [None]
        self.allow_downstream_triggers = True
        self.downstream_event = Event()
        self.external_jobs = Queue() # queue for jobs received from other sources
        self.can_be_externally_triggered = True

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

    async def _job_external_source_mods(self, job) -> dict:
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

    async def _trigger(self, job) -> None:
        """ Trigger the DUT capture.
        """
        self.dut._log.error("This must be implemented in child class.")

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

    def get_downstream_trigger(self) -> None:
        """ If a job triggers another job, returns that second job's Test
        class; otherwise, returns None.
        """
        return None

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
                source, event = self.external_jobs.get_nowait()
                self.dut._log.info("%12s using external job from %s" % (job_name, source.name))
                job = await self._job_external_source_mods(source, job)
                externally_triggered = True
            else:
                externally_triggered = False

            # see comments around queue definition in Harness for how this queue and lock mechanism works:
            self.dut._log.debug("%12s trying to trigger job..." % job_name)
            while self.harness.read_lock.locked:
                await ClockCycles(self.clk, 10)
            self.dut._log.debug("%12s trying to trigger job: read lock freed" % job_name)
            # decide whether this job also triggers a downstream job:
            # TODO: this only allows a single downstream trigger; extend it to multiple!
            downstream_trigger = self.get_downstream_trigger()
            if downstream_trigger:
                self.dut._log.info("%12s sending downstream trigger to %s" % (job_name, downstream_trigger.name))
                downstream_trigger.external_jobs.put_nowait((self, self.downstream_event))
                # wait for downstream job to be ready to capture
                await self.downstream_event.wait()
                self.downstream_event.clear()

            # now we can trigger *this* job:
            self.harness.queue.put_nowait(self.name)
            self.dut._log.debug("%12s pushing to job queue (count = %d)" % (job_name, self.harness.queue.qsize()))
            self.dut._log.info("%12s Triggering: %s" %(job_name, job))
            self.dut.current_action.value = self.harness.hexstring("%12s Triggering" % job_name)
            await self._trigger(job)
            if externally_triggered:
                # let the parent triggering job know that we're good to go:
                event.set()
            self.checker.jobs.put_nowait(job)
            await self._wait_capture_done(job)
            self.harness.queue.get_nowait()
            self.dut._log.debug("%12s popping from job queue (count = %d)" % (job_name, self.harness.queue.qsize()))
            result = await self.checker.results.get()
            await self._post_job()
            #assert result['errors'] == 0 # TODO: optionally assert here, to stop test as soon as errors are found?
            self.errors += result['errors']
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
        self.errors = 0
        self.first_read_sample = None
        self.raw_read_data = []

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

    async def _check_fifo_errors(self, job_name) -> None:
        """ Check FIFO status and errors. Meant to be called after reading all
        samples. Verifies that FIFO is empty.
        """
        self.dut._log.error("This must be implemented in child class.")

    def _check_samples(self, job, data) -> None:
        """ Check <data> for errors. Return the number of errors seen.
        """
        self.dut._log.error("This must be implemented in child class.")

    def inc_error(self) -> None:
        """ Call this to increase the local class error count, the global
        harness error count, and the waveform error count, with one easy call.
        """
        self.errors += 1
        self.harness.inc_error()

    async def _run(self) -> None:
        """ Main run loop. """
        self.dut_reading_signal.value = 0
        self.job_id = 0
        while True:
            job = await self.jobs.get()
            job_name = job['job_name']
            #await self._pre_read_wait(job) TODO: no longer needed since _wait_capture_done does the equivalent?
            # see comments around queue definition in Harness for how this queue and lock mechanism works:
            self.dut._log.info("%12s trying to acquire read lock..." % job_name)
            await self.harness.read_lock.acquire()
            self.dut._log.debug("%12s read lock acquired" % job_name)
            self.dut._log.debug("%12s awaiting empty queue (count = %d)" % (job_name, self.harness.queue.qsize()))
            while not self.harness.queue.empty():
                await ClockCycles(self.clk, 10)
            self.dut._log.debug("%12s empty queue wait done" % job_name)
            self.dut.current_action.value = self.harness.hexstring("%12s initread" % job_name)
            await self._initiate_read()
            self.dut_reading_signal.value = 1
            self.dut._log.info("%12s Starting read for job: %s" % (job_name, job))
            self.dut.current_action.value = self.harness.hexstring("%12s Reading" % job_name)
            data = await self._read_samples(job)
            self.dut._log.info("%12s Done read" % job_name)
            self.harness.read_lock.release()
            self.dut._log.info("%12s read lock released" % job_name)
            self.dut_reading_signal.value = 0
            await self._check_fifo_errors(job_name)
            self._check_samples(job, data)
            self.results.put_nowait({"errors": self.errors})
            if self.errors:
                self.find_bad_words(job)
            self.job_id += 1

    def _limit_read(self, job) -> int:
        """ To test that the design functions correctly when the full capture is not read back.
        """
        samples = job['samples']
        #1. Read full capture 75% of the time:
        if random.randint(0,3) < 3:
            return samples
        #2. otherwise randomly reduce the number of samples read to as little as 1:
        else:
            samples = random.randint(1, samples-1)
            self.dut._log.info("%12s reducing sample read count to %d" % (job['job_name'], samples))
            return samples

    def find_bad_words(self, job):
        """ Convenience method to help debugging bad sample reads.
        Internally, Husky stores sample data in 32-bit words. Since the source
        samples can be 9, 12 or 18 bits wide, it can be hard to pinpoint where
        things go wrong inside Husky when a bad sample value is obtained. Given
        the first sample of a capture (assumed to be correct), this method
        prints the sequence of expected 32-bit words and the actual received
        sequence of 32-bit words; this makes it easier to
        see where things diverged.
        """
        expected_words = []
        actual_words = []
        first_sample = self.first_read_sample
        width = job['bits_per_sample']
        increment = self.sample_increment
        mod = 2**width
        read_data = self.raw_read_data
        num_big_words = math.ceil(len(read_data)*8/(32*width))

        #self.dut._log.info("num_big_words=%d, read_data=%s" % (num_big_words, read_data))
        self.dut._log.info("first=%03x, width=%d, increment=%d, mod=%d" % (first_sample, width, increment, mod))
        if len(read_data) % 4:
            read_data.extend([0]*(4-len(read_data)%4))
        message = "Expected: "
        word = first_sample
        for i in range(num_big_words):
            big_word = 0
            for j in range(32):
                big_word = word + (big_word << width)
                word = (word + increment) % mod
                #self.dut._log.info("j=%d, big_word: %096x; word=%d" % (j, big_word, word))
                #self.dut._log.info("j=%d, big_word: %x; word=%d" % (j, big_word, word))
            for j in range(width):
                word32bits = (big_word >> (32*(width-j-1)) & 0xffff_ffff)
                #self.dut._log.info("words32bits: %
                message += "%08x " % word32bits
                expected_words.append(word32bits)
        message += "\nGot:      "
        num_words = math.floor(len(read_data)/4)
        for i in range(num_words):
            big_word = 0
            for j in range(4):
                big_word = read_data[i*4+j] + (big_word << 8)
            message += "%08x " % big_word
            actual_words.append(big_word)
        self.dut._log.info(message)
        for i in range(len(actual_words)):
            if actual_words[i] != expected_words[i]:
                self.dut._log.error("32-bit word %3d: expected %08x" % (i, expected_words[i]))
                self.dut._log.error("                 got      %08x" % actual_words[i])



class ADCTest(GenericTest):
    def __init__(self, dut, harness, registers, dut_job_signal, dut_reading_signal, num_captures=5):
        super().__init__(dut, harness, registers)
        self.dut_job_signal = dut_job_signal
        self.checker = ADCCapture(dut, harness, dut_reading_signal)
        self.name = 'ADC'
        fifo_watch_thread = cocotb.start_soon(self.fifo_watch())
        preddr_watch_thread = cocotb.start_soon(self.preddr_watch())

    async def _job_setup(self) -> dict:
        samples = random.randint(self.capture_min, self.capture_max)
        await self.registers.write(16, self.registers.to_bytes(samples, 4))
        bits_per_sample = 12
        return {"samples": samples, "bits_per_sample": bits_per_sample}

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

    async def _trigger(self, job) -> None:
        await self.trigger_now()
        # TODO: code more trigger options

    async def trigger_now(self) -> None:
        await self.registers.write(1, [0x24]) # disarm
        await self.registers.write(1, [0x0c]) # arm
        await self.harness.wait_flush('ADC')  # allow for any flushes (triggered by arming) to complete before triggering
        await self.registers.write(1, [0x4c]) # trigger

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
            if self.dut.U_dut.U_trace_converter.fifo_overflow_sticky:  error_message += "U_trace_converter overflow "
            if self.dut.U_dut.U_trace_converter.fifo_underflow_sticky: error_message += "U_trace_converter underflow "
            if self.dut.U_dut.U_la_converter.fifo_overflow_sticky:     error_message += "U_la_converter overflow "
            if self.dut.U_dut.U_la_converter.fifo_underflow_sticky:    error_message += "U_la_converter underflow "
            self.dut._log.error(error_message)

    def get_downstream_trigger(self) -> None:
        # TODO: possibly return multiple downstream triggers
        if self.allow_downstream_triggers:
            choice = random.choice(self.downstream_triggers)
            if choice is not None:
                if not choice.can_be_externally_triggered:
                    choice = None
        else:
            choice = None
        return choice


class ADCCapture(GenericCapture):
    def __init__(self, dut, harness, dut_reading_signal):
        super().__init__(dut, harness, dut_reading_signal)
        self.name = 'ADC'
        self.sample_increment = 1

    async def read_adc_data(self, samples, bits_per_sample):
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
        await self.harness.wait_flush('ADC') # if previous read wasn't complete, wait for post-DDR to get flushed
        # wait for read FIFO to be not empty:
        #self.dut._log.info("waiting for FIFO to not be empty...")
        empty = True
        while empty:
            await ClockCycles(self.clk, 50)
            empty = (await self.harness.registers.read(44, 2))[1] & 32

    async def _read_samples(self, job) -> list:
        samples = self._limit_read(job)
        bits_per_sample = job['bits_per_sample']
        #self.dut._log.info("starting the read (%0d samples)" % samples)
        self.raw_read_data = await self.read_adc_data(samples, bits_per_sample)
        data = self.processHuskyData(samples, bytearray(self.raw_read_data))
        return data

    async def _check_fifo_errors(self, job_name) -> None:
        # TODO: replace internal signal checks with a register status read
        if self.dut.U_dut.oadc.U_fifo.fast_fifo_empty.value == 0:
            self.harness.inc_error()
            self.dut._log.error('%12s fast FIFO not empty after reading all samples.' % job_name)
        if self.dut.U_dut.oadc.U_fifo.preddr_fifo_empty.value == 0:
            self.harness.inc_error()
            self.dut._log.error('%12s pre-DDR FIFO not empty after reading all samples.' % job_name)
        ## TODO: temporarily commented out because last word is left unread, due to the first word fallthrough nature of the FIFO.
        #if self.dut.U_dut.oadc.U_fifo.postddr_fifo_empty.value == 0:
        #    self.harness.inc_error()
        #    self.dut._log.error('%12s post-DDR FIFO not empty after reading all samples.' % job_name)

    @staticmethod
    def processHuskyData(NumberPoints, data, bits_per_sample=12):
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

    def _check_samples(self, job, data) -> None:
        bits_per_sample = job['bits_per_sample']
        segment_cycles = 0 # TODO
        verbose = True # TODO?
        stop = False # TODO?
        MOD = 2**bits_per_sample
        samples = len(data)
        current_count = data[0]
        self.first_read_sample = int(current_count)
        first_error = None
        #self.dut._log.info("Checking ramp (%0d samples)" % len(data))
        for i, byte in enumerate(data[1:]):
            if byte != (current_count+1)%MOD:
                self.dut._log.error("%12s Sample %4d: expected %3x got %3x" % (job['job_name'], i+1, (current_count+1)%MOD, byte))
                self.inc_error()
                if stop:
                    return
                if not first_error:
                    first_error = i
                current_count = byte
            else:
                self.dut._log.debug("%12s Good sample %4d: %2x" % (job['job_name'], i+1, byte))
                current_count += 1
                if (i+2) % samples == 0:
                    current_count = (current_count + segment_cycles - samples) % MOD



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
        #source = self.external_jobs.get_nowait()
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

    async def _trigger(self, job) -> None:
        if job['trigger_type'] == 'manual':
            await self.trigger_now()
        elif job['trigger_type'] == 'ADC':
            await self.trigger_adc()
        else:
            raise ValueError
        # TODO: code more trigger options

    async def trigger_now(self) -> None:
        await self.registers.write(98, [0])   # LA disarm
        await self.registers.write(98, [1])   # LA arm
        await self.harness.wait_flush('LA')   # allow for any flushes (triggered by arming) to complete before triggering
        await self.registers.write(75, [1])   # LA_MANUAL_CAPTURE
        await self.registers.write(75, [0])   # LA_MANUAL_CAPTURE

    async def trigger_adc(self) -> None:
        await self.registers.write(98, [0])   # LA disarm
        await self.registers.write(98, [1])   # LA arm
        await self.harness.wait_flush('LA')   # allow for any flushes (triggered by arming) to complete before triggering



class LACapture(GenericCapture):
    def __init__(self, dut, harness, dut_reading_signal):
        super().__init__(dut, harness, dut_reading_signal)
        self.name = 'LA'
        self.sample_increment = None # filled in by each job

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
        await self.harness.wait_flush('LA') # if previous read wasn't complete, wait for post-DDR to get flushed
        # wait for read FIFO to be not empty:
        #self.dut._log.info("waiting for FIFO to not be empty...")
        empty = True
        while empty:
            await ClockCycles(self.clk, 50)
            empty = (await self.harness.registers.read(44, 2))[1] & 32

    async def _read_samples(self, job) -> list:
        samples = self._limit_read(job)
        bits_per_sample = job['bits_per_sample']
        if bits_per_sample == 8:
            bytes_to_read = math.ceil(samples/2)
        elif bits_per_sample == 9:
            bytes_to_read = math.ceil(samples*9/8)
        else:
            raise ValueError("Unsupported capture width")
        data = list(await self.harness.registers.read(3, bytes_to_read))
        self.raw_read_data = data
        if bits_per_sample == 9:
            data = self.process9bitRawData(data)
        return data

    @staticmethod
    def process9bitRawData(raw, verbose=False):
        """ Check LA 9-bit ramp pattern: instead of efficient numpy.reshape (as
        done in processHuskyData), we take a simple big hammer...
            1. expand the raw data list to a multiple of 9*64 bits = 72 bytes = 576 bits;
            2. take each 72-byte chunk as a large number and shift out sixty-four 9-bit words, one at a time;
            3. trim any extra words to account for #1 above.
        """
        words = []
        diff = len(raw) % 72
        raw_extended = raw.copy()
        if diff:
            extrazeros = 72-diff
            raw_extended.extend([0]*extrazeros)
        else:
            extrazeros = 0
        if verbose: print('%d extra zeros' % extrazeros)
        for i in range(len(raw_extended)//72):
            bignum = int.from_bytes(raw_extended[i*72:(i+1)*72], byteorder='big')
            if verbose: print(hex(bignum))
            for j in range(64):
                word = (bignum >> (576-9*(j+1)) & 0x1ff)
                words.append(word)
                if verbose: print(hex(word))
        num_full_words = int(len(raw)/9*8)
        return words[:num_full_words]

    async def _check_fifo_errors(self, job_name) -> None:
        # TODO: replace internal signal checks with a register status read
        if self.dut.U_dut.U_la_converter.fifo_empty.value == 0:
            self.harness.inc_error()
            self.dut._log.error('%12s pre-DDR FIFO not empty after reading all samples.' % job_name)
        ## TODO: temporarily commented out because last word is left unread, due to the first word fallthrough nature of the FIFO.
        #if self.dut.U_dut.oadc.U_fifo.postddr_fifo_empty.value == 0:
        #    self.harness.inc_error()
        #    self.dut._log.error('%12s post-DDR FIFO not empty after reading all samples.' % job_name)

    def _check_samples(self, job, data) -> None:
        if job['bits_per_sample'] == 8:
            INC = 2
        elif job['bits_per_sample'] == 9:
            INC = 1
        else:
            raise ValueError('Unsupported')
        MOD = 2**job['bits_per_sample']
        self.first_read_sample = int(data[0])
        self.sample_increment = INC
        for i,byte in enumerate(data[1:]):
            expected = (data[0] + INC*(i+1)) % MOD
            if expected != byte:
                self.inc_error()
                self.dut._log.error("%12s Sample %4d: expected %2x got %2x" % (job['job_name'], i+1, expected, byte))
            else:
                self.dut._log.debug("%12s Good sample %4d: %2x" % (job['job_name'], i+1, byte))



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
        return {"samples": samples, "bits_per_sample": bits_per_sample}

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

    async def _trigger(self, job) -> None:
        await self.trigger_now()
        # TODO: code more trigger options

    async def trigger_now(self) -> None:
        await self.registers.write(0x84, [0])   # trace disarm
        await self.registers.write(0x84, [1])   # trace arm
        await self.harness.wait_flush('trace')# allow for any flushes (triggered by arming) to complete before triggering
        await self.registers.write(0x84, [3])   # capture now


class TraceCapture(GenericCapture):
    def __init__(self, dut, harness, dut_reading_signal):
        super().__init__(dut, harness, dut_reading_signal)
        self.name = 'trace'
        self.sample_increment = 1

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
        await self.harness.registers.write(105, [4])
        await ClockCycles(self.clk, 50)
        await self.harness.wait_flush('trace') # if previous read wasn't complete, wait for post-DDR to get flushed
        # wait for read FIFO to be not empty:
        #self.dut._log.info("waiting for FIFO to not be empty...")
        empty = True
        while empty:
            await ClockCycles(self.clk, 50)
            empty = (await self.harness.registers.read(44, 2))[1] & 32

    async def _read_samples(self, job) -> list:
        samples = self._limit_read(job)
        samples = job['samples']
        bytes_to_read = math.ceil(samples*18/8)
        self.raw_read_data = list(await self.harness.registers.read(3, bytes_to_read))
        data = self.process18bitRawData(self.raw_read_data)
        return data

    @staticmethod
    def process18bitRawData(raw, verbose=False):
        """ Check trace 18-bit ramp pattern: instead of efficient numpy.reshape (as
        done in processHuskyData), we take a simple big hammer...
            1. expand the raw data list to a multiple of 9*64 bits = 72 bytes = 576 bits;
            2. take each 72-byte chunk as a large number and shift out thirty-two 18-bit words, one at a time;
            3. trim any extra words to account for #1 above.
        """
        words = []
        diff = len(raw) % 72
        raw_extended = raw.copy()
        if diff:
            extrazeros = 72-diff
            raw_extended.extend([0]*extrazeros)
        else:
            extrazeros = 0
        if verbose: print('%d extra zeros' % extrazeros)
        for i in range(len(raw_extended)//72):
            bignum = int.from_bytes(raw_extended[i*72:(i+1)*72], byteorder='big')
            if verbose: print(hex(bignum))
            for j in range(32):
                word = (bignum >> (576-18*(j+1)) & 0x3ffff)
                words.append(word)
                if verbose: print(hex(word))
        num_full_words = int(len(raw)/18*8)
        return words[:num_full_words]

    async def _check_fifo_errors(self, job_name) -> None:
        # TODO: replace internal signal checks with a register status read
        if self.dut.U_dut.U_trace_converter.fifo_empty.value == 0:
            self.harness.inc_error()
            self.dut._log.error('%12s pre-DDR FIFO not empty after reading all samples.' % job_name)
        ## TODO: temporarily commented out because last word is left unread, due to the first word fallthrough nature of the FIFO.
        #if self.dut.U_dut.oadc.U_fifo.postddr_fifo_empty.value == 0:
        #    self.harness.inc_error()
        #    self.dut._log.error('%12s post-DDR FIFO not empty after reading all samples.' % job_name)

    def _check_samples(self, job, data) -> None:
        self.first_read_sample = int(data[0])
        for i,byte in enumerate(data[1:]):
            expected = (data[0] + i + 1) % 2**18
            if expected != byte:
                self.inc_error()
                self.dut._log.error("%12s Sample %4d: expected %5x got %5x" % (job['job_name'], i+1, expected, byte))
            else:
                self.dut._log.debug("%12s Good sample %4d: %5x" % (job['job_name'], i+1, byte))



class Harness(object):
    def __init__(self, dut, registers):
        self.dut = dut
        self.registers = registers
        self.tests = []
        self.errors = 0
        self.queue = Queue(maxsize=3)   # maxsize represents the number of concurrent capture sources: ADC, LA, trace
                                        # The purpose of this queue is to enforce concurrency rules, which are a bit tricky:
                                        # 1. Each capture source can be active concurrently.
                                        # 2. No read can occur while another read is occuring or when a capture is occuring.
                                        # Queue entries carry no information other than their presence.
                                        # When a capture source wishes to issue a capture trigger, it first verifies that the
                                        # global read lock is not locked. It then pushes an entry into this queue; it pops the
                                        # queue when the capture is done.
                                        # On the read side, a global read lock is first acquired, and then we must wait until
                                        # this queue is empty before starting the read.
        self.read_lock = Lock()
        # Actual seed is obtained only if RANDOM_SEED is defined on vvp command line (otherwise you get 0)
        # regress.py always specifies the seed so this is fine.
        self.dut._log.info("seed: %d" % int(os.getenv('RANDOM_SEED', '0')))
        #cocotb.start_soon(Clock(dut.clk_usb, 1, units='ns').start())
        adc_period = random.randint(4, 20)
        self.dut._log.info("ADC clock randomized to %5.1f MHz" % (1/adc_period*1000))
        usb_clock_thread = cocotb.start_soon(Clock(dut.clk_usb, 10, units="ns").start())
        adc_clock_thread = cocotb.start_soon(Clock(dut.PLL_CLK1, adc_period, units="ns").start())
        ui_clock_thread = cocotb.start_soon(Clock(dut.ui_clk, 6, units="ns").start())
        # TODO: initialize all DUT input values
        self.dut.errors.value = 0


    async def initialize_dut(self):
        self.dut.target_io4.value = 0
        await self.reset()
        await self.registers.write(51, [0,0,0,0,0,0xcc,0,1])  # CLOCKGLITCH_SETTINGS: set source to clk_usb (otherwise, X's propagate)
        self.dut.U_dut.reg_clockglitch.U_clockglitch.glitch_go.value = Force(0)
        await ClockCycles(self.dut.clk_usb, 10)
        self.dut.U_dut.reg_clockglitch.U_clockglitch.glitch_go.value = Release()
        await self.registers.write(45, [3]) # NO_CLIP_ERRORS: disable gain errors

    async def reset(self):
        await self.registers.write(28, [1])
        await ClockCycles(self.dut.clk_usb, 10)
        await self.registers.write(28, [0])

    async def ddr_done_writing(self):
        raw = await self.registers.read(105)
        if raw[0] >> 7:
            return True
        else:
            return False

    async def wait_flush(self, source):
        if source == 'ADC':
            bitmask = 16
        elif source == 'LA':
            bitmask = 32
        elif source == 'trace':
            bitmask = 64
        flushing = True
        await ClockCycles(self.dut.clk_usb, 5) # give time for flushing to begin
        while flushing:
            self.dut._log.debug("...waiting for flush to complete...")
            flushing = (await self.registers.read(44, 3))[2] & bitmask

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
        await ClockCycles(self.dut.clk_usb, 10) # to give time for fifo_watch errors to be seen

    #def init_tests(self):
    #    """ call after all tests have been defined, to resolve inter-dependencies
    #    """
    #    TODO?

    def start_tests(self):
        """ Wait for all tests which were registered via register_test() to finish.
        """
        for test in self.tests:
            test.start()

    def inc_error(self):
        self.errors += 1
        self.dut.errors.value = self.errors

    async def register_rw_thread(self, address, size):
        while True:
            wdata = random.randint(1,2**(size*8)-1)
            #self.dut._log.info("Writing to %d at time %s" % (address, cocotb.utils.get_sim_time('ns')))
            await self.registers.write(address, self.registers.to_bytes(wdata, size))
            await ClockCycles(self.dut.clk_usb, random.randint(0, 50))
            #self.dut._log.info("Reading from %d at time %s" % (address, cocotb.utils.get_sim_time('ns')))
            rdata = self.registers.from_bytes(await self.registers.read(address, size))
            assert rdata == wdata, "Wrote %x but read %x" % (wdata, rdata)

    @staticmethod
    def hexstring(string, max_chars=24):
        """ Convenience function to put a string onto the simulation waveform."""
        data = 0
        for i,j in enumerate(string[:max_chars]):
            data += (ord(j) << ((max_chars-1-i)*8))
        return data


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


@cocotb.test(timeout_time=600, timeout_unit="us")
async def capture(dut):
    """Concurrent captures of ADC and LA."""
    registers = Registers(dut)
    harness = Harness(dut, registers)

    num_captures = int(os.getenv('NUM_CAPTURES', '3'))
    min_size = int(os.getenv('MIN_SIZE', '30'))
    max_size = int(os.getenv('MAX_SIZE', '100'))

    await harness.initialize_dut()

    if int(os.getenv('LA_CAPTURE')):
        latest = LATest(dut, harness, registers, dut.la_job, dut.la_reading)
        latest.num_captures = num_captures
        latest.capture_min = min_size
        latest.capture_max = max_size
        if int(os.getenv('NO_DOWNSTREAM_TRIGGERS', 0)):
            latest.allow_downstream_triggers = False
        harness.register_test(latest)

    if int(os.getenv('ADC_CAPTURE')):
        adctest = ADCTest(dut, harness, registers, dut.adc_job, dut.adc_reading)
        adctest.num_captures = num_captures
        adctest.capture_min = min_size
        adctest.capture_max = max_size
        if int(os.getenv('NO_DOWNSTREAM_TRIGGERS', 0)):
            adctest.allow_downstream_triggers = False
        harness.register_test(adctest)

    if int(os.getenv('TRACE_CAPTURE')):
        tracetest = TraceTest(dut, harness, registers, dut.trace_job, dut.trace_reading)
        tracetest.num_captures = num_captures
        tracetest.capture_min = min_size
        tracetest.capture_max = max_size
        if int(os.getenv('NO_DOWNSTREAM_TRIGGERS', 0)):
            tracetest.allow_downstream_triggers = False
        harness.register_test(tracetest)


    # TODO: find a better mechanism (maybe init_tests?); add trace
    try:
        adctest.downstream_triggers.append(latest)
    except NameError:
        pass

    harness.start_tests()
    #dut._log.debug("ADC downstream enabled: %s" % adctest.allow_downstream_triggers)
    await harness.all_tests_done()
    assert harness.errors == 0


