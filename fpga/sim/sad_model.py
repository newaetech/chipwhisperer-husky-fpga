from chipwhisperer.common.utils import util

# NEXT: add a property to turn on "halfsies" or not (eSAD or regular-SAD);
# have eSAD object instantiate both types of counters... almost done!

# ALSO: offer a way to visualize which samples were NOT covered (due to eSAD)

class Counter(object):
    def __init__(self, idx, ref, refen, half_threshold, threshold, startup_latency, emode=True, verbose=False):
        self.verbose = verbose
        self.emode = emode # True: eSAD; False: regular SAD
        self.idx = idx
        self.ref = ref
        self.refen = refen
        self.half_threshold = half_threshold
        self.threshold = threshold
        self.startup_latency = startup_latency
        self.reflen = len(ref)
        self.started = False
        self.valid = False
        self.starting_sample = None
        self.current_idx = None
        self.ready2trigger = False
        self.armed_and_ready = False
        self.extended_mode = 0
        self.SAD = 0
        self.SADS = []

    def _dict_repr(self):
        rtn = {}
        rtn['idx'] = self.idx
        rtn['emode'] = self.emode
        rtn['reflen'] = self.reflen
        rtn['starting_sample'] = self.starting_sample
        rtn['current_idx'] = self.current_idx
        rtn['started'] = self.started
        rtn['valid'] = self.valid
        rtn['SAD'] = self.SAD
        return rtn

    def reset(self):
        self.started = False
        self.valid = False
        self.starting_sample = None
        self.current_idx = -1
        self.ready2trigger = False
        self.SAD = 0

    def activate(self, time=-1):
        # if we were already active, don't touch anything!
        if not self.started:
            if self.verbose: print("%4d: activating counter %d" % (time, self.idx))
            self.started = True
            self.SAD = 0
            self.current_idx = -self.startup_latency
            self.ready2trigger = False

    @property
    def running(self):
        return self.current_idx >= 0


    def update(self, sample, time, armed_and_ready):
        # returns matched, covered:
        # - matched: True on a SAD counter match
        # - covered: True is sample is covered by a counter *as the first sample of a potential match pattern*
        match = False
        covered = True
        if not armed_and_ready:
            self.reset()
            return (match, covered)

        if not self.started:
            return (match, covered)

        if not self.running:
            self.current_idx += 1
            return (match, covered)

        #self.SAD += np.abs(sample - self.ref[self.current_idx])
        # samples and references likely come in as np.uint8's so need to avoid inadvertent overflow!
        if self.refen[self.current_idx]:
            if sample > self.ref[self.current_idx]:
                self.SAD += sample - self.ref[self.current_idx]
            else:
                self.SAD += self.ref[self.current_idx] - sample

        self.SADS.append(self.SAD)

        self.current_idx += 1
        # Note: DUT decides to extend to full pattern a few cycles before the halfway point:
        if (self.current_idx == self.reflen//2 - 4) and self.emode:
            if self.SAD < self.half_threshold:
                covered = False
                self.extended_mode = 1
                if self.verbose: print("%4d: counter %d reached halfway point and is still alive" % (time, self.idx))
            else:
                self.extended_mode = 0
                if self.verbose: print("%4d: counter %d stopping halfway" % (time, self.idx))

        elif self.current_idx == self.reflen//2 and self.emode and not self.extended_mode:
                self.current_idx = 0
                self.SAD = 0

        elif self.current_idx == self.reflen:
            self.ready2trigger = True
            self.current_idx = 0
            if self.verbose: print("%4d: counter %d done" % (time, self.idx))
            if self.SAD <= self.threshold:
                if self.verbose: print("%4d: counter %d MATCHED at time %6d with score: %d ===============================" % (time, self.idx, time, self.SAD))
                match = True
            self.SAD = 0

        return (match, covered)


    def __repr__(self):
        return util.dict_to_str(self._dict_repr())

    def __str__(self):
        return self.__repr__()



class SAD(object):
    def __init__(self, ref, refen, half_threshold, threshold, startup_latency, multiple_triggers, emode=False, verbose=False):
        self.emode = emode # True: eSAD; False: regular SAD
        self.ref = ref
        self.refen = refen
        self.startup_latency = startup_latency
        self.multiple_triggers = multiple_triggers
        self.half_threshold = half_threshold
        self.threshold = threshold
        self.verbose = verbose
        self.reflen = len(ref)
        if emode:
            if self.reflen % 2:
                raise ValueError('Reference length must be even')
            self.num_counters = self.reflen // 2
        else:
            self.num_counters = self.reflen
        self.counters = []
        self.match_times = [] # for logging match times
        self.match_counters = []
        self.uncovered_samples = []
        self.covered = []
        self.triggered = False
        for i in range(self.num_counters):
            self.counters.append(Counter(i, ref, refen, half_threshold, threshold, startup_latency, emode, verbose))


    def _dict_repr(self):
        rtn = {}
        rtn['emode'] = self.emode
        rtn['half_threshold'] = self.half_threshold
        rtn['threshold'] = self.threshold
        rtn['match_times'] = self.match_times
        rtn['match_counters'] = self.match_counters
        if self.emode: 
            rtn['uncovered_samples'] = self.uncovered_samples
        return rtn


    def reset(self):
        self.match_times = []
        self.match_counters = []
        for c in self.counters:
            c.reset()

    def run(self, wave):
        # to visualize which starting samples aren't covered... easiest way
        # is to first mark all samples as covered, then later (in step())
        # demote those that aren't:
        self.covered = [1]*len(wave)
        for i in range(len(wave)): # go through the full powertrace
            self.step(i, wave[i])

    def activate_next_counter(self):
        for c in self.counters:
            if not c.started:
                c.activate()
                break

    @property
    def trigger_allowed(self):
        if self.triggered and not self.multiple_triggers:
            return False
        else:
            return True

    def step(self, sample, armed_and_ready):
        # on the first run through, counters are started one at a time:
        #if i < self.num_counters:
        #    self.counters[i].activate(i)
        if armed_and_ready and self.trigger_allowed:
            self.activate_next_counter()
        elif not armed_and_ready:
            self.triggered = False
        if not self.trigger_allowed:
            armed_and_ready = False
        # all activated counters are in free-running mode:
        matched = False
        for c in self.counters:
            match, covered = c.update(sample, 0, armed_and_ready)
            if match:
                matched = True
                self.match_times.append(0)
                self.match_counters.append(c.idx)
                self.triggered = True
                print("counter %d matched with score: %d" % (c.idx, c.SAD))
                #if self.verbose: print("counter %d matched at time %6d with score: %d" % (c.idx, i, c.SAD))
            #if not covered:
            #    # TODO: somehow the indices in covered are off by one? not sure why?
            #    self.uncovered_samples.append(i+1)
            #    self.covered[i+1] = 0 
            #    if self.verbose: print("warning: sample %d is not covered" % i+1)
        return matched


    def __repr__(self):
        return util.dict_to_str(self._dict_repr())

    def __str__(self):
        return self.__repr__()


class eSAD(object):
    def __init__(self, ref, refen, half_threshold, threshold, startup_latency, multiple_triggers, verbose=False):
        self.ref = ref
        self.refen = refen
        self.startup_latency = startup_latency
        self.multiple_triggers = multiple_triggers
        self.half_threshold = half_threshold
        self.threshold = threshold
        self.verbose = verbose
        self.reflen = len(ref)
        if self.reflen % 2:
            raise ValueError('Reference length must be even')
        self.num_counters = self.reflen // 2
        self.esad = SAD(ref, refen, half_threshold, startup_latency, multiple_triggers, threshold, True, verbose)
        self.fsad = SAD(ref, refen, half_threshold, startup_latency, multiple_triggers, threshold, False, verbose)

    def _dict_repr(self):
        rtn = {}
        rtn['half_threshold'] = self.half_threshold
        rtn['threshold'] = self.threshold
        rtn['match_times'] = self.match_times
        rtn['match_counters'] = self.match_counters
        rtn['uncovered_samples'] = self.uncovered_samples
        rtn['missed_triggers'] = self.missed_triggers
        return rtn

    @property
    def match_times(self):
        return self.esad.match_times

    @property
    def match_counters(self):
        return self.esad.match_counters

    @property
    def uncovered_samples(self):
        return self.esad.uncovered_samples

    @property
    def missed_triggers(self):
        return sorted(list(set(self.fsad.match_times) - set(self.esad.match_times)))

    def reset(self):
        self.esad.reset()
        self.fsad.reset()

    def run(self, wave):
        self.esad.run(wave)
        self.fsad.run(wave)

    def step(self, sample, armed_and_ready):
        self.fsad.step(sample, armed_and_ready)
        return self.esad.step(sample, armed_and_ready)

    def __repr__(self):
        return util.dict_to_str(self._dict_repr())

    def __str__(self):
        return self.__repr__()



