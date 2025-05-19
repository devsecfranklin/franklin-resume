provider "aws" {
  profile = "default"
  region  = var.region
}

provider "aws" {
  region = "ca-central-1"
  alias  = "base"
}

/*
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    region = "${var.vpc_state_region}"
    bucket = "${var.vpc_bucket}"
    key    = "${var.vpc_state_key}"
  }
}


terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "s3" {
    region = "ca-central-1"
    bucket = "lab-franklin-tfstate"
    key    = "lab-franklin-tfstate-key"
    //dynamodb_table = "franklin-terraform-state-locking"
  }
}
*/
