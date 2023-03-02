# TensorFlow Runtime Dockerfiles

Simple Dockerfiles for running TensorFlow, with Jupyter and GPU variants.

Maintainer: @angerson (TensorFlow, SIG Build)

* * *

These containers are built by an internal job at Google and published to
[tensorflow/tensorflow](https://hub.docker.com/r/tensorflow/tensorflow) on
Docker Hub. Here's a quick way to try out TensorFlow with GPU support and Jupyter:

```bash
docker run --gpus=all -it --rm -v $(realpath ~/notebooks):/tf/notebooks -p 8888:8888 tensorflow/tensorflow:nightly-gpu-jupyter
```

Refer to [the tensorflow.org Docker installation
instructions](https://www.tensorflow.org/install/docker) for more details.

# Building Containers

Builds are straightforward. Here's a sample:

```bash
docker build --target=base --build-arg TENSORFLOW_PACKAGE=tf-nightly-cpu -t tensorflow-nightly -f cpu.Dockerfile .
```

Look at the Dockerfiles for full details.

The builds include very simple import tests to verify that the packages work.
You can run the tests like so:

```bash
docker build --target=test --build-arg TENSORFLOW_PACKAGE=tf-nightly-cpu -f cpu.Dockerfile .
docker build --target=base --build-arg TENSORFLOW_PACKAGE=tf-nightly-cpu -t tensorflow-nightly -f cpu.Dockerfile .
```

The test layer starts from the base layer, so the second command will complete instantly.

# Contributions

If you would like to contribute a small change, please make a pull request. For
large changes such as support for additional platforms, please clone this
directory into a new directory and update the README to indicate that you are
the new maintainer.
