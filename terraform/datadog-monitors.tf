resource "datadog_monitor" "ec2_status_check_failed" {
  count = var.enable_datadog ? 1 : 0

  name = "EC2 status check failed - terraform-ansible-baseline"
  type = "query alert"

  query = "max(last_5m):max:aws.ec2.status_check_failed{project:ansible-baseline} by {instance_id} >= 1"

  message = <<EOT
EC2 status check failure detected for terraform-ansible-baseline.

Investigate:
- EC2 system/instance status checks
- SSM managed instance connectivity
- Recent patching or configuration changes
- CloudWatch Agent health

Runbook: docs/datadog-observability.md
EOT

  monitor_thresholds {
    critical = 1
  }

  tags = [
    "project:ansible-baseline",
    "managed-by:terraform",
    "service:cloud-ops"
  ]
}
