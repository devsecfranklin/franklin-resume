#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# v0.1 02/06/2021 08:40

set -o nounset # Treat unset variables as an error

#Black        0;30     Dark Gray     1;30
#Red          0;31     Light Red     1;31
#Green        0;32     Light Green   1;32
#Brown/Orange 0;33     Yellow        1;33
#Blue         0;34     Light Blue    1;34
#Purple       0;35     Light Purple  1;35
#Cyan         0;36     Light Cyan    1;36
#Light Gray   0;37     White         1;37

RED='\033[0;31m'
LRED='\033[1;31m'
LGREEN='\033[1;32m'
CYAN='\033[0;36m'
LPURP='\033[1;35m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

#############################
# Do stuff for Debian based #
#############################
function config_deb {
  echo -e "${LPURP}***** Do the Debian Setup *****${NC}"
  grep -Ei 'debian|buntu|mint' /etc/*release

  DEBIAN_FRONTEND=noninteractive apt update
  DEBIAN_FRONTEND=noninteractive apt install -y dialog apt-utils krb5-user
  DEBIAN_FRONTEND=noninteractive apt install -y sshpass neofetch lolcat

  echo -e "${CYAN}"

  PYVER=$(python3 --version)
  if [ -z "$PYVER" ]; then
    echo "$PYVER"
  else
    echo "need to install python?"
  fi
  if [ -e "/usr/bin/pip3" ]; then
    pip --version
  else
    echo "Need to install pip?"
  fi
  if [ -e /usr/bin/aws ]; then
    aws --version
  else
    echo "Need to install awscli"
    #pip install awscli --upgrade --user
  fi
  echo -e "${NC}"

}

function check_if_root {
  if [[ $(id -u) -ne 0 ]]; then echo -e "${RED}This script must be run as root.${NC}" && exit 1; fi
}

function main {
  check_if_root

  if [ "$(uname)" == "Darwin" ]; then
    config_apple
  elif [ "$(uname)" == "OpenBSD" ]; then
    config_obsd
  elif [ "$(grep -Ei 'fedora|redhat' /etc/*release)" ]; then
    config_redhat
  elif [ "$(grep -Ei 'debian|buntu|mint' /etc/*release)" ]; then
    config_deb
  else
    echo "Unable to auto-configure this architecture"
    echo "Please make sure you have all the right packages installed"
    #exit 1
  fi

  #check_terraform
  #check_aws
  #check_terra_config
  #check_do_vars
  #show_summary

}

main
