#!/bin/bash

# ------------------------------------------------------------------
# Author: Franklin Diaz <fdiaz@paloaltonetowrks.com>
#
#     Shell script to gather details about Oracle Cloud configuration.
#
# Repository:
#
#     https://github.com/devsecfranklin/lab-franklin
#
# Example: 
#
#     Run the script twice on two different VCN. Results are captured
#     to a single log file with today's date.
#
#     ./oci_check.sh -v ti-ai-network-host
#     ./oci_check.sh ti-ai-outside
#
# ------------------------------------------------------------------

# --- Some config Variables ----------------------------------------
OUTPUT="aws_check_results_$(date '+%Y-%m-%d-%H').txt"

function usage()
{
   # Display Help
   echo "AWS config check script."
   echo
   echo "Syntax: aws_check.sh [-h|-v|-V]"
   echo "options:"
   echo "h     Print this Help."
   echo "v     Specify a Network Name (VCN)."
   echo "V     Print software version and exit."
   echo
}

function my_version() {
  echo "oci_check.sh - version 0.1 - fdiaz@paloaltonetwoks.com"
}

# --- The main() function ----------------------------------------
function main() {
  printf "# --- oci_check.sh -------------------------------------------------\n" | tee -a ${OUTPUT}
  my_version | tee -a ${OUTPUT}
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
