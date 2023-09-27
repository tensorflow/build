# Golang Install Guide 

Documentation for installing the Go bindings for TensorFlow.

Maintainer: @wamuir

* * *

## About

TensorFlow provides a
[Go API](https://pkg.go.dev/github.com/tensorflow/tensorflow/tensorflow/go)
particularly useful for loading models created with Python and running them
within a Go application.

**Important**: TensorFlow for Go is no longer supported by the TensorFlow team.
The TensorFlow Go API is also *not* covered by the TensorFlow
[API stability guarantees](https://www.tensorflow.org/guide/versions).

### Supported Platforms

The Go bindings for TensorFlow work on the following systems, and likely others:

* Linux, 64-bit, x86
* macOS, Version 10.12.6 (Sierra) or higher

### Installation

Install the TensorFlow Go API from a community build (compatible with `go get`)
or from source.

## Community Build

> Note: the Go bindings depend on
> [libtensorflow](https://www.tensorflow.org/install/lang_c), which should be
> downloaded (or compiled) and installed first.


A community build, Graft, contains nightly and release builds of the Go
language bindings to the TensorFlow C API, including Go-compiled TensorFlow
protocol buffers and generated Go wrappers for TensorFlow operations. This
community build can be fetched using `go get`.

After installing [libtensorflow](https://www.tensorflow.org/install/lang_c),
use Graft exactly as you would use the Go bindings found in the main TensorFlow
repo, and with one of the following import statements:


| TensorFlow C API          | Graft                                                                                               |
| :------------------------ | :-------------------------------------------------------------------------------------------------- |
| TensorFlow Release 2.14.0 | [`go get github.com/wamuir/graft/tensorflow@v0.6.0`](https://github.com/wamuir/graft/tree/v0.6.0)   |
| TensorFlow Release 2.13.1 | [`go get github.com/wamuir/graft/tensorflow@v0.5.1`](https://github.com/wamuir/graft/tree/v0.5.1)   |
| TensorFlow Nightly        | [`go get github.com/wamuir/graft/tensorflow@nightly`](https://github.com/wamuir/graft/tree/nightly) |


## Build from Source

<details>
<summary>Click to expand</summary>

> Note: these build instructions are specific to TensorFlow 2.14.0

### 1. Install the TensorFlow C Library

Install the [TensorFlow C library](https://www.tensorflow.org/install/lang_c). This
library is required for use of the TensorFlow Go package at runtime. For example,
on Linux (64-bit, x86):

  ```sh
  $ curl -L https://storage.googleapis.com/tensorflow/libtensorflow/libtensorflow-cpu-linux-x86_64-2.14.0.tar.gz | tar xz --directory /usr/local
  $ ldconfig
  ```

### 2. Install the Protocol Buffers Library and Compiler

Install the [protocol buffers library and compiler](https://developers.google.com/protocol-buffers).
The compiler and well-known proto type files from the library are required
during installation of the Go bindings.

- Linux, using `apt` or `apt-get`, for example:

  ```sh
  $ apt install libprotobuf-dev protobuf-compiler
  ```

- MacOS, using [Homebrew](https://brew.sh/):

  ```sh
  $ brew install protobuf
  ```

### 3. Install and Setup the TensorFlow Go API

***The use of `go get` is not currently supported for installation of the TensorFlow Go API.
Instead, follow these instructions.***

- First, note the location of your Go workspace. The remaining installation
  steps must be performed inside your Go workspace.

  ```sh
  $ go env GOPATH
  ```

- Clone the TensorFlow source repository, substituting the location of your Go
  workspace for `/go` in the command below.

  ```sh
  $ git clone --branch v2.14.0 https://github.com/tensorflow/tensorflow.git /go/src/github.com/tensorflow/tensorflow
  ```

- Change the working directory to the base of the cloned TensorFlow repository,
  substituting the the location of your Go workspace for `/go` in the command
  below.
 
   ```sh
   $ cd /go/src/github.com/tensorflow/tensorflow
   ```

- Initialize a new go.mod file.

   ```sh
   $ go mod init github.com/tensorflow/tensorflow
   ```

- Patch protos to declare Go package.

   ```sh
   $ sed -i '4 i option go_package = "github.com\/tensorflow\/tensorflow\/tensorflow\/go\/core\/framework\/dataset_go_proto";' tensorflow/core/framework/dataset.proto
   $ sed -i '9 c option go_package = "github.com\/tensorflow\/tensorflow\/tensorflow\/go\/core\/framework\/graph_debug_info_go_proto";' tensorflow/core/framework/graph_debug_info.proto
   $ sed -i '4 i option go_package = "github.com\/tensorflow\/tensorflow\/tensorflow\/go\/core\/framework\/optimized_function_graph_go_proto";' tensorflow/core/framework/optimized_function_graph.proto
   $ sed -i '4 i option go_package = "github.com\/google\/tsl\/tsl\/go\/core\/protobuf\/for_core_protos_go_proto";' tensorflow/tsl/protobuf/test_log.proto
   $ sed -i '5d' tensorflow/core/protobuf/autotuning.proto
   ```

- Patch tensorflow/go/genop to generate TF and TSL protobufs.

   ```sh
   $ sed -i '71d;72d' tensorflow/go/genop/generate.sh
   $ sed -i '71 i \    ${TF_DIR}\/tensorflow\/tsl\/protobuf\/*.proto \\' tensorflow/go/genop/generate.sh
   $ sed -i '72 i \    ${TF_DIR}\/tensorflow\/compiler\/xla\/stream_executor\/dnn.proto; do' tensorflow/go/genop/generate.sh
   ```

- Generate wrappers and protocol buffers.

   ```sh
   $ (cd tensorflow/go/op && go generate)
   ```

- Use Go Mod's `replace` directive to locate TSL protos.

   ```sh
   $ go mod edit -require github.com/google/tsl@v0.0.0+incompatible
   $ go mod edit -replace github.com/google/tsl=/go/src/github.com/google/tsl
   ```

- Initialize a new go.mod for TSL and add dependencies.

   ```sh
   $ (cd /go/src/github.com/google/tsl && go mod init github.com/google/tsl && go mod tidy)
   ```

- Add missing modules.

   ```sh
   $ go mod tidy
   ```

- Test the installation.
   ```sh
   $ go test ./...
   ``` 


## Usage

### Applications must use Go Mod's `replace` directive

The `replace` directive instructs Go to use the local installation and must be
added to `go.mod` for every Go module that depends on the API.  Point the
replace directive to the location within your Go workspace where you [installed
the API](#installation-and-setup), substituting the location of your Go
workspace for `/go` in the command below:

```sh
$ go mod init hello-world
$ go mod edit -require github.com/google/tsl@v0.0.0+incompatible
$ go mod edit -require github.com/tensorflow/tensorflow@v2.14.0+incompatible
$ go mod edit -replace github.com/google/tsl=/go/src/github.com/google/tsl
$ go mod edit -replace github.com/tensorflow/tensorflow=/go/src/github.com/tensorflow/tensorflow
$ go mod tidy
```


### Example program

With the TensorFlow Go API [installed](#installation-and-setup), create an
example program with the following source code (`hello_tf.go`):

```go
package main

import (
	tf "github.com/tensorflow/tensorflow/tensorflow/go"
	"github.com/tensorflow/tensorflow/tensorflow/go/op"
	"fmt"
)

func main() {
	// Construct a graph with an operation that produces a string constant.
	s := op.NewScope()
	c := op.Const(s, "Hello from TensorFlow version " + tf.Version())
	graph, err := s.Finalize()
	if err != nil {
		panic(err)
	}

	// Execute the graph in a session.
	sess, err := tf.NewSession(graph, nil)
	if err != nil {
		panic(err)
	}
	output, err := sess.Run(nil, []tf.Output{c}, nil)
	if err != nil {
		panic(err)
	}
	fmt.Println(output[0].Value())
}
```

#### Initialize go.mod for the example program:

```sh
$ go mod init app
$ go mod edit -require github.com/google/tsl@v0.0.0+incompatible
$ go mod edit -require github.com/tensorflow/tensorflow@v2.14.0+incompatible
$ go mod edit -replace github.com/google/tsl=/go/src/github.com/google/tsl
$ go mod edit -replace github.com/tensorflow/tensorflow=/go/src/github.com/tensorflow/tensorflow
$ go mod tidy
```

#### Then, run the example program:

```sh
$ go run hello_tf.go
```

The command outputs: `Hello from TensorFlow version *number*`

#### Success: TensorFlow for Go has been configured.


# Docker Example

A [Dockerfile is available](https://github.com/tensorflow/build/tree/master/golang_install_guide/example-program),
which executes the installation and setup process for the Go bindings and
builds the example program.  To use,
[install Docker](https://www.docker.com/get-started) and then run the
following commands:

```sh
$ docker build -t tensorflow/build:golang-example https://github.com/tensorflow/build.git#:golang_install_guide/example-program
$ docker run tensorflow/build:golang-example
```
</details>
