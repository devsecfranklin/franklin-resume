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

declare MY_ROLES=(common cluster nfs ntp raspberrypi security ssh) # ansible-galaxy role list | sort
declare PKG=(podman-compose)
ANSIBLE_ROLES_PATH="${ANSIBLE_COLLECTIONS_PATH}/ansible_collections/lab/franklin/roles"
MOLECULE="${HOME}/.local/bin/molecule"
# PYTHON=$(command -v python3 python | head -n1)
# PKG_CMD=$(command -v dnf yum apt-get | head -n1)
WORK_DIR="$PWD"

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

function setup_role_test_env() {
  echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"
  echo -e "${LPURP}\nSetting up the environment for role: ${ROLE_NAME}\n${NC}"

  echo -e "${LGREEN}Copy files for role ${ROLE_NAME} to ${ANSIBLE_LOCAL_TEMP}/${ROLE_NAME}${NC}"
  #mkdir -p "${ANSIBLE_ROLES_PATH}/${ROLE_NAME}"
  cp -R "${ANSIBLE_ROLES_PATH}/${ROLE_NAME}" "${ANSIBLE_LOCAL_TEMP}/${ROLE_NAME}"

  command -v python3 python
  # "${PYTHON}" -m venv "${VENV}"
  # . "${VENV}/bin/activate"
  # "${PYTHON}" -m pip install -U tox
  # "${PYTHON}" -m pip install --upgrade setuptools
}

function run_scenario() {
  echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"
  echo -e "${LPURP}\nPrepare scenarios for role: ${ROLE_NAME}\n${NC}"

  FOLDERS=$(cd "${ANSIBLE_ROLES_PATH}/${ROLE_NAME}/extensions/molecule" && \
    find "${ANSIBLE_ROLES_PATH}/${ROLE_NAME}/extensions/molecule" -maxdepth 1 -type d | rev | cut -f1 -d/ | rev)
  SCENARIO_NAMES="${FOLDERS[*]/'.'/}"

  #echo "folders: $FOLDERS"
  #echo "scenarios: $SCENARIO_NAMES"

  for SCENARIO_NAME in ${SCENARIO_NAMES}; do
    if [ "${SCENARIO_NAME}" != "molecule" ]; then
      echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"
      echo -e "${LPURP}\nExexcute scenario: ${SCENARIO_NAME}\n${NC}"
      # echo "work dir: ${WORK_DIR}"

      # MOLECULE_FILES=(
      #   "${ANSIBLE_ROLES_PATH}/${ROLE_NAME}/extensions/molecule/default/collections.yml"
      # )

      # cp -R "${ANSIBLE_ROLES_PATH}/${ROLE_NAME}/extensions/molecule/default/collections.yml" \
      #   "${ANSIBLE_ROLES_PATH}/${ROLE_NAME}/extensions/molecule/default/destroy.yml" \
      #   "${ANSIBLE_ROLES_PATH}/${ROLE_NAME}/extensions/molecule/default/prepare.yml" \
      #   "${ANSIBLE_ROLES_PATH}/${ROLE_NAME}/extensions/molecule/default/create.yml" \
      #   "${ANSIBLE_ROLES_PATH}/${ROLE_NAME}/extensions/molecule/default/tasks" \
      #   "${ANSIBLE_ROLES_PATH}/${ROLE_NAME}/extensions/molecule/default/tests" \
      #   "${ANSIBLE_LOCAL_TEMP}/${ROLE_NAME}/extensions/molecule/${SCENARIO_NAME}/"

      # for ii in ${MOLECULE_FILES}; do
      #   if [ -f "$ii" ] || [ -d "$ii" ]; then cp -Rp $ii "${ANSIBLE_LOCAL_TEMP}/${ROLE_NAME}/extensions/molecule/${SCENARIO_NAME}/"; fi
      # done
      # Running molecule scenarios using pytest

      # The molecule_scenario fixture provides parameterized molecule scenarios discovered
      # in the collection's extensions/molecule directory, as well as other directories within the collection.

      # molecule test -s <scenario> will be run for each scenario and a completed
      # subprocess returned from the test() call.
      # pushd "${ANSIBLE_LOCAL_TEMP}/${ROLE_NAME}/extensions" || exit 1
      pushd "${ANSIBLE_ROLES_PATH}/${ROLE_NAME}/extensions" || exit 1
      # echo "pwd $(pwd)"
      "${MOLECULE}" destroy -s "${SCENARIO_NAME}"
      "${MOLECULE}" prepare -s "${SCENARIO_NAME}"
      "${MOLECULE}" create -s "${SCENARIO_NAME}"
      "${MOLECULE}" test -s "${SCENARIO_NAME}"
      popd

    fi
  done
}

function cleanup() {
  echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"
  echo -e "${LCYAN}Cleaning up!!! ${NC}"
  for ROLE_NAME in "${MY_ROLES[@]}"; do
    echo -e "Removing ${ANSIBLE_LOCAL_TEMP}/${ROLE_NAME}"
    rm -rf "${ANSIBLE_LOCAL_TEMP:?}/${ROLE_NAME:?}"
  done
}

function main() {

  [[ -n "${ANSIBLE_HOME}" ]] && ANSIBLE_HOME="${HOME}/workspace/lab-franklin/ansible" || echo "ANSIBLE_HOME env var is not set!"
  [[ -n "${ANSIBLE_CONFIG}" ]] && ANSIBLE_CONFIG="${ANSIBLE_HOME}/ansible.cfg" || echo "ANSIBLE_CONFIG env var is not set!"

  cleanup

  echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"
  echo -e "${LRED}$(figlet -d /usr/share/figlet/fonts -f smmono9 "Welcome to")${NC}\n"
  echo -e "${LRED}$(figlet -d /usr/share/figlet/fonts -f smmono9 bitsmasher.net)${NC}\n"
  echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"

  for ROLE_NAME in "${MY_ROLES[@]}"; do
    setup_role_test_env
    run_scenario
  done

 echo "rtf: $ANSIBLE_LOCAL_TEMP"

}

main "$@"
