#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2021-2025 franklin <smoooth.y62wj@passmail.net>
#
# SPDX-License-Identifier: MIT

# ChangeLog:


set -o nounset  # Treat unset variables as an error

KUBECONFIG=/etc/rancher/k3s/k3s.yaml
LRED='\033[1;31m'

function cluster_labels() {

  kubectl label nodes node900.lab.bitsmasher.net board=nvidia-jetson
  kubectl label nodes node901.lab.bitsmasher.net board=nvidia-jetson
  kubectl label nodes node0.lab.bitsmasher.net board=raspi-4b
  kubectl label nodes node1.lab.bitsmasher.net board=raspi-4b
  kubectl label nodes node2.lab.bitsmasher.net board=raspi-4b
  kubectl label nodes node3.lab.bitsmasher.net board=raspi-4b
}

function cluster_health(){
  kubectl get nodes
  kubectl get pods --all-namespaces

  cat /etc/nv_tegra_release
  cat /etc/os-release

  apt-cache show nvidia-jetpack

  #sudo apt-get install mesa-utils

  glxinfo

}


function run_command() {
  ansible nodes -a "${1}" -b -i /mnt/storage1/workspace/lab-home/ansible/hosts
}

function main() {

  figlet -f fonts/pagga kubernetes && echo -e "\n"
  if [ -f "./bin/common.sh" ]; then
    source "./bin/common.sh"
  else
    echo -e "${LRED}can not find common.sh.${NC}"
    exit 1
  fi
  log_info "successfully sourced common.sh" && echo -e "\n"

  log_header "Cluster status tool"

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

main "$@"