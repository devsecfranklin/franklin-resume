#!/usr/bin/env bash

# SPDX-FileCopyrightText: 2023-2025 franklin <smoooth.y62wj@passmail.net>
#
# SPDX-License-Identifier: MIT

LBLUE='\033[1;34m'
CYAN='\033[0;36m'
LPURP='\033[1;35m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function required_files() {
  declare -a required_files=("AUTHORS" "ChangeLog" "NEWS")
  declare -a required_dirs=( "" )

  for xx in "${required_files[@]}"; do
    if [ ! -f "${xx}" ]; then
      echo -e "${LBLUE}Creating required file ${xx} since it is not found.${NC}"
      touch "${xx}"
    else
      echo "Found required file: ${xx}"
    fi
  done

  if [ ! -d "config/m4" ]; then mkdir -p config/m4; fi
}

required_files
mkdir -p aclocal
mkdir -p config/m4
aclocal