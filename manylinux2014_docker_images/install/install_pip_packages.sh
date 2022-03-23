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

PYTHON_CMD="python3"


# Determine OS
UNAME=$(uname | tr "[:upper:]" "[:lower:]")
# If Linux
if [ "$UNAME" == "linux" ]; then
    # If redhat-release file is available use it to identify distribution
    if [ -f /etc/redhat-release ]; then
        PYTHON_CMD="python"
        # Note: 
        # We need to run>scl enable devtoolset-7 rh-python36
        # to use gcc-7 and python3.6. Adding it here will exit the script.
        # So we add in the Dockerfile.
    fi
    if [ -f /etc/lsb-release ]; then
        PYTHON_CMD="python3"
    fi
fi

# gcc is installed via install_[deb|rpm]_packages.sh
gcc --version
echo "Python and pip versions:"
$PYTHON_CMD --version
$PYTHON_CMD -m pip --version
echo

# Get the latest version of pip so it recognize manylinux2010
$PYTHON_CMD -m pip install --upgrade pip

# Install pip packages from whl files to avoid the time-consuming process of
# building from source.

# wheel==0.32.0 breaks auditwheel:
# https://github.com/pypa/auditwheel/issues/102
$PYTHON_CMD -m pip install --upgrade wheel>=0.32.1

# Install last working version of setuptools. This must happen before we install
# absl-py, which uses install_requires notation introduced in setuptools 20.5.
$PYTHON_CMD -m pip install --upgrade setuptools>=39.1.0

# Install six and future.
$PYTHON_CMD -m pip install --upgrade six>=1.12.0
$PYTHON_CMD -m pip install --upgrade future>=0.17.1

# Install absl-py.
$PYTHON_CMD -m pip install --upgrade absl-py==1.0.0

# Install werkzeug.
$PYTHON_CMD -m pip install --upgrade werkzeug==0.11.10

# Install bleach. html5lib will be picked up as a dependency.
$PYTHON_CMD -m pip install --upgrade bleach==2.0.0

# Install markdown.
$PYTHON_CMD -m pip install --upgrade markdown==2.6.8

# Install protobuf.
$PYTHON_CMD -m pip install --upgrade protobuf==3.6.1

# Remove obsolete version of six, which can sometimes confuse virtualenv.
rm -rf /usr/lib/$PYTHON_CMD/dist-packages/six*

$PYTHON_CMD -m pip install --upgrade numpy==1.14.5

$PYTHON_CMD -m pip install scipy==1.4.1

$PYTHON_CMD -m pip install scikit-learn==0.18.1

# pandas required by `inflow`
$PYTHON_CMD -m pip install pandas==0.19.2

# Benchmark tests require the following:
$PYTHON_CMD -m pip install psutil==5.6.3
$PYTHON_CMD -m pip install py-cpuinfo

# pylint tests require the following:
$PYTHON_CMD -m pip install pylint==1.6.4

# pycodestyle tests require the following:
$PYTHON_CMD -m pip install pycodestyle

$PYTHON_CMD -m pip install portpicker

# TensorFlow Serving integration tests require the following:
$PYTHON_CMD -m pip install grpcio

# Eager-to-graph execution needs astor, gast and termcolor:
$PYTHON_CMD -m pip install --upgrade astor
$PYTHON_CMD -m pip install --upgrade gast
$PYTHON_CMD -m pip install --upgrade termcolor

# Keras
$PYTHON_CMD -m pip install --upgrade keras_applications>=1.0.8 --no-deps
$PYTHON_CMD -m pip install --upgrade keras_preprocessing>=1.1.0 --no-deps
$PYTHON_CMD -m pip install --upgrade h5py>=2.8.0

# Estimator
$PYTHON_CMD -m pip install tf-estimator-nightly --no-deps

# Tensorboard
$PYTHON_CMD -m pip install --upgrade google-auth>=1.6.3 google-auth-oauthlib>=0.4.1 werkzeug>=0.11.15
$PYTHON_CMD -m pip install tb-nightly --no-deps

# Argparse
$PYTHON_CMD -m pip install --upgrade argparse

$PYTHON_CMD -m pip install auditwheel>=2.0.0

echo "Installed python package versions:"
$PYTHON_CMD -m pip freeze

