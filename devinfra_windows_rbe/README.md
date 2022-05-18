# DevInfra Windows RBE

Static snapshot of TF DevInfra's Windows Remote Build Execution images

Maintainer: @angerson (TensorFlow, SIG Build)

* * *

This directory was extracted from TF's internal code base in May 2022. It's not
being updated.

## Building RBE Containers & The Toolchains

These examples use bash-via-Msys on a Windows machine with Docker installed,
starting from this directory. Since it's bash, I used `pwd -W` to get the
Windows paths for volume mounts, and manually escaped extra backslashes.

1.  Make any changes to the Dockerfile
2.  Build the image

    ```
    docker build . -t tf_win_rbe
    ```

3.  Compile the basic project in the container to create the toolchain config:

    ```
    md toolchain
    docker run --name tf -itd -v "$(pwd -W)\workspace:C:\workspace" -v "$(pwd -W)\toolchain:C:\config" -w "C:\\workspace" tf_win_rbe powershell
    docker exec tf bazel build //:cc_test
    docker exec tf robocopy bazel-workspace\\external\\local_config_cc C:\\config\\ BUILD "*.bzl" builtin_include_directory_paths_msvc
    docker stop tf
    docker rm tf
    ```

Now you have a Docker container for RBE, and a Windows toolchain to use with it.
Your use case may be different than TensorFlow's. Here's how we configured ours.

For the toolchains, the TF team would copy those new "toolchain" files into a
new directory in `//tensorflow/tools/toolchains/win`, e.g.
[tf_win_08062020](https://github.com/tensorflow/tensorflow/tree/master/tensorflow/tools/toolchains/win/tf_win_08062020).
We run buildifier on these to auto-format them. We'd then update the TensorFlow
[`.bazelrc`](http://github.com/tensorflow/tensorflow/tree/master/.bazelrc). with
the new toolchain directory. We'd change all instances of `tf_win_YYYYMMDD` in
the new file to the new directory, e.g. lines like this:

```
build:rbe_win --crosstool_top="//tensorflow/tools/toolchains/win/tf_win_06242021:toolchain"
build:rbe_win --extra_toolchains="//tensorflow/tools/toolchains/win/tf_win_06242021:cc-toolchain-x64_windows"
```

For the RBE container, we would upload the new container to a GCP Docker repo
and update our RBE configuration rule in
[`//tensorflow/tools/toolchains/win/BUILD`](http://github.com/tensorflow/tensorflow/tree/master/tensorflow/tools/toolchains/win/BUILD).
with the new hash. You can see the identifier `rbe_windows_ltsc2019` in our
[`.bazelrc`](http://github.com/tensorflow/tensorflow/tree/master/.bazelrc). Past
that, I'm not really sure about how Bazel does RBE environment selection.
