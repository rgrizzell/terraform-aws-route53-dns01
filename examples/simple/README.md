# Example: Simple
This example utilizes an EC2 instance using Certbot to retrieve certifications for two domains.

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