#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: ©2021-2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: MIT

getent passwd franklin
 klist -e 
klist -k -t /etc/krb5.keytab 
