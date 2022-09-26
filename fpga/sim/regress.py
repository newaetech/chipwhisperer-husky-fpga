#!/usr/bin/env python3

import argparse
import subprocess
import random
import re
import time
from tqdm import tqdm

parser = argparse.ArgumentParser()
group = parser.add_mutually_exclusive_group()
group.add_argument("--runs", type=int, help="Number of iterations.", default=1)
group.add_argument("--test", help="Testcase to run")
parser.add_argument("--seed", type=int, help="Seed to use when running a single test with --test.")
parser.add_argument("--tests", help="Run all tests whose name contains TESTS", default='')
parser.add_argument("--list", help="List available tests.", action='store_true')
parser.add_argument("--dump", help="Enable waveform dumping.", action='store_true')
args = parser.parse_args()

# Define testcases:
tests = []
tests.append(dict(name  = 'slow_adc',
             frequency = 5,
             TRIGGER_NOW = [0,1],
             ADC_LOW_RES = [0,1],
             OFFSET_ENABLE = [0,1],
             SHORT_TRIGGER = [0,1],
             description = 'Slow ADC clock.',
             SLOW_ADC = 1))

tests.append(dict(name  = 'fast_adc',
             frequency = 5,
             TRIGGER_NOW = [0,1],
             ADC_LOW_RES = [0,1],
             OFFSET_ENABLE = [0,1],
             SHORT_TRIGGER = [0,1],
             description = 'Fast ADC clock.',
             FAST_ADC = 1))

tests.append(dict(name  = 'nom_adc',
             frequency = 5,
             TRIGGER_NOW = [0,1],
             ADC_LOW_RES = [0,1],
             OFFSET_ENABLE = [0,1],
             SHORT_TRIGGER = [0,1],
             TIMEOUT_CYCLES=25000,
             description = 'Nominal ADC clock (almost same as USB clock).'))

tests.append(dict(name  = 'presamples',
             frequency = 1,
             FIFO_SAMPLES = [601,1000],
             PRESAMPLES = [8, 600],
             READ_DELAY = [100, 500],
             TRIGGER_DELAY = [2500, 4000],
             TRIGGER_NOW = [0,1],
             OFFSET_ENABLE = [0,1],
             SHORT_TRIGGER = [0,1],
             description = 'Randomized pre-trigger samples.'))

tests.append(dict(name  = 'nopresamples_pro',
             frequency = 1,
             PRESAMPLES = 0,
             #FIFO_SAMPLES = [500,1000],
             #FIFO_SAMPLES = [16,47],
             FIFO_SAMPLES = [16,200],
             TRIGGER_DELAY = [1500, 3000],
             READ_DELAY = [100, 500],
             TRIGGER_NOW = [0,1],
             OFFSET_ENABLE = [0,1],
             SHORT_TRIGGER = [0,1],
             description = 'No pre-trigger samples.'))

tests.append(dict(name  = 'ddrmax_pro',
             frequency = 1,
             PRESAMPLES = 0,
             FIFO_SAMPLES = [1350,1365],
             TRIGGER_DELAY = [1500, 3000],
             READ_DELAY = [100, 500],
             TRIGGER_NOW = [0,1],
             OFFSET_ENABLE = [0,1],
             SHORT_TRIGGER = [0,1],
             DDRSIZE = "TINYDDR",
             description = 'Use TINYDDR to reach maximum DDR capacity.'))

tests.append(dict(name  = 'noddrmax_pro',
             frequency = 6,
             PRESAMPLES = 0,
             FIFO_SAMPLES = [6468,6484],
             TRIGGER_DELAY = [1500, 3000],
             READ_DELAY = [100, 500],
             TRIGGER_NOW = [0,1],
             OFFSET_ENABLE = [0,1],
             SHORT_TRIGGER = [0,1],
             FIFOSIZE = "TINYFIFO",
             BYPASS_DDR = 1,
             TIMEOUT_CYCLES=200000,
             description = 'Use TINYFIFO to reach maximum FIFO capacity.'))

