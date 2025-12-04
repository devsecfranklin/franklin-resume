#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

#===============================================================================
#
#          FILE: install_packages.sh
#
#         USAGE: ./install_packages.sh
#
#   DESCRIPTION:
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: YOUR NAME (),
#  ORGANIZATION:
#       CREATED: 02/16/2018 21:29
#      REVISION:  ---
#===============================================================================

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

usage() {

  cat <<-EOF
  usage: $PROGNAME options

    OPTIONS:
      -v --verbose             Verbose.
      -x --debug               debug
      -h --help                show this help
          --help-config         configuration help
EOF

}

function check_if_root {

  if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
  else
    echo "Running as root"
  fi

  return 0

}

#############################
# Do stuff for Debian based #
#############################
function check_apt_inst() {

  PKG=$1

  if [ $(dpkg-query -W -f='${Status}' ${PKG} 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
    echo -e "${YELLOW}Installing ${PKG}${NC}"
    apt-get install --yes ${PKG}
  else
    echo -e "${LGREEN}Found package: ${PKG}${NC}"
  fi

}

function config_deb {

  echo -e "${LPURP}***** Do the Debian Setup *****${NC}"
  grep -Ei 'debian|buntu|mint' /etc/*release
  #sudo apt-get install software-properties-common gnupg git \
  #python-pip mlocate awscli
  declare -a pkgs=("software-properties-common" "gnupg" "git" "python-pip"
    "mlocate" "awscli")
  for i in "${pkgs[@]}"; do
    check_apt_inst "$i"
  done

  echo -e "${CYAN}"

  PYVER=$(python --version)
  if [ -z "$PYVER" ]; then
    echo "$PYVER"
  else
    echo "need to install python?"
  fi
  if [ -e "/usr/bin/pip" ]; then
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
  # BATS package for Ubuntu, not Debian
  #sudo add-apt-repository ppa:duggan/bats
  #sudo apt-get update
  #sudo apt-get install bats

}

#######################
# Do stuff for RedHat #
#######################
function config_redhat {

  echo -e "${LPURP}***** Do the RedHat setup *****${NC}"
  sudo yum update -y
  sudo yum groupinstall 'Development Tools'

}

########################
# Do stuff for FreeBSD #
########################

########################
# Do stuff for OpenBSD #
########################
function config_obsd {
  echo -e "${LPURP}***** Do the Setup for OpenBSD *****${NC}"
  echo 'export PKG_PATH=ftp://mirror.planetunix.net/pub/OpenBSD/`uname -r`/packages/`machine -a`/' >>~/.profile
  #pkg_add -Uu
  pkg_add ftp://mirror.planetunix.net/OpenBSD/$(uname -r)/packages/$(machine -a)/python-2.7.13p0.tgz
  ln -sf /usr/local/bin/python2.7 /usr/local/bin/python
  ln -sf /usr/local/bin/python2.7-2to3 /usr/local/bin/2to3
  ln -sf /usr/local/bin/python2.7-config /usr/local/bin/python-config
  #ln -sf /usr/local/bin/pydoc2.7  /usr/local/bin/pydoc
  pkg_add py-pip py-boto
  pkg_add -i -v bash
  pip install awscli aws-shell terraform
  #/usr/bin/doas -u root pkg_add -v bash

}

######################
# Do Stuff for Apple #
######################
function config_apple {
  echo -e "${LPURP}***** Do the Setup for Mac *****${NC}"
  if [ -e "/usr/local/bin/brew" ]; then
    brew update
    brew upgrade
    brew install terraform
    brew install awscli
    # alternative awscli install method, requires brew
    #cd /tmp && curl -o awscli.zip https://s3.amazonaws.com/aws-cli/awscli-bundle.zip
    #unzip /tmp/awscli.zip
    #sudo ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws
    echo -e "${LPURP}***** Mac Setup Complete *****${NC}"
  else
    echo -e "${YELLOW}"
    echo "Install brew from here: https://brew.sh/ and run this script again."
    echo -e "${NC}"
    ERROR_COUNTER=$((ERROR_COUNTER + 1))
  fi

  return 0

}

function main {

  if [ "$(uname)" == "Darwin" ]; then
    config_apple
  elif [ "$(uname)" == "OpenBSD" ]; then
    config_obsd
  elif [ "$(grep -Ei 'fedora|redhat' /etc/*release)" ]; then
    check_if_root
    config_redhat
  elif [ "$(grep -Ei 'debian|buntu|mint' /etc/*release)" ]; then
    check_if_root
    config_deb
  else
    echo "Unable to auto-configure this architecture"
    exit 1
  fi

}

main $@
