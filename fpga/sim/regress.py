#!/usr/bin/env python3

import argparse
import subprocess
import random
import re
import time
import os
from tqdm import tqdm

parser = argparse.ArgumentParser()
group = parser.add_mutually_exclusive_group()
group.add_argument("--runs", type=int, help="Number of iterations.", default=1)
group.add_argument("--test", help="Testcase to run")
parser.add_argument("--variant", help="Husky variant (regular/plus/pro)", default='regular')
parser.add_argument("--seed", type=int, help="Seed to use when running a single test with --test.")
parser.add_argument("--timeout", type=int, help="Simulation timeout.")
parser.add_argument("--tests", help="Run all tests whose name contains TESTS", default='')
parser.add_argument("--exclude", help="Exclude tests whose name contains TESTS", default='')
parser.add_argument("--list", help="List available tests.", action='store_true')
parser.add_argument("--dump", help="Enable waveform dumping.", action='store_true')
parser.add_argument("--proc", type=int, help="Maximum number of parallel jobs to dispatch.")
parser.add_argument("--cocodebug", help="Cocotb debug level", default='INFO')
parser.add_argument("--fast_fifo_sim", help="Force FIFOs to use flopped version, for considerably faster run times.", action='store_true')
parser.add_argument("--compile_once", help="Compile only once for faster regressions. CAUTION: prevents changes to test parameters \
                                            which affect Verilog instantiations (such as TINYFIFO), which means \
                                            some testcases won't run as intended.  Test parameters which affect \
                                            only the Python testbench are not impacted by this.", action='store_true')
args = parser.parse_args()

# Optionally compile only once, for faster regressions (which prevents changing defines such as TINYFIFO from their defaults):

# Define testcases:
tests = []
tests.append(dict(name  = 'adc_capture',
             testcase = 'capture',
             frequency = 4,
             LA_CAPTURE = 0,
             TRACE_CAPTURE = 0,
             GLITCH_CAPTURE = 0,
             MAX_SIZE = 300,
             MAX_PRESAMPLES = 300,
             MAX_OFFSET = 1000,
             MAX_DOWNSAMPLE = 4,
             description = 'ADC-only capture.'))

# downsamples gets its own testcase because it has restrictions on presamples and segments:
tests.append(dict(name  = 'adc_downsample',
             testcase = 'capture',
             frequency = 6,
             LA_CAPTURE = 0,
             TRACE_CAPTURE = 0,
             GLITCH_CAPTURE = 0,
             MAX_SIZE = 300,
             MAX_PRESAMPLES = 0,
             MAX_SEGMENTS = 1,
             MAX_OFFSET = 1000,
             MAX_DOWNSAMPLE = 10,
             description = 'ADC-only capture with downsamples.'))

tests.append(dict(name  = 'adc_segments',
             testcase = 'capture',
             frequency = 1,
             LA_CAPTURE = 0,
             TRACE_CAPTURE = 0,
             GLITCH_CAPTURE = 0,
             MAX_SIZE = 300,
             MAX_PRESAMPLES = 300,
             MAX_OFFSET = 1000,
             MAX_SEGMENTS = 3,
             MAX_SEGMENT_CYCLES = 1000,
             description = 'ADC-only capture with segments.'))

tests.append(dict(name  = 'la_capture',
             testcase = 'capture',
             frequency = 4,
             ADC_CAPTURE = 0,
             GLITCH_CAPTURE = 0,
             TRACE_CAPTURE = 0,
             MAX_SIZE = 300,
             MAX_DOWNSAMPLE = 4,
             description = 'LA-only capture.'))

tests.append(dict(name  = 'trace_capture',
             testcase = 'capture',
             frequency = 4,
             ADC_CAPTURE = 0,
             GLITCH_CAPTURE = 0,
             LA_CAPTURE = 0,
             MAX_SIZE = 300,
             description = 'Trace-only capture.'))

tests.append(dict(name  = 'all_capture',
             testcase = 'capture',
             frequency = 1,
             description = 'All sources capture.'))

tests.append(dict(name  = 'all_capture_no_downstream',
             testcase = 'capture',
             frequency = 2,
             NO_DOWNSTREAM_TRIGGERS = 1,
             description = 'All sources capture, no downstream triggers.'))

tests.append(dict(name  = 'big_capture',
             testcase = 'capture',
             frequency = 4,
             MIN_SIZE = 300,
             MAX_SIZE= 1000,
             NUM_CAPTURES = 2,
             description = 'All sources, larger captures.'))

