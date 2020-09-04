# Dockerfiles for TensorFlow builds

## manylinux2014 builds
Run the below commands to create manylinux2014 build environment.    
```
docker build -t build/manylinux2014 -f Dockerfile.manylinux2014.cpu .
docker run -it build/manylinux2014:latest /bin/bash
```

Run the below commands to build TF.  
```
source scl_source enable devtoolset-7 rh-python36
git clone --branch=r2.1 --depth=1 https://github.com/tensorflow/tensorflow.git
cd tensorflow/
./configure
bazel build -c opt --cxxopt="-D_GLIBCXX_USE_CXX11_ABI=0" --verbose_failures //tensorflow/tools/pip_package:build_pip_package
```

## Distroless Dockerfiles
Distroless Dockerfiles for CPU (`Dockerfile.cpu`) and GPU (`Dockerfile.distroless`) are hosted in the [rivanna-docker repo (Research Computing, University of Virginia)](https://github.com/uvarc/rivanna-docker). Using the [MNIST benchmark](https://www.tensorflow.org/tutorials/quickstart/beginner), the containers were tested on UVA's HPC Rivanna cluster to have the same performance as the official ones.

Image size comparison:
| [Official](https://hub.docker.com/r/tensorflow/tensorflow/tags) | Size | [Distroless](https://hub.docker.com/r/uvarc/tensorflow/tags) | Size | Reduction |
|---|---|---|---|---|
| `2.3.0` | 582 MB | `2.3.0-cpu` | 227 MB | 61% |
| `2.3.0-gpu` | 1.44 GB | `2.3.0-distroless` | 1.18 GB | 18% |
| `nightly-gpu` | 2.27 GB | `2.4.0-distroless` | 1.47 GB | 35% |
