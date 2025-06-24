# Raspberry Pi Builds

TensorFlow's old official docs for building on Raspberry Pi. Needs an owner.

Maintainer: @angerson (TensorFlow, SIG Build)

* * *

**Important: TensorFlow for the Raspberry Pi is no longer supported by the
TensorFlow team. (last tested on 2.3.0rc2). See the [Build TensorFlow Light for
Raspberry Pi](https://www.tensorflow.org/lite/guide/build_rpi) guide.**

**This guide is a mirror of the old official documentation and may not work. If
you'd like to own this and keep it up-to-date, please file a PR!**
# Build [This] guide builds a TensorFlow package for a
[Raspberry Pi](https://www.raspberrypi.org/) device running
[9.0](https://www.raspberrypi.org/downloads/raspbian/).
While the instructions might work for other Raspberry Pi variants,
Git is only
tested and supported for this configuration.

We recommend *cross-compiling* the TensorFlow Raspbian package.
Cross-compilation is using a different platform to build the package than deploy
to. Instead of using the Raspberry Pi's limited RAM and comparatively slow
processor, it's easier to build TensorFlow on a more powerful host machine
running Linux, macOS, or Windows.

## Setup for host

### Install Docker

To simplify dependency management, the build script uses
[Docker](https://docs.docker.com/install/) to create a virtual Linux development
environment for compilation. Verify your Docker install by executing: `docker
run --rm hello-world`

### Download the TensorFlow source code

Use [Git](https://git-scm.com/) to clone the
[TensorFlow repository](https://github.com/tensorflow/tensorflow):

```
git clone https://github.com/tensorflow/tensorflow.git
cd tensorflow
```

The repo defaults to the `master` development branch. You can also checkout a
[release branch](https://github.com/tensorflow/tensorflow/releases)
to build:

```
git checkout <branch_name>  # r1.9, r1.10, etc.
```

Key Point: If you're having build problems on the latest development branch, try
a release branch that is known to work.


## Build from source

Cross-compile the TensorFlow source code to build a Python *pip* package with
ARMv7 [NEON instructions](https://developer.arm.com/technologies/neon) that
works on Raspberry Pi 2, 3 and 4 devices. The build script launches a Docker
container for compilation. You can also build ARM 64-bit binary (aarch64) by
providing `AARCH64` parameter to the `build_raspberry_pi.sh` script. Choose
among Python 3.8, Python 3.7, Python 3.5 and Python 2.7 for the target package:

### Python 3.5

```
tensorflow/tools/ci_build/ci_build.sh PI-PYTHON3 \
    tensorflow/tools/ci_build/pi/build_raspberry_pi.sh
```

### Python 3.7

```
tensorflow/tools/ci_build/ci_build.sh PI-PYTHON37 \
    tensorflow/tools/ci_build/pi/build_raspberry_pi.sh
```

### Python 3.8 (64bit)

```
tensorflow/tools/ci_build/ci_build.sh PI-PYTHON38 \
    tensorflow/tools/ci_build/pi/build_raspberry_pi.sh AARCH64
```

### Python 2.7

```
tensorflow/tools/ci_build/ci_build.sh PI \
    tensorflow/tools/ci_build/pi/build_raspberry_pi.sh
```

To build a package that supports all Raspberry Pi devices—including the Pi 1 and
Zero—pass the `PI_ONE` argument, for example:

```
tensorflow/tools/ci_build/ci_build.sh PI \
    tensorflow/tools/ci_build/pi/build_raspberry_pi.sh PI_ONE
```

When the build finishes (~30 minutes), a `.whl` package file is created in the
output-artifacts directory of the host's source tree. Copy the wheel file to the
Raspberry Pi and install with `pip`:

```
pip install tensorflow-<version>-cp35-none-linux_armv7l.whl
```

Success: TensorFlow is now installed on Raspbian.
