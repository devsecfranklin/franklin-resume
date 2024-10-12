#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Date: 12/28/2017
#
# Script Name: brightness.sh
#
# Description: Control backlighting on laptop.
#
#
# Run Information:
#
# Error Log: Any output found in /path/to/logfile

sudo tee /sys/class/backlight/acpi_video0/brightness <<< 15
