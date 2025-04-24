#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# winetricks explorer
# run winecfg and set emulate virtual desktop

# Sound
# winetricks sound=disabled   # shut off sound
# Revert it back using " winetricks sound=pulse " or "winetricks settings list"

sudo apt-get --reinstall install ttf-mscorefonts-installer # this is interactive
# install fonts into .wine/drive_c/windows/Fonts
winetricks dlls # install first one
winetricks corefonts vcrun6 

