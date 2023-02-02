#!/bin/bash
jupyter serverextension enable --py jupyter_http_over_ws

mkdir -p /tf/tensorflow-tutorials
chmod -R a+rwx /tf/
mkdir /.local
chmod a+rwx /.local
apt-get update
apt-get install -y --no-install-recommends wget git
cd /tf/tensorflow-tutorials
wget https://raw.githubusercontent.com/tensorflow/docs/master/site/en/tutorials/keras/classification.ipynb
wget https://raw.githubusercontent.com/tensorflow/docs/master/site/en/tutorials/keras/overfit_and_underfit.ipynb
wget https://raw.githubusercontent.com/tensorflow/docs/master/site/en/tutorials/keras/regression.ipynb
wget https://raw.githubusercontent.com/tensorflow/docs/master/site/en/tutorials/keras/save_and_load.ipynb
wget https://raw.githubusercontent.com/tensorflow/docs/master/site/en/tutorials/keras/text_classification.ipynb
wget https://raw.githubusercontent.com/tensorflow/docs/master/site/en/tutorials/keras/text_classification_with_hub.ipynb

apt-get autoremove -y
apt-get remove -y wget

python3 -m ipykernel.kernelspec
