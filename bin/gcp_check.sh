#!/bin/bash

# ------------------------------------------------------------------
# Author: Franklin Diaz <fdiaz@paloaltonetowrks.com>
#
#     Shell script to gather details about GCP configuration.
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
#     ./gcp_check.sh -v ti-ai-network-host
#     ./gcp_check.sh -v ti-ai-outside
#
# ------------------------------------------------------------------

# --- Some config Variables ----------------------------------------
OUTPUT="gcp_check_results_$(date '+%Y-%m-%d-%H').txt"
#GCP_PROJECT="ti-ai-network-host"

# --- Some globals to hold results ---------------------------------
declare -a SUBNETS # global to hold and pass results
declare -a ROUTING_MODE
declare -a FW_RULES
declare -a INSTANCE_GROUPS

function usage()
{
   # Display Help
   echo "GCP config check script."
   echo
   echo "Syntax: gcp_check.sh [-h|-v|-V]"
   echo "options:"
   echo "h     Print this Help."
   echo "v     Specify a Network Name (VPC)."
   echo "V     Print software version and exit."
   echo
}

function my_version() {
  echo "gcp_check.sh - version 0.1 - fdiaz@paloaltonetwoks.com"
}

function get_subnets() {
  printf "\n# --- GCP Network Details ----------------------------------------\n" | tee -a ${OUTPUT}
  gcloud compute networks describe ${1} | tee -a ${OUTPUT}
  # gather the subnet names
  mapfile -t < <(cat ${OUTPUT}| grep subnetworks | cut -d'/' -f11)
  MAPFILE=("${MAPFILE[@]:1}") # pop first item because I am lazy
  SUBNETS="${MAPFILE[@]}"
  mapfile -t < <(cat ${OUTPUT} | grep "routingMode:" | cut -d":" -f2)
  ROUTING_MODE="${MAPFILE[@]}"
}

function get_firewall_rules() {
  printf "\n# --- GCP Firewall Rules -----------------------------------------\n" | tee -a ${OUTPUT}
  gcloud compute firewall-rules list --filter="network:${1}" | tee -a ${OUTPUT}
  mapfile -t < <(cat ${OUTPUT} | grep zs-vpc | grep -v selfLink: | grep -v "name:")
  FW_RULES="${MAPFILE[@]}"
}

function get_instance_groups {
  printf "\n# --- GCP Instance Groups ----------------------------------------\n" | tee -a ${OUTPUT}
  gcloud compute instance-groups list --filter="network:${1}" | tee -a ${OUTPUT}
  mapfile -t < <(cat ${OUTPUT} | grep ${1})
  INSTANCE_GROUPS="${MAPFILE[@]}"
}

function get_health_checks {
  printf "\n# --- GCP Health Checks ------------------------------------------\n" | tee -a ${OUTPUT}
  gcloud compute http-health-checks list | tee -a ${OUTPUT}
}

# --- The main() function ----------------------------------------
function main() {
  printf "# --- gcp_check.sh -------------------------------------------------\n" | tee -a ${OUTPUT}
  my_version | tee -a ${OUTPUT}
  # the numbers in the steps below match the picture "ilb-l7-numbered-components.png"
  for network in ${VPC[@]}; do
    # 1. we need A VPC network with at least two subnets
    get_subnets ${network}
    # echo $RESULTS # a list of subnets

    # 2. A firewall rule that permits proxy-only subnet traffic flows in your network.
    # This means adding one rule that allows TCP port 80, 443, and 8080 traffic from 10.129.0.0/23
    # (the range of the proxy-only subnet in this example).
    # Another firewall rule for the health check probes.
    get_firewall_rules ${network}

    # 3. Backend instances. (VM Series FW in this case)

    # 4. Instance Groups
    # Managed or unmanaged instance groups for Compute Engine VM deployments
    get_instance_groups ${network}

    # 5. A regional health check that reports the readiness of your backends.
    get_health_checks ${network}

    # 6. A regional backend service that monitors the usage and health of backends.
    printf "\n# --- GCP Backend Services ---------------------------------------\n" | tee -a ${OUTPUT}
    gcloud compute backend-services list | tee -a ${OUTPUT}

    # 7. A regional URL map that parses the URL of a request and forwards requests to specific
    # backend services based on the host and path of the request URL.
    printf "\n# --- GCP URL Maps -----------------------------------------------\n" | tee -a ${OUTPUT}
    gcloud compute url-maps list | tee -a ${OUTPUT}

    # 8. A regional target HTTP or HTTPS proxy, which receives a request from the user and forwards
    # it to the URL map. For HTTPS, configure a regional SSL certificate resource. The target proxy
    # uses the SSL certificate to decrypt SSL traffic if you configure HTTPS load balancing. The
    # target proxy can forward traffic to your instances by using HTTP or HTTPS.
    printf "\n# --- GCP Target HTTP Proxies ------------------------------------\n" | tee -a ${OUTPUT}
    gcloud compute target-http-proxies list | tee -a ${OUTPUT}
    printf "\n# --- GCP SSL Certificates ---------------------------------------\n" | tee -a ${OUTPUT}
    gcloud compute ssl-certificates list | tee -a ${OUTPUT}
    printf "\n# --- GCP Target HTTPS Proxies -----------------------------------\n" | tee -a ${OUTPUT}
    gcloud compute target-https-proxies list | tee -a ${OUTPUT}

    # 9. A forwarding rule, which has the internal IP address of your load balancer, to forward each
    # incoming request to the target proxy.
    #
    # The internal IP address associated with the forwarding rule can come from any subnet (in the
    # same network and region) with its --purpose flag set to PRIVATE. Note that:
    #
    # The IP address can (but does not need to) come from the same subnet as the backend
    # instance groups.
    # The IP address must not come from a reserved proxy-only subnet that has its --purpose
    # flag set to REGIONAL_MANAGED_PROXY.
    #
    # For the forwarding rule's IP address, use the backend-subnet. If you try to use the proxy-only subnet, forwarding rule creation fails.
    printf "\n# --- GCP Forwarding Rules --------------------------------------\n" | tee -a ${OUTPUT}
    gcloud compute forwarding-rules list | tee -a ${OUTPUT}

  done
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
