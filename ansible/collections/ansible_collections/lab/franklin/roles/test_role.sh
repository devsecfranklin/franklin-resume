#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: ©2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: MIT

# ChangeLog:
#
# v0.1 05/16/2025 Initial Version

RED='\033[0;31m'
LRED='\033[1;31m'
LGREEN='\033[1;32m'
CYAN='\033[0;36m'
LCYAN='\033[1;36m'
LPURP='\033[1;35m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# run like so
# HOMELAB_MOLECULE_TEST=true ./test_role.sh {{rolename}}

#DEB_PKG=(podman podman-compose)
export HOMELAB_MOLECULE_TEST=true
ROLE_NAME="$1"
MOLECULE_EXEC_DIR="${ANSIBLE_ROLES_PATH}/${ROLE_NAME}/extensions"
TEST_DIR="${MOLECULE_EXEC_DIR:?}/molecule"

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

function check_for_file() {
  log_info "Check for file: $1"
  if [ ! -e "$1" ]; then
    log_error "Missing file: $1"
  fi
}

function check_installed() {
  if command -v "$1" &>/dev/null; then
    log_success "Found command: $1"
    return 0
  else
    log_error "$1 could not be found"
  fi
}

function setup_ansible_logging() {
  log_header "set up ansible logging"
  if [[ -d "/var/log/ansible" ]]; then
    log_info "Found /var/log/ansible"
  else
    log_info "Attempting to create /var/log/ansible..."
    sudo mkdir -p /var/log/ansible
    if ! 0; then
      log_error "mkdir command failed"
    else
      sudo chown nobody:engr /var/log/ansible
      sudo chmod 770 /var/log/ansible
      log_info "Created directory /var/log/ansible"
    fi
  fi
}

function prepare_env() {
  log_header "Prepare the Test Environment"

  log_info "setup test dir: ${ANSIBLE_LOCAL_TEMP}/${ROLE_NAME}"
  if [ -d "${ANSIBLE_LOCAL_TEMP}/${ROLE_NAME}" ]; then
    log_warn "erase stale role test files"
    rm -rf "${ANSIBLE_LOCAL_TEMP:?}/${ROLE_NAME}"
  fi

  log_info "Copy in Default files" # copy these in first
  mkdir -p "${MOLECULE_EXEC_DIR}"
  cp -Rp "${ANSIBLE_COLLECTIONS_PATH}/ansible_collections/lab/franklin/tests/extensions/molecule" "${MOLECULE_EXEC_DIR}"

  log_info "Copying role to tmp dir: ${ANSIBLE_LOCAL_TEMP:?}" # then overwrite the ones you have customized
  cp -Rp "${ANSIBLE_ROLES_PATH}/${ROLE_NAME}" "${ANSIBLE_LOCAL_TEMP:?}"

  log_info "collect scenario names"
  FOLDERS=$(cd "${TEST_DIR}" &&
    find . -maxdepth 1 -type d | cut -f2 -d/)
  SCENARIO_NAMES="${FOLDERS[*]/'.'/}"

  for SCENARIO_NAME in ${SCENARIO_NAMES}; do
    log_info "check scenario: ${SCENARIO_NAME}"
    log_info "molecule list --scenario-name ${SCENARIO_NAME}"
    pushd "${MOLECULE_EXEC_DIR}" || log_error "big fail"
    HOMELAB_MOLECULE_TEST=true molecule list --scenario-name "${SCENARIO_NAME}"
    popd || log_error "failed"
  done
}

function setup_test_files() {
  log_info "Copy files for role ${ROLE_NAME} to ${ANSIBLE_LOCAL_TEMP}/${ROLE_NAME}"
  MY_FILES=(collections.yml create.yml converge.yml destroy.yml molecule.yml prepare.yml verify.yml)

  #mkdir -p "${ANSIBLE_ROLES_PATH}/${ROLE_NAME}"
  cp -R "${ANSIBLE_ROLES_PATH}/${ROLE_NAME}/extensions/molecule" "${ANSIBLE_LOCAL_TEMP}/${ROLE_NAME}"

  command -v python3 python
  # "${PYTHON}" -m venv "${VENV}"
  # . "${VENV}/bin/activate"
  # "${PYTHON}" -m pip install -U tox
  # "${PYTHON}" -m pip install --upgrade setuptools
}

function molecule_check() {
  # python3 -m pip install "molecule-plugins[podman]" podman-compose # set up molecule

  for SCENARIO_NAME in ${SCENARIO_NAMES}; do
    log_header "molecule setup for scenario: ${SCENARIO_NAME}"
    pushd "${MOLECULE_EXEC_DIR}" || log_error "no such directory: ${MOLECULE_EXEC_DIR}"
    #log_info "pwd: $(ls -al molecule/)"
    log_header "molecule prepare"
    HOMELAB_MOLECULE_TEST=true molecule prepare --scenario-name "${SCENARIO_NAME}"
    log_info "tell us about molecule"
    HOMELAB_MOLECULE_TEST=true molecule --version
    log_info "molecule dependencies"
    HOMELAB_MOLECULE_TEST=true molecule dependency --scenario-name "${SCENARIO_NAME}"
    log_info "molecule check"
    HOMELAB_MOLECULE_TEST=true molecule check --scenario-name "${SCENARIO_NAME}"
    popd || log_error "no such directory"
  done
}

function run_tests() {
  for SCENARIO_NAME in ${SCENARIO_NAMES}; do
    log_header "Exexcute scenario: ${SCENARIO_NAME}"
    pushd "${ANSIBLE_HOME:?}/${ROLE_NAME}/extensions" || log_error "no such directory"
    log_info "${LPURP}Configuring via podman"
    # HOMELAB_MOLECULE_TEST=true molecule --debug destroy --all --driver-name podman --scenario-name nfs-client
    HOMELAB_MOLECULE_TEST=true molecule destroy --all --driver-name podman --scenario-name "${SCENARIO_NAME}"
    HOMELAB_MOLECULE_TEST=true molecule prepare --driver-name podman --scenario-name "${SCENARIO_NAME}"

    log_info "molecule converge"
    sudo chmod -R 777 /mnt/storage1/workspace/lab-franklin/ansible/tmp
    HOMELAB_MOLECULE_TEST=true molecule converge --scenario-name "${SCENARIO_NAME}"
    popd || log_error "no such directory"
  done
}

function main() {
  log_header "Ansible testing for role: $1"
  #check_installed podman-compose
  #check_installed podman
  #check_installed molecule
  #setup_ansible_logging
  prepare_env
  molecule destroy
  molecule_check
}

main "$@"
