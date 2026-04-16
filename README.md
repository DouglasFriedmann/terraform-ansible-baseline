# Terraform + Ansible AWS Baseline

A production-style infrastructure and configuration automation project that provisions AWS infrastructure with Terraform and configures Linux hosts using Ansible over AWS Systems Manager (SSM).

## Overview

This project demonstrates an end-to-end DevOps workflow:

- **Terraform** provisions AWS infrastructure
- **Ansible** configures EC2 instances using dynamic inventory
- **SSM (no SSH)** enables secure, agent-based access
- **Docker + Nginx** provide application runtime and web service
- **CloudWatch Agent** enables logs and metrics collection
- **GitHub Actions** enforces CI validation

## Architecture

Terraform → AWS EC2 (Ubuntu)
↓
IAM Role (SSM + CloudWatch)
↓
Ansible (via SSM, no SSH)
↓

Baseline OS config
Docker installation
Nginx deployment
CloudWatch agent setup

## Key Features

- **Infrastructure as Code**
  - VPC, subnet, routing, security groups
  - EC2 instance with IAM role
  - Remote state (S3 + DynamoDB)

- **Configuration Management**
  - Dynamic AWS inventory (`amazon.aws.aws_ec2`)
  - Role-based Ansible structure
  - Idempotent playbooks

- **Security-first Access**
  - No SSH required
  - Uses AWS Systems Manager Session Manager

- **Observability**
  - CloudWatch Agent installed via Ansible
  - Logs:
    - `/var/log/syslog`
    - `/var/log/nginx/access.log`
  - Metrics:
    - CPU
    - Memory (custom)

- **CI/CD**
  - Terraform validation workflow
  - Ansible linting workflow

## Project Structure


terraform/ # AWS infrastructure
inventory/ # Dynamic inventory config
playbooks/ # Ansible playbooks
roles/
common/ # OS baseline + hardening
docker/ # Docker installation
nginx/ # Web server + template
cloudwatch_agent/ # Logs + metrics
.github/workflows/ # CI pipelines


## Usage

1. Provision Infrastructure
cd terraform
terraform init
terraform apply
2. Configure Instance
ansible-playbook playbooks/site.yml
3. Access Web Server
terraform output public_ip

Open:

http://<public_ip>

## Highlights
Uses SSM instead of SSH for secure instance access
Demonstrates separation of concerns between Terraform and Ansible
Implements idempotent configuration management
Includes observability and monitoring, not just provisioning

