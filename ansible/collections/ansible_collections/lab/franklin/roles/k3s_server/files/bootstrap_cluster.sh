#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: MIT

BUILD_PREFIX="/mnt/clusterfs2/build"
INSTALL_PREFIX="/mnt/clusterfs2/scratch"
UBUNTU_PKG="libxml2-utils hwloc clustershell python3-clustershell lolcat bison make openmpi-bin openmpi-common openmpi-doc git shellcheck figlet neofetch gfortran"

function configure_nodes() {
  # clush -g gpu sudo cp /mnt/clusterfs2/config.toml.tmpl /var/lib/rancher/k3s/agent/etc/containerd 
  sudo sysctl -w net.ipv6.conf.all.disable_ipv6=1
  sudo sysctl -w net.ipv6.conf.default.disable_ipv6=1
  sudo sysctl -w net.ipv6.conf.lo.disable_ipv6=1
  # curl -sfL https://get.k3s.io | K3S_URL=https://head2.lab.bitsmasher.net:6443 K3S_TOKEN=ATTACKATDAWN sh -
}

function direnv_setup() {
  curl -sfL https://direnv.net/install.sh | bash
  # echo ${HOME}/.bashrc >> eval "$(direnv hook bash)"
}

function helm_setup() {
  # download helm binary
  #scratch/https://get.helm.sh/helm-v3.18.4-linux-arm64.tar.gz
  helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
}

function setup_docker(){
  docker version
  nvidia-docker version | grep NVIDIA
  export DOCKER_COMPOSE_VERSION=1.27.4
  sudo apt-get -y install libhdf5-dev libssl-dev
  sudo pip3 install docker-compose=="${DOCKER_COMPOSE_VERSION}"
  sudo apt-get -y install python3 python3-pip 
  pip install docker-compose
}

function main() {
  hostname=$(hostname)
  echo "Found hostname: ${hostname}"
  if [[ $hostname == "head2.lab.bitsmasher.net" ]]; then
    echo "run this on the cluster nodes" && exit 1
  fi

  #if [ ! -d "${INSTALL_PREFIX}/.build/test" ]; then python3 -m venv "${INSTALL_PREFIX}/.build/test"; fi
  #source "${INSTALL_PREFIX}/venv/bin/activate"
  #python3 -m pip install --upgrade pip
  #
  #python3 -m pip install -r/mnt/clusterfs2/test/requirements.txt

  #sudo tar -C /usr/local -xzf go1.24.4.linux-arm64.tar.gz # install golang

  sudo apt-get install -y ${UBUNTU_PKG}
}

main "$@"
