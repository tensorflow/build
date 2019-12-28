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

echo "Python and pip versions:"
python3 --version
python3 -m pip --version
echo

# Get the latest version of pip so it recognize manylinux2010
python3 -m pip install --upgrade pip

# Install pip packages from whl files to avoid the time-consuming process of
# building from source.

# wheel==0.32.0 breaks auditwheel:
# https://github.com/pypa/auditwheel/issues/102
python3 -m pip install --upgrade wheel>=0.32.1

# Install last working version of setuptools. This must happen before we install
# absl-py, which uses install_requires notation introduced in setuptools 20.5.
python3 -m pip install --upgrade setuptools>=39.1.0

# Install six and future.
python3 -m pip install --upgrade six>=1.12.0
python3 -m pip install --upgrade future>=0.17.1

# Install absl-py.
python3 -m pip install --upgrade absl-py

# Install werkzeug.
python3 -m pip install --upgrade werkzeug==0.11.10

# Install bleach. html5lib will be picked up as a dependency.
python3 -m pip install --upgrade bleach==2.0.0

# Install markdown.
python3 -m pip install --upgrade markdown==2.6.8

# Install protobuf.
python3 -m pip install --upgrade protobuf==3.6.1

# Remove obsolete version of six, which can sometimes confuse virtualenv.
rm -rf /usr/lib/python3/dist-packages/six*

python3 -m pip install --upgrade numpy==1.14.5

python3 -m pip install scipy==1.4.1

python3 -m pip install scikit-learn==0.18.1

# pandas required by `inflow`
python3 -m pip install pandas==0.19.2

# Benchmark tests require the following:
python3 -m pip install psutil==5.6.3
python3 -m pip install py-cpuinfo

# pylint tests require the following:
python3 -m pip install pylint==1.6.4

# pycodestyle tests require the following:
python3 -m pip install pycodestyle

python3 -m pip install portpicker

# TensorFlow Serving integration tests require the following:
python3 -m pip install grpcio

# Eager-to-graph execution needs astor, gast and termcolor:
python3 -m pip install --upgrade astor
python3 -m pip install --upgrade gast
python3 -m pip install --upgrade termcolor

# Keras
python3 -m pip install --upgrade keras_applications>=1.0.8 --no-deps
python3 -m pip install --upgrade keras_preprocessing>=1.1.0 --no-deps
python3 -m pip install --upgrade h5py>=2.8.0

# Estimator
python3 -m pip install tf-estimator-nightly --no-deps

# Tensorboard
python3 -m pip install --upgrade google-auth>=1.6.3 google-auth-oauthlib>=0.4.1 werkzeug>=0.11.15
python3 -m pip install tb-nightly --no-deps

# Argparse
python3 -m pip install --upgrade argparse

python3 -m pip install auditwheel>=2.0.0

echo "Installed python package versions:"
python3 -m pip freeze

