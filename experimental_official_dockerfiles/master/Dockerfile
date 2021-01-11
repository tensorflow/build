# useful for team: build gpu, cpu for specific versions, w/ any Py version; also run tests etc
# for users: have same build env as us
# support usability over size 
# let users run TF easily
# use requirements.txt instead of scripts pls
# prob use bazelisk
# maybe pyenv instead of build_and_install_python ? idk, would be nice

FROM nvidia/cuda:11.0-cudnn8-devel-ubuntu18.04 as builder

ENV DEBIAN_FRONTEND=noninteractive
# Tools to build Python from source and build devtoolset for manylinux2010
COPY install_packages.sh install_packages.sh
COPY packages.build.txt packages.build.txt
RUN /install_packages /packages.build.txt
RUN git clone https://github.com/tensorflow/tensorflow /tensorflow && cd /tensorflow/tools/ci_build/devtoolset && mv -t / fixlinks.sh build_devtoolset.sh rpm-patch.sh

# Set up a sysroot for glibc 2.12 / libstdc++ 4.4 / devtoolset-7 in /dt7.
RUN /build_devtoolset.sh devtoolset-7 /dt7
# Set up a sysroot for glibc 2.12 / libstdc++ 4.4 / devtoolset-8 in /dt8.
RUN /build_devtoolset.sh devtoolset-8 /dt8 

# Build Python from source
RUN curl https://pyenv.run | bash
ENV PATH /root/.pyenv/shims:/root/.pyenv/bin:$PATH
RUN pyenv install 3.6.9
RUN pyenv install 3.7.7
RUN pyenv install 3.8.2

FROM nvidia/cuda:11.0-cudnn8-devel-ubuntu18.04 as base
COPY --from=devtoolset /dt7 /dt7
COPY --from=devtoolset /dt8 /dt8
COPY --from=devtoolset /root/.pyenv /root/.pyenv
COPY nvidia-ml.list /etc/apt/sources.list.d/
COPY bash_profile /root/.bash_profile

# Install deps for building TF
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential \
        libnvinfer7=7.1.3-1+cuda11.0 \
        libnvinfer-dev=7.1.3-1+cuda11.0 \
        libnvinfer-plugin7=7.1.3-1+cuda11.0 \
        libnvinfer-plugin-dev=7.1.3-1+cuda11.0 \
        libcurl3-dev \
        libfreetype6-dev \
        libhdf5-serial-dev \
        libzmq3-dev \
        pkg-config \
        rsync \
        software-properties-common \
        unzip \
        zip \
        zlib1g-dev \
        wget \
        curl \
        git \
         && \
        rm -rf /var/lib/apt/lists/*

# Bazelisk
RUN wget https://github.com/bazelbuild/bazelisk/releases/download/v1.7.4/bazelisk-linux-amd64 -O /usr/local/bin/bazel && chmod +x /usr/local/bin/bazel
RUN git clone https://github.com/pyenv/pyenv-virtualenv.git $(pyenv root)/plugins/pyenv-virtualenv


# -------------------------------------------------------------------
FROM base as with_tensorflow
RUN python3 -m pip install --no-cache-dir ${TF_PACKAGE}${TF_PACKAGE_VERSION:+==${TF_PACKAGE_VERSION}}

# -------------------------------------------------------------------

FROM base as devtoolset
ADD devtoolset/fixlinks.sh fixlinks.sh
ADD devtoolset/build_devtoolset.sh build_devtoolset.sh
ADD devtoolset/rpm-patch.sh rpm-patch.sh

# Set up a sysroot for glibc 2.12 / libstdc++ 4.4 / devtoolset-7 in /dt7.
RUN /build_devtoolset.sh devtoolset-7 /dt7
# Set up a sysroot for glibc 2.12 / libstdc++ 4.4 / devtoolset-8 in /dt8.
RUN /build_devtoolset.sh devtoolset-8 /dt8

# FROM nvidia/cuda${ARCH:+-$ARCH}:${CUDA}-base-ubuntu${UBUNTU_VERSION} as base
COPY --from=devtoolset /dt7 /dt7
COPY --from=devtoolset /dt8 /dt8

RUN /install/install_bootstrap_deb_packages.sh
RUN /install/install_deb_packages.sh
RUN /install/install_clang.sh
RUN /install/install_bazel.sh
RUN /install/install_buildifier.sh
RUN /install/install_pip_packages.sh
RUN /install/install_auditwheel.sh

ENV TF_NEED_CUDA=1

COPY install/install_pip_packages_by_version.sh /install/
RUN /install/install_pip_packages_by_version.sh "/usr/local/bin/pip3.5"
RUN /install/install_pip_packages_by_version.sh "/usr/local/bin/pip3.8"
RUN /install/install_pip_packages_by_version.sh "/usr/local/bin/pip3.6"
RUN /install/install_pip_packages_by_version.sh "/usr/local/bin/pip3.7"
