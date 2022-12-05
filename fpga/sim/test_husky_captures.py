import cocotb
from cocotb.triggers import RisingEdge, ClockCycles, Join, Lock, Event
from cocotb.clock import Clock
from cocotb.queue import Queue
import random
import math
import numpy as np

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
        self._first_read_sample = None
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

    @property
    def first_read_sample(self):
        """
        """
        return self._first_read_sample

    @first_read_sample.setter
    def first_read_sample(self, value):
        if value == self._first_read_sample:
            self.dut._log.warning("%12s first read sample (0x%0x) is the same as the previous read;" \
                                  "Either this is a coincidence, or the capture didn't happen at all." % (self.name, value))
        self._first_read_sample = value


    async def _run(self) -> None:
        """ Main run loop. """
        self.dut_reading_signal.value = 0
        self.job_id = 0
        while True:
            job = await self.jobs.get()
            job_name = job['job_name']
            #await self._pre_read_wait(job) TODO: no longer needed since _wait_capture_done does the equivalent?
            # see comments around queue definition in Harness for how this queue and lock mechanism works:
            self.dut._log.debug("%12s trying to acquire read_lock..." % job_name)
            await self.harness.read_lock.acquire()
            self.dut._log.info("%12s read_lock acquired" % job_name)
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
            self.dut._log.info("%12s read_lock released" % job_name)
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
        num_big_words = math.ceil(len(read_data)*8/(64*width))*2

        #self.dut._log.info("num_big_words=%d, read_data=%s" % (num_big_words, read_data))
        self.dut._log.info("first=%03x, width=%d, increment=%d, mod=%d" % (first_sample, width, increment, mod))
        if len(read_data) % 8:
            read_data.extend([0]*(8-len(read_data)%8))
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
                if j%2:
                    end = ' '
                else:
                    end = '_'
                message += "%08x%s" % (word32bits, end)
                expected_words.append(word32bits)
        message += "\nGot:      "
        num_words = math.floor(len(read_data)/4)
        for i in range(num_words):
            big_word = 0
            for j in range(4):
                big_word = read_data[i*4+j] + (big_word << 8)
            if i%2:
                end = ' '
            else:
                end = '_'
            message += "%08x%s" % (big_word, end)
            actual_words.append(big_word)
        self.dut._log.info(message)
        for i in range(len(actual_words)//2):
            if (actual_words[i*2] != expected_words[i*2]) or (actual_words[i*2+1] != expected_words[i*2+1]):
                self.dut._log.error("64-bit word %3d: expected %08x_%08x" % (i, expected_words[i*2], expected_words[i*2+1]))
                self.dut._log.error("                 got      %08x_%08x" % (actual_words[i*2], actual_words[i*2+1]))



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
