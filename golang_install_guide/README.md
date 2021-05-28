# Golang Install Guide 

TensorFlow's old official docs for installing the (unsupported) Go bindings.
Needs an owner.

Maintainer: @angerson (TensorFlow, SIG Build)

* * *

**Important: TensorFlow for Go is no longer supported by the
TensorFlow team.**

**This guide is a mirror of the old official documentation and may not work. If
you'd like to own this and keep it up-to-date, please file a PR!**

# Install TensorFlow for Go

TensorFlow provides a
[Go API](https://pkg.go.dev/github.com/tensorflow/tensorflow/tensorflow/go)
particularly useful for loading models created with Python and running them
within a Go application.

Caution: The TensorFlow Go API is *not* covered by the TensorFlow
[API stability guarantees](https://www.tensorflow.org/guide/versions).


## Supported Platforms

The Go bindings for TensorFlow work on the following systems, and likely others:

* Linux, 64-bit, x86
* macOS, Version 10.12.6 (Sierra) or higher


## Installation and Setup

### 1. Install the TensorFlow C library

Install the [TensorFlow C library](https://www.tensorflow.org/install/lang_c). This
library is required for use of the TensorFlow Go package at runtime. For example,
on Linux (64-bit, x86):

  ```sh
  $ curl -L https://storage.googleapis.com/tensorflow/libtensorflow/libtensorflow-cpu-linux-x86_64-2.5.0.tar.gz | tar xz --directory /usr/local
  $ ldconfig
  ```

### 2. Install the Protocol Buffer Compiler (Protoc)

Install the [Protocol Buffer Compiler](https://developers.google.com/protocol-buffers).
This compiler is required to install the Go bindings but is not needed at runtime.

- Linux, using `apt` or `apt-get`, for example:

  ```sh
  $ apt install -y protobuf-compiler
  ```

- MacOS, using [Homebrew](https://brew.sh/):

  ```sh
  $ brew install protobuf
  ```

### 3. Install and Setup the Tensorflow Go API

***The use of `go get` is not currently supported for installation of the Tensorflow Go API.
Instead, follow these instructions.***

- Decide on a location to install the API, such as within the `src` folder immediately below
the Go workspace (e.g., the location of $GOPATH).  The location `/go/src/github.com/tensorflow/tensorflow`
will be used in these instructions.

- Clone the Tensorflow source respository to the install location

  ```sh
  $ git clone --branch v2.5.0 https://github.com/tensorflow/tensorflow.git /go/src/github.com/tensorflow/tensorflow
  ```

- Change the working directory to the install location.
 
   ```sh
   $ cd /go/src/github.com/tensorflow/tensorflow
   ```

- Apply a patch to declare the Go package within Tensorflow's proto definition files

   ```sh
   $ git format-patch -1 835d7da --stdout | git apply
   ```

- Initialize a new go.mod file

   ```sh
   $ go mod init github.com/tensorflow/tensorflow
   ```

- Generate the protocol buffers and move the generating files to their correct locations.  You
will receive two errors (`no required module provides package ...`), which you can ignore.

   ```sh
   $ cd tensorflow/go
   $ go generate ./...
   $ mv vendor/github.com/tensorflow/tensorflow/tensorflow/go/* .
   ```

- Add missing modules

   ```sh
   $ go mod tidy
   ```

- Test the installation
   ```sh
   $ go test ./...
   ``` 


## Usage

### Applications must use Go Mod's `replace` directive

The `replace` directive instructs Go to use the local installation.  Point this
to the installation location (such as `/go/src/github.com/tensorflow/tensorflow`
from the above installation instructions).

This directive must be added for each Go module that uses the Go API. As an
example: 

```sh
$ go mod init hello-world
$ go mod edit -require github.com/tensorflow/tensorflow@v2.5.0+incompatible
$ go mod edit -replace github.com/tensorflow/tensorflow=/go/src/github.com/tensorflow/tensorflow
$ go mod tidy
```


### Example program

With the TensorFlow Go package installed, create an example program with the
following source code (`hello_tf.go`):

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
$ go mod edit -require github.com/tensorflow/tensorflow@v2.5.0+incompatible
$ go mod edit -replace github.com/tensorflow/tensorflow=/go/src/github.com/tensorflow/tensorflow
$ go mod tidy
```

#### Then, run the example program:

```sh
$ go run hello_tf.go
```

The command outputs: `Hello from TensorFlow version *number*`

Success: TensorFlow for Go has been configured.

The program may generate the following warning messages, which you can ignore:

```
W tensorflow/core/platform/cpu_feature_guard.cc:45] The TensorFlow library
wasn't compiled to use *Type* instructions, but these are available on your
machine and could speed up CPU computations.
```

## Build from source

TensorFlow is open source. Read
[the instructions](https://github.com/tensorflow/tensorflow/blob/master/tensorflow/go/README.md)
to build TensorFlow for Go from source code.
