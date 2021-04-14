#!/bin/bash
 
################################################################################

set -e

# Retry on connection timeout.
bash -c "echo 'APT::Acquire::Retries \"3\";' > /etc/apt/apt.conf.d/80-retries"

# Install bootstrap dependencies from ubuntu deb repository.
apt-get update
apt-get install -y --no-install-recommends \
    apt-transport-https ca-certificates software-properties-common
apt-get clean
rm -rf /var/lib/apt/lists/*

################################################################################

set -e
ubuntu_version=$(cat /etc/issue | grep -i ubuntu | awk '{print $2}' | \
  awk -F'.' '{print $1}')

if [[ "$1" != "" ]] && [[ "$1" != "--without_cmake" ]]; then
  echo "Unknown argument '$1'"
  exit 1
fi

# Install dependencies from ubuntu deb repository.
apt-key adv --keyserver keyserver.ubuntu.com --recv 084ECFC5828AB726
apt-get update

if [[ "$ubuntu_version" == "14" ]]; then
  # specifically for trusty linked from ffmpeg.org
  add-apt-repository -y ppa:mc3man/trusty-media
  apt-get update
  apt-get dist-upgrade -y
fi

## TODO(yifeif) remove ffmpeg once ffmpeg is removed from contrib
apt-get install -y --no-install-recommends \
    autoconf \
    automake \
    build-essential \
    curl \
    ffmpeg \
    git \
    libcurl4-openssl-dev \
    libtool \
    libssl-dev \
    mlocate \
    openjdk-8-jdk \
    openjdk-8-jre-headless \
    pkg-config \
    python-dev \
    python-setuptools \
    python-virtualenv \
    python3-dev \
    python3-setuptools \
    rsync \
    sudo \
    swig \
    unzip \
    vim \
    wget \
    zip \
    zlib1g-dev

# populate the database
updatedb

if [[ "$1" != "--without_cmake" ]]; then
  apt-get install -y --no-install-recommends \
    cmake
fi


# Install ca-certificates, and update the certificate store.
apt-get install -y ca-certificates-java
update-ca-certificates -f

apt-get clean
rm -rf /var/lib/apt/lists/*

################################################################################

DIST="$(grep "DISTRIB_CODENAME" /etc/lsb-release |sed 's,.*=,,')"
wget -O - "https://apt.llvm.org/llvm-snapshot.gpg.key"| apt-key add -
add-apt-repository "deb http://apt.llvm.org/${DIST}/ llvm-toolchain-${DIST}-8 main"
apt-get update && apt-get install -y clang-8 && \
  rm -rf /var/lib/apt/lists/*


################################################################################

# Select bazel version.
BAZEL_VERSION="3.7.2"

set +e
local_bazel_ver=$(bazel version 2>&1 | grep -i label | awk '{print $3}')

if [[ "$local_bazel_ver" == "$BAZEL_VERSION" ]]; then
  exit 0
fi

set -e

# Install bazel.
mkdir -p /bazel
cd /bazel
if [[ ! -f "bazel-$BAZEL_VERSION-installer-linux-x86_64.sh" ]]; then
  curl -fSsL -O https://github.com/bazelbuild/bazel/releases/download/$BAZEL_VERSION/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh
fi
chmod +x /bazel/bazel-*.sh
/bazel/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh
rm -f /bazel/bazel-$BAZEL_VERSION-installer-linux-x86_64.sh

# Enable bazel auto completion.
echo "source /usr/local/lib/bazel/bin/bazel-complete.bash" >> ~/.bashrc


################################################################################

