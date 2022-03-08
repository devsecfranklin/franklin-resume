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
#     Run the script twice on two different VPC. Results are captured
#     to a single log file with today's date.
#
#     ./az_check.sh -v ti-ai-network-host
#     ./az_check.sh -v ti-ai-outside
#
# ------------------------------------------------------------------

# --- Some config Variables ----------------------------------------
OUTPUT="az_check_results_$(date '+%Y-%m-%d-%H').txt"

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

function get_vnet() {
    az network vnet list
}

# --- The main() function ----------------------------------------
function main() {
  printf "# --- az_check.sh -------------------------------------------------\n" | tee -a ${OUTPUT}
  my_version | tee -a ${OUTPUT}

  get_vnet ${VPC}

}

while getopts "hv:V" option; do
   case $option in
      h) # display Help
         usage
         exit 0
         ;;
      v) # get VPC
         VPC=${OPTARG}
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
