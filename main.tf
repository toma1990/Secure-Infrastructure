
# Get current account ID automatically
data "aws_caller_identity" "current" {}

# IAM security baseline
module "iam" {
  source       = "./modules/iam"
  project_name = var.project_name
  environment  = var.environment
}

# CloudTrail logging
module "cloudtrail" {
  source       = "./modules/cloudtrail"
  project_name = var.project_name
  environment  = var.environment
  account_id   = data.aws_caller_identity.current.account_id
}

# GuardDuty threat detection
module "guardduty" {
  source      = "./modules/guardduty"
  environment = var.environment
}

# S3 security baseline
module "s3" {
  source       = "./modules/s3"
  project_name = var.project_name
  environment  = var.environment
  account_id   = data.aws_caller_identity.current.account_id
}# Main Terraform configuration for secure AWS infrastructure
# All resources are provisioned with security controls enabled by default

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Remote state would go in S3 in a real environment
# Using local state for this portfolio project
