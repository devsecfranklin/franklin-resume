#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023-2025 franklin <smoooth.y62wj@passmail.net>
#
# SPDX-License-Identifier: MIT

#RED='\033[0;31m'
LRED='\033[1;31m'
LGREEN='\033[1;32m'
#CYAN='\033[0;36m'
LCYAN='\033[1;36m'
LPURP='\033[1;35m'
#YELLOW='\033[1;33m'
NC='\033[0m' # No Color

COLLECTION_DIR="${ANSIBLE_COLLECTIONS_PATH}/ansible_collections/lab/franklin"

# --- Helper Functions for Logging ---
log_header() {
  printf "\n${LPURP}# --- %s ${NC}\n" "$1"
}

log_info() { printf "\n${LBLUE}==>${NC} \e[1m%s\e[0m\n\n" "$1"; } # Using printf for Bold
log_warn() { printf >&2 "\n${YELLOW}WARN:${NC} %s\n" "$1"; }
log_success() { printf "\n${LGREEN}==>${NC} \e[1m%s\e[0m\n" "$1"; } # Using printf for Bold

log_error() {
  printf "${LRED}ERROR: %s${NC}\n" "$1" >&2
  exit 1
}

function verify_collections() {
  log_header "Verify Ansible Collections"

  MY_COLLECTIONS=(containers.podman community.docker ansible.posix)
  for COLLECTION in "${MY_COLLECTIONS[@]}"; do
    log_info "verify collection: ${COLLECTION}"
    if ! ansible-galaxy collection verify "${COLLECTION}"; then
      log_warn "installing ${COLLECTION}"
      ansible-galaxy collection install --collections-path "${ANSIBLE_COLLECTIONS_PATH}" --force "${COLLECTION}"
    fi
  done
}

function build_collection() {
  MY_COLELCTION="lab.franklin"
  log_header "Verify ${MY_COLLECTION} collection package"

  pushd "${COLLECTION_DIR}" || log_error "Directory not found ${COLLECTION_DIR}"
  if [ ! -f "${COLLECTION_DIR}/galaxy.yml" ]; then
    log_info "building collection: ${MY_COLLECTION}"
    ansible-galaxy collection build # generates MANIFEST.json and FILES.json
  else
    log_success "Found file: ${COLLECTION_DIR}/galaxy.yml"
  fi
}

function main() {
  verify_collections
  build_collection

  log_info "list local from ansible galaxy collections"
  ansible-galaxy collection list

  # https://docs.ansible.com/ansible/latest/dev_guide/developing_collections_testing.html
  #ansible-test sanity --docker default -v
}

main "$@"
