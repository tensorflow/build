#!/bin/bash

#
# build the CPU images
#
docker build --target=jupyter \
    --build-arg TENSORFLOW_PACKAGE=tf-nightly-cpu \
    --build-arg TENSORFLOW_USER=tf \
    --build-arg TENSORFLOW_GROUP=tfuser \
    --build-arg TENSORFLOW_UID=2024 \
    --build-arg TENSORFLOW_GID=2024 \
    -t tensorflow-nightly-cpu -f cpu.Dockerfile .

docker build --target=test \
    --build-arg TENSORFLOW_PACKAGE=tf-nightly-cpu \
    --build-arg TENSORFLOW_USER=tf \
    --build-arg TENSORFLOW_GROUP=tfuser \
    --build-arg TENSORFLOW_UID=2024 \
    --build-arg TENSORFLOW_GID=2024 \
    -t tensorflow-nightly-cpu-test -f cpu.Dockerfile .

#
# build the GPU images
#
docker build --target=jupyter \
    --build-arg TENSORFLOW_PACKAGE=tf-nightly-gpu \
    --build-arg TENSORFLOW_USER=tf \
    --build-arg TENSORFLOW_GROUP=tfuser \
    --build-arg TENSORFLOW_UID=2024 \
    --build-arg TENSORFLOW_GID=2024 \
    -t tensorflow-nightly-gpu -f gpu.Dockerfile .

docker build --target=test \
    --build-arg TENSORFLOW_PACKAGE=tf-nightly-gpu \
    --build-arg TENSORFLOW_USER=tf \
    --build-arg TENSORFLOW_GROUP=tfuser \
    --build-arg TENSORFLOW_UID=2024 \
    --build-arg TENSORFLOW_GID=2024 \
    -t tensorflow-nightly-gpu-test -f cpu.Dockerfile .

#
# build the TPU images
#
docker build --target=jupyter \
    --build-arg TENSORFLOW_PACKAGE=tf-nightly-tpu \
    --build-arg TENSORFLOW_USER=tf \
    --build-arg TENSORFLOW_GROUP=tfuser \
    --build-arg TENSORFLOW_UID=2024 \
    --build-arg TENSORFLOW_GID=2024 \
    -t tensorflow-nightly-tpu -f cpu.Dockerfile .

docker build --target=test \
    --build-arg TENSORFLOW_PACKAGE=tf-nightly-tpu \
    --build-arg TENSORFLOW_USER=tf \
    --build-arg TENSORFLOW_GROUP=tfuser \
    --build-arg TENSORFLOW_UID=2024 \
    --build-arg TENSORFLOW_GID=2024 \
    -t tensorflow-nightly-tpu-test -f cpu.Dockerfile .