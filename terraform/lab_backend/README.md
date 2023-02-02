# Lab Backend

## Terraform

```sh
brew install kreuzwerker/taps/m1-terraform-provider-helper
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
m1-terraform-provider-helper activate
m1-terraform-provider-helper install hashicorp/template -v v2.2.0
```

Import existing:

```sh
terraform import google_storage_bucket.terraform_state franklin-gcp-terraform
terraform import google_compute_network.vpc projects/gcp-gcs-pso/global/networks/franklin-lab-mgmt-vpc
terraform import google_compute_firewall.lab-ingress projects/gcp-gcs-pso/global/firewalls/franklin-lab-ingress
```

## Storage

Storage buckets for TF state and other semi-permanent things.

```sh
terraform plan -out=franklin.plan
terraform apply "franklin.plan"
```
