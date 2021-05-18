#!/bin/bash
# Sample of how to build and run these containers.
# 
# Depends on a /tf directory with these directories:
#   cache - bazel cache
#   tensorflow - tensorflow source code tree
#   pkg - for built packages
# 
# For example, run like this:
#
#   docker run --rm -v ~/your/mountable/directory:/tf angersson/tensorflow-build /user_tools/build_tf.sh
set -e
cd /tf/tensorflow
bazel --bazelrc=/user_tools/gpu.bazelrc build tensorflow/tools/pip_package:build_pip_package  --disk_cache=/tf/cache
./bazel-bin/tensorflow/tools/pip_package/build_pip_package /tf/pkg --gpu
