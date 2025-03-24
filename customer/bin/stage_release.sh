#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: © 2024 Palo Alto Networks, Inc.  All rights reserved. <fdiaz@paloaltonetworks.com>
#
# SPDX-License-Identifier: https://www.paloaltonetworks.com/legal/script-software-license-1-0.pdf

# v0.1 | 02/15/2024 | initial version | franklin
# v0.2 | 02/27/2024 | Updates for favorite customer env | franklin

# --- Some config Variables ----------------------------------------
CONNECT_TIMEOUT_CURL="10"
CURL_COMMAND="curl -k --noproxy 10.245.219.107,10.251.22.230,10.251.150.80 --connect-timeout ${CONNECT_TIMEOUT_CURL}"
FAILED_OP=false
IS_CHECKPOINT_FW=false
LOGGING_DIR="/tmp/palo/log"
MY_DATE=$(date '+%Y-%m-%d-%H')
RAW_OUTPUT="stage_release_output_${MY_DATE}.txt" # log file name
SOFTWARE_VERSION="10.2.8-h3"

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

function usage() {
  # Display Help
  echo -e "\n${LGREEN}stage_release script."
  echo
  echo "Syntax: stage_release.sh [-f|-h|-i|-p|-r|-t|-u|-v]"
  echo "options:"
  echo -e "${YELLOW}-f     Specify a file with FW IPv4 addresses, one per line.${LGREEN}"
  echo "-h     Print this Help."
  echo "-i     Install release"
  echo "-p     Use PROD environment"
  echo "-r     Specify a sofwtware release to download/install (ex: 10.2.0)"
  echo "-t     Use TESTNET environment" # this is maybe redundant now, since it is the default
  echo "-u     Specify a USER for the Panorama"
  echo -e "-v     Enable verbose (debug) mode.\n${NC}"
}

function directory_setup() {
  if [ ! -d "${LOGGING_DIR}" ]; then
    echo -e "${LRED}Did not find log dir: ${LCYAN}${LOGGING_DIR}${NC}"
    mkdir -p ${LOGGING_DIR}
    echo -e "${LGREEN}Creating logging directory: ${LCYAN}${LOGGING_DIR}${NC}" | tee -a "${RAW_OUTPUT}"
  fi

  RAW_OUTPUT="${LOGGING_DIR}/${RAW_OUTPUT}"

  echo -e "\n${LCYAN}-------------------- Starting Tool --------------------${NC}" | tee -a "${RAW_OUTPUT}"
  echo -e "${LGREEN}Found log dir, log path is: ${NC}${RAW_OUTPUT}"
}

function check_environment() {
  # There is a BASH shell version 3.1.17(1) on checkpoint firewalls
  BASH_VERSION=$(bash --version | grep "GNU bash, version" | cut -f4 -d" ")
  if $verbose; then echo -e "${LGREEN}Found BASH version: ${NC}${BASH_VERSION}" | tee -a "${RAW_OUTPUT}"; fi
  if [ -d "/opt/CPshared" ]; then
    . /opt/CPshared/5.0/tmp/.CPprofile.sh
    echo -e "\n${YELLOW}Running on a Checkpoint FW${NC}" | tee -a "${RAW_OUTPUT}"
    IS_CHECKPOINT_FW=true
    CURL_COMMAND="curl_cli"
    ALL_FW=""
  else
    echo -e "${LGREEN}NOT Running on a Checkpoint FW${NC}" | tee -a "${RAW_OUTPUT}"
    declare -A ALL_FW # cannot declare an associative array in older BASH
  fi
}