tests.append(dict(name  = 'noddr_pro',
             frequency = 1,
             PRESAMPLES = 0,
             FIFO_SAMPLES = [16,200],
             TRIGGER_DELAY = [1500, 3000],
             READ_DELAY = [100, 500],
             TRIGGER_NOW = [0,1],
             OFFSET_ENABLE = [0,1],
             SHORT_TRIGGER = [0,1],
             FIFOSIZE = "TINYFIFO",
             BYPASS_DDR = 1,
             description = 'Use TINYFIFO to reach maximum FIFO capacity.'))

tests.append(dict(name  = 'ddr_rwtest_pro',
             frequency = 20,
             DDR_TEST = 1,
             DDR_TEST_LOOPS = [1,3],
             TIMEOUT_CYCLES=200000,
             description = 'Run the built-in DDR R/W test.'))


tests.append(dict(name  = 'quick_stream',
             frequency = 1,
             STREAM = 1,
             PRESAMPLES = 0,
             FIFO_SAMPLES = 2000,
             TRIGGER_DELAY = [1500, 1600],
             READ_DELAY = [100, 500],
             ADC_LOW_RES = [0, 1],
             OFFSET_ENABLE = [0,1],
             SHORT_TRIGGER = [0,1],
             TIMEOUT_CYCLES = 100000,
             description = 'Emulate streaming mode, few samples.'))

tests.append(dict(name  = 'medium_stream',
             frequency = 5,
             STREAM = 1,
             STREAM_SEGMENT_THRESHOLD = [1024, 8192],
             PRESAMPLES = 0,
             FIFO_SAMPLES = 40000,
             TRIGGER_DELAY = [1500, 1600],
             READ_DELAY = [100, 500],
             ADC_LOW_RES = [0, 1],
             OFFSET_ENABLE = [0,1],
             SHORT_TRIGGER = [0,1],
             TIMEOUT_CYCLES = 200000,
             description = 'Emulate streaming mode, moderate amount of samples.'))

tests.append(dict(name  = 'full_stream',
             frequency = 5,
             STREAM = 1,
             STREAM_SEGMENT_THRESHOLD = 128,
             FIFOSIZE = "TINYFIFO",
             PRESAMPLES = 0,
             FIFO_SAMPLES = 15000,
             TRIGGER_DELAY = [1500, 1600],
             READ_DELAY = [100, 500],
             ADC_LOW_RES = [0, 1],
             SLOW_ADC = 1, # TODO-temporary, to prevent fast FIFO overflow
             OFFSET_ENABLE = [0,1],
             SHORT_TRIGGER = [0,1],
             TIMEOUT_CYCLES = 100000,
             description = 'Emulate streaming mode, reading past the internal storage capacity, using tiny FIFOs to manage the run time.'))


tests.append(dict(name  = 'both_fifos',
             frequency = 3,
             FIFOSIZE = "TINYFIFO",
             description = 'Read beyond what the slow FIFO can hold, to verify proper transitioning, using tiny FIFOs to manage the run time.',
             ADC_LOW_RES = [0,1],
             READ_DELAY = [100, 3000],
             TRIGGER_DELAY = [1500, 3000],
             TRIGGER_NOW = [0,1],
             OFFSET_ENABLE = [0,1],
             SHORT_TRIGGER = [0,1],
             TIMEOUT_CYCLES = 500000,
             FIFO_SAMPLES = 4096))

tests.append(dict(name  = 'presamp_error',
             frequency = 10,
             ERRORS_OK = 1,
             PRESAMP_ERROR = 1,
             PRESAMPLES = 100,
             FIFO_SAMPLES = 200,
             READ_DELAY = [100, 500],
             SEGMENT_CYCLES = 250,
             SEGMENT_CYCLE_COUNTER_EN = 1,
             NUM_SEGMENTS = 2,
             TRIGGER_DELAY = [2500, 4000],
             TRIGGER_NOW = 0,
             SLOW_ADC = 1,
             OFFSET_ENABLE = [0,1],
             SHORT_TRIGGER = [0,1],
             description = 'Too many presamples before trigger.'))


