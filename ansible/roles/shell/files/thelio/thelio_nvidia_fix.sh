#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# this script is to fix the Nvidia drivers on the Thelio

# remove the current Nvidia packages
apt purge ~nnvidia

# make sure we are getting the most recent release
apt update -m  

# make sure apt and dpkg were not interrupted
dpkg --configure -a  
apt install -f  

# remove supporting libraries as well
apt autoremove --purge

# install the nvidia driver
apt install system76-driver-nvidia

# reboot the system to start using the new driver
# reboot
echo "YOU SHOULD REBOOT NOW"

