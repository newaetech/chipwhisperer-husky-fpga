import cocotb
from cocotb.triggers import RisingEdge, FallingEdge, Edge, ClockCycles, Join, Lock, Event, with_timeout
from cocotb.clock import Clock
from cocotb.queue import Queue
from cocotb.result import SimTimeoutError
import random
import math
import numpy as np

class GenericCapture(object):
    def __init__(self, dut, sampling_clock, harness, dut_reading_signal):
        self.reg_addr = harness.reg_addr
        self.clk_usb = dut.clk_usb
        self.dut = dut
        self.sampling_clock = sampling_clock
        self.harness = harness
        self.dut_reading_signal = dut_reading_signal
        self.jobs = Queue()
        self.results = Queue()
        self._coro = None
        self.job_id = 0
        self.name = None
        self.errors = 0
        self.stream = 0
        self._first_read_sample = None
        self._actual_first_write = None
        self.raw_read_data = []

    def start(self) -> None:
        """Start capture thread"""
        if self._coro is not None:
            raise RuntimeError("Capture already started")
        self._coro = cocotb.start_soon(self._run())
        first_write_thread = cocotb.start_soon(self._catch_first_write())

    def stop(self) -> None:
        """Stop capture thread"""
        if self._coro is None:
            raise RuntimeError("Capture never started")
        self._coro.kill()
        self._coro = None

    async def _initiate_read(self) -> None:
        """ Set up the read and ensure that data is available to be read.
        """
        self.dut._log.error("%12s: _initiate_read() must be implemented in child class." % self.name)

    async def _read_samples(self, job) -> list:
        """ Read all the samples from DUT. Should return actual samples, not
        raw read data (e.g. a list of 12-bit samples, not a list of bytes that
        encode 12-bit samples)
        """
        self.dut._log.error("%12s: _read_samples() must be implemented in child class." % self.name)

    async def _check_fifo_empty(self, job) -> None:
        """ Meant to be called after reading all samples; verifies that FIFO is empty.
        """
        self.dut._log.error("%12s: _check_fifo_empty() must be implemented in child class." % self.name)

    def _check_samples(self, job, data) -> None:
        """ Check <data> for errors. Return the number of errors seen.
        """
        self.dut._log.error("%12s: _check_samples() must be implemented in child class." % self.name)

    def _catch_first_write(self) -> None:
        """ Monitor DUT internals to catch the actual first write.
        """
        self.dut._log.error("%12s: _catch_first_write() must be implemented in child class." % self.name)


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
            job_name = job['name']
            # note: used to have a  self._pre_read_wait(job) here but no longer needed since _wait_capture_done does the equivalent
            # see comments around queue definition in Harness for how this queue and lock mechanism works:
            self.dut._log.info("%12s awaiting freed trigger lock" % job_name)
            while self.harness.trigger_lock.locked:
                await ClockCycles(self.clk_usb, 10)
            if not self.stream:
                await self.harness.read_lock_acquire(job_name)
                self.dut._log.info("%12s awaiting empty queue (count = %d, contents: %s)" % (job_name, self.harness.queue.qsize(), self.harness._queue_contents))
                while not self.harness.queue.empty():
                    await ClockCycles(self.clk_usb, 10)
                self.dut._log.info("%12s empty queue wait done" % job_name)
            self.dut.current_action.value = self.harness.hexstring("%12s initread" % job_name)
            try:
                await with_timeout(self._initiate_read(), 100, 'us')
            except:
                # catch timeout to print something about it
                raise SimTimeoutError('%12s timed out on _initiate_read()' % job_name)
            self.dut_reading_signal.value = 1
            self.dut._log.info("%12s Starting read" % job_name)
            self.dut.current_action.value = self.harness.hexstring("%12s Reading" % job_name)
            data = await self._read_samples(job)
            self.dut._log.info("%12s Done read" % job_name)
            self.harness.read_lock_release()
            self.dut._log.info("%12s read_lock released" % job_name)
            self.dut_reading_signal.value = 0
            await self._check_fifo_empty(job)
            self._check_samples(job, data)
            self.results.put_nowait({"errors": self.errors})
            if self.errors:
                self.find_bad_words(job)
            self.job_id += 1

    def _limit_read(self, job) -> int:
        """ To test that the design functions correctly when the full capture is not read back.
        """
        samples = job['samples']
        if 'segments' in job.keys():
            samples *= job['segments']
        #1. Read full capture 75% of the time:
        if self.stream or random.randint(0,3) < 3:
            return samples
        #2. otherwise randomly reduce the number of samples read to as little as 1:
        else:
            if self.harness.is_pro:
                MIN = 1
            else:
                MIN = 2
            samples = random.randint(MIN, samples-1)
            self.dut._log.info("%12s reducing sample read count to %d" % (job['name'], samples))
            job['limited_reads'] = True
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
    def __init__(self, dut, sampling_clock, harness, dut_reading_signal):
        super().__init__(dut, sampling_clock, harness, dut_reading_signal)
        self.name = 'ADC'
        self.sample_increment = 1

    async def read_adc_data(self, samples, bits_per_sample):
        # do the read:
        if bits_per_sample == 12:
            bytes_to_read = math.ceil(samples*1.5)
        else:
            bytes_to_read = samples
        raw = list(await self.harness.registers.read(self.reg_addr['ADCREAD_ADDR'], bytes_to_read))
        return raw

    async def _initiate_read(self) -> None:
        #self.dut._log.info("issuing initiate read command...")
        # 1. initiate the read:
        if self.harness.is_pro:
            await self.harness.registers.write(self.reg_addr['REG_DDR_START_READ'], [0])
            await self.harness.registers.write(self.reg_addr['REG_DDR_START_READ'], [1])
            await ClockCycles(self.clk_usb, 50)
        await self.harness.wait_flush('ADC') # if previous read wasn't complete, wait for post-DDR to get flushed
        # wait for read FIFO to be not empty:
        #self.dut._log.info("waiting for FIFO to not be empty...")
        empty = True
        while empty:
            await ClockCycles(self.clk_usb, 50)
            empty = (await self.harness.registers.read(self.reg_addr['FIFO_STAT'], 2))[1] & 64

    async def _read_samples(self, job) -> list:
        job_name = job['name']
        samples = self._limit_read(job)
        bits_per_sample = job['bits_per_sample']
        if self.stream:
            stream_segment_n = 0
            stream_segment_size = job['stream_segment_threshold'] # N.B.: does NOT need to be equal, though in practice (and by default) it usually is
            self.raw_read_data = []
            samples_left = samples
            while samples_left:
                wait_printed = False
                while self.dut.USB_SPARE0.value == 0:
                    if not wait_printed:
                        self.dut._log.info('%12s waiting for stream segment to be available...' % job_name)
                        wait_printed = True
                    await ClockCycles(self.clk_usb, 10)
                samples_to_read = min(stream_segment_size, samples_left)
                self.dut._log.info('%12s starting stream segment read %d: reading %d samples' % (job_name, stream_segment_n, samples_to_read))
                stream_segment = await self.read_adc_data(samples_to_read, bits_per_sample)
                self.raw_read_data.extend(stream_segment)
                samples_left -= samples_to_read
                stream_segment_n += 1

        else:
            downsample = job['downsample']
            # if capture is downsampled, we could read it too fast and underflow:
            if downsample > 1:
                await ClockCycles(self.sampling_clock, math.ceil(samples * downsample * bits_per_sample/8))
            #self.dut._log.info("starting the read (%0d samples)" % samples)
            self.raw_read_data = await self.read_adc_data(samples, bits_per_sample)

        data = self.processHuskyData(samples, bytearray(self.raw_read_data), bits_per_sample)
        return data


    async def _check_fifo_empty(self, job) -> None:
        # give a chance for FSM to return to idle (e.g. in case where we don't read all the samples)
        if job['limited_reads']:
            # nothing to check because FIFOs are probably not empty
            return
        job_name = job['name']
        idle = False
        while not idle:
            raw = (await self.harness.registers.read(self.reg_addr['FIFO_STATE'], 1))[0]
            idle = (raw & 0x03) == 0
        # note that we don't check the slow/post-DDR FIFO because last word is left unread since FIFO is first word fallthrough
        empty = (await self.harness.registers.read(self.reg_addr['FIFO_STAT'], 4))[3] & 0x03
        if not empty:
            self.dut._log.error('%12s fast/pre-DDR FIFO not empty after reading all samples.' % job_name)
            self.harness.inc_error()

    @staticmethod
    def processHuskyData(NumberPoints, data, bits_per_sample):
        if bits_per_sample == 12:
            if len(data)%3:
                data.extend([0]*(3-len(data)%3))
            data = np.frombuffer(data, dtype=np.uint8)
            fst_uint8, mid_uint8, lst_uint8 = np.reshape(data, (data.shape[0] // 3, 3)).astype(np.uint16).T
            fst_uint12 = (fst_uint8 << 4) + (mid_uint8 >> 4)
            snd_uint12 = ((mid_uint8 % 16) << 8) + lst_uint8
            data = np.reshape(np.concatenate((fst_uint12[:, None], snd_uint12[:, None]), axis=1), 2 * fst_uint12.shape[0])
        return data[:NumberPoints]


    def _check_samples(self, job, data) -> None:
        bits_per_sample = job['bits_per_sample']
        MOD = 2**bits_per_sample
        samples = len(data)
        current_count = data[0]
        self.first_read_sample = int(current_count)
        expected = (self._actual_first_write - job['presamples']) % MOD
        if int(current_count) != expected:
            self.dut._log.error("%12s First sample: expected %3x got %3x" % (job['name'], expected, current_count))
            self.inc_error()
        first_error = None
        #self.dut._log.info("Checking ramp (%0d samples)" % len(data))
        segment = 0
        for i, byte in enumerate(data[1:]):
            tolerance = 0
            if (i+1) % job['samples'] == 0:
                if job['segment_counter_en']:
                    current_count += job['segment_cycles'] - job['samples']
                else:
                    current_count += job['segment_times'][segment] - job['samples']
                    tolerance = 2 # because of the USB <-> sampling clock conversion
                segment += 1
            if abs(byte - (current_count + job['downsample']) % MOD) > tolerance:
                self.dut._log.error("%12s Sample %4d: expected %3x got %3x" % (job['name'], i+1, (current_count+1)%MOD, byte))
                self.inc_error()
                if not first_error:
                    first_error = i
                current_count = byte
            else:
                self.dut._log.debug("%12s Good sample %4d: %2x" % (job['name'], i+1, byte))
                current_count = byte

    async def _catch_first_write(self) -> None:
        while True:
            await RisingEdge(self.dut.U_dut.oadc.U_fifo.armed_and_ready)
            self.dut._log.info("%12s armed" % self.name)
            await RisingEdge(self.dut.U_dut.oadc.U_fifo.state_triggered)
            await FallingEdge(self.dut.U_dut.oadc.U_fifo.adc_sampleclk)
            self._actual_first_write = int(self.dut.U_dut.oadc.U_fifo.adc_datain.value)
            self.dut._log.info("%12s got first write: %0x" % (self.name, self._actual_first_write))



class LACapture(GenericCapture):
    def __init__(self, dut, sampling_clock, harness, dut_reading_signal):
        super().__init__(dut, sampling_clock, harness, dut_reading_signal)
        self.name = 'LA'
        self.sample_increment = None # filled in by each job

    async def _initiate_read(self) -> None:
        #self.dut._log.info("issuing initiate read command...")
        # 1. initiate the read:
        if self.harness.is_pro:
            await self.harness.registers.write(self.reg_addr['REG_DDR_START_READ'], [0])
            await self.harness.registers.write(self.reg_addr['REG_DDR_START_READ'], [2])
            await ClockCycles(self.clk_usb, 50)
        else:
            await self.harness.registers.write(self.reg_addr['REG_FAST_FIFO_RD_EN'], [1])
        await self.harness.wait_flush('LA') # if previous read wasn't complete, wait for post-DDR to get flushed

        # wait for read FIFO to be not empty:
        #self.dut._log.info("waiting for FIFO to not be empty...")
        empty = True
        while empty:
            await ClockCycles(self.clk_usb, 50)
            if self.harness.is_pro:
                empty = (await self.harness.registers.read(self.reg_addr['FIFO_STAT'], 2))[1] & 64
            else:
                empty = (await self.harness.registers.read(self.reg_addr['REG_SNIFF_FIFO_STAT'], 1))[0] & 0x01

    async def _read_samples(self, job) -> list:
        if not self.harness.is_pro:
            data = await self._read_samples_regular(job)
        else:
            samples = self._limit_read(job)
            bits_per_sample = job['bits_per_sample']
            if bits_per_sample == 8:
                bytes_to_read = math.ceil(samples/2)
            elif bits_per_sample == 9:
                bytes_to_read = math.ceil(samples*9/8)
            else:
                raise ValueError("Unsupported capture width")
            self.dut._log.info('YOYOYO reading %d bytes' % bytes_to_read)
            data = list(await self.harness.registers.read(self.reg_addr['ADCREAD_ADDR'], bytes_to_read))
            self.raw_read_data = data
            if bits_per_sample == 9:
                data = self.process9bitRawData(data)
        return data

    async def _read_samples_regular(self, job) -> list:
        samples = self._limit_read(job)
        bits_per_sample = job['bits_per_sample']
        bytes_to_read = samples*2
        data = list(await self.harness.registers.read(self.reg_addr['REG_SNIFF_FIFO_RD'], bytes_to_read))
        self.raw_read_data = data
        data = self.process9bitRawDataRegular(data)
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

    @staticmethod
    def process9bitRawDataRegular(raw, verbose=False):
        """ 9-bit ramp pattern comes out different on the regular Husky (because it's read directly from the
        shared FIFO). Every four bytes contains two 2-bit counter samples:
        | byte 3  | byte 2 | byte 1 | byte 0
         | 1st counter| 2nd counter |
         |(bits 25:17)| (bits 16:8) |
        """
        words = []
        for i in range(len(raw)//4):
            bignum = int.from_bytes(raw[i*4:(i+1)*4], byteorder='little')
            words.append((bignum >> 17) & 0x1ff)
            words.append((bignum >> 8) & 0x1ff)
        return words

    async def _check_fifo_empty(self, job) -> None:
        # note that we don't check the slow/post-DDR FIFO because last word is left unread since FIFO is first word fallthrough
        job_name = job['name']
        empty = (await self.harness.registers.read(self.reg_addr['FIFO_STAT'], 4))[3] & 0x18
        if not empty:
            self.dut._log.error('%12s shared/pre-DDR FIFO not empty after reading all samples.' % job_name)
            self.harness.inc_error()

    def _check_samples(self, job, data) -> None:
        if job['bits_per_sample'] == 8:
            INC = 2
        elif job['bits_per_sample'] == 9:
            INC = 1
        else:
            raise ValueError('Unsupported')
        INC *= job['downsample']
        MOD = 2**job['bits_per_sample']
        self.first_read_sample = int(data[0])

        if job['bits_per_sample'] == 9:
            expected = (self._actual_first_write & 0x3fe00) >> 9
        else:
            expected =  self._actual_first_write & 0xff
        if int(data[0]) != expected:
            self.dut._log.error("%12s First sample: expected %3x got %3x" % (job['name'], expected, data[0]))
            self.inc_error()

        self.sample_increment = INC
        for i,byte in enumerate(data[1:]):
            expected = (data[0] + INC*(i+1)) % MOD
            if expected != byte:
                self.dut._log.error("%12s Sample %4d: expected %2x got %2x" % (job['name'], i+1, expected, byte))
                self.inc_error()
            else:
                self.dut._log.debug("%12s Good sample %4d: %2x" % (job['name'], i+1, byte))

    async def _catch_first_write(self) -> None:
        while True:
            await RisingEdge(self.dut.U_dut.reg_la.armed)
            self.dut._log.info("%12s armed" % self.name)
            await RisingEdge(self.dut.U_dut.la_fifo_wr)
            await FallingEdge(self.dut.U_dut.reg_la.observer_clk)
            self._actual_first_write = int(self.dut.U_dut.la_wr_data.value)
            self.dut._log.info("%12s got first write: %0x" % (self.name, self._actual_first_write))



class TraceCapture(GenericCapture):
    def __init__(self, dut, sampling_clock, harness, dut_reading_signal):
        super().__init__(dut, sampling_clock, harness, dut_reading_signal)
        self.name = 'trace'
        self.sample_increment = 1

    async def _initiate_read(self) -> None:
        #self.dut._log.info("issuing initiate read command...")
        # 1. initiate the read:
        if self.harness.is_pro:
            await self.harness.registers.write(self.reg_addr['REG_DDR_START_READ'], [0])
            await self.harness.registers.write(self.reg_addr['REG_DDR_START_READ'], [4])
            await ClockCycles(self.clk_usb, 50)
        else:
            await self.harness.registers.write(self.reg_addr['REG_FAST_FIFO_RD_EN'], [1])
        await self.harness.wait_flush('trace') # if previous read wasn't complete, wait for post-DDR to get flushed
        # wait for read FIFO to be not empty:
        #self.dut._log.info("waiting for FIFO to not be empty...")
        empty = True
        while empty:
            await ClockCycles(self.clk_usb, 50)
            if self.harness.is_pro:
                empty = (await self.harness.registers.read(self.reg_addr['FIFO_STAT'], 2))[1] & 64
            else:
                empty = (await self.harness.registers.read(self.reg_addr['REG_SNIFF_FIFO_STAT'], 1))[0] & 0x01

    async def _read_samples(self, job) -> list:
        if not self.harness.is_pro:
            data = await self._read_samples_regular(job)
        else:
            samples = self._limit_read(job)
            bytes_to_read = math.ceil(samples*18/8)
            self.raw_read_data = list(await self.harness.registers.read(self.reg_addr['ADCREAD_ADDR'], bytes_to_read))
            data = self.process18bitRawData(self.raw_read_data)
        return data

    async def _read_samples_regular(self, job) -> list:
        samples = self._limit_read(job)
        bytes_to_read = samples * 4
        self.raw_read_data = list(await self.harness.registers.read(self.reg_addr['REG_SNIFF_FIFO_RD'], bytes_to_read))
        data = self.processRawDataRegular(self.raw_read_data)
        return data

    @staticmethod
    def processRawDataRegular(raw, verbose=False):
        """ Ramp pattern comes out different on the regular Husky (because it's read directly from the
        shared FIFO). Every four bytes contains a single 18-bit counter sample so it's pretty straightfoward
        as long as you drop the right byte and order and index correctly.
        """
        words = []
        for i in range(len(raw)//4):
            bignum = int.from_bytes(raw[i*4+1:(i+1)*4], byteorder='little')
            word = bignum & 0x3ffff
            words.append(word)
        return words


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

    async def _check_fifo_empty(self, job) -> None:
        # note that we don't check the slow/post-DDR FIFO because last word is left unread since FIFO is first word fallthrough
        job_name = job['name']
        empty = (await self.harness.registers.read(self.reg_addr['FIFO_STAT'], 4))[3] & 0x14
        if not empty:
            self.dut._log.error('%12s pre-DDR FIFO not empty after reading all samples.' % job_name)
            self.harness.inc_error()

    def _check_samples(self, job, data) -> None:
        self.first_read_sample = int(data[0])
        expected = self._actual_first_write
        if int(data[0]) != expected:
            self.dut._log.error("%12s First sample: expected %3x got %3x" % (job['name'], expected, data[0]))
            self.inc_error()
        for i,byte in enumerate(data[1:]):
            expected = (data[0] + i + 1) % 2**18
            if expected != byte:
                self.dut._log.error("%12s Sample %4d: expected %5x got %5x" % (job['name'], i+1, expected, byte))
                self.inc_error()
            else:
                self.dut._log.debug("%12s Good sample %4d: %5x" % (job['name'], i+1, byte))

    async def _catch_first_write(self) -> None:
        self._actual_first_write = 0
        while True:
            await RisingEdge(self.dut.U_dut.U_trace_top.arm_fe)
            self.dut._log.info("%12s armed" % self.name)
            await RisingEdge(self.dut.U_dut.trace_fifo_wr)
            await FallingEdge(self.dut.U_dut.U_trace_top.fe_clk)
            self._actual_first_write = int(self.dut.U_dut.trace_wr_data.value)
            self.dut._log.info("%12s got first write: %0x" % (self.name, self._actual_first_write))



class GlitchCapture(GenericCapture):
    def __init__(self, dut, sampling_clock, harness, dut_reading_signal):
        super().__init__(dut, sampling_clock, harness, dut_reading_signal)
        self.name = 'glitch'
        self.glitch_error = self.dut.glitch_error_reg
        self.expect_glitch(0)

    def _start_watch_threads(self):
        glitch_watch_thread = cocotb.start_soon(self.glitch_watch())

    async def _run(self) -> None:
        """ Main run loop. 
        Verifying glitches is sufficiently different from verifying ADC/LA/trace captures that
        it merits a custom _run() routine.
        """
        self.job_id = 0
        while True:
            self.dut_reading_signal.value = 0
            job = await self.jobs.get()
            self.dut_reading_signal.value = 1
            job_name = job['name']
            self.job_name = job_name
            self.dut._log.info("%12s Starting check for job" % job_name)
            self.dut.current_action.value = self.harness.hexstring("%12s verify" % job_name)
            await self.glitch_check(job)
            await ClockCycles(self.clk_usb, 50)
            self.results.put_nowait({"errors": self.errors})
            self.job_id += 1
            self.not_in_a_job()

    async def glitch_watch(self) -> None:
        """ Ensures there are glitches when there are supposed to be.
        """
        self.not_in_a_job()
        while True:
            await Edge(self.glitch_error)
            self.dut._log.error('%12s Unexpected glitch value! (expected %d, got %s)' % (self.job_name, self.dut.expected_glitch.value, self.dut.glitch_out.value))
            self.harness.inc_error()

    async def glitch_check(self, job) -> None:
        """ Ensures there are glitches when there are supposed to be.
        """
        if job['trigger_type'] == 'manual':
            if self.harness.is_pro: # offset difference is from USB write timing differences:
                actual_offset = 0
            else:
                actual_offset = 3
        else:
            actual_offset = job['offset'] + 2
            await FallingEdge(self.sampling_clock) # because incoming trigger to reg_clockglitch.v first gets negedge sampled
        await ClockCycles(self.sampling_clock, 3 + actual_offset)
        await FallingEdge(self.sampling_clock)
        self.expect_glitch(1)
        for i in range(job['repeats']):
            await FallingEdge(self.sampling_clock)
        self.expect_glitch(0)

    def expect_glitch(self, value) -> None:
        self.dut.expected_glitch.value = value

    def not_in_a_job(self) -> None:
        self.job_name = '(glitch: no job)'

    async def _catch_first_write(self) -> None:
        pass

