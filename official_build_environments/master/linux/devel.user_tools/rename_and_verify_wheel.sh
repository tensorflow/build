#!/bin/bash
set -e

# Check and rename the wheel with auditwheel. Inserts the platform tags like
# "manylinux_xyz" into the wheel filename.
TF_WHEEL=$(find /tf/pkg -iname '*.whl')
python3 -m auditwheel repair --plat manylinux2010_x86_64 "$TF_WHEEL" --wheel-dir /tf/pkg | tee check.txt
if grep -q "Fixed-up wheel written to" check.txt; then rm $TF_WHEEL; fi
