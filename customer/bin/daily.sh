#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: © 2024 Palo Alto Networks, Inc.  All rights reserved. <fdiaz@paloaltonetworks.com>
#
# SPDX-License-Identifier: https://www.paloaltonetworks.com/legal/script-software-license-1-0.pdf

# v0.1 | 05/15/2024 | initial version | franklin
# v0.2 | 07/10/2024 | update logging and cert checks | franklin

# set -x # the x is for extreme debugging lol

# --- Some config Variables ----------------------------------------
declare -A ALL_FW # assoc array to hold list of FW
BACKUP_DIR="/tmp/palo/data"
BASH_VERSION="$(bash --version | head -1 | sed -e 's/.* version //;s/ .*//')"
CONNECT_TIMEOUT_CURL="10"
CONTAINER=false
# Use the IP addr of primary panorama in the no proxy list
CURL_COMMAND="curl -X POST -k --noproxy 10.245.219.107,10.251.22.230,10.251.22.80 --connect-timeout ${CONNECT_TIMEOUT_CURL}"
DATA_DIR="/tmp/palo/data"
IFS=$' \t\r\n'
IS_FW_CONNECTED=false
LOGGING_DIR="/tmp/palo/log"
MY_DATE=$(date '+%Y-%m-%d-%H')
MY_OS="unknown"
OS_RELEASE=""
RAW_OUTPUT="status_panorama_${MY_DATE}.txt" # log file name
TIMEOUT_CMD="timeout"
verbose=false

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

function directory_setup() {
  RAW_OUTPUT="${LOGGING_DIR}/${RAW_OUTPUT}"

  if [ ! -d "${LOGGING_DIR}" ]; then
    echo -e "${LRED}Did not find log dir: ${LCYAN}${LOGGING_DIR}${NC}"
    mkdir -p ${LOGGING_DIR}
    echo -e "${LGREEN}Creating logging directory: ${LCYAN}${LOGGING_DIR}${NC}" | tee -a "${RAW_OUTPUT}"
  fi

  echo -e "\n${LCYAN}------------------ Starting Daily Tool ------------------${NC}\n" | tee -a "${RAW_OUTPUT}"
  #echo -e "${LGREEN}Using log dir: ${LCYAN}${LOGGING_DIR}${NC}" | tee -a "${RAW_OUTPUT}"
  echo -e "${LGREEN}Log file path is: ${LCYAN}${RAW_OUTPUT}${NC}" | tee -a "${RAW_OUTPUT}"

  if [ ! -d "${DATA_DIR}" ]; then
    echo -e "${LRED}Did not find data dir: ${LCYAN}${DATA_DIR}${NC}"
    #DATA_DIR="."
    mkdir -p ${DATA_DIR}
  fi
  echo -e "${LGREEN}Data directory is: ${LCYAN}${DATA_DIR}${NC}" | tee -a "${RAW_OUTPUT}"
}

# Check if we are inside a docker container
function check_docker() {
  if [ -f /.dockerenv ]; then
    echo -e "${CYAN}Containerized build environment...${NC}" | tee -a "${RAW_OUTPUT}"
    CONTAINER=true
  else
    echo -e "${CYAN}NOT a containerized build environment...${NC}" | tee -a "${RAW_OUTPUT}"
  fi
}

function detect_os() {
  # check for the /etc/os-release file
  if [ -f "/etc/os-release" ]; then
    OS_RELEASE=$(cat /etc/os-release | grep "^ID=" | cut -d"=" -f2)
  fi

  if [ -n "${OS_RELEASE}" ]; then
    echo -e "${CYAN}Found /etc/os-release file: ${OS_RELEASE}${NC}" | tee -a "${RAW_OUTPUT}"
  fi

  # Check uname (Linux, OpenBSD, Darwin)
  MY_UNAME=$(uname)
  if [ -n "${OS_RELEASE}" ]; then
    echo -e "${CYAN}Found uname: ${MY_UNAME}${NC}" | tee -a "${RAW_OUTPUT}"
  fi

  if [ "${MY_UNAME}" == "OpenBSD" ]; then
    echo -e "${CYAN}Detected OpenBSD${NC}" | tee -a "${RAW_OUTPUT}"
    MY_OS="openbsd"
  elif [ "${MY_UNAME}" == "Darwin" ]; then
    echo -e "${CYAN}Detected MacOS${NC}" | tee -a "${RAW_OUTPUT}"
    MY_OS="mac"
  elif [ -f "/etc/redhat-release" ]; then
    echo -e "${CYAN}Detected Red Hat/CentoOS/RHEL${NC}" | tee -a "${RAW_OUTPUT}"
    MY_OS="rh"
    LAST_UPDATE=$(grep "Updated:" /var/log/yum.log | tail -5)
    if [ -z "${LAST_UPDATE}" ]; then
      echo -e "${YELLOW}This system has not been updated: ${LAST_UPDATE}${NC}"
      echo "last: ${LAST_UPDATE}"
    fi
  elif [ "$(grep -Ei 'debian|buntu|mint' /etc/*release)" ]; then
    echo -e "${CYAN}Detected Debian/Ubuntu/Mint${NC}" | tee -a "${RAW_OUTPUT}"
    MY_OS="deb"
  elif grep -q Microsoft /proc/version; then
    echo -e "${CYAN}Detected Windows pretending to be Linux${NC}" | tee -a "${RAW_OUTPUT}"
    MY_OS="win"
  else
    echo -e "${YELLOW}Unrecongnized architecture.${NC}" | tee -a "${RAW_OUTPUT}"
    exit 1
  fi
}

