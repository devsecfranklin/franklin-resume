#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: © 2022-2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

HOSTNAME=$(hostnamectl hostname)
LOGDIR="/mnt/storage1/logs/${HOSTNAME}"
MYDATE=$(date +%Y%m%d)

if test -d "/mnt/storage1" && not test "${LOGDIR}" ; then
  echo "In local lab. Creating ${LOGDIR}"
  mkdir "${LOGDIR}"
else
  echo "Not in local lab. Creating ${LOGDIR}"
  LOGDIR="/var/log/lynis"
fi

command -v /usr/sbin/lynis >/dev/null 2>&1 || \
  { echo >&2 "lynis not found. Installing"; apt install -y lynis; }


# updates
/usr/sbin/lynis update info # grep for "Outdated" and update if needed

# During the security audit, Lynis attempts to assign two identifiers to the system.
# They can be compared as fingerprints and can be used in other tools and to link data to an existing system.

# The first identifier is named hostid and has a length of 40 characters. The MAC address of
# the system is typically used its data input. The second identifier is hostid2. It is 64 characters long and
# typically uses a public SSH key a data input.
#lynis show hostids >> /usr/share/lynis/reports/hostids.txt
/usr/sbin/lynis show hostids >> "${LOGDIR}/hostids.txt"

#cd /usr/share/lynis/reports && \
#/usr/sbin/lynis audit system --quick --auditor "franklin" >> ${LOGDIR}/${MYDATE}.log 2>&1
/usr/sbin/lynis audit system --log-file "${LOGDIR}/${MYDATE}-lynis.log" --report-file "${LOGDIR}/${MYDATE}-lynis-report.dat"

# scan the system for Dockerfiles and audit them
