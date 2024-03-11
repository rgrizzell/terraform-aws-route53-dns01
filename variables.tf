variable "iam_role_name" {
  type        = string
  description = "The IAM role name to allow"
}

variable "iam_policy_name" {
  type        = string
  description = "The IAM policy name you wish to set."
  default     = "Route53ChallengeRecords"
}

variable "route53_zone_id" {
  type        = string
  description = "The ID of the Route53 zone to add challenge records to"
  validation {
    condition     = can(regex("[A-Z0-9]{8,32}", var.route53_zone_id))
    error_message = "The provided zone ID is invalid."
  }
}

variable "zone_records" {
  type        = list(string)
  description = "The list of zone records to allow challenge records"
  validation {
    condition     = length(var.zone_records) > 0
    error_message = "A list of one more more zone records must be specified."
  }
}

variable "challenge_prefix" {
  type        = string
  description = "The record prefix used for the challenge records."
  default     = "_acme-challenge"
}