#!/bin/bash
set -e
cd /tf/tensorflow
bazel build tensorflow/tools/pip_package:build_pip_package --bazelrc=/user_tools/gpu.bazelrc --disk_cache=/tf/cache
./bazel-bin/tensorflow/tools/pip_package/build_pip_package /tf/pkg --gpu
