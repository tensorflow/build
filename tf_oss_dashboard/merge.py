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

print("Total number of commits:", len(commits), file=sys.stderr)

if overlap:
  a = list(commits.values())
  a.sort(key=lambda x: x["committedDate"])
  # Only store the last 1000 commits worth of data, which is roughly 2 wks max
  # The sort is ascending (-2 days..yesterday..today), so [-1000:] gets the
  # 1000 most recent commits.
  new["data"]["repository"]["defaultBranchRef"]["target"]["history"]["nodes"] = a[-1000:]
print(json.dumps(new))
