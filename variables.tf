variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "eu-west-2"
}

variable "environment" {
  description = "Environment name - used for tagging and naming resources"
  type        = string
  default     = "security-lab"
}

variable "project_name" {
  description = "Project name - used for resource naming"
  type        = string
  default     = "secure-infra"
}
