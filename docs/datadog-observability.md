# Datadog Observability

This repo uses CloudWatch as the AWS-native telemetry source and Datadog as an optional external observability layer.

## Goal

Provide centralized monitoring for infrastructure managed by Terraform and configured by Ansible.

## Signals

Initial monitor coverage:

- EC2 status check failures
- Host health issues after patching
- SSM connectivity concerns
- CloudWatch Agent health
- Future: disk, memory, and service-level checks from the Datadog Agent

## Workflow

1. Terraform provisions AWS infrastructure.
2. Ansible configures EC2 instances.
3. CloudWatch collects AWS-native metrics and logs.
4. Datadog consumes AWS metrics through the AWS integration.
5. Datadog monitors alert on operational risk.

## Why This Matters

This supports a Cloud Ops workflow focused on:

- patching visibility
- upgrade safety
- operational monitoring
- faster incident triage
- infrastructure-as-code-managed alerting