tests.append(dict(name  = 'segments_counter',
             frequency = 5,
             #frequency = 0,
             PRESAMPLES = 0,
             FIFO_SAMPLES = [50,400],
             READ_DELAY = [100, 500],
             #READ_DELAY = [1000, 2000],
             SEGMENT_CYCLES = [2000, 5000],
             SEGMENT_CYCLE_COUNTER_EN = 1,
             NUM_SEGMENTS = [2,4],
             TRIGGER_DELAY = [2500, 4000],
             TRIGGER_NOW = 0,
             OFFSET_ENABLE = [0,1],
             SHORT_TRIGGER = [0,1],
             TIMEOUT_CYCLES = 100000,
             description = 'Segmented capture, by cycle counter.'))

# rule: segment_cycles >= fifo_samples + 10
tests.append(dict(name  = 'segments_quick_nopresamp',
             frequency = 1,
             PRESAMPLES = 0,
             FIFO_SAMPLES = [25,30],
             READ_DELAY = [100, 500],
             SEGMENT_CYCLES = [40,45],
             SEGMENT_CYCLE_COUNTER_EN = [0,1],
             NUM_SEGMENTS = [5,10],
             TRIGGER_DELAY = [2500, 4000],
             TRIGGER_NOW = 0,
             OFFSET_ENABLE = 0,
             SHORT_TRIGGER = [0,1],
             description = 'Segmented capture, very short segments, without presamples.'))

# rule: segment_cycles >= fifo_samples + presamples AND segment_cycles >= fifo_samples + 10
tests.append(dict(name  = 'segments_quick_presample',
             frequency = 1,
             PRESAMPLES = [8,20],
             FIFO_SAMPLES = [25,30],
             READ_DELAY = [100, 500],
             SEGMENT_CYCLES = [51,60],
             SEGMENT_CYCLE_COUNTER_EN = [0,1],
             NUM_SEGMENTS = [5,10],
             TRIGGER_DELAY = [2500, 4000],
             TRIGGER_NOW = 0,
             OFFSET_ENABLE = 0,
             SHORT_TRIGGER = [0,1],
             description = 'Segmented capture, very short segments, with presamples.'))


tests.append(dict(name  = 'segments_trigger',
             frequency = 3,
             #frequency = 0,
             PRESAMPLES = 0,
             FIFO_SAMPLES = [50,400],
             READ_DELAY = [100, 500],
             SEGMENT_CYCLES = [2000, 5000],
             SEGMENT_CYCLE_COUNTER_EN = 0,
             NUM_SEGMENTS = [2,4],
             TRIGGER_DELAY = [2500, 4000],
             TRIGGER_NOW = 0,
             OFFSET_ENABLE = [0,1],
             SHORT_TRIGGER = [0,1],
             TIMEOUT_CYCLES = 100000,
             description = 'Segmented capture, by external trigger.'))

tests.append(dict(name  = 'segments_presamples',
             frequency = 3,
             #frequency = 0,
             FIFO_SAMPLES = [50,500],
             PRESAMPLES = [8,49],
             READ_DELAY = [100, 500],
             SEGMENT_CYCLES = [2000, 5000],
             SEGMENT_CYCLE_COUNTER_EN = [0, 1],
             NUM_SEGMENTS = [2,4],
             TRIGGER_DELAY = [2500, 4000],
             TRIGGER_NOW = 0,
             OFFSET_ENABLE = [0,1],
             SHORT_TRIGGER = [0,1],
             TIMEOUT_CYCLES = 100000,
             description = 'Segmented capture, by external trigger.'))

