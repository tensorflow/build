#!/usr/bin/env bash
#
# setup.cuda.sh: Clean up and prepare the CUDA installation on the container.
# TODO(@perfinion) Review this file

# Delete uneccessary static libraries
find /usr/local/cuda-*/lib*/ -type f -name 'lib*_static.a' -not -name 'libcudart_static.a' -delete
rm /usr/lib/x86_64-linux-gnu/libcudnn_static_v*.a


# Link the libcuda stub to the location where tensorflow is searching for it and
# reconfigure dynamic linker run-time bindings
ln -s /usr/local/cuda/lib64/stubs/libcuda.so /usr/local/cuda/lib64/stubs/libcuda.so.1
echo "/usr/local/cuda/lib64/stubs" > /etc/ld.so.conf.d/z-cuda-stubs.conf
ldconfig
