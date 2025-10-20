#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# v0.1 16 feb 2023

set -u

gpg --list-secret-keys --keyid-format=long

# check for .gnupg/trustdb.gpg
