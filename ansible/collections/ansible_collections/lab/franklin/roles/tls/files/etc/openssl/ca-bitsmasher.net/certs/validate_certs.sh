#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: ©2021-2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: MIT

set -euo pipefail # Exit on error, exit on unset variables, fail if any command in a pipe fails.
IFS=$'\n\t'        # Preserve newlines and tabs in word splitting.

# --- Terminal Colors ---
LRED='\033[1;31m'
LGREEN='\033[1;32m'
LBLUE='\033[1;34m'
CYAN='\033[0;36m'
LPURP='\033[1;35m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- Helper Functions for Logging ---
log_header() {
    echo -e "\n${LPURP}# --- $1 ${NC}"
}

log_info() {
    echo -e "${LBLUE}$1${NC}"
}

log_success() {
    echo -e "${LGREEN}$1${NC}"
}

log_error() {
    echo -e "${LRED}ERROR: $1${NC}" >&2
    exit 1
}

FILES=$(ls *.crt | cut -f1 -d'.')
FILES_CLEANED=$(echo "${FILES}" | grep -v "intermediate" | grep -v "root")
PWD=$(pwd)

for MYCRT in $FILES_CLEANED; do
  log_info "Validating certificate: ${MYCRT}"
  openssl verify "${PWD}/${MYCRT}.crt" || log_error "validation failed for: ${MYCRT}"
  log_success "validated: ${MYCRT}.crt"
  log_info "Validating certificate: ${MYCRT}-chain.pem"
  openssl verify "${PWD}/${MYCRT}-chain.pem"
  log_success "validated: ${MYCRT}-chain.pem"
done
