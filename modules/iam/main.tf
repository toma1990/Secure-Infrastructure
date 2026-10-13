
# IAM Security Baseline Module
# Enforces password policy, creates security audit role,
# and sets up least privilege access patterns

# Enforce a strong password policy across the account
resource "aws_iam_account_password_policy" "strict" {
  minimum_password_length        = 14
  require_uppercase_characters   = true
  require_lowercase_characters   = true
  require_numbers                = true
  require_symbols                = true
  allow_users_to_change_password = true
  max_password_age               = 90
  password_reuse_prevention      = 24
}

# Read-only security audit role - for running our Python security tools
resource "aws_iam_role" "security_auditor" {
  name = "${var.project_name}-security-auditor"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    Purpose     = "Security auditing - least privilege read only access"
  }
}

# Attach AWS managed security audit policy to the role
resource "aws_iam_role_policy_attachment" "security_audit" {
  role       = aws_iam_role.security_auditor.name
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}