tests.append(dict(name  = 'downsample',
             frequency = 2,
             FIFO_SAMPLES = [30,500],
             DOWNSAMPLE = [1, 50],
             OFFSET_ENABLE = [0,1],
             SHORT_TRIGGER = [0,1],
             TIMEOUT_CYCLES = 1000000,
             description = 'Downsample.'))

tests.append(dict(name  = 'sad',
             frequency = 2,
             BITS_PER_SAMPLE = 8,
             REF_SAMPLES = 32, # maximum supported by target (could do more by upsizing internal registers)
             THRESHOLD = [10,50], # keep threshold low to avoid unintentional triggers - testbench isn't smart enough
             TRIGGERS = 10,
             FLUSH = [0,1],
             LINEAR_RAMP = 0,
             TIMEOUT_CYCLES = 2000,
             TOP = 'sad_tb.v',
             description = 'SAD block-level test.'))

tests.append(dict(name  = 'edge',
             frequency = 2,
             EDGES = [1, 32],
             TIMEOUT_CYCLES = 10000,
             TOP = 'edge_tb.v',
             description = 'edge trigger block-level test.'))


tests.append(dict(name  = 'glitches_short',
             frequency = 3,
             FIFO_SAMPLES = 30,
             SHORT_TRIGGER = [0,1],
             NUM_GLITCHES = [1, 32],
             MAX_GLITCH_REPEATS = 10,
             MAX_GLITCH_OFFSET = 11,
             description = 'Test programmable multiple glitches, quick and short.'))

tests.append(dict(name  = 'glitches_long',
             frequency = 6,
             FIFO_SAMPLES = 30,
             SHORT_TRIGGER = [0,1],
             NUM_GLITCHES = [4, 8],
             MAX_GLITCH_REPEATS = 1000,
             MAX_GLITCH_OFFSET = 1010,
             description = 'Test programmable multiple glitches, slow and long.'))

tests.append(dict(name  = 'glitches_very_long_and_slow',
             #frequency = 10,
             frequency = 0, # this is just too slow to run!
             FIFO_SAMPLES = 30,
             SHORT_TRIGGER = [0,1],
             NUM_GLITCHES = 2,
             MAX_GLITCH_REPEATS = 10,
             MAX_GLITCH_OFFSET = 200000,
             TIMEOUT_CYCLES = 1000000,
             description = 'Test programmable multiple glitches beyond 2^16. Very slow!'))

tests.append(dict(name  = 'glitches_lots',
             frequency = 8,
             FIFO_SAMPLES = 30,
             SHORT_TRIGGER = [0,1],
             NUM_GLITCHES = 32,
             MAX_GLITCH_REPEATS = 100,
             MAX_GLITCH_OFFSET = 110,
             description = 'Test programmable multiple glitches, lots of them.'))

tests.append(dict(name  = 'glitches_single',
             frequency = 10,
             FIFO_SAMPLES = 30,
             SHORT_TRIGGER = [0,1],
             NUM_GLITCHES = 1,
             MAX_GLITCH_REPEATS = 2000,
             MAX_GLITCH_OFFSET = 2010,
             description = 'Test single glitch.'))


def print_tests():
    print("Available tests:")
    for test in tests:
       print("%s: %s" % (test['name'], test['description']))
    quit()

def check_pass_fail(logfile):
    log = open(logfile, 'r')
    passed = None
    warnings = 0
    errors = 0
    for line in log:
       pass_matches = pass_regex.search(line)
       fail_matches = fail_regex.search(line)
       if pass_matches:
          passed = 1
          warnings = int(pass_matches.group(1))
          break
       elif fail_matches:
          passed = 0
          errors = int(fail_matches.group(1))
          break
    log.close()
    if passed is None:
        print("*** parsing error on %s ***" % logfile)
    return passed, warnings, errors


if (args.list):
    print_tests()
    quit()

# if running a single testcase:
if (args.test):
   found = False
   for test in tests:
      if test['name'] == args.test:
         found = True
         tests = [test]
         break
   if not found:
      print("Error: test %s undefined." % args.test)
      print_tests()


