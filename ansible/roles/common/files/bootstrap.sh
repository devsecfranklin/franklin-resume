#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# v0.1 06/11/2021 Original Version
# v0.2 11/11/2022 Support differet Linux distros
# v0.3 12/26/2022 Add SPARC support
# v0.4 08/03/2024 Update the hosts file

set -o nounset                              # Treat unset variables as an error

#Black        0;30     Dark Gray     1;30
#Red          0;31     Light Red     1;31
#Green        0;32     Light Green   1;32
#Brown/Orange 0;33     Yellow        1;33
#Blue         0;34     Light Blue    1;34
#Purple       0;35     Light Purple  1;35
#Cyan         0;36     Light Cyan    1;36
#Light Gray   0;37     White         1;37

#RED='\033[0;31m'
#LRED='\033[1;31m'
LGREEN='\033[1;32m'
CYAN='\033[0;36m'
#LPURP='\033[1;35m'
#YELLOW='\033[1;33m'
NC='\033[0m' # No Color

MY_OS="unknown"
MACHINE="unknown"
KERNEL="unknown"
KERNEL_VERSION="unknown"
MY_USER="franklin"

function detect_os() {
  MACHINE=$(uname -m)
  KERNEL=$(uname -s)
  KERNEL_VERSION=$(uname -v)
  
  if [ "$MACHINE" = "aarch64" ]; then
    echo -e "${CYAN}Found ARM hardware.${NC}"
  elif [ "$MACHINE" = "sparc64" ]; then
    echo -e "${CYAN}Found Sun SPARC hardware.${NC}"
    MY_OS="sparc"
  elif [ "$MACHINE" = "x86_64" ]; then
    echo -e "${CYAN}Found INTEL compatible hardware.${NC}"
  else
    echo -e "${CYAN}Other Hardware: ${MACHINE}${NC}"
  fi

  if [ ! "${KERNEL}" = "unknown" ]; then
    echo -e "${CYAN}Kernel: ${KERNEL}${NC}"
  fi

  if [ ! "${KERNEL_VERSION}" = "unknown" ]; then
    echo -e "${CYAN}Kernel Version: ${KERNEL_VERSION}${NC}"
  fi

  if [ "$(uname)" == "Darwin" ]
  then
    echo -e "${CYAN}Detected MacOS${NC}"
    MY_OS="mac"
  elif [ -f "/etc/redhat-release" ]
  then
    echo -e "${CYAN}Detected Red Hat/CentoOS/RHEL${NC}"
    MY_OS="rh"
  elif [ "$(grep -Ei 'debian|buntu|mint' /etc/*release)" ]
  then
    echo -e "${CYAN}Detected Debian/Ubuntu/Mint${NC}"
    MY_OS="deb"
  elif grep -q Microsoft /proc/version
  then
    echo -e "${CYAN}Detected Windows pretending to be Linux${NC}"
    MY_OS="win"
  elif [ "$(uname -s)" == "OpenBSD" ]
  then
    echo -e "${CYAN}Detected OpenBSD${NC}"
    MY_OS="obsd"
  else
    echo -e "${YELLOW}Unrecongnized architecture.${NC}"
    exit 1
  fi
}

function install_debian() {
  echo -e "${LGREEN}install Debian specifics${NC}"
  declare -a  Packages=( "doxygen" "gawk" "doxygen-latex" )
  for i in ${Packages[@]};
  do
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' ${i}|grep "install ok installed")
    echo Checking for ${i}: $PKG_OK
    if [ "" = "$PKG_OK" ]; then
      echo "Installing ${i} since it is not found."
      sudo apt-get --yes install ${i}
    fi
  done
}

function install_ubuntu() {
  echo -e "${LGREEN}install Ubuntu specifics${NC}"
  declare -a  Packages=( "doxygen" "gawk" "doxygen-latex" )
  for i in ${Packages[@]};
  do
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' ${i}|grep "install ok installed")
    echo Checking for ${i}: $PKG_OK
    if [ "" = "$PKG_OK" ]; then
      echo "Installing ${i} since it is not found."
      sudo apt-get --yes install ${i}
    fi
  done
}

function krb5_conf() {
  echo -e "${LGREEN}install MIT Kerberos client packages${NC}"
  declare -a Pakcages=(  "krb5-user" "libsasl2-modules-gssapi-mit" )
  for i in ${Packages[@]};
  do
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' ${i}|grep "install ok installed")
    echo Checking for ${i}: $PKG_OK
    if [ "" = "$PKG_OK" ]; then
      echo "Installing ${i} since it is not found."
      sudo apt-get --yes install ${i}
    fi
  done
  
  echo -e "${LGREEN}install /etc/krb5.conf${NC}"
cat <<EOF >> /etc/krb5.conf
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

[libdefaults]
default_realm = LAB.BITSMASHER.NET
dns_lookup_realm = true
dns_lookup_kdc = true

# The following krb5.conf variables are only for MIT Kerberos.
kdc_timesync = 1
ccache_type = 4
forwardable = true
proxiable = true

[realms]
LAB.BITSMASHER.NET = {
        pkinit_anchors = FILE:/etc/krb5/cacert.pem
        kdc = kdc1.lab.bitsmasher.net
        admin_server = kdc1.lab.bitsmasher.net
        default_domain = LAB.BITSMASHER.NET
}

[domain_realm]
.bitsmasher.net = LAB.BITSMASHER.NET
bitsmasher.net = LAB.BITSMASHER.NET
lab.bitsmasher.net = LAB.BITSMASHER.NET
.lab.bitsmasher.net = LAB.BITSMASHER.NET
EOF
  
}

