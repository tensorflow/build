#!/usr/bin/env python3
import json
import sys

with open(sys.argv[1], "r") as f:
  old = json.load(f)
with open(sys.argv[2], "r") as f:
  new = json.load(f)

overlap = False
commits = {}
for commit in old["data"]["repository"]["defaultBranchRef"]["target"]["history"]["nodes"]:
  commits[commit["oid"]] = commit
for commit in new["data"]["repository"]["defaultBranchRef"]["target"]["history"]["nodes"]:
  if commit["oid"] in commits:
    overlap = True
  commits[commit["oid"]] = commit

if overlap:
  # TODO(angerson) guarantee that this is sorted by date before being sliced
  new["data"]["repository"]["defaultBranchRef"]["target"]["history"]["nodes"] = list(commits.values())[0:300]
print(json.dumps(new))
