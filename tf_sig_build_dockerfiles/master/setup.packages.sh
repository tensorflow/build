#!/usr/bin/env bash
#
# setup.packages.sh: Given a list of Ubuntu packages, install them and clean up.
# Usage: setup.packages.sh <package_list.txt>
set -e

# Prevent apt install tzinfo from asking our location (assumes UTC)
export DEBIAN_FRONTEND=noninteractive

apt-get update
# Remove commented lines and blank lines
apt-get install -y --no-install-recommends $(sed -e '/^\s*#.*$/d' -e '/^\s*$/d' "$1" | sort -u)
rm -rf /var/lib/apt/lists/*
