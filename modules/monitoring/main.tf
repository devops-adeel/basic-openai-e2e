# Monitoring Module

# Create Log Analytics Workspace
resource "azurerm_log_analytics_workspace" "this" {
  name                = "${var.name}-law"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_retention_days
  tags                = var.tags
}

# Create Application Insights
resource "azurerm_application_insights" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  workspace_id        = azurerm_log_analytics_workspace.this.id
  application_type    = "web"
  retention_in_days   = var.log_retention_days
  tags                = var.tags
  
  # Sampling configuration for high-volume applications
  sampling_percentage = var.sampling_percentage
}

# Create an Action Group for alerts (optional)
resource "azurerm_monitor_action_group" "critical" {
  count               = length(var.alert_email_addresses) > 0 ? 1 : 0
  name                = "${var.name}-critical-alerts"
  resource_group_name = var.resource_group_name
  short_name          = "Critical"
  
  dynamic "email_receiver" {
    for_each = var.alert_email_addresses
    content {
      name                    = "Email-${email_receiver.key}"
      email_address           = email_receiver.value
      use_common_alert_schema = true
    }
  }
}

# Set up basic alerts for the application
resource "azurerm_monitor_metric_alert" "server_exceptions" {
  count               = var.enable_basic_alerts ? 1 : 0
  name                = "${var.name}-server-exceptions"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_insights.this.id]
  description         = "Alert when server exceptions exceed threshold"
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"
  
  criteria {
    metric_namespace = "microsoft.insights/components"
    metric_name      = "exceptions/server"
    aggregation      = "Count"
    operator         = "GreaterThan"
    threshold        = var.server_exceptions_threshold
  }
  
  action {
    action_group_id = length(var.alert_email_addresses) > 0 ? azurerm_monitor_action_group.critical[0].id : null
  }
}

resource "azurerm_monitor_metric_alert" "failed_requests" {
  count               = var.enable_basic_alerts ? 1 : 0
  name                = "${var.name}-failed-requests"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_insights.this.id]
  description         = "Alert when failed requests exceed threshold"
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"
  
  criteria {
    metric_namespace = "microsoft.insights/components"
    metric_name      = "requests/failed"
    aggregation      = "Count"
    operator         = "GreaterThan"
    threshold        = var.failed_requests_threshold
  }
  
  action {
    action_group_id = length(var.alert_email_addresses) > 0 ? azurerm_monitor_action_group.critical[0].id : null
  }
}

resource "azurerm_monitor_metric_alert" "response_time" {
  count               = var.enable_basic_alerts ? 1 : 0
  name                = "${var.name}-response-time"
  resource_group_name = var.resource_group_name
  scopes              = [azurerm_application_insights.this.id]
  description         = "Alert when response time exceeds threshold"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  
  criteria {
    metric_namespace = "microsoft.insights/components"
    metric_name      = "requests/duration"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = var.response_time_threshold
  }
  
  action {
    action_group_id = length(var.alert_email_addresses) > 0 ? azurerm_monitor_action_group.critical[0].id : null
  }
}

