#!/bin/bash
set -e
source ~/.bashrc
pyenv global tf-38
mv devel.bazelrc /tmp/dockertests/tensorflow/.tf_configure.bazelrc
cd /tmp/dockertests/tensorflow
bazel build tensorflow/tools/pip_package:build_pip_package --disk_cache=/tmp/dockertests/cache
./bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/dockertests/pkg --gpu
