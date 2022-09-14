# Palo Alto Networks Azure Transit VNet Common

This folder shows Terraform code that helps to deploy a [Transit VNet design model](https://www.paloaltonetworks.com/resources/guides/azure-transit-vnet-deployment-guide-common-firewall-option) (common firewall option) with a VM-Series firewall on Microsoft Azure.

## Usage

1. Edit files/init-cfg.txt to match lab config. (auth key expires April 2023)
2. Adjust  `terraform.tfvars` file to your needs.

```sh
terraform init
terraform plan -out franklin.plan -var-file terraform.tfvars
terraform apply "franklin.plan"
```

## Configure Firewalls

Don't forget to manually start the VMs each day.

```sh
terraform output -json password # use pass to log in to UI of each firewall and configure
```

Prepare to connect to Panorama

1. Set DNS `168.63.129.16`
2. Set NTP `3.pool.ntp.org` and `2.pool.ntp.org`
