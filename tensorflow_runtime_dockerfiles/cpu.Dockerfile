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

FROM ubuntu:22.04 as base
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG C.UTF-8

COPY setup.sources.sh /setup.sources.sh
COPY setup.packages.sh /setup.packages.sh
COPY cpu.packages.txt /cpu.packages.txt
# set up apt sources (must be done as root):
RUN /setup.sources.sh
# install required packages (must be done as root):
RUN /setup.packages.sh /cpu.packages.txt


ARG PYTHON_VERSION=python3.11
ARG TENSORFLOW_PACKAGE=tf-nightly
ARG TENSORFLOW_USER=tfuser
ARG TENSORFLOW_GROUP=tensorflow
ARG TENSORFLOW_UID=2234
ARG TENSORFLOW_GID=5567
ARG TENSORFLOW_NOTEBOOK_DIR=/home/${TENSORFLOW_USER}/notebooks
ENV TENSORFLOW_USER=${TENSORFLOW_USER}
ENV TENSORFLOW_GROUP=${TENSORFLOW_GROUP}
ENV TENSORFLOW_UID=${TENSORFLOW_UID}
ENV TENSORFLOW_GID=${TENSORFLOW_GID}
ENV TENSORFLOW_NOTEBOOK_DIR=${TENSORFLOW_NOTEBOOK_DIR}
COPY setup.python.sh /setup.python.sh
COPY cpu.requirements.txt /cpu.requirements.txt
# install python (must be done as root):
RUN /setup.python.sh $PYTHON_VERSION /cpu.requirements.txt
COPY bashrc /etc/bash.bashrc
RUN chmod a+rwx /etc/bash.bashrc
# create and setup user ${TENSORFLOW_USER}:${TENSORFLOW_GROUP} (must be done as root):
COPY setup.tensorflow.user.sh /setup.tensorflow.user.sh
RUN /setup.tensorflow.user.sh && \
    mkdir -p /home/${TENSORFLOW_USER}/.local && \
    chown -R ${TENSORFLOW_USER}:${TENSORFLOW_GROUP} /home/${TENSORFLOW_USER}/.local
ENV PATH="${PATH}:/home/${TENSORFLOW_USER}/.local/bin"

# the rest of the commands is run by TENSORFLOW_USER
USER ${TENSORFLOW_USER}

RUN pip install --no-cache-dir ${TENSORFLOW_PACKAGE}


FROM base as jupyter

USER ${TENSORFLOW_USER}
# install and setup jupyter (should be done as TENSORFLOW_USER):
COPY --chown=${TENSORFLOW_USER}:${TENSORFLOW_GROUP} jupyter.requirements.txt /jupyter.requirements.txt
COPY --chown=${TENSORFLOW_USER}:${TENSORFLOW_GROUP} setup.jupyter.sh /setup.jupyter.sh
RUN python3 -m pip install --no-cache-dir -r /jupyter.requirements.txt -U
RUN /setup.jupyter.sh
COPY --chown=${TENSORFLOW_USER}:${TENSORFLOW_GROUP} jupyter.readme.md ${TENSORFLOW_NOTEBOOK_DIR}/tensorflow-tutorials/README.md



WORKDIR ${TENSORFLOW_NOTEBOOK_DIR}
EXPOSE 8888

# finally start jupyter (this should be done as TENSORFLOW_USER):
CMD ["bash", "-c", "source /etc/bash.bashrc && jupyter notebook --notebook-dir=${TENSORFLOW_NOTEBOOK_DIR} --ip 0.0.0.0 --no-browser --allow-root"]

FROM base as test

COPY test.import_cpu.sh /test.import_cpu.sh
RUN /test.import_cpu.sh
