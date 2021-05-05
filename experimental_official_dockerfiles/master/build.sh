#!/usr/bin/env bash
# Sample of how to build and run these containers.
# Expects a /tmp/dockertests directory that contains these folders:
# cache - bazel cache
# tensorflow - tensorflow source code
set -euxo pipefail
DOCKER_BUILDKIT=1 docker build --target=devel --build-arg PYTHON_VERSION=python3.8 -t tf-exp-devel .
docker run --rm -v ~/tmp/dockertests:/tf tf-exp-devel bats -T /devel.preliminary.bats
docker run --rm -v ~/tmp/dockertests:/tf tf-exp-devel /devel.build_tf.sh
