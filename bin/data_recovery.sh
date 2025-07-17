#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: © 2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# ChangeLog:

DISK="/dev/sdc"
PARTITION="${DISK}1"

# Check if a directory is provided as an argument
if [ $# -eq 1 ]; then
  PARTITION="$1" # get the contents of this current dir and subdirs
fi

echo "Using Partition: ${PARTITION}"

sudo apt install testdisk
# testdisk /dev/sdc (don't use sdc1)
sudo testdisk /list "${DISK}"

fdisk -l "${PARTITION}"
stat -f "${PARTITION}"
df -Th "${PARTITION}"
#debugfs -w ${PARTITION}
