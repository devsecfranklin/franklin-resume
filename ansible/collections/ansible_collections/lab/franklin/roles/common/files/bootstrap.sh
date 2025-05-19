#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: © 2021-2025 franklin <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# ChangeLog:
#

# v0.1 06/11/2021 Original Version
# v0.2 11/11/2022 Support differet Linux distros
# v0.3 12/26/2022 Add SPARC support
# v0.4 08/03/2024 Update the hosts file
# v0.5 11/16/2024 Update the home directory fixer
# v0.6 11/18/2024 Add required_files and OpenBSD support

#set -euo pipefail
set -o errexit # abort on nonzero exitstatus
set -o nounset # abort on unbound variable

# The special shell variable IFS determines how Bash
# recognizes word boundaries while splitting a sequence of character strings.
#IFS=$'\n\t'


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

CONTAINER=false
DOCUMENTATION=false
KERNEL="unknown"
KERNEL_VERSION="unknown"
MACHINE="unknown"
MY_USER="franklin"
MY_OS="unknown"
OS_RELEASE=""

# Check if we are inside a docker container
function check_docker() {
  if [ -f /.dockerenv ]; then
    echo -e "${CYAN}Containerized build environment...${NC}"
    CONTAINER=true
  else
    echo -e "${CYAN}NOT a containerized build environment...${NC}"
  fi
}

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

  if [ "$(uname)" == "Darwin" ]; then
    echo -e "${CYAN}Detected MacOS${NC}"
    MY_OS="mac"
  elif [ -f "/etc/redhat-release" ]; then
    echo -e "${CYAN}Detected Red Hat/CentoOS/RHEL${NC}"
    MY_OS="rh"
  elif [ "$(grep -Ei 'debian|buntu|mint' /etc/*release)" ]; then
    echo -e "${CYAN}Detected Debian/Ubuntu/Mint${NC}"
    MY_OS="deb"
  elif grep -q Microsoft /proc/version; then
    echo -e "${CYAN}Detected Windows pretending to be Linux${NC}"
    MY_OS="win"
  elif [ "$(uname -s)" == "OpenBSD" ]; then
    echo -e "${CYAN}Detected OpenBSD${NC}"
    MY_OS="obsd"
  else
    echo -e "${YELLOW}Unrecongnized architecture.${NC}"
    exit 1
  fi
}

function install_debian() {
  echo -e "${LGREEN}install Debian specifics${NC}"
  declare -a Packages=("doxygen" "gawk" "doxygen-latex")
  for i in "${Packages[@]}"; do
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' "${i}" | grep "install ok installed")
    echo Checking for "${i}": "$PKG_OK"
    if [ "" = "$PKG_OK" ]; then
      echo "Installing ${i} since it is not found."
      sudo apt-get --yes install "${i}"
    fi
  done
}

function install_ubuntu() {
  echo -e "${LGREEN}install Ubuntu specifics${NC}"
  declare -a Packages=("doxygen" "gawk" "doxygen-latex")
  for i in "${Packages[@]}"; do
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' ${i} | grep "install ok installed")
    echo "Checking for ${i}: $PKG_OK"
    if [ "" = "$PKG_OK" ]; then
      echo "Installing ${i} since it is not found."
      sudo apt-get --yes install "${i}"
    fi
  done
}