pass_regex = re.compile(r'^Simulation passed \((\d+) warnings')
fail_regex = re.compile(r'^SIMULATION FAILED \((\d+) errors')
seed_regex = re.compile(r'^Running with pSEED=(\d+)$')
test_regex = re.compile(args.tests)

# Check once that compile passes:
outfile = open('regress.out', 'w')
for compile_target in ['compile', 'sad_nofifo', 'compile_edge']:
    makeargs = ['make', compile_target]
    result = subprocess.run(makeargs, stdout=outfile, stderr=outfile)
    if result.returncode:
       print ("Compilation for target %s failed (return code: %d), check regress.out." % (compile_target, result.returncode))
       quit()

# Run tests:
start_time = int(time.time())
processes = []

print("Dispatching jobs... ", end='')
for test in tests:
   if args.tests:
      if test_regex.search(test['name']) == None:
          continue

   for i in range(args.runs):

      # set the random seed first, so that both Python and Verilog randomizations are reproducible:
      if (args.seed):
         seed = args.seed
      else:
         seed = random.randint(0, 2**31-1)
      random.seed(seed)

      run_test = True
      # build make command:
      makeargs = ['make', 'all', 'VERBOSE=1']
      makeargs.append("SEED=%d" % seed)
      if args.dump:
         makeargs.append('DUMP=1')
      for key in test.keys():
         if key == 'name':
            logfile = "results/%s%d.log" % (test[key], i) 
            exefile = "results/%s%d.vvp" % (test[key], i) 
            makeargs.append("LOGFILE=%s" % logfile)
            makeargs.append("EXEFILE=%s" % exefile)
         elif key == 'description':
            pass
         elif key == 'frequency':
            if test[key] == 0:
               run_test = False
            elif i % test[key]:
               run_test = False
         elif key == 'TOP' and test[key] == 'sad_tb.v':
             makeargs[1] = 'all_sad'
         elif key == 'TOP' and test[key] == 'edge_tb.v':
             makeargs[1] = 'all_edge'
         else:
            if type(test[key]) == list:
               value = random.randint(test[key][0], test[key][1])
            else:
               value = test[key]
            makeargs.append("%s=%s" % (key, value))

      # run:
      if run_test:
         #print("Running: %s" % makeargs)
         p = subprocess.Popen(makeargs, stdout=outfile, stderr=outfile)
         processes.append((p,logfile,seed))

num_processes = len(processes)
print("done. %d tests running." % num_processes)

warns = []
fails = []

pbar       = tqdm(total=len(processes), desc='Tests finished')
pbarpassed = tqdm(total=len(processes), desc='Tests passing ')

oldfinished = 0
finished = 0
oldpass_count = 0
fail_count = 0
pass_count = 0
while len(processes):
    for p,l,s in processes:
        if not p.poll() is None:
            finished += 1
            passed, warnings, errors = check_pass_fail(l)
            pass_count += passed
            if warnings:
                warns.append("%s: %0d warnings" % (l, warnings))
            if errors:
                fail_count += 1
                fails.append("%s: %d errors (seed=%d)" % (l, errors, s))
            processes.remove((p,l,s))

    pbar.update(finished - oldfinished)
    pbarpassed.update(pass_count - oldpass_count)
    oldfinished = finished
    oldpass_count = pass_count
    time.sleep(1)
pbar.close()
pbarpassed.close()

# just to be sure:
#exit_codes = [p.wait() for p,l,s in processes]

# sanity check:
assert num_processes == pass_count + fail_count, "pass=%d, fail=%d" % (pass_count, fail_count)


# Summarize results:
print('\n*** RESULTS SUMMARY ***')
print('%d tests passing, %d tests failing.' % (pass_count, fail_count))
print('Elapsed time: %d seconds' % (int(time.time() - start_time)))
if warns:
    for w in warns:
        print(w)
if fails:
    for f in fails:
        print(f)


