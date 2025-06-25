#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: ©2021-2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: MIT

# ChangeLog:
#
# v0.1 02/25/2022 Maintainer script
# v0.2 09/24/2022 Update this script
# v0.3 10/19/2022 Add tool functions
# v0.4 11/10/2022 Add automake check
# v0.5 11/16/2022 Handle container builds
# v0.6 07/13/2023 Add required_files and OpenBSD support
# v0.7 04/22/2024 More OpenBSD support
# v0.8 09/06/2024 Support GCP Linux
# v0.9 02/18/2025 Updates for Mac
# v1.0 02/26/2025 Optimize some functions using Gemini 2.0 Flash
# v1.1 05/29/2025 Update the OS Detection function, add HW Detection function

#set -euo pipefail

# The special shell variable IFS determines how Bash
# recognizes word boundaries while splitting a sequence of character strings.
#IFS=$'\n\t'

#Black        0;30     Dark Gray     1;30
#Red          0;31     Light Red     1;31
#Green        0;32     Light Green   1;32
#Brown/Orange 0;33     Yellow        1;33
#Blue         0;34     Light Blue    1;34
#Purple       0;35     Light Purple  1;35
#Cyan         0;36     Light Cyan    1;36
#Light Gray   0;37     White         1;37

#RED='\033[0;31m'
LRED='\033[1;31m'
LGREEN='\033[1;32m'
LBLUE='\033[1;34m'
CYAN='\033[0;36m'
LPURP='\033[1;35m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- Some config Variables ----------------------------------------
CONTAINER=false
DEB_PKG=(direnv git podman-toolbox)
MAC_PKG=(git)
MY_OS="unknown"
OS_RELEASE="unknown"
RHEL_PKG=(git)

function check_container() { # Check if we are inside a container
  if [ -f /.dockerenv ]; then
    echo -e "${CYAN}Containerized build environment...${NC}"
    CONTAINER=true
  else
    echo -e "${CYAN}NOT a containerized build environment...${NC}"
  fi
}

function detect_os() {
  if [ -f "/etc/os-release" ]; then  # check for the /etc/os-release file
    OS_RELEASE=$(grep "^ID=" /etc/os-release | cut -d"=" -f2)
    echo -e "${CYAN}Found /etc/os-release file: ${OS_RELEASE}${NC}"
  else
    echo -e "${YELLOW}NO /etc/os-release file found.${NC}"
  fi

  MY_UNAME=$(uname) # Check uname (Linux, OpenBSD, Darwin)
  if [ -n "${OS_RELEASE}" ]; then
    echo -e "${CYAN}Found uname: ${MY_UNAME}${NC}"
  fi

  if [ "${MY_UNAME}" == "OpenBSD" ]
  then
    echo -e "${CYAN}Detected OpenBSD${NC}"
    MY_OS="openbsd"
  elif [ "${MY_UNAME}" == "Darwin" ]
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
  else
    echo -e "${YELLOW}Unrecongnized architecture.${NC}"
    exit 1
  fi
}

function check_installed() {
  if ! command -v ${1} &> /dev/null
  then
    echo "${1} could not be found"
    exit
  fi
}

function install_macos() {
  echo -e "${CYAN}Updating brew for MacOS (this may take a while...)${NC}"
  
  brew cleanup
  brew upgrade

  for i in ${MAC_PKG[@]};
  do
    brew install "${i}"
  done
}

function install_debian() {
  # Container package installs will fail unless you do an initial update, the upgrade is optional
  if [ "${CONTAINER}" = true ]; then
    apt-get update && apt-get upgrade -y
  fi

  for i in ${DEB_PKG[@]};
  do
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' ${i}|grep "install ok installed") &> /dev/null
    # echo -e "${LBLUE}Checking for ${i}: ${PKG_OK}${NC}"
    if [ "" = "${PKG_OK}" ]; then
      echo -e "${LBLUE}Installing ${i} since it is not found.${NC}"

      # If we are in a container there is no sudo in Debian
      if [ "${CONTAINER}" = true ]; then
        apt-get --yes install ${i}
      else
        sudo apt-get install ${i} -y
      fi
    fi
  done
}

function install_redhat() {
  echo -e "${CYAN}RedHat 8 setup${NC}"
  dnf upgrade -y
  yum -y --disableplugin=subscription-manager update
  dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

  for i in ${RHEL_PKG[@]};
  do
    dnf install -y ${i} --skip-broken
  done
}

function main() {
  check_container
  detect_os

  case "${MY_OS}" in
  "mac")
    check_installed brew
    install_macos
  ;;
  "rh")
    install_redhat
  ;;

  "deb")
    install_debian
  ;;
  *)
    echo "what are you doing, Dave?"
  ;;
  esac
}

main "$@"
