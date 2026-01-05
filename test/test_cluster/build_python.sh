#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023-2025 franklin <smoooth.y62wj@passmail.net>
#
# SPDX-License-Identifier: MIT

# ChangeLog:
#
# v0.1

#set -euo pipefail

# SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="/mnt/storage1/workspace/lab-franklin/bin"
if [ -d "${SCRIPT_DIR}" ]; then source "${SCRIPT_DIR}/common.sh"; else log_error "Unable to find your script directory"; fi

log_header "Preparing your environment, please stand by" && echo -e "\n"

log_info "load the common functions" && echo -e "\n"


sudo apt update
sudo apt install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
    libsqlite3-dev wget curl llvm libncursesw5-dev xz-utils tk-dev libffi-dev liblzma-dev \
	python3-openssl git

curl https://pyenv.run | bash

# export PYENV_ROOT="$HOME/.pyenv"
# export PATH="$PYENV_ROOT/bin:$PATH"
# eval "$(pyenv init --path)"
# eval "$(pyenv init -)"

# pyenv install --list
pyenv install 3.11.13
# pyenv global 3.12.2

# Navigate to your project directory
#cd my-project
# Set the local Python version
#pyenv local 3.12.2
