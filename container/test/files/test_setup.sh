#!/bin/bash -e
set -eux pipefail

# for ansible dev tools
# https://github.com/ansible/ansible-dev-tools
if [[ -f "/usr/bin/apt-get" ]]; then
    sudo apt-get install -y -q libonig-dev tox
fi

if [ ! -d "/etc/ansible" ]; then
  sudo mkdir /etc/ansible
fi
