#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: © 2022-2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# ChangeLog:
#
# v0.1 02/25/2022 Maintainer script

LDAP_HOST="ldap.lab.bitsmasher.net"

MY_PASS="$(slappasswd -h {SSHA} -s ${1})"

echo "$MY_PASS"

ldapmodify -h "${LDAP_HOST}" -D cn=user,dc=lab,dc=bitsmasher,dc=net \
           -W dn: cn=user,dc=lab,dc=bitsmasher,dc=net \
	changetype: modify \
	replace: userPassword \
	userPassword: "${MY_PASS}"

