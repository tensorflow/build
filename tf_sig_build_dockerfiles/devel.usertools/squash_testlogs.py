#!/usr/bin/env python3
#
# Usage: squash_testlogs.py START_DIRECTORY OUTPUT_FILE
#
# Example: squash_testlogs.py /tf/pkg/testlogs /tf/pkg/merged.xml
#
# Recursively find all the JUnit XML files in one directory, and merge any of
# them that contain failures into one file. Then compress it to avoid repeats.
import glob
import os
import sys
from junitparser import JUnitXml
from lxml import etree
import subprocess
import re

result = JUnitXml()
try:
  # Something about this doesn't work.
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

  short_name = re.search(r'/(bazel_pip|tensorflow)/.*', f.decode("utf-8")).group(0)
  for testsuite in r:
    for p in testsuite._elem.xpath('.//testcase'):
      if not len(p):
        testsuite._elem.remove(p)
    for p in testsuite._elem.xpath('.//error | .//failure | .//system-out'):
      if p.text and p.text.strip() != "" and p.text not in seen:
        seen.add(p.text)
        extra = ""
        if "bazel_pip" in short_name:
          extra = " This was a pip test. Take off //bazel_pip to find the real target."
        p.text = p.text + "\nNote: from /" + short_name + extra
      else:
        if p.tag in ["error", "failure"]:
          testsuite._elem.remove(p.getparent())
        else:
          r._elem.remove(p.getparent())
    if len(testsuite) == 0:
      r._elem.remove(testsuite._elem)
  if len(r) > 0:
    result += r


os.makedirs(os.path.dirname(sys.argv[2]), exist_ok=True)
result.update_statistics()
result.write(sys.argv[2])