function credentials() {
  # check if the BASH ENV var is set, if not use the default value
  if [ -z "${PAN_USER}" ]; then
    TOOL_USER='xml-api-user'
  else
    TOOL_USER="${PAN_USER}"
  fi
  echo -e "${LGREEN}Using USER name: ${NC}${TOOL_USER}" | tee -a "${RAW_OUTPUT}"

  # DO NOT HARD CODE CREDENTIALS
  #[[ -z "${PASS}" ]] && TOOL_PASS='default' || TOOL_PASS="${PASS}"
  if [ -z "${PASS}" ]; then
    echo -e "${RED}Please export the PASS env var per the docs${NC}" | tee -a "${RAW_OUTPUT}"
    exit 1
  else
    TOOL_PASS="${PASS}"
    if $verbose; then echo -e "${LGREEN}Using PASS: ${NC}${TOOL_PASS}"; fi # Do NOT tee this into the log file #| tee -a "${RAW_OUTPUT}"
  fi

  # Check pass for reserved characters
  #
  # gen-delims  = ":" / "/" / "?" / "#" / "[" / "]" / "@"
  # sub-delims  = "!" / "$" / "&" / "'" / "(" / ")" / "*" / "+" / "," / ";" / "="
  if ! $IS_CHECKPOINT_FW; then
    length=${#TOOL_PASS}
    for ((i = 0; i < $length; i++)); do
      if [[ "${TOOL_PASS}" == *['!'@#\$%\^\&\*\(\)_+] ]]; then
        echo -e "${RED}Pass contains special character, giving up.${NC}"
        echo -e "${YELLOW}More detail available here${NC}: https://knowledgebase.paloaltonetworks.com/KCSArticleDetail?id=kA10g000000CliMCAS&lang=en_US" | tee -a "${RAW_OUTPUT}"
        exit 1
      fi
    done
  else
    echo -e "${YELLOW}Unable to check for special chars in PASS on obsolete BASH version: ${BASH_VERSION}${NC}" | tee -a "${RAW_OUTPUT}"
    echo -e "${YELLOW}More detail available here${NC}: https://knowledgebase.paloaltonetworks.com/KCSArticleDetail?id=kA10g000000CliMCAS&lang=en_US" | tee -a "${RAW_OUTPUT}"
  fi

  # franklin lab test panorama 34.134.31.136 is set via .envrc/direnv tool
  # TESTNET :: NJRAR-PANORAMA-T :: 10.251.22.230 is the default
  [[ -z "${PAN_IP}" ]] && PANORAMA_IP="10.251.22.230" || PANORAMA_IP="${PAN_IP}"

  if $verbose; then echo -e "${LGREEN}Using Panorama IP: ${PANORAMA_IP}${NC}" | tee -a "${RAW_OUTPUT}"; fi

  XML_API_KEY=$(${CURL_COMMAND} -X GET "https://${PANORAMA_IP}/api/?type=keygen&user=${TOOL_USER}&password=${TOOL_PASS}" | cut -d">" -f4 | cut -d"<" -f1)
  if [ -z "${XML_API_KEY}" ]; then
    echo -e "${RED}FAIL: Unable to set the XML API key from Panorama: ${PANORAMA_IP}${NC}"
    exit 1
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

function get_connected_fw_list() {
  echo -e "\n${LGREEN}Get connected firewalls...${NC}\n" | tee -a "${RAW_OUTPUT}"
  ALL_FW=$(${CURL_COMMAND} -X POST "https://${PANORAMA_IP}/api?type=op&cmd=<show><devices><connected></connected></devices></show>&user=${TOOL_USER}&key=${XML_API_KEY}")
  echo ${ALL_FW} >${DATA_DIR}/${PAN_SERIAL}/show_devices_connected.xml | tee -a "${RAW_OUTPUT}"

  # this does not work on checkpoint because the xmllint binary/libxml library is too old.
  # Checkpoint is using 20904
  if ! $IS_CHECKPOINT_FW; then
    #xmllint --pretty 2 output.xml # pretty print the output | tee -a "${RAW_OUTPUT}"
    # this does not work on checkpoint because the xmllint binary is too old.
    ALL_FW_SERIALS=$(xmllint --xpath '//result/devices/entry[*]/serial' ${DATA_DIR}/${PAN_SERIAL}/show_devices_connected.xml | cut -d">" -f2 | cut -d"<" -f1) # serial number list
    # echo -e "\nFound FW serial numbers:\n${ALL_FW_SERIALS}" # this is redundant, but keep for debugging

    for i in ${ALL_FW_SERIALS}; do
      XML_RESPONSE=$(${CURL_COMMAND} -X POST "https://${PANORAMA_IP}/api?type=op&cmd=<show><system><info></info></system></show>&target=${i}&key=${XML_API_KEY}" 2>&1)
      SERIAL=$(sed -ne '/serial/{s/.*<serial>\(.*\)<\/serial>.*/\1/p;q;}' <<<"${XML_RESPONSE}")
      MY_IP=$(sed -ne '/ip-address/{s/.*<ip-address>\(.*\)<\/ip-address>.*/\1/p;q;}' <<<"${XML_RESPONSE}")
      echo -e "${LGREEN}Found firewall serial: ${LCYAN}${SERIAL} ${LGREEN}IP: ${LCYAN}${MY_IP}${NC}" | tee -a "${RAW_OUTPUT}"
      ALL_FW["$MY_IP"]="$SERIAL"
      mkdir -p ${DATA_DIR}/${SERIAL}
      echo ${XML_RESPONSE} >>${DATA_DIR}/${SERIAL}/show_system_info.xml
    done
  else
    echo -e "${YELLOW}Unable to get connected firewalls via Checkpoint${NC}" | tee -a "${RAW_OUTPUT}"
  fi
}

# function get_fw_ip_list() {
#   # This will work on RFC 1918 address space, but not public FW IPv4
#   ALL_FW_IP_ADDR=$(xmllint --xpath '//result/devices/entry[*]/ip-address' output.xml | cut -d">" -f2 | cut -d"<" -f1)
#   while IFS= read -r line; do
#     echo "Found firewall IP: ${line}" | tee -a "${RAW_OUTPUT}"
#   done <<<"${ALL_FW_IP_ADDR}"
# }

function test_fw_connection() {
  THIS_FW=${1}

  echo -e "\nTest connection to FW ${THIS_FW}\n" | tee -a "${RAW_OUTPUT}"

  # test connection to the FW and get its serial number
  #${CURL_COMMAND} --connect-timeout ${CONNECT_TIMEOUT_CURL} -k -X POST "https://${THIS_FW}/api?type=op&cmd=<request><system><software><check></check></software></system></request>&key=${XML_API_KEY}" | tee -a "${RAW_OUTPUT}"
  XML_RESPONSE=$(${CURL_COMMAND} -X POST "https://${THIS_FW}/api/?type=op&cmd=<validate><full></full></validate>&key=${XML_API_KEY}" 2>&1)
  RESULT=$(echo ${XML_RESPONSE} | grep "response status" | cut -f2 -d"=")

  # the actual IP may not be known
  #MY_IP=$(sed -ne '/ip-address/{s/.*<ip-address>\(.*\)<\/ip-address>.*/\1/p;q;}' <<<"${XML_RESPONSE}") # private (MY_IP) may be different from public (THIS_FW)

  if [ -z "${RESULT}" ]; then
    echo -e "------------------------\nresponse: FAILURE\n------------------------\n"
    FAILED_OP=true
    return
  else
    echo -e "------------------------\nresponse: ${RESULT}\n------------------------\n"
    FAILED_OP=false
  fi

  XML_RESPONSE=$(${CURL_COMMAND} -X POST "https://${THIS_FW}/api?type=op&cmd=<show><system><info></info></system></show>&key=${XML_API_KEY}" 2>&1)
  SERIAL=$(sed -ne '/serial/{s/.*<serial>\(.*\)<\/serial>.*/\1/p;q;}' <<<"${XML_RESPONSE}")
  MY_IP=$(sed -ne '/ip-address/{s/.*<ip-address>\(.*\)<\/ip-address>.*/\1/p;q;}' <<<"${XML_RESPONSE}") # private (MY_IP) may be different from public (THIS_FW)
  echo -e "Panorama response: serial: ${SERIAL} actual mgmt ip: ${MY_IP}\n" | tee -a "${RAW_OUTPUT}"
  if [ -z "${SERIAL}" ]; then
    echo -e "------------------------\nresponse: FAILURE\n------------------------\n"
    FAILED_OP=true
    return
  else
    echo -e "------------------------\nresponse: ${RESULT}\n------------------------\n"
    ALL_FW["$THIS_FW"]="$SERIAL"
    FAILED_OP=false
  fi
}

function check_for_updates() {
  THIS_FW=${1}
  THIS_SERIAL="${ALL_FW[$1]}"

  echo -e "\n" | tee -a "${RAW_OUTPUT}"
  echo -e "Check for Updates on host: serial: ${THIS_SERIAL} ip: ${THIS_FW}\n" | tee -a "${RAW_OUTPUT}"

  # Check for the latest available PAN-OS software updates. Include the firewall serial number in your request
  XML_RESPONSE=$(${CURL_COMMAND} -X POST "https://${PANORAMA_IP}/api?type=op&cmd=<request><system><software><check></check></software></system></request>&target=${THIS_SERIAL}&key=${XML_API_KEY}" 2>&1)
  # echo "${XML_RESPONSE}"
  RESULT=$(echo ${XML_RESPONSE} | grep "response status" | cut -f2 -d"=")
  if [ -z "${RESULT}" ]; then
    echo -e "------------------------\nresponse: FAILURE\n------------------------\n"
    echo -e "${RED}Failure connecting to Panorama${NC}"
    FAILED_OP=true
  else
    echo -e "------------------------\nresponse: ${RESULT}\n------------------------\n"
    FAILED_OP=false
  fi

  # XML_RESPONSE=$(${CURL_COMMAND} -X GET "https://${THIS_FW}/api?type=op&cmd=<request><system><software><eligible></eligible></software></system></request>&key=${XML_API_KEY}" 2>&1)
  # RESULT=$(echo ${XML_RESPONSE} | grep "response status" | cut -f2 -d"=")

  # if [ -z "${RESULT}" ]; then
  #   echo -e "------------------------\nresponse: FAILURE\n------------------------\n"
  #   FAILED_OP=true
  # else
  #   echo -e "------------------------\nresponse: ${RESULT}\n------------------------\n"
  #   FAILED_OP=false
  # fi
}

function download_panos_software() {
  # This function will download the specified software version to the firewalls
  # You can generate this list of ALL firewalls by calling this script with no arguments
  # or you can specify a list of firewall IP address in a text file.
  THIS_FW="${1}"
  echo -e "\n" | tee -a "${RAW_OUTPUT}"
  echo -e "Downloading release ${SOFTWARE_VERSION} to firewall IP: ${THIS_FW}\n" | tee -a "${RAW_OUTPUT}"
  XML_RESPONSE=$(${CURL_COMMAND} -X POST "https://${THIS_FW}/api/?type=op&cmd=<request><system><software><download><version>${SOFTWARE_VERSION}</version></download></software></system></request>&key=${XML_API_KEY}" 2>&1)
  RESULT=$(echo ${XML_RESPONSE} | grep "response status" | cut -f2 -d"=")

  if [ -z "${RESULT}" ]; then
    echo -e "------------------------\nresponse: FAILURE\n------------------------\n"
    FAILED_OP=true
  else
    echo -e "------------------------\nresponse: ${RESULT}\n------------------------\n"
    FAILED_OP=false
  fi
}

function install_release() {
  # This function can be used to install a software release that was previously downloaded
  THIS_FW="${1}"
  echo -e "\n" | tee -a "${RAW_OUTPUT}"
  echo -e "${CYAN}Attempting to install release ${SOFTWARE_VERSION} to firewall IP: ${THIS_FW}${NC}\n" | tee -a "${RAW_OUTPUT}"
  XML_RESPONSE=$(${CURL_COMMAND} -X POST "https://${FIREWALL_IP}/api?type=op&cmd=<request><system><software><install><version>${SOFTWARE_VERSION}</version></install></software></system></request>" 2>&1)
  RESULT=$(echo ${XML_RESPONSE} | grep "response status" | cut -f2 -d"=")

  if [ -z "${RESULT}" ]; then
    echo -e "------------------------\nresponse: FAILURE\n------------------------\n"
    FAILED_OP=true
  else
    echo -e "------------------------\nresponse: ${RESULT}\n------------------------\n"
    FAILED_OP=false
  fi
}

# function system_restart() {
#   # reboot the host
#   echo -e "\n"
# }

# function check_installation_status() {
#   # This function can be used to check the state of an on-going installation
#   # You need to know the JOB ID
#   THIS_FW="${1}"
#   echo -e "\n" | tee -a "${RAW_OUTPUT}"
#   echo -e "${CYAN}Sshow status of action${NC}"
#   ${CURL_COMMAND} --connect-timeout ${CONNECT_TIMEOUT_CURL} --insecure -X POST "https://${FIREWALL_IP}/api?type=op&action=get&job-id=<jobid>"
#   echo -e "\n" | tee -a "${RAW_OUTPUT}"
# }

# function show_current_sw_version() {
#   # This function can be used to check the currently running PAN OS version on a device.
#   echo "" | tee -a "${RAW_OUTPUT}"
# }

# function get_fw_public_ip() {
#   # This function can be used to get the PUBLIC IPv4 address of a device.
#   # Until this point we only have the "private" IP, probably.
#   echo "" | tee -a "${RAW_OUTPUT}"

# }

# function scp_import_file() {
#   # SCP the file into the firewall from somewhere else
#   #<request><system><software><scp-import><file></file></scp-import></software></system></request>
#   echo "" | tee -a "${RAW_OUTPUT}"
# }

# function check_panorama_certificate_status() {
#   # debug management-server panorama-root-ca-info
#   echo "" | tee -a "${RAW_OUTPUT}"
# }

# function check_fw_certificate_status() {
#   # show device-certificate status
#   echo "" | tee -a "${RAW_OUTPUT}"
# }

function cleanup() {
  echo "Cleaning up..." | tee -a "${RAW_OUTPUT}"
  if [ -f "output.xml" ]; then
    rm output.xml
  fi
}

function main() {

  MY_FILE=''
  verbose='false'

  directory_setup # log related setup

  while getopts 'hf:ipr:tu:v' flag; do
    case "${flag}" in
    h)
      usage
      exit 0
      ;;

    f)
      MY_FILE="${OPTARG}"
      echo -e "${LGREEN}User provided a text file with IP addresses: ${NC}${MY_FILE}" | tee -a "${RAW_OUTPUT}"
      if [ ! -f "${MY_FILE}" ]; then
        echo -e "${RED}File ${MY_FILE} does not exist! Exiting.${NC}"
        exit 1
      fi
      ;;
    i)
      echo -e "${YELLOW}User will install new software to devices!${NC}" | tee -a "${RAW_OUTPUT}"
      INSTALL_RELEASE=true
      ;;
    p)
      PAN_IP="10.251.22.80"
      echo -e "${LGREEN}User request to use PROD environment.${NC}" | tee -a "${RAW_OUTPUT}" | tee -a "${RAW_OUTPUT}"
      ;;
    r)
      SOFTWARE_VERSION="${OPTARG}"
      echo -e "${LGREEN}User provided a software version: ${SOFTWARE_VERSION}${NC}" | tee -a "${RAW_OUTPUT}"
      ;;
    t)
      PAN_IP="10.251.22.230"
      echo -e "${LGREEN}User request to use TESTNET environment.${NC}" | tee -a "${RAW_OUTPUT}"
      ;;
    u)
      PAN_USER="${OPTARG}"
      ;;
    v)
      verbose=true
      echo -e "${LGREEN}User specified \"verbose\" mode.${NC}" | tee -a "${RAW_OUTPUT}"
      ;;
    *)
      usage
      exit 1
      ;;
    esac
  done

  check_environment # figure out if we are running in limited environment
  credentials       # no hard coded credentials please
  get_panorama_serial
  get_connected_fw_list # from Panorama, make an array of FW with their actual (possibly private) IP
  #get_fw_ip_list # this one is redundant now

  # The user may choose to provide a file containing IP addresses
  if [ "${MY_FILE}" != "" ]; then
    while IFS= read -r i; do

      echo -e "\n${LCYAN}-------------------- Firewall: ${i} --------------------${NC}" | tee -a "${RAW_OUTPUT}"
      starttime=$(date +%s) # track the time to execute

      FAILED_OP=false # keep the status in case of failure

      if [[ "${FAILED_OP}" == false ]]; then test_fw_connection ${i}; fi # This will build the Array of firewalls
      if [[ "${FAILED_OP}" == false ]]; then check_for_updates ${i}; fi
      if [[ "${FAILED_OP}" == false ]]; then download_panos_software ${i}; fi
      if [[ "${FAILED_OP}" == false ]] && [[ "${INSTALL_RELEASE}" == true ]]; then install_release; fi

      endtime=$(date +%s)
      runtime=$((endtime - starttime)) # total execution time
      echo -e "\nTotal time for ${i}: ${runtime} seconds" | tee -a "${RAW_OUTPUT}"
    done <"${MY_FILE}"
  else
    if $IS_CHECKPOINT_FW; then
      echo -e "${RED}Please use the -f flag w the name of a file containing IP address, one per line${NC}" | tee -a "${RAW_OUTPUT}"
      exit 1
    else
      for i in ${ALL_FW_IP_ADDR}; do
        echo -e "\n${LCYAN}-------------------- Firewall: ${i} --------------------${NC}" | tee -a "${RAW_OUTPUT}"
        starttime=$(date +%s)
        test_fw_connection ${i}
        if [[ "${FAILED_OP}" == false ]]; then check_for_updates ${i}; fi
        if [[ "${FAILED_OP}" == false ]]; then download_panos_software ${i}; fi
        if [[ "${FAILED_OP}" == false ]] && [[ "${INSTALL_RELEASE}" == true ]]; then install_release; fi
        endtime=$(date +%s)
        runtime=$((endtime - starttime))
        echo -e "\nTotal time for ${line}: ${runtime} seconds" | tee -a "${RAW_OUTPUT}"
      done
      download_panos_software
      #if $INSTALL_RELEASE; then install_release; fi
    fi
  fi

  #check_installation_status
  #show_current_sw_version
  #get_fw_public_ip
  cleanup
}

main "$@"
