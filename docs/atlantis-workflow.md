# Atlantis Terraform Workflow

This repo uses Terraform for AWS infrastructure provisioning and Ansible for instance configuration.

Atlantis is added as a pull-request-driven Terraform workflow tool. The goal is to make infrastructure changes reviewable before apply.

## Responsibilities

Terraform:
- Provisions AWS infrastructure
- Manages EC2, IAM, S3, SSM logging resources, and related AWS dependencies

Ansible:
- Configures provisioned instances
- Installs packages
- Applies baseline system configuration
- Configures services such as Nginx, Docker, and CloudWatch Agent

Atlantis:
- Detects Terraform changes in pull requests
- Runs `terraform plan`
- Comments the plan output back on the PR
- Allows `terraform apply` only after review/approval

## Workflow

1. Create a feature branch.
2. Modify Terraform files under `terraform/`.
3. Open a pull request.
4. Atlantis automatically runs:

```bash
terraform init
terraform plan
