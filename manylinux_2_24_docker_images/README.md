# Manylinux_2_24 Docker Images

`manylinux_2_24` build environment for TensorFlow packages.

Maintainer: @sub-mod (Red Hat)

* * *

Run the below commands to create a manylinux2014 build environment.    
```
docker build -t build/manylinux_2_24 -f Dockerfile.manylinux_2_24.cpu .
docker run -it build/manylinux_2_24:latest /bin/bash
```

Run the below commands to build TF.  
```
source ./venv/bin/activate
git clone --branch=r2.6 --depth=1 https://github.com/tensorflow/tensorflow.git
cd tensorflow/
./configure
bazel build -c opt --verbose_failures //tensorflow/tools/pip_package:build_pip_package
```

