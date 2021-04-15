################################################################################
FROM ubuntu:20.04 as builder
################################################################################

COPY setup.packages.sh setup.packages.sh
COPY builder.packages.txt builder.packages.txt
RUN /setup.packages.sh /builder.packages.txt

# Build Python from source
# TODO replace with github pinned url
RUN curl https://pyenv.run | bash
ENV PATH /root/.pyenv/shims:/root/.pyenv/bin:$PATH
# RUN pyenv install 3.6.9
#RUN pyenv install 3.7.7
RUN pyenv install 3.8.2
#RUN pyenv install 3.9.1

COPY devtoolset/fixlinks.sh /fixlinks.sh
COPY devtoolset/rpm-patch.sh /rpm-patch.sh
COPY devtoolset/build_devtoolset.sh /build_devtoolset.sh

# Set up a sysroot for glibc 2.12 / libstdc++ 4.4 / devtoolset-7 in /dt7.
RUN /build_devtoolset.sh devtoolset-7 /dt7 

################################################################################
FROM nvidia/cuda:11.2.1-base-ubuntu20.04 as devel
################################################################################

COPY --from=builder /dt7 /dt7
COPY --from=builder /root/.pyenv /root/.pyenv

COPY nvidia-ml.list /etc/apt/sources.list.d/
COPY bashrc /root/.bashrc
COPY setup.packages.sh /setup.packages.sh
COPY setup.cuda.sh /setup.cuda.sh
COPY devel.packages.txt /devel.packages.txt

# Install required development packages but delete unneeded CUDA bloat
RUN /setup.packages.sh /devel.packages.txt && /setup.cuda.sh

# Install build tools: Bazelisk, Buildifier, and Buildozer
RUN wget https://github.com/bazelbuild/bazelisk/releases/download/v1.7.4/bazelisk-linux-amd64 -O /usr/local/bin/bazel && chmod +x /usr/local/bin/bazel
RUN wget https://github.com/bazelbuild/buildtools/releases/download/3.5.0/buildifier -O /usr/local/bin/buildifier && chmod +x /usr/local/bin/buildifier
RUN wget https://github.com/bazelbuild/buildtools/releases/download/3.5.0/buildozer -O /usr/local/bin/buildozer && chmod +x /usr/local/bin/buildozer

# Setup pyenv-virtualenv and virtual environments for build
COPY devel.requirements.txt /devel.requirements.txt
COPY setup.virtualenv.sh /setup.virtualenv.sh
RUN /setup.virtualenv.sh 3.8.2 tf-38 devel.requirements.txt
ENV PYENV_VERSION tf-38
ENV PATH /root/.pyenv/shims:/root/.pyenv/bin:$PATH
COPY devel.bazelrc /devel.bazelrc
COPY devel.build_tf.sh /devel.build_tf.sh
# RUN /setup.virtualenv.sh 3.6.9 tf-36 requirements.txt
# RUN /setup.virtualenv.sh 3.7.7 tf-37 requirements.txt
# RUN /setup.virtualenv.sh 3.8.2 tf-38 requirements.txt
# RUN /setup.virtualenv.sh 3.9.1 tf-39 requirements.txt


################################################################################
FROM builder as onlydefaultpy
RUN cd /root/.pyenv/versions && rm -rf 3.6.9 3.7.7 3.9.1
FROM nvidia/cuda:11.2.1-cudnn8-runtime-ubuntu20.04 as runtime
################################################################################

COPY --from=base /usr/local/bin/bazel /usr/local/bin/bazel
COPY --from=onlydefaultpy /root/.pyenv /root/.pyenv
COPY bashrc /root/.bashrc
COPY runtime.requirements.txt /runtime.requirements.txt
COPY setup.virtualenv.sh /setup.virtualenv.sh

RUN /setup.virtualenv.sh 3.8.2 tf-38 runtime.requirements.txt
ENV PATH /root/.pyenv/shims:/root/.pyenv/bin:$PATH
ENV PYENV_VERSION tf-38
