# [Experimental] Official Dockerfiles

Rework of TensorFlow's Dockerfiles

Maintainer: @angerson (TensorFlow, SIG Build)

* * *

WIP Dockerfiles for building and using TensorFlow and related packages.

Nothing here is constant! If you see something that doesn't make sense or could
be better, chances are it could be improved.

The idea here is to create an easy-to-maintain Docker image that can build
TensorFlow and related tools. Challenges include reducing image size (CUDA for
instance is very big) and supporting manylinux2010 (which is why it uses
devtoolset-7. This depends on external toolchains in TensorFlow's bazelrc).

They should have as few external dependencies as possible, and ideally could be
built to target any TensorFlow version consistently: whenever TensorFlow
releases, `master` gets frozen into a branch-specific directory. Ease of
maintenance is prioritized over image size.

Initial versions of the `devel` images are available at
[angersson/tensorflow-build](https://hub.docker.com/r/angersson/tensorflow-build).
You can build the images yourself like this:

```
$ DOCKER_BUILDKIT=1 docker build --target=devel --build-arg PYTHON_VERSION=python3.8 -t tensorflow-build-devel .
```

See `master/devel.user_tools/build_tf.sh` for how you can use these images to
build TensorFlow.
