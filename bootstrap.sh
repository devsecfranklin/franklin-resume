#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: ©2026 franklin <smoooth.y62wj@passmail.net>
#
# SPDX-License-Identifier: MIT

# ChangeLog:

DEB_PKG=(libpcsclite-dev texlive-pictures texlive-latex-extra libssl-dev)
LRED=$(tput setaf 1)

function main() {
  # echo -e "${LRED}can not find common.sh${NC}"

  autoreconf -i
  ./configure
}

main "$@"