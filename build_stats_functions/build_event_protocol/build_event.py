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


"""Python Code for grabbing stats from build event protocol to be used."""
import json
import os
import re
from os import path

import functions_framework
from google.cloud import bigquery
from google.cloud import logging 
from google.cloud import storage

class IncorrectFileTypeError(Exception):
  """This file is not correctly formatted in JSON."""

class EmptyFileError(Exception):
  """The file passed in was empty"""

class IncorrectFileFormatError(Exception):
  """This file is not in the correct Build Event Protocol format."""


# Triggered by a change in a storage bucket
@functions_framework.cloud_event
def main(cloud_event: any):
  """Entry point function that is triggered by cloud event.
  Gathers stats from Build Event Protocol file and sends to BigQuery.
  Args:
    cloud_event: event that triggers the function
  """
  STORAGE_BUCKET = os.environ.get("STORAGE_BUCKET")
  TABLE_ID = os.environ.get("TABLE_ID")
  try:
    client = logging.Client()
    log_name = "build-event-testing"
    logger = client.logger(log_name)
    logger.log_text("Successfully connected to GCP Logging Client", severity="INFO")
  except logging.Error:
    logger.log_text("Unable to connect to GCP Logging client", severity="WARNING")
    raise logging.Error()
  data = cloud_event.data
  if "name" not in data:
    logger.log_text("No filename was found", severity="WARNING")
    return
  file_name = data["name"]
  check_file = check_path(file_name)
  if not check_file:
    logger.log_text(
        "The current file is not a BEP according to its path", severity="INFO"
    )
    return
  # Extract job name from overall path
    logger.log_text("Build Event Protocol found", severity="INFO")
    r = re.search("/[0-9].*", file_name)
    index = r.span()[0]
    job = file_name[0:index]
  try:
    storage_client = storage.Client()
    bucket = storage_client.get_bucket(STORAGE_BUCKET)
    data_blob = bucket.get_blob(file_name)
  except Exception as exc:
    logger.log_text("Unable to access Cloud Storage client or storage bucket", severity="WARNING")
    raise Exception() from exc
  # Extract test information from file
  all_events = extract_events(data_blob)
  # In the event that the job does not test
  if not all_events:
    logger.log_text("This job does not run tests", severity="INFO")
    return
  # Make an API request and make sure it executes correctly
  try:
    bigquery_client = bigquery.Client()
    for event in all_events:
      event["JOB_NAME"] = job
      event = [event]
      errors = bigquery_client.insert_rows_json(TABLE_ID, event)
      if not errors:
        logger.log_text("Successfully added row to table", severity="INFO")
      else:
        logger.log_text("Encountered errors while inserting rows", severity="INFO")
  except bigquery.Error:
    logger.log_text("Unable to access Bigquery client", severity="WARNING")
    return
  


def check_path(file_name: str):
  """Checks that the uploaded file is a BEP using regex
  Args:
    file_name: file path name
  Returns:
    The first occurence in the path that matches regex 
    or None if no match
  """
  regex = "prod/tensorflow/.*/bep.json"
  check_file = re.match(regex, file_name)
  return check_file


def extract_events(data_blob: any):
  """Extracts the TestSummary build events from build event protocol.
  Args:
    data_blob: the blob file that was uploaded in the triggering cloud event
  Raises:
    IncorrectFileTypeError: not JSON file
    IncorrectFileFormatError: wrong format
  Returns:
    Array of objects representing each TestSummary event
  """
  all_events = []
  # Loop through each line of the file and if in correct
  # format convert to json. If the current event is
  # a TestSummary event extract the relevant information.
  with data_blob.open("r") as file:
    for line in file:
      try:
        curr = json.loads(line)
      except ValueError:
        raise IncorrectFileTypeError()
      if type(curr) is not dict:
        raise IncorrectFileTypeError()
      event_id = curr["id"]
      if "testSummary" in event_id:
        test_summary = curr["testSummary"]
        obj = {}
        try:
          obj["TEST_NAME"] = event_id["testSummary"]["label"]
          obj["TOTAL_RUN_COUNT"] = test_summary["totalRunCount"]
          obj["STATUS"] = test_summary["overallStatus"]
          run_duration = test_summary["totalRunDuration"]
          obj["TOTAL_RUN_DURATION"] = float(run_duration[:-1])/1000)
          obj["ATTEMPT_COUNT"] = test_summary["attemptCount"]
        except KeyError as exc:
          raise IncorrectFileFormatError() from exc
        all_events.append(obj)
  return all_events
