# Secure Infrastructure

Terraform modules that provision a secure AWS environment from scratch 
with security controls enabled by default. Everything is defined as 
code so the baseline is reproducible, version controlled, and auditable.

## What it provisions

Four modules working together to create a secure AWS foundation:

### IAM Security Baseline
- Enforces a strong account-wide password policy (14 char minimum, 
  90 day expiry, 24 password history)
- Creates a least-privilege security auditor role for running 
  security tooling without admin credentials
- Attaches AWS SecurityAudit managed policy for read-only access

### CloudTrail Logging
- Multi-region trail capturing all management events
- Logs stored in a dedicated S3 bucket with AES-256 encryption
- Public access blocked at bucket level
- Bucket policy restricts writes to CloudTrail service only
- Log file validation enabled to detect tampering

### GuardDuty Threat Detection
- Continuous threat detection across the account
- S3 log analysis enabled
- Kubernetes audit log monitoring enabled
- Malware protection for EC2 EBS volumes enabled

### S3 Security Baseline
- Account-wide public access block - no bucket can be made 
  public regardless of individual bucket settings
- Dedicated IR evidence bucket with AES-256 encryption
- Versioning enabled on evidence bucket for integrity
- Lifecycle policy archives evidence to cheaper storage after 
  90 days and Glacier after 365 days

## Why I built this

Everything in my other security projects - CloudTrail, GuardDuty, 
IAM roles, S3 buckets - was being configured manually through the 
AWS console. That means it can be accidentally changed or deleted 
with no audit trail and no way to restore it quickly.

This Terraform baseline means the entire security foundation is 
defined in code, reviewed in Git, and reproducible with a single 
terraform apply. That is how security infrastructure should be 
managed in any real environment.

## How to use it

Configure AWS CLI with appropriate credentials, then:

terraform init
terraform plan
terraform apply

The plan output shows exactly what will be created before anything 
is deployed. All 15 resources provision in under 30 seconds.

## Outputs

After apply, Terraform outputs:
- Security auditor role ARN
- CloudTrail S3 bucket name  
- IR evidence bucket name

## Structure

modules/
  iam/          - Password policy and security auditor role
  cloudtrail/   - Trail, S3 bucket, encryption, bucket policy
  guardduty/    - Detector with all data sources enabled
  s3/           - Account public access block and IR evidence bucket

## What's next

Planning to add:
- EKS cluster module with Kubernetes security controls
- GitHub Actions CI/CD pipeline with automated Terraform 
  security scanning using tfsec
- Security Hub integration for centralised findings
