#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: © 2022-2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# ChangeLog:
#

PKG_CMD=$(command -v dnf yum apt-get | head -n1)

# remove the current Nvidia packages
sudo "${PKG_CMD}" purge ~nnvidia

# make sure we are getting the most recent release
sudo "${PKG_CMD}" update -m

# make sure apt and dpkg were not interrupted
sudo dpkg --configure -a
sudo "${PKG_CMD}" install -f

# remove supporting libraries as well
sudo "${PKG_CMD}" autoremove --purge

# sudo apt full-upgrade

# install the nvidia driver
sudo "${PKG_CMD}" install system76-driver-nvidia

# reboot the system to start using the new driver
sudo reboot
