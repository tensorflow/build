# Copyright 2022 The TensorFlow Authors. All Rights Reserved.
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


FROM golang:1.21-bookworm

# 1. Install the TensorFlow C Library (v2.14.0).
RUN curl -L https://storage.googleapis.com/tensorflow/libtensorflow/libtensorflow-cpu-linux-$(uname -m)-2.14.0.tar.gz \
    | tar xz --directory /usr/local \
    && ldconfig

# 2. Install the Protocol Buffers Library and Compiler.
RUN apt-get update && apt-get -y install --no-install-recommends \
    libprotobuf-dev \
    protobuf-compiler

# 3. Install and Setup the TensorFlow Go API.
RUN git clone --branch=v2.14.0 https://github.com/tensorflow/tensorflow.git /go/src/github.com/tensorflow/tensorflow \
    && cd /go/src/github.com/tensorflow/tensorflow \
    && go mod init github.com/tensorflow/tensorflow \
    && sed -i '4 i option go_package = "github.com\/tensorflow\/tensorflow\/tensorflow\/go\/core\/framework\/dataset_go_proto";' tensorflow/core/framework/dataset.proto \
    && sed -i '9 c option go_package = "github.com\/tensorflow\/tensorflow\/tensorflow\/go\/core\/framework\/graph_debug_info_go_proto";' tensorflow/core/framework/graph_debug_info.proto \
    && sed -i '4 i option go_package = "github.com\/tensorflow\/tensorflow\/tensorflow\/go\/core\/framework\/optimized_function_graph_go_proto";' tensorflow/core/framework/optimized_function_graph.proto \
    && sed -i '4 i option go_package = "github.com\/google\/tsl\/tsl\/go\/core\/protobuf\/for_core_protos_go_proto";' tensorflow/tsl/protobuf/test_log.proto \
    && sed -i '5d' tensorflow/core/protobuf/autotuning.proto \
    && sed -i '71d;72d' tensorflow/go/genop/generate.sh \
    && sed -i '71 i \    ${TF_DIR}\/tensorflow\/tsl\/protobuf\/*.proto \\' tensorflow/go/genop/generate.sh \
    && sed -i '72 i \    ${TF_DIR}\/tensorflow\/compiler\/xla\/stream_executor\/dnn.proto; do' tensorflow/go/genop/generate.sh \
    && (cd tensorflow/go/op && go generate) \
    && go mod edit -require github.com/google/tsl@v0.0.0+incompatible \
    && go mod edit -replace github.com/google/tsl=/go/src/github.com/google/tsl \
    && (cd /go/src/github.com/google/tsl && go mod init github.com/google/tsl && go mod tidy) \
    && go mod tidy \
    && go test ./...

# Build the Example Program.
WORKDIR /example-program
COPY hello_tf.go .
RUN go mod init app \
    && go mod edit -require github.com/google/tsl@v0.0.0+incompatible \
    && go mod edit -require github.com/tensorflow/tensorflow@v2.14.0+incompatible \
    && go mod edit -replace github.com/google/tsl=/go/src/github.com/google/tsl \
    && go mod edit -replace github.com/tensorflow/tensorflow=/go/src/github.com/tensorflow/tensorflow \
    && go mod tidy \
    && go build


ENTRYPOINT ["/example-program/app"]
