# This file is a work in progress, designed to replace the complicated test
# orchestration previously placed in TensorFlow's ci_sanity.sh.
# This is not currently in use.
setup_file() {
    cd /tf/tensorflow
    bazel version  # Start the bazel server
    git diff --name-only origin/master > $BATS_FILE_TMPDIR/changed_files
    run bazel query $(git diff --name-only origin/master | sed ':a; N; $!ba; s/\n/ union /g') --keep_going > $BATS_FILE_TMPDIR/changed_targets || true
}

@test "Run bazel nobuild on affected targets" {
    xargs -a $BATS_FILE_TMPDIR/changed_targets bazel build --experimental_cc_shared_library --jobs=auto --nobuild --deleted_packages="" --
}

@test "Pip package smoke test" {
    skip
}

@test "Check buildifier formatting on BUILD files" {
    grep -e 'BUILD' $BATS_FILE_TMPDIR/changed_files | xargs buildifier -v -mode=diff -diff_command=diff
}

@test "Check formatting for C++ files" {
    grep -e '\.h$' -e '\.cc$' $BATS_FILE_TMPDIR/changed_files | xargs -I'{}' -n1 -P $(nproc --all) bash -c 'clang-format {} | diff - {} >/dev/null|| echo {}' | tee needs_help.txt
    test ! -s needs_help.txt
}

@test "Check formatting for Python files" {
    grep -e "\.py$" $BATS_FILE_TMPDIR/changed_files | xargs -I'{}' pylint --rcfile=tensorflow/tools/ci_build/pylintrc {} -j $(nproc --all) --disable=all --enable=E,W0311,W0312,C0330,C0301,C0326,W0611,W0622
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
    echo There are repeats of these filename(s) with different casing.
    echo Please rename files so there are no repeats.
    echo Rationale: for example, README.md and Readme.md would be the same file
    echo            on windows. In this test, you would get a warning for
    echo            "readme.md" because it checks by setting all to lowercase.
    find . | tr '[A-Z]' '[a-z]' | sort | uniq -d | tee $BATS_FILE_TMPDIR/repeats
    [[ ! -s $BATS_FILE_TMPDIR/repeats ]]
}

teardown_file() {
    bazel shutdown
}
