#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: © 2022-2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# ChangeLog:
#

# v0.1 02/06/2021 franklin@dead10c5.org

set -o nounset # Treat unset variables as an error

#Black        0;30     Dark Gray     1;30
#Red          0;31     Light Red     1;31
#Green        0;32     Light Green   1;32
#Brown/Orange 0;33     Yellow        1;33
#Blue         0;34     Light Blue    1;34
#Purple       0;35     Light Purple  1;35
#Cyan         0;36     Light Cyan    1;36
#Light Gray   0;37     White         1;37

RED='\033[0;31m'
LRED='\033[1;31m'
LGREEN='\033[1;32m'
CYAN='\033[0;36m'
LPURP='\033[1;35m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

false=0
true=1

function check_if_root {
  if [[ $(id -u) -eq 0 ]]; then echo -e "${RED}Do not run his script as root.${NC}" && exit 1; fi
}

function check_repo {
  if [ ! -d "./.git" ]; then
    echo -e "${RED}ERROR: ${YELLOW}Run script from top level of your Git repo${NC}"
    exit 1
  fi
}

# test if the branch is in the local repository.
# return 1 if the branch exists in the local, or 0 if not.
function is_in_local() {
  local __branch=${1}
  local __result=${2}
  local exists_in_local=$(git branch --list ${__branch})

  if [[ -z ${exists_in_local} ]]; then
    eval $__result="'$false'"
  else
    eval $__result="'$true'"
  fi
}

# test if the branch is in the remote repository.
# return 1 if its remote branch exists, or 0 if not.
function is_in_remote() {
  local __branch=${1}
  local result=${2}
  local exists_in_remote=$(git ls-remote --heads origin ${__branch})

  if [[ -z ${exists_in_remote} ]]; then
    eval $result="$false"
  else
    eval $result="$true"
  fi
}

function check_repo_size {
  du -sh .git
}

function clean_repo {
  # Delete all the local references of the remote branch
  git remote prune origin
  # Create new packs that are not packed yet in the repo
  git repack
  # reduce extra objects that are already present in the pack files
  git prune-packed
  # remove all refs that are older than one month.
  git reflog expire --expire=1.month.ago
  # remove all refs and inaccessible commits in the repo which are older than two weeks
  git gc --aggressive
}

function fix_permissions() {
  if [ -d "/mnt/development/workspace" ]; then
    sudo chgrp -R engr /mnt/development/workspace/lab-franklin/.git
    sudo chmod -R g+rw /mnt/development/workspace/lab-franklin/.git/logs
  fi
}

function validate_remote() {
  # git remote add origin git@github.com:devsecfranklin/bot-hanson.git
  # git remote show  origin
  pass
}

function main {
  check_if_root

  fix_permissions

  is_in_local main result
  if [ "${result}" == "$true" ]; then echo -e "Branch main exists in local"; fi
  is_in_remote main result
  if [ "${result}" == "$true" ]; then echo -e "Branch main exists in remote"; fi
  is_in_local master result
  if [ "${result}" == "$true" ]; then echo -e "${RED}Branch master exists in local${NC}"; fi
  is_in_remote master result
  if [ "${result}" == "$true" ]; then echo -e "${RED}Branch master exists in remote${NC}"; fi

  check_repo
  echo -e "${CYAN}"
  echo "Start size of repo: $(check_repo_size)"
  echo -e "${NC}"
  clean_repo
  echo -e "${CYAN}"
  echo "End size of repo: $(check_repo_size)"
  echo -e "${NC}"
}

main
