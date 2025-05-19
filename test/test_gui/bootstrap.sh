#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: © 2022-2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# ChangeLog:
#
# v0.1 02/25/2022 Maintainer script
# v0.2 09/24/2022 Update this script
# v0.3 10/19/2022 Add tool functions
# v0.4 11/10/2022 Add automake check
# v0.5 11/16/2022 Handle Docker container builds
# v0.6 07/13/2023 Add required_files and OpenBSD support
# v0.7 04/22/2024 More OpenBSD support
# v0.8 09/06/2024 Support GCP Linux
# v0.9 02/18/2025 Updates for Mac
# v1.0 02/26/2025 Optimize some functions using Gemini 2.0 Flash
# v1.1 04/14/2025 Add shfmt as a function here instead of standalone

set -euo pipefail
IFS=$'\n\t'

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

RED='\033[0;31m'
LRED='\033[1;31m'
LGREEN='\033[1;32m'
LBLUE='\033[1;34m'
CYAN='\033[0;36m'
LPURP='\033[1;35m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

CONTAINER=false
MY_OS="unknown"
WORKDIR=${PWD##*/}    # to assign to a variable
WORKDIR=${WORKDIR:-/} # to correct for the case where PWD is / (root)

# Check if we are inside a docker container
function check_docker() {
  if [ -f /.dockerenv ]; then
    echo -e "${CYAN}Containerized build environment...${NC}"
    CONTAINER=true
  else
    echo -e "${CYAN}NOT a containerized build environment...${NC}"
  fi
}

function detect_os() {
  # check for the /etc/os-release file
  if [ -f "/etc/os-release" ]; then
    OS_RELEASE=$(cat /etc/os-release | grep "^ID=" | cut -d"=" -f2)
  fi

  if [ -n "${OS_RELEASE}" ]; then
    echo -e "${CYAN}Found /etc/os-release file: ${OS_RELEASE}${NC}"
  fi

  # Check uname (Linux, OpenBSD, Darwin)
  MY_UNAME=$(uname)
  if [ -n "${OS_RELEASE}" ]; then
    echo -e "${CYAN}Found uname: ${MY_UNAME}${NC}"
  fi

  if [ "${MY_UNAME}" == "OpenBSD" ]; then
    echo -e "${CYAN}Detected OpenBSD${NC}"
    MY_OS="openbsd"
  elif [ "${MY_UNAME}" == "Darwin" ]; then
    echo -e "${CYAN}Detected MacOS${NC}"
    MY_OS="mac"
  elif [ -f "/etc/redhat-release" ]; then
    echo -e "${CYAN}Detected Red Hat/CentoOS/RHEL${NC}"
    MY_OS="rh"
  elif [ "$(grep -Ei 'debian|buntu|mint' /etc/*release)" ]; then
    echo -e "${CYAN}Detected Debian/Ubuntu/Mint${NC}"
    MY_OS="deb"
  elif grep -q Microsoft /proc/version; then
    echo -e "${CYAN}Detected Windows pretending to be Linux${NC}"
    MY_OS="win"
  else
    echo -e "${YELLOW}Unrecongnized architecture.${NC}"
    exit 1
  fi
}

function format_shell() {
  # To install shfmt
  # curl -sS https://webi.sh/shfmt | sh

  if ! command -v shfmt &>/dev/null; then
    echo "shfmt not found... installing!"
    curl -sS https://webi.sh/shfmt | sh
  fi

  if [ ! -d "docs" ] && [ ! -d "bin" ]; then
    echo "Run script from top level of repo"
    exit 1
  fi

  if ! command -v shfmt &>/dev/null; then
    echo "shfmt not found... installing!"
    curl -sS https://webi.sh/shfmt | sh
    MY_SHFMT="${HOME}/.local/bin/shfmt"
  else
    MY_SHFMT=$(which shfmt)
  fi

  echo "Checking file: ${WORKDIR}/bootstrap.sh"
  ${MY_SHFMT} -i 2 -l -w "${WORKDIR}/bootstrap.sh"

  for filename in "bin"/*.sh; do
    echo "Checking file: ${WORKDIR}/${filename}"
    ${MY_SHFMT} -i 2 -l -w "${WORKDIR}/${filename}"
  done

  for filename in "${WORKDIR}/bin"/*.sh; do
    echo "Checking file: ${WORKDIR}/${filename}"
    ${MY_SHFMT} -i 2 -l -w "${WORKDIR}/${filename}"
  done

}

function run_autopoint() {
  echo "Checking autopoint version..."
  ver=$(autopoint --version | awk '{print $NF; exit}')
  ap_maj=$(echo $ver | sed 's;\..*;;g')
  ap_min=$(echo $ver | sed -e 's;^[0-9]*\.;;g' -e 's;\..*$;;g')
  ap_teeny=$(echo $ver | sed -e 's;^[0-9]*\.[0-9]*\.;;g')
  echo "    $ver"

  case $ap_maj in
  0)
    if test $ap_min -lt 14; then
      echo "You must have gettext >= 0.14.0 but you seem to have $ver"
      exit 1
    fi
    ;;
  esac
  echo "Running autopoint..."
  autopoint --force || exit 1
}

function run_libtoolize() {
  echo "Checking libtoolize version..."
  libtoolize --version 2>&1 >/dev/null
  rc=$?
  if test $rc -ne 0; then
    echo "Could not determine the version of libtool on your machine"
    echo "libtool --version produced:"
    libtool --version
    exit 1
  fi
  lt_ver=$(libtoolize --version | awk '{print $NF; exit}')
  lt_maj=$(echo $lt_ver | sed 's;\..*;;g')
  lt_min=$(echo $lt_ver | sed -e 's;^[0-9]*\.;;g' -e 's;\..*$;;g')
  #lt_teeny=$(echo $lt_ver | sed -e 's;^[0-9]*\.[0-9]*\.;;g')
  echo "    $lt_ver"

  case $lt_maj in
  0)
    echo "You must have libtool >= 1.4.0 but you seem to have ${lt_ver}"
    exit 1
    ;;
  1)
    if test "${lt_min}" -lt 4; then
      echo "You must have libtool >= 1.4.0 but you seem to have ${lt_ver}"
      exit 1
    fi
    ;;
  2) ;;
  *)
    echo "You are running a newer libtool than gerbv has been tested with."
    echo "It will probably work, but this is a warning that it may not."
    ;;
  esac
  echo "Running libtoolize..."
  libtoolize --force --copy --automake || exit 1
}

function run_aclocal() {
  if [ "${MY_OS}" != "openbsd" ]; then
    echo -e "${LBLUE}Checking aclocal version...${NC}"
    acl_ver=$(aclocal --version | awk '{print $NF; exit}')
    echo "    $acl_ver"

    echo -e "${CYAN}Running aclocal...${NC}"
    #aclocal -I m4 $ACLOCAL_FLAGS || exit 1
    aclocal -Iaclocal/latex-m4 || exit 1
  else
    AUTOCONF_VERSION=2.71 AUTOMAKE_VERSION=1.16 aclocal || exit 1
  fi
  echo -e "${CYAN}.. done with aclocal.${NC}"
}

function run_autoheader() {
  echo "Checking autoheader version..."
  ah_ver=$(autoheader --version | awk '{print $NF; exit}')
  echo "    $ah_ver"

  echo "Running autoheader..."
  autoheader || exit 1
  echo "... done with autoheader."
}

function run_automake() {
  if [ "${MY_OS}" != "openbsd" ]; then
    echo "Checking automake version..."
    am_ver=$(automake --version | awk '{print $NF; exit}')
    echo "    $am_ver"

    echo "Running automake..."
    automake -a -c --add-missing || exit 1
    #automake --force --copy --add-missing || exit 1
  else
    AUTOCONF_VERSION=2.71 AUTOMAKE_VERSION=1.16 automake -a -c --add-missing || exit 1
  fi
  echo "... done with automake."
}

function run_autoconf() {
  if [ "${MY_OS}" != "openbsd" ]; then
    echo -e "${LGREEN}Checking autoconf version...${NC}"
    ac_ver=$(autoconf --version | awk '{print $NF; exit}')
    echo -e "${LGREEN}Autoconf version: $ac_ver${NC}"
    echo "Running autoconf..."
    autoreconf -i || exit 1
  else
    # this is for OpenBSD systems
    ac_ver="2.71"
    echo "Running autoconf..."
    AUTOCONF_VERSION=2.71 AUTOMAKE_VERSION=1.16 autoreconf -i || exit 1
  fi
  echo "... done with autoconf."
}

function main() {

  sudo apt install -y clang-format clang-tidy build-essential gdb
  clang-format -i src/main.c
  clang-format --style Google --dump-config >.clang-format
  clang-tidy --dump-config >.clang-tidy

  # build folder
  if [ ! -d "${WORKDIR}/build/logs" ]; then mkdir -p "${WORKDIR}build/logs"; fi

  # create configure.scan
  # autoscan && mv configure.scan configure.ac
  if [ -f "autoscan.log" ]; then mv autoscan.log "${WORKDIR}build/logs"; fi

  if [ ! -f "Makefile.in" ] && [ -f "./config.status" ]; then
    rm config.status # if Makefile.in is missing, then erase stale config.status
  fi

  if [ ! -f "./config.status" ]; then
    echo -e "${YELLOW}no config.status${NC}"
    # libtoolize
    if [ ! -d "aclocal" ]; then mkdir aclocal; fi
    #aclocal -I config
    run_aclocal
    if [ "${MY_OS}" == "openbsd" ]; then
      AUTOCONF_VERSION=2.71 AUTOMAKE_VERSION=1.16 autoreconf -i || exit 1
    else
      autoreconf -i
    fi
    #automake -a -c --add-missing
    run_automake
    ./configure
  else
    ./config.status
  fi
}

main "$@"
