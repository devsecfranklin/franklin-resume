#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# v0.1 16 feb 2023

set -u

DATE=$(date +%Y%m%d)
HOST=$(hostname -f)
LOG_DIR="/mnt/storage1/logs"
REPORT="${LOG_DIR}/${HOST}"

if [ ! -d "${REPORT}" ]; then mkdir "${REPORT}"; fi


# Run Lynis
#/usr/sbin/lynis audit system --cronjob > ${REPORT} # dow e want this --crontab flag?
lynis audit system --quick --auditor "franklin" > "${LOG_DIR}/${HOST}/lynis-${DATE}.log"
