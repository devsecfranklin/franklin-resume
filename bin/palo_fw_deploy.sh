#!/usr/bin/env bash
#
# SPDX-FileCopyrightText: 2023 DE:AD:10:C5 <thedevilsvoice@dead10c5.org>
#
# SPDX-License-Identifier: GPL-3.0-or-later

# Run this tool from GCP cloud shell

# Labels:

# nonstop-reason test-pipeline
# nonstop_expected_end_date dec-2025
# lab-franklin nam-ps-east
# runstatus nonstop

declare -A FW_NAMES # [ "lab-franklin-gcp-fw-one" "lab-franklin-gcp-fw-one" ]

export FW_NAME="lab-franklin-fw-two"
#export FW_NAME="palo-firewall-vm-b"
export UNTRUST_SUBNET="ps-devsecops-untrust"
export MGMT_SUBNET="ps-devsecops-mgmt"
export TRUST_SUBNET="ps-devsecops-trust"
export FW_ZONE="us-central1-a"
export INSTANCE_TYPE="n2-standard-4"
export DISK_SIZE="60GB"
export DISK_TYPE="pd-ssd"
export INSTANCE_PROJECT="paloaltonetworksgcp-public" # do not change this value
export IMAGE="vmseries-flex-byol-1023" # search for images in the preceding project
export TAGS="lab-franklin,allow-icmp,http-server,https-server" # edit these, comma separate?
export PANORAMA1="192.168.0.3"
export PANORAMA2="192.168.0.4"
export TEMPLATE="TMPL-Google-lab" # this is the STACK
export DEVICEGROUP="DG-google-lab"
export DNS="8.8.4.4"
export AUTHKEY="916211127077247" # from panorama CLI: `request bootstrap vm-auth-key generate lifetime 8760`
export KEY="admin:ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCu+5vKjTtTWZwlDlm7AlmQdWKujHq7cWnoeJZa/sUGNj+rg8d+SfJZCF+cSuOEFxqJ6wVbX5WSAvB0MNETtncVsC6NvKNSGFsc8vIrIas5cQtyk8frp6SA9aJ/M90p2ekYwPVhqshGCLiRZ1enbm+8uvpGZkWW/g7eQV8HbxFnFCsdf9JZzHcnXWOD8tkRO9r/uuIX31BmVxEG2YE8IPC3Xq18hGglLsi0vOGdBicfOGGc/DRsw6wxXSjXF66nJAxmKZgg4lWzNIe8MkEJthI9cWPsTWcJC3XPpRuKQY6crofZa+atwkymhYJ/MUIJW4172cWLpbA1+4dvSFKSUpyo/Qs+0Zpft8vVvceaDhOsNCpzKk/qINZ3Z+Q/B4I9Ribw83K3FwfAlr6t35Z4j7cCw3VrlJtyVHrwUnVwkCNuw2zcWISfXSnCCFyVgxiJltnqk6CBOUfk6P3qIXqvQqQqp3cB1SiimVtSN5bzITiNnAdySnOUYJIsmMxkPH0Qua8cOQNNs2Ns9zAjgilTZtzG0siJtWmHJrg8+3jMG5mwzOvIgT3DadAx5ao1/+8ak4gBfoqSrLSJXPwW8Myl/I3/uxVkbxb4+jjJwnxKsbGS5LnfVGSvqEFXgtGYfNz79emdIWf3Tbh6Lv9+3Rrt9maCPg3/i5QtWBpaflI2RxurbQ== fdiaz@paloaltonetworks.com"

# check if subnets exist

# run it
#
# change "no-address" to "address" tog et a public IP
echo "Deploying firewall: ${FW_NAME}"
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
--metadata="block-project-ssh-keys=true,ssh-keys=$KEY,serial-port-enable=false,mgmt-interface-swap=enable,type=dhcp-client,panorama-server=$PANORAMA1,panorama-server-2=$PANORAMA2,tplname=$TEMPLATE,dgname=$DEVICEGROUP,hostname=$FW_NAME,dns-primary=$DNS,vm-auth-key=$AUTHKEY,dhcp-accept-server-hostname=yes,dhcp-accept-server-domain=yes"
	
