variable "aws_region" {
  description = "AWS region for Atlantis bootstrap infrastructure."
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name prefix."
  type        = string
  default     = "atlantis-bootstrap"
}

variable "github_user" {
  description = "GitHub username Atlantis uses to comment on PRs."
  type        = string
}

variable "github_token" {
  description = "GitHub token for Atlantis."
  type        = string
  sensitive   = true
}

variable "github_webhook_secret" {
  description = "GitHub webhook secret shared by GitHub and Atlantis."
  type        = string
  sensitive   = true
}

variable "repo_allowlist" {
  description = "Atlantis repo allowlist."
  type        = string
  default     = "github.com/DouglasFriedmann/terraform-ansible-baseline"
}

variable "datadog_api_key" {
  description = "Datadog API key for Atlantis Terraform runs."
  type        = string
  sensitive   = true
}

variable "datadog_app_key" {
  description = "Datadog application key for Atlantis Terraform runs."
  type        = string
  sensitive   = true
}

variable "datadog_site" {
  description = "Datadog site for Atlantis Terraform runs."
  type        = string
  default     = "datadoghq.com"
}
