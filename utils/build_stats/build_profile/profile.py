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
# =============================================================================
"""Python Code for grabbing stats from build profile to import into BigQuery."""
import json
import logging
import os
import re

import functions_framework
from google.cloud import bigquery
from google.cloud import logging 
from google.cloud import storage


class IncorrectFileTypeError(Exception):
  """This file is not correctly formatted in JSON."""


class MissingTopLevelError(Exception):
  """The build profile is missing the top-level object."""


class IncorrectProfileFormatError(Exception):
  """This file is not in the correct Build Profile format."""


@functions_framework.cloud_event
def main(cloud_event: any):
  """Entry point function that is triggered by uploading build profile.
  Gathers stats from build profile file and sends to BigQuery. Goes through
  each thread in the file and for each event in the thread extracts relevant
  info and writes as an object into bigquery
  Args:
    cloud_event: the google cloud event that triggered the function
  """
  STORAGE_BUCKET = os.environ.get("STORAGE_BUCKET")
  TABLE_ID = os.environ.get("TABLE_ID")
  try:
    client = logging.Client()
    log_name = "trying-this-out"
    logger = client.logger(log_name)
    logger.log_text("Successfully connected to GCP Logging Client", severity="INFO")
  except logging.Error:
    logger.log_text("Unable to connect to GCP Logging client", severity="WARNING")
    return
  data = cloud_event.data
  if "name" not in data:
    logger.log_text("No filename was found", severity="WARNING")
    return
  file_name = data["name"]
  print(file_name)
  check_file = check_path(file_name)
  if not check_file:
    logger.log_text(
        "The current file is not a build profile according to its path", severity="INFO"
    )
    return
  else:
    logger.log_text("Build profile found", severity="INFO")
  try:
    storage_client = storage.Client()
    print(STORAGE_BUCKET)
    bucket = storage_client.get_bucket(STORAGE_BUCKET)
    print(bucket)
    data_blob = bucket.get_blob(file_name)
    print(data_blob)
  except Exception as exc:
    logger.log_text("Unable to access Cloud Storage client or storage bucket", severity="WARNING")
    raise Exception() from exc
  threads = get_data(data_blob)
  all_threads = get_percents(threads)
  if len(all_threads) == 0:
    logger.log_text(
        "Profile had no completed action events or wasn't in correct format", severity="WARNING"
    )
    return
  objs = create_event_objects(all_threads)
  try:
    bigquery_client = bigquery.Client()
    for obj in objs:
      errors = bigquery_client.insert_rows_json(TABLE_ID, [obj])
      if not errors:
        logger.log_text("New rows have been added.", severity="INFO")
      else:
        logger.log_text("Encountered errors while inserting rows", severity="INFO")
  except bigquery.Error:
    logger.log_text("Unable to access Bigquery client", severity="WARNING")
    return

def check_path(file_name: str):
  regex = "resultstore/prod/tensorflow/rel.*/profile.json"
  check_file = re.match(regex, file_name)
  return check_file


def get_data(data_blob: any):
  """Goes through each line in blob file and converts strings to dictionary object.
  Args:
    data_blob: the blob file that was uploaded in the triggering cloud event
  Raises:
    MissingTopLevelError: Doesn't have top level object
    IncorrectProfileFormatError: Missing required fields for a profile
    IncorrectFileTypeError: One or more lines is not in correct JSON format
  Returns:
    A dict mapping keys of thread ids to an array of events in that thread
  """
  threads = {}
  with data_blob.open("r") as file:
    i = 0
    for line in file:
      if i == 0:
        # Make sure the first line is top level object containing
        # MetaData "Otherdata" and "TraceEvents"
        if "otherData" not in line or "traceEvents" not in line:
          raise MissingTopLevelError()
          logger.log_text("Missing first line of profile", severity="WARNING")
      if i > 0:
        my_json = line.rstrip()
        if my_json[-1] == ",":
          my_json = my_json[0 : len(my_json) - 1]
        if my_json[-1] != "}":
          break
      # JSONDecodeError is general error for incorrect Json Format
      # Wrap in class error to have more specific exception
        try:
          data = json.loads(my_json)
        except ValueError as exc:
          raise IncorrectFileTypeError() from exc
        if "tid" not in data:
          raise IncorrectProfileFormatError()
        a = data["tid"]
        if a not in threads:
          threads[a] = []
        threads[a].append(data)
      i += 1
  return threads


def get_percents(threads: dict):
  """For each event in thread keep track of total time it takes.
  Args:
    threads: dictionary of {thread id: [events in thread]}
  Raises:
    IncorrectProfileFormatError: Incorrect format for profile format
  Returns:
    A dict mapping type of event to total time event took
  """
  # For each thread create a dictionary of {eventtype: sum of eventtype times}
  # Also keep an overall dictionary of all of the threads
  all_threads = {}
  for thread in threads:
    total_time = 0
    all_events = []
    event_times = {}
    seen = set()
    for event in threads[thread]:
      if "ts" not in event or "dur" not in event or "ph" not in event:
        raise IncorrectProfileFormatError()
      # If the current event is a complete event (indicated by phase X)
      # we want to look at it because then it has all the information we need
      if event["ph"] == "X":
        # To calculate the self time of the event want to get the duration
        # and subtract the time of any child jobs
        # Child events show up before the current event however can be out of 
        # order overall so hence loop through all previous events in the file
        # if the time stamps overlap we see it is a child event
        # NOTE: In rare occassions there won't be an overlap showing up but 
        # this only throws off overall self time of event by 10ths of a second.
        self_time = event["dur"]
        if total_time > 0:
          low = event["ts"]
          high = low + event["dur"]
          for i in range(len(all_events) - 1, -1, -1):
            curr = all_events[i]
            if (
                curr["ts"] > low
                and curr["ts"] < high
                and str(curr) not in seen
                and curr["dur"] < event["dur"]
            ):
              seen.add(str(curr))
              self_time -= curr["dur"]
        all_events.append(event)
        total_time += self_time
        if "name " not in event:
          raise IncorrectProfileFormatError()
        event_type = event["name"]
        event_type = event_type.replace(":", "")
        event_type = event_type.replace(" ", "")
        if event_type not in event_times:
          event_times[event_type] = 0
        event_times[event_type] += self_time
    all_threads[thread] = event_times
  return all_threads

def create_event_objects(all_threads: dict):
  objs = []
  for line in all_threads:
    for data in all_threads[line]:
      ev = {}
      ev["THREAD"] = line
      ev["EVENT_TYPE"] = data
      ev["TOTAL_TIME"] = all_threads[line][data]
      objs.append(ev)
  return objs
