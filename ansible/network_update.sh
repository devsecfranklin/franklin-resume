#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# v0.1 02/25/2022 Maintainer script
# v0.2 04/22/2024 Add OpenBSD support

#Black        0;30     Dark Gray     1;30
#Red          0;31     Light Red     1;31
#Green        0;32     Light Green   1;32
#Brown/Orange 0;33     Yellow        1;33
#Blue         0;34     Light Blue    1;34
#Purple       0;35     Light Purple  1;35
#Cyan         0;36     Light Cyan    1;36
#Light Gray   0;37     White         1;37

RED='\033[0;31m'
LRED='\033[1;31m'
# LGREEN='\033[1;32m'
CYAN='\033[0;36m'
# LPURP='\033[1;35m'
# YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ETC_DIR="/etc/ansible"
WORKDIR="${PWD}"
PLAYBOOK_DIR="collections/ansible_collections/lab/franklin/playbooks"

# Check if we are inside a docker container
function check_docker() {
  if [ -f /.dockerenv ]; then
    echo -e "${CYAN}Containerized build environment...${NC}" | tee -a "${RAW_OUTPUT}"
    CONTAINER=true
  else
    echo -e "${CYAN}NOT a containerized build environment...${NC}" | tee -a "${RAW_OUTPUT}"
  fi
}

function all_playbooks() {
  # Debian: snowy
  # Do this one first since it is our file server
  echo -e "${CYAN}RUNNING DEBIAN PLAYBOOK${ID}${NC}"
  ansible-playbook "${WORKDIR}/${PLAYBOOK_DIR}/debian.yml" -i "${ETC_DIR}/hosts" -b

  # storage1
  echo -e "${CYAN}RUNNING STORAGE PLAYBOOK${ID}${NC}"
  ansible-playbook "${WORKDIR}/${PLAYBOOK_DIR}/storage.yml" -i "${ETC_DIR}/hosts" -b

  # server1 server2 server3
  echo -e "${CYAN}RUNNING SERVER PLAYBOOK${ID}${NC}"
  ansible-playbook "${WORKDIR}/${PLAYBOOK_DIR}/servers.yml" -i "${ETC_DIR}/hosts" -b -e 'ansible_python_interpreter=/usr/bin/python3'

  # node0 node1 node2 node3
  echo -e "${CYAN}RUNNING RASPI CLUSTER PLAYBOOK${ID}${NC}"
  ansible-playbook "${WORKDIR}/${PLAYBOOK_DIR}/cluster_raspi.yml" -i "${ETC_DIR}/hosts" -b -e 'ansible_python_interpreter=/usr/bin/python3'

  # node900 node901 node902 node903
  echo -e "${CYAN}RUNNING NVIDIA CLUSTER PLAYBOOK${ID}${NC}"
  ansible-playbook "${WORKDIR}/${PLAYBOOK_DIR}/nvidia_nodes.yml" -i "${ETC_DIR}/hosts" -b

  # openbsd
  echo -e "${CYAN}RUNNING OPENBSD PLAYBOOK${NC}"
  ansible-playbook "${WORKDIR}/${PLAYBOOK_DIR}/openbsd.yml" -i "${ETC_DIR}/hosts" -b

  # odroid-c1
  echo -e "${CYAN}RUNNING UBUNTU PLAYBOOK${ID}${NC}"
  ansible-playbook "${WORKDIR}/${PLAYBOOK_DIR}/ubuntu.yml" -i "${ETC_DIR}/hosts" -b
}

function main() {
  
  [[ -n "${ANSIBLE_HOME}" ]] && ANSIBLE_HOME="${HOME}/workspace/lab-franklin/ansible" || echo "ANSIBLE_HOME env var is not set!"
  [[ -n "${ANSIBLE_CONFIG}" ]] && ANSIBLE_CONFIG="${ANSIBLE_HOME}/ansible.cfg" || echo "ANSIBLE_CONFIG env var is not set!"

  echo -e "${LRED}$(figlet -d /usr/share/figlet -f smmono9 "Welcome to")${NC}\n"
  echo -e "${LRED}$(figlet -d /usr/share/figlet -f smmono9 bitsmasher.net)${NC}\n"

  # if [ ! -f "${ETC_DIR}/hosts" ]; then
  #   echo -e "${LRED}Copy the hosts file from ${RED}${WORKDIR}${LRED} to ${RED}${ETC_DIR}${NC}"
  #   exit 1
  # fi

  # copy ${WORKDIR}/ansible.cfg to /etc/ansible
  
  #all_playbooks
}

main "$@"