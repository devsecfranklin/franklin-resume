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

HOST=$(hostname | cut -f1 -d'.')
PWD=$(pwd)

echo -e "${CYAN} This is host: ${HOST}${NC}"
cp "${PWD}/ca-bitsmasher.net/certs/root-ca.crt" "${PWD}/ca-bitsmasher.net/certs/${HOST}.crt" "${PWD}/ca-bitsmasher.net/certs/${HOST}-chain.pem" /etc/ssl/certs
cp "${PWD}/ca-bitsmasher.net/private/${HOST}.key" "${PWD}/ca-bitsmasher.net/private/intermediate-ca.key" "${PWD}/ca-bitsmasher.net/private/root-ca.key" /etc/ssl/private