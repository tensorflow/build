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
# Generates the TF OSS dashboard.
# Usage: ./query_api.sh config.yaml | ./dashboard.py config.yaml | tee dashboard.html
#        You can also do ./query_api.sh config.yaml > data.json and then do:
#        cat data.json | ./dashboard.py config.yaml | tee dashboard.html

from collections import defaultdict
from jinja2 import Environment, FileSystemLoader
import arrow
import cmarkgfm
import itertools
import json
import os.path
import pypugjs
import re
import subprocess
import sys
import yaml

OUTDIR=sys.argv[1]
with open(sys.argv[1] + ".yaml", 'r') as f:
  YAML_CONFIG = yaml.safe_load(f)
JSON_DATA = json.load(sys.stdin)

# Gather "all_records", which is a list of individual job results for one commit
# with all its associated data. The query data from the GitHub API comes back
# as this structure:
#   COMMIT-A
#     JOB-1
#       RESULT-A-1
#     JOB-2
#       RESULT-A-2
#   COMMIT-1
#     JOB-1
#       RESULT-B-1
#     JOB-2
#       RESULT-B-2
#   ...and so on.
# In order to process this data conveniently, the first thing to do is flatten
# it while doing some basic preprocessing. So this first large loop flattens
# and partially duplicates the above structure into a list of "records":
#   COMMIT-A+JOB-1+RESULT-A-1
#   COMMIT-A+JOB-2+RESULT-A-2
#   COMMIT-A+JOB-1+RESULT-A-1
#   COMMIT-B+JOB-2+RESULT-B-2
#   ...and so on.
# So we end up with a big list of each single job invocation and its results
# plus all its associated commit metadata.
all_records = []
workflows = defaultdict(object)
CHANGELIST_REGEX = re.compile(r"PiperOrigin-RevId: (\d+)")
for commit in JSON_DATA["data"]["repository"]["ref"]["target"]["history"]["nodes"]:
  # Ignore commits with no statusCheckRollup, which can happen sometimes --
  # maybe when a commit has no results at all yet for any jobs?
  if commit["statusCheckRollup"] is None:
    continue

  record = {
    "commit": commit["oid"],
    "commit_id": "#" + commit["oid"],
    "date": arrow.get(commit["committedDate"], "YYYY-MM-DDTHH:mm:ssZ").to('US/Pacific'),
    "commit_url": commit["commitUrl"],
    "commit_summary": commit["messageHeadline"],
    "short_commit": commit["oid"][0:YAML_CONFIG["short_sha_length"]]
  }
  commit_has_cl = CHANGELIST_REGEX.search(commit["message"])
  if commit_has_cl:
    record["cl"] = commit_has_cl.group(1)
    record["cl_url"] = f"http://cl/{record['cl']}"
    # Remove the last two lines, which is where the PiperOrigin-RevID trailer is
    commit["message"] = commit["message"].rstrip().rsplit("\n", 2)[0]
  record["commit_message"] = cmarkgfm.github_flavored_markdown_to_html(commit["message"])

  record["date_human"] = record["date"].to('US/Pacific').format("ddd, MMM D [at] h:mma ZZZ")

  # Every record will have the same base commit data, so now we duplicate that
  # info into one record for every job result
  for check in commit["statusCheckRollup"]["contexts"]["nodes"]:
    clone = record.copy()
    # The structure is different for GitHub Actions-based jobs and statuses
    # reported to the GitHub API by other systems like Jenkins or Kokoro.
    # Non-GitHub-Actions jobs will have "context" as a data key.
    if "context" in check:
        clone["name"] = check["context"]
        clone["type"] = "status check"
        clone["state"] = check["state"]
        clone["result_url"] = check["targetUrl"]
        clone["is_public"] = not (check["targetUrl"] or "").startswith(tuple(YAML_CONFIG["internal_startswith"]))
    # GitHub Actions jobs are all other kinds of jobs.
    else:
      # Some GitHub Actions results don't have a workflow group name, so we
      # default it to "?"
      name_first = "?"
      if check["checkSuite"]["workflowRun"]:
        name_first = check["checkSuite"]["workflowRun"]["workflow"]["name"]
        clone["workflow_id"] = check["checkSuite"]["workflowRun"]["workflow"]["id"]
        if clone["workflow_id"] not in workflows:
          workflows[clone["workflow_id"]] = {
            "url": check["checkSuite"]["workflowRun"]["workflow"]["url"],
            "name": check["checkSuite"]["workflowRun"]["workflow"]["name"],
            "jobs": defaultdict(object)
          }

      clone["base_name"] = f"{check["name"]}"
      clone["name"] = f"{name_first} / {check['name']}"
      clone["type"] = "github action"

      if check["checkSuite"]["workflowRun"] and clone["workflow_id"] in workflows and clone["name"] not in workflows[clone["workflow_id"]]["jobs"]:
        workflows[clone["workflow_id"]]["jobs"][clone["name"]] = {
          "display_name" : clone["base_name"], # When we add workflow runs we don't want the workflow name appended twice
          "entries": list()
        }

      # "conclusion" is only present and valuable if the Action has already
      # finished running. If it's not there, then we want "status", which will
      # say e.g. PENDING or QUEUED.
      clone["state"] = check["conclusion"] or check["status"]
      clone["result_url"] = check["url"]
      clone["is_public"] = True
      
    if not YAML_CONFIG["internal_shown"] and not clone["is_public"]:
      continue
    if clone["name"] in YAML_CONFIG["hidden"]:
      continue
    all_records.append(clone)

