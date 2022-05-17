# DevInfra Windows RBE

Static snapshot of TF DevInfra's Windows Remote Build Execution images

Maintainer: @angerson (TensorFlow, SIG Build)

* * *

This directory was extracted from TF's internal code base in May 2022. It's not
being updated.

## Updating RBE Containers

These examples use Powershell on a Windows machine with Docker installed,
starting from this directory.

1.  Update the Dockerfile as you wish
2.  Build the image

    ```
    docker build . -t tf_win_rbe
    ```
    
3. Push the new image to a GCP docker repository so you can use it with RBE
    
3. Compile the basic project to create the toolchain config

    ```
    md toolchain
    docker run --name tf -itd --rm ^
      -v workspace:C:\workspace ^
      -v toolchain:C:\config ^
      -w C:\workspace tf_win_rbe
      powershell
    docker exec tf bazel build //:cc_test
    docker exec tf robocopy bazel-workspace\external\local_config_cc C:\config\ BUILD *.bzl builtin_include_directory_paths_msvc
    docker stop tf
    docker rm tf
    ```
    
4.  Update the toolchain that TensorFlow uses for RBE Windows builds. Create a
    new folder under
    [`tensorflow/tools/toolchains/win`](http://github.com/tensorflow/tensorflow/tree/master/tensorflow/tensorflow/tools/toolchains/win)
    and place all the files from the `toolchains` artifact directory under
    there. DevInfra runs buildifier on these to auto-format them.

5.  Update the docker image hash used by the RBE configuration: Update the hash
    in
    [`win/BUILD.oss`](http://github.com/tensorflow/tensorflow/tree/master/tensorflow/toolchains/win/BUILD.oss)
    to the same hash as the new one you uploaded

6.  Update the TensorFlow
    [`.bazelrc`](http://github.com/tensorflow/tensorflow/tree/master/.bazelrc)
    with the new toolchain directory. There are a few lines that will look
    something like this:

    ```
    build:rbe_win --crosstool_top="//tensorflow/tools/toolchains/win/tf_win_06242021:toolchain"
    build:rbe_win --extra_toolchains="//tensorflow/tools/toolchains/win/tf_win_06242021:cc-toolchain-x64_windows"
    ```

    Change all instances of `tf_win_YYYYMMDD` to the new directory you made,
    which should share the same naming scheme.
