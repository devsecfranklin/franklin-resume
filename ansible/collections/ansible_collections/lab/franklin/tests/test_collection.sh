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

# ~/workspace/lab-franklin/ansible/collections/ansible_collections/lab/franklin

# Ensure pytest is being run from the collection's root directory, adjacent to the galaxy.yml

function setup_ansible_logging() {
  if [[ -d "var/log/ansible" ]]; then
    echo -e "${LPURP}Found /var/log/ansible.${NC}"
  else
    echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"
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
    find -maxdepth 1 -type d | cut -f2 -d/)
  SCENARIO_NAMES="${FOLDERS[*]/'.'/}"

  for SCENARIO_NAME in ${SCENARIO_NAMES}; do
    echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"
    echo -e "${LPURP}tell us about molecule\n"
    HOMELAB_MOLECULE_TEST=true molecule --version
    HOMELAB_MOLECULE_TEST=true molecule dependency --scenario-name "${SCENARIO_NAME}"
    echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"
    echo -e "${LPURP}molecule list --scenario-name ${SCENARIO_NAME}\n{NC}"
    HOMELAB_MOLECULE_TEST=true molecule list --scenario-name "${SCENARIO_NAME}"
  done
}

function molecule_check() {
  for SCENARIO_NAME in ${SCENARIO_NAMES}; do
    echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"
    echo -e "${LPURP}molecule check\n"
    HOMELAB_MOLECULE_TEST=true molecule check --scenario-name "${SCENARIO_NAME}"
  done
}

function main() {

  setup_ansible_logging
  prepare_env
  molecule_check

  ansible-galaxy collection list

  ansible-galaxy collection install containers.podman --upgrade
  ansible-galaxy collection install paloaltonetworks.panos --force
  ansible-galaxy collection install ansible.posix --force

}

main "$@"
