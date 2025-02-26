# Sentinel Policy Coverage

This document provides details about the Sentinel policy coverage for the Azure OpenAI Chat Reference Architecture.

## Policy Sets

The Sentinel policies are organized into two policy sets:

1. **Basic Policy Set**: For the basic reference architecture
2. **Production Policy Set**: Additional policies and stricter enforcement for production environments

## Policy Categories

### Identity and Access Management

| Policy | Description | CIS Benchmark | Enforcement |
|--------|-------------|--------------|-------------|
| require-managed-identity.sentinel | Ensures Azure resources use managed identities for authentication | CIS Azure 1.21 | Hard-Mandatory |

### Security Configuration

| Policy | Description | CIS Benchmark | Basic Enforcement | Production Enforcement |
|--------|-------------|--------------|-------------------|------------------------|
| enforce-resource-tagging.sentinel | Ensures resources are tagged consistently | CIS Azure 1.23 | Soft-Mandatory | Hard-Mandatory |
| require-https-and-tls.sentinel | Ensures HTTPS and TLS 1.2+ are used | CIS Azure 9.1, 9.4 | Hard-Mandatory | Hard-Mandatory |
| secure-key-vault.sentinel | Validates Key Vault security settings | CIS Azure 8.1-8.5 | Hard-Mandatory | Hard-Mandatory |
| openai-content-filter.sentinel | Ensures OpenAI content filtering | N/A | Hard-Mandatory | Hard-Mandatory |
| storage-security.sentinel | Validates storage security settings | CIS Azure 3.1-3.8 | Soft-Mandatory | Hard-Mandatory |
| container-registry-security.sentinel | Ensures ACR security configuration | CIS Azure 9.5, 9.6 | Soft-Mandatory | Hard-Mandatory |
| azure-ml-security.sentinel | Validates ML workspace and endpoint security | N/A | Soft-Mandatory | Hard-Mandatory |
| search-configuration.sentinel | Ensures Search service configuration | N/A | Advisory | Soft-Mandatory |
| network-security.sentinel | Validates network security settings | CIS Azure 6.1-6.6 | Advisory | Soft-Mandatory |
| ai-foundry-security.sentinel | Validates AI Foundry security | N/A | Soft-Mandatory | Hard-Mandatory |
| app-service-security.sentinel | Ensures App Service security | CIS Azure 9.1-9.10 | Hard-Mandatory | Hard-Mandatory |

### Logging and Monitoring

| Policy | Description | CIS Benchmark | Basic Enforcement | Production Enforcement |
|--------|-------------|--------------|-------------------|------------------------|
| require-diagnostic-settings.sentinel | Ensures diagnostic logging is enabled | CIS Azure 5.1.3, 5.1.5 | Soft-Mandatory | Hard-Mandatory |

## CIS Azure Benchmark Coverage

This section maps the CIS Azure Foundations Benchmark recommendations to the Sentinel policies that enforce them.

### 1. Identity and Access Management

| CIS Recommendation | Sentinel Policy |
|--------------------|-----------------|
| 1.21: Ensure that a Managed Identity is used for Resource Deployment | require-managed-identity.sentinel |
| 1.23: Ensure that 'Unattached disks' are encrypted with CMK | enforce-resource-tagging.sentinel |

### 3. Storage Accounts

| CIS Recommendation | Sentinel Policy |
|--------------------|-----------------|
| 3.1: Ensure that 'Secure transfer required' is set to 'Enabled' | storage-security.sentinel |
| 3.3: Ensure Storage logging is enabled for Queue service | storage-security.sentinel |
| 3.6: Ensure that 'Public access level' is set to Private for blob containers | storage-security.sentinel |
| 3.7: Ensure default network access rule for Storage Accounts is set to deny | storage-security.sentinel, network-security.sentinel |

### 5. Logging and Monitoring

| CIS Recommendation | Sentinel Policy |
|--------------------|-----------------|
| 5.1.3: Ensure that Diagnostic Logs are enabled for all services | require-diagnostic-settings.sentinel |
| 5.1.5: Ensure that logging for Azure Key Vault is 'Enabled' | require-diagnostic-settings.sentinel |

### 6. Networking

| CIS Recommendation | Sentinel Policy |
|--------------------|-----------------|
| 6.1-6.6: Network Security Group and Firewall configurations | network-security.sentinel |

### 8. Key Vault

| CIS Recommendation | Sentinel Policy |
|--------------------|-----------------|
| 8.1: Ensure that the expiration date is set on all keys | secure-key-vault.sentinel |
| 8.2: Ensure that the expiration date is set on all secrets | secure-key-vault.sentinel |
| 8.4: Ensure the Key Vault is recoverable | secure-key-vault.sentinel |

### 9. App Service

| CIS Recommendation | Sentinel Policy |
|--------------------|-----------------|
| 9.1: Ensure web app redirects all HTTP traffic to HTTPS | require-https-and-tls.sentinel, app-service-security.sentinel |
| 9.2: Ensure web app uses latest TLS version | require-https-and-tls.sentinel, app-service-security.sentinel |
| 9.3: Ensure web app is using managed identity | require-managed-identity.sentinel, app-service-security.sentinel |
| 9.4: Ensure the web app has 'Client Certificate Enabled' | app-service-security.sentinel |
| 9.5: Ensure Container Registry has content trust policy enabled | container-registry-security.sentinel |
| 9.6: Minimize admin access for Container Registries | container-registry-security.sentinel |
| 9.9: Ensure that 'HTTP Version' is the latest if used to run the web app | app-service-security.sentinel |

## Azure-Specific Policies

In addition to CIS Benchmark recommendations, we've included policies specific to Azure OpenAI architecture:

1. **Content Filtering**: Ensures OpenAI deployments have appropriate content filtering
2. **AI Foundry Security**: Validates AI Foundry hub and project security settings
3. **Azure ML Security**: Ensures ML workspaces and endpoints use managed identities
4. **Search Configuration**: Validates Azure AI Search service configuration

## Enforcement Strategy

The enforcement strategy differs between basic and production environments:

1. **Basic Environment**:
   - Critical security controls: Hard-Mandatory
   - Important best practices: Soft-Mandatory
   - Production-specific controls: Advisory

2. **Production Environment**:
   - Most policies: Hard-Mandatory
   - Network and search controls: Soft-Mandatory
   - No Advisory policies

## Customizing Policies

To customize the policies for your specific requirements:

1. **Modify Policy Files**: Adjust rules in individual policy files
2. **Update sentinel.hcl**: Change enforcement levels or policy sets
3. **Create New Policies**: Add custom policies for specific requirements

## Implementation

To apply these policies:

1. **Terraform Cloud**: Upload to your organization and apply to workspaces
2. **Terraform Enterprise**: Configure policy sets in your organization
3. **CI/CD Integration**: Run Sentinel checks as part of your pipeline
