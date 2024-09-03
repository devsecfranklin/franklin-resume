#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <thedevilsvoice@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

kubectl label nodes node900.lab.bitsmasher.net board=nvidia-jetson
kubectl label nodes node901.lab.bitsmasher.net board=nvidia-jetson
kubectl label nodes node0.lab.bitsmasher.net board=raspi-4b
kubectl label nodes node1.lab.bitsmasher.net board=raspi-4b
kubectl label nodes node2.lab.bitsmasher.net board=raspi-4b
kubectl label nodes node3.lab.bitsmasher.net board=raspi-4b

