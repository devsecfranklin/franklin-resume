#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: ©2025 franklin <smoooth.y62wj@passmail.net>
#
# SPDX-License-Identifier: MIT


# ChangeLog:
#
# v0.1 06/11/2025 Project Maintainer script

set -euo pipefail # Exit on error, exit on unset variables, fail if any command in a pipe fails.
IFS=$'\n\t'        # Preserve newlines and tabs in word splitting.

# --- Terminal Colors ---
LRED='\033[1;31m'
LGREEN='\033[1;32m'
LBLUE='\033[1;34m'
CYAN='\033[0;36m'
LPURP='\033[1;35m'
NC='\033[0m' # No Color

# --- Helper Functions for Logging ---
log_header() {
    printf "\n${LPURP}# --- %s ${NC}\n" "$1"
}

log_info() { printf "${LBLUE}==>${NC} \e[1m%s\e[0m\n" "$1"; } # Using printf for Bold
log_warn() { printf >&2 "${YELLOW}WARN:${NC} %s\n" "$1"; }
log_success() { printf "${LGREEN}==>${NC} \e[1m%s\e[0m\n" "$1"; } # Using printf for Bold

log_error() {
    printf "${LRED}ERROR: %s${NC}\n" "$1" >&2
    exit 1
}

# --- Some config Variables ----------------------------------------
CONTAINER=false
GO_VERSION="$(/usr/local/go/bin/go version | awk '{print $3}')"
DEB_PKG=(nginx certbot)


check_container() { # Check if we are inside a container
  log_header "Check Container Status"
  if [ -f /.dockerenv ]; then
    log_info "Containerized build environment..."
    CONTAINER=true
  else
    log_info "NOT a containerized build environment..."
  fi
}

function setup_golang() {
  log_header "setup golang"

  #wget https://go.dev/dl/go1.24.4.linux-amd64.tar.gz
  #rm -rf /usr/local/go && tar -C /usr/local -xzf go1.24.4.linux-amd64.tar.gz

  echo "Go version: ${GO_VERSION}"

  if [ ! -f "go.mod" ]; then
    log_info "Initializing go module"
    /usr/local/go/bin/go mod init github.com/devsecfranklin/franklin-resume
  fi

  log_info "Tidying up Go modules"
  /usr/local/go/bin/go mod tidy

  
  # /usr/local/go/bin/go get github.com/mattn/go-sqlite3


  if ! command -v errcheck &>/dev/null; then
    log_info "Installing errcheck"
    /usr/local/go/bin/go install github.com/kisielk/errcheck@latest
  fi

  if ! command -v golangci-lint &>/dev/null; then
    log_info "Installing golang CI"
    /usr/local/go/bin/go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
  fi
  
  # go get is deprecated, consider `go mod tidy` or `go install` where applicable
  #  These lines might cause issues since `internal` is usually not publicly available.
  #  If they are in the same module, just running `go mod tidy` should be sufficient.
  # go get internal/database  #  Consider if this is really needed, and how it's used.
  # go get internal/auth      #  Same here
  # go get internal/cookies   #  Same here
}

check_installed() {
  if ! command -v "$1" &>/dev/null; then
    log_warn "$1 could not be found"
  fi
}

main() {
  check_installed figlet
  check_container
  setup_golang
}

main "$@"

