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


FROM golang:1.22-bookworm

# 1. Install the TensorFlow C Library (v2.17.0).
RUN curl -L https://storage.googleapis.com/tensorflow/versions/2.17.0/libtensorflow-cpu-linux-$(uname -m).tar.gz \
    | tar xz --directory /usr/local \
    && ln -s external/local_tsl/tsl /usr/local/include/tsl \
    && ldconfig

# 2. Install the Protocol Buffers Library and Compiler.
RUN apt-get update && apt-get -y install --no-install-recommends \
    libprotobuf-dev \
    protobuf-compiler

# 3. Install and Setup the TensorFlow Go API.
RUN git clone --branch=v2.17.0 https://github.com/tensorflow/tensorflow.git /go/src/github.com/tensorflow/tensorflow \
    && cd /go/src/github.com/tensorflow/tensorflow \
    && go mod init github.com/tensorflow/tensorflow \
    && sed -i '4 i option go_package = "github.com\/tensorflow\/tensorflow\/tensorflow\/go\/core\/framework\/dataset_go_proto";' tensorflow/core/framework/dataset.proto \
    && sed -i '9 c option go_package = "github.com\/tensorflow\/tensorflow\/tensorflow\/go\/core\/framework\/graph_debug_info_go_proto";' tensorflow/core/framework/graph_debug_info.proto \
    && sed -i '4 i option go_package = "github.com\/tensorflow\/tensorflow\/tensorflow\/go\/core\/framework\/optimized_function_graph_go_proto";' tensorflow/core/framework/optimized_function_graph.proto \
    && sed -i '5 c option go_package = "github.com\/google\/tsl\/tsl\/go_proto";' third_party/xla/third_party/tsl/tsl/protobuf/bfc_memory_map.proto \
    && sed -i '5 c option go_package = "github.com\/google\/tsl\/tsl\/go_proto";' third_party/xla/third_party/tsl/tsl/protobuf/coordination_config.proto \
    && sed -i '7 c option go_package = "github.com\/google\/tsl\/tsl\/go_proto";' third_party/xla/third_party/tsl/tsl/protobuf/coordination_service.proto \
    && sed -i '6 c option go_package = "github.com\/google\/tsl\/tsl\/go_proto";' third_party/xla/third_party/tsl/tsl/protobuf/distributed_runtime_payloads.proto \
    && sed -i '8 c option go_package = "github.com\/google\/tsl\/tsl\/go_proto";' third_party/xla/third_party/tsl/tsl/protobuf/dnn.proto \
    && sed -i '12 c option go_package = "github.com\/google\/tsl\/tsl\/go_proto";' third_party/xla/third_party/tsl/tsl/protobuf/error_codes.proto \
    && sed -i '8 c option go_package = "github.com\/google\/tsl\/tsl\/go_proto";' third_party/xla/third_party/tsl/tsl/protobuf/histogram.proto \
    && sed -i '5 c option go_package = "github.com\/google\/tsl\/tsl\/go_proto";' third_party/xla/third_party/tsl/tsl/protobuf/rpc_options.proto \
    && sed -i '10 c option go_package = "github.com\/google\/tsl\/tsl\/go_proto";' third_party/xla/third_party/tsl/tsl/protobuf/status.proto \
    && sed -i '13 i option go_package = "github.com\/google\/tsl\/tsl\/go_proto";' third_party/xla/third_party/tsl/tsl/protobuf/test_log.proto \
    && sed -i '71d;72d' tensorflow/go/genop/generate.sh \
    && sed -i '71 i \    ${TF_DIR}\/third_party\/xla\/xla\/autotuning.proto \\' tensorflow/go/genop/generate.sh \
    && sed -i '72 i \    ${TF_DIR}\/third_party\/xla\/third_party\/tsl\/tsl\/protobuf\/*.proto; do \\' tensorflow/go/genop/generate.sh \
    && sed -i '74 i \    -I ${TF_DIR}/third_party/xla/third_party/tsl \\' tensorflow/go/genop/generate.sh \
    && sed -i '75 i \    -I ${TF_DIR}/third_party/xla \\' tensorflow/go/genop/generate.sh \
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
    && go mod edit -require github.com/tensorflow/tensorflow@v2.17.0+incompatible \
    && go mod edit -replace github.com/google/tsl=/go/src/github.com/google/tsl \
    && go mod edit -replace github.com/tensorflow/tensorflow=/go/src/github.com/tensorflow/tensorflow \
    && go mod tidy \
    && go build


ENTRYPOINT ["/example-program/app"]