function configure_mac() {
  TIMEOUT_CMD="gtimeout" # use homebrew to install coreutils to get the GNU commands
}

function setup_user() {
  # check if the BASH ENV var is set, if not use the default value
  if [ -z "${PAN_USER}" ]; then
    TOOL_USER='xml-api-user'
  else
    TOOL_USER="${PAN_USER}"
  fi
  echo -e "\n${LGREEN}Using USER name: ${LCYAN}${TOOL_USER}${NC}" | tee -a "${RAW_OUTPUT}"
}

function setup_password() {

  if [ -f "~/.netrc" ]; then
    echo -e "{LGREEN}Found ~/.netrc file, updating curl command.${NC}"
    CURL_COMMAND="${CURL_COMMAND} -n ~/.netrc"
  fi

  # DO NOT HARD CODE CREDENTIALS
  #[[ -z "${PASS}" ]] && TOOL_PASS='default' || TOOL_PASS="${PASS}"
  if [ -z "${PASS}" ]; then
    echo -e "${LRED}Please export the PASS env var per the docs${NC}" | tee -a "${RAW_OUTPUT}"
    exit 1
  else
    TOOL_PASS="${PASS}"
    if $verbose; then echo -e "${LGREEN}Using PASS: ${LCYAN}${TOOL_PASS}${NC}"; fi # Do NOT tee this into the log file #| tee -a "${RAW_OUTPUT}"
  fi

  # Check pass for reserved characters
  #
  # gen-delims  = ":" / "/" / "?" / "#" / "[" / "]" / "@"
  # sub-delims  = "!" / "$" / "&" / "'" / "(" / ")" / "*" / "+" / "," / ";" / "="

  MY_UNAME=$(uname)
  if [ "${MY_UNAME}" != "Darwin" ]; then
    length=${#TOOL_PASS}
    for ((i = 0; i < $length; i++)); do
      if [[ "${TOOL_PASS}" == *['!'@#\$%\^\&\*\(\)_+] ]]; then
        echo -e "\n${LRED}Pass contains special character. You may experience issues getting XMI API key.${NC}"
        echo -e "${LRED}More detail available here${NC}: https://knowledgebase.paloaltonetworks.com/KCSArticleDetail?id=kA10g000000CliMCAS&lang=en_US\n" | tee -a "${RAW_OUTPUT}"
      fi
    done
  fi
}

function setup_panorama() {
  # franklin lab test panorama cat is set via .envrc/direnv tool
  #[[ -z "${PAN_IP}" ]] && PANORAMA_IP="10.251.22.80" || PANORAMA_IP="${PAN_IP}" # PROD
  #[[ -z "${PAN_IP}" ]] && PANORAMA_IP="10.251.22.230" || PANORAMA_IP="${PAN_IP}" # TESTNET
  [[ -z "${PAN_IP}" ]] && PANORAMA_IP="10.245.219.107" || PANORAMA_IP="${PAN_IP}"

  if $verbose; then echo -e "${LGREEN}Using Panorama IP: ${LCYAN}${PANORAMA_IP}${NC}\n" | tee -a "${RAW_OUTPUT}"; fi

  XML_API_KEY=$(${CURL_COMMAND} "https://${PANORAMA_IP}/api/?type=keygen&user=${TOOL_USER}&password=${TOOL_PASS}" | cut -d">" -f4 | cut -d"<" -f1)
  if [ -z "${XML_API_KEY}" ]; then
    echo -e "${LRED}FAIL: Unable to set the XML API key from Panorama: ${PANORAMA_IP}${NC}"
    exit 1
  elif [ "${XML_API_KEY}" == "Invalid Credential" ]; then
    echo -e "${LRED}FAIL: Invalid pass for user ${TOOL_USER} on Panorama: ${PANORAMA_IP}${NC}"
    exit 2
  else
    if $verbose; then echo -e "\n${LGREEN}Setting XML API key: ${NC}${XML_API_KEY}\n"; fi # Do NOT tee this into the log file #| tee -a "${RAW_OUTPUT}"
  fi

  # check if active or passive panorama
}

function get_panorama_serial() {
  echo -e "\n------------------------ ${LGREEN}Connect to Panorama: ${LCYAN}${PANORAMA_IP}${NC} ------------------------\n" | tee -a "${RAW_OUTPUT}"
  echo -e "\n${LGREEN}Getting Panorama serial number...${NC}\n" | tee -a "${RAW_OUTPUT}"

  XML_RESPONSE=$(${CURL_COMMAND} "https://${PANORAMA_IP}/api?type=op&cmd=<show><system><info></info></system></show>&key=${XML_API_KEY}" 2>&1)
  PAN_SERIAL=$(sed -ne '/serial/{s/.*<serial>\(.*\)<\/serial>.*/\1/p;q;}' <<<"${XML_RESPONSE}")

  # Some vars to collect
  PANORAMA_FAMILY=$(sed -ne '/family/{s/.*<family>\(.*\)<\/family>.*/\1/p;q;}' <<<"${XML_RESPONSE}")
  echo -e "${CYAN}Panorama family:${NC}${PANORAMA_FAMILY}"
  PANORAMA_MODEL=$(sed -ne '/model/{s/.*<model>\(.*\)<\/model>.*/\1/p;q;}' <<<"${XML_RESPONSE}")
  echo -e "${CYAN}Panorama model: ${NC}${PANORAMA_MODEL}"
  PANORAMA_CLOUD=$(sed -ne '/cloud-mode/{s/.*<cloud-mode>\(.*\)<\/cloud-mode>.*/\1/p;q;}' <<<"${XML_RESPONSE}")
  echo -e "${CYAN}Panorama Cloud Mode: ${NC}${PANORAMA_CLOUD}"
  PANORAMA_DEVICE_CERT=$(sed -ne '/device-certificate-status/{s/.*<device-certificate-status>\(.*\)<\/device-certificate-status>.*/\1/p;q;}' <<<"${XML_RESPONSE}")
  echo -e "${CYAN}Panorama Device Certificate Status: ${NC}${PANORAMA_DEVICE_CERT}"
  PANORAMA_PUBLIC_IP=$(sed -ne '/public-ip-address/{s/.*<public-ip-address>\(.*\)<\/public-ip-address>.*/\1/p;q;}' <<<"${XML_RESPONSE}")
  echo -e "${CYAN}Panorama public IPv4: ${NC}${PANORAMA_PUBLIC_IP}"
  echo -e "\n"

  XML_OUTPUT_FILE="${DATA_DIR}/${PAN_SERIAL}/show_system_info_${MY_DATE}.xml"
  mkdir -p ${DATA_DIR}/${PAN_SERIAL}
  echo ${XML_RESPONSE} >${XML_OUTPUT_FILE}
  echo ${XML_RESPONSE} >>${RAW_OUTPUT}
  echo -e "${LGREEN}Panorama serial: ${LCYAN}${PAN_SERIAL}${NC}" | tee -a "${RAW_OUTPUT}"

  # Testing JSON output for ingestion into other tools
  JSON_STRING=$(jq -n --arg ip "${PAN_IP}" --arg se "${PAN_SERIAL}" '{IP: $ip, serial: $se}')
  echo ${JSON_STRING} >${DATA_DIR}/${PAN_SERIAL}/panorama_${PAN_SERIAL}.json

  # dump the system state
  #XML_RESPONSE=$(${CURL_COMMAND} "https://${PANORAMA_IP}/api?type=op&cmd=<show><system><state></state></system></show>&key=${XML_API_KEY}" 2>&1)
}

function panorama_es_health_chk() {
  # check elastic search (red/yel/grn) on panorama
  echo -e "\n------------------------ ${LGREEN}Check Elasticsearch on Panorama: ${LCYAN}${PANORAMA_IP}${NC} ------------------------\n" | tee -a "${RAW_OUTPUT}"

  # https://docs.paloaltonetworks.com/pan-os/10-2/pan-os-panorama-api/pan-os-xml-api-request-types/pan-os-xml-api-request-types-and-actions/configuration-actions/actions-for-reading-a-configuration
  #
  # Show actions retrieve the active configuration, while get actions retrieve the candidate, uncommitted configuration.
  # Show actions only work when the provided XPath specifies a single node. Get actions work with single and multiple nodes.
  # Show actions can use relative XPath, while get actions require absolute XPath.
  XML_OUTPUT_FILE="${DATA_DIR}/${PAN_SERIAL}/show_lc_es_health_${MY_DATE}.xml"
  XML_RESPONSE=$(${CURL_COMMAND} -X POST "https://${PANORAMA_IP}/api?type=op&cmd=<show><log-collector-es-cluster><health></health></log-collector-es-cluster></show>&key=${XML_API_KEY}")
  echo ${XML_RESPONSE} >${XML_OUTPUT_FILE}
  echo ${XML_RESPONSE} >>${RAW_OUTPUT}

  # check elastic search (red/yel/grn) on panorama
  STATUS=$(cat ${XML_OUTPUT_FILE} | cut -f2- -d"," | cut -f1 -d",")
  echo -e "\n${LGREEN}Status (Red/Yel/Grn): ${LCYAN}${STATUS}${NC}\n"

  # check elastic shards on panorama
  UNASSIGNED=$(cat ${XML_OUTPUT_FILE} | cut -f10- -d"," | cut -f1 -d",")
  echo -e "${LGREEN}Unassigned shards: ${LCYAN}${UNASSIGNED}${NC}\n"

  # check ES percent of shards allocated
  ALLOC=$(cat ${XML_OUTPUT_FILE} | cut -f15- -d"," | cut -f1 -d"}")
  echo -e "${LGREEN}% Shards allocated: ${LCYAN}${ALLOC}${NC}\n"
}

function verify_disk() {
  # Verify the integrity of the hard drives.
  echo -e "\n------------------------ ${LGREEN}Check RAID status on Panorama: ${LCYAN}${PANORAMA_IP}${NC} ------------------------\n" | tee -a "${RAW_OUTPUT}"

  XML_OUTPUT_FILE="${DATA_DIR}/${PAN_SERIAL}/show_system_raid_detail_${MY_DATE}.xml"
  XML_RESPONSE=$(${CURL_COMMAND} "https://${PANORAMA_IP}/api?type=op&cmd=<show><system><raid><detail></detail></raid></system></show>&key=${XML_API_KEY}")
  echo ${XML_RESPONSE} >${XML_OUTPUT_FILE}
  echo ${XML_RESPONSE} >>${RAW_OUTPUT}

  echo -e "${LCYAN}check disk partition${NC}\n"
  XML_OUTPUT_FILE="${DATA_DIR}/${PAN_SERIAL}/show_system_disk-partition_${MY_DATE}.xml"
  XML_RESPONSE=$(${CURL_COMMAND} "https://${PANORAMA_IP}/api?type=op&cmd=<show><system><disk-partition></disk-partition></system></show>&key=${XML_API_KEY}")
  echo ${XML_RESPONSE} >${XML_OUTPUT_FILE}
  echo ${XML_RESPONSE} >>${RAW_OUTPUT}

  echo -e "${LCYAN}check disk space${NC}\n"
  XML_OUTPUT_FILE="${DATA_DIR}/${PAN_SERIAL}/show_system_disk-space_${MY_DATE}.xml"
  XML_RESPONSE=$(${CURL_COMMAND} "https://${PANORAMA_IP}/api?type=op&cmd=<show><system><disk-space></disk-space></system></show>&key=${XML_API_KEY}")
  echo ${XML_RESPONSE} >${XML_OUTPUT_FILE}
  echo ${XML_RESPONSE} >>${RAW_OUTPUT}
}

function verify_logging() {
  # check for last traffic logs received on primary and secondary Panorama
  # check if logs are being written

  echo -e "\n------------------------ ${LGREEN}Check logging on Panorama: ${LCYAN}${PANORAMA_IP}${NC} ------------------------\n" | tee -a "${RAW_OUTPUT}"

  XML_OUTPUT_FILE="${DATA_DIR}/${PAN_SERIAL}/show_logging-status_all_${MY_DATE}.xml"
  XML_RESPONSE=$(${CURL_COMMAND} "https://${PANORAMA_IP}/api?type=op&cmd=<show><logging-status><all></all></logging-status></show>&key=${XML_API_KEY}")
  echo ${XML_RESPONSE} >${XML_OUTPUT_FILE}
  echo ${XML_RESPONSE} >>${RAW_OUTPUT}

  # debug syslog-params show

  # device -> setup -> log interface -> service route configuration
}

function find_panorama_zombies() {
  #show system resoruces | match z
  echo ""
}

function get_connected_fw_list() {
  echo -e "\n------------------------ ${LGREEN}Check connected firewalls...${NC} ------------------------\n" | tee -a "${RAW_OUTPUT}"

  ALL_FW_CONNECTED=$(${CURL_COMMAND} "https://${PANORAMA_IP}/api?type=op&cmd=<show><devices><connected></connected></devices></show>&user=${TOOL_USER}&key=${XML_API_KEY}")
  XML_OUTPUT_FILE="${DATA_DIR}/${PAN_SERIAL}/show_connected_devices_${MY_DATE}.xml"
  echo ${ALL_FW_CONNECTED} >${XML_OUTPUT_FILE} | tee -a "${RAW_OUTPUT}"

  ALL_SERIALS=$(xmllint --xpath '//result/devices/entry[*]/serial' ${XML_OUTPUT_FILE})
  mapfile -t ALL_FW_SERIALS < <(echo $ALL_SERIALS | sed 's/>/\n/2; P; D' | cut -f2 -d'>' | cut -d'<' -f1)

  ALL_FW_SERIALS=()
  for line in ${ALL_SERIALS}; do
    blah=$(echo ${line} | cut -d">" -f2 | cut -d"<" -f1)
    if $verbose; then echo -e "\nFound FW serial number: ${blah}"; fi
    ALL_FW_SERIALS+=($blah)
  done

  for i in ${ALL_FW_SERIALS[@]}; do
    XML_OUTPUT_FILE="${DATA_DIR}/${SERIAL}/show_system_info_${MY_DATE}.xml"
    XML_RESPONSE=$(${CURL_COMMAND} "https://${PANORAMA_IP}/api?type=op&cmd=<show><system><info></info></system></show>&target=${i}&key=${XML_API_KEY}" 2>&1)
    SERIAL=$(sed -ne '/serial/{s/.*<serial>\(.*\)<\/serial>.*/\1/p;q;}' <<<"${XML_RESPONSE}")
    MY_IP=$(sed -ne '/ip-address/{s/.*<ip-address>\(.*\)<\/ip-address>.*/\1/p;q;}' <<<"${XML_RESPONSE}")

    #echo -e "\n------------------------ ${LGREEN}Connect to Firewall: ${LCYAN}${i}${NC} ------------------------\n" | tee -a "${RAW_OUTPUT}"
    echo -e "${LGREEN}Found firewall serial: ${LCYAN}${SERIAL} ${LGREEN}IP: ${LCYAN}${MY_IP}${NC}" | tee -a "${RAW_OUTPUT}"

    ALL_FW["$MY_IP"]="$SERIAL"
    mkdir -p ${DATA_DIR}/${SERIAL}
    echo ${XML_RESPONSE} >${XML_OUTPUT_FILE}

    echo -e "${CYAN}Firewall internal IPv4: ${NC}${MY_IP}"
    FIREWALL_PUBLIC_IP=$(sed -ne '/public-ip-address/{s/.*<public-ip-address>\(.*\)<\/public-ip-address>.*/\1/p;q;}' <<<"${XML_RESPONSE}")
    echo -e "${CYAN}Firewall public IPv4: ${NC}${FIREWALL_PUBLIC_IP}"
    #echo -e "\n"

    check_connectivity "$MY_IP"
    if [ "$IS_FW_CONNECTED" == "true" ];
    then
      device_certificate_check "$SERIAL" "$MY_IP"
    fi
  done
}

function backup_panorama() {
  # https://docs.paloaltonetworks.com/pan-os/10-2/pan-os-panorama-api/pan-os-xml-api-request-types/pan-os-xml-api-request-types-and-actions/configuration-actions/actions-for-reading-a-configuration
  #
  # Show actions retrieve the active configuration, while get actions retrieve the candidate, uncommitted configuration.
  # Show actions only work when the provided XPath specifies a single node. Get actions work with single and multiple nodes.
  # Show actions can use relative XPath, while get actions require absolute XPath.
  #XML_RESPONSE=$(${CURL_COMMAND} "https://${PANORAMA_IP}/api?type=export&action=show&key=${XML_API_KEY}&xpath=/response/result/config&element=element-value" 2>&1)

  echo -e "\n------------------------ ${LGREEN}Attempting to backup Panorama: ${LCYAN}${PANORAMA_IP}${NC} ------------------------\n" | tee -a "${RAW_OUTPUT}"

  MY_BACKUP="${BACKUP_DIR}/${PAN_SERIAL}/panorama_backup_${MY_DATE}.txt" # backup file
  if [ -f "${MY_BACKUP}" ]; then echo -e "${LGREEN}Removing stale backup file: ${LCYAN}${MY_BACKUP}${NC}" && rm ${MY_BACKUP}; fi

  # there is an issue where shfmt tries to break the URI into multiple lines, causing the script to fail
  XML_RESPONSE=$(${CURL_COMMAND} -g -o ${MY_BACKUP} "https://${PANORAMA_IP}/api/?type=export&category=configuration&key=${XML_API_KEY}")
  echo -e "${LGREEN}Write backup file: ${LCYAN}${MY_BACKUP}${NC}" | tee -a "${RAW_OUTPUT}"
  echo ${XML_RESPONSE} >>${MY_BACKUP} # | tee -a "${RAW_OUTPUT}"
  # deal with the results
  RESULT=$(echo ${XML_RESPONSE} | grep "response status" | cut -f2 -d"=")
  if [ ! -z "${RESULT}" ]; then
    echo -e "\n-----------------------------\n${LGREEN}Panorama response: ${LRED}FAILURE${NC}\n-----------------------------\n" | tee -a "${RAW_OUTPUT}"
    echo -e "${LRED}Failure connecting to Panorama${NC}" | tee -a "${RAW_OUTPUT}"
    echo -e "\n\n${XML_RESPONSE}" | tee -a "${RAW_OUTPUT}"
  else
    echo -e "\n-----------------------------\n${LGREEN}Panorama response: ${LCYAN}SUCCESS${NC}\n----------------------------\n" | tee -a "${RAW_OUTPUT}"
  fi
}

function backup_firewalls() {
  for key in ${!ALL_FW[@]}; do

    # why do we keey getting a "0" for the value of FW IP
    if [[ ${key} == "0" ]]; then
      echo -e "${LRED}Does not look like a Palo FW IP, skipping: ${LRED}${key}${NC}" | tee -a "${RAW_OUTPUT}"
      continue
    fi

    echo -e "\n------------------------ ${LGREEN}Backup Firewall: ${LCYAN}${key}${NC} ------------------------\n" | tee -a "${RAW_OUTPUT}"
    #echo "FOUND FW: ${key} serial: ${ALL_FW[${key}]}" | tee -a "${RAW_OUTPUT}"
    MY_BACKUP="${BACKUP_DIR}/${ALL_FW[${key}]}/firewall_backup_${key}_${MY_DATE}.txt"
    if [ -f "${MY_BACKUP}" ]; then echo -e "${LGREEN}Removing stale backup file: ${LCYAN}${MY_BACKUP}${NC}" && rm ${MY_BACKUP}; fi

    if [[ ${key} =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      # adding the `-g` flag to disable globbing on RHEL
      XML_RESPONSE=$(${CURL_COMMAND} -g -o ${MY_BACKUP} "https://${PANORAMA_IP}/api/?type=export&category=configuration&key=${XML_API_KEY}&xpath=/config/devices/entry/vsys/entry[@name=\"vsys1\"]&target=${i}")
      echo ${XML_RESPONSE} >>${MY_BACKUP} # | tee -a "${RAW_OUTPUT}"
      echo -e "${LGREEN}Write backup file: ${LCYAN}${MY_BACKUP}${NC}" | tee -a "${RAW_OUTPUT}"

      JSON_STRING=$(jq -s -n \
        --arg ip "${key}" \
        --arg se "${ALL_FW[${key}]}" \
        '{IP: $ip, serial: $se}')
      echo -e "${LGREEN}Write JSON file: ${LCYAN}${BACKUP_DIR}/${ALL_FW[${key}]}/fw_${ALL_FW[${key}]}.json${NC}" | tee -a "${RAW_OUTPUT}"
      echo ${JSON_STRING} >${BACKUP_DIR}/${ALL_FW[${key}]}/fw_${ALL_FW[${key}]}.json
    else
      echo -e "${LRED}Does not look like a Palo FW IP, skipping: ${LRED}${key}${NC}" | tee -a "${RAW_OUTPUT}"
    fi
  done
}

function device_certificate_check() {
  # November 15th deadline
  # We will need to renew every 90 days.
  # The process is automatic after the first time.
  # Requires a valid device certificate.

  # call this function like so:
  # device_certificate_check "$SERIAL" "$MY_IP"

  # for key in ${!ALL_FW[@]}; do
  XML_OUTPUT_FILE="${DATA_DIR}/${1}/device-certificate_info_${MY_DATE}.xml"
  XML_RESPONSE=$(${CURL_COMMAND} "https://${2}/api?type=op&cmd=<show><device-certificate><status></status></device-certificate></show>&key=${XML_API_KEY}")
  echo ${XML_RESPONSE} >${XML_OUTPUT_FILE}
  echo ${XML_RESPONSE} >>${RAW_OUTPUT}
  # done

  # Device Certificate information:
  #       Current device certificate status: Valid
  #       Not valid before: 2024/06/09 03:58:19 MDT
  #       Not valid after: 2024/09/07 03:58:18 MDT
  #       Last fetched timestamp: 2024/06/09 04:08:19 MDT
  #       Last fetched status: success
  #       Last fetched info: Successfully fetched Device Certificate


  # check if device cert is valid
  # show device-certificate status

  # if no then note that we need to install it
  # request certificate fetch otp

  # if yes then run this to establish a connection to the Advanced Wildfire Cloud
  # request wildfire registration channel public
  echo ""
}

function example_report() {
  echo ""
}

function crontab_entry() {
  echo -e "\n------------------------ ${LGREEN}Configure Crontab${NC} ------------------------\n" | tee -a "${RAW_OUTPUT}"
  is_in_cron="${HOME}/workspace/customer/bin/${0}"
  echo -e "${LGREEN}Verify CRON entry: ${LCYAN}${is_in_cron}${NC}" | tee -a "${RAW_OUTPUT}"
  cron_entry=$(crontab -l 2>&1) || exit

  new_cron_entry='0 22 * * * $(whoami) ${HOME}/workspace/customer/bin/${0} >> ${LOGGING_DIR}/franklin.cron.log 2>&1'

  if [[ "${cron_entry}" != *"${is_in_cron}"* ]]; then
    echo -e "${LGREEN}Adding CRON entry: ${LCYAN}${is_in_cron}${NC}" | tee -a "${RAW_OUTPUT}"
    printf '%s\n' "$cron_entry" "$new_cron_entry" | crontab -
  fi
}

function check_panorama_certificate() {
  # collect raw data from panorama

  echo -e "\n------------------------ ${LGREEN}Check Panorama Certificate: ${LCYAN}${1}${NC} ------------------------\n" | tee -a "${RAW_OUTPUT}"

  XML_OUTPUT_FILE="${DATA_DIR}/${PAN_SERIAL}/show_device-certificate_status_${MY_DATE}.xml"
  XML_RESPONSE=$(${CURL_COMMAND} "https://${PANORAMA_IP}/api?type=op&cmd=<show><device-certificate><status></status></device-certificate></show>&key=${XML_API_KEY}")
  echo ${XML_RESPONSE} >${XML_OUTPUT_FILE}
  echo ${XML_RESPONSE} >>${RAW_OUTPUT}

  #PAN_CERT_AFTER=$(sed -ne '/not_valid_after/{s/.*<not_valid_after>\(.*\)<\/not_valid_after>.*/\1/p;q;}' <<<"${XML_RESPONSE}")
  #[[ -z "${PAN_CERT_AFTER}" ]] && PAN_CERT_AFTER="No data found" || PANORAMA_CERT_AFTER="${PAN_CERT_AFTER}"

  XML_OUTPUT_FILE="${DATA_DIR}/${PAN_SERIAL}/show_device-certificate_info_${MY_DATE}.xml"
  XML_RESPONSE=$(${CURL_COMMAND} -X POST "https://${PANORAMA_IP}/api?type=op&cmd=<show><device-certificate><status></status></device-certificate></show>&key=${XML_API_KEY}")
  echo ${XML_RESPONSE} >${XML_OUTPUT_FILE}
  echo ${XML_RESPONSE} >>${RAW_OUTPUT}

  #PAN_CERT_VALID=$(sed -ne '/vailidity/{s/.*<validity>\(.*\)<\/validity>.*/\1/p;q;}' <<<"${XML_RESPONSE}")
  #[[ -z "${PAN_CERT_VALID}" ]] && PANORAMA_CERT_VALID="${PAN_CERT_VALID}" || PAN_CERT_VALID="No data found"
  PAN_CERT_VALID=$(sed -ne '/validity/{s/.*<validity>\(.*\)<\/validity>.*/\1/p;q;}' <<<"${XML_RESPONSE}")
  PAN_CERT_AFTER=$(sed -ne '/not_valid_after/{s/.*<not_valid_after>\(.*\)<\/not_valid_after>.*/\1/p;q;}' <<<"${XML_RESPONSE}")
  [[ -z "${PAN_CERT_AFTER}" ]] && PAN_CERT_AFTER="No data found" || PANORAMA_CERT_AFTER="${PAN_CERT_AFTER}"

  echo -e "${LGREEN}Validity: ${LCYAN}${PAN_CERT_VALID}\n${LGREEN}Expires: ${LCYAN}${PAN_CERT_AFTER}${NC}"

}

function check_firewall_certificate() {
  echo -e "\n------------------------ ${LGREEN}Check Firewall Certificate: ${LCYAN}${1}${NC} ------------------------\n" | tee -a "${RAW_OUTPUT}"

  if true | ${TIMEOUT_CMD} 5 openssl s_client -connect ${1}:443 2>/dev/null | timeout 5 openssl x509 -noout -checkend 0; then
    echo -e "${LGREEN}Certificate is not expired on host: ${1}${NC}" | tee -a "${RAW_OUTPUT}"
    # get the validity date
    #echo -e "\n------------------------ ${LGREEN}Show certificate contents: ${LCYAN}${1}${NC} ------------------------\n" | tee -a "${RAW_OUTPUT}"
    NOT_AFTER=$(${TIMEOUT_CMD} 5 openssl s_client -connect ${1}:443 -servername ${1} | timeout 5 openssl x509 -in /dev/stdin -noout -text | grep 'Expires:' | sed -e 's/^[[:space:]]*//')
    echo -e "${LGREEN}Certification expiration: ${LCYAN}$(echo ${NOT_AFTER} | cut -f4- -d" ")${NC}" | tee -a "${RAW_OUTPUT}"

    # show the full contents
    #openssl s_client -connect ${1}:443 -servername ${1} </dev/null | openssl x509 -in /dev/stdin -noout -text

    # Is this certificate self-signed?
    #echo -e "\n------------------------ ${LGREEN}Checking if self signed: ${LCYAN}${1}${NC} ------------------------\n" | tee -a "${RAW_OUTPUT}"
    VERIFY=$(${TIMEOUT_CMD} 5 openssl s_client -connect ${1}:443 -servername ${1} </dev/null | sed -e 's/^[[:space:]]*//' | grep "Verify return code:")
    if [[ $VERIFY == *"18 (self-signed certificate)"* ]]; then
      echo -e "\n${LRED}${VERIFY}${NC}" | tee -a "${RAW_OUTPUT}"
    else
      echo -e "\n${LGREEN}Certificate is NOT self-signed.${NC}" | tee -a "${RAW_OUTPUT}"
    fi
  else
    echo -e "${LRED}Certificate is expired on host: ${1}${NC}" | tee -a "${RAW_OUTPUT}"
  fi
}

function check_connectivity() {
  echo -e "${CYAN}Check connectivity to site: ${1}${NC}" | tee -a "${RAW_OUTPUT}"
  if curl --connect-timeout ${CONNECT_TIMEOUT_CURL} -I -k -s -o /dev/null "https://${1}"; then
    echo -e "${LGREEN}✓ Connected: ${1}${NC}\n"
    IS_FW_CONNECTED=true
  else
    echo -e "${LRED}✗ No connection: ${1} (unreachable subnet?)${NC}\n"
    IS_FW_CONNECTED=false
  fi
}

function cleanup() {
  echo -e "\n------------------------ ${LGREEN}Cleaning up...${NC} ------------------------\n" | tee -a "${RAW_OUTPUT}"

  # format the XML results
  #find ${DATA_DIR}/${PAN_SERIAL} -name "*.xml" -type f -exec xmllint --output '{}' --format '{}' \;
}

function main() {

  # Setup
  directory_setup
  check_docker
  detect_os
  setup_user
  setup_password # no hard coded credentials please
  setup_panorama
  get_panorama_serial
  backup_panorama

  # Hardware Panorama checks
  if [ "${PANORAMA_FAMILY}" == "m" ]; then
    panorama_es_health_chk # Elastic Search
    verify_disk            # Check disks
  else
    echo -e "${LGREEN}Skipping RAID checks on Cloud/Virtual Panorama${NC}" | tee -a "${RAW_OUTPUT}"
  fi

  verify_logging
  get_connected_fw_list
  backup_firewalls
  # example_report
  # show device-telemetry details
  device_certificate_check

  # TLS Certificates
  check_panorama_certificate

  for key in ${!ALL_FW[@]}; do
    # why do we keey getting a "0" for the value of FW IP
    if [[ ${key} == "0" ]]; then
      echo -e "${LRED}Does not look like a Palo FW IP, skipping: ${LRED}${key}${NC}" >>"${RAW_OUTPUT}"
      continue
    fi

    check_firewall_certificate "$key"
  done

  # Reporting
  # example_report # test the reports via XML API

  # crontab_entry
  cleanup
}

main "$@"
