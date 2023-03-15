# Backend

```sh
terraform import google_compute_network.mgmt-vpc projects/gcp-gcs-pso/global/networks/lab-franklin-mgmt-vpc
terraform import azurerm_storage_account.tfstate_old /subscriptions/d47f1af8-9795-4e86-bbce-da72cfd0f8ec/resourceGroups/franklin-lab/providers/Microsoft.Storage/storageAccounts/franklintfstate
terraform import azurerm_storage_account.tfstate /subscriptions/d47f1af8-9795-4e86-bbce-da72cfd0f8ec/resourceGroups/lab-franklin/providers/Microsoft.Storage/storageAccounts/labfraaztest123
terraform import google_compute_subnetwork.mgmt-subnet projects/gcp-gcs-pso/global/networks/lab-franklin-mgmt-vpc
```
