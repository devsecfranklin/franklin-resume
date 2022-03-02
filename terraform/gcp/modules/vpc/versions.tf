/*
terraform {
  required_version = ">= 0.12, < 0.13"
}
*/

/*
\│ Warning: Version constraints inside provider configuration blocks are deprecated
│ 
│   on modules/vpc/versions.tf line 8, in provider "google":
│    8:   version = "~> 3.33" # 3.33 because of google_compute_firewall.log_config.metadata
│ 
│ Terraform 0.13 and earlier allowed provider version constraints inside the provider configuration block, but that is now deprecated and
│ will be removed in a future version of Terraform. To silence this warning, move the provider version constraint into the
│ required_providers block.

provider "google" {
  version = "~> 3.33" # 3.33 because of google_compute_firewall.log_config.metadata
}
*/