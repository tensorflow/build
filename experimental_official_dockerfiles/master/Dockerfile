################################################################################
FROM ubuntu:20.04 as builder
################################################################################

# Install devtoolset + python build dependencies
COPY setup.packages.sh setup.packages.sh
COPY builder.packages.txt builder.packages.txt
RUN /setup.packages.sh /builder.packages.txt

# Install devtoolset-7 in /dt7 with gclibc 2.12 and libstdc++ 4.4, for building
# manylinux2010-compatible packages. Scripts expect to be in the root directory
COPY devtoolset/fixlinks.sh /fixlinks.sh
COPY devtoolset/rpm-patch.sh /rpm-patch.sh
COPY devtoolset/build_devtoolset.sh /build_devtoolset.sh
RUN /build_devtoolset.sh devtoolset-7 /dt7 

# Build and install specified Python from source with pyenv
# Install script is pinned to a specific commit (the latest as of 2021-04-20)
ARG PYENV_VERSION
RUN curl https://raw.githubusercontent.com/pyenv/pyenv-installer/dd3f7d0914c5b4a416ca71ffabdf2954f2021596/bin/pyenv-installer | bash
ENV PATH /root/.pyenv/shims:/root/.pyenv/bin:$PATH
RUN pyenv install $PYENV_VERSION

################################################################################
FROM nvidia/cuda:11.2.1-base-ubuntu20.04 as devel
################################################################################

COPY --from=builder /dt7 /dt7
COPY --from=builder /root/.pyenv /root/.pyenv

# Install required development packages but delete unneeded CUDA bloat
# CUDA must be cleaned up in the same command to prevent Docker layer bloating
COPY nvidia-ml.list /etc/apt/sources.list.d/
COPY setup.packages.sh /setup.packages.sh
COPY setup.cuda.sh /setup.cuda.sh
COPY devel.packages.txt /devel.packages.txt
RUN /setup.packages.sh /devel.packages.txt && /setup.cuda.sh

# Install various tools.
# - bats: bash unit testing framework
# - bazelisk: always use the correct bazel version
# - buildifier: clean bazel build deps
# - buildozer: clean bazel build deps
RUN git clone https://github.com/bats-core/bats-core.git && bats-core/install.sh /usr/local
RUN wget https://github.com/bazelbuild/bazelisk/releases/download/v1.7.4/bazelisk-linux-amd64 -O /usr/local/bin/bazel && chmod +x /usr/local/bin/bazel
RUN wget https://github.com/bazelbuild/buildtools/releases/download/3.5.0/buildifier -O /usr/local/bin/buildifier && chmod +x /usr/local/bin/buildifier
RUN wget https://github.com/bazelbuild/buildtools/releases/download/3.5.0/buildozer -O /usr/local/bin/buildozer && chmod +x /usr/local/bin/buildozer

# Setup Python environment
COPY bashrc /root/.bashrc
ARG PYENV_VERSION
COPY devel.requirements.txt /devel.requirements.txt
COPY setup.virtualenv.sh /setup.virtualenv.sh
ENV PATH /root/.pyenv/shims:/root/.pyenv/bin:$PATH
RUN /setup.virtualenv.sh $PYENV_VERSION tensorflow devel.requirements.txt
ENV PYENV_VERSION tensorflow

# Setup testing stuff
COPY devel.bazelrc /devel.bazelrc
COPY devel.build_tf.sh /devel.build_tf.sh
COPY devel.build_addons.sh /devel.build_addons.sh
COPY devel.preliminary.bats /devel.preliminary.bats

################################################################################
FROM nvidia/cuda:11.2.1-cudnn8-runtime-ubuntu20.04 as runtime
################################################################################

COPY --from=builder /root/.pyenv /root/.pyenv
COPY bashrc /root/.bashrc
COPY runtime.requirements.txt /runtime.requirements.txt
COPY setup.virtualenv.sh /setup.virtualenv.sh

ARG PYENV_VERSION
RUN /setup.virtualenv.sh $PYENV_VERSION tensorflow runtime.requirements.txt
ENV PATH /root/.pyenv/shims:/root/.pyenv/bin:$PATH
ENV PYENV_VERSION tensorflow
