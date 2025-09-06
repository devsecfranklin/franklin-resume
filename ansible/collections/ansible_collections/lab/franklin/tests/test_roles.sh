#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: ©2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: MIT

# run like so
# HOMELAB_MOLECULE_TEST=true ./test_role.sh {{rolename}}

# ChangeLog:
#
# v0.1 05/16/2025 Maintainer script

#RED='\033[0;31m'
LRED='\033[1;31m'
LGREEN='\033[1;32m'
#CYAN='\033[0;36m'
LCYAN='\033[1;36m'
LPURP='\033[1;35m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

MY_ROLES=(ntp) # ansible-galaxy role list | sort
ANSIBLE_ROLES_PATH="${ANSIBLE_COLLECTIONS_PATH}/ansible_collections/lab/franklin/roles"
export HOMELAB_MOLECULE_TEST=true
SCENARIO_NAMES=""

# --- Helper Functions for Logging ---
log_info() { printf "\n${LBLUE}==>${NC} \e[1m%s\e[0m\n" "$1"; } # Using printf for Bold
log_warn() { printf >&2 "\n${YELLOW}WARN:${NC} %s" "$1"; }
log_success() { printf "\n${LGREEN}==>${NC} \e[1m%s\e[0m" "$1"; } # Using printf for Bold
log_error() {
  printf "${LRED}ERROR: %s${NC}\n" "$1" >&2
  exit 1
}
log_header() {
  printf "\n${LPURP}# --- %s ${NC}\n" "$1"
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
  for ROLE_NAME in "${MY_ROLES[@]}"; do
    MOLECULE_EXEC_DIR="${ANSIBLE_ROLES_PATH}/${ROLE_NAME}/extensions"
    TEST_DIR="${MOLECULE_EXEC_DIR:?}/molecule"

    log_header "collect scenario names in: ${TEST_DIR}"

    FOLDERS=$(cd "${TEST_DIR}" &&
      find . -maxdepth 1 -type d | cut -f2 -d/)
    SCENARIO_NAMES="${FOLDERS[*]/'.'/}"
  done

  verify_test_files

  for SCENARIO_NAME in ${SCENARIO_NAMES}; do
    cd "${MOLECULE_EXEC_DIR}" && HOMELAB_MOLECULE_TEST=true molecule reset --scenario-name "${SCENARIO_NAME}" && (cd - || log_error "unable to cd")
    log_info "check scenario: ${SCENARIO_NAME}"
    log_info "molecule list --scenario-name ${SCENARIO_NAME}"
    cd "${MOLECULE_EXEC_DIR}" && HOMELAB_MOLECULE_TEST=true molecule list --scenario-name "${SCENARIO_NAME}" && (cd - || log_error "unable to cd")
  done

  log_info "do python stuff"
  # PYTHON=$(command -v python3 python | head -n1)
  command -v python3 python
  # "${PYTHON}" -m venv "${VENV}"
  # . "${VENV}/bin/activate"
  # "${PYTHON}" -m pip install -U tox
  # "${PYTHON}" -m pip install --upgrade setuptools
}

function run_scenario() {
  SCENARIO_NAME=$(echo "$1" | xargs)
  log_header "Run scenario: ${SCENARIO_NAME}"
  MOLECULE_EXEC_DIR="${ANSIBLE_ROLES_PATH}/${ROLE_NAME}/extensions"
  TEST_DIR="${MOLECULE_EXEC_DIR:?}/molecule"
  verify_test_files
  log_info "molecule destroy"
  cd "${MOLECULE_EXEC_DIR}" && HOMELAB_MOLECULE_TEST=true molecule destroy -s "${SCENARIO_NAME}" && (cd - || log_error "unable to cd")
  log_info "molecule prepare"
  cd "${MOLECULE_EXEC_DIR}" && HOMELAB_MOLECULE_TEST=true molecule prepare -s "${SCENARIO_NAME}" && (cd - || log_error "unable to cd")
  log_info "molecule create"
  cd "${MOLECULE_EXEC_DIR}" && HOMELAB_MOLECULE_TEST=true molecule create -s "${SCENARIO_NAME}" && (cd - || log_error "unable to cd")
  log_info "molecule test"
  cd "${MOLECULE_EXEC_DIR}" && HOMELAB_MOLECULE_TEST=true molecule test -s "${SCENARIO_NAME}" && (cd - || log_error "unable to cd")
  # Running molecule scenarios using pytest
}

function verify_test_files() {
  log_header "verify test files exist"
  TEST_FILES=(collections.yml create.yml converge.yml destroy.yml molecule.yml prepare.yml verify.yml)
  for TEST_FILE in "${TEST_FILES[@]}"; do
    if [ -f "${ANSIBLE_ROLES_PATH}/${ROLE_NAME}/extensions/molecule/default/${TEST_FILE}" ]; then
      log_success "Found file: ${TEST_FILE}"
    else
      log_warn "Did not find file, copying to test dir: ${TEST_FILE}"
      cp -r "${ANSIBLE_COLLECTIONS_PATH}/ansible_collections/lab/franklin/tests/extensions/molecule/default/${TEST_FILE}" "${MOLECULE_EXEC_DIR}/molecule/"
      cp
    fi
  done
  echo -e "\n\n"
}

function cleanup_tmp() {
  log_header "Cleaning up!!!"
  for ROLE_NAME in "${MY_ROLES[@]}"; do
    echo -e "Removing ${ANSIBLE_LOCAL_TEMP}/${ROLE_NAME}"
    #rm -rf "${ANSIBLE_ROLES_PATH:?}/${ROLE_NAME:?}"
  done
}

# function install_debian() {
#   PKG_CMD=$(command -v dnf yum apt-get | head -n1)
#   DEB_PKG=(podman podman-compose)
#   python3 -m pip install "molecule-plugins[podman]" --break-system-packages

# }

function main() {
  setup_ansible_logging
  [[ -n "${ANSIBLE_HOME}" ]] && ANSIBLE_HOME="${HOME}/workspace/lab-franklin/ansible" || echo "ANSIBLE_HOME env var is not set!"
  [[ -n "${ANSIBLE_CONFIG}" ]] && ANSIBLE_CONFIG="${ANSIBLE_HOME}/ansible.cfg" || echo "ANSIBLE_CONFIG env var is not set!"

  # cleanup_tmp # nopt needed rn
  echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"
  echo -e "${LRED}$(figlet -d /usr/share/figlet -f mono9 "Welcome to")${NC}\n"
  echo -e "${LRED}$(figlet -d /usr/share/figlet -f mono9 bitsmasher.net)${NC}\n"
  echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"

  prepare_env # set up the roles

  for SCENARIO_NAME in "${SCENARIO_NAMES[@]}"; do
    if [ "${SCENARIO_NAME}" != "molecule" ]; then
      run_scenario "${SCENARIO_NAME}"
    fi
  done
}

main "$@"
