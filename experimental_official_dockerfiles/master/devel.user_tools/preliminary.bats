setup_file() {
    cd /tmp/dockertests/tensorflow
    bazel version  # Start the bazel server
}

@test "Validate BUILD files" {
    # bazel build --jobs=auto --nobuild -- //tensorflow/... -//tensorflow/lite/...
    #bazel query --noimplicit_deps -- 'deps(//tensorflow/...) - kind("android_*", //tensorflow/...)' > /dev/null
}

@test "Check formatting for C++ files" {
    # find tensorflow -name "*.h" -o -name "*.cc" | xargs -I'{}' -n1 -P $(nproc --all) bash -c 'clang-format {} | diff - {} >/dev/null|| echo {}' | tee needs_help.txt
    # test ! -s needs_help.txt
}

@test "Check formatting for Python files" {
    # pylint --rcfile=tensorflow/tools/ci_build/pylintrc -j $(nproc --all) $(git ls-files '*.py') --disable=all --enable=E,W0311,W0312,C0330,C0301,C0326,W0611,W0622
    tensorflow/tools/ci_build/ci_sanity.sh --pylint
}

teardown_file() {
    bazel shutdown
}
