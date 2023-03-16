/*
resource "aws_subnet" "jump" {
  vpc_id            = aws_vpc.lab-franklin.id
  cidr_block        = "172.16.243.0/28"
  availability_zone = "${var.region}a"

  tags = var.tags
    lifecycle {
    prevent_destroy = true
  }
}

resource "aws_security_group" "jump" {
  description = "Allow SSH to the jumpbox"
  vpc_id      = aws_vpc.lab-franklin.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = var.aws_security_group_cidr_blocks
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_instance" "jump" {
  ami                         = var.aws_instance_ami
  instance_type               = var.aws_instance_instance_type
  key_name                    = var.aws_instance_key_name
  vpc_security_group_ids      = [aws_security_group.jump.id]
  subnet_id                   = aws_subnet.jump.id
  associate_public_ip_address = true

  root_block_device {
    volume_size = var.aws_instance_volume_size
  }

  tags = var.tags
}

resource "aws_eip" "jump" {
  instance = aws_instance.jump.id
  vpc      = true

  tags = var.tags

    lifecycle {
    prevent_destroy = true
  }
}
*/