# Copyright 2021 The TensorFlow Authors. All Rights Reserved.
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


FROM golang:1.16-buster

# 1. Install the TensorFlow C library (v2.6.0)
RUN curl -L https://storage.googleapis.com/tensorflow/libtensorflow/libtensorflow-cpu-linux-$(uname -m)-2.6.0.tar.gz \
    | tar xz --directory /usr/local \
    && ldconfig

# 2. Install the Protocol Buffer Compiler (Protoc)
RUN apt-get update && apt-get -y install --no-install-recommends \
    libprotobuf-dev \
    protobuf-compiler 

# 3. Install and setup the Tensorflow Go API
RUN git clone --branch v2.6.0 https://github.com/tensorflow/tensorflow.git /go/src/github.com/tensorflow/tensorflow \
    && cd /go/src/github.com/tensorflow/tensorflow \
    && go mod init github.com/tensorflow/tensorflow \
    && go get google.golang.org/protobuf/proto \
    && cd tensorflow/go \
    && (cd genop && go generate) \
    && mv vendor/github.com/tensorflow/tensorflow/tensorflow/go/* . \
    && (cd op && go generate) \
    && go mod tidy \
    && go test ./...


# Build example program
WORKDIR /example-program
COPY hello_tf.go .
RUN go mod init app \
    && go mod edit -require github.com/tensorflow/tensorflow@v2.6.0+incompatible \
    && go mod edit -replace github.com/tensorflow/tensorflow=/go/src/github.com/tensorflow/tensorflow \
    && go mod tidy \
    && go build


ENTRYPOINT ["/example-program/app"]
