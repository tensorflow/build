# vim: filetype=bash
# This file is a work in progress, designed to replace the complicated test
# orchestration previously placed in TensorFlow's ci_sanity.sh.
# This is not currently in use.
setup_file() {
    cd /tf/tensorflow
    bazel version  # Start the bazel server
}

# 
get_high_level_for_query() {
 bazel cquery --experimental_cc_shared_library "$1" 2>/dev/null --keep_going \
  | grep -e "^//" -e "^@" \
  | grep -E -v "^//tensorflow" \
  | sed -e 's|:.*||' \
  | sort -u
}

# 
do_external_licenses_check(){
  BUILD_TARGET="$1"
  LICENSES_TARGET="$2"

  # grep patterns for targets which are allowed to be missing from the licenses
  cat > $BATS_TEST_TMPDIR/allowed_to_be_missing <<EOF
@absl_py//absl
@bazel_tools//platforms
@bazel_tools//third_party/
@bazel_tools//tools
@local
@com_google_absl//absl
@org_tensorflow//
@com_github_googlecloudplatform_google_cloud_cpp//google
@com_github_grpc_grpc//src/compiler
@platforms//os
@ruy//
EOF

  # grep patterns for targets which are allowed to be extra licenses
  cat > $BATS_TEST_TMPDIR/allowed_to_be_extra <<EOF
//third_party/mkl
//third_party/mkl_dnn
@absl_py//
@bazel_tools//src
@bazel_tools//platforms
@bazel_tools//tools/
@org_tensorflow//tensorflow
@com_google_absl//
//external
@local
@com_github_googlecloudplatform_google_cloud_cpp//
@embedded_jdk//
^//$
@ruy//
EOF

  get_high_level_for_query "attr('licenses', 'notice', deps($BUILD_TARGET))" | tee $BATS_TEST_TMPDIR/expected_licenses
  get_high_level_for_query "deps($LICENSES_TARGET)" | tee $BATS_TEST_TMPDIR/actual_licenses

  # Select lines unique to actual_licenses, i.e. extra licenses
  comm -1 -3 $BATS_TEST_TMPDIR/expected_licenses $BATS_TEST_TMPDIR/actual_licenses | grep -v -f $BATS_TEST_TMPDIR/allowed_to_be_extra > $BATS_TEST_TMPDIR/actual_extra_licenses || true
  # Select lines unique to expected_licenses, i.e. missing licenses
  comm -2 -3 $BATS_TEST_TMPDIR/expected_licenses $BATS_TEST_TMPDIR/actual_licenses | grep -v -f $BATS_TEST_TMPDIR/allowed_to_be_missing > $BATS_TEST_TMPDIR/actual_missing_licenses || true

  ret=0
  if [[ -s $BATS_TEST_TMPDIR/actual_extra_licenses ]]; then
    ret=1
    echo "Please remove the following extra licenses from $LICENSES_TARGET:"
    cat $BATS_TEST_TMPDIR/actual_extra_licenses
  fi

  if [[ -s $BATS_TEST_TMPDIR/actual_missing_licenses ]]; then
    ret=1
    echo "Please include the missing licenses for the following packages in $LICENSES_TARGET:"
    cat $BATS_TEST_TMPDIR/actual_extra_licenses
  fi

  [[ $ret -eq 0 ]]
}

@test "No pip CUDA deps" {
  run bazel cquery --experimental_cc_shared_library --@local_config_cuda//:enable_cuda \
    "somepath(//tensorflow/tools/pip_package:build_pip_package, " \
    "@local_config_cuda//cuda:cudart + "\
    "@local_config_cuda//cuda:cudart + "\
    "@local_config_cuda//cuda:cuda_driver + "\
    "@local_config_cuda//cuda:cudnn + "\
    "@local_config_cuda//cuda:curand + "\
    "@local_config_cuda//cuda:cusolver + "\
    "@local_config_tensorrt//:tensorrt)" --keep_going

  if [[ -e "$output" ]]; then
    echo "There was a path found connecting //tensorflow/tools/pip_package:build_pip_package to a banned CUDA dependency:"
    echo "$output"
    return 1
  fi
}


@test "Pip package licenses check" {
  do_external_licenses_check \
    "//tensorflow/tools/pip_package:build_pip_package" \
    "//tensorflow/tools/pip_package:licenses"
}

@test "Lib package licenses check" {
  do_external_licenses_check \
    "//tensorflow:libtensorflow.so" \
    "//tensorflow/tools/lib_package:clicenses_generate"
}

@test "Java package licenses check" {
  do_external_licenses_check \
    "//tensorflow/java:libtensorflow_jni.so" \
    "//tensorflow/tools/lib_package:jnilicenses_generate"
}

@test "Pip package smoke test" {
    cd tensorflow/tools/pip_package
    python pip_smoke_test.py
}

@test "Check loading" {
    cd tensorflow/tools/pip_package
    python check_load_py_test.py
}

@test "All tensorflow.org/code links point to real files" {
    for i in $(grep -onI 'https://www.tensorflow.org/code/[a-zA-Z0-9/._-]\+' -r tensorflow); do
        target=$(echo $i | sed 's!.*https://www.tensorflow.org/code/!!g')

        if [[ ! -f $target ]] && [[ ! -d $target ]]; then
            echo "$i" >> errors.txt
        fi
        if [[ -e errors.txt ]]; then
            echo "Broken links found:"
            cat errors.txt
            rm errors.txt
            false
        fi
    done
}

@test "No identically-named files if ignoring casing" {
    cat <<EOF
There are repeats of these filename(s) with different casing.
Please rename files so there are no repeats.
Rationale: for example, README.md and Readme.md would be the same file
           on windows. In this test, you would get a warning for
           "readme.md" because it checks by setting all to lowercase.
EOF
    find . | tr '[A-Z]' '[a-z]' | sort | uniq -d | tee $BATS_FILE_TMPDIR/repeats
    [[ ! -s $BATS_FILE_TMPDIR/repeats ]]
}

teardown_file() {
    bazel shutdown
}
