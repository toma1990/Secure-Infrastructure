output "security_auditor_role_arn" {
  description = "ARN of the security auditor IAM role"
  value       = module.iam.security_auditor_role_arn
}

output "cloudtrail_bucket" {
  description = "S3 bucket storing CloudTrail logs"
  value       = module.cloudtrail.cloudtrail_bucket_name
}

output "ir_evidence_bucket" {
  description = "S3 bucket for IR evidence storage"
  value       = module.s3.ir_evidence_bucket_name
}

