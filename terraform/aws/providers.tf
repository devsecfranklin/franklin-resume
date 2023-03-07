provider "aws" {
  profile = "default"
  region  = var.region
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  /*
  backend "s3" {
    key    = "global/s3/lab-franklin-aws-tfstate"
    region = "us-west-1"
    bucket = "ps-east-lab-franklin"
    //dynamodb_table = "franklin-terraform-state-locking"
  }
  */

}

