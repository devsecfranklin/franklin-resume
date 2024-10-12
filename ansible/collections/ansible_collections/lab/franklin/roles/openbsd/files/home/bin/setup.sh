#!/usr/bin/env ksh
#
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# this is the default root shell on OpenBSD first boot

## Reset to normal: \033[0m
NORM="\033[0m"

## Colors:
BLACK="\033[0;30m"
GRAY="\033[1;30m"
RED="\033[0;31m"
LRED="\033[1;31m"
GREEN="\033[0;32m"
LGREEN="\033[1;32m"
YELLOW="\033[0;33m"
LYELLOW="\033[1;33m"
BLUE="\033[0;34m"
LBLUE="\033[1;34m"
PURPLE="\033[0;35m"
PINK="\033[1;35m"
CYAN="\033[0;36m"
LCYAN="\033[1;36m"
LGRAY="\033[0;37m"
WHITE="\033[1;37m"

## Backgrounds
BLACKB="\033[0;40m"
REDB="\033[0;41m"
GREENB="\033[0;42m"
YELLOWB="\033[0;43m"
BLUEB="\033[0;44m"
PURPLEB="\033[0;45m"
CYANB="\033[0;46m"
GREYB="\033[0;47m"

## Attributes:
UNDERLINE="\033[4m"
BOLD="\033[1m"
INVERT="\033[7m"

## Cursor movements
CUR_UP="\033[1A"
CUR_DN="\033[1B"
CUR_LEFT="\033[1D"
CUR_RIGHT="\033[1C"

## Start of display (top left)
SOD="\033[1;1f"

MY_OS="unknown"
CONTAINER=false

# Check if we are inside a docker container
function check_docker {
  if [[ -e "/.dockerenv" ]]
  then
    echo "${RED}Building in container...${NORM}"
    CONTAINER=true
  fi
}

function detect_os {
  if [ "$(uname)" == "Darwin" ]
  then
    echo -e "${CYAN}Detected MacOS${NC}"
    MY_OS="mac"
  elif [ -f "/etc/redhat-release" ]
  then
    echo -e "${CYAN}Detected Red Hat/CentoOS/RHEL${NC}"
    MY_OS="rh"
  elif [ "$(grep -Ei 'debian|buntu|mint' /etc/*release)" ]
  then
    echo -e "${CYAN}Detected Debian/Ubuntu/Mint${NC}"
    MY_OS="deb"
  elif grep -q Microsoft /proc/version
  then
    echo -e "${CYAN}Detected Windows pretending to be Linux${NC}"
    MY_OS="win"
  elif [ "$(uname -s)" == "OpenBSD" ]
  then
    echo -e "${GREEN}Detected OpenBSD${NC}"
    MY_OS="obsd"
  else
    echo -e "${YELLOW}Unrecongnized architecture.${NC}"
    exit 1
  fi
}

function main {
  check_docker
  detect_os

  if [[ $MY_OS != "obsd" ]]; then
    echo -e "${RED}This is not an OpenBSD system. Exiting.${NC}"
    exit 1
  else
    echo -e "${GREEN}Detected OpenBSD${NC}"
  fi

  # NETWORK
  echo "10.10.8.1" > /etc/mygate
  sh /etc/netstart
}

main
