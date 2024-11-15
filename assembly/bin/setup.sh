#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# openbsd
cd /usr/ports/devel/nasm && doas make install
cd /usr/ports/devel/yasm && doas make install

# linux
sudo apt-get update && sudo apt install -y yasm nasm
# https://mariokartwii.com/armv8/
sudo apt-get install -y gcc-aarch64-linux-gnu binutils-aarch64-linux-gnu binutils-aarch64-linux-gnu-dbg

# QEMU
sudo apt-get install -y qemu binfmt-support qemu-user-static # Install the qemu packages