function krb5_conf() {
  echo -e "${LGREEN}install MIT Kerberos client packages${NC}"
  declare -a Packages=("krb5-user" "libsasl2-modules-gssapi-mit")
  for i in "${Packages[@]}"; do
    PKG_OK=$(dpkg-query -W --showformat='${Status}\n' ${i} | grep "install ok installed")
    echo "Checking for ${i}: $PKG_OK"
    if [ "" = "$PKG_OK" ]; then
      echo "Installing ${i} since it is not found."
      sudo apt-get --yes install "${i}"
    fi
  done

  echo -e "${LGREEN}install /etc/krb5.conf${NC}"
  cat <<EOF >>/etc/krb5.conf
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@bitsmasher.net>
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

  cat <<EOF >>/root/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDU9GRwNI2y9NuElgDgLcfDuGstEZiHaMT/2Gs0prPUFN5egpqzJy1qrf7VLf7U4CyxU8QXnhPhzE9qLnDmqFMWpfyaw4F16YhDzxESZHZ6gqKcPhHRPTwVyIdF9nhH0bh9jZxdvUMuUO+G7T+kvKTcrLlmxnbE6dd/UOcZesuyjNeyPfPkYPXrx40LtXwEvk/EoaTQjjlBxOh2YWevHIVEeKgIXDd96UfrQT7ywPT9klBPEc7GxgDMNFKJ1bSWR51TOETRAfFmEnoc0pmULpvzQgj28ppxUZCEXBt8OImkRSG+rPypjIWIEIa54ap3kL9DeJbK6iC9DdXzmCp004EdZdpXqWzLkHOWL58En0c4puRVv+26DGgwwk8sTbyRIDBbkRNiR2HGpasK7SyMy7xdko8W2TScHnXYc/G9R9T4oEcnyN1rY65uNkfKg5QCC2NHDb+vShKHTQ6/wbvtC7sDt7RM6IYwfv46+Wo3D8uYNwow3Ny71EwtdxRkkn2tc5SAyYxBo7N0kFSPKrr15/fUY2TeYV/r/x9xa4cgg/VV8GOxwg/vQxyg9YZNpdiXSM9FCQMtv8wObci4tHpiySDYPo55Aga3EW6Jut856KP15EXPYWml/sHCbEvJUByk3CTt0wW2nxNSl9KUfcQrKGmW3YTW9LhoFDqY1WUHBjdHtQ== thedevilsvoice@protonmail.ch
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFN4w59V3YUwvONCPTClD2SnXhYhQsh/wO0Gr3tNta1w franklin@bitsmasher.net
EOF

  if [ ! -d "/home/${MY_USER}/.ssh" ]; then mkdir /home/${MY_USER}/.ssh; fi
  cp /root/.ssh/authorized_keys /home/${MY_USER}/.ssh
  chmod 700 /home/${MY_USER}/.ssh

}

function azure_setup() {
  # install azure cli
  curl -sL https://packages.microsoft.com/keys/microsoft.asc |
    gpg --dearmor |
    sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg >/dev/null
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
  grep -qxF 'franklin ALL=(ALL) NOPASSWD:ALL' /etc/sudoers || echo 'franklin ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers
  grep -qxF 'sly ALL=(ALL) NOPASSWD:ALL' /etc/sudoers || echo 'sly ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers
}

function nfs_configuration() {
  echo -e "${LGREEN}NFS Setup${NC}"
  if [ ! -d "/mnt/clusterfs" ]; then mkdir /mnt/clusterfs; fi
  if [ ! -d "/mnt/backup1" ]; then mkdir /mnt/backup1; fi
  if [ ! -d "/mnt/storage1" ]; then mkdir /mnt/storage1; fi
 if [ ! -d "/mnt/storage2" ]; then mkdir /mnt/storage2; fi
  if [ ! -d "/mnt/storage3" ]; then mkdir /mnt/storage3; fi
  # grep -qxF 'storage1:/mnt/clusterfs /mnt/clusterfs nfs defaults 0 0' /etc/fstab || echo 'storage1:/mnt/clusterfs /mnt/clusterfs nfs sec=krb5i,rw,sync 0 0' >>/etc/fstab
  # grep -qxF 'storage1:/mnt/backup1 /mnt/backup1 nfs defaults 0 0' /etc/fstab || echo 'storage1:/mnt/backup1 /mnt/backup1 nfs defaults 0 0' >>/etc/fstab
  grep -qxF 'snowy:/mnt/storage1 /mnt/storage1 nfs defaults 0 0' /etc/fstab || echo 'snowy:/mnt/storage1 /mnt/storage1 nfs defaults 0 0' >>/etc/fstab
  systemctl daemon-reload
  echo -e "${LGREEN}mount all NFS volumes${NC}"
  mount -a
}

