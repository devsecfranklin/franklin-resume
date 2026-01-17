#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: ©2025 franklin
#
# SPDX-License-Identifier: MIT

# ChangeLog:
#
# v0.1 | 29 Sept 2023 | franklin <smoooth.y62wj@passmail.net>
# v0.2 | 12/27/2025 | update for common.sh

set -o nounset  # Treat unset variables as an error
#set -euo pipefail

# The special shell variable IFS determines how Bash
# recognizes word boundaries while splitting a sequence of character strings.
#IFS=$'\n\t'

LRED='\033[0;31m'
NC='\033[0m' # No Color
SERVER_DIR="/mnt/backup1/workspace/consulting/franklin-resume"


function main() {
  echo -e "\n" && figlet -f fonts/pagga resume && echo -e "\n"
  if [ -f "bin/common.sh" ]; then
    source "bin/common.sh"
  else
    echo -e "${LRED}can not find bin/common.sh.${NC}"
    exit 1
  fi
  log_info "successfully sourced bin/common.sh" && echo -e "\n"

  log_header "Starting the server."


  log_info "cd to ${SERVER_DIR}"
  pushd ${SERVER_DIR} >> /dev/null || exit 1       
  log_info "start screen session"
  screen -mdS franklin_resume go run cmd/main.go
  popd >> /dev/null || exit 1
  log_info "done!"

}

main "$@"

