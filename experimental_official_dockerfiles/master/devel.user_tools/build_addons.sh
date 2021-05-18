#!/bin/bash
# Sample of how to build and run TF addons.
# 
# Depends on a /tf directory with these directories:
#   addons - tensorflow source code tree
# 
# For example, run like this:
#
#   docker run --rm -v ~/your/mountable/directory:/tf angersson/tensorflow-build:latest-python3.8 /user_tools/build_addons.sh
set -e
cd /tf/addons
python -m pip install tensorflow wheel auditwheel
chmod +x ./tools/testing/build_and_run_tests.sh
./tools/testing/build_and_run_tests.sh
bazel build --crosstool_top=//build_deps/toolchains/gcc7_manylinux2010-nvcc-cuda11:toolchain --action_env=PYENV_VERSION=3.8.2 build_pip_pkg
./bazel-bin/build_pip_pkg artifacts
chmod +x ./tools/releases/tf_auditwheel_patch.sh
./tools/releases/tf_auditwheel_patch.sh
python -m auditwheel repair --plat manylinux2010_x86_64 /tf/addons/artifacts/tensorflow_addons-0.13.0.dev0-cp38-cp38-linux_x86_64.whl
python -m auditwheel show /tf/addons/wheelhouse/*
