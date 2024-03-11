locals {
  trimmed_records = [for record in var.zone_records : trimsuffix(record, ".${data.aws_route53_zone.target_zone.name}")]
}

resource "aws_iam_role_policy" "dns01_updates" {
  name   = var.iam_policy_name
  role   = var.iam_role_name
  policy = data.aws_iam_policy_document.dns01.json
}
data "aws_iam_policy_document" "dns01" {
  statement {
    actions   = ["route53:GetChange"]
    effect    = "Allow"
    resources = ["arn:aws:route53:::change/*"]
  }
  statement {
    actions = [
      "route53:ListHostedZones",
      "route53:ListHostedZonesByName"
    ]
    effect    = "Allow"
    sid       = "ListZones"
    resources = ["*"]
  }
  statement {
    actions   = ["route53:ListResourceRecordSets"]
    effect    = "Allow"
    sid       = "ListChallengeRecords"
    resources = [data.aws_route53_zone.target_zone.arn]
  }
  statement {
    actions   = ["route53:ChangeResourceRecordSets"]
    effect    = "Allow"
    sid       = "UpdateChallengeRecords"
    resources = [data.aws_route53_zone.target_zone.arn]
    condition {
      test     = "ForAllValues:StringEquals"
      values   = formatlist("%s.%s.%s", var.challenge_prefix, local.trimmed_records, data.aws_route53_zone.target_zone.name)
      variable = "route53:ChangeResourceRecordSetsNormalizedRecordNames"
    }
    condition {
      test     = "ForAllValues:StringEquals"
      values   = ["TXT"]
      variable = "route53:ChangeResourceRecordSetsRecordTypes"
    }
  }
}

data "aws_iam_role" "target_role" {
  name = var.iam_role_name
}
data "aws_route53_zone" "target_zone" {
  zone_id = var.route53_zone_id
}
