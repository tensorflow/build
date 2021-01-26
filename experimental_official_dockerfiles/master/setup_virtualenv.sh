#!/bin/bash
set -e

# Usage: setup_virtualenv.sh <pyversion> <virtualenv-name> <requirements.txt>
# setup_virtualenv.sh 3.6.9 tf-36 requirements.txt
source ~/.bashrc
pyenv virtualenv $1 $2
pyenv activate $2
pip install --upgrade pip
pip install -r $3 -U
