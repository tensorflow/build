# TF SIG Build Dockerfiles

Standard Dockerfiles for TensorFlow builds.

Maintainer: @angerson (TensorFlow OSS DevInfra; SIG Build)

* * *

These docker containers are for building and testing TensorFlow in CI
environments (and for users replicating those CI builds). They are openly
developed in TF SIG Build, verified by Google developers, and published to
tensorflow/build on [Docker Hub](https://hub.docker.com/r/tensorflow/build/).
The TensorFlow OSS DevInfra team is evaluating these containers for building
`tf-nightly`.

## Tags

These Dockerfiles are built and deployed to [Docker
Hub](https://hub.docker.com/r/tensorflow/build/) via [Github
Actions](https://github.com/tensorflow/build/blob/master/.github/workflows/docker.yml).

The tags are defined as such:

- The `latest` tags are kept up-to-date to build TensorFlow's `master` branch.
- The `version number` tags target the corresponding TensorFlow version. We
  continuously build the `current-tensorflow-version + 1` tag, so when a new
  TensorFlow branch is cut, that Dockerfile is frozen to support that branch.
- We support the same Python versions that TensorFlow does.

## Updating the Containers

For simple changes, you can adjust the source files and then make a PR. Send it
to @angerson for review. We have presubmits that will make sure your change
still builds a container. After approval and submission, our GitHub Actions
workflow deploys the containers to Docker Hub.

- To update Python packages, look at `devel.requirements.txt`
- To update system packages, look at `devel.packages.txt`
- To update the way `bazel build` works, look at `devel.usertools/*.bazelrc`.

To rebuild the containers locally after making changes, use this command from this
directory:

```bash
# Tips:
# - Don't forget the . at the end
# - Optionally, add '--pull' or '--no-cache' if you are having rebuild issues
DOCKER_BUILDKIT=1 docker build --pull --no-cache \
  --build-arg PYTHON_VERSION=python3.9 --target=devel -t my-tf-devel .
```

It will take a long time to build devtoolset and install CUDA packages. After
it's done, you can use the commands below to test your changes. Just replace
`tensorflow/build:latest-python3.9` with `my-tf-devel` to use your image
instead.

## Building `tf-nightly` packages

The TensorFlow team's scripts aren't visible, but use the configuration files
which are included in the containers. Here is how to build a TensorFlow package
with the same configuration as `tf-nightly`.

Note: the Git commit of a `tf-nightly` package on pypi.org is shown in
`tf.version.GIT_VERSION`, which will look something like
`v1.12.1-67282-g251085598b7`. The final section, `g251085598b7`, is a short git
hash. The `nightly` tag on GitHub is not related to the `tf-nightly` packages. 

1. Set up your directories:

    - A directory with the TensorFlow source code, e.g. `/tmp/tensorflow`
    - A directory for TensorFlow packages built in the container, e.g. `/tmp/packages`
    - A directory for your local bazel cache, e.g. `/tmp/bazelcache`

2. Choose the Docker container to use from [Docker Hub](https://hub.docker.com/r/tensorflow/build/tags). The options are:

    - `tensorflow/build:latest-python3.6`
    - `tensorflow/build:latest-python3.7`
    - `tensorflow/build:latest-python3.8`
    - `tensorflow/build:latest-python3.9`

    For this example we'll use `tensorflow/build:latest-python3.9`.

3. Pull the container you decided to use.

    ```bash
    docker pull tensorflow/build:latest-python3.9
    ```
  
4. Start a Docker container with the three folders mounted.

    - Mount the TensorFlow source code to `/tf/tensorflow`.
    - Mount the directory for built packages to `/tf/pkg`.
    - Mount the bazel cache to `/tf/cache`.

    You don't need `/tf/cache` if you're going to use the remote cache.

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
  
6. Build TensorFlow. You can build both CPU and GPU packages without a GPU.  TF
   DevInfra's remote cache is better for building TF only once, but if you
   build over and over, it will probably be better in the long run to use a
   local cache. We're not sure about which is best for most users, so let us
   know on [Gitter](https://gitter.im/tensorflow/sig-build).

    <details><summary>TF Nightly CPU - Remote Cache</summary>

    Build the sources with Bazel:

    ```
    docker exec tf bazel --bazelrc=/usertools/cpu.bazelrc \
    build --config=sigbuild_remote_cache \
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

    <details><summary>TF Nightly GPU - Remote Cache</summary>

    Build the sources with Bazel:

    ```
    docker exec tf bazel --bazelrc=/usertools/gpu.bazelrc \
    build --config=sigbuild_remote_cache \
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

    <details><summary>TF Nightly CPU - Local Cache</summary>

    Make sure you have a directory mounted to the Dockerfile in /tf/cache!

    Build the sources with Bazel:

    ```
    docker exec tf bazel --bazelrc=/usertools/cpu.bazelrc \
    build --config=sigbuild_local_cache \
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

    <details><summary>TF Nightly GPU - Local Cache</summary>

    Make sure you have a directory mounted to the Dockerfile in /tf/cache!

    Build the sources with Bazel:

    ```
    docker exec tf \
    bazel --bazelrc=/usertools/gpu.bazelrc \
    build --config=sigbuild_local_cache \
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

7. Run the helper script that checks for manylinux compliance, renames the
   wheels, and then checks the size of the packages.

    ```
    docker exec tf /usertools/rename_and_verify_wheels.sh
    ```
  
8. Take a look at the new wheel packages you built!

    ```
    ls -al /tmp/packages
    ```

9. Shut down the container when you are finished.

    ```
    docker stop tf
    ```
