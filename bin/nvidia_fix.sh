#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: © 2022-2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# ChangeLog:
#

# remove the current Nvidia packages
sudo apt purge ~nnvidia

# make sure we are getting the most recent release
sudo apt update -m

# make sure apt and dpkg were not interrupted
sudo dpkg --configure -a
sudo apt install -f

# remove supporting libraries as well
sudo apt autoremove --purge

# sudo apt full-upgrade

# install the nvidia driver
sudo apt install system76-driver-nvidia

# reboot the system to start using the new driver
sudo reboot
