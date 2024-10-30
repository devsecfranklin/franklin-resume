#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: © 2022-2024 DE:AD:10:C5 <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# ChangeLog:
#
# v0.1 02/25/2023 initial

MUSIC_DIR="/mnt/storage1/Music"

# Note that our installer, linked above, does all of the below for you, but if you're an intrepid hacker then you might need to know this stuff!

# The DAC can be configured by adding dtoverlay=hifiberry-dac to the /boot/config.txt file.
# There is a DAC enable pin—BCM 25— that must be driven high to enable the DAC. You can do this by adding gpio=25=op,dh to the /boot/config.txt file.
# The buttons are active low, and connected to pins BCM 5, 6, 16, and 24.
# The display uses SPI, and you'll need to enable SPI through the Raspberry Pi configuration menu.
# If you want to use these boards with a Pibow Coupé case (either for the Zero / Zero W or Pi 4), then you'll need to use a booster header to raise it up a little.

# https://github.com/pimoroni/pirate-audio/blob/master/mopidy/README.md
# git clone https://github.com/pimoroni/pirate-audio
# cd pirate-audio/mopidy
# sudo ./install.sh

sudo apt-get -y install mpg321
