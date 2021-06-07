#!/bin/bash
git clone --depth=1 --single-branch --branch ${1:-master} https://github.com/tensorflow/tensorflow /tmp/tf
pushd /tmp/tf && git pull && popd
cp -t "$(dirname "$0")" /tmp/tf/tensorflow/tools/ci_build/devtoolset/fixlinks.sh \
  /tmp/tf/tensorflow/tools/ci_build/devtoolset/build_devtoolset.sh \
  /tmp/tf/tensorflow/tools/ci_build/devtoolset/rpm-patch.sh
