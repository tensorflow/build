# Dockerfiles for TensorFlow builds

## manylinux2014 builds
Run the below commands to create manylinux2014 build environment.    
```
docker build -t build/manylinux2014 -f Dockerfile.manylinux2014.cpu .
docker run -it build/manylinux2014:latest /bin/bash

Run the below commands to build TF.  
```
source scl_source enable devtoolset-7 rh-python36
git clone --branch=r2.1 --depth=1 https://github.com/tensorflow/tensorflow.git
cd tensorflow/
./configure
bazel build -c opt --cxxopt="-D_GLIBCXX_USE_CXX11_ABI=0" --verbose_failures //tensorflow/tools/pip_package:build_pip_package
```