#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <franklin@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Run this tool from the jump host or the GCP console

# Palo Alto Lab Labels:

# nonstop-reason test-pipeline
# nonstop_expected_end_date dec-2025
# lab-franklin nam-ps-east
# runstatus nonstop


set -euo pipefail

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

RED='\033[0;31m'
LRED='\033[1;31m'
LGREEN='\033[1;32m'
LBLUE='\033[1;34m'
CYAN='\033[0;36m'
LPURP='\033[1;35m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# --- Some config Variables ----------------------------------------
#declare -a FW_NAMES=(lab-franklin-gcp-fw-one lab-franklin-gcp-fw-three lab-franklin-gcp-fw-four)
declare -a FW_NAMES=(lab-franklin-gcp-fw-six lab-franklin-gcp-fw-seven)
# export FW_NAME="lab-franklin-gcp-two"

export UNTRUST_SUBNET="lab-franklin-untrust"
export MGMT_SUBNET="ps-devsecops-mgmt"
export TRUST_SUBNET="lab-franklin-trust"
export FW_ZONE="us-central1-a"

export DISK_SIZE="60GB"
export DISK_TYPE="pd-ssd"
export INSTANCE_PROJECT="paloaltonetworksgcp-public" # do not change this value
export INSTANCE_TYPE="n2-standard-4"
export IMAGE="vmseries-flex-byol-1023"                         # search for images in the preceding project
export TAGS="lab-franklin,allow-icmp,http-server,https-server" # edit these, comma separate?

export PANORAMA1="192.168.0.3"
export PANORAMA2="192.168.0.4"
export TEMPLATE="STK-Google" # this is the STACK
export DEVICEGROUP="DG-google-lab"
export DNS="8.8.4.4"
export AUTHKEY="2:9KD16LjLR_OSGlJKUAU0Mq3uSVu1k0K1pfLkNCZ9zLCkPl-Oe7m64WzQtXLswbcGVMyorgc_5CO3mO5w8FKx8g" # from panorama CLI: `request bootstrap vm-auth-key generate lifetime 8760`
export KEY="admin:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCu+5vKjTtTWZwlDlm7AlmQdWKujHq7cWnoeJZa/sUGNj+rg8d+SfJZCF+cSuOEFxqJ6wVbX5WSAvB0MNETtncVsC6NvKNSGFsc8vIrIas5cQtyk8frp6SA9aJ/M90p2ekYwPVhqshGCLiRZ1enbm+8uvpGZkWW/g7eQV8HbxFnFCsdf9JZzHcnXWOD8tkRO9r/uuIX31BmVxEG2YE8IPC3Xq18hGglLsi0vOGdBicfOGGc/DRsw6wxXSjXF66nJAxmKZgg4lWzNIe8MkEJthI9cWPsTWcJC3XPpRuKQY6crofZa+atwkymhYJ/MUIJW4172cWLpbA1+4dvSFKSUpyo/Qs+0Zpft8vVvceaDhOsNCpzKk/qINZ3Z+Q/B4I9Ribw83K3FwfAlr6t35Z4j7cCw3VrlJtyVHrwUnVwkCNuw2zcWISfXSnCCFyVgxiJltnqk6CBOUfk6P3qIXqvQqQqp3cB1SiimVtSN5bzITiNnAdySnOUYJIsmMxkPH0Qua8cOQNNs2Ns9zAjgilTZtzG0siJtWmHJrg8+3jMG5mwzOvIgT3DadAx5ao1/+8ak4gBfoqSrLSJXPwW8Myl/I3/uxVkbxb4+jjJwnxKsbGS5LnfVGSvqEFXgtGYfNz79emdIWf3Tbh6Lv9+3Rrt9maCPg3/i5QtWBpaflI2RxurbQ== fdiaz@paloaltonetworks.com"

DATA_DIR="/tmp/palo/data"
LOGGING_DIR="/tmp/palo/log"
MY_DATE=$(date '+%Y-%m-%d-%H')
RAW_OUTPUT="palo_gcloud_deploy_${MY_DATE}.txt" # log file name

function directory_setup() {
  if [ ! -d "${LOGGING_DIR}" ]; then
    echo -e "${LRED}Did not find log dir: ${LCYAN}${LOGGING_DIR}${NC}"
    mkdir -p ${LOGGING_DIR}
    echo -e "${LGREEN}Creating logging directory: ${LCYAN}${LOGGING_DIR}${NC}" | tee -a "${RAW_OUTPUT}"
  fi

  RAW_OUTPUT="${LOGGING_DIR}/${RAW_OUTPUT}"

  echo -e "\n${LCYAN}------------------ Starting GCP Deployment Tool ------------------${NC}" | tee -a "${RAW_OUTPUT}"
  echo -e "${LGREEN}Log file path is: ${LCYAN}${RAW_OUTPUT}${NC}" | tee -a "${RAW_OUTPUT}"

  if [ ! -d "${DATA_DIR}" ]; then
    echo -e "${LRED}Did not find data dir: ${LCYAN}${DATA_DIR}${NC}"
    mkdir -p ${DATA_DIR}
  fi
  echo -e "${LGREEN}Data directory is: ${LCYAN}${DATA_DIR}${NC}" | tee -a "${RAW_OUTPUT}"
}

function deploy_firewall() {
  # change "no-address" to "address" to get a public IP
  gcloud compute instances create $FW_NAME \
    --zone=$FW_ZONE \
    --machine-type=$INSTANCE_TYPE \
    --boot-disk-size=$DISK_SIZE \
    --boot-disk-type=$DISK_TYPE \
    --network-interface subnet=$UNTRUST_SUBNET,address \
    --network-interface subnet=$MGMT_SUBNET,address \
    --network-interface subnet=$TRUST_SUBNET,no-address \
    --image-project=$INSTANCE_PROJECT \
    --image=$IMAGE \
    --maintenance-policy=MIGRATE \
    --can-ip-forward \
    --tags=$TAGS \
    --metadata="block-project-ssh-keys=true,ssh-keys=$KEY,serial-port-enable=false,mgmt-interface-swap=enable,type=dhcp-client,panorama-server=$PANORAMA1,panorama-server-2=$PANORAMA2,tplname=$TEMPLATE,dgname=$DEVICEGROUP,hostname=$FW_NAME,dns-primary=$DNS,vm-auth-key=$AUTHKEY,dhcp-accept-server-hostname=yes,dhcp-accept-server-domain=yes" |
    tee -a "${RAW_OUTPUT}"
}

function main() {
  read -p "Is the auth key ${AUTHKEY} valid? (yes/no) " yn

  `case $yn in
    yes ) echo "ok, we will proceed";;
    no ) echo "Generate from Panorama CLI like so: request bootstrap vm-auth-key generate lifetime 8760";
      exit 1;;
    * ) echo invalid response;
      exit 1;;
  esac`

  directory_setup
  # check if subnets exist

  for key in "${FW_NAMES[@]}"; do
    FW_NAME="${key}"
    echo "Deploying firewall: ${FW_NAME}" | tee -a "${RAW_OUTPUT}"
    deploy_firewall
  done
}

main "@"
