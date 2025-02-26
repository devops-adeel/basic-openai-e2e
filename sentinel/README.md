# Sentinel Policies for Azure OpenAI Architecture

This directory contains Sentinel policies for enforcing security standards and CIS Azure Foundations Benchmark recommendations for the Azure OpenAI architecture.

## Policy Sets

The policies are organized into policy sets that correspond to CIS Azure Foundations Benchmark sections:

- **Identity and Access Management**: Policies for enforcing proper identity and access controls
- **Security Configuration**: Policies for enforcing secure configurations for Azure resources
- **Logging and Monitoring**: Policies for ensuring proper logging and monitoring
- **Networking**: Policies for enforcing secure networking configurations
- **Data Protection**: Policies for ensuring data protection measures

## How to Use

These policies are designed to be used with HashiCorp Terraform Cloud or Terraform Enterprise. To use these policies:

1. Upload the policy sets to your Terraform Cloud/Enterprise organization
2. Create policy sets in Terraform Cloud/Enterprise and associate them with your workspaces
3. Configure the policies to be advisory or mandatory based on your requirements

## Policy Enforcement

Policies can be configured with the following enforcement levels:

- **Advisory**: Policy violations are reported but do not prevent deployments
- **Soft Mandatory**: Policy violations prevent deployments but can be overridden
- **Hard Mandatory**: Policy violations prevent deployments and cannot be overridden

For development environments, you may want to set policies to advisory mode. For production environments, consider using mandatory enforcement to ensure compliance.

## CIS Azure Foundations Benchmark

These policies are designed to help enforce the CIS Azure Foundations Benchmark recommendations. The CIS Azure Foundations Benchmark provides prescriptive guidance for establishing a secure baseline configuration for Azure.

Key sections covered include:

- Identity and Access Management
- Security Center
- Storage Accounts
- Virtual Networks
- Virtual Machines
- Logging and Monitoring
- Key Vault
- App Service

For more information, refer to the [CIS Azure Foundations Benchmark documentation](https://www.cisecurity.org/benchmark/azure/).
