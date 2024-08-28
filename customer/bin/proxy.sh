#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: © 2024 Palo Alto Networks, Inc.  All rights reserved. <fdiaz@paloaltonetworks.com>
#
# SPDX-License-Identifier: https://www.paloaltonetworks.com/legal/script-software-license-1-0.pdf

# v0.1 | 02/15/2024 | initial version | franklin

#PROXY_HOST="63.171.196.203" # oasis - sandbox
PROXY_HOST="153.2.227.107" # njrar testnet panorama

export http_proxy=http://${PROXY_HOST}:8080
export https_proxy=https://${PROXY_HOST}:8080

read -p "Enter username: " MY_USERNAME
stty -echo
printf "Enter Password: "
read MY_PASSWORD
stty echo
printf "\n"

MY_CREDS=$(echo "${MY_USERNAME}:${MY_PASSWORD}" | base64)
ENCRYPT_CREDS=$(echo $MY_CREDS | openssl enc -aes-128-cbc -a)

export http_proxy="http://$(echo \"${ENCRYPT_CREDS}\" | openssl enc -aes-128-cbc -a -d | base64 -d)@${PROXY_HOST}:8080/"
export https_proxy="https://$(echo \"${ENCRYPT_CREDS}\" | openssl enc -aes-128-cbc -a -d | base64 -d)@${PROXY_HOST}:8080/"

echo "Checking if git is installed..."
if ! command -v git &>/dev/null; then
  echo "git could not be found"
  exit 1
else
  echo "Setting git proxy"
  git config --global http.proxy ${http_proxy}
fi
