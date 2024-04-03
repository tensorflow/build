#!/bin/bash
jupyter serverextension enable --py jupyter_http_over_ws

TENSORFLOW_TUTORIALS="${TENSORFLOW_NOTEBOOK_DIR}/tensorflow-tutorials"
mkdir -p -v ${TENSORFLOW_TUTORIALS}

chmod -R a+rwx ${TENSORFLOW_NOTEBOOK_DIR}
mkdir /.local
chmod a+rwx /.local

cd ${TENSORFLOW_TUTORIALS}
wget https://raw.githubusercontent.com/tensorflow/docs/master/site/en/tutorials/keras/classification.ipynb
wget https://raw.githubusercontent.com/tensorflow/docs/master/site/en/tutorials/keras/overfit_and_underfit.ipynb
wget https://raw.githubusercontent.com/tensorflow/docs/master/site/en/tutorials/keras/regression.ipynb
wget https://raw.githubusercontent.com/tensorflow/docs/master/site/en/tutorials/keras/save_and_load.ipynb
wget https://raw.githubusercontent.com/tensorflow/docs/master/site/en/tutorials/keras/text_classification.ipynb
wget https://raw.githubusercontent.com/tensorflow/docs/master/site/en/tutorials/keras/text_classification_with_hub.ipynb

python3 -m ipykernel.kernelspec
