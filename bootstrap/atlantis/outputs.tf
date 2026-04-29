output "atlantis_url" {
  description = "Public Atlantis URL for GitHub webhook configuration."
  value       = "http://${aws_lb.atlantis.dns_name}"
}

output "github_webhook_url" {
  description = "GitHub webhook payload URL."
  value       = "http://${aws_lb.atlantis.dns_name}/events"
}