function setup_ldap() {
  if [ ! -d "/etc/ldap" ]; then mkdir /etc/ldap; fi
  chmod 755 /etc/ldap

  cat <<EOF >/etc/ldap.conf
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

BASE    dc=lab,dc=bitsmasher,dc=net
URI     ldap://10.10.13.1/
TLS_REQCERT allow
TLS_CACERT      /etc/ssl/certs/ca-certificates.crt
SASL_MECH GSSAPI
SASL_REALM LAB.BITSMASHER.NET
EOF

  cat <<EOF >/etc/pam_ldap.conf
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

base dc=lab,dc=bitsmasher,dc=net
uri ldap://10.10.13.1/
ldap_version 3
pam_password md5
EOF

  cat <<EOF >/etc/libnss-ldap.conf
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

base dc=lab,dc=bitsmasher,dc=net
uri ldap://10.10.13.1/
ldap_version 3
EOF

  cat <<EOF >/etc/nsswitch.conf
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@bitsmasher.net>
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

  cat <<EOF >/etc/hosts
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@bitsmasher.net>
#
# SPDX-License-Identifier: GPL-3.0-or-later

127.0.0.1	localhost
::1		localhost ip6-localhost ip6-loopback
ff02::1		ip6-allnodes
ff02::2		ip6-allrouters

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
178.62.60.55 www.bitsmasher.net wonderland
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
  echo -e "${LGREEN}link home dir${NC}"
  if [ ! -d "/home/franklin.old" ]; then mv /home/franklin /home/franklin.old; fi

  if [ "${MY_OS}" == "obsd" ] && [ ! -L "/home/franklin" ]; then
    ln -s /mnt/storage1/home/franklin-openbsd /home
  elif [ "${MY_OS}" != "obsd" ] && [ ! -L "/home/franklin" ]; then
    ln -s /mnt/storage1/home/franklin /home
  else
    echo -e "${LGREEN}The symlink already exists for /home/franklin${NC}"
  fi
}

function raspi_serial() {
  sudo systemctl enable getty@ttyAMA0.service
  grep -qxF 'enable_uart=1' /boot/config.txt || echo 'enable_uart=1' >>/boot/config.txt
}

function open_bsd_nfs_configuration() {
  echo -e "${LGREEN}NFS Setup${NC}"
  if [ ! -d "/mnt/clusterfs" ]; then mkdir /mnt/clusterfs; fi
  if [ ! -d "/mnt/backup1" ]; then mkdir /mnt/backup1; fi
  if [ ! -d "/mnt/passport" ]; then mkdir /mnt/passport; fi
  if [ ! -d "/mnt/storage1" ]; then mkdir /mnt/storage1; fi
  # fstab
  #storage1:/mnt/clusterfs /mnt/clusterfs nfs -3,-T,rw,nodev,nosuid,soft,intr 0 0
  #storage1:/mnt/backup1 /mnt/backup1 nfs -3,-T,rw,nodev,nosuid,soft,intr 0 0
  #storage1:/mnt/passport /mnt/passport nfs -3,-T,rw,nodev,nosuid,soft,intr 0 0
  #snowy:/mnt/storage1 /mnt/storage1 nfs -3,-T,rw,nodev,nosuid,soft,intr 0 0

  grep -qxF 'storage1:/mnt/clusterfs /mnt/clusterfs nfs -3,-T,rw,nodev,nosuid,soft,intr 0 0' /etc/fstab ||
    echo 'storage1:/mnt/clusterfs /mnt/clusterfs nfs -3,-T,rw,nodev,nosuid,soft,intr 0 0' >>/etc/fstab
  grep -qxF 'storage1:/mnt/backup1 /mnt/backup1 nfs -3,-T,rw,nodev,nosuid,soft,intr 0 0' /etc/fstab ||
    echo 'storage1:/mnt/backup1 /mnt/backup1 nfs -3,-T,rw,nodev,nosuid,soft,intr 0 0' >>/etc/fstab
  grep -qxF 'storage1:/mnt/passport /mnt/passport nfs -3,-T,rw,nodev,nosuid,soft,intr 0 0' /etc/fstab ||
    echo 'storage1:/mnt/passport /mnt/passport nfs -3,-T,rw,nodev,nosuid,soft,intr 0 0' >>/etc/fstab
  grep -qxF 'snowy:/mnt/storage1 /mnt/storage1 nfs -3,-T,rw,nodev,nosuid,soft,intr 0 0' /etc/fstab ||
    echo 'snowy:/mnt/storage1 /mnt/storage1 nfs -3,-T,rw,nodev,nosuid,soft,intr 0 0' >>/etc/fstab
  echo -e "${LGREEN}mount all NFS volumes${NC}"
  mount -a
}

