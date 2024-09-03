#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <thedevilsvoice@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

set -o nounset  # Treat unset variables as an error

# disable docker
sudo systemctl disable docker.service --now
sudo apt-get purge docker-ce docker-ce-cli

# update local certs
sudo update-ca-certificates

# disable junk
systemctl disable nm-cloud-setup.service nm-cloud-setup.timer reboot

# install master node
#curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644 \
#--disable servicelb --token some_random_password --node-taint CriticalAddonsOnly=true:NoExecute \
#--bind-address 10.10.12.18 --disable-cloud-controller --disable local-storage

# install sever
hostname=`hostname`
echo "Found hostname: ${hostname}"

if [[ $hostname == "head1.lab.bitsmasher.net" ]]; then
  curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644 --node-name ${hostname}
else
  export K3S_URL="https://10.10.12.18:6443"
  export K3S_TOKEN="K10e03d0a2089241be4e045af28f831dc78a594675d60e41518b5e36f1785fce5a0::server:1e04ea44e0ffdc32e79bf2a56e8a2ad8"
  curl -sfL https://get.k3s.io | sh - 
fi
