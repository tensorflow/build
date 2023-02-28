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
import logging
import os
import re

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
#@functions_framework.cloud_event
def main(cloud_event):
  """Entry point function that is triggered by cloud event.

  Gathers stats from Build Event Protocol file and sends to BigQuery

  Args:
    cloud_event: event that triggers the function
  """
  storage_bucket = os.environ.get("STORAGE_BUCKET")
  table_id = os.environ.get("TABLE_ID")
  try:
    logging_client = logging.Client()
    logging_client.logging()
  except logging.Error:
    logging.warning("Unable to connect to GCP Logging client")
    raise logging.Error()
  data = cloud_event.data
  if "name" not in data:
    logging.warning("No filename was found")
    return
  file_name = data["name"]
  check_file = check_path(file_name)
  if not check_file:
    logging.info("This file path is not in the correct format for a BEP")
    return
  try:
    storage_client = storage.Client()
    bucket = storage_client.get_bucket(storage_bucket)
    data_blob = bucket.get_blob(file_name)
  except Exception as exc:
    logging.warning("Unable to access Cloud Storage client or storage bucket")
    raise Exception() from exc
  # Loops through file
  all_events = extract_events(data_blob)
  try:
    bigquery_client = bigquery.Client()
    for event in all_events:
      event = [event]
      errors = bigquery_client.insert_rows_json(table_id, event)
      if not errors:
        logging.info("Successfully added row to table")
      else:
        logging.info("Encountered errors while inserting rows")
    # log instead no one's ever going to catch that ever if it gets printed
  except bigquery.Error:
    logging.warning("Unable to access Bigquery client")
    return
  # Make an API request and make sure it executes correctly


def check_path(file_name: str):
  regex = "resultstore/prod/tensorflow/rel.*/build_event.json"
  check_file = re.match(regex, file_name)
  return check_file


def extract_events(data_blob):
  """Extracts the build events from build event protocol.

  Args:
    data_blob: the file

  Raises:
    IncorrectFileTypeError: not JSON file
    IncorrectFileFormatError: wrong format

  Returns:
    list of all build events in file in an array
  """
  all_events = []
  with open(data_blob, "r") as file:
    for line in file:
      try:
        curr = json.loads(line)
      except ValueError:
        raise IncorrectFileTypeError()
      if type(curr) is not dict:
        raise IncorrectFileTypeError()
      # have string version because curr["id"] is json object and string allows
      # for easier searching for terms
      event_id = str(curr["id"])
      if "testSummary" in event_id:
        test_summary = curr["testSummary"]
        obj = {}
        try:
          obj["TEST_NAME"] = curr["id"]["testSummary"]["label"]
          obj["TOTAL_RUN_COUNT"] = test_summary["totalRunCount"]
          obj["STATUS"] = test_summary["overallStatus"]
          run_duration = test_summary["totalRunDuration"]
          obj["TOTAL_RUN_DURATION"] = float(run_duration[:-1])
          obj["ATTEMPT_COUNT"] = test_summary["attemptCount"]
        except KeyError as exc:
          raise IncorrectFileFormatError() from exc
        all_events.append(obj)
    if len(all_events) == 0:
      logging.warning("Empty output")
      raise EmptyFileError()
  return all_events