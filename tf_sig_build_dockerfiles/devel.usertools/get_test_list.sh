#!/bin/bash

# Usage: get_test_list.sh OUTPUT BAZEL_TEST_COMMAND...
# Writes the list of tests that would be run from BAZEL_TEST_COMMAND to OUTPUT.
# Hides all extra output and always exits with success for now.
OUTPUT=$1
shift
"$@" --check_tests_up_to_date 2>/dev/null | sort -u | awk '{print $1}' | grep "^//" | tee $OUTPUT
