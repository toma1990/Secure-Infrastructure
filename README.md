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

## Known issues and production considerations

This is a learning project and several decisions were made for 
simplicity that would be done differently in a production environment.

### Terraform state
State files were accidentally committed to this repository before
the .gitignore was properly configured. This demonstrates an important
lesson - a .gitignore rule does not remove files that are already
tracked by git. The files have since been removed from history using
git filter-branch. In production, state should be stored remotely
in an S3 bucket with DynamoDB locking and never committed to version
control.

### EKS public endpoint
The EKS API endpoint is publicly accessible from any IP address.
In production this would be restricted to specific trusted CIDR
ranges or set to private-only access. Public access was used here
to simplify connectivity during development.

### Security auditor role trust policy
The security auditor role trusts the EC2 service broadly. In
production the trust policy would be scoped to specific principals
using conditions, and the permissions would be reviewed against the
actual needs of each tool rather than using the broad SecurityAudit
managed policy.

### Local Terraform state
This project uses local state which is not suitable for team
environments or production use. A production setup would use an
S3 backend with DynamoDB state locking and versioning enabled.

### Cost awareness
The NAT gateway and EKS cluster incur ongoing AWS charges if left
running. Run terraform destroy when not actively using the cluster.
The security baseline resources (IAM, CloudTrail, GuardDuty, S3)
are low cost and can remain deployed.
