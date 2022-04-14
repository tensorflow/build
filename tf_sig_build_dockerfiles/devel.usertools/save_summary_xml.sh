#!/bin/bash

# Usage: save_summary.sh OUTPUT BAZEL_TEST_COMMAND...
OUTPUT=$1
shift
mkdir -p "$(dirname $OUTPUT)"
"$@" 2>&1 | tee $OUTPUT.txt
/usertools/save_summary_xml.sh $OUTPUT.txt $OUTPUT
rm $OUTPUT.txt
