# Global Protect 

* Test in PAN labs

```sh
az login -t 66b66353-3b76-4e41-9dc3-fee328bd400e
```

## terraform 

* Put the VM auth key in files/init-cfg.txt
* Put the Authcode(s) in files/authcodes

```sh
export ARM_ACCESS_KEY=$(az storage account keys list --resource-group rg-ssg-palo-scus --account-name rgssgpaloscus26826 --query [0].value -o tsv)
terraform init -migrate
```

## deploy 

```sh
 az vm image accept-terms --offer vmseries-flex --publish paloaltonetworks --plan bundle2
```
