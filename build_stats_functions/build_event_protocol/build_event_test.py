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

import os
import build_event
import pytest


def test_check_path():
  # This is the path for where to find the build events we want in GCS storage
  r1 = build_event.check_path(
      'resultstore/prod/tensorflow/rel/build_event.json'
  )
  r2 = build_event.check_path(
      'resultstore/prod/tensorflow/rel/random_folder/build_event.json'
  )
  r3 = build_event.check_path(
      'resultstore/prod/tensorflow/rel.*/profile.json'
  )
  assert r1 is not None
  assert r2 is not None
  assert r3 is None

def test_extract_events():
  file_name = '/usr/local/google/home/halseycamilla/pytest/build/utils/build_stats/testing_files/example.json'
  r1 = build_event.extract_events(file_name)
  assert r1 is not None
  file_no_test = '/usr/local/google/home/halseycamilla/pytest/build/utils/build_stats/testing_files/no_test_label.json'
  with pytest.raises(build_event.IncorrectFileFormatError):
    build_event.extract_events(file_no_test)
  file_not_json = '/usr/local/google/home/halseycamilla/pytest/build/utils/build_stats/testing_files/not_json.json'
  with pytest.raises(build_event.IncorrectFileTypeError):
    build_event.extract_events(file_not_json)
  empty_file = '/usr/local/google/home/halseycamilla/pytest/build/utils/build_stats/testing_files/empty.json'
  with pytest.raises(build_event.EmptyFileError):
    build_event.extract_events(empty_file)

