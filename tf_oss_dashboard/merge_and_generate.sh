#!/bin/bash
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
# Usage:
#   merge_and_generate.sh [name of config file]
#   e.g. merge_and_generate.sh jax
set -euxo pipefail

pip install -r requirements.txt
NAME=$1

mkdir -p $NAME
./query_api.sh $NAME.yaml $NAME/new.json
echo "::group::new data (LARGE)"
cat $NAME/new.json
echo "::endgroup::"
if [[ -e "$NAME/old.json" ]]; then
  echo "::group::old data (LARGE)"
  cat $NAME/old.json
  echo "::endgroup::"
  echo "::group::Merged data"
  ./merge.py $NAME.yaml $NAME/old.json $NAME/new.json | tee $NAME/merged.json
  echo "::endgroup::"
else
  mv $NAME/new.json $NAME/merged.json
fi
echo "::group::Dashboard"
cat $NAME/merged.json | ./dashboard.py $NAME
echo "::endgroup::"
mv $NAME/merged.json $NAME/old.json
