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
# v1.2 07/28/2025 Remove GNU autotools and add Golang

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
DEB_PKG=(direnv git podman-toolbox nginx certbot)
GO_VERSION="$(go version | awk '{print $3}')"
MY_OS="unknown"
OS_RELEASE="unknown"
RHEL_PKG=(git)

function log_header() {
  printf "\n${LPURP}# --- %s ${NC}\n" "$1"
}
function log_info() { printf "${LBLUE}==>${NC} \e[1m%s\e[0m\n" "$1"; } # Using printf for Bold
function log_warn() { printf >&2 "${YELLOW}WARN:${NC} %s\n" "$1"; }
function log_success() { printf "${LGREEN}==>${NC} \e[1m%s\e[0m\n" "$1"; } # Using printf for Bold
function log_error() {
  printf "${LRED}ERROR: %s${NC}\n" "$1" >&2
  exit 1
}

function check_container() {
  log_header "Check Container Status"
  if [ -f /.dockerenv ]; then
    log_info "Containerized build environment..."
    CONTAINER=true
  else
    log_info "NOT a containerized build environment..."
  fi
}

function check_installed() {
  if ! command -v ${1} &>/dev/null; then
    echo "${1} could not be found"
    exit
  fi
}

function install_debian() {
  # Container package installs will fail unless you do an initial update, the upgrade is optional
  if [ "${CONTAINER}" = true ]; then
    apt-get update && apt-get upgrade -y
  fi

  for i in ${DEB_PKG[@]}; do
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' ${i} | grep "install ok installed") &>/dev/null
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

function setup_golang() {
  #wget https://go.dev/dl/go1.24.4.linux-amd64.tar.gz
  #rm -rf /usr/local/go && tar -C /usr/local -xzf go1.24.4.linux-amd64.tar.gz

  echo "Go version: ${GO_VERSION}"

  if [ ! -f "go.mod" ]; then
    log_info "Initializing go module"
    go mod init github.com/devsecfranklin/website
  fi

  log_info "Tidying up Go modules"
  go mod tidy

  log_info "Installing Go tools"
  go install github.com/mattn/go-sqlite3
  go install github.com/kisielk/errcheck@latest
  go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
  # test/test.sh  <-- What is this for? Is this a comment or needed?

  # Consolidate errcheck installation. No need to do it multiple times.
  if ! command -v errcheck &>/dev/null; then
    go install github.com/kisielk/errcheck@latest
  fi
  # Correct the path for golangci-lint check
  if ! command -v golangci-lint &>/dev/null; then
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
  fi

  # go get is deprecated, consider `go mod tidy` or `go install` where applicable
  #  These lines might cause issues since `internal` is usually not publicly available.
  #  If they are in the same module, just running `go mod tidy` should be sufficient.
  # go get internal/database  #  Consider if this is really needed, and how it's used.
  # go get internal/auth      #  Same here
  # go get internal/cookies   #  Same here
}

function main() {
  check_container
  install_debian
  setup_golang
  go get codeberg.org/go-pdf/fpdf
  go get -u -v codeberg.org/go-pdf/fpdf/...
}

main "$@"