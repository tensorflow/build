# Copyright 2024 The TensorFlow Authors. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ============================================================================

FROM ubuntu:22.04 as base
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG C.UTF-8

COPY setup.sources.sh /setup.sources.sh
COPY setup.packages.sh /setup.packages.sh
COPY tpu.packages.txt /tpu.packages.txt
RUN /setup.sources.sh
RUN /setup.packages.sh /tpu.packages.txt


ARG PYTHON_VERSION=python3.11
ARG TENSORFLOW_PACKAGE=tf-nightly-tpu
COPY setup.python.sh /setup.python.sh
COPY cpu.requirements.txt /tpu.requirements.txt
RUN /setup.python.sh $PYTHON_VERSION /tpu.requirements.txt
RUN pip install --no-cache-dir ${TENSORFLOW_PACKAGE} -f https://storage.googleapis.com/libtpu-tf-releases/index.html 

COPY bashrc /etc/bash.bashrc
RUN chmod a+rwx /etc/bash.bashrc

FROM base as jupyter

COPY jupyter.requirements.txt /jupyter.requirements.txt
COPY setup.jupyter.sh /setup.jupyter.sh
RUN python3 -m pip install --no-cache-dir -r /jupyter.requirements.txt -U
RUN /setup.jupyter.sh
COPY jupyter.readme.md /tf/tensorflow-tutorials/README.md

WORKDIR /tf
EXPOSE 8888

CMD ["bash", "-c", "source /etc/bash.bashrc && jupyter notebook --notebook-dir=/tf --ip 0.0.0.0 --no-browser --allow-root"]

FROM base as test

COPY test.import_tpu.sh /test.import_tpu.sh
RUN /test.import_tpu.sh
