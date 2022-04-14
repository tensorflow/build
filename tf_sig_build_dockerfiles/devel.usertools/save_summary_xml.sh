#!/bin/bash

# Usage: save_summary_xml.sh OUTPUT BAZEL_TEST_COMMAND...
OUTPUT=$1
shift
mkdir -p "$(dirname $OUTPUT)"
"$@" 2>&1 | tee "$OUTPUT.txt"
python /usertools/save_summary_xml.py $OUTPUT.txt $OUTPUT
rm $OUTPUT.txt
