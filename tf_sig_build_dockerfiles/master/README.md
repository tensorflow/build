# TensorFlow `master` branch Dockerfiles

These Dockerfiles are supported by the TensorFlow team and are published to
tensorflow/build as latest-python3.6..3.9. The TensorFlow OSS DevInfra team
is evaluating these containers for building `tf-nightly`.

## Updating the Containers

For simple changes, you can adjust the source files and then make a PR. Send
it to @angerson for review. Our GitHub Actions workflow deploys the containers
after approval and submission.

- To update Python packages, look at `devel.requirements.txt`
- To update system packages, look at `devel.packages.txt`
- To update the way `bazel build` works, look at `devel.usertools/*.bazelrc`.

To rebuild the containers locally after making changes, use this command from this
directory:

```bash
# Tips:
# - Don't forget the . at the end
# - Optionally, add '--pull' or '--no-cache' if you are having rebuild issues
# - The build must work with Python 3.6 through Python 3.9
DOCKER_BUILDKIT=1 docker build --pull --no-cache \
  --build-arg PYTHON_VERSION=python3.9 --target=devel -t my-tf-devel .
```

Because we don't have Docker-building presubmits, you'll have to do this if you
want to check to see if your change works. It will take a long time to build
devtoolset and install CUDA packages. After it's done, you can use the commands
below to test your changes -- just replace `tensorflow/build:latest-python3.9`
with `my-tf-devel` to use your image instead.

## Building `tf-nightly` packages

The TensorFlow team's scripts aren't visible, but use the configuration files
which are included in the containers. Here is how to build a TensorFlow package
with the same configuration as tf-nightly.

Note that you can determine the Git commit of a tf-nightly package on pypi.org 
by checking `tf.version.GIT_VERSION`. The `nightly` tag on GitHub is not
related to the `tf-nightly` packages. `tf.version.GIT_VERSION` will look
something like `v1.12.1-67282-g251085598b7`, where the final section is a short
Git hash: `g251085598b7` for that example.

1. Set up your directories:
  - A directory with the TensorFlow source code, e.g. /tmp/tensorflow
  - A directory for TensorFlow packages built in the container, e.g. /tmp/packages
  - A directory for your local bazel cache, e.g. /tmp/bazelcache

2. Choose the Docker container to use from [Docker Hub](https://hub.docker.com/r/tensorflow/build/tags). The options are:
  1. `tensorflow/build:latest-python3.6`
  2. `tensorflow/build:latest-python3.7`
  3. `tensorflow/build:latest-python3.8`
  4. `tensorflow/build:latest-python3.9`
  For this example we'll use `tensorflow/build:latest-python3.9`.

3. Pull the container you decided to use.

  ```bash
  docker pull tensorflow/build:latest-python3.9
  ```
  
4. Start a Docker container with the three folders mounted.
  - Mount the TensorFlow source code to `/tf/tensorflow`
  - Mount the directory for built packages to `/tf/pkg`
  - Mount the bazel cache to `/tf/cache`

  ```bash
  docker run --name tf -w /tf/tensorflow -itd --rm \
    -v "/tmp/packages:/tf/pkg" \
    -v "/tmp/tensorflow:/tf/tensorflow" \
    -v "/tmp/bazelcache:/tf/cache" \
    tensorflow/build:latest-python3.9 \
    bash
  ```
  
5. Apply the `update_version.py` script that changes the TensorFlow version to
   `X.Y.Z.devYYYYMMDD`. This is used for `tf-nightly` on PyPI and is technically
   optional.

  ```bash
  docker exec tf python3 tensorflow/tools/ci_build/update_version.py --nightly
  ```
  
6. Build TensorFlow.

  <details><summary>`tf-nightly-cpu`</summary>

  Build the sources with Bazel:

  ```
  docker exec tf \
  bazel \
  --bazelrc=/usertools/cpu.bazelrc \
  build \
  --config=sigbuild_remote_cache \
  tensorflow/tools/pip_package:build_pip_package
  ```

  And then construct the pip package:

  ```
  docker exec tf \
    ./bazel-bin/tensorflow/tools/pip_package/build_pip_package \
    /tf/pkg \
    --nightly_flag
  ```
  
  </details>

  <details><summary>`tf-nightly` (GPU)</summary>

  Build the sources with Bazel:

  ```
  docker exec tf \
  bazel \
  --bazelrc=/usertools/gpu.bazelrc \
  build \
  --config=sigbuild_remote_cache \
  tensorflow/tools/pip_package:build_pip_package
  ```
  
  And then construct the pip package:

  ```
  docker exec tf \
    ./bazel-bin/tensorflow/tools/pip_package/build_pip_package \
    /tf/pkg \
    --gpu \
    --nightly_flag
  ```
  
  </details>

7. Run the helper script that checks for manylinux compliance, renames the wheels, and then checks the size of the packages.

  ```
  docker exec tf /usertools/rename_and_verify_wheels.sh
  ```
  
8. Take a look at the new packages you made

  ```
  ls -al /tmp/packages
  ```

9. Shut down the container if you are finished.

  ```
  docker stop tf
  ```
