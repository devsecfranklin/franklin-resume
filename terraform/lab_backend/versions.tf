terraform {
  required_version = ">= 0.13, < 2.0"
  required_providers {
    random   = "~> 3.4.0"
    external = "~> 2.2.0"
    azurerm = {
      source = "hashicorp/azurerm"
      # version = "= 2.97"
    }
    oci = {
      source  = "oracle/oci"
      version = ">= 4.69.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }

  }
}

provider "azurerm" {
  features {}
}

provider "google" {
  project = var.project_id
  region  = var.region
  //impersonate_service_account = var.service_account_terraform
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
}

provider "aws" {
  region = var.aws_region
}
