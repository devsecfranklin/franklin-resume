#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

HOSTS=$(cat /etc/hosts | grep ^10 | cut -f1 -d' ')
for x in ${HOSTS}; do
  ping -c1 ${x}
done
