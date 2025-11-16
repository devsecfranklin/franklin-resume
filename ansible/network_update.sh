#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2021-2025 franklin <smoooth.y62wj@passmail.net>
#
# SPDX-License-Identifier: MIT

# v0.1 02/25/2022 Maintainer script
# v0.2 04/22/2024 Add OpenBSD support
# v0.3 09/22/2025 Major change to the logicdddd

#set -euo pipefail # Exit on error, exit on unset variables, fail if any command in a pipe fails.
#IFS=$'\n\t'        # Preserve newlines and tabs in word splitting.

# --- Terminal Colors ---
LRED='\033[1;31m'
LGREEN='\033[1;32m'
LBLUE='\033[1;34m'
CYAN='\033[0;36m'
LPURP='\033[1;35m'
NC='\033[0m' # No Color

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

function check_container() {
  log_header "Check Container Status ------------------------------------------" && echo -e "\n"
  if [ -f /.dockerenv ]; then
    log_warn "Containerized build environment..." && echo -e "\n"
    CONTAINER=true
  else
    log_info "NOT a containerized build environment" && echo -e "\n"
  fi
}

function check_installed() {
  if command -v "${1}" &>/dev/null; then
    log_info "Found command: ${1}" && echo -e "\n"
    return 0
  else
    log_warn "${1} was not found" && echo -e "\n"
    return 1
  fi
}

# it also needs to account for failures in apt-get
function apt-get-target() {

  # for the 32 bit armhf hosts
  # sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6ED0E7B82643E131 78DBA3BC47EF2265 F8D2585B8783D481

  CLUSH_GROUPS=(compute gpu)

  for i in "${CLUSH_GROUPS[@]}"; do
    # check_installed sshpass
    clush -v -g "${i}" env DEBIAN_FRONTEND="noninteractive" sudo apt-get -y install sshpass
    log_header "Update the ${i} nodes  ------------------------------------------" && echo -e "\n"
    clush -v -g "${i}" sudo apt-get update
    log_header "Upgrade the ${i} nodes  ------------------------------------------" && echo -e "\n"
    clush -v -g "${i}" env DEBIAN_FRONTEND="noninteractive" sudo apt-get -y upgrade
    log_header "Autoremove on the ${i} nodes  ------------------------------------------" && echo -e "\n"
    clush -v -g "${i}" sudo apt-get -y autoremove
  done
}

function openbsd() {
  log_header "setup OpenBSD  ------------------------------------------" && echo -e "\n"
  ansible -m raw -a "pkg_add -y python" -b -i ./hosts blowfish.lab.bitsmasher.net
}

function main() {

  # [[ -n "${ANSIBLE_HOME}" ]] && ANSIBLE_HOME="${HOME}/workspace/lab-franklin/ansible" || log_warn "ANSIBLE_HOME env var is not set!"
  #[[ -n "${ANSIBLE_CONFIG}" ]] && ANSIBLE_CONFIG="${ANSIBLE_HOME}/ansible.cfg" || log_warn "ANSIBLE_CONFIG env var is not set!"
  if [ -z ${ANSIBLE_HOME+x} ]; then
    echo "ANSIBLE_HOME is unset"
    export ANSIBLE_HOME="/mnt/clusterfs2/workspace/lab-franklin/ansible"
  fi 
  echo "ANSIBLE_HOME is set to ${ANSIBLE_HOME}"

  #echo -e "${LRED}$(figlet -d /usr/share/figlet -f block "Welcome to")${NC}\n"
  #echo -e "${LRED}$(figlet -d /usr/share/figlet -f block bitsmasher.net)${NC}\n"

  check_container
  # configure_head_node
  apt-get-target
  # openbsd

  log_header "RUNNING MAIN PLAYBOOK  ------------------------------------------"
  ansible-playbook "${ANSIBLE_PLAYBOOK_DIR}/playbook.yml" -i ./hosts -b
}

main "$@"
