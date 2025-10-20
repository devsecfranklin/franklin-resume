#!/usr/bin/env sh
#
# SPDX-FileCopyrightText: 2023 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Change Wallpaper, dmenu version, by Ian LeCorbeau

ln -sf "$(find ~/Pictures -type f | sort -n | xargs -r0 | dmenu -l 15 -p chwall)" ~/Pictures/20231108_100325.jpg && xwallpaper --stretch ~/Pictures/20231108_100325.jpg
