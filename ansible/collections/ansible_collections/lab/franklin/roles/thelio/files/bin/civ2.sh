#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# WINEARCH=win64
export WINEPREFIX=/home/franklin/.wine
export WINEDEBUG="-all"


wine /home/franklin/.wine/drive_c/Program\ Files/MPS/CIV2/CIV2.EXE
#cd /home/franklin/.wine/drive_c/MPS/CIV2 && env ${WINEPREFIX} wine CIV2.EXE

