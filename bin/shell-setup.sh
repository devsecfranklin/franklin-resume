#!/bin/bash

function install_packages {
  sudo apt get install neopfetch moonmoji npm direnv automake
}

function main() {
  printf 'Desktop: %s\nSession: %s\n' "$XDG_CURRENT_DESKTOP" "$GDMSESSION"
}

main
