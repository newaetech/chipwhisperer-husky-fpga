#!/usr/bin/env python3

import argparse
import subprocess
import random
import re
import time

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
             description = 'Slow ADC clock.',
             SLOW_ADC = 1))

tests.append(dict(name  = 'fast_adc',
             frequency = 5,
             TRIGGER_NOW = [0,1],
             description = 'Fast ADC clock.',
             FAST_ADC = 1))

tests.append(dict(name  = 'nom_adc',
             frequency = 5,
             TRIGGER_NOW = [0,1],
             description = 'Nominal ADC clock (almost same as USB clock).'))

tests.append(dict(name  = 'presamples',
             frequency = 1,
             PRESAMPLES = [10, 500],
             READ_DELAY = [0, 500],
             TRIGGER_DELAY = [2500, 4000],
             TRIGGER_NOW = [0,1],
             description = 'Randomized pre-trigger samples.'))

tests.append(dict(name  = 'nopresamples',
             frequency = 2,
             PRESAMPLES = 0,
             TRIGGER_DELAY = [1500, 3000],
             READ_DELAY = [0, 500],
             TRIGGER_NOW = [0,1],
             description = 'No pre-trigger samples.'))

tests.append(dict(name  = 'both_fifos',
             frequency = 2,
             description = 'Read beyond what the slow FIFO can hold, to verify proper transitioning.',
             ADC_LOW_RES = [0,1],
             READ_DELAY = [0, 3000],
             TRIGGER_DELAY = [1500, 3000],
             TRIGGER_NOW = [0,1],
             TIMEOUT_CYCLES = 500000,
             FIFO_SAMPLES = 2043)) # multiple of 9 for now

tests.append(dict(name  = 'segments_counter',
             frequency = 1,
             PRESAMPLES = 0,
             READ_DELAY = [0, 500],
             SEGMENT_CYCLES = [2000, 3000],
             SEGMENT_CYCLE_COUNTER_EN = 1,
             NUM_SEGMENTS = 1,
             TRIGGER_DELAY = [2500, 4000],
             TRIGGER_NOW = 0,
             description = 'Segmented capture, by cycle counter.'))

tests.append(dict(name  = 'segments_trigger',
             frequency = 1,
             PRESAMPLES = 0,  # TODO: allow presamples
             READ_DELAY = [0, 500],
             SEGMENT_CYCLES = [2000, 3000],
             SEGMENT_CYCLE_COUNTER_EN = 0,
             NUM_SEGMENTS = 1,
             TRIGGER_DELAY = [2500, 4000],
             TRIGGER_NOW = 0,
             description = 'Segmented capture, by external trigger.'))



def print_tests():
    print("Available tests:")
    for test in tests:
       print("%s: %s" % (test['name'], test['description']))
    quit()

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

passed = 0
failed = 0

# Check once that compile passes:
outfile = open('regress.out', 'w')
makeargs = ['make', 'compile']
result = subprocess.run(makeargs, stdout=outfile, stderr=outfile)
if result.returncode:
   print ("Compilation failed (return code: %d), check regress.out." % result.returncode)
   quit()

# Run tests:
start_time = int(time.time())


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
      makeargs.append("SEED=%d" % seed)

      run_test = True
      # build make command:
      makeargs = ['make', 'all', 'VERBOSE=0']
      if args.dump:
         makeargs.append('DUMP=1')
      for key in test.keys():
         if key == 'name':
            logfile = "results/%s%d.log" % (test[key], i) 
            makeargs.append("LOGFILE=%s" % logfile)
         elif key == 'description':
            pass
         elif key == 'frequency':
            if test[key] == 0:
               run_test = False
            elif i % test[key]:
               run_test = False
         else:
            if type(test[key]) == list:
               value = random.randint(test[key][0], test[key][1])
            else:
               value = test[key]
            makeargs.append("%s=%s" % (key, value))

      # run:
      if run_test:
         print("Running %s... " % logfile, end='', flush=True)
         subprocess.run(makeargs, stdout=outfile, stderr=outfile)

         # check pass/fail:
         log = open(logfile, 'r')
         for line in log:
            pass_matches = pass_regex.search(line)
            fail_matches = fail_regex.search(line)
            if pass_matches:
               passed += 1
               warnings = int(pass_matches.group(1))
               if warnings:
                  print("pass (%0d warnings)" % warnings)
               else:
                  print("pass")
               break
            elif fail_matches:
               failed += 1
               print("FAILED! %d errors, seed = %d" % (int(fail_matches.group(1)), seed))
               break


# Summarize results:
print('\n*** RESULTS SUMMARY ***')
print('%d tests passing, %d tests failing.' % (passed, failed))
print('Elapsed time: %d seconds' % (int(time.time() - start_time)))



