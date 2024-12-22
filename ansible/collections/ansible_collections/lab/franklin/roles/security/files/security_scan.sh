#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# v0.1 16 FEB 2023
# v0.2 21 DEC 2024 | added chkrootkit

set -u

MYDATE=$(date +%Y%m%d)
HOST=$(hostname -f)
LOG_DIR="/mnt/storage1/logs"
REPORT_DIR="${LOG_DIR}/${HOST}"
LYNIS_FILE="${LOG_DIR}/${HOST}/${MYDATE}-lynis.log"
CHKROOT_FILE="${REPORT_DIR}/${MYDATE}-chkrootkit.log"

if [ ! -d "${REPORT_DIR}" ]; then mkdir "${REPORT_DIR}"; fi

function run_lynis() {
  if [ -f "${LYNIS_FILE}" ]; then
    echo "It looks like Lynis has already run once today. Skipping..."
  else
    command -v /usr/sbin/lynis >/dev/null 2>&1 ||
      {
        echo >&2 "lynis not found. Installing"
        apt install -y lynis
      }
    /usr/sbin/lynis update info # grep for "Outdated" and update if needed
    /usr/sbin/lynis show hostids >>${REPORT_DIR}/hostids.txt
    /usr/sbin/lynis audit system --auditor "franklin" \
      --log-file "${LYNIS_FILE}" --report-file "${REPORT_DIR}/${MYDATE}-lynis-report.dat"
  fi
}

# scan the system for Dockerfiles and audit them
function run_trivy() {
  pass
}

function run_chkrootkit() {
  if [ -f "${CHKROOT_FILE}" ]; then
    echo "It looks like Chkrootkit has already run once today. Skipping..."
  else
    /usr/sbin/chkrootkit | tee "${CHKROOT_FILE}"
  fi
}

function main() {
  run_lynis
  #run_trivy
  run_chkrootkit
}

main "$@"
