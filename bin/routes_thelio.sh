#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -o nounset # Treat unset variables as an error

#Black        0;30     Dark Gray     1;30
#Red          0;31     Light Red     1;31
#Green        0;32     Light Green   1;32
#Brown/Orange 0;33     Yellow        1;33
#Blue         0;34     Light Blue    1;34
#Purple       0;35     Light Purple  1;35
#Cyan         0;36     Light Cyan    1;36
#Light Gray   0;37     White         1;37

#RED='\033[0;31m'
#LRED='\033[1;31m'
LGREEN='\033[1;32m'
CYAN='\033[0;36m'
#LPURP='\033[1;35m'
#YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function wireless() {
  route add -net 10.10.8.0/21 gw 10.0.0.70
}

function wired() {
  route add -net 0.0.0.0/0 gw 10.10.8.1
}

function route_del() {
  # this will erase the wireless routes
  route delete -net 10.10.8.0/21 gw 10.0.0.70
  route delete 10.0.0.70
  route delete 10.0.0.1
}

function main() {
  wireless
  #wired
  #route_del
}

main "$@"
