#!/bin/bash
set -e
cd /tf/tensorflow
bazel --bazelrc=/user_tools/gpu.bazelrc build tensorflow/tools/pip_package:build_pip_package  --disk_cache=/tf/cache
./bazel-bin/tensorflow/tools/pip_package/build_pip_package /tf/pkg --gpu