# Order every record by date, DESCENDING, so that the MOST RECENT RECORDS
# appear FIRST. This eventually leads to the dashboard showing the status dots
# for a job in reverse order, i.e. the most recent (most useful) records are
# first on the list. Once they've been sorted we can group them by job name
# for further processing.
#
# NOTE: EVERY DATE REFERRED TO IN THE DASHBOARD IS THE COMMIT DATE, NOT THE
# JOB EXECUTION DATE.
all_records.sort(key=lambda l: l["date"], reverse=True)
job_names_to_records = defaultdict(list)
for record in all_records:
  job_names_to_records[record["name"]].append(record)

# Populate extra "nightly status" tracking in every record. A commit has been
# included in the nightly jobs if it was committed before a nightly job's
# commit. This way we can quickly tell when a commit was first tested in a TF
# Nightly test.
basis = YAML_CONFIG.get("nightly_job_basis", False) 
if basis:
  if basis not in job_names_to_records:
    exit(f"nightly_job_basis has been set to '{basis}', but those results are missing. Is the configuration correct?")
  nightlies = job_names_to_records[basis]
  for name, records in job_names_to_records.items():
    for record in records:
      for nightly in nightlies:
        if record["date"] <= nightly["date"]:
          record["first_nightly"] = "In Nightly Since: " + nightly["date_human"]
          record["first_nightly_sha"] = nightly["commit_id"]

# Populate GitHub diff URLs for every record within a job. Since records are
# grouped by job and sorted by date, we can easily compute the diff between
# two job results by comparing the commit hash between two neighboring records.
for job_name, original_records in job_names_to_records.items():
  for later, earlier in itertools.pairwise(original_records):
    later["previous_diff_url"] = "https://github.com/{}/{}/compare/{}...{}".format(
        YAML_CONFIG["repo_owner"],
        YAML_CONFIG["repo_name"],
        earlier['commit'],
        later['commit'])

# Now that all the individual record preprocessing is done, every record has
# everything it needs to be displayed individually as part of a commit record.
# So we gather all records again and group them by commit, then sort them
# by job name (since they're going to be displayed as a big list, so it should
# be easy to find each one)
commits_to_records = defaultdict(list)
for job_name, original_records in job_names_to_records.items():
  for record in original_records:
    commits_to_records[record["commit"]].append(record)
for name, records in commits_to_records.items():
  records.sort(key=lambda k: k["name"].lower())


# Now we'll generate a list of records specifically used for display on cards.
# Cards need a little more fine-tuning than just a list of records:
#   1. They need aggregate metadata about all contained records
#   2. They need date separators
#   3. They need a size limit on their contents (to prevent huge cards)
# So we iterate through job_names_to_records again and insert fake "records"
# to use for display. All of them visually separate the days that a record
# came from, and the first one ("meta" below) also has extra data about all
# of the records in the list.
for job_name, original_records in job_names_to_records.items():
  records = []

  meta = {"date_tag": original_records[0]["date"].strftime("%a %b %d")}
  meta["is_public"] = any(r["is_public"] for r in original_records)

  # The CSS class for a card is the most recent completed job. That is, if
  # every job has been failing, we prefer to know that at a glance rather than
  # whether or not a new invocation is currently running.
  meta["css_classes"] = ""
  for record in original_records:
    if record["state"] not in ["PENDING", "IN_PROGRESS", "QUEUED", "EXPECTED"]:
      meta["css_classes"] = record["state"]
      break
  meta["passing"] = meta["css_classes"] not in ["FAILURE", "ERROR", "TIMEOUT"]

  records.append(meta)

  # Cut off the records tracked for a card so that the cards don't grow too
  # large visually. At the same time, insert fake date "records" to separate
  # the days for records on the cards.
  DATE_BADGE_SIZE = 3
  MAX_CARD_SIZE = YAML_CONFIG["maximum_card_size"]
  card_visual_size = DATE_BADGE_SIZE  # For the first "meta" record
  for later, earlier in itertools.pairwise(original_records):
    card_visual_size += 1
    if card_visual_size >= MAX_CARD_SIZE:
      break
    records.append(later)
    if later["date"].date() != earlier["date"].date():
      card_visual_size += DATE_BADGE_SIZE
      if card_visual_size >= MAX_CARD_SIZE:
        break
      records.append({"date_tag": earlier["date"].strftime("%a %b %d")})
  # The final record isn't included by pairwise, so add it manually
  if card_visual_size < MAX_CARD_SIZE:
    records.append(original_records[-1])

  job_names_to_records[job_name] = records


# If group by workflow is set, all GH Actions workflows will gain their own category
# In which their jobs are listed underneath them.  The workflow will also
# have a link to the workflow file.
# For each workflow claim each job name that it is associated with
for workflow_id, workflow_record in workflows.items():
  for name in workflow_record["jobs"]:
    if name in job_names_to_records:
      workflow_record["jobs"][name]["entries"] = job_names_to_records[name]
      # TODO: probably delete the record from the main list


# Now we group all the jobs (which are records grouped by job name, sorted
# by date) into their categories, as specified in config.yaml. We process
# everything such that we get:
#  1. All categories with specified children sorted in the same order as their
#     children are specified in config.yaml
#  2. The special "default" category with all children in alphabetical order
by_group = defaultdict(dict)
known_names = list(itertools.chain(*YAML_CONFIG["categories"].values()))
for category, job_names in YAML_CONFIG["categories"].items():
  if category == YAML_CONFIG["default_category"]:
    for job_name, records in sorted(job_names_to_records.items()):
      if job_name not in known_names and records:
        by_group[category][job_name] = job_names_to_records[job_name]
  else:
    for job_name in job_names:
      if job_names_to_records[job_name]:
        by_group[category][job_name] = job_names_to_records[job_name]

# Finally, pass everything to the template and render it
with open("help.md", "r") as f:
  helptext = cmarkgfm.github_flavored_markdown_to_html(YAML_CONFIG["help"] + "\n\n" + f.read())
env = Environment(
    loader=FileSystemLoader('.'),
    extensions=['pypugjs.ext.jinja.PyPugJSExtension']
)
template = env.get_template('template.html.pug')
now = arrow.now().to('US/Pacific').format("ddd, MMM D [at] h:mma ZZZ")
isonow = arrow.now().to('US/Pacific').isoformat() 
with open(os.path.join(OUTDIR, "index.html"), "w") as f:
  f.write(template.render(
      by_group=by_group,
      by_workflow=workflows,
      by_commit=commits_to_records,
      helptext=helptext,
      now=now,
      isonow=isonow,
      yaml=YAML_CONFIG))

# Generate SVG badges. wget prints to stderr so it doesn't corrupt HTML output.
# Maybe the print statement above should be using an output file instead.
for category in YAML_CONFIG["badges"]:
  total = len(by_group[category])
  passed = sum([jobs[0]["passing"] for name, jobs in by_group[category].items()])
  failed = total - passed
  if failed == 0:
    url = f"https://img.shields.io/static/v1?label={category}&message={passed} passed, 0 failed&color=success"
  else:
    url = f"https://img.shields.io/static/v1?label={category}&message={passed} passed, {failed} failed&color=critical"
  subprocess.run(["wget", url, "-O", f"{OUTDIR}/{category}.svg"])
