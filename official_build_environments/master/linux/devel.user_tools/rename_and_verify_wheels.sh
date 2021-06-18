#!/bin/bash
set -euo pipefail

# Check and rename wheels with auditwheel. Inserts the platform tags like
# "manylinux_xyz" into the wheel filename.
for wheel in /tf/pkg/*.whl; do
  echo "Checking and renaming $wheel..."
  time python3 -m auditwheel repair --plat manylinux2010_x86_64 "$wheel" --wheel-dir /tf/pkg 2>&1 | tee check.txt

  # We don't need the original wheel
  if grep -q "Fixed-up wheel written to" check.txt; then
    rm "$wheel"
  else
    echo "Failed to rename the wheel! Aborting.."
    exit 1
  fi
  wheel=$(grep -o '/tf/pkg/\S.whl' check.txt)

  TF_WHEEL="$wheel" bats /user_tools/wheel_verification.bats --timing
done
