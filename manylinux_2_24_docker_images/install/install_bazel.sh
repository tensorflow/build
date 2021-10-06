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

# Select bazel version.
BAZEL_VERSION="1.2.1"
BAZELISK_VERSION="1.2.1"

set +e
local_bazel_ver=$(bazel version 2>&1 | grep -i label | awk '{print $3}')

if [[ "$local_bazel_ver" == "$BAZEL_VERSION" ]]; then
  exit 0
fi

set -e

# download installer
mkdir -p /bazel
cd /bazel
if [[ ! -f "bazel-$BAZEL_VERSION-installer-linux-x86_64.sh" ]]; then
  curl -fSsL -O https://github.com/bazelbuild/bazel/releases/download/$BAZEL_VERSION/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh
fi
chmod +x /bazel/bazel-*-installer-linux-*.sh

# install
/bazel/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh
mv /usr/local/bin/bazel /usr/local/bin/bazel-${BAZEL_VERSION}
rm -f /bazel/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh

# install bazelisk
if [[ ! -f "bazelisk-linux-amd64-${BAZELISK_VERSION}" ]]; then
  curl -fSsL -O https://github.com/bazelbuild/bazelisk/releases/download/v${BAZELISK_VERSION}/bazelisk-linux-amd64
  mv /bazel/bazelisk-linux-amd64 /bazel/bazelisk-linux-amd64-${BAZELISK_VERSION}
fi
chmod +x /bazel/bazelisk-linux-amd64-${BAZELISK_VERSION}
mv /bazel/bazelisk-linux-amd64-${BAZELISK_VERSION} /usr/local/bin/bazelisk
ln -sf /usr/local/bin/bazelisk /usr/local/bin/bazel
rm -f /bazel/bazelisk-linux-amd64-${BAZELISK_VERSION}

# Enable bazel auto completion.
echo "source /usr/local/lib/bazel/bin/bazel-complete.bash" >> ~/.bashrc
