#!/usr/bin/env bash
set -euxo pipefail
# DOCKER_BUILDKIT=1 docker build --target=runtime -t tf-exp-runtime .
# docker run --gpus=all --rm tf-exp-runtime python -c "import tensorflow as tf; tf.test.is_gpu_available()"

DOCKER_BUILDKIT=1 docker build --target=devel --build-arg PYTHON_VERSION=python3.8 -t tf-exp-devel .
# docker run --rm -v ~/tmp/dockertests:/tmp/dockertests tf-exp-devel bats -T /devel.preliminary.bats

# docker run --rm -it -v ~/tmp/dockertests:/tmp/dockertests tf-exp-devel bash

docker run --rm -v ~/tmp/dockertests:/tf tf-exp-devel /devel.build_tf.sh

# docker run --rm -v ~/tmp/dockertests:/tmp/dockertests tf-exp-devel /devel.build_addons.sh
