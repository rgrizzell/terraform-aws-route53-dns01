# terraform-aws-route53-dns01

Terraform module to allow a given IAM role to update its DNS01 Challenge records in a given zone.

This module seeks to implement least-privilege, only allowing the role to update its own challenge records in the
specified zone and nothing else. Defaults to `_acme-challenge.<zone_domain_name>`.

```hcl
module "alice_certbot" {
  source = "rgrizzell/route53-dns01/aws"
  iam_role_name = aws_iam_instance_profile.alice.id
  route53_zone_id = aws_route53_zone.public_zone_east.zone_id
  zone_records = [
    aws_route53_record.alice_public.name,
    aws_route53_record.myapp_public.name
  ]
}
```