function setup_ssh_key() {
  echo -e "${LGREEN}install /root/.ssh/authorized_keys file${NC}"
  if [ ! -d "/root/.ssh" ]; then mkdir /root/.ssh; fi
  chmod 700 /root/.ssh
  
cat <<EOF >> /root/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDU9GRwNI2y9NuElgDgLcfDuGstEZiHaMT/2Gs0prPUFN5egpqzJy1qrf7VLf7U4CyxU8QXnhPhzE9qLnDmqFMWpfyaw4F16YhDzxESZHZ6gqKcPhHRPTwVyIdF9nhH0bh9jZxdvUMuUO+G7T+kvKTcrLlmxnbE6dd/UOcZesuyjNeyPfPkYPXrx40LtXwEvk/EoaTQjjlBxOh2YWevHIVEeKgIXDd96UfrQT7ywPT9klBPEc7GxgDMNFKJ1bSWR51TOETRAfFmEnoc0pmULpvzQgj28ppxUZCEXBt8OImkRSG+rPypjIWIEIa54ap3kL9DeJbK6iC9DdXzmCp004EdZdpXqWzLkHOWL58En0c4puRVv+26DGgwwk8sTbyRIDBbkRNiR2HGpasK7SyMy7xdko8W2TScHnXYc/G9R9T4oEcnyN1rY65uNkfKg5QCC2NHDb+vShKHTQ6/wbvtC7sDt7RM6IYwfv46+Wo3D8uYNwow3Ny71EwtdxRkkn2tc5SAyYxBo7N0kFSPKrr15/fUY2TeYV/r/x9xa4cgg/VV8GOxwg/vQxyg9YZNpdiXSM9FCQMtv8wObci4tHpiySDYPo55Aga3EW6Jut856KP15EXPYWml/sHCbEvJUByk3CTt0wW2nxNSl9KUfcQrKGmW3YTW9LhoFDqY1WUHBjdHtQ== thedevilsvoice@protonmail.ch
EOF
  
  if [ ! -d "/home/${MY_USER}/.ssh" ]; then mkdir /home/${MY_USER}/.ssh; fi
  cp /root/.ssh/authorized_keys /home/${MY_USER}/.ssh
  chmod 700 /home/${MY_USER}/.ssh
  
}

function azure_setup() {
  # install azure cli
  curl -sL https://packages.microsoft.com/keys/microsoft.asc |
  gpg --dearmor |
  sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
  AZ_REPO=$(lsb_release -cs)
  echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" |
  sudo tee /etc/apt/sources.list.d/azure-cli.list
  apt -y install azure-cli
}

function apt_update() {
  echo -e "${LGREEN}apt update and upgrade${NC}"
  apt update
  apt -y full-upgrade
  echo -e "${LGREEN}install tools${NC}"
  apt -y install krb5-user nfs-common apt-utils
}

function setup_sudoers() {
  grep -qxF 'franklin ALL=(ALL) NOPASSWD:ALL' /etc/sudoers || echo 'franklin ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
}

function nfs_configuration() {
  echo -e "${LGREEN}NFS Setup${NC}"
  if [ ! -d  "/mnt/clusterfs" ]; then mkdir /mnt/clusterfs; fi
  if [ ! -d "/mnt/backup1" ]; then mkdir /mnt/backup1; fi
  if [ ! -d "/mnt/storage1" ]; then mkdir /mnt/storage1; fi
  grep -qxF 'storage1:/mnt/clusterfs /mnt/clusterfs nfs defaults 0 0' /etc/fstab || echo 'storage1:/mnt/clusterfs /mnt/clusterfs nfs sec=krb5i,rw,sync 0 0' >> /etc/fstab
  grep -qxF 'storage1:/mnt/backup1 /mnt/backup1 nfs defaults 0 0' /etc/fstab || echo 'storage1:/mnt/backup1 /mnt/backup1 nfs defaults 0 0' >> /etc/fstab
  grep -qxF 'snowy:/mnt/storage1 /mnt/storage1 nfs defaults 0 0' /etc/fstab || echo 'snowy:/mnt/storage1 /mnt/storage1 nfs defaults 0 0' >> /etc/fstab
  systemctl daemon-reload
  echo -e "${LGREEN}mount all NFS volumes${NC}"
  mount -a
}

