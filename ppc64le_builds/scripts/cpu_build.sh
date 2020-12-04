#!/usr/bin/env bash
# Run in the docker_image: ibmcom/tensorflow-ppc64le:devel-manylinux2014
# Run every commit or nightly

set -e

# Remove the prior build results.
rm -rf ./tensorflow_pkg

# Replaces calling ./configure
cat <<EOT > .tf_configure.bazelrc
build --action_env PYTHON_BIN_PATH="/opt/python/cp36-cp36m/bin/python"
build --action_env PYTHON_LIB_PATH="/opt/python/cp36-cp36m/lib/python3.6/site-packages"
build --python_path="/opt/python/cp36-cp36m/bin/python"
build:xla --define with_xla_support=true
build --config=xla
build:opt --copt=-mcpu=power8
build:opt --copt=-mtune=power8
build:opt --define with_default_optimizations=true
test --flaky_test_attempts=3
test --test_size_filters=small,medium
test:v1 --test_tag_filters=-benchmark-test,-no_oss,-gpu,-oss_serial
test:v1 --build_tag_filters=-benchmark-test,-no_oss,-gpu
test:v2 --test_tag_filters=-benchmark-test,-no_oss,-gpu,-oss_serial,-v1only
test:v2 --build_tag_filters=-benchmark-test,-no_oss,-gpu,-v1only
build --action_env TF_CONFIGURE_IOS="0"
EOT

cat <<EOT > ./tools/python_bin_path.sh
export PYTHON_BIN_PATH=/opt/python/cp36-cp36m/bin/python
EOT

# Mark the version with the nightly tag (this automatically bumps the version)
# Need to make sure it is not run more than once
git diff --name-only | grep tensorflow/core/public/version.h > /dev/null || rc=$?
if [[ $rc -ne 0 ]]; then
    ./tensorflow/tools/ci_build/update_version.py --nightly
fi

BAZEL_LINKLIBS=-l%:libstdc++.a bazel build -c opt --config=v2 --local_resources 4096,4.0,1.0 \
    //tensorflow/tools/pip_package:build_pip_package

bazel-bin/tensorflow/tools/pip_package/build_pip_package --nightly_flag --cpu ./tensorflow_pkg