tests.append(dict(name  = 'huge_adc_capture',
             testcase = 'capture',
             frequency = 7,
             # note: max_size will get adjusted down if not pro
             MIN_SIZE = 12000,
             MAX_SIZE = 12100,
             NUM_CAPTURES = 1,
             LA_CAPTURE = 0,
             TRACE_CAPTURE = 0,
             GLITCH_CAPTURE = 0,
             FIFOSIZE = "TINYFIFO",
             # with TINY FIFO, for ADC we have:
             # fast FIFO: 1024 samples
             # pre DDR: 512*64/12 = 2730 samples
             # post DDR: 512*64/12 = 2730 samples
             # DDR capacity: selectable via TINYDDR, 256*64/12 = 1365 or 64K*64/12 = 349525 samples
             description = 'ADC capture exceeding pre-DDR FIFO size.'))

tests.append(dict(name  = 'adc_stream_regular',
             testcase = 'capture',
             frequency = 3,
             MIN_SIZE = 4096,
             MAX_SIZE = 16384,
             NUM_CAPTURES = 2,
             LA_CAPTURE = 0,
             TRACE_CAPTURE = 0,
             GLITCH_CAPTURE = 0,
             STREAM = 1,
             FIFOSIZE = "TINYFIFO",
             VARIANT = 'regular', # will only run with --variant=regular
             TIMEOUT_TIME = 10000,
             description = 'ADC-only stream capture (regular Husky only).'))

tests.append(dict(name  = 'adc_concurrent_stream_regular',
             testcase = 'capture',
             frequency = 3,
             MIN_SIZE = 4096,
             MAX_SIZE = 16384,
             NUM_CAPTURES = 2,
             LA_CAPTURE = 1,
             TRACE_CAPTURE = 1,
             STREAM = 1,
             FIFOSIZE = "TINYFIFO",
             VARIANT = 'regular', # will only run with --variant=regular
             TIMEOUT_TIME = 15000,
             description = 'ADC stream capture plus other sources (regular Husky only).'))

tests.append(dict(name  = 'huge_la_capture',
             testcase = 'capture',
             frequency = 7,
             MIN_SIZE = 12000,
             MAX_SIZE = 12100,
             NUM_CAPTURES = 1,
             ADC_CAPTURE = 0,
             TRACE_CAPTURE = 0,
             GLITCH_CAPTURE = 0,
             FIFOSIZE = "TINYFIFO",
             # with TINY FIFO, for LA we have:
             # pre DDR: 512*64/9 = 3640 samples
             # DDR capacity: selectable via TINYDDR, 256*64/12 = 1365 or 64K*64/12 = 349525 samples
             description = 'LA capture exceeding pre-DDR FIFO size.'))

tests.append(dict(name  = 'huge_all_capture',
             testcase = 'capture',
             frequency = 7,
             MIN_SIZE = 4000,
             MAX_SIZE = 4100,
             NUM_CAPTURES = 1,
             FIFOSIZE = "TINYFIFO",
             DDR_MODEL_WRITES = 'FAST_DDR_WRITES',
             description = 'ADC+trace+LA capture exceeding pre-DDR FIFO size.'))

tests.append(dict(name  = 'glitch_only',
             testcase = 'capture',
             frequency = 1,
             MIN_SIZE = 1,
             MAX_SIZE = 1,
             NUM_CAPTURES = 3,
             ADC_CAPTURE = 0,
             LA_CAPTURE = 0,
             TRACE_CAPTURE = 0,
             GLITCH_CAPTURE = 1,
             description = 'Only glitches.'))

tests.append(dict(name  = 'glitch_adc',
             testcase = 'capture',
             frequency = 2,
             MIN_SIZE = 20,
             MAX_SIZE = 50,
             NUM_CAPTURES = 3,
             ADC_CAPTURE = 1,
             LA_CAPTURE = 0,
             TRACE_CAPTURE = 0,
             GLITCH_CAPTURE = 1,
             description = 'ADC + glitches.'))

tests.append(dict(name  = 'glitch_ext_continuous',
             testcase = 'capture',
             frequency = 2,
             MIN_SIZE = 1,
             MAX_SIZE = 1,
             NUM_CAPTURES = 3,
             ADC_CAPTURE = 0,
             LA_CAPTURE = 0,
             TRACE_CAPTURE = 0,
             GLITCH_CAPTURE = 1,
             GLITCH_EXT_CONTINUOUS = 1,
             description = 'glitches, ext_continuous mode'))


