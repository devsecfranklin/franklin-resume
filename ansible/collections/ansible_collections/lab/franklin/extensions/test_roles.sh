#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: ©2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: MIT

# ChangeLog:
#
# v0.1 05/16/2025 Maintainer script

#RED='\033[0;31m'
LRED='\033[1;31m'
LGREEN='\033[1;32m'
#CYAN='\033[0;36m'
LCYAN='\033[1;36m'
LPURP='\033[1;35m'
#YELLOW='\033[1;33m'
NC='\033[0m' # No Color

declare MY_ROLES=("common" "nfs") # ansible-galaxy role list | sort
# PYTHON=$(command -v python3 python | head -n1)
# PKG_CMD=$(command -v dnf yum apt-get | head -n1)

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
}

function setup_role_test_env() {
  echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"
  echo -e "${LPURP}\nSetting up the environment for role: ${ROLE_NAME}\n${NC}"
  ROLE_TEST_FOLDER="${ANSIBLE_HOME}/tmp"

  if [[ -d "${ROLE_TEST_FOLDER}" ]]; then
    echo -e "${LPURP}Temp directory already exists for role: ${ROLE_NAME}${NC}"
  else
    echo -e "${LGREEN}Copy files for role ${ROLE_NAME} to ${ANSIBLE_ROLES_PATH}/${ROLE_NAME}${NC}"
    cp -R "${ANSIBLE_ROLES_PATH}/${ROLE_NAME}" "${ROLE_TEST_FOLDER}"
  fi

  command -v python3 python

  # "${PYTHON}" -m venv "${VENV}"
  # . "${VENV}/bin/activate"
  # "${PYTHON}" -m pip install -U tox
  # "${PYTHON}" -m pip install --upgrade setuptools
}

function run_scenario() {
  echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"
  echo -e "${LPURP}\nPrepare scenarios for role: ${ROLE_NAME}\n${NC}"

  FOLDERS=$(cd "${ANSIBLE_ROLES_PATH}/${ROLE_NAME}/extensions/molecule" && find -maxdepth 1 -type d | cut -f2 -d/)
  SCENARIO_NAMES="${FOLDERS[*]/'.'/}"

  for SCENARIO_NAME in ${SCENARIO_NAMES}; do
    echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"
    echo -e "${LPURP}\nExexcute scenario: ${SCENARIO_NAME}\n${NC}"
    # Running molecule scenarios using pytest

    # The molecule_scenario fixture provides parameterized molecule scenarios discovered
    # in the collection's extensions/molecule directory, as well as other directories within the collection.

    # molecule test -s <scenario> will be run for each scenario and a completed
    # subprocess returned from the test() call.
    cd "${ROLE_TEST_FOLDER}/${ROLE_NAME}/extensions" && molecule test -s "${SCENARIO_NAME}"
    # rm -rf "${ROLE_TEST_FOLDER}"
  done

}

function main() {

  [[ -n "${ANSIBLE_HOME}" ]] && ANSIBLE_HOME="${HOME}/workspace/lab-franklin/ansible" || echo "ANSIBLE_HOME env var is not set!"
  [[ -n "${ANSIBLE_CONFIG}" ]] && ANSIBLE_CONFIG="${ANSIBLE_HOME}/ansible.cfg" || echo "ANSIBLE_CONFIG env var is not set!"

  echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"
  echo -e "${LRED}$(figlet -d /usr/share/figlet -f smmono9 "Welcome to")${NC}\n"
  echo -e "${LRED}$(figlet -d /usr/share/figlet -f smmono9 bitsmasher.net)${NC}\n"
  echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"

  echo "$BASH: $BASHVERSION"
  for ROLE_NAME in "${MY_ROLES[@]}"; do
    setup_role_test_env
    run_scenario
  done

}

main "$@"
