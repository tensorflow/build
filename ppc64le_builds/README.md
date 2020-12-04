# ppc64le Builds

Dockerfiles and wheel build scripts for building TF on ppc64le.

Maintainer: @wdirons (IBM)

* * *

`cpu/Dockerfile.manylinux_2014` extends from the
quay.io/pypa/manylinux2014_ppc64le docker image and installs java, bazel (from
source), and the minimal required pip packages to build TensorFlow. It also adds
the jenkins userid necessary to work with Oregon State University's Open Source
Lab jenkins environment. `gpu/Dockerfile.manylinux_2014.cuda10_1` extends from
the cpu image and adds CUDA 10.1 and cuDNN 7.6.

The bash scripts are the equivalent of what is run in the TensorFlow builds done
with Jenkins (everything except the remote cache server). They can also be run
manually by cloning tensorflow and copying the script into the root of the
workspace.
