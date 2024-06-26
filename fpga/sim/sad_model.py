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

from chipwhisperer.common.utils import util


# NOTE: this is a fairly accurate model of the Verilog SAD implementations in Husky.
# It is *almost* cycle accurate. The main difference is that when multiple triggers
# are not enabled, it is in fact possible for some of the Verilog implementations to
# issue more than one trigger, when multiple counters meet the triggering condition
# 1 or 2 cycles apart. This is usually a degenerate case which shouldn't happen with
# a properly tuned SAD module IRL. The main inconvenience is that SAD simulations
# can sometimes fail, and this must be inspected manually.

# TODO: offer a way to visualize which samples were NOT covered (due to eSAD)

class Counter(object):
    def __init__(self, idx, counter_width, ref, refen, triglen, half_threshold, threshold, interval_threshold, startup_latency, emode=False, interval_matching=False, verbose=False):
        self.verbose = verbose
        self.emode = emode # True: eSAD; False: regular SAD
        self.idx = idx
        self.counter_width = counter_width
        self.ref = ref
        self.refen = refen
        self.triglen = triglen
        self.half_threshold = half_threshold
        self.threshold = threshold
        self.interval_threshold = interval_threshold
        self.startup_latency = startup_latency
        self.interval_matching = interval_matching
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
        rtn['triglen'] = self.triglen
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

        incr = 0
        if self.refen[self.current_idx]:
            if self.interval_matching:
                if self.current_idx == 0 or self.SAD < 2**self.counter_width-1: # don't overflow
                    if sample > self.ref[self.current_idx]:
                        if sample > self.ref[self.current_idx] + self.interval_threshold:
                            incr = 1
                    else:
                        if sample < self.ref[self.current_idx] - self.interval_threshold:
                            incr = 1

            else:
                if self.current_idx == 0 or self.SAD < 2**(self.counter_width-1): # don't overflow
                    if sample > self.ref[self.current_idx]:
                        incr = int(sample) - int(self.ref[self.current_idx])
                    else:
                        incr = int(self.ref[self.current_idx]) - int(sample)

        if self.current_idx == 0:
            self.SAD = incr
        else:
            self.SAD += incr
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

        else:
            if self.current_idx == self.triglen and self.ready2trigger:
                if self.verbose: print("%4d: counter %d done, SAD=%d" % (time, self.idx, self.SAD))
                if self.SAD <= self.threshold:
                    if self.verbose: print("%4d: counter %d MATCHED at time %6d with score: %d ===============================" % (time, self.idx, time, self.SAD))
                    match = True
            if self.current_idx == self.reflen:
                self.ready2trigger = True
                self.current_idx = 0

        return (match, covered)


    def __repr__(self):
        return util.dict_to_str(self._dict_repr())

    def __str__(self):
        return self.__repr__()



class SAD(object):
    def __init__(self, counter_width, ref, refen, triglen, half_threshold, threshold, interval_threshold, startup_latency, multiple_triggers, emode=False, interval_matching=False, verbose=False):
        self.emode = emode # True: eSAD; False: regular SAD
        self.ref = ref
        self.refen = refen
        self.triglen = triglen
        self.startup_latency = startup_latency
        self.multiple_triggers = multiple_triggers
        self.half_threshold = half_threshold
        self.threshold = threshold
        self.interval_matching = interval_matching
        self.interval_threshold = interval_threshold
        self.verbose = verbose
        self.reflen = len(ref)
        self.index = 0
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
            self.counters.append(Counter(i, counter_width, ref, refen, self.triglen, half_threshold, threshold, interval_threshold, startup_latency, emode, interval_matching, verbose))


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
        self.index = 0
        for c in self.counters:
            c.reset()

    def run(self, wave):
        # to visualize which starting samples aren't covered... easiest way
        # is to first mark all samples as covered, then later (in step())
        # demote those that aren't:
        self.covered = [1]*len(wave)
        for i in range(len(wave)): # go through the full powertrace
            self.step(wave[i], True)

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
                self.match_times.append(self.index)
                self.match_counters.append(c.idx)
                self.triggered = True
                if self.verbose: print("counter %d matched at time %6d with score: %d" % (self.index, c.idx, c.SAD))
            if not covered:
                # TODO: somehow the indices in covered are off by one? not sure why?
                self.uncovered_samples.append(self.index+1)
                try:
                    self.covered[self.index+1] = 0 
                except:
                    pass
                if self.verbose: print("warning: sample %d is not covered" % (self.index+1))
        self.index += 1
        return matched


    def __repr__(self):
        return util.dict_to_str(self._dict_repr())

    def __str__(self):
        return self.__repr__()


class eSAD_wrapper(object):
    def __init__(self, counter_width, ref, refen, half_threshold, threshold, interval_threshold, startup_latency, multiple_triggers, interval_matching=False, verbose=False):
        self.esad = SAD(counter_width, ref, refen, half_threshold, threshold, interval_threshold, startup_latency, multiple_triggers, True,  interval_matching, verbose)
        self.fsad = SAD(counter_width, ref, refen, half_threshold, threshold, interval_threshold, startup_latency, multiple_triggers, False, interval_matching, verbose)

    def _dict_repr(self):
        rtn = {}
        rtn['half_threshold'] = self.esad.half_threshold
        rtn['threshold'] = self.esad.threshold
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

    def step(self, sample, armed_and_ready=True):
        self.fsad.step(sample, armed_and_ready)
        return self.esad.step(sample, armed_and_ready)

    def __repr__(self):
        return util.dict_to_str(self._dict_repr())

    def __str__(self):
        return self.__repr__()



