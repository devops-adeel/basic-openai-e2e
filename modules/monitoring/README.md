# Azure Monitoring Module

This module provisions Azure monitoring resources including Application Insights and Log Analytics Workspace for the Azure OpenAI architecture.

## Features

- Creates a Log Analytics Workspace for centralized log collection
- Sets up Application Insights for application monitoring
- Optionally configures alerting for critical metrics
- Can create a pre-configured Azure Portal dashboard
- Configurable sampling rate and retention periods

## Usage

```hcl
module "monitoring" {
  source              = "./modules/monitoring"
  name                = "openai-dev-ai"
  resource_group_name = module.resource_group.name
  location            = var.location
  log_retention_days  = 30
  tags                = var.tags
}
```

## Usage with Alerting

```hcl
module "monitoring" {
  source                    = "./modules/monitoring"
  name                      = "openai-dev-ai"
  resource_group_name       = module.resource_group.name
  location                  = var.location
  log_retention_days        = 90
  enable_basic_alerts       = true
  alert_email_addresses     = ["admin@example.com", "devops@example.com"]
  server_exceptions_threshold = 3
  failed_requests_threshold = 5
  response_time_threshold   = 3000 # 3 seconds
  create_dashboard          = true
  tags                      = var.tags
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.7.0 |
| azurerm | ~> 3.85.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the Application Insights instance | `string` | n/a | yes |
| resource_group_name | Name of the resource group | `string` | n/a | yes |
| location | Azure region for the Application Insights | `string` | n/a | yes |
| tags | Tags to apply to the monitoring resources | `map(string)` | `{}` | no |
| log_analytics_sku | SKU of the Log Analytics Workspace | `string` | `"PerGB2018"` | no |
| log_retention_days | Retention days for the logs | `number` | `30` | no |
| sampling_percentage | Sampling percentage for Application Insights | `number` | `100` | no |
| enable_basic_alerts | Enable basic alerts for the application | `bool` | `false` | no |
| alert_email_addresses | Email addresses for alerts | `list(string)` | `[]` | no |
| server_exceptions_threshold | Threshold for server exceptions alert | `number` | `5` | no |
| failed_requests_threshold | Threshold for failed requests alert | `number` | `5` | no |
| response_time_threshold | Threshold for response time alert (in milliseconds) | `number` | `5000` | no |
| create_dashboard | Create a dashboard for the application | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| application_insights_id | ID of the Application Insights instance |
| application_insights_name | Name of the Application Insights instance |
| instrumentation_key | Instrumentation key of the Application Insights instance |
| app_id | App ID of the Application Insights instance |
| connection_string | Connection string of the Application Insights instance |
| log_analytics_workspace_id | ID of the Log Analytics Workspace |
| log_analytics_workspace_name | Name of the Log Analytics Workspace |
| log_analytics_workspace_primary_key | Primary key of the Log Analytics Workspace |
| log_analytics_workspace_secondary_key | Secondary key of the Log Analytics Workspace |
| dashboard_id | ID of the dashboard (if created) |

## Notes

- Application Insights is configured to be workspace-based for improved integration with Log Analytics
- Default retention period is set to 30 days, but can be increased for long-term analytics
- For high-traffic applications, consider adjusting the sampling percentage to control costs
- The dashboard provided is a basic template that can be customized further in the Azure Portal
