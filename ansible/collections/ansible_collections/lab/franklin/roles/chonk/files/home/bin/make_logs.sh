#!/bin/bash

echo "Creating Logs"
mkdir -p ~/system76/apt

cp -r /etc/apt ~/system76/apt
mkdir -p ~/system76/apt/logs
cp -r /var/log/apt ~/system76/apt/logs
journalctl --since="4 days ago" > ~/system76/journal.log
sudo dmesg > ~/system76/dmesg.log
cp ~/.local/share/xorg/Xorg.0.log ~/system76/Xorg.0.log 2>/dev/null

sudo dmidecode > ~/system76/demidecode 2>/dev/null
sudo lspci -vv > ~/system76/lscpi.log 2>/dev/null
sudo lsusb -vv > ~/system76/lsusb.log 2>/dev/null
uname -a > ~/system76/uname.log
df -h / > ~/system76/df
lsblk -f > ~/system76/lsblk
cp /etc/fstab ~/system76/fstab 2>/dev/null
cp /etc/os-release ~/system76/os-release 2>/dev/null
upower -d > ~/system76/upower

[ -f /usr/bin/sensors ] && sensors > ~/system76/sensors.log
tar cvzf ~/system76-log.tgz ~/system76/
rm -rf ~/system76/


