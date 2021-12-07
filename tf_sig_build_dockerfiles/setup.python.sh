#!/usr/bin/env bash
#
# setup.python.sh: Install a specific Python version and packages for it.
# Usage: setup.python.sh <pyversion> <requirements.txt>
set -xe

source ~/.bashrc
VERSION=$1
REQUIREMENTS=$2
echo $PATH

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
  rm -f /dt7/usr/include/x86_64-linux-gnu/$f
  ln -s /usr/include/x86_64-linux-gnu/$f /dt7/usr/include/x86_64-linux-gnu/$f
done
popd

# Setup links for TensorFlow to compile.
# Referenced in devel.usertools/*.bazelrc
ln -sf /usr/bin/$VERSION /usr/bin/python3
ln -sf /usr/bin/$VERSION /usr/bin/python
ln -sf /usr/lib/$VERSION /usr/lib/tf_python

# Install pip
if [[ "$VERSION" == "python3.10" ]]; then
  # Python 3.10 pip reference is broken for pip 21.3 (pypa/pip#10647)
  python3 -m ensurepip
  python3 -m pip install pip~=21.2.0
  python3 -m ensurepip --upgrade  # Only upgrades minor version (21.2.x)
else
  curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
  python3 get-pip.py
  python3 -m pip install --no-cache-dir --upgrade pip
fi

# Disable the cache dir to save image space, and install packages
python3 -m pip install --no-cache-dir -r $REQUIREMENTS -U
python3 -m pip list
