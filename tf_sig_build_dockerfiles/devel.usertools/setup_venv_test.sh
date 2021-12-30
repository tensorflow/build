#!/usr/bin/env bash
set -euxo pipefail

# Run this from inside the tensorflow github directory.
# Usage: setup_venv_test.sh venv_and_symlink_name "glob pattern for one wheel file"
# Example: setup_venv_test.sh bazel_pip "/tf/pkg/*.whl"
# 
# This will create a venv with that wheel file installed in it, and a symlink
# in ./venv_and_symlink_name/tensorflow to ./tensorflow. We use this for the
# "pip" tests.

python -m venv /$1
mkdir -p $1
rm -f ./$1/tensorflow
ln -s $(ls /$1/lib) /$1/lib/python3
ln -s ../tensorflow $1/tensorflow
# extglob is necessary for @(a|b) pattern matching
# see "extglob" in the bash manual page ($ man bash)
bash -O extglob -c "/$1/bin/pip install $2"
/$1/bin/pip install -r /usertools/test.requirements.txt
