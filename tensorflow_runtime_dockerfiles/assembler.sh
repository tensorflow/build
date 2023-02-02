#!/bin/bash

function try() {
  "$@" || echo "failed: $@" >> log.txt
}

try docker build --target=jupyter --build-arg TENSORFLOW_PACKAGE=tensorflow-cpu -t tensorflow/tensorflow:latest-jupyter -f cpu.Dockerfile .
try docker build --target=jupyter --build-arg TENSORFLOW_PACKAGE=tensorflow -t tensorflow/tensorflow:latest-gpu-jupyter -f gpu.Dockerfile .
try docker build --target=base --build-arg TENSORFLOW_PACKAGE=tensorflow-cpu -t tensorflow/tensorflow:latest -f cpu.Dockerfile .
try docker build --target=base --build-arg TENSORFLOW_PACKAGE=tensorflow -t tensorflow/tensorflow:latest-gpu -f gpu.Dockerfile .

try docker build --target=jupyter --build-arg TENSORFLOW_PACKAGE=tensorflow-cpu -t tensorflow/tensorflow:latest-jupyter -f cpu.Dockerfile .
try docker build --target=jupyter --build-arg TENSORFLOW_PACKAGE=tf-nightly-cpu -t tensorflow/tensorflow:nightly-jupyter -f cpu.Dockerfile .
try docker build --target=jupyter --build-arg TENSORFLOW_PACKAGE=tensorflow -t tensorflow/tensorflow:latest-gpu-jupyter -f gpu.Dockerfile .
try docker build --target=jupyter --build-arg TENSORFLOW_PACKAGE=tf-nightly -t tensorflow/tensorflow:nightly-gpu-jupyter -f gpu.Dockerfile .

try docker build --target=base --build-arg TENSORFLOW_PACKAGE=tensorflow-cpu -t tensorflow/tensorflow:latest -f cpu.Dockerfile .
try docker build --target=base --build-arg TENSORFLOW_PACKAGE=tf-nightly-cpu -t tensorflow/tensorflow:nightly -f cpu.Dockerfile .
try docker build --target=base --build-arg TENSORFLOW_PACKAGE=tensorflow -t tensorflow/tensorflow:latest-gpu -f gpu.Dockerfile .
try docker build --target=base --build-arg TENSORFLOW_PACKAGE=tf-nightly -t tensorflow/tensorflow:nightly-gpu -f gpu.Dockerfile .

if [[ -s log.txt ]]; then
  echo "all these failed:"
  cat log.txt
  exit 1
fi
