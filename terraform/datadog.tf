variable "enable_datadog" {
  description = "Whether to create Datadog monitors and observability resources."
  type        = bool
  default     = false
}

variable "datadog_api_key" {
  description = "Datadog API key."
  type        = string
  sensitive   = true
  default     = null
}

variable "datadog_app_key" {
  description = "Datadog application key."
  type        = string
  sensitive   = true
  default     = null
}

variable "datadog_site" {
  description = "Datadog site."
  type        = string
  default     = "datadoghq.com"
}

provider "datadog" {
  api_key  = var.datadog_api_key
  app_key  = var.datadog_app_key
  api_url  = "https://api.${var.datadog_site}/"
  validate = var.enable_datadog
}
