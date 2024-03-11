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

// Alice's existence.
resource "aws_instance" "alice" {
  ami                         = "ami-0f5daaa3a7fb3378b"
  instance_type               = "t2.micro"
  iam_instance_profile        = aws_iam_instance_profile.alice.name
  associate_public_ip_address = true
  tags = {
    Name = "alice"
  }
}
resource "aws_iam_instance_profile" "alice" {
  name = "AliceInstanceProfile"
  role = aws_iam_role.alice.name
}
resource "aws_iam_role" "alice" {
  name               = "AliceInstanceRole"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
  }
}


resource "aws_route53_zone" "main" {
  name = "us-west-1.example.com"
}
resource "aws_route53_record" "alice_main" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "alice.us-west-1.example.com"
  type    = "CNAME"
  ttl     = 300
  records = [aws_instance.alice.public_dns]
}

resource "aws_route53_zone" "public" {
  name = "example.com"
}
resource "aws_route53_record" "alice_public" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "alice.example.com"
  type    = "CNAME"
  ttl     = 300
  records = [aws_instance.alice.public_dns]
}
resource "aws_route53_record" "myapp_public" {
  zone_id = aws_route53_zone.public.zone_id
  name    = "myapp.example.com"
  type    = "CNAME"
  ttl     = 300
  records = [aws_instance.alice.public_dns]
}