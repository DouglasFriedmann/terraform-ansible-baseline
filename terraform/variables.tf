variable "aws_region" {
  description = "AWS region for project resources"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project tag value"
  type        = string
  default     = "ansible-baseline"
}

variable "environment" {
  description = "Environment tag value"
  type        = string
  default     = "dev"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "my_ip_cidr" {
  description = "Optional CIDR allowed for SSH access"
  type        = string
  default     = ""
}
