output "security_auditor_role_arn" {
  description = "ARN of the security auditor role"
  value       = aws_iam_role.security_auditor.arn
}
