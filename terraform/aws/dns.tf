data "aws_route53_zone" "w-aws" {
  name = var.dns_zone
}

resource "aws_route53_record" "jumphost" {
  zone_id = data.aws_route53_zone.w-aws.zone_id
  name    = "${var.name}-jumphost"
  type    = "A"
  ttl     = 600
  records = [
    aws_instance.jumphost.public_ip
  ]
}
