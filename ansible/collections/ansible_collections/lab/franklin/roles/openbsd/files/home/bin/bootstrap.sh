#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Date: 11 Oct 2022

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
CONTAINER=false

# Check if we are inside a docker container
function check_docker() {
  if [ -f /.dockerenv ]; then
    echo -e "${LGREEN}Building in container...${NC}"
    CONTAINER=true
  fi
}

function detect_os() {
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

function install_hosts_file() {

  cat <<EOF > /etc/hosts
127.0.0.1	localhost
::1		localhost ip6-localhost ip6-loopback
ff02::1		ip6-allnodes
ff02::2		ip6-allrouters

10.10.8.1 dream-machine.lab.bitsmasher.net dream-machine
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
10.10.12.19 head2.lab.bitsmasher.net head2
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

function setup_ssh_key() {
  echo -e "${LGREEN}install /root/.ssh/authorized_keys file${NC}"
  if [ ! -d "/root/.ssh" ]; then mkdir /root/.ssh; fi
  chmod 700 /root/.ssh

cat <<EOF >> /root/.ssh/authorized_keys
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDU9GRwNI2y9NuElgDgLcfDuGstEZiHaMT/2Gs0prPUFN5egpqzJy1qrf7VLf7U4CyxU8QXnhPhzE9qLnDmqFMWpfyaw4F16
YhDzxESZHZ6gqKcPhHRPTwVyIdF9nhH0bh9jZxdvUMuUO+G7T+kvKTcrLlmxnbE6dd/UOcZesuyjNeyPfPkYPXrx40LtXwEvk/EoaTQjjlBxOh2YWevHIVEeKgIXDd96UfrQT
7ywPT9klBPEc7GxgDMNFKJ1bSWR51TOETRAfFmEnoc0pmULpvzQgj28ppxUZCEXBt8OImkRSG+rPypjIWIEIa54ap3kL9DeJbK6iC9DdXzmCp004EdZdpXqWzLkHOWL58En0c
4puRVv+26DGgwwk8sTbyRIDBbkRNiR2HGpasK7SyMy7xdko8W2TScHnXYc/G9R9T4oEcnyN1rY65uNkfKg5QCC2NHDb+vShKHTQ6/wbvtC7sDt7RM6IYwfv46+Wo3D8uYNwow
3Ny71EwtdxRkkn2tc5SAyYxBo7N0kFSPKrr15/fUY2TeYV/r/x9xa4cgg/VV8GOxwg/vQxyg9YZNpdiXSM9FCQMtv8wObci4tHpiySDYPo55Aga3EW6Jut856KP15EXPYWml/
sHCbEvJUByk3CTt0wW2nxNSl9KUfcQrKGmW3YTW9LhoFDqY1WUHBjdHtQ== thedevilsvoice@protonmail.ch
EOF

  if [ ! -d "/home/franklin/.ssh" ]; then mkdir /home/${MY_USER}/.ssh; fi
  cp /root/.ssh/authorized_keys /home/franklin/.ssh
  chmod 700 /home/franklin/.ssh

}

function setup_ldap() {
  if [ ! -d "/etc/ldap" ]; then mkdir /etc/ldap; fi
  chmod 755 /etc/ldap

cat <<EOF > /etc/ldap.conf
BASE    dc=lab,dc=bitsmasher,dc=net
URI     ldap://10.10.13.1/
TLS_REQCERT allow
TLS_CACERT      /etc/ssl/certs/ca-certificates.crt
SASL_MECH GSSAPI
SASL_REALM LAB.BITSMASHER.NET
EOF

}

function nfs_configuration() {
  echo -e "${LGREEN}NFS Setup${NC}"
  if [ ! -d  "/mnt/clusterfs" ]; then mkdir /mnt/clusterfs; fi
  if [ ! -d "/mnt/backup1" ]; then mkdir /mnt/backup1; fi
  if [ ! -d "/mnt/passport" ]; then mkdir /mnt/passport; fi
  if [ ! -d "/mnt/storage1" ]; then mkdir /mnt/storage1; fi
  # fstab
  #storage1:/mnt/clusterfs /mnt/clusterfs nfs -3,-T,rw,nodev,nosuid,soft,intr 0 0
  #storage1:/mnt/backup1 /mnt/backup1 nfs -3,-T,rw,nodev,nosuid,soft,intr 0 0
  #storage1:/mnt/passport /mnt/passport nfs -3,-T,rw,nodev,nosuid,soft,intr 0 0
  #snowy:/mnt/storage1 /mnt/storage1 nfs -3,-T,rw,nodev,nosuid,soft,intr 0 0

  grep -qxF 'storage1:/mnt/clusterfs /mnt/clusterfs nfs -3,-T,rw,nodev,nosuid,soft,intr 0 0' /etc/fstab || \
  echo 'storage1:/mnt/clusterfs /mnt/clusterfs nfs -3,-T,rw,nodev,nosuid,soft,intr 0 0' >> /etc/fstab
  grep -qxF 'storage1:/mnt/backup1 /mnt/backup1 nfs -3,-T,rw,nodev,nosuid,soft,intr 0 0' /etc/fstab || \
  echo 'storage1:/mnt/backup1 /mnt/backup1 nfs -3,-T,rw,nodev,nosuid,soft,intr 0 0' >> /etc/fstab
  grep -qxF 'storage1:/mnt/passport /mnt/passport nfs -3,-T,rw,nodev,nosuid,soft,intr 0 0' /etc/fstab || \
  echo 'storage1:/mnt/passport /mnt/passport nfs -3,-T,rw,nodev,nosuid,soft,intr 0 0' >> /etc/fstab
  grep -qxF 'snowy:/mnt/storage1 /mnt/storage1 nfs -3,-T,rw,nodev,nosuid,soft,intr 0 0' /etc/fstab || \
  echo 'snowy:/mnt/storage1 /mnt/storage1 nfs -3,-T,rw,nodev,nosuid,soft,intr 0 0' >> /etc/fstab
  echo -e "${LGREEN}mount all NFS volumes${NC}"
  mount -a
}

function krb5_conf() {

  if [ ! -d "/etc/kerberos" ]; then doas mkdir /etc/kerberos; fi
  echo -e "${LGREEN}install Heimdal Kerberos client packages${NC}"
  declare -a Packages=(  "heimdal" "heimdal-libs" "login_krb5" )
  for i in ${Packages[@]};
  do
    pkg_add ${i}
  done

  echo -e "${LGREEN}install /etc/heimdal/krb5.conf${NC}"
cat <<EOF > /etc/heimdal/krb5.conf
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

function add_pkgs() {
  declare -a Packages=(  "colorls" "polybar" "dia" "codeblocks" "git" "bash" "fish" "portslist" "openbsd-backgrounds" "qterminal" "neofetch" )
  for i in ${Packages[@]};
  do
    pkg_add ${i}
  done
}

function setup_ports() {
  #Look for a file named ports.tar.gz on the mirrors.
  cd /tmp && ftp https://cdn.openbsd.org/pub/OpenBSD/$(uname -r)/{ports.tar.gz,SHA256.sig}
  signify -Cp /etc/signify/openbsd-$(uname -r | cut -c 1,3)-base.pub -x SHA256.sig ports.tar.gz
  # You want to untar this file in the /usr directory, which will create /usr/ports and all the directories under it.
  cd /usr && tar xzf /tmp/ports.tar.gz
}

function config_shell() {
  echo "/usr/local/share/fish/man" >> /etc/man.conf
  curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
  set -U fish_user_paths  /usr/local/heimdal/bin $fish_user_paths
}

function setup_wifi() {
  doas ifconfig # lists all supported interfaces
  doas fw_update # to install missing driver for your card
  #dmesg | grep pci | grep <wifi card model> # report if not supported
  doas ifconfig # again to check if your card listed
  #doas ifconfig join <Wifi name> wpakey <password> # to join your wifi
  # Run following 2 lines if you want to auto join your wifi:
  #doas echo "join wifiname wpakey password" >> /etc/hostname.<wificardname>
  #doas echo "dhcp" >> /etc/hostname.<wificardname>
  doas sh /etc/netstart # to restart the network
  ping openbsd.org # to test your network
}

function initial_setup() {
  # add my user to the staff group
  usermod -G staff franklin
  usermod -G wheel franklin
  doas echo "permit persist :wheel" >> /etc/doas.conf

  doas rcctl enable messagebus ## enable dbus
  doas rcctl start messagebus ## start dbus
  doas rcctl enable apmd ## enable power daemon
  doas rcctl start apmd  ## start power daemon
}

function main() {
  check_docker
  detect_os

  if [[ $MY_OS != "obsd" ]]; then
    echo -e "${RED}This is not an OpenBSD system. Exiting.${NC}"
    exit 1
  fi

  syspatch
  # add my user to the staff group
  #usermod -G staff franklin
  setup_ports
  setup_ssh_key
  nfs_configuration
  add_pkgs
  krb5_conf
  config_shell


  # netbeans
  # https://netbeans.apache.org/download/nb14/nb14.html
}

main
