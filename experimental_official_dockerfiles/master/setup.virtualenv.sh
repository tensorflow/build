#!/bin/bash
set -xe

# Usage: setup_virtualenv.sh <pyversion> <virtualenv-name> <requirements.txt>
# setup_virtualenv.sh 3.6.9 tf-36 requirements.txt
source ~/.bashrc
VERSION=$1
NAME=$2
REQUIREMENTS=$3
pyenv virtualenv $VERSION $NAME
pyenv activate $NAME
# Disable the cache dir to save image space
pip install --no-cache-dir --upgrade pip
pip install --no-cache-dir -r $REQUIREMENTS -U
