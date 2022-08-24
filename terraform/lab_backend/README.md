# Lab Backend

## Terraform 

```sh
brew install kreuzwerker/taps/m1-terraform-provider-helper
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
m1-terraform-provider-helper activate
m1-terraform-provider-helper install hashicorp/template -v v2.2.0
```

## Storage

Storage buckets for TF state and other semi-permanent things.

```sh
terraform plan -out=franklin.plan
terraform apply "franklin.plan"
```
