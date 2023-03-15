resource "aws_vpc" "lab-franklin" {
  cidr_block = "172.16.240.0/20"
  lifecycle {
    prevent_destroy = true
  }
}
