#!/bin/bash

# ??? Magic ???

# Delete uneccessary static libraries, which we don't need for some reason.
find /usr/local/cuda-11.0/lib64/ -type f -name 'lib*_static.a' -not -name 'libcudart_static.a' -delete
rm /usr/lib/x86_64-linux-gnu/libcudnn_static_v8.a


# Link the libcuda stub to the location where tensorflow is searching for it and reconfigure
# dynamic linker run-time bindings
ln -s /usr/local/cuda/lib64/stubs/libcuda.so /usr/local/cuda/lib64/stubs/libcuda.so.1
echo "/usr/local/cuda/lib64/stubs" > /etc/ld.so.conf.d/z-cuda-stubs.conf
ldconfig
