#!/usr/bin/env bash
# Copyright 2015 The TensorFlow Authors. All Rights Reserved.
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
# ==============================================================================

set -e

VERSION="0.4.5"

# Download buildifier
wget https://github.com/bazelbuild/buildtools/releases/download/${VERSION}/buildifier -O /usr/local/bin/buildifier
chmod +x /usr/local/bin/buildifier

# Download buildozer
wget https://github.com/bazelbuild/buildtools/releases/download/${VERSION}/buildozer -O /usr/local/bin/buildozer
chmod +x /usr/local/bin/buildozer