tests.append(dict(name  = 'everything',
             testcase = 'capture',
             frequency = 1,
             NUM_CAPTURES = 3,
             ADC_CAPTURE = 1,
             LA_CAPTURE = 1,
             TRACE_CAPTURE = 1,
             GLITCH_CAPTURE = 1,
             description = 'ADC+LA+glitch.'))

tests.append(dict(name  = 'sad',
             frequency = 4,
             BITS_PER_SAMPLE = 8,
             REF_SAMPLES = 128, # caution: large values can lead to slow simulation
             SHORT_SAD = [0,1],
             THRESHOLD = [20,100], # keep threshold low to avoid unintentional triggers - testbench isn't smart enough
             TRIGGERS = 4,
             FLUSH = [0,1],
             LINEAR_RAMP = 0,
             TIMEOUT_CYCLES = 5000,
             SAD = 'SAD_X2',
             TOP = 'sad_tb.v',
             description = 'SAD block-level test.'))

tests.append(dict(name  = 'edge',
             frequency = 4,
             EDGES = [1, 32],
             TIMEOUT_CYCLES = 10000,
             TOP = 'edge_tb.v',
             description = 'edge trigger block-level test.'))

# TODO: more NUM_TRIGGERS for some variants?
tests.append(dict(name  = 'trigger_sequencer_pass',
             frequency = 4,
             PASS = 1,
             NUM_TRIGGERS = 2,
             TOP = 'trigger_sequencer_cocowrapper.v',
             description = 'trigger sequencer block-level test.'))

tests.append(dict(name  = 'trigger_sequencer_fail',
             frequency = 4,
             FAIL = 1,
             NUM_TRIGGERS = 2,
             TOP = 'trigger_sequencer_cocowrapper.v',
             description = 'trigger sequencer block-level test.'))

tests.append(dict(name  = 'trigger_sequencer_rand',
             frequency = 2,
             RAND = 1,
             NUM_TRIGGERS = 2,
             TOP = 'trigger_sequencer_cocowrapper.v',
             description = 'trigger sequencer block-level test.'))


def print_tests():
    print("Available tests:")
    for test in tests:
       print("%s: %s" % (test['name'], test['description']))
    quit()

def check_pass_fail(logfile, cocotb):
    log = open(logfile, 'r')
    passed = None
    warnings = 0
    errors = 0
    error_msg = None
    for line in log:
       if cocotb:
           failed = None
           if not error_msg:
               error_match = error_regex.search(line)
               if error_match:
                   error_msg = error_match.group(1)

           stat_matches = cocotb_stat_regex.search(line)
           if stat_matches:
              passed = int(stat_matches.group(2))
              failed = int(stat_matches.group(3))
              break
       else:
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
    if cocotb and failed:
        errors = 1
    return passed, warnings, errors, error_msg



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


if args.variant == 'plus':
    variant = 'VARIANT=PLUS'
elif args.variant == 'pro':
    variant = 'VARIANT=PRO'
elif args.variant == 'regular':
    variant = 'VARIANT=REGULAR'
else:
    raise ValueError('Variant not recognized (%s)' % args.variant)


pass_regex = re.compile(r'^Simulation passed \((\d+) warnings')
fail_regex = re.compile(r'^SIMULATION FAILED \((\d+) errors')
test_regex = re.compile(args.tests)
exclude_regex = re.compile(args.exclude)
cocotb_stat_regex = re.compile(r'TESTS=(\d+) PASS=(\d+) FAIL=(\d+) SKIP=(\d+)')
error_regex = re.compile(r'ERROR\s+cocotb.+cocowrapper\s+(.+)$')


exefile = 'coco.vvp'
outfile = open('coco_compile.out', 'w')
makeargs = ['make', 'compile_coco', variant, 'EXEFILE=%s' % exefile]
if args.dump:
    makeargs.append('DUMP=1')
if args.fast_fifo_sim:
    makeargs.append('FAST_FIFO_SIM=FAST_FIFO_SIM')
result = subprocess.run(makeargs, stdout=outfile, stderr=outfile)
if result.returncode:
    print ("Compilation for target %s failed (return code: %d), check coco_compile.out." % result.returncode)
    quit()

# Run tests:
start_time = int(time.time())
processes = []
jobs_to_submit = []
exefiles = []

