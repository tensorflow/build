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
  # Sometimes test logs can be empty. I'm not sure why they are, so for now
  # I'm just going to ignore failures and print a message about them
  try:
    result += JUnitXml.fromfile(f)
  except Exception as e: 
    print("Ignoring this XML parse failure: ", str(e))
result.update_statistics()

def short_tail(elem):
  return "\n".join([x[-LEN:] for x in elem.text.rstrip().splitlines()[-TAIL:]])

# For test cases, only show the ones that failed that have text (a log)
# And cut that log down to the last 5 lines, max length 80 characters
LEN = 80
TAIL = 5
for testsuite in result:
  # Use findall() to avoid removing any elements during traversal
  keep = False
  for elem in testsuite._elem.findall("testcase"):
    if not len(elem):
      testsuite._elem.remove(elem)
  for elem in testsuite._elem.findall("testcase/error"):
    if elem.text:
      keep = True
      elem.text = short_tail(elem)
    else:
      testsuite._elem.remove(elem.getparent())
  for elem in testsuite._elem.findall("testcase/failure"):
    if elem.text:
      keep = True
      elem.text = short_tail(elem)
    else:
      testsuite._elem.remove(elem.getparent())
  for elem in testsuite._elem.findall("system-out"):
    if elem.text:
      keep = True
      elem.text = short_tail(elem)
  if not keep:
    result._elem.remove(testsuite._elem)

os.makedirs(os.path.dirname(sys.argv[2]), exist_ok=True)
result.write(sys.argv[2])
