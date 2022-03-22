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
#
# Usage:
#     ./install_deb_packages

set -e

export DEBIAN_FRONTEND=noninteractive

# Install bootstrap dependencies from ubuntu deb repository.
apt-get update
apt-get install -y --no-install-recommends \
    apt-transport-https \
    ca-certificates \
    software-properties-common

#apt-get clean
#rm -rf /var/lib/apt/lists/*

# Add PPAs
add-apt-repository -y ppa:openjdk-r/ppa

# Install dependencies from ubuntu deb repository.
apt-key adv --keyserver keyserver.ubuntu.com --recv 084ECFC5828AB726
apt-get update

apt-get install -y --no-install-recommends \
    autoconf \
    automake \
    build-essential \
    clang-format-3.8 \
    curl \
    git \
    libcurl4-openssl-dev \
    libssl-dev \
    libtool \
    mlocate \
    openjdk-8-jdk \
    openjdk-8-jre-headless \
    openssh-client \
    patchelf \
    pkg-config \
    python3-dev \
    python3-pip \
    python3-setuptools \
    python3-venv \
    rsync \
    sudo \
    swig \
    unzip \
    vim \
    wget \
    zip \
    zlib1g-dev

# populate the database
updatedb


# Install ca-certificates, and update the certificate store.
apt-get install -y ca-certificates-java
update-ca-certificates -f

apt-get clean
rm -rf /var/lib/apt/lists/*
