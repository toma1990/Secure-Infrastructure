# Secure Infrastructure Baseline

Terraform modules that provision a secure AWS environment from scratch 
with security controls enabled by default. Everything is defined as 
code so the baseline is reproducible, version controlled, and auditable.

## What I set out to solve

Manually configuring security controls through the AWS console means 
they can be accidentally changed or deleted with no audit trail. This 
project codifies the security baseline from my other portfolio projects 
into Terraform so it is reproducible, reviewable, and version controlled.

## What I implemented

Six Terraform modules provisioning a connected security baseline:

| Module | Purpose |
|--------|---------|
| iam | Account password policy and least-privilege security auditor role |
| cloudtrail | Multi-region trail with encrypted S3 storage and log validation |
| guardduty | Threat detection with S3, Kubernetes and malware protection enabled |
| s3 | Account-level public access block and encrypted IR evidence bucket |
| vpc | Private and public subnets with NAT gateway for EKS node egress |
| eks | Kubernetes cluster with KMS secrets encryption and full audit logging |

GitHub Actions CI/CD pipeline runs on every push with tfsec and 
Checkov scanning the Terraform code for security misconfigurations.

## Why I chose this approach

Each of the other portfolio projects configures AWS resources manually 
via boto3. Terraform means those same resources can be provisioned 
consistently across environments, reviewed in pull requests, and 
restored quickly if something is accidentally changed or deleted.

The module structure separates concerns so security controls can be 
applied independently without coupling unrelated infrastructure.

## What I validated

- terraform validate passed with no errors
- terraform plan reviewed before every apply
- terraform apply successfully deployed all resources against a real AWS account
- GitHub Actions pipeline runs tfsec and Checkov on every push
- EKS cluster provisioned and node group joined successfully
- Compliance Scanner (Project 6) confirmed CloudTrail and GuardDuty 
  controls passing after this baseline was applied

## Security decisions and trade-offs

| Decision | What was done | Production alternative |
|----------|--------------|----------------------|
| EKS API access | Public endpoint, 0.0.0.0/0 | Restrict to trusted CIDRs or private only |
| Terraform state | Local state file | S3 backend with DynamoDB locking |
| Security auditor role | Trusts EC2 service broadly | Scope trust to specific principals with conditions |
| NAT gateway | Single AZ for cost | Multi-AZ for high availability |
| State file exposure | tfstate committed accidentally, removed from history | Never commit state, use remote backend from day one |

The state file issue was the most important lesson. A .gitignore rule 
does not remove files already tracked by git. The files were purged 
from history using git filter-branch. The state files contained no 
credentials or access keys - only resource IDs and configuration.

## Cost and teardown

Resources with ongoing costs:
- EKS cluster: approximately $0.10 per hour
- NAT gateway: approximately $0.045 per hour plus data transfer
- CloudTrail: free tier covers most lab usage

The EKS and VPC modules were destroyed after validation to avoid 
ongoing charges. The security baseline modules (IAM, CloudTrail, 
GuardDuty, S3) remain deployed as they are low cost and used by 
other portfolio projects.

To destroy the expensive resources:

terraform destroy -target=module.eks -target=module.vpc

## Structure

modules/
  iam/          - Password policy and security auditor role
  cloudtrail/   - Trail, S3 bucket, encryption, bucket policy
  guardduty/    - Detector with all data sources enabled
  s3/           - Account public access block and IR evidence bucket
  vpc/          - VPC, public and private subnets, NAT gateway
  eks/          - EKS cluster, node group, KMS secrets encryption

## Required permissions

Deploying this baseline requires IAM permissions to create and 
manage IAM roles and policies, S3 buckets, CloudTrail trails, 
GuardDuty detectors, VPC resources, and EKS clusters.

## What I would change before production

- Remote Terraform state in S3 with DynamoDB locking and versioning
- EKS API endpoint restricted to specific trusted IP ranges
- Security auditor role trust policy scoped to specific principals
- Multi-AZ NAT gateways for production resilience
- Separate AWS accounts for different environments
- Automated drift detection to catch manual console changes
