#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: ©2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: MIT

# ChangeLog:
#
# v0.1 05/16/2025 Maintainer script

RED='\033[0;31m'
LRED='\033[1;31m'
LGREEN='\033[1;32m'
CYAN='\033[0;36m'
LCYAN='\033[1;36m'
LPURP='\033[1;35m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

MY_ANSIBLE_DIR="/home/franklin/workspace/lab-franklin/ansible"
declare MY_ROLES=("nfs")
PYTHON=$(command -v python3 python | head -n1)
PKG_CMD=$(command -v dnf yum apt-get | head -n1)
VENV=""

function check_repo() {
  if [ ! -d "./.git" ]; then
    echo -e "${RED}ERROR: ${YELLOW}Run script from top level of your Git repo${NC}"
    exit 1
  fi
}

function setup_env() {
  sudo ln -s "${MY_ANSIBLE_DIR}/collections" /etc/ansible/collections
  command -v python3 python

  echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"
  for i in "${MY_ROLES[@]}"; do
    "${PYTHON}" -m venv "/tmp/lab.franklin.${i}"
    source "/tmp/lab.franklin.${i}/bin/activate"
    "${PYTHON}" -m pip install -U tox
    "${PYTHON}" -m pip install --upgrade setuptools
  done
}

function verify() {
  echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"
  ansible-galaxy role list
}

function main() {
  echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"
  check_repo
  setup_env
  verify
}

main "$@"
