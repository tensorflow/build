# Copyright 2019 The TensorFlow Authors. All Rights Reserved.
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

FROM nvidia/cuda:12.3.0-base-ubuntu22.04 as base
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG C.UTF-8

COPY setup.sources.sh /setup.sources.sh
COPY setup.packages.sh /setup.packages.sh
COPY gpu.packages.txt /gpu.packages.txt
RUN /setup.sources.sh
RUN /setup.packages.sh /gpu.packages.txt

ARG PYTHON_VERSION=python3.11
ARG TENSORFLOW_PACKAGE=tf-nightly
COPY setup.python.sh /setup.python.sh
COPY gpu.requirements.txt /gpu.requirements.txt
RUN /setup.python.sh $PYTHON_VERSION /gpu.requirements.txt
RUN pip install --no-cache-dir ${TENSORFLOW_PACKAGE} 

COPY setup.cuda.sh /setup.cuda.sh
RUN /setup.cuda.sh

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

ENV LD_LIBRARY_PATH /usr/local/cuda/lib64/stubs/:$LD_LIBRARY_PATH
COPY test.import_gpu.sh /test.import_gpu.sh
RUN /test.import_gpu.sh
