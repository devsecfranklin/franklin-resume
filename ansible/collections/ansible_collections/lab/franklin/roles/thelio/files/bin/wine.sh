#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

WINEDEBUG="-all"
WINEPREFIX="/home/franklin/.wine"
# WINEPREFIX=~/.wine WINEARCH="win32" winecfg


function setup_wine() {
    dpkg --add-architecture i386 
    sudo mkdir -pm755 /etc/apt/keyrings
    wget -O - https://dl.winehq.org/wine-builds/winehq.key | sudo gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key -
    sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/jammy/winehq-jammy.sources
    sudo apt update && sudo apt install --install-recommends winehq-stable
}

function winetricks() {
    # winetricks explorer
    # run winecfg and set emulate virtual desktop
    # Sound
    # winetricks sound=disabled   # shut off sound
    # Revert it back using " winetricks sound=pulse " or "winetricks settings list"
    sudo apt-get --reinstall install ttf-mscorefonts-installer # this is interactive
    # install fonts into .wine/drive_c/windows/Fonts
    winetricks dlls # install first one
    winetricks corefonts vcrun6 
}

function main() {
  setup_wine
  # winetricks
}

main "$@"