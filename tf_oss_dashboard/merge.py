#!/usr/bin/env python3
#
# Copyright 2023 The TensorFlow Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============================================================================
#
# Merge two GitHub GraphQL response data JSON files.
#
# Usage:
#   merge.py config.yaml old.json new.json > merged.json
import json
import sys
import yaml

with open(sys.argv[1], 'r') as f:
  YAML_CONFIG = yaml.safe_load(f)

with open(sys.argv[2], "r") as f:
  old = json.load(f)
with open(sys.argv[3], "r") as f:
  new = json.load(f)

overlap = False
commits = {}
for commit in old["data"]["repository"]["ref"]["target"]["history"]["nodes"]:
  commits[commit["oid"]] = commit
for commit in new["data"]["repository"]["ref"]["target"]["history"]["nodes"]:
  if commit["oid"] in commits:
    overlap = True
  commits[commit["oid"]] = commit

print("Total number of commits:", len(commits), file=sys.stderr)

if overlap:
  a = list(commits.values())
  a.sort(key=lambda x: x["committedDate"])
  # Only store the last N commits worth of data, based on history_size from the
  # yaml config. For TF it's 1000, which is roughly 2 wks max. The sort is
  # ascending (-2 days..yesterday..today), so [-1000:] gets the 1000 most recent
  # commits.
  new["data"]["repository"]["ref"]["target"]["history"]["nodes"] = a[-YAML_CONFIG["history_size"]:]
print(json.dumps(new))
