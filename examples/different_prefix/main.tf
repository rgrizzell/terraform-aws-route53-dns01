// The instance will be using Certbot as the ACME client to Let's Encrypt.
module "alice_certbot" {
  source           = "rgrizzell/route53-dns01/aws"
  iam_role_name    = aws_iam_instance_profile.alice.id
  route53_zone_id  = aws_route53_zone.public_zone_east.zone_id
  challenge_prefix = "my_custom_record"
  zone_records     = [
    aws_route53_record.myapp_public.name,
  ]
}


// Alice's existence.
resource "aws_instance" "alice" {
  ami                         = data.aws_ami.ubuntu_22
  instance_type               = "t2.micro"
  iam_instance_profile        = aws_iam_instance_profile.alice.name
  associate_public_ip_address = true
}
resource "aws_iam_instance_profile" "alice" {
  name = "AliceInstanceProfile"
  role = aws_iam_role.alice.name
}
resource "aws_iam_role" "alice" {
  name = "AliceInstanceRole"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}
data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ec2.amazonaws.com"]
      type        = "Service"
    }
    resources = [module.alice_certbot.iam_role_policy.arn]
  }
}


// To demonstrate this example, Alice handles traffic for itself and another domain.
// Both must have valid TLS certificates.
resource "aws_route53_zone" "public_zone_east" {
  name = "us-east.example.com"
}
resource "aws_route53_record" "alice_public" {
  zone_id = aws_route53_zone.public_zone_east.zone_id
  name    = "alice.us-east.example.com"
  type    = "CNAME"
  ttl     = 300
  records = [aws_instance.alice.public_dns]
}
resource "aws_route53_record" "myapp_public" {
  zone_id = aws_route53_zone.public_zone_east.zone_id
  name    = "myapp.us-east.example.com"
  type    = "CNAME"
  ttl     = 300
  records = [aws_instance.alice.public_dns]
}

data "aws_ami" "ubuntu_22" {
    most_recent = true
    filter {
        name   = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
    owners = ["099720109477"]
}
