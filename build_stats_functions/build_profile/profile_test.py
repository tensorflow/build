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
import profile
import pytest


def test_check_path():
  # Path for where to find the build profiles we want in GCS storage
  r1 = profile.check_path(
      'resultstore/prod/tensorflow/rel/profile.json'
  )
  r2 = profile.check_path(
      'resultstore/prod/tensorflow/rel/random_folder/profile.json'
  )
  r3 = profile.check_path(
       'resultstore/prod/tensorflow/rel.*/build.json'
  )
  assert r1 is not None
  assert r2 is not None
  assert r3 is None

def test_get_data():
  f1 = '//build/build_stats_functions/testing_files/no_first_line.json'
  with pytest.raises(profile.MissingTopLevelError):
    profile.get_data(f1)
  no_tid = '//build/build_stats_functions/testing_files/no_thread_id.json'
  with pytest.raises(profile.IncorrectProfileFormatError):
    profile.get_data(no_tid)
  no_name = '//build/build_stats_functions/testing_files/no_event_name.json'
  assert profile.get_data(no_name) is not None

def test_get_percents():
  no_name = '//build/build_stats_functions/testing_files/no_event_name.json'
  with pytest.raises(profile.IncorrectProfileFormatError):
    profile.get_percents(profile.get_data(no_name))
  no_ts = '//build/build_stats_functions/testing_files/no_timestamp.json'
  with pytest.raises(profile.IncorrectProfileFormatError):
       profile.get_percents(profile.get_data(no_ts))

