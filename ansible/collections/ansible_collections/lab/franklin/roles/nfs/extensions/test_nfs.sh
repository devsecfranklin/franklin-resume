#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: ©2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: MIT

# ChangeLog:
#
# v0.1 05/16/2025 Maintainer script

RED='\033[0;31m'
LRED='\033[1;31m'
LGREEN='\033[1;32m'
CYAN='\033[0;36m'
LCYAN='\033[1;36m'
LPURP='\033[1;35m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"
ansible-galaxy collection list
echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"
pip install "molecule[lint]"
echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"
molecule --version
molecule dependency --scenario
echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"
molecule check
echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"
molecule list
echo -e "${LCYAN}\n# -----------------------------------------------\n${NC}"
molecule destroy

molecule prepare
