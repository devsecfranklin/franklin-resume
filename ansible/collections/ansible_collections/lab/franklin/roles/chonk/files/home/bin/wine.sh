#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# winetricks explorer
# run winecfg and set emulate virtual desktop

# Sound 
winetricks sound=disabled   # shut off sound
Revert it back using " winetricks sound=pulse " or "winetricks settings list"


winetricks dlls # install first one

# start a new game, shut off sound and graphics in the Game menu
