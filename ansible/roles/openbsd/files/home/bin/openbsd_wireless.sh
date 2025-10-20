#!/usr/bin/env sh
#
# SPDX-FileCopyrightText: 2023 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

ifconfig athn0 media
 doas ifconfig athn0 nwid uncanny-valley wpakey
