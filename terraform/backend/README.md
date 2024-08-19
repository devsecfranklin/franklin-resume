---
title: Lab backend
author: Franklin Diaz <franklin@dead10c5.org>
header-includes: |
    \usepackage{fancyhdr}
    \pagestyle{fancy}
    \fancyfoot[CO,CE]{v 0.1 | 07/17/2024 | initial version}
    \fancyfoot[LE,RO]{\thepage}
abstract: Lab tools and documentation.
...

# Backend

There is no Terraform backend bucket for the infra in this folder.
It is like the "meta infra" for the project. Use the commands to import
the existing lab infra as needed.

## GCP imports

- Import the terraform state buckets to a new workstation if needed

```sh
terraform import google_storage_bucket.terraform_state lab-franklin-terraform
terraform import google_storage_bucket.gke_terraform_state lab-franklin
terraform import google_compute_network.mgmt-vpc projects/gcp-gcs-pso/global/networks/lab-franklin-mgmt-vpc
terraform import google_compute_subnetwork.mgmt-subnet us-central1/lab-franklin-mgmt-subnet
terraform import google_compute_subnetwork.aus_network_subnet australia-southeast2/lab-franklin-aus-mgmt-subnet
```

## Azure imports

- import the azure infra to a new workstation if needed
- the `tfstatelabinfra` backend terraform storage container is used to store the state for Azure

```sh
terraform import azurerm_resource_group.lab_franklin /subscriptions/d47f1af8-9795-4e86-bbce-da72cfd0f8ec/resourceGroups/lab-franklin
terraform import azurerm_storage_account.tfstate /subscriptions/d47f1af8-9795-4e86-bbce-da72cfd0f8ec/resourceGroups/franklin-lab/providers/Microsoft.Storage/storageAccounts/labfraaztest123
terraform import azurerm_storage_container.tfstate_labinfra https://labfraaztest123.blob.core.windows.net/tfstatelabinfra
```
