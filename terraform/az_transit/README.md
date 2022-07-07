# Azure Transit VNet

## Deployment

```sh
terraform init
terraform plan -out franklin.plan -var-file terraform.tfvars
terraform apply "franklin.plan"
terraform output -json password
```