# Create dashboard for the application (optional)
resource "azurerm_portal_dashboard" "this" {
  count               = var.create_dashboard ? 1 : 0
  name                = "${var.name}-dashboard"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
  
  dashboard_properties = <<DASHBOARD
{
  "lenses": {
    "0": {
      "order": 0,
      "parts": {
        "0": {
          "position": {
            "x": 0,
            "y": 0,
            "colSpan": 6,
            "rowSpan": 4
          },
          "metadata": {
            "inputs": [
              {
                "name": "resourceTypeMode",
                "isOptional": true,
                "value": "components"
              },
              {
                "name": "ComponentId",
                "isOptional": true,
                "value": "${azurerm_application_insights.this.id}"
              },
              {
                "name": "TimeContext",
                "isOptional": true,
                "value": {
                  "durationMs": 86400000,
                  "endTime": null,
                  "createdTime": "2023-01-01T00:00:00.000Z",
                  "isInitialTime": true,
                  "grain": 1,
                  "useDashboardTimeRange": false
                }
              },
              {
                "name": "Version",
                "isOptional": true,
                "value": "1.0"
              }
            ],
            "type": "Extension/AppInsightsExtension/PartType/AppMapGalPt",
            "settings": {
              "advanced": {
                "showTraceInformationByCodes": true
              }
            },
            "asset": {
              "idInputName": "ComponentId",
              "type": "ApplicationInsights"
            }
          }
        },
        "1": {
          "position": {
            "x": 6,
            "y": 0,
            "colSpan": 6,
            "rowSpan": 4
          },
          "metadata": {
            "inputs": [
              {
                "name": "ComponentId",
                "value": {
                  "SubscriptionId": "${azurerm_application_insights.this.id}",
                  "ResourceGroup": "${var.resource_group_name}",
                  "Name": "${var.name}",
                  "ResourceId": "${azurerm_application_insights.this.id}"
                }
              },
              {
                "name": "TimeContext",
                "value": {
                  "durationMs": 86400000,
                  "createdTime": "2023-01-01T00:00:00.000Z",
                  "isInitialTime": true,
                  "grain": 1,
                  "useDashboardTimeRange": false
                }
              },
              {
                "name": "Version",
                "value": "1.0"
              }
            ],
            "type": "Extension/AppInsightsExtension/PartType/FailuresCurPt",
            "settings": {
              "advanced": {
                "PartTitle": "Failures"
              }
            },
            "asset": {
              "idInputName": "ComponentId",
              "type": "ApplicationInsights"
            }
          }
        },
        "2": {
          "position": {
            "x": 0,
            "y": 4,
            "colSpan": 6,
            "rowSpan": 4
          },
          "metadata": {
            "inputs": [
              {
                "name": "ComponentId",
                "value": {
                  "SubscriptionId": "${azurerm_application_insights.this.id}",
                  "ResourceGroup": "${var.resource_group_name}",
                  "Name": "${var.name}",
                  "ResourceId": "${azurerm_application_insights.this.id}"
                }
              },
              {
                "name": "TimeContext",
                "value": {
                  "durationMs": 86400000,
                  "createdTime": "2023-01-01T00:00:00.000Z",
                  "isInitialTime": true,
                  "grain": 1,
                  "useDashboardTimeRange": false
                }
              },
              {
                "name": "Version",
                "value": "1.0"
              }
            ],
            "type": "Extension/AppInsightsExtension/PartType/PerformanceCurPt",
            "settings": {
              "advanced": {
                "PartTitle": "Performance"
              }
            },
            "asset": {
              "idInputName": "ComponentId",
              "type": "ApplicationInsights"
            }
          }
        },
        "3": {
          "position": {
            "x": 6,
            "y": 4,
            "colSpan": 6,
            "rowSpan": 4
          },
          "metadata": {
            "inputs": [
              {
                "name": "ComponentId",
                "value": {
                  "SubscriptionId": "${azurerm_application_insights.this.id}",
                  "ResourceGroup": "${var.resource_group_name}",
                  "Name": "${var.name}",
                  "ResourceId": "${azurerm_application_insights.this.id}"
                }
              },
              {
                "name": "TimeContext",
                "value": {
                  "durationMs": 86400000,
                  "createdTime": "2023-01-01T00:00:00.000Z",
                  "isInitialTime": true,
                  "grain": 1,
                  "useDashboardTimeRange": false
                }
              },
              {
                "name": "Dimensions",
                "value": {
                  "xAxis": {
                    "name": "request/duration",
                    "type": "measure"
                  },
                  "yAxis": {
                    "name": "request/count",
                    "type": "measure"
                  },
                  "splitBy": [
                    {
                      "name": "request/name",
                      "type": "dimension"
                    },
                    {
                      "name": "request/resultCode",
                      "type": "dimension"
                    }
                  ],
                  "aggregation": "Sum"
                }
              },
              {
                "name": "Version",
                "value": "1.0"
              }
            ],
            "type": "Extension/AppInsightsExtension/PartType/ScatterChartPt",
            "settings": {
              "advanced": {
                "PartTitle": "Server Requests",
                "LegendOptions": {
                  "isEnabled": true,
                  "position": "Bottom"
                }
              }
            },
            "asset": {
              "idInputName": "ComponentId",
              "type": "ApplicationInsights"
            }
          }
        }
      }
    }
  },
  "metadata": {
    "model": {
      "timeRange": {
        "value": {
          "relative": {
            "duration": 24,
            "timeUnit": 1
          }
        },
        "type": "MsPortalFx.Composition.Configuration.ValueTypes.TimeRange"
      },
      "filterLocale": {
        "value": "en-us"
      },
      "filters": {
        "value": {
          "MsPortalFx_TimeRange": {
            "model": {
              "format": "utc",
              "granularity": "auto",
              "relative": "24h"
            },
            "displayCache": {
              "name": "UTC Time",
              "value": "Past 24 hours"
            }
          }
        }
      }
    }
  }
}
DASHBOARD

  lifecycle {
    ignore_changes = [
      dashboard_properties
    ]
  }
}

# Check log analytics workspace configuration
check "log_analytics_retention" {
  assert {
    condition     = azurerm_log_analytics_workspace.this.retention_in_days >= 30
    error_message = "Log Analytics workspace retention must be at least 30 days."
  }
}

check "app_insights_workspace_mode" {
  assert {
    condition     = azurerm_application_insights.this.workspace_id != null
    error_message = "Application Insights must be connected to a Log Analytics workspace."
  }
}
