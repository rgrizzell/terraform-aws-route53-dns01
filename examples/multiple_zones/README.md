# Multiple Zones
Adding support for multiple zones is a matter of defining the module for each zone and specifying a different policy
name. Failure to set `iam_policy_name` will result in over module overwriting the policy for the other module.

In this example, Alice can update:
- `alice.example.com`
- `myapp.example.com`
- `alice.us-west-1.example.com`

```hcl
module "alice_certbot_public" {
  source          = "rgrizzell/route53-dns01/aws"
  iam_policy_name = "PublicRoute53ChallengeRecords"
  iam_role_name   = aws_iam_role.alice.id
  route53_zone_id = aws_route53_zone.public.zone_id
  zone_records = [
    aws_route53_record.alice_public.name,
    aws_route53_record.myapp_public.name
  ]
}

module "alice_certbot_main" {
  source          = "rgrizzell/route53-dns01/aws"
  iam_policy_name = "MainRoute53ChallengeRecords"
  iam_role_name   = aws_iam_role.alice.id
  route53_zone_id = aws_route53_zone.main.zone_id
  zone_records = [
       aws_route53_record.alice_main.name
  ]
}
```
