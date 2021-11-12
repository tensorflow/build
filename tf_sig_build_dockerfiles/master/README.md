# TensorFlow `master` branch Dockerfiles

These Dockerfiles are supported by the TensorFlow team and are published to
tensorflow/build as latest-python3.6..3.9. The TensorFlow OSS DevInfra team
is evaluating these containers for building `tf-nightly`.

## Building `tf-nightly` packages

The TensorFlow team's scripts aren't visible, but use the configuration files which are
included in the containers. Here is how to build a TensorFlow package with the same
configuration as tf-nightly:

```
# Beforehand, set up:
#  - A directory with the TensorFlow source code, e.g. /tmp/tensorflow
#  - A directory for TensorFlow packages, e.g. /tmp/packages
#  - OPTIONAL: A directory for your local bazel cache, e.g. /tmp/bazelcache

time docker pull tensorflow/build:latest-python3.7
docker run --name tf -w /tf/tensorflow -itd --rm \
  -v "/tmp/packages:/tf/pkg" \
  -v "/tmp/tensorflow:/tf/tensorflow" \
  -v "/tmp/bazelcache:/tf/cache" \
  tensorflow/build:latest-python3.7 \
  bash

time docker exec tf python3 tensorflow/tools/ci_build/update_version.py --nightly

# The local cache will be faster if you're repeatedly testing new changes, and the
# remote cache will be faster if you have a low-powered computer. We're still not
# sure how much the cache helps yet.
time docker exec tf \
    bazel \
    --bazelrc=/user_tools/cpu.bazelrc \
    # OR --bazelrc=/user_tools/gpu.bazelrc \
    build \
    --config=sigbuild_remote_cache \
    # OR: --config=sigbuild_local_cache \
    tensorflow/tools/pip_package:build_pip_package
    
time docker exec tf \
    ./bazel-bin/tensorflow/tools/pip_package/build_pip_package \
    /tf/pkg \
    --cpu \
    # OR: --gpu \
    --nightly_flag
    
# Check for manylinux compliance and rename the wheels appropriately
time docker exec tf /user_tools/rename_and_verify_wheels.sh

# Check the newly built wheel
ls -al /tmp/packages

# Shut down the container if you are finished.
docker stop tf
```
