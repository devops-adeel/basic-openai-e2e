# Troubleshooting Guide

This document provides solutions for common issues that may arise when deploying or using the Azure OpenAI Chat Reference Architecture.

## Deployment Issues

### Terraform Initialization Failures

**Problem**: `terraform init` fails with provider or module errors.

**Solution**:
1. Check your internet connection and proxy settings
2. Verify Terraform version compatibility (`terraform -v`)
3. Delete the `.terraform` directory and try again
4. Check for authentication issues with the Azure provider

```bash
# Clear Terraform cache and reinitialize
rm -rf .terraform
rm -f .terraform.lock.hcl
terraform init
```

### Resource Creation Failures

**Problem**: `terraform apply` fails when creating specific resources.

**Solutions**:

#### Azure OpenAI Service Creation Fails
- Verify that Azure OpenAI is available in your selected region
- Check your subscription has quota for Azure OpenAI
- Request quota increase if needed via Azure Portal

#### Role Assignment Failures
- Verify you have Owner or User Access Administrator role in the subscription
- Wait a few minutes for AAD propagation and try again
- Check for naming conflicts with existing resources

#### ML Workspace Creation Fails
- Ensure dependent resources exist and are correctly referenced
- Check for naming conflicts or length restrictions
- Verify region supports all required services

### Timeouts

**Problem**: Terraform operations time out during resource creation.

**Solution**:
```hcl
# Increase timeouts in provider configuration
provider "azurerm" {
  features {}
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  
  # Add timeout configuration
  operation_timeout_seconds = 600
}

# Or add to individual resources
resource "azurerm_cognitive_account" "openai" {
  # ... resource configuration ...
  
  timeouts {
    create = "60m"
    update = "60m"
    delete = "60m"
  }
}
```

## Runtime Issues

### Authentication Problems

**Problem**: Services cannot authenticate with each other.

**Solutions**:

#### App Service Cannot Access Key Vault
1. Verify managed identity is enabled for App Service
2. Check that the identity has appropriate Key Vault permissions
3. Ensure Key Vault references in app settings are correct
4. Check Key Vault network access settings

#### ML Endpoint Cannot Access OpenAI
1. Verify role assignments for the managed identity
2. Check networking configuration if private endpoints are used
3. Inspect error logs in Application Insights for detailed messages

### Connection Issues

**Problem**: Services cannot connect to each other.

**Solutions**:

#### App Service Cannot Reach ML Endpoint
1. Verify endpoint URL in App Service settings
2. Check that the endpoint is deployed and running
3. Verify network connectivity if VNet integration is used
4. Check for TLS/certificate issues

#### Prompt Flow Cannot Access AI Search
1. Verify connection configuration in AI Foundry
2. Check that search service is accessible
3. Inspect logs for authentication or authorization errors

### Performance Issues

**Problem**: Response times are slow or timeouts occur.

**Solutions**:

#### OpenAI API Latency
1. Monitor API call patterns and response times
2. Increase capacity if rate limits are being hit
3. Implement caching for common queries
4. Consider upgrading to provisioned throughput

```python
# Example caching implementation for Python application
import redis
import json
import hashlib

cache = redis.Redis(host='your-redis-server', port=6379)

def get_openai_response(prompt, history=None):
    # Create a cache key from the prompt and history
    cache_key = hashlib.md5((prompt + str(history)).encode()).hexdigest()
    
    # Try to get from cache first
    cached_response = cache.get(cache_key)
    if cached_response:
        return json.loads(cached_response)
    
    # Call the OpenAI API
    response = call_openai_api(prompt, history)
    
    # Cache the response (with expiration)
    cache.setex(cache_key, 3600, json.dumps(response))
    
    return response
```

#### ML Endpoint Processing Time
1. Monitor CPU and memory usage
2. Consider scaling up or out if resources are constrained
3. Optimize prompt flow logic for performance
4. Implement request queuing for high traffic

## Logging and Diagnostics

### Enabling Verbose Logging

**App Service Logs**:
```bash
# Enable detailed logging via Azure CLI
az webapp log config --resource-group myResourceGroup --name myAppService --application-logging filesystem --level verbose --detailed-error-messages true --failed-request-tracing true
```

**Application Insights Queries**:
```kusto
# Find failed requests
requests
| where success == false
| project timestamp, name, resultCode, duration, operation_Id

# Check dependency failures
dependencies
| where success == false
| project timestamp, name, type, resultCode, operation_Id

# Look for exceptions
exceptions
| project timestamp, type, method, outerMessage, operation_Id
```

**OpenAI Service Logs**:
```kusto
# Query OpenAI API errors
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.COGNITIVESERVICES" 
| where Category == "RequestResponse"
| where StatusCode != 200
| project TimeGenerated, OperationName, StatusCode, RequestUrl, RequestQuery
```

### Diagnostic Tools

**Azure ML Diagnostics**:
```bash
# Check online endpoint status
az ml online-endpoint show -n myEndpoint -g myResourceGroup

# Get deployment logs
az ml online-deployment get-logs -e myEndpoint -n myDeployment -g myResourceGroup
```

**Container Registry Diagnostics**:
```bash
# Check container registry image status
az acr repository show-tags -n myRegistry --repository myRepository

# Check repository webhooks
az acr webhook list -r myRegistry
```

## Common Error Messages and Solutions

### Azure OpenAI

| Error | Possible Cause | Solution |
|-------|----------------|----------|
| `QuotaExceeded` | Token limit or rate limit reached | Increase capacity or implement rate limiting |
| `InvalidRequest` | Malformed prompt or parameters | Check prompt structure and parameter values |
| `AuthenticationError` | Invalid or expired key | Rotate keys or check managed identity |
| `ServiceUnavailable` | Service outage or maintenance | Implement retry logic with backoff |

### AI Foundry / Prompt Flow

| Error | Possible Cause | Solution |
|-------|----------------|----------|
| `ConnectionFailed` | Cannot connect to dependent service | Check connection configuration and service health |
| `PromptExecutionFailed` | Error in flow logic | Debug flow in AI Foundry with test cases |
| `ResourceNotFound` | Referenced resource doesn't exist | Verify resource IDs and availability |
| `AuthorizationFailed` | Insufficient permissions | Check role assignments for managed identity |

### ML Endpoint

| Error | Possible Cause | Solution |
|-------|----------------|----------|
| `DeploymentFailed` | Issues with container or configuration | Check deployment logs for specific errors |
| `ScalingError` | Cannot allocate requested resources | Verify quota and capacity in region |
| `InferenceError` | Runtime error in deployed model | Check logs and debug model logic |
| `TimeoutError` | Request processing exceeded time limit | Optimize model or increase timeout settings |

## Getting Support

If you're unable to resolve an issue using this guide:

1. **Check GitHub Issues**: Look for similar issues in the project repository
2. **Create a New Issue**: Provide detailed information about the problem
3. **Contact Azure Support**: For Azure service-specific issues
4. **Community Forums**: Ask in HashiCorp or Azure community forums

## Preventative Measures

1. **Implement Monitoring**: Set up alerts for key metrics and errors
2. **Regular Testing**: Test your deployment with integration tests
3. **CI/CD Pipeline**: Automate testing and deployment
4. **Documentation**: Keep deployment and configuration details updated
