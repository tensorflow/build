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
    print("Ignoring this XML parse failure in {}: ".format(f), str(e))
result.update_statistics()

# For test cases, only show the ones that failed that have text (a log)
# And cut that log down to the last 5 lines, max line length 80 characters
seen = set()
for testsuite in result:
  # Use findall() to avoid removing any elements during traversal
  for elem in testsuite._elem.findall("testcase"):
    if not len(elem):
      testsuite._elem.remove(elem)

  keep = False
  for elem in testsuite._elem.findall("testcase/error"):
    if elem.text:
      keep = True
    else:
      testsuite._elem.remove(elem.getparent())
  for elem in testsuite._elem.findall("testcase/failure"):
    if elem.text:
      keep = True
    else:
      testsuite._elem.remove(elem.getparent())
  for elem in testsuite._elem.findall("system-out"):
    if elem.text:
      keep = True
  if testsuite.failures == 0 and testsuite.errors == 0:
    keep = False
  if testsuite.name in seen:
    keep = False
  if not keep:
    result._elem.remove(testsuite._elem)
  else:
    seen.add(testsuite.name)

os.makedirs(os.path.dirname(sys.argv[2]), exist_ok=True)
result.write(sys.argv[2])

# If the resulting log file is beyond the internal limit for Google's Sponge
# log system (either 10MB or 4MB, not clear), then also cut down all text
# sections to the final few lines, truncated to a reasonable length (some
# logs will dump out log lines that are thousands of characters long).
FOUR_MB = 4194304
TEN_MB = 10485760
if os.path.getsize(sys.argv[2]) <= TEN_MB:
  exit(0)

LEN = 400
TAIL = 5
def get_short_tail(elem):
  def truncate(x):
    if len(x) > LEN:
      return "..." + x[-LEN:] + " (line truncated)"
    return x
  return "\n".join([truncate(x) for x in elem.text.rstrip().splitlines()[-TAIL:]])

for testsuite in result:
  for elem in testsuite._elem.findall("testcase/error"):
    if elem.text:
      elem.text = get_short_tail(elem)
  for elem in testsuite._elem.findall("testcase/failure"):
    if elem.text:
      elem.text = get_short_tail(elem)
  for elem in testsuite._elem.findall("system-out"):
    if elem.text:
      elem.text = get_short_tail(elem)

result.write(sys.argv[2])
