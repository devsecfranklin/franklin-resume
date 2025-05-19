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

ansible-galaxy collection list

ansible-galaxy collection install containers.podman --upgrade
ansible-galaxy collection install paloaltonetworks.panos --force
ansible-galaxy collection install ansible.posix --force
