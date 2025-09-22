#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2021-2025 franklin <smoooth.y62wj@passmail.net>
#
# SPDX-License-Identifier: MIT

# 06/11/2021

set -o nounset                              # Treat unset variables as an error

#Black        0;30     Dark Gray     1;30
#Red          0;31     Light Red     1;31
#Green        0;32     Light Green   1;32
#Brown/Orange 0;33     Yellow        1;33
#Blue         0;34     Light Blue    1;34
#Purple       0;35     Light Purple  1;35
#Cyan         0;36     Light Cyan    1;36
#Light Gray   0;37     White         1;37

RED='\033[0;31m'
LRED='\033[1;31m'
LGREEN='\033[1;32m'
CYAN='\033[0;36m'
LCYAN='\033[1;36m'
LPURP='\033[1;35m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

MY_DATE=$(date '+%Y-%m-%d-%H')

function check_directory () {
  if [ -d "${1}" ]; then
        echo -e "${LGREEN}Directory exists: ${1}${NC}"
    else
        echo -e "${LRED}Directory missing: ${1}${NC}"
  fi
}

function check_if_kdc() {
  pass
}

function check_file () {
  if [ -f "${1}" ]; then
        echo -e "${LGREEN}File exists: ${1}${NC}"
    else
        echo -e "${LRED}File missing: ${1}${NC}"
  fi
}

function check_service () {
    if "$(systemctl is-enabled ${1} &> /dev/null)"; then
        echo -e "${LGREEN}Running: ${1}${NC}"
    else
        echo -e "${LRED}NOT Running: ${1}${NC}"
    fi
}

function check_package () {
    STATUS=$(dpkg-query -W --showformat='${Status}\n' ${1}| grep "ok installed")
    if [[ ${STATUS} == "install ok installed" ]]; then
        echo -e "${LGREEN}Package installed: ${1}${NC}"
    else
        echo -e "${LRED}Package NOT Installed: ${1}${NC}"
    fi
}

# Create a kadmind Keytab
# https://web.mit.edu/kerberos/krb5-1.5/krb5-1.5.4/doc/krb5-install/Create-a-kadmind-Keytab-_0028optional_0029.html
function create_kadmind_keytab() {
  /usr/sbin/kadmin.local
  ktadd -k /etc/krb5kdc/kadm5.keytab kadmin/admin kadmin/changepw
  quit
}

function generate_host_keytabs() {
  declare -a  KT_HOSTS=( "edge-t" )
  for i in "${KT_HOSTS[@]}";
  do
    echo -e "${LGREEN}Generating host keytabd: ${i}}${NC}"
    ktutil
    add_entry -password -p host/${i}}.lab.bitsmasher.net -k 1 -e aes256-cts-hmac-sha1-96
    add_entry -password -p host/${i}.lab.bitsmasher.net -k 1 -e aes128-cts-hmac-sha1-96
    add_entry -password -p ldap/${i}.lab.bitsmasher.net -k 1 -e aes256-cts-hmac-sha1-96
    add_entry -password -p ldap/${i}.lab.bitsmasher.net -k 1 -e aes128-cts-hmac-sha1-96
    wkt /tmp/${i}.keytab
    quit
  done
}

function main() {
    echo -e "\n${LCYAN}# --- kdc_check.sh --- ${YELLOW}DATE: ${MY_DATE} ${LCYAN}---------------\n${NC}"
    check_if_kdc
    check_directory "/var/lib/krb5kdc"
    check_directory "/etc/krb5"
    check_directory "/etc/krb5kdc"
    check_file "/etc/krb5.keytab"
    check_file "/etc/krb5.conf"
    check_file "/etc/krb5kdc/kdc.conf"
    check_file "/etc/krb5kdc/extensions.client"
    check_file "/etc/krb5kdc/extensions.kdc"
    # The kadmind keytab is the key that the legacy admininstration daemons kadmind4 and v5passwdd will
    # use to decrypt administrators' or clients' Kerberos tickets to determine whether or not they should
    # have access to the database. You need to create the kadmin keytab with entries for the principals
    # kadmin/admin and kadmin/changepw.
    check_file "/etc/krb5kdc/kadm5.keytab"
    check_service "krb5-kdc.service"
    check_service "krb5-admin-server"
    # if systemctl is-enabled rpc-svcgssd then mask it
    check_package "krb5-user"
    check_package "krb5-config"
    generate_host_keytabs
    klist -ke /etc/krb5.keytab
    echo -e "\n${LCYAN}# -------------------- ${YELLOW}DATE: ${MY_DATE} ${LCYAN}---------------\n${NC}"
}

main
