#!/bin/bash
set -e
source ~/.bashrc
pyenv global tf-38
git clone https://github.com/tensorflow/tensorflow --depth=1
mv tf_configure.bazelrc tensorflow/.tf_configure.bazelrc
cd tensorflow
bazel build tensorflow/tools/pip_package:build_pip_package --disk_cache=/tmp/dockertests/cache
./bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/dockertests/pkg --gpu
