#!/usr/bin/env python3
from junitparser import JUnitXml, TestCase, TestSuite, Error, Skipped
import sys
import os

# Usage: 
# cat input | summary_to_xml.py > output
# Parses a bazel test log summary and generates a complete test list with
# timing information (even for passing tests).
# It would probably be better to parse this from BEP data, but ...

out = JUnitXml()
data = sys.stdin.readlines()
ts = TestSuite()
cs = None
for line in data:
  line = line.strip()

  if line.startswith("//"):
    if cs is not None:
      ts.append(cs)
    if "(cached)" in line:
      target, _, result, _, time = line.split()
    else:
      target, result, _, time = line.split()
    time = time.replace("s", "")
    classname = target.split(":")[0]
    cs = TestCase(target, classname, time)
    if result in ["ERROR", "FAILED", "FLAKY"]:
      cs.result=[Error()]
    if result in ["SKIPPED"] or "(cached)" in line:
      cs.result=[Skipped()]

  elif line.startswith("Stats over"):
    d = line.replace("s", "").replace(",", "").split()
    # Stats over 50 runs: max = 74.2s, min = 4.3s, avg = 6.8s, dev = 9.7s
    #   0    1   2   3     4  5  6     7   8  9    10  11 12    13 14  15
    n = int(d[2])
    maxs, mins, avgs, devs = [ float(d[n]) for n in [6, 9, 12, 15] ]
    # A weak real-time estimate is just "average speed * number of runs"
    cs.time = round(avgs * n, 2)
    cs.name = cs.name + " ({} runs est. sum)".format(n)
ts.append(cs)
out.add_testsuite(ts)

out.update_statistics()
out.write(sys.stdout.buffer)
