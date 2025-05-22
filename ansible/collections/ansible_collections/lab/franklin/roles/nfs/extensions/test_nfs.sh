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
# HOMELAB_MOLECULE_TEST=true ./test_nfs.sh

# set up molecule
# python3 -m pip install "molecule-plugins[podman]"

sudo mkdir /var/log/ansible
sudo chmod 777 /var/log/ansible

# Collections
ansible-galaxy collection install \
  --collections-path /mnt/storage1/workspace/lab-franklin/ansible/collections \
  containers.podman community.docker ansible.posix --force


echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"
echo -e "${LPURP}tell us about molecule\n"
ansible-galaxy collection list

echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"
echo -e "${LPURP}tell us about molecule\n"
HOMELAB_MOLECULE_TEST=true molecule --version
HOMELAB_MOLECULE_TEST=true molecule dependency --scenario-name nfs-client 

echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"
echo -e "${LPURP}molecule check\n"
HOMELAB_MOLECULE_TEST=true molecule check --scenario-name nfs-client  

echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"
echo -e "${LPURP}molecule list\n"
HOMELAB_MOLECULE_TEST=true molecule list --scenario-name nfs-client 

echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"
echo -e "${LPURP}preparing podman...\n"
HOMELAB_MOLECULE_TEST=true molecule --debug destroy --all --driver-name podman --scenario-name nfs-client 
HOMELAB_MOLECULE_TEST=true molecule create --driver-name podman --scenario-name nfs-client 

echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"
echo -e "${LPURP}molecule converge\n"
HOMELAB_MOLECULE_TEST=true molecule converge --scenario-name nfs-client 
echo -e "${NC}"
