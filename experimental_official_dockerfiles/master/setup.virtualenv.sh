#!/bin/bash
set -e

# Usage: setup_virtualenv.sh <pyversion> <virtualenv-name> <requirements.txt>
# setup_virtualenv.sh 3.6.9 tf-36 requirements.txt
source ~/.bashrc
VERSION=$1
NAME=$2
REQUIREMENTS=$3
pyenv virtualenv $VERSION $NAME
pyenv activate $NAME
pip install --upgrade pip
pip install -r $REQUIREMENTS -U
