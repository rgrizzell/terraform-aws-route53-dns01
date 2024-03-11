# Example: Custom Challenge Name
If the ACME client is configured to utilize a different record name, `challenge_prefix` can be set. In ths example, the
ACME client is configuring a `TXT` record named `my_custom_record.myapp.us-east.example.com`.

```hcl
module "myapp_custom_prefix" {
  source           = "rgrizzell/route53-dns01/aws"
  iam_role_name    = aws_iam_instance_profile.alice.id
  route53_zone_id  = aws_route53_zone.public_zone_east.zone_id
  challenge_prefix = "my_custom_record"
  zone_records     = [
    aws_route53_record.myapp_public.name,
  ]
}
```