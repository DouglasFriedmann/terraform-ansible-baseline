data "aws_caller_identity" "current" {}

data "datadog_integration_aws_iam_permissions" "datadog_permissions" {
  count = var.enable_datadog ? 1 : 0
}

locals {
  datadog_iam_permissions = var.enable_datadog ? data.datadog_integration_aws_iam_permissions.datadog_permissions[0].iam_permissions : []
}

data "aws_iam_policy_document" "datadog_aws_integration" {
  count = var.enable_datadog ? 1 : 0

  statement {
    actions   = local.datadog_iam_permissions
    resources = ["*"]
  }
}

resource "aws_iam_policy" "datadog_aws_integration" {
  count = var.enable_datadog ? 1 : 0

  name   = "DatadogAWSIntegrationPolicy"
  policy = data.aws_iam_policy_document.datadog_aws_integration[0].json
}

resource "datadog_integration_aws_account" "this" {
  count = var.enable_datadog ? 1 : 0

  aws_account_id = data.aws_caller_identity.current.account_id
  aws_partition  = "aws"

  aws_regions {
    include_all = true
  }

  auth_config {
    aws_auth_config_role {
      role_name = "DatadogIntegrationRole"
    }
  }

  resources_config {
    cloud_security_posture_management_collection = false
    extended_collection                          = true
  }

  metrics_config {
    namespace_filters {}
  }

  traces_config {
    xray_services {}
  }

  logs_config {
    lambda_forwarder {}
  }
}

data "aws_iam_policy_document" "datadog_assume_role" {
  count = var.enable_datadog ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::464622532012:root"]
    }

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values = [
        datadog_integration_aws_account.this[0].auth_config.aws_auth_config_role.external_id
      ]
    }
  }
}

resource "aws_iam_role" "datadog_integration" {
  count = var.enable_datadog ? 1 : 0

  name               = "DatadogIntegrationRole"
  description        = "Role used by Datadog AWS integration."
  assume_role_policy = data.aws_iam_policy_document.datadog_assume_role[0].json

  tags = {
    Project = var.project
  }
}

resource "aws_iam_role_policy_attachment" "datadog_integration" {
  count = var.enable_datadog ? 1 : 0

  role       = aws_iam_role.datadog_integration[0].name
  policy_arn = aws_iam_policy.datadog_aws_integration[0].arn
}

resource "aws_iam_role_policy_attachment" "datadog_security_audit" {
  count = var.enable_datadog ? 1 : 0

  role       = aws_iam_role.datadog_integration[0].name
  policy_arn = "arn:aws:iam::aws:policy/SecurityAudit"
}