print("Building list of jobs... ", end='')
for test in tests:
   if args.tests:
      if test_regex.search(test['name']) == None:
          continue
   if args.exclude:
      if exclude_regex.search(test['name']) != None:
          continue

   cocotb = True
   for i in range(args.runs):

      if args.compile_once:
          make_target = 'run_coco'
      else:
          make_target = 'coco'


      makeargs = ['make', make_target, 'COCOTB_LOG_LEVEL=%s' % args.cocodebug]
      if 'testcase' in test:
          makeargs.append('TESTCASE=%s' % test['testcase'])
      if (args.seed):
          seed = args.seed
      else:
          # not easy/clean to get cocotb-generated seed from logfile, so force ours instead
          seed = random.randint(0, 2**31-1)
      random.seed(seed)

      makeargs.append(variant)

      if args.timeout:
          makeargs.append('TIMEOUT_TIME=%d' % args.timeout)

      run_test = True
      # build make command:
      for key in test.keys():
         if key == 'name':
            logfile = "results/%s%d.log" % (test[key], i) 
            if not args.compile_once:
                exefile = "results/%s%d.vvp" % (test[key], i) 
                if args.dump:
                   makeargs.append('DUMP=1')
            makeargs.append("LOGFILE=%s" % logfile)
            makeargs.append("EXEFILE=%s" % exefile)
         elif key == 'description':
            pass
         elif key == 'frequency':
            if test[key] == 0:
               run_test = False
            elif i % test[key]:
               run_test = False
         elif key == 'VARIANT':
             if test[key] != args.variant:
                 run_test = False
         elif key == 'TOP' and test[key] == 'sad_tb.v':
             makeargs[1] = 'all_sad'
             cocotb = False
         elif key == 'TOP' and test[key] == 'edge_tb.v':
             makeargs[1] = 'all_edge'
             cocotb = False
         elif key == 'TOP' and test[key] == 'trigger_sequencer_cocowrapper.v':
             makeargs[1] = 'all_trigger_sequencer'
         else:
            if type(test[key]) == list:
               value = random.randint(test[key][0], test[key][1])
            else:
               value = test[key]
            makeargs.append("%s=%s" % (key, value))

      if cocotb:
          makeargs.append("RANDOM_SEED=%d" % seed)
      else:
          makeargs.append("SEED=%d" % seed)

      # run:
      if run_test:
         #print("Adding job: %s" % makeargs)
         jobs_to_submit.append((makeargs, logfile, outfile, seed, cocotb))
         exefiles.append(exefile)

num_processes = len(jobs_to_submit)
print("done. %d tests to run." % num_processes)

warns = []
fails = []

pbar_dispatched = tqdm(total=len(jobs_to_submit), desc='Tests dispatched')
pbar_finished   = tqdm(total=len(jobs_to_submit), desc='Tests finished ')
pbar_passed     = tqdm(total=len(jobs_to_submit), desc='Tests passing  ')

# submit first batch of jobs (up to args.proc):
if args.proc:
    procs = args.proc
elif os.cpu_count():
    procs = os.cpu_count()
else:
    procs = 8
if procs > len(jobs_to_submit):
    num_first_batch = len(jobs_to_submit)
else:
    num_first_batch = procs
for i in range(num_first_batch):
    makeargs, logfile, outfile, seed, cocotb = jobs_to_submit.pop()
    p = subprocess.Popen(makeargs, stdout=outfile, stderr=outfile)
    processes.append((p,logfile,seed, cocotb))

pbar_dispatched.update(num_first_batch)
pbar_dispatched.refresh()

oldfinished = 0
finished = 0
oldpass_count = 0
fail_count = 0
pass_count = 0
while len(processes):
    for p,l,s,cocotb in processes:
        if not p.poll() is None:
            finished += 1
            passed, warnings, errors, error_msg = check_pass_fail(l,cocotb)
            pass_count += passed
            if warnings:
                warns.append("%s: %0d warnings" % (l, warnings))
            if errors:
                fail_count += 1
                fails.append("%-42s %3d errors, seed:%12d 1st error: %20s" % (l, errors, s, error_msg))
            processes.remove((p,l,s,cocotb))
            if len(jobs_to_submit) > 0:
                makeargs, logfile, outfile, seed, cocotb = jobs_to_submit.pop()
                p = subprocess.Popen(makeargs, stdout=outfile, stderr=outfile)
                processes.append((p,logfile,seed,cocotb))
                pbar_dispatched.update(1)
                pbar_dispatched.refresh()

    pbar_finished.update(finished - oldfinished)
    pbar_passed.update(pass_count - oldpass_count)
    oldfinished = finished
    oldpass_count = pass_count
    time.sleep(1)

pbar_dispatched.close()
pbar_finished.close()
pbar_passed.close()

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

# clean up .vvp files:
if not args.compile_once:
    for v in exefiles:
        try:
            os.remove(v)
        except OSError as e:
            print("Error removing %s: %s" % (v, e))

