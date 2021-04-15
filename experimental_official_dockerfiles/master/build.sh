#!/usr/bin/env bash
set -euxo pipefail
# mkdir -p ~/tmp/dockertests/cache
# DOCKER_BUILDKIT=1 docker build --target=runtime -t tf-exp-runtime .
# docker run --gpus=all --rm tf-exp-runtime python -c "import tensorflow as tf; tf.test.is_gpu_available()"

DOCKER_BUILDKIT=1 docker build --target=devel -t tf-exp-devel .
# docker run --rm -v ~/tmp/dockertests:/tmp/dockertests tf-exp-devel /devel.build_tf.sh

docker run --rm -v ~/tmp/dockertests:/tmp/dockertests tf-exp-devel /devel.build_addons.sh
