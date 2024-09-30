#!/usr/bin/bash

MUSIC_DIR="/mnt/storage1/Music/"

detox -r -v ${MUSIC_DIR}

#chmod 644 *.mp3 *.jpg *.txt *.png  ${MUSIC_DIR}
chmod 755 $(find ${MUSIC_DIR} -type d)
chmod 644 $(find ${MUSIC_DIR} -type f)

du -ach ${MUSIC_DIR}
