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
LGREEN='\033[1;32m'
CYAN='\033[0;36m'
LPURP='\033[1;35m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

ETC_DIR="/etc/ansible"
WORKDIR="/home/franklin/workspace/LAB/lab-home/ansible"

function directories() {
  # /etc/ansible/group_vars -> /home/franklin/workspace/LAB/lab-franklin/ansible/group_vars
  # /etc/ansible/roles -> /home/franklin/workspace/LAB/lab-franklin/ansible/roles
  # /etc/ansible/hosts -> /home/franklin/workspace/LAB/lab-franklin/ansible/hosts
  pass
}

function main() {
echo -e "${LRED} _     _ _                           _                          _   "
echo -e "| |__ (_) |_ ___ _ __ ___   __ _ ___| |__   ___ _ __ _ __   ___| |_ "
echo -e "| '_ \| | __/ __| '_ \` _ \ / _\` / __| '_ \ / _ \ '__| '_ \ / _ \ __|"
echo -e "| |_) | | |_\__ \ | | | | | (_| \__ \ | | |  __/ | _| | | |  __/ |_ "
echo -e "|_.__/|_|\__|___/_| |_| |_|\__,_|___/_| |_|\___|_|(_)_| |_|\___|\__|${NC}\n"

# Debian: snowy
echo -e "${CYAN}RUNNING DEBIAN PLAYBOOK${ID}${NC}"
ansible-playbook playbook/debian.yml -i ${WORKDIR}/hosts -b

# storage1
echo -e "${CYAN}RUNNING STORAGE PLAYBOOK${ID}${NC}"
ansible-playbook playbook/storage.yml -i ${WORKDIR}/hosts -b

# server1 server2 server3
echo -e "${CYAN}RUNNING SERVER PLAYBOOK${ID}${NC}"
ansible-playbook playbook/servers.yml -i ${WORKDIR}/hosts -b -e 'ansible_python_interpreter=/usr/bin/python3'

# node0 node1 node2 node3
echo -e "${CYAN}RUNNING RASPI CLUSTER PLAYBOOK${ID}${NC}"
ansible-playbook playbook/raspi_nodes.yml -i ${WORKDIR}/hosts -b -e 'ansible_python_interpreter=/usr/bin/python3'

# node900 node901 node902 node903
echo -e "${CYAN}RUNNING NVIDIA CLUSTER PLAYBOOK${ID}${NC}"
ansible-playbook playbook/nvidia_nodes.yml -i ${WORKDIR}/hosts -b

# openbsd
echo -e "${CYAN}RUNNING OPENBSD PLAYBOOK${NC}"
ansible-playbook playbook/openbsd.yml -i ${WORKDIR}/hosts -b

# odroid-c1
echo -e "${CYAN}RUNNING UBUNTU PLAYBOOK${ID}${NC}"
ansible-playbook playbook/ubuntu.yml -i ${WORKDIR}/hosts -b
}

main "$@"
