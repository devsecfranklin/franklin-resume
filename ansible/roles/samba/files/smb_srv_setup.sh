# SPDX-FileCopyrightText: © 2022-2024 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

#
# {{ ansible_managed }}
#

apt-get install -y locales-all
localectl set-locale LANG=en_US.utf8
localectl status

# Disable avahi-daemon (mDNS protocol / bonjour):
#systemctl stop avahi-daemon.service avahi-daemon.socket
#systemctl disable avahi-daemon.service avahi-daemon.socket

apt-get update -y
apt-get install -y wget sudo screen nmap tcpdump rsync net-tools dnsutils htop apt-transport-https vim gnupg lsb-release

export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install samba winbind libnss-winbind krb5-user smbclient ldb-tools python3-cryptography wsdd
unset DEBIAN_FRONTEND

# https://samba.tranquil.it/doc/en/samba_config_server/debian/server_install_samba_debian.html#server-install-samba-debian
