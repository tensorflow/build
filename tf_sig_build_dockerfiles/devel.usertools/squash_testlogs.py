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
seen = set()

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
      key = p.getparent().get("name", "") + p.text
      if key in seen:
        testsuite._elem.remove(p.getparent())
      else:
        seen.add(key)
    # Include helpful notes
    for p in testsuite._elem.xpath('.//error | .//failure'):
      short_name = re.search(r'/(bazel_pip|tensorflow)/.*', f.decode("utf-8")).group(0)
      p.text += f"\nNOTE: From /{short_name}"
      if "bazel_pip" in short_name:
        p.text += "\nNOTE: This was a pip test. Remove 'bazel_pip' to find the real target."
      p.text += f"\nNOTE: The list of failures from the XML includes flakes and attempts as well."
      p.text += f"\n      The error(s) that caused the invocation to fail may not include this testcase."
    # Remove this testsuite if it doesn't have anything in it any more
    if len(testsuite) == 0:
      r._elem.remove(testsuite._elem)
  if len(r) > 0:
    result += r

os.makedirs(os.path.dirname(sys.argv[2]), exist_ok=True)
result.update_statistics()
result.write(sys.argv[2])
