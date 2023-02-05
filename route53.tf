# Get hosted zone details
resource "aws_route53_zone" "hosted_zone" {
  name = var.domain_name

  tags = {
    Environment = "dev"
  }
}

# Creating a record set
resource "aws_route53_record" "domain" {
  zone_id = aws_route53_zone.hosted_zone.id
  name    = "dev.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.mini_project_lb.dns_name
    zone_id                = aws_lb.mini_project_lb.zone_id
    evaluate_target_health = true
  }
}