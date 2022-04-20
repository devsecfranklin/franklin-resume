terraform {
  required_version = ">= 0.13, < 2.0"
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      # version = "= 2.97"
    }
  }
}

provider "azurerm" {
  features {}
}
