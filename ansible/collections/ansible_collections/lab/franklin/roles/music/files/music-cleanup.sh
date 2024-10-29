#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: © 2022-2024 DE:AD:10:C5 <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# ChangeLog:
#
# v0.1 02/25/2023 initial

MUSIC_DIR="/mnt/storage1/Music/"


du -ach ${MUSIC_DIR} # find the size of the music folder

detox -r -v ${MUSIC_DIR}

#chmod 644 *.mp3 *.jpg *.txt *.png  ${MUSIC_DIR}
chmod 755 $(find ${MUSIC_DIR} -type d)
chmod 644 $(find ${MUSIC_DIR} -type f)

du -ach ${MUSIC_DIR}
