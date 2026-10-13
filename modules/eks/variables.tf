variable "project_name" {
  description = "Project name for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name for tagging"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for EKS cluster and nodes"
  type        = list(string)
}
