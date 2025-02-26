#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: © 2022-2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# ChangeLog:
#

function check_installed() {
  if command -v "$1" &>/dev/null; then
    printf "${LPURP}Found command: %s${NC}\n" "$1"
    return 0
  else
    printf "${LRED}%s could not be found${NC}\n" "$1"
    return 1
  fi
}

function install_packages {
  # sudo apt get install neopfetch moonmoji npm direnv automake
  pass
}

function main() {
  printf 'Desktop: %s\nSession: %s\n' "$XDG_CURRENT_DESKTOP" "$GDMSESSION"
}

main "$@"
