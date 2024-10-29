#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: © 2024 Palo Alto Networks, Inc.  All rights reserved. <fdiaz@paloaltonetworks.com>
#
# SPDX-License-Identifier: https://www.paloaltonetworks.com/legal/script-software-license-1-0.pdf

# v0.1 | 07/09/2024 | initial version | franklin

sudo groupadd docker
sudo usermod -aG docker $USER
sudo apt-get update && sudo apt-get install -y docker-compose-plugin
sudo chmod a+rw /var/run/docker.sock
export DOCKER_CONFIG="/usr/libexec/docker"
sudo chgrp docker /usr/libexec/docker/
sudo chmod g+w /usr/libexec/docker
#export DOCKER_CONFIG="~/.docker/cli-plugins"
chmod +x ${DOCKER_CONFIG}/cli-plugins/docker-compose
