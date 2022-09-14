# Google Cloud

## Terraform

```sh
brew install kreuzwerker/taps/m1-terraform-provider-helper
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
m1-terraform-provider-helper activate
m1-terraform-provider-helper install hashicorp/template -v v2.2.0
terraform providers lock -provider=darwin_arm64
```

## Subnets/CIDR Blocks

| Name | CIDR |
| ---- | ---- |
| lab-franklin-gp-client-subnet | 10.10.24.0/24 |
| lpgcen-ppal-mgmt | 10.252.0.0/24 |
| lpgcen-ppal-ingress | 10.252.1.0/24 |
| lpgcen-ppal-egress | 10.252.2.0/24 |
| ps-devsecops-mgmt | 192.168.0.0 |
| ps-devsecops-untrust | 192.168.1.0 |
| ps-devsecops-trust | 192.168.2.0 |
