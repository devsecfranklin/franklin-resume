#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: © 2024 Palo Alto Networks, Inc.  All rights reserved. <fdiaz@paloaltonetworks.com>
#
# SPDX-License-Identifier: https://www.paloaltonetworks.com/legal/script-software-license-1-0.pdf

# v0.1 | 05/15/2024 | initial version | franklin

# --- Some config Variables ----------------------------------------
BACKUP_DIR="/tmp/palo/data"
CONNECT_TIMEOUT_CURL="10"
CURL_COMMAND="curl -k --noproxy 10.245.219.107,10.251.22.230,10.251.150.80 --connect-timeout ${CONNECT_TIMEOUT_CURL}"
DATA_DIR="/tmp/palo/data"
LOGGING_DIR="/tmp/palo/log"
MY_DATE=$(date '+%Y-%m-%d-%H')
RAW_OUTPUT="framework_output_${MY_DATE}.txt" # log file name

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

  echo -e "\n${LCYAN}------------------ Starting XXX Tool ------------------${NC}" | tee -a "${RAW_OUTPUT}"
  echo -e "${LGREEN}Log file path is: ${LCYAN}${RAW_OUTPUT}${NC}" | tee -a "${RAW_OUTPUT}"

  if [ ! -d "${DATA_DIR}" ]; then
    echo -e "${LRED}Did not find data dir: ${LCYAN}${DATA_DIR}${NC}"
    mkdir -p ${DATA_DIR}
  fi
  echo -e "${LGREEN}Data directory is: ${LCYAN}${DATA_DIR}${NC}" | tee -a "${RAW_OUTPUT}"

  if [ ! -d "${BACKUP_DIR}" ]; then
    echo -e "${LRED}Did not find backup dir: ${LCYAN}${BACKUP_DIR}${NC}"
    mkdir -p ${BACKUP_DIR}
    echo -e "${LGREEN}Creating backup directory: ${LCYAN}${BACKUP_DIR}${NC}" | tee -a "${RAW_OUTPUT}"
  fi
  echo -e "${LGREEN}Backup directory is: ${LCYAN}${BACKUP_DIR}${NC}" | tee -a "${RAW_OUTPUT}"
}

function setup_user() {
  # check if the BASH ENV var is set, if not use the default value
  if [ -z "${PAN_USER}" ]; then
    TOOL_USER='xml-api-user'
  else
    TOOL_USER="${PAN_USER}"
  fi
  echo -e "${LGREEN}Using USER name: ${LCYAN}${TOOL_USER}${NC}" | tee -a "${RAW_OUTPUT}"
}

