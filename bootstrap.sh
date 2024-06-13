#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# v0.1 02/25/2022 Maintainer script
# v0.2 09/24/2022 Update this script
# v0.3 10/19/2022 Add tool functions
# v0.4 11/10/2022 Add automake check
# v0.5 11/15/2022 Handle Docker container builds

set -eu

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
LBLUE='\033[1;34m'
CYAN='\033[0;36m'
LPURP='\033[1;35m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

MY_OS="unknown"
CONTAINER=false
DOCUMENTATION=false

# Check if we are inside a docker container
function check_docker() {
  if [ -f /.dockerenv ]; then
    echo -e "${LGREEN}Building in container...${NC}"
    CONTAINER=true
  fi
}

function run_autopoint() {
  echo -e "${CYAN}Checking autopoint version...${NC}"
  ver=`autopoint --version | awk '{print $NF; exit}'`
  ap_maj=`echo $ver | sed 's;\..*;;g'`
  ap_min=`echo $ver | sed -e 's;^[0-9]*\.;;g'  -e 's;\..*$;;g'`
  ap_teeny=`echo $ver | sed -e 's;^[0-9]*\.[0-9]*\.;;g'`
  echo "    $ver"

  case $ap_maj in
      0)
          if test $ap_min -lt 14 ; then
              echo "You must have gettext >= 0.14.0 but you seem to have $ver"
              exit 1
          fi
          ;;
  esac
  echo "Running autopoint..."
  autopoint --force || exit 1
}

function run_libtoolize() {
  MY_LIBTOOL="libtoolize"
  if [ "$MY_OS" == "mac" ]; then
    MY_LIBTOOL="glibtoolize"
  fi
  echo "Checking ${MY_LIBTOOL} version..."
  ${MY_LIBTOOL} --version 2>&1 > /dev/null
  rc=$?
  if test $rc -ne 0 ; then
      echo "Could not determine the version of ${MY_LIBTOOL} on your machine"
      echo "${MY_LIBTOOL} --version produced:"
      ${MY_LIBTOOL} --version
      exit 1
  fi
  lt_ver=`${MY_LIBTOOL} --version | awk '{print $NF; exit}'`
  lt_maj=`echo $lt_ver | sed 's;\..*;;g'`
  lt_min=`echo $lt_ver | sed -e 's;^[0-9]*\.;;g'  -e 's;\..*$;;g'`
  lt_teeny=`echo $lt_ver | sed -e 's;^[0-9]*\.[0-9]*\.;;g'`
  echo "    $lt_ver"

  case $lt_maj in
      0)
          echo "You must have libtool >= 1.4.0 but you seem to have $lt_ver"
          exit 1
    ;;

      1)
          if test $lt_min -lt 4 ; then
              echo "You must have libtool >= 1.4.0 but you seem to have $lt_ver"
              exit 1
          fi
          ;;

      2)
          ;;

      *)
          echo "You are running a newer libtool than gerbv has been tested with."
    echo -e "${YELLOW}It will probably work, but this is a warning that it may not.${NC}"
    ;;
  esac
  echo -e "${CYAN}Running ${MY_LIBTOOL}...${NC}"
  ${MY_LIBTOOL} --force --copy --automake || exit 1
}

function run_aclocal() {
  echo -e "${LBLUE}Checking aclocal version...${NC}"
  acl_ver=`aclocal --version | awk '{print $NF; exit}'`
  echo -e "${CYAN}    $acl_ver${NC}"

  echo -e "${CYAN}Running aclocal...${NC}"
  #aclocal -I m4 $ACLOCAL_FLAGS || exit 1
  aclocal -I config || exit 1
  echo -e "${CYAN}.. done with aclocal.${NC}"
}

function run_autoheader() {
  echo -e "${CYAN}Checking autoheader version...${NC}"
  ah_ver=`autoheader --version | awk '{print $NF; exit}'`
  echo -e "${CYAN}    $ah_ver${NC}"

  echo -e "${CYAN}Running autoheader...${NC}"
  autoheader || exit 1
  echo -e "${CYAN}... done with autoheader.${NC}"
}

function run_automake() {
  echo -e "${CYAN}Checking automake version...${NC}"
  am_ver=`automake --version | awk '{print $NF; exit}'`
  echo -e "${CYAN}    $am_ver${NC}"

  echo -e "${CYAN}Running automake...${NC}"
  automake -a -c --add-missing || exit 1
  #automake --force --copy --add-missing || exit 1
  echo -e "${CYAN}... done with automake.${NC}"
}

function run_autoconf() {
  echo -e "${CYAN}Checking autoconf version...${NC}"
  ac_ver=`autoconf --version | awk '{print $NF; exit}'`
  echo -e "${CYAN}    $ac_ver${NC}"

  echo -e "${CYAN}Running autoconf...${NC}"
  autoreconf -i || exit 1
  echo -e "${CYAN}... done with autoconf.${NC}"
}

function check_installed() {
  if ! command -v ${1} &> /dev/null
  then
    echo -e "${CYAN}${1} could not be found${NC}"
    exit
  fi
}

function detect_os() {
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
    else
        echo -e "${YELLOW}Unrecongnized architecture.${NC}"
        exit 1
    fi
}

function install_macos() {
  echo -e "${CYAN}Updating brew for MacOS (this may take a while...)${NC}"
  brew cleanup
  brew upgrade

  echo -e "${CYAN}Setting up autools for MacOS (this may take a while...)${NC}"
  brew install libtool
  brew install automake
  brew install gawk
  # brew install pass # not sure if we need this
}

function install_debian() {
  # sudo apt install gnuplot gawk libtool psutils make autopoint
  #declare -a  Packages=( "doxygen" "gawk" "doxygen-latex" "automake" )
  declare -a Packages=( "git" "make" "automake" "libtool" ) # "chktex" )

  # Container package installs will fail unless you do an initial update, the upgrade is optional
  if [ "${CONTAINER}" = true ]; then
    apt-get update && apt-get upgrade -y
  fi

  for i in ${Packages[@]};
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
  # Container package installs will fail unless you do an initial update, the upgrade is optional
  if [ "${CONTAINER}" = true ]; then
    sudo yum update
  fi 
}

function main() {
  check_docker
  detect_os
  #check_installed doxygen

  if [ ! -d "config/m4" ]; then mkdir -p config/m4; fi

  if [ "${MY_OS}" == "mac" ]; then
    check_installed brew
    install_macos
  fi

  if [ "${MY_OS}" == "rh" ]; then
    install_redhat
  fi

  if [ "${MY_OS}" == "deb" ]; then
    install_debian
  fi

  if [ ! -d "aclocal" ]; then mkdir aclocal; fi
  run_libtoolize
  run_aclocal
  # run_autoheader
  run_automake
  run_autoconf
  ./configure
  #./config.status
}

main
 
