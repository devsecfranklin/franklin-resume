#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# v0.1 02/25/2022 Maintainer script
# v0.2 04/22/2024 Add OpenBSD support

#set -euo pipefail # Exit on error, exit on unset variables, fail if any command in a pipe fails.
#IFS=$'\n\t'        # Preserve newlines and tabs in word splitting.

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

ETC_DIR="${ANSIBLE_HOME}"

# Check if we are inside a docker container
function check_docker() {
	if [ -f "/.dockerenv" ]; then
		log_warn "Containerized build environment..."
		CONTAINER=true
	else
		log_info "NOT a containerized build environment"
	fi
}

function openbsd() {
  log_header "setup OpenBSD"
	ansible -m raw -a "pkg install -y python" -b ./hosts blowfish
}

function main() {

	[[ -n "${ANSIBLE_HOME}" ]] && ANSIBLE_HOME="${HOME}/workspace/lab-franklin/ansible" || echo "ANSIBLE_HOME env var is not set!"
	[[ -n "${ANSIBLE_CONFIG}" ]] && ANSIBLE_CONFIG="${ANSIBLE_HOME}/ansible.cfg" || echo "ANSIBLE_CONFIG env var is not set!"

	#echo -e "${LRED}$(figlet -d /usr/share/figlet -f block "Welcome to")${NC}\n"
	#echo -e "${LRED}$(figlet -d /usr/share/figlet -f block bitsmasher.net)${NC}\n"

  ansible raspi_nodes -a 'apt update' -b -i "${ANSIBLE_HOME}/hosts"

	log_header "RUNNING MAIN PLAYBOOK"
	ansible-playbook "${ANSIBLE_PLAYBOOK_DIR}/playbook.yml" -i ./hosts -b

}

main "$@"
