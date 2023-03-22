#!/usr/bin/env python3

from collections import defaultdict
from jinja2 import Environment, FileSystemLoader
import arrow
import itertools
import json
import markdown
import pypugjs
import re
import sys
import yaml

with open('config.yaml', 'r') as f:
  yaml_config = yaml.safe_load(f)
category_map = {}
for name, items in yaml_config["categories"].items():
  for item in items:
    category_map[item] = name

data = json.load(sys.stdin)
records = []
cl_re = re.compile(r"PiperOrigin-RevId: (\d+)")
for d in data["data"]["repository"]["defaultBranchRef"]["target"]["history"]["nodes"]:
  record = {
    "commit": d["oid"],
    "commit_id": "#" + d["oid"],
    "date": arrow.get(d["committedDate"], "YYYY-MM-DDTHH:mm:ssZ"),
    "commit_url": d["commitUrl"],
    "commit_summary": d["messageHeadline"],
    "commit_body": d["messageBody"].replace("\n", "</br>"),
    "commit_message": d["message"],
    "short_commit": d["oid"][0:7]
  }
  record["date_human"] = record["date"].to('US/Pacific').format("ddd, MMM D [at] h:mma ZZZ")
  has_cl = cl_re.search(d["message"])
  if has_cl:
    record["cl"] = has_cl.group(1)
    record["cl_url"] = f"http://cl/{record['cl']}"
  for item in d["statusCheckRollup"]["contexts"]["nodes"]:
    if "context" in item:
      sub = {
          "name": item["context"],
          "type": "status check",
          "state": item["state"],
          "result_url": item["targetUrl"]
      }
    else:
      default = { "workflow": { "name": "?" } }
      sub = {
          "name": (item["checkSuite"]["workflowRun"] or default)["workflow"]["name"] + " / " + item["name"],
          "type": "github action",
          "state": item["conclusion"] or item["status"],
          "result_url": item["url"]
      }
    raw = record | sub
    raw["category"] = category_map.get(raw["name"], "Everything Else")
    raw["raw"] = json.dumps(raw, default=str)
    records.append(raw)

records.sort(key=lambda l: l["date"], reverse=True)
by_name = defaultdict(list)
for record in records:
  by_name[record["name"]].append(record)

for name, jobs in by_name.items():
  new_jobs = []
  new_jobs.append({"date_tag": jobs[0]["date"].strftime("%a %b %d")})
  first_non_pending_status = None
  for job in jobs:
    if first_non_pending_status in [None, "PENDING", "IN_PROGRESS", "QUEUED"]:
      first_non_pending_status = job["state"]
  for left, right in itertools.pairwise(jobs):
    left["previous_diff_url"] = f"https://github.com/tensorflow/tensorflow/compare/{left['commit']}..{right['commit']}"
    new_jobs.append(left)
    if left["date"].date() != right["date"].date():
      new_jobs.append({"date_tag": right["date"].strftime("%a %b %d")})
  new_jobs.append(jobs[-1])
  new_jobs[0]["first_non_pending_status"] = first_non_pending_status
  new_jobs[0]["is_pending"] = new_jobs[1]["state"] in ["PENDING", "IN_PROGRESS", "QUEUED"]
  new_jobs[0]["card_class"] = " ".join([first_non_pending_status, "CARD_PENDING" if new_jobs[0]["is_pending"] else "CARD_NOT_PENDING"])
  # only render up to 150 commits per card
  by_name[name] = new_jobs[0:150]

by_group = defaultdict(dict)
for category, items in yaml_config["categories"].items():
  by_group[category] = {}
for name, jobs in sorted(by_name.items(), key=lambda x: x[0]):
  by_group[category_map.get(name, "Everything Else")][name] = jobs

by_commit = defaultdict(list)
for name, jobs in by_name.items():
  for job in jobs:
    if "commit" not in job:
      continue
    by_commit[job["commit"]].append(job)
for name, jobs in by_commit.items():
  jobs.sort(key=lambda k: k["name"])

with open("style.css", "r") as f:
  css = f.read()

with open("script.js", "r") as f:
  js = f.read()

with open("help.md", "r") as f:
  helptext = markdown.markdown(f.read())

env = Environment(
    loader=FileSystemLoader('.'),
    extensions=['pypugjs.ext.jinja.PyPugJSExtension']
)
template = env.get_template('template.html.pug')
now = arrow.now().to('US/Pacific').format("ddd, MMM D [at] h:mma ZZZ")
print(template.render(records=by_name, by_group=by_group, by_commit=by_commit, css=css, js=js, helptext=helptext, now=now))
