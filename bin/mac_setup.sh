#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: © 2022-2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# ChangeLog:
#

#Black        0;30     Dark Gray     1;30
#Red          0;31     Light Red     1;31
#Green        0;32     Light Green   1;32
#Brown/Orange 0;33     Yellow        1;33
#Blue         0;34     Light Blue    1;34
#Purple       0;35     Light Purple  1;35
#Cyan         0;36     Light Cyan    1;36
#Light Gray   0;37     White         1;37

RED='\033[0;31m'
#LRED='\033[1;31m'
LGREEN='\033[1;32m'
CYAN='\033[0;36m'
#LPURP='\033[1;35m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

MY_ARCH=$(uname -m)

function check_python_version() {
  if ! hash python3; then echo -e "${RED}Python is not installed${NC}" && exit 1; fi

  ver=$(python3 -V 2>&1 | sed 's/.* \([0-9]\).\([0-9]\).*/\1\2/')
  if [ "$ver" -lt "27" ]; then
    echo -e "${RED}This script requires python 2.7 or greater${NC}"
    exit 1
  else
    echo -e "${LGREEN}Found Python $(python3 -V) instaleld${NC}"
  fi
}

function brew_stuff() {
  # install brew if the binary is not found
  # /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # install package with brew
  if brew ls --versions "$1"; then brew upgrade "$1"; else brew install "$1"; fi
}

function install_google_sdk() {
  if [ ${MY_ARCH} == "arm64" ]; then
    MY_FILE="google-cloud-cli-407.0.0-darwin-arm.tar.gz"
  else
    fail "Could not find Google SDK for your arch"
  fi

  if [ ! -e "${HOME}/Downloads/${MY_FILE}" ]; then
    echo -e "${LGREEN}Download ${MY_FILE}${NC}"
    wget -O ${HOME}/Downloads/${MY_FILE} https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/${MY_FILE}
  fi

  if [ ! -d "${HOME}/Downloads/google-cloud-sdk" ]; then
    echo -e "${LGREEN}Unpack ${MY_FILE}${NC}"
    pushd ${HOME}/Downloads && tar xzvf ${HOME}/Downloads/${MY_FILE}
  fi

  pushd ${HOME}/Downloads/google-cloud-sdk
  ${HOME}/Downloads/google-cloud-sdk/install.sh
}

function main() {
  brew_stuff rust # needed to build cryptography for AWS gimme creds
  check_python_version
  brew_stuff wget # needed for Google SDK
  install_google_sdk
}

main
