/*
 * This file contains things we will use for testing. 
 *
 * Rename this file (something besides *.tf) and do a terraform apply to
 * remove the test framework.
 */

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

module "testing_ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "4.0.0"

  name = "nj-courts-test-instance"

  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.micro"
  key_name               = var.ssh_key_name
  monitoring             = true
  vpc_security_group_ids = [module.security_vpc.security_group_ids["nj-courts-fw-mgmt"]]
  subnet_id              = module.security_subnet_sets["nj-courts-mgmt"].subnets["us-east-1b"].id

  tags = {
    ps = "franklin"
  }
}

resource "aws_eip" "nj-courts-test-instance" {
  vpc      = true
  instance = module.testing_ec2.id
}

