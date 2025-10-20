#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

FILEPATH=/sys/bus/i2c/devices/2-0050/eeprom

function read_sn {
  data1=$(xxd -s 0x6 -l 16 -g 1 $FILEPATH |
    awk '{ print $2$3$4$5$6$7$8$9$10$11$12$13$14$15$16$17 }')
  data2=$(xxd -s 0x16 -l 4 -g 1 $FILEPATH |
    awk '{ print $2$3$4$5 }')

  idx=0
  while [ $idx -lt 32 ]; do
    val=${data1:$idx:2}
    if [ "${val}" != "00" ]; then
      tmp=$(printf "${val}\n")
      SN="$SN$tmp"
    fi
    idx=$((idx + 2))
  done
  idx=0
  while [ $idx -lt 8 ]; do
    val=${data2:$idx:2}
    if [ "${val}" != "00" ]; then
      tmp=$(printf "${val}\n")
      SN="$SN$tmp"
    fi
    idx=$((idx + 2))
  done

  echo $SN
  exit 1
}

read_sn
