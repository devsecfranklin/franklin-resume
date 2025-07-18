#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: © 2022-2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# ChangeLog:
#

# v0.1 | 02/15/2024 | initial version | franklin
# v0.2 | 10/05/2024 | check the scripts in test/ | franklin

# To install shfmt
# curl -sS https://webi.sh/shfmt | sh

#set -euo pipefail
#IFS=$'\n\t'

if ! command -v shfmt &>/dev/null; then
  echo "shfmt not found... installing!"
  curl -sS https://webi.sh/shfmt | sh
fi

if [ ! -d "./.git" ]; then
  echo -e "${RED}ERROR: ${YELLOW}Run script from top level of your Git repo${NC}"
  exit 1
fi

if ! command -v shfmt &>/dev/null; then
  echo "shfmt not found... installing!"
  curl -sS https://webi.sh/shfmt | sh
  MY_SHFMT="${HOME}/.local/bin/shfmt"
else
  MY_SHFMT=$(which shfmt)
fi

# returns nothing on success
${MY_SHFMT} test/test_cluster/bootstrap.sh
${MY_SHFMT} -i 2 -l -w test/test_gui/bootstrap.sh
${MY_SHFMT} -i 2 -l -w test/test_ansible/*.sh

# check bootstrap.sh
echo "Checking file: bootstrap.sh"
${MY_SHFMT} -i 2 -l -w bootstrap.sh

# check the bin dir
for filename in "bin"/*.sh; do
  echo "Checking file: ${filename}"
  ${MY_SHFMT} -i 2 -l -w "${filename}"
done

# check the test dir
for filename in "test"/*.sh; do
  echo "Checking file: ${filename}"
  ${MY_SHFMT} -i 2 -l -w "${filename}"
done

for filename in "ansible"/*.sh; do
  echo "Checking file: ${filename}"
  ${MY_SHFMT} -i 2 -l -w "${filename}"
done
