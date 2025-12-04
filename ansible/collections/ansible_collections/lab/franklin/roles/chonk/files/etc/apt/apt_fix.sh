#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: ©2021-2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: MIT

BACKUP_DIR="/etc/apt/backup"

if [ ! -d "${BACKUP_DIR}" ]; then mkdir -p "${BACKUP_DIR}" && echo "create dir"; fi

function update() {
  dpkg --configure -a
  apt install -f
  apt full-upgrade
  apt install pop-desktop
  mv /etc/apt/sources.list.d/* "${BACKUP_DIR}"
}
