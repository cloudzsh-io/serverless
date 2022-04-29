data "aws_route53_zone" "hosted_zone" {
  name = local.hosted_zone_name
  private_zone = false
}