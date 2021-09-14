#!/bin/bash
set -euxo pipefail

# Check and rename wheels with auditwheel. Inserts the platform tags like
# "manylinux_xyz" into the wheel filename.
for wheel in /tf/pkg/*.whl; do
  echo "Checking and renaming $wheel..."
  time python3 -m auditwheel repair --plat manylinux2014_x86_64 "$wheel" --wheel-dir /tf/pkg 2>&1 | tee check.txt

  # We don't need the original wheel if it was renamed
  new_wheel=$(grep --extended-regexp --only-matching '/tf/pkg/\S+.whl' check.txt)
  if [[ "$new_wheel" != "$wheel" ]]; then
    rm "$wheel"
    wheel="$new_wheel"
  fi

  TF_WHEEL="$wheel" bats /user_tools/wheel_verification.bats --timing
done
