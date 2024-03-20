# Notes

* Test in PAN labs

```sh
az login -t 66b66353-3b76-4e41-9dc3-fee328bd400e
```

## terraform

```sh
export ARM_ACCESS_KEY=$(az storage account keys list --resource-group pirates-booty --account-name clownshow --query [0].value -o tsv)
terraform init -migrate
```

## Panorama

* get `panadmin` password

```sh
terraform output -json panorama_admin_password
ssh -l panadmin 99.4.668.125 -o IdentitiesOnly=yes
```

* VM auth key for firewalls

```sh
request bootstrap vm-auth-key generate lifetime 96
```
