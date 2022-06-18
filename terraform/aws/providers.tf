provider "aws" {
  profile = "default"
  region  = var.region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.19"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.2.0"
    }
  }

  backend "s3" {
    //key    = "tf-state-nj-courts"
    key    = "franklin.tfstate"
    region = "us-east-2"
    bucket = "ps-devsecops-tf-state-242206"
    //dynamodb_table = "franklin-terraform-state-locking"
  }
  required_version = ">= 0.13, < 2.0"
  //required_version = "~> 1.0"
}

