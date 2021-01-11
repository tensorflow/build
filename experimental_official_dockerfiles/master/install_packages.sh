#!/bin/bash

# Install packages from a file containing a list of packages that may include
# commented lines and blank lines.
apt-get update
apt-get install -y --no-recommends $(sed -e '/^\s*#.*$/d' -e '/^\s*$/d' "$1" | sort -u)
rm -rf /var/lib/apt/lists/*
