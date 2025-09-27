#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2023-2025 franklin <smoooth.y62wj@passmail.net>
#
# SPDX-License-Identifier: MIT

set -euxo pipefail

# Make a directory for the output files
dir="$(pwd)/ompi-output"
mkdir $dir

# Fill in the options you want to pass to configure here
options=""
./configure $options 2>&1 | tee $dir/config.out
tar -cf - $(find . -name config.log) | tar -x -C $dir

# Build and install Open MPI
make V=1 all 2>&1 | tee $dir/make.out
make install 2>&1 | tee $dir/make-install.out

# Bundle up all of these files into a tarball
filename="ompi-output.tar.bz2"
tar -jcf $filename $(basename $dir)
echo "Tarball $filename created"
