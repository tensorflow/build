#!/usr/bin/env bash
#
# setup.python.sh: Install a specific Python version and packages for it.
# Usage: setup.python.sh <pyversion> <requirements.txt>
set -xe

source ~/.bashrc
VERSION=$1
REQUIREMENTS=$2

# Install Python packages for this container's version
cat >pythons.txt <<EOF
$VERSION
$VERSION-dev
$VERSION-venv
$VERSION-distutils
EOF
/setup.packages.sh pythons.txt

# Re-link pyconfig.h from x86_64-linux-gnu into the devtoolset directory
# for any Python version present
pushd /usr/include/x86_64-linux-gnu
for f in $(ls | grep python); do
  # set up symlink for devtoolset-7
  rm -f /dt7/usr/include/x86_64-linux-gnu/$f
  ln -s /usr/include/x86_64-linux-gnu/$f /dt7/usr/include/x86_64-linux-gnu/$f
  # set up symlink for devtoolset-8
  rm -f /dt8/usr/include/x86_64-linux-gnu/$f
  ln -s /usr/include/x86_64-linux-gnu/$f /dt8/usr/include/x86_64-linux-gnu/$f
done
popd

# Setup links for TensorFlow to compile.
# Referenced in devel.usertools/*.bazelrc
ln -sf /usr/bin/$VERSION /usr/bin/python3
ln -sf /usr/bin/$VERSION /usr/bin/python
ln -sf /usr/lib/$VERSION /usr/lib/tf_python

# Install pip
if [[ "$VERSION" == "python3.10" ]]; then
  # In Python 3.10 with pip 21.3.x, get-pip.py does not install pip correctly.
  # Therefore, we use "ensurepip" but do not upgrade pip afterwards. The version
  # of pip included with ensurepip should work properly.
  # See https://github.com/pypa/pip/issues/10647#issuecomment-967144347
  # TODO(rameshsampath): Remove this version-specific workaround, either when
  #   pip is fixed or when we find a method that works for all versions.
  #   ensurepip does not work for the system python version (python 3.8 for 
  #   Ubuntu 20.04); it wants "python3-pip" instead.
  python3 -m ensurepip
  # Create a symlink so that "pip" works as expected
  ln --symbolic --force pip3 /usr/bin/pip
else
  curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
  python3 get-pip.py
  python3 -m pip install --no-cache-dir --upgrade pip
fi

# Disable the cache dir to save image space, and install packages
python3 -m pip install --no-cache-dir -r $REQUIREMENTS -U