function setup_ldap() {
  if [ ! -d "/etc/ldap" ]; then mkdir /etc/ldap; fi
  chmod 755 /etc/ldap
  
cat <<EOF > /etc/ldap.conf
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

BASE    dc=lab,dc=bitsmasher,dc=net
URI     ldap://10.10.13.1/
TLS_REQCERT allow
TLS_CACERT      /etc/ssl/certs/ca-certificates.crt
SASL_MECH GSSAPI
SASL_REALM LAB.BITSMASHER.NET
EOF
  
cat <<EOF > /etc/pam_ldap.conf
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

base dc=lab,dc=bitsmasher,dc=net
uri ldap://10.10.13.1/
ldap_version 3
pam_password md5
EOF
  
cat <<EOF > /etc/libnss-ldap.conf
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

base dc=lab,dc=bitsmasher,dc=net
uri ldap://10.10.13.1/
ldap_version 3
EOF
  
cat <<EOF > /etc/nsswitch.conf
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

passwd:         compat systemd ldap
group:          compat systemd ldap
shadow:         compat
gshadow:        files
hosts:          files mdns4_minimal [NOTFOUND=return] dns myhostname
networks:       file
EOF
  
  apt -y install ldap-utils libnss-ldapd libpam-ldapd nscd libsasl2-modules-gssapi-mit
}

function install_hosts_file() {
  
  cat <<EOF > /etc/hosts
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

127.0.0.1	localhost
::1		localhost ip6-localhost ip6-loopback
ff02::1		ip6-allnodes
ff02::2		ip6-allrouters

10.0.0.1   xfinity.engr.bitsmasher.net xfinity
10.0.0.70  dream-machine.engr.bitsmasher.net
10.0.0.205 femputer.engr.bitsmasher.net femputer

10.10.8.1  dream-machine.lab.bitsmasher.net dream-machine
10.10.8.3 netlab1.lab.bitsmasher.net netlab1
10.10.8.4 netlab2.lab.bitsmasher.net netlab2
10.10.8.11 snowy.lab.bitsmasher.net snowy
10.10.12.0 node0.lab.bitsmasher.net node0
10.10.12.1 node1.lab.bitsmasher.net node1
10.10.12.2 node2.lab.bitsmasher.net node2
10.10.12.3 node3.lab.bitsmasher.net node3
10.10.12.4 edge-t.lab.bitsmasher.net edge-t
10.10.12.12 server1.lab.bitsmasher.net server1
10.10.12.13 server2.lab.bitsmasher.net server2
10.10.12.14 storage1.lab.bitsmasher.net storage1
10.10.12.15 blowfish.lab.bitsmasher.net blowfish
10.10.12.18 head1.lab.bitsmasher.net head1
10.10.12.20 media01.lab.bitsmasher.net media1
10.10.12.21 media02.lab.bitsmasher.net media2
10.10.12.90 node900.lab.bitsmasher.net node900
10.10.12.91 node901.lab.bitsmasher.net node901
10.10.12.92 node902.lab.bitsmasher.net node902
10.10.12.93 node903.lab.bitsmasher.net node903
10.10.12.254 odroid-c1.lab.bitsmasher.net odroid-c1 kdc1.lab.bitsmasher.net kdc1
10.10.13.1 server3.lab.bitsmasher.net server3
10.10.13.10 bbb1.lab.bitsmasher.net bbb1
EOF
  
}

function configure_raspi() {
  echo -e "${LGREEN}Configure with raspi-config${NC}"
  raspi-config nonint do_configure_keyboard us
  raspi-config nonint do_change_locale LANG=en_US.UTF-8
  raspi-config nonint do_ssh 0
  # 0=auto, 1=jack, 2=HDMI
  #raspi-config nonint do_audio 1
  raspi-config nonint do_boot_splash 1 # Disable the splash screen
}

function configure_jetson() {
  echo -e "${LGREEN}Configure Jetson Nano specifics${NC}"
  systemctl set-default multi-user.target # set system to text only
  #systemctl set-default graphical.target # enable X window on system
  nvpmodel -m 0 # set nano to high power mode (10w)
}

function fix_home_dir() {
  if [ -d "/home/franklin" ];
  then
    mv /home/franklin /home/franklin.old
  fi

  echo -e "${LGREEN}link home dir${NC}"
  cd /home && ln -s /mnt/backup1/franklin /home
}

function raspi_serial() {
  sudo systemctl enable getty@ttyAMA0.service
  grep -qxF 'enable_uart=1' /boot/config.txt || echo 'enable_uart=1' >> /boot/config.txt
}

function main() {
  detect_os
  krb5_conf
  setup_ssh_key
  # azure_setup
  apt_update
  setup_sudoers
  nfs_configuration
  # home dir stuff
  fix_home_dir
  setup_ldap
  install_hosts_file
  
  # configure_raspi
  raspi_serial
  
  # configure_jetson
  
}

main
