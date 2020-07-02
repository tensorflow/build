#!/usr/bin/env bash
# Copyright 2020 The TensorFlow Authors. All Rights Reserved.
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
#     ./install_rpm_packages

set -e

# Note:
# Don't run >yum update for manylinux2014 Image
# https://github.com/sclorg/centos-release-scl
# pypa uses centos-release-scl-rh
# Don't run >yum install -y centos-release-scl

# gpg java-headless procps are not available
INSTALL_PKGS="autoconf \
    automake \
    binutils \
    bsdtar \
    bzip2 \
    c-ares \
    c-ares-devel \
    clang \
    cmake \
    cpuid \
    curl \
    devtoolset-7 \
    dmidecode \
    file \
    findutils \
    freetype-devel \
    gcc \
    gcc-c++ \
    gdb \
    gettext \
    git \
    giflib-devel \
    glibc-devel \
    gnupg2 \
    groff-base \
    gzip \
    java-1.8.0-openjdk \
    java-1.8.0-openjdk-devel \
    kernel-devel \
    libpng12-devel \
    libtool \
    libxml2 \
    libxml2-devel \
    libxslt \
    libxslt-devel \
    make \
    mlocate \
    openssl-devel \
    patch \
    pciutils \
    perf \
    protobuf-compiler \
    python27 \
    rh-python35 \
    rh-python36 \
    rsync \
    scl-utils \
    sqlite \
    swig \
    tar \
    tree \
    unzip \
    wget \
    which \
    x86info  \
    yum-utils \
    zeromq3-devel \
    zip \
    zlib-devel"

yum install -y --setopt=tsflags=nodocs $INSTALL_PKGS
#rpm -V $INSTALL_PKGS
yum -y clean all --enablerepo='*'

# populate the database
updatedb
