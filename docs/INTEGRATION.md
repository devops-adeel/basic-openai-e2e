# Integration Guide

This document provides detailed guidance on integrating various components of the Azure OpenAI Chat Reference Architecture.

## Architecture Flow

The Azure OpenAI Chat Reference Architecture implements the following data flow:

1. **User requests** are sent to **App Service** (chat UI)
2. App Service authenticates users with **Easy Auth**
3. App Service calls the **ML Managed Online Endpoint**
4. ML Endpoint invokes the deployed **Prompt Flow**
5. Prompt Flow extracts intent and queries **AI Search**
6. Prompt Flow sends grounding data to **Azure OpenAI Service**
7. OpenAI generates a response which flows back to the user

## Integration Points

### App Service to ML Endpoint Integration

The App Service accesses the ML Endpoint through a key stored in Key Vault:

```javascript
// Sample JavaScript in the chat application
async function queryEndpoint(prompt) {
  const response = await fetch(process.env.ML_ENDPOINT_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${apiKey}`
    },
    body: JSON.stringify({
      prompt: prompt,
      history: conversationHistory
    })
  });
  return await response.json();
}
```

The Terraform configures this integration through:

```hcl
# App Service configuration
app_settings = {
  "ML_ENDPOINT_URL" = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.endpoint_key[0].versionless_id})"
}
```

### AI Foundry to ML Endpoint Integration

AI Foundry deploys prompt flows to the ML Endpoint:

1. ML Endpoint uses a managed identity to access resources
2. The identity has appropriate roles on the AI Foundry Project
3. The identity also has ACR Pull permissions to access container images

```hcl
# Role assignments for ML Endpoint identity
resource "azurerm_role_assignment" "endpoint_ai_foundry_project_contributor" {
  scope                = var.ai_foundry_project_id
  role_definition_name = "Contributor"
  principal_id         = azurerm_machine_learning_online_endpoint.this.identity[0].principal_id
}
```

### Prompt Flow Integration

Prompt Flow connects to Azure OpenAI and AI Search through connections defined in AI Foundry:

```hcl
# OpenAI Connection
resource "azurerm_machine_learning_connection" "openai" {
  name      = "openai-connection"
  hub_id    = azurerm_machine_learning_hub.this.id
  target    = "AzureOpenAI"
  category  = "AzureResource"
  
  credentials {
    identity {
      type = "SystemAssigned"
    }
  }
  
  resource_id_parameter_name = "resource_id"
  parameters = {
    resource_id = var.openai_id
  }
}
```

## Managed Identities

System-assigned managed identities are used for authentication between services:

| Service | Identity Used For |
|---------|------------------|
| App Service | Accessing Key Vault |
| AI Foundry Hub | Accessing Storage, ACR, Key Vault, OpenAI, Search |
| AI Foundry Project | Accessing Storage, ACR, Key Vault, App Insights |
| ML Endpoint | Accessing Storage, ACR, AI Foundry |

## Storage Configuration

Storage is configured with three containers:

1. `prompt-flows` - Stores prompt flow code
2. `connections` - Stores connection configurations
3. `models` - Stores ML models

## Integrating Custom Chat UI

To integrate a custom chat UI:

1. Deploy a web application to App Service
2. Configure the application to use the ML Endpoint
3. Add authentication using Easy Auth
4. Use Application Insights for monitoring

Example App Service configuration in `main.tf`:

```hcl
module "app_service" {
  source              = "./modules/app_service"
  name                = "${var.prefix}-${var.environment}-app"
  resource_group_name = module.resource_group.name
  location            = var.location
  key_vault_id        = module.key_vault.id
  application_insights_id = module.monitoring.application_insights_id
  endpoint_id         = module.azure_ml.endpoint_id
  endpoint_key        = module.azure_ml.endpoint_key
}
```

## Logging and Monitoring

Logging is configured for all components using Application Insights:

1. App Service logs requests, responses, and application logs
2. ML Endpoint logs inference requests and performance metrics
3. OpenAI telemetry flows to Azure Monitor

Configure Application Insights in your application with:

```javascript
const appInsights = require('applicationinsights');
appInsights.setup(process.env.APPINSIGHTS_INSTRUMENTATIONKEY)
  .setAutoDependencyCorrelation(true)
  .setAutoCollectRequests(true)
  .setAutoCollectPerformance(true)
  .setAutoCollectExceptions(true)
  .setAutoCollectDependencies(true)
  .setAutoCollectConsole(true)
  .setUseDiskRetryCaching(true)
  .start();
```

## Troubleshooting

### Common Issues

1. **Authentication Errors**: Check the system-assigned managed identity role assignments
2. **Connection Failures**: Verify network connectivity and public access settings
3. **ML Endpoint Errors**: Review prompt flow deployment logs
4. **OpenAI Rate Limiting**: Adjust capacity or implement throttling in your application

### Viewing Logs

Access logs through:

1. Azure Portal - Application Insights
2. Log Analytics Queries
3. Diagnostic settings for each service

Example Log Analytics query to view ML Endpoint errors:

```
AzureDiagnostics
| where ResourceProvider == "MICROSOFT.MACHINELEARNINGSERVICES" 
| where Category == "AmlOnlineEndpointConsoleLog"
| where StatusCode != 200
| project TimeGenerated, OperationName, StatusCode, Message
```

## Security Considerations

1. **Managed Identities**: Used for secure service-to-service authentication
2. **Key Vault**: Stores secrets like API keys
3. **Easy Auth**: Provides authentication for the web application
4. **Content Filtering**: Applied to OpenAI to prevent misuse

## Further Resources

- [Azure OpenAI Documentation](https://learn.microsoft.com/en-us/azure/ai-services/openai/)
- [AI Foundry Documentation](https://learn.microsoft.com/en-us/azure/machine-learning/prompt-flow/overview-what-is-prompt-flow)
- [Azure ML Documentation](https://learn.microsoft.com/en-us/azure/machine-learning/)
- [Application Insights Documentation](https://learn.microsoft.com/en-us/azure/azure-monitor/app/app-insights-overview)
