#!/usr/bin/env sh
#
# SPDX-FileCopyrightText: 2023 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# set the openBSD screensaver

me=${0##*/}
T=300		# 5 mins.
case $1 in
off)	xset -dpms s off
	;;
on)	xset +dpms s $T 30 s blank s expose
	;;
*)	>&2 echo "Usage: $me on|off"
	exit 1
	;;
esac
