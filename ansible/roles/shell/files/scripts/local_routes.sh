#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

function route_add() {
  route add -net 10.10.8.0/21 gw 10.0.0.70
}

function route_del() {
  route delete -net 10.10.8.0/21
}

function main() {
  route_add
}

main
