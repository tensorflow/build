#!/usr/bin/env python3
#
# Usage: squash_testlogs.py START_DIRECTORY OUTPUT_FILE
#
# Example: squash_testlogs.py /tf/pkg/testlogs /tf/pkg/merged.xml
#
# Recursively find all the JUnit test.xml files in one directory, and merge any
# of them that contain failures into one file. The TensorFlow DevInfra team
# uses this to generate a simple overview of an entire pip and nonpip test
# invocation, since the normal logs that Bazel creates are too large for the
# internal invocation viewer.
import collections
import glob
import os
import sys
from junitparser import JUnitXml
from lxml import etree
import subprocess
import re

result = JUnitXml()
try:
  files = subprocess.check_output(["grep", "-rlE", '(failures|errors)="[1-9]', sys.argv[1]])
except subprocess.CalledProcessError as e:
  print("No failures found to log!")
  exit(0)

# For test cases, only show the ones that failed that have text (a log)
seen = collections.Counter()
runfiles_matcher = re.compile(r"(/.*\.runfiles/)")

for f in files.strip().splitlines():
  # Just ignore any failures, they're probably not important
  try:
    r = JUnitXml.fromfile(f)
  except Exception as e: 
    print("Ignoring this XML parse failure in {}: ".format(f), str(e))

  for testsuite in r:
    # Remove empty testcases
    for p in testsuite._elem.xpath('.//testcase'):
      if not len(p):
        testsuite._elem.remove(p)
    # Convert "testsuite > testcase,system-out" to "testsuite > testcase > error"
    for p in testsuite._elem.xpath('.//system-out'):
      for c in p.getparent().xpath('.//error | .//failure'):
        c.text = p.text
      p.getparent().remove(p)
    # Remove duplicate results of the same exact test (e.g. due to retry attempts)
    for p in testsuite._elem.xpath('.//error | .//failure'):
      # Sharded tests have target names like this:
      # WindowOpsTest.test_tflite_convert0 (<function hann_window at 0x7fc61728dd40>, 10, False, tf.float32)
      # Where 0x... is a thread ID (or something) that is not important for
      # debugging, but breaks this "number of failures" counter because it's
      # different for repetitions of the same test. We use re.sub("0x\w+")
      # to remove it.
      key = re.sub("0x\w+", "", p.getparent().get("name", "")) + p.text
      if key in seen:
        testsuite._elem.remove(p.getparent())
      seen[key] += 1
    # Remove this testsuite if it doesn't have anything in it any more
    if len(testsuite) == 0:
      r._elem.remove(testsuite._elem)
  if len(r) > 0:
    result += r

# Insert the number of failures for each test to help identify flaikes
# need to clarify for shard
for p in result._elem.xpath('.//error | .//failure'):
  short_name = re.search(r'/(bazel_pip|tensorflow)/.*', f.decode("utf-8")).group(0)
  key = re.sub("0x\w+", "", p.getparent().get("name", "")) + p.text
  p.text += f"\nNOTE: From /{short_name}"
  p.text = runfiles_matcher.sub("[testroot]/", p.text)
  if "bazel_pip" in short_name:
    p.text += "\nNOTE: This is a --config=pip test. Remove 'bazel_pip' to find the file."
  n_failures = seen[key]
  p.text += f"\nNOTE: Number of failures for this test: {seen[key]}."
  p.text += f"\n      Most TF jobs run tests three times to root out flakes."
  if seen[key] == 3:
    p.text += f"\n      Since there were three failures, this is not flaky, and it"
    p.text += f"\n      probably caused the Kokoro invocation to fail."
  else:
    p.text += f"\n      Since there were not three failures, this is probably a flake."
    p.text += f"\n      Flakes make this pkg/pip_and_nonpip_tests target show as failing,"
    p.text += f"\n      but do not make the Kokoro invocation fail."

os.makedirs(os.path.dirname(sys.argv[2]), exist_ok=True)
result.update_statistics()
result.write(sys.argv[2])
