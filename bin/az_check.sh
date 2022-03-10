#!/bin/bash

# ------------------------------------------------------------------
# Author: Franklin Diaz <fdiaz@paloaltonetowrks.com>
#
#     Shell script to gather details about Azure configuration.
#
# Repository:
#
#     https://github.com/devsecfranklin/lab-franklin
#
# Example:
#
#     brew install bash
#     /usr/local/bin/bash az_check.sh -g bmika-transit-rg
#
# ------------------------------------------------------------------

# --- Some config Variables ----------------------------------------
OUTPUT="az_check_results_$(date '+%Y-%m-%d-%H').txt"
LOCATION=""
declare -a VNETS
declare -a SUBNETS

function usage()
{
    # Display Help
    echo "Azure config check script."
    echo
    echo "Syntax: aws_check.sh [-h|-v|-V]"
    echo "options:"
    echo "h     Print this Help."
    echo "v     Specify a Network Name (VPC)."
    echo "V     Print software version and exit."
    echo
}

function my_version() {
    echo "az_check.sh - version 0.1 - fdiaz@paloaltonetwoks.com"
}

function get_rg() {
   printf "\n# --- Azure Network Details -------------------------------------\n" | tee -a ${OUTPUT}
   #az group list | grep resourceGroups | grep id | cut -f5 -d"/" | cut -f1 -d"\""
   az group show -g ${1} -o yaml | tee -a ${OUTPUT}
   mapfile -t < <(cat ${OUTPUT}| grep location | cut -f2 -d":")
   LOCATION="${MAPFILE[@]}"
}

function get_vnets() {
   printf "\n# --- Azure Vnet Details -------------------------------------\n" | tee -a ${OUTPUT}
   az network vnet list -g ${1} -o yaml | grep id | grep virtualNetworks | grep -v subnets | grep -v Peerings | tee -a ${OUTPUT}
   mapfile -t VNETS < <(cat ${OUTPUT} | grep virtualNetworks | cut -f9 -d"/")
   for x in "${VNETS[@]}"
   do
     echo "Found VNet: ${x}" | tee -a ${OUTPUT}
   done
}

function get_subnets() {
   printf "\n# --- Azure Subnet Details -----------------------------------\n" | tee -a ${OUTPUT}
   for vnet in "${VNETS[@]}"
   do
      echo "Checking VNet ${vnet} for subnets"
      az network vnet subnet list -g ${1} --vnet-name ${vnet}
   done
}

# --- The main() function ----------------------------------------
function main() {
    printf "# --- az_check.sh -------------------------------------------------\n" | tee -a ${OUTPUT}
    my_version | tee -a ${OUTPUT}
    get_rg ${RG}
    get_vnets ${RG}
    #get_subnets ${RG}
}

if [ $# -lt 1 ]; then
    usage
    exit 1
fi

while getopts "hg:V" option; do
    case $option in
        h) # display Help
            usage
            exit 0
        ;;
        g) # get Resource Group
            RG=${OPTARG}
            main
            exit 0
        ;;
        V) # display version
            my_version
            exit 0
        ;;
        \?) # incorrect option
            echo "Error: Invalid option"
            usage
            exit 1
        ;;
    esac
done
