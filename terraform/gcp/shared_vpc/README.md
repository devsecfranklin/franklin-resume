# Terraform

## Configure

In `terraform.tfvars`:

1. Erase the host project ID (will read default from `variables.tf`)
1. Update the service project IDs
1. Update the ssh key (used for deployment)
1. Update the Panorama server IP(s) (around line 17). This will update the GCP instance Metadata on each FW.
1. Update the "allowed sources" at the end of the file

## FW Setup

Once deployed:

1. SSH to CLI with your key and set the admin pass. Do a commit.
1. Log in via UI of FW.
1. Set the NTP and DNS, do another commit.
