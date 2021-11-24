#!/usr/bin/env python3
#
# Usage: squash_testlogs.py "GLOBPATTERN" OUTPUT_FILE
#
# Example: squash_testlogs.py "/tf/pkg/testlogs/**/*.xml" /tf/pkg/merged.xml
#
# Squash a glob pattern of junit XML files into one minified XML file.
# The merged XML includes the timing and count for all tests, but only includes
# <testcase>s that have a sub-element (which gives us errors and failures).
import glob
import os
import sys
from junitparser import JUnitXml
from lxml import etree

result = JUnitXml()
for f in sorted(glob.glob(sys.argv[1], recursive=True)):
  result += JUnitXml.fromfile(f)
result.update_statistics()

for testsuite in result:
  # Use findall() to avoid removing any elements during traversal
  for testcase in testsuite._elem.findall("testcase"):
    if not len(testcase):
      testsuite._elem.remove(testcase)
  # Turn empty <testsuite></testsuite> into <testsuite/> to save space
  if not len(testsuite):
    testsuite._elem.text = None

os.makedirs(os.path.dirname(sys.argv[2]))
result.write(sys.argv[2])
