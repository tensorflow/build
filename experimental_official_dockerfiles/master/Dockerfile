################################################################################
FROM ubuntu:18.04 as resourcebuilder
################################################################################

COPY install_packages.sh install_packages.sh
COPY packages.build.txt packages.build.txt
RUN /install_packages.sh /packages.build.txt

# Build Python from source
# TODO replace with github pinned url
RUN curl https://pyenv.run | bash
ENV PATH /root/.pyenv/shims:/root/.pyenv/bin:$PATH
RUN pyenv install 3.6.9
RUN pyenv install 3.7.7
RUN pyenv install 3.8.2
RUN pyenv install 3.9.1

RUN git clone --depth=1 --single-branch --branch master https://github.com/tensorflow/tensorflow /tensorflow \
        && cd /tensorflow/tensorflow/tools/ci_build/devtoolset \
        && mv -t / fixlinks.sh build_devtoolset.sh rpm-patch.sh

# Set up a sysroot for glibc 2.12 / libstdc++ 4.4 / devtoolset-7 in /dt7.
RUN /build_devtoolset.sh devtoolset-7 /dt7 

################################################################################
FROM nvidia/cuda:11.0-base-ubuntu18.04 as devel
################################################################################

COPY --from=resourcebuilder /dt7 /dt7
COPY --from=resourcebuilder /root/.pyenv /root/.pyenv

COPY nvidia-ml.list /etc/apt/sources.list.d/
COPY bashrc /root/.bashrc
COPY install_packages.sh /install_packages.sh
COPY cleanup_cuda_install.sh /cleanup_cuda_install.sh
COPY packages.devel.txt /packages.devel.txt

# Install required development packages but delete unneeded CUDA bloat
RUN /install_packages.sh /packages.devel.txt && /cleanup_cuda_install.sh

# Install build tools: Bazelisk, Buildifier, and Buildozer
RUN wget https://github.com/bazelbuild/bazelisk/releases/download/v1.7.4/bazelisk-linux-amd64 -O /usr/local/bin/bazel && chmod +x /usr/local/bin/bazel
RUN wget https://github.com/bazelbuild/buildtools/releases/download/3.5.0/buildifier -O /usr/local/bin/buildifier && chmod +x /usr/local/bin/buildifier
RUN wget https://github.com/bazelbuild/buildtools/releases/download/3.5.0/buildozer -O /usr/local/bin/buildozer && chmod +x /usr/local/bin/buildozer

# Setup pyenv-virtualenv and virtual environments for build
COPY requirements.devel.txt /requirements.devel.txt
COPY setup_virtualenv.sh /setup_virtualenv.sh
RUN /setup_virtualenv.sh 3.8.2 tf-38 requirements.devel.txt
ENV PYENV_VERSION tf-38
ENV PATH /root/.pyenv/shims:/root/.pyenv/bin:$PATH
COPY tf_configure.bazelrc /tf_configure.bazelrc
COPY build_tf.sh /build_tf.sh
# RUN /setup_virtualenv.sh 3.6.9 tf-36 requirements.txt
# RUN /setup_virtualenv.sh 3.7.7 tf-37 requirements.txt
# RUN /setup_virtualenv.sh 3.8.2 tf-38 requirements.txt
# RUN /setup_virtualenv.sh 3.9.1 tf-39 requirements.txt

################################################################################
FROM resourcebuilder as onlydefaultpy
RUN cd /root/.pyenv/versions && rm -rf 3.6.9 3.7.7 3.9.1
FROM nvidia/cuda:11.0-cudnn8-runtime-ubuntu18.04 as runtime
################################################################################

COPY --from=base /usr/local/bin/bazel /usr/local/bin/bazel
COPY --from=onlydefaultpy /root/.pyenv /root/.pyenv
COPY bashrc /root/.bashrc
COPY requirements.runtime.txt /requirements.runtime.txt
COPY setup_virtualenv.sh /setup_virtualenv.sh

RUN /setup_virtualenv.sh 3.8.2 tf-38 requirements.runtime.txt
ENV PATH /root/.pyenv/shims:/root/.pyenv/bin:$PATH
ENV PYENV_VERSION tf-38
