#!/usr/bin/env bash
# Run in the docker_image: ibmcom/tensorflow-ppc64le:gpu-devel-manylinux2014
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
build --action_env CUDA_TOOLKIT_PATH="/usr/local/cuda"
build --action_env TF_CUDA_COMPUTE_CAPABILITIES="3.5,7.0"
build --action_env LD_LIBRARY_PATH="/usr/local/nvidia/lib:/usr/local/nvidia/lib64"
build --action_env GCC_HOST_COMPILER_PATH="/opt/rh/devtoolset-8/root/usr/bin/gcc"
build --config=cuda
build:opt --copt=-mcpu=power8
build:opt --copt=-mtune=power8
build:opt --define with_default_optimizations=true
test --flaky_test_attempts=3
test --test_size_filters=small,medium
test:v1 --test_tag_filters=-benchmark-test,-no_oss,-no_gpu,-oss_serial
test:v1 --build_tag_filters=-benchmark-test,-no_oss,-no_gpu
test:v2 --test_tag_filters=-benchmark-test,-no_oss,-no_gpu,-oss_serial,-v1only
test:v2 --build_tag_filters=-benchmark-test,-no_oss,-no_gpu,-v1only
build --action_env TF_CONFIGURE_IOS="0"
EOT

cat <<EOT > ./tools/python_bin_path.sh
export PYTHON_BIN_PATH=/opt/python/cp36-cp36m/bin/python
EOT

#Hack to compile against CUDA on a non-gpu system
sudo ln -fs /usr/local/cuda/lib64/stubs/libcuda.so /usr/local/cuda/targets/ppc64le-linux/lib/libcuda.so.1
sudo ldconfig

# Mark the version with the nightly tag (this automatically bumps the version)
# Need to make sure it is not run more than once
git diff --name-only | grep tensorflow/core/public/version.h > /dev/null || rc=$?
if [[ $rc -ne 0 ]]; then
    ./tensorflow/tools/ci_build/update_version.py --nightly
fi

bazel --host_jvm_args="-Xms512m" --host_jvm_args="-Xmx4096m" build \
      -c opt --config=v2 --local_resources 8192,4.0,1.0 \
      //tensorflow/tools/pip_package:build_pip_package

bazel-bin/tensorflow/tools/pip_package/build_pip_package --nightly_flag ./tensorflow_pkg