function open_bsd_krb5_conf() {

  if [ ! -d "/etc/kerberos" ]; then doas mkdir /etc/kerberos; fi
  echo -e "${LGREEN}install Heimdal Kerberos client packages${NC}"
  declare -a Packages=("heimdal" "heimdal-libs" "login_krb5")
  for i in "${Packages[@]}"; do
    doas pkg_add "${i}"
  done

  echo -e "${LGREEN}install /etc/heimdal/krb5.conf${NC}"
  cat <<EOF >/etc/heimdal/krb5.conf
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

[kadmin]
        # default salt string
        default_keys = v5

[logging]
        # log to syslog(3)
        kdc = SYSLOG:INFO:DAEMON
        kpasswdd = SYSLOG:INFO:AUTH
        default = SYSLOG:INFO:DAEMON

EOF

}

function open_bsd_add_pkgs() {
  declare -a Packages=("colorls" "polybar" "dia" "codeblocks" "git" "bash" "fish" "portslist" "openbsd-backgrounds" "qterminal" "neofetch")
  for i in "${Packages[@]}"; do
    pkg_add ${i}
  done
}

function open_bsd_setup_ports() {
  #Look for a file named ports.tar.gz on the mirrors.
  cd /tmp && ftp https://cdn.openbsd.org/pub/OpenBSD/$(uname -r)/{ports.tar.gz,SHA256.sig}
  signify -Cp /etc/signify/openbsd-$(uname -r | cut -c 1,3)-base.pub -x SHA256.sig ports.tar.gz
  # You want to untar this file in the /usr directory, which will create /usr/ports and all the directories under it.
  cd /usr && tar xzf /tmp/ports.tar.gz
}

function open_bsd_config_shell() {
  doas usermod -G staff franklin # add my user to the staff group
  echo "/usr/local/share/fish/man" >>/etc/man.conf
  curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
  set -U fish_user_paths /usr/local/heimdal/bin $fish_user_paths
}

function open_bsd_setup_wifi() {
  doas ifconfig  # lists all supported interfaces
  doas fw_update # to install missing driver for your card
  #dmesg | grep pci | grep <wifi card model> # report if not supported
  doas ifconfig # again to check if your card listed
  #doas ifconfig join <Wifi name> wpakey <password> # to join your wifi
  # Run following 2 lines if you want to auto join your wifi:
  #doas echo "join wifiname wpakey password" >> /etc/hostname.<wificardname>
  #doas echo "dhcp" >> /etc/hostname.<wificardname>
  doas sh /etc/netstart # to restart the network
  ping openbsd.org      # to test your network
}

function open_bsd_initial_setup() {
  # add my user to the staff group
  usermod -G staff franklin
  usermod -G wheel franklin
  doas echo "permit persist :wheel" >>/etc/doas.conf

  doas rcctl enable messagebus ## enable dbus
  doas rcctl start messagebus  ## start dbus
  doas rcctl enable apmd       ## enable power daemon
  doas rcctl start apmd        ## start power daemon
}

function main() {
  check_docker
  detect_os

  if [[ "${MY_OS}" == "obsd" ]]; then
    open_bsd_initial_setup
    open_bsd_setup_wifi
    syspatch
    open_bsd_config_shell
    open_bsd_setup_ports
    open_bsd_nfs_configuration
    open_bsd_add_pkgs
    open_bsd_krb5_conf
    open_bsd_config_shell
    # netbeans https://netbeans.apache.org/download/nb14/nb14.html
  else
    krb5_conf
    setup_ldap
    setup_sudoers
    nfs_configuration
    fix_home_dir
    apt_update
    install_hosts_file
    raspi_serial # configure_raspi
  # configure_jetson
  fi
  setup_ssh_key
  # azure_setup

}

main "$@"
