terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    datadog = {
      source  = "Datadog/datadog"
      version = "~> 4.0"
    }
  }
}
