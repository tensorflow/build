#!/usr/bin/env bash
#
# Check and rename wheels with auditwheel. Inserts the platform tags like
# "manylinux_xyz" into the wheel filename.
set -euxo pipefail

if [[ "$1" != "manylinux2010" ]] || [[ "$1" != "manylinux2014" ]]; then
  echo "Invalid manylinux version provided. Please choose either 'manylinux2010' or 'manylinux2014'."
  exit 1
fi

MANYLINUX_VERSION="$1"
for wheel in /tf/pkg/*.whl; do
  echo "Checking and renaming $wheel..."
  time python3 -m auditwheel repair --plat ${MANYLINUX_VERSION}_x86_64 "$wheel" --wheel-dir /tf/pkg 2>&1 | tee check.txt

  # We don't need the original wheel if it was renamed
  new_wheel=$(grep --extended-regexp --only-matching '/tf/pkg/\S+.whl' check.txt)
  if [[ "$new_wheel" != "$wheel" ]]; then
    rm "$wheel"
    wheel="$new_wheel"
  fi

  TF_WHEEL="$wheel" bats /usertools/wheel_verification.bats --timing
done
