#!/usr/bin/env bash

# Sets up custom apt sources for our TF images.

# Prevent apt install tzinfo from asking our location (assumes UTC)
export DEBIAN_FRONTEND=noninteractive

# Set up shared custom sources
apt-get update
apt-get install -y gnupg ca-certificates

# Deadsnakes: https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F23C5A6CF475977595C89F51BA6932366A755776

# Set up custom sources
cat >/etc/apt/sources.list.d/custom.list <<SOURCES
# Nvidia CUDA packages: 18.04 has more available than 20.04, and we use those
deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /

# More Python versions: Deadsnakes
deb http://ppa.launchpad.net/deadsnakes/ppa/ubuntu focal main
deb-src http://ppa.launchpad.net/deadsnakes/ppa/ubuntu focal main
SOURCES


