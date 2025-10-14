#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: ©2025 franklin <smoooth.y62wj@passmail.net>
#
# SPDX-License-Identifier: MIT

function install() {
  cd /usr/ports/comms/hackrf/
  make && doas make install 
}

function main() {
  /usr/local/bin/hackrf_info -s /dev/ttyp0 
}

main "@"
