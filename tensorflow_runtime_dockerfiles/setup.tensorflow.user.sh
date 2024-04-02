#!/usr/bin/env bash
#
# Copyright 2022 The TensorFlow Authors. All Rights Reserved.
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
#
# setup.tensorflow.user.sh: create an user account used to run tensorflow
# Usage: set envrionment variables TENSORFLOW_USER, TENSORFLOW_GROUP, TENSORFLOW_UID, TENSORFLOW_GID and run script setup.tensorflow.user.sh
#

echo "creating group ${TENSORFLOW_GROUP} with gid ${TENSORFLOW_GID} ..." && \
groupadd --system --gid ${TENSORFLOW_GID} ${TENSORFLOW_GROUP} && \
echo "creating user ${TENSORFLOW_USER}:${TENSORFLOW_GROUP} (${TENSORFLOW_UID}:${TENSORFLOW_GID}) ..." && \
useradd --system --uid ${TENSORFLOW_UID} --home-dir=/home/${TENSORFLOW_USER} --create-home --gid ${TENSORFLOW_GID} ${TENSORFLOW_USER}