#!/usr/bin/env python3
from junitparser import JUnitXml, TestCase, TestSuite, Error
import sys
import os
import numpy as np

out = JUnitXml()
with open(sys.argv[1]) as f:
  data = f.readlines()
ts = TestSuite()
cs = None
for line in data:
  line = line.strip()
  if line.startswith("//"):
    if cs is not None:
      ts.append(cs)
    if "(cached)" in line:
      target, _, result, _, time = line.split()
      target = "CACHED:" + target
    else:
      target, result, _, time = line.split()
    time = time.replace("s", "")
    classname = target.split(":")[0]
    cs = TestCase(target, classname, time)
    if result in ["ERROR", "FAILED", "FLAKY"]:
      cs.result=[JUnitXml.Error()]
  elif line.startswith("Stats over"):
    d = line.replace("s", "").replace(",", "").split()
    # Stats over 50 runs: max = 74.2s, min = 4.3s, avg = 6.8s, dev = 9.7s
    #   0    1   2   3     4  5  6     7   8  9    10  11 12    13 14  15
    n = int(d[2])
    maxs, mins, avgs, devs = [ float(d[n]) for n in [6, 9, 12, 15] ]
    a = np.random.normal(avgs, devs, n)
    b = np.interp(a, (a.min(), a.max()), (mins, maxs))
    b = np.round(np.sum(b), 1)
    cs.time = b
    cs.name = cs.name + " ({} runs est. sum)".format(n)
ts.append(cs)
out.add_testsuite(ts)

os.makedirs(os.path.dirname(sys.argv[2]), exist_ok=True)
out.update_statistics()
out.write(sys.argv[2])
