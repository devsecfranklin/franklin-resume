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

# set up molecule
# python3 -m pip install "molecule-plugins[podman]"

# Collections
ansible-galaxy collection install \
  --collections-path /mnt/storage1/workspace/lab-franklin/ansible/collections \
  containers.podman community.docker ansible.posix --force


echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"
echo -e "${LPURP}tell us about molecule\n"
ansible-galaxy collection list

echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"
echo -e "${LPURP}tell us about molecule\n"
molecule --version
molecule dependency --scenario-name default

echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"
echo -e "${LPURP}molecule check\n"
molecule check

echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"
echo -e "${LPURP}molecule list\n"
molecule list

echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"
echo -e "${LPURP}preparing podman...\n"
molecule --debug destroy --all --driver-name podman
molecule prepare --driver-name podman

echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"
echo -e "${LPURP}molecule converge\n"
molecule converge

echo -e "${NC}"
