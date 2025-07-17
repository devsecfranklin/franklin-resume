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

DEB_PKG=(podman podman-compose)
export HOMELAB_MOLECULE_TEST=true
ROLE_NAME="$1"

function check_installed() {
  if command -v "$1" &>/dev/null; then
    printf "${LBLUE}Found command: %s${NC}\n" "$1"
    return 0
  else
    printf "${LRED}%s could was not found${NC}\n" "$1"
    return 1
  fi
}

function setup_ansible_logging() {
  if [[ -d "var/log/ansible" ]]; then
    echo -e "${LPURP}Found /var/log/ansible.${NC}"
  else
    echo -e "${LCYAN}\n# -------------------- set up ansible logging ---------------------------\n${NC}"
    echo -e "${LPURP}Attempting to create /var/log/ansible..."
    sudo mkdir -p /var/log/ansible
    if [ $? -ne 0 ]; then
      echo -e "${LRED}mkdir command failed.${NC}"
    else
      sudo chown nobody:engr /var/log/ansible
      sudo chmod 770 /var/log/ansible
      echo -e "${LGREEN}Created directory /var/log/ansible${NC}"
    fi
  fi
  # set up molecule
  # python3 -m pip install "molecule-plugins[podman]" podman-compose
  podman --version
  podman-compose --version
}

function prepare_env() {
  # Collections
  ansible-galaxy collection install \
    --collections-path /mnt/storage1/workspace/lab-franklin/ansible/collections \
    containers.podman \
    community.docker \
    ansible.posix \
    --force

  echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"
  echo -e "${LPURP}tell us about molecule\n"
  ansible-galaxy collection list

  FOLDERS=$(cd "${ANSIBLE_ROLES_PATH}/${ROLE_NAME}/extensions/molecule" &&
    find . -maxdepth 1 -type d | cut -f2 -d/)
  SCENARIO_NAMES="${FOLDERS[*]/'.'/}"

  for SCENARIO_NAME in ${SCENARIO_NAMES}; do
    echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"
    echo -e "${LPURP}tell us about molecule\n"
    HOMELAB_MOLECULE_TEST=true molecule --version
    HOMELAB_MOLECULE_TEST=true molecule dependency --scenario-name "${SCENARIO_NAME}"
    echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"
    echo -e "${LPURP}molecule list --scenario-name ${SCENARIO_NAME}\n${NC}"
    HOMELAB_MOLECULE_TEST=true molecule list --scenario-name "${SCENARIO_NAME}"
  done
}

function molecule_check() {
  for SCENARIO_NAME in ${SCENARIO_NAMES}; do
    echo -e "${LCYAN}\n# ---------------------- molecule check -------------------------\n${NC}"
    # HOMELAB_MOLECULE_TEST=true molecule prepare --scenario-name "${SCENARIO_NAME}"
    HOMELAB_MOLECULE_TEST=true molecule check --scenario-name "${SCENARIO_NAME}"
  done
}

function run_tests() {
  for SCENARIO_NAME in ${SCENARIO_NAMES}; do
    echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"
    echo -e "${LPURP}\nExexcute scenario: ${SCENARIO_NAME}\n${NC}"

    echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"
    echo -e "${LPURP}Configuring via podman...\n"
    # HOMELAB_MOLECULE_TEST=true molecule --debug destroy --all --driver-name podman --scenario-name nfs-client
    HOMELAB_MOLECULE_TEST=true molecule destroy --all --driver-name podman --scenario-name "${SCENARIO_NAME}"
    HOMELAB_MOLECULE_TEST=true molecule prepare --driver-name podman --scenario-name "${SCENARIO_NAME}"

    echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"
    echo -e "${LPURP}molecule converge\n"
    HOMELAB_MOLECULE_TEST=true molecule converge --scenario-name "${SCENARIO_NAME}"
    echo -e "${NC}"
  done
}

function main() {
  check_installed podman-compose
  setup_ansible_logging
  pushd "${ROLE_NAME}/extensions" || exit 1
  prepare_env
  molecule destroy
  molecule_check
}

main "$@"
