#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023-2025 franklin <smoooth.y62wj@passmail.net>
#
# SPDX-License-Identifier: MIT

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
  sudo apt get install neofetch moonmoji npm direnv automake
}

function main() {
  printf 'Desktop: %s\nSession: %s\n' "$XDG_CURRENT_DESKTOP" "$GDMSESSION"
}

main "$@"