function setup_password() {

  if [ -f "~/.netrc" ]; then
    echo -e "{LGREEN}Found ~/.netrc file, updating curl command.${NC}"
    CURL_COMMAND="${CURL_COMMAND} -n ~/.netrc"
  fi

  # DO NOT HARD CODE CREDENTIALS
  #[[ -z "${PASS}" ]] && TOOL_PASS='default' || TOOL_PASS="${PASS}"
  if [ -z "${PASS}" ]; then
    echo -e "${RED}Please export the PASS env var per the docs${NC}" | tee -a "${RAW_OUTPUT}"
    exit 1
  else
    TOOL_PASS="${PASS}"
    if $verbose; then echo -e "${LGREEN}Using PASS: ${LCYAN}${TOOL_PASS}${NC}"; fi # Do NOT tee this into the log file #| tee -a "${RAW_OUTPUT}"
  fi

  # Check pass for reserved characters
  #
  # gen-delims  = ":" / "/" / "?" / "#" / "[" / "]" / "@"
  # sub-delims  = "!" / "$" / "&" / "'" / "(" / ")" / "*" / "+" / "," / ";" / "="

  length=${#TOOL_PASS}
  for ((i = 0; i < $length; i++)); do
    if [[ "${TOOL_PASS}" == *['!'@#\$%\^\&\*\(\)_+] ]]; then
      echo -e "${RED}Pass contains special character, giving up.${NC}"
      echo -e "${YELLOW}More detail available here${NC}: https://knowledgebase.paloaltonetworks.com/KCSArticleDetail?id=kA10g000000CliMCAS&lang=en_US" | tee -a "${RAW_OUTPUT}"
    fi
  done
}

function setup_panorama() {
  # franklin lab test panorama cat is set via .envrc/direnv tool
  #[[ -z "${PAN_IP}" ]] && PANORAMA_IP="10.251.150.80" || PANORAMA_IP="${PAN_IP}" # PROD
  #[[ -z "${PAN_IP}" ]] && PANORAMA_IP="10.251.22.230" || PANORAMA_IP="${PAN_IP}" # TESTNET
  [[ -z "${PAN_IP}" ]] && PANORAMA_IP="10.245.219.107" || PANORAMA_IP="${PAN_IP}"

  if $verbose; then echo -e "${LGREEN}Using Panorama IP: ${LCYAN}${PANORAMA_IP}${NC}" | tee -a "${RAW_OUTPUT}"; fi

  XML_API_KEY=$(${CURL_COMMAND} --data-urlencode -X GET "https://${PANORAMA_IP}/api/?type=keygen&user=${TOOL_USER}&password=${TOOL_PASS}" | cut -d">" -f4 | cut -d"<" -f1)
  if [ -z "${XML_API_KEY}" ]; then
    echo -e "${RED}FAIL: Unable to set the XML API key from Panorama: ${PANORAMA_IP}${NC}"
    exit 1
  elif [ "${XML_API_KEY}" == "Invalid Credential" ]; then
    echo -e "${RED}FAIL: Invalid pass for user ${TOOL_USER} on Panorama: ${PANORAMA_IP}${NC}"
    exit 2
  else
    if $verbose; then echo -e "\n${LGREEN}Setting XML API key: ${NC}${XML_API_KEY}\n"; fi # Do NOT tee this into the log file #| tee -a "${RAW_OUTPUT}"
  fi
}

function get_panorama_serial() {
  echo -e "\n${LGREEN}Getting Panorama serial number...${NC}\n" | tee -a "${RAW_OUTPUT}"
  XML_RESPONSE=$(${CURL_COMMAND} -X POST "https://${PANORAMA_IP}/api?type=op&cmd=<show><system><info></info></system></show>&key=${XML_API_KEY}" 2>&1)
  PAN_SERIAL=$(sed -ne '/serial/{s/.*<serial>\(.*\)<\/serial>.*/\1/p;q;}' <<<"${XML_RESPONSE}")

  if [ -z "${PAN_SERIAL}" ]; then
    echo ${XML_RESPONSE} >>${DATA_DIR}/show_system_info.xml
    echo -e "${RED}FAIL: Unable to determine Panorama serial number:\n${NC}${XML_RESPONSE}" | tee -a "${RAW_OUTPUT}"
    exit 1
  else
    echo -e "${LGREEN}Panorama serial: ${LCYAN}${PAN_SERIAL}${NC}" | tee -a "${RAW_OUTPUT}"
    mkdir -p ${DATA_DIR}/${PAN_SERIAL}
    echo ${XML_RESPONSE} >>${DATA_DIR}/${PAN_SERIAL}/show_system_info.xml
    JSON_STRING=$(jq -n \
      --arg ip "${PAN_IP}" \
      --arg se "${PAN_SERIAL}" \
      '{IP: $ip, serial: $se}')
    echo ${JSON_STRING} >${DATA_DIR}/${PAN_SERIAL}/panorama_${PAN_SERIAL}.json
  fi
}

function cleanup() {
  echo "Cleaning up..." | tee -a "${RAW_OUTPUT}"
  if [ -f ${DATA_DIR}/output.xml ]; then
    rm ${DATA_DIR}/output.xml
  fi
}

function main() {
  directory_setup
  path_setup
  setup_user
  setup_password # no hard coded credentials please
  setup_panorama
  get_panorama_serial
  cleanup
}

main "$@"
