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

for f in files.strip().splitlines():
  # Just ignore any failures, they're probably not important
  try:
    f = f.decode("utf-8")
    r = JUnitXml.fromfile(f)
    short_name = re.search(r'/(bazel_pip|tensorflow)/.*', f).group(0)
    for testsuite in r:
      for elem in testsuite._elem.xpath('.//text()'):
        if elem.strip() != "":
          extra = ""
          if "bazel_pip" in short_name:
            extra = "\n//bazel_pip means this was a pip test."
          elem.getparent().text = elem + "\nNote: from /" + short_name + extra
    result += r
  except Exception as e: 
    print("Ignoring this XML parse failure in {}: ".format(f), str(e))


def content_hash(elem):
  return elem.getparent().get("name", "") + "\n".join(elem.text.splitlines()[:-2])

# For test cases, only show the ones that failed that have text (a log)
seen = set()
for testsuite in result:
  # Use findall() to avoid removing any elements during traversal
  for elem in testsuite._elem.findall("testcase"):
    if not len(elem):
      testsuite._elem.remove(elem)

  keep = False
  for elem in testsuite._elem.findall("testcase/error"):
    if elem.text and content_hash(elem) not in seen:
      seen.add(content_hash(elem))
      keep = True
    else:
      testsuite._elem.remove(elem.getparent())
  for elem in testsuite._elem.findall("testcase/failure"):
    if elem.text and content_hash(elem) not in seen:
      seen.add(content_hash(elem))
      keep = True
    else:
      testsuite._elem.remove(elem.getparent())
  for elem in testsuite._elem.findall("system-out"):
    if elem.text and content_hash(elem) not in seen:
      keep = True
      seen.add(content_hash(elem))
  if testsuite.failures == 0 and testsuite.errors == 0:
    keep = False
  if not keep:
    result._elem.remove(testsuite._elem)
  else:
    seen.add(testsuite.name)

os.makedirs(os.path.dirname(sys.argv[2]), exist_ok=True)
result.update_statistics()
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
