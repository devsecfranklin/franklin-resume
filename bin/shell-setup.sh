#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: © 2022-2024 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

function install_packages {
  sudo apt get install neopfetch moonmoji npm direnv automake
}

function main() {
  printf 'Desktop: %s\nSession: %s\n' "$XDG_CURRENT_DESKTOP" "$GDMSESSION"
}

main
