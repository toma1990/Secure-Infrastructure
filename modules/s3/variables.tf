variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name for tagging"
  type        = string
}

variable "account_id" {
  description = "AWS account ID for bucket naming"
  type        = string
}
