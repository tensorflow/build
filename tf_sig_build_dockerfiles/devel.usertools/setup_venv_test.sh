#!/usr/bin/env bash
set -euxo pipefail

# Run this from inside the tensorflow github directory

python -m venv /$1
mkdir -p $1
rm -f ./$1/tensorflow
ln -s ../tensorflow $1/tensorflow
bash -c "/$1/bin/pip install $2"
