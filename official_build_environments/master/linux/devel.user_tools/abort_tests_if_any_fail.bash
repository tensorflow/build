# If loaded in bats, skip all tests after a failing one.
#
# Very useful to emulate GitHub Actions-style sequence of CI steps, each with
# their own timing and failure status. A bats file filled with @tests is run
# one-at-a-time in order, so using this method will get us timing information
# and xUnit XML status for each test.

setup_file() {
    # Start the bazel server to exclude startup time from tests
    bazel version
}

teardown() {
    # $BATS_ERROR_STATUS is an undocumented variable available in the teardown
    # See https://github.com/bats-core/bats-core/search?q=BATS_ERROR_STATUS
    if test "$BATS_ERROR_STATUS" -ne 0; then
        touch "$BATS_TMPDIR/abort"
    fi
}

teardown_file() {
    rm -rf "$BATS_TMPDIR/abort"
    # Bats will hang if the bazel server isn't manually shut down
    bazel shutdown
}

setup() {
    cd /tf/tensorflow
    if test -e "$BATS_TMPDIR/abort"; then
      skip "A previous step failed."
    fi
}
