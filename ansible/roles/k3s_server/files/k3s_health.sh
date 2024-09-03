#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <thedevilsvoice@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -o nounset  # Treat unset variables as an error

#Black        0;30     Dark Gray     1;30
#Red          0;31     Light Red     1;31
#Green        0;32     Light Green   1;32
#Brown/Orange 0;33     Yellow        1;33
#Blue         0;34     Light Blue    1;34
#Purple       0;35     Light Purple  1;35
#Cyan         0;36     Light Cyan    1;36
#Light Gray   0;37     White         1;37

RED='\033[0;31m'
#LRED='\033[1;31m'
#LGREEN='\033[1;32m'
CYAN='\033[0;36m'
#LPURP='\033[1;35m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function run_command() {
  ansible nodes -a "${1}" -b -i /mnt/storage1/workspace/lab-home/ansible/hosts
}

function main() {
  echo -e "${CYAN}Cluster health check script${NC}"

  #nvidia-container-runtime --version

  # should exist
  run_command "ls /etc/rancher/k3s/config.yaml"
   
  # should be 64 bit
  run_command "docker version" 

  # should be 64 bit
  run_command "gcc --version" 

  # Try to curl the certs on the master node:
  curl -vk https://10.10.12.18:6443/cacerts
}

main
