# Monitoring Module Tests

# Mock provider for Azure
mock_provider "azurerm" {
  source = "registry.terraform.io/hashicorp/azurerm"
}

# Variables for the test runs
variables {
  name                = "test-appinsights"
  resource_group_name = "test-rg"
  location            = "eastus"
  tags                = {
    Environment = "test"
    Project     = "openai-chat"
    Provisioner = "Terraform"
  }
  log_analytics_sku   = "PerGB2018"
  log_retention_days  = 30
  sampling_percentage = 100
  enable_basic_alerts = false
  create_dashboard    = false
}

# Test case: Create monitoring resources with basic configuration
run "create_monitoring_basic" {
  # Define mock resources
  mock_resource "azurerm_log_analytics_workspace" {
    defaults = {
      id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/test-appinsights-law"
      name                = "test-appinsights-law"
      resource_group_name = "test-rg"
      location            = "eastus"
      sku                 = "PerGB2018"
      retention_in_days   = 30
      primary_shared_key   = "test-primary-key"
      secondary_shared_key = "test-secondary-key"
      tags                = {
        Environment = "test"
        Project     = "openai-chat"
        Provisioner = "Terraform"
      }
    }
  }
  
  mock_resource "azurerm_application_insights" {
    defaults = {
      id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Insights/components/test-appinsights"
      name                = "test-appinsights"
      resource_group_name = "test-rg"
      location            = "eastus"
      application_type    = "web"
      retention_in_days   = 30
      workspace_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/test-appinsights-law"
      instrumentation_key = "test-instrumentation-key"
      connection_string   = "InstrumentationKey=test-instrumentation-key;IngestionEndpoint=https://eastus-0.in.applicationinsights.azure.com/;LiveEndpoint=https://eastus.livediagnostics.monitor.azure.com/"
      app_id              = "test-app-id"
      sampling_percentage = 100
      tags                = {
        Environment = "test"
        Project     = "openai-chat"
        Provisioner = "Terraform"
      }
    }
  }

  # Reference the module
  module {
    source = "../../modules/monitoring"
  }

  # Assert outputs
  assert {
    condition     = output.application_insights_name == "test-appinsights"
    error_message = "Application Insights name does not match expected value."
  }

  assert {
    condition     = output.instrumentation_key == "test-instrumentation-key"
    error_message = "Application Insights instrumentation key does not match expected value."
  }

  assert {
    condition     = output.log_analytics_workspace_name == "test-appinsights-law"
    error_message = "Log Analytics Workspace name does not match expected value."
  }

  assert {
    condition     = output.log_analytics_workspace_primary_key == "test-primary-key"
    error_message = "Log Analytics Workspace primary key does not match expected value."
  }

  assert {
    condition     = output.dashboard_id == null
    error_message = "Dashboard ID should be null."
  }
}

# Test case: Create monitoring resources with alerts and dashboard
run "create_monitoring_with_alerts" {
  # Override variables
  variables {
    enable_basic_alerts       = true
    alert_email_addresses     = ["admin@example.com"]
    server_exceptions_threshold = 3
    failed_requests_threshold = 5
    response_time_threshold   = 3000
    create_dashboard          = true
  }
  
  # Define mock resources
  mock_resource "azurerm_log_analytics_workspace" {
    defaults = {
      id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/test-appinsights-law"
      name                = "test-appinsights-law"
      resource_group_name = "test-rg"
      location            = "eastus"
      sku                 = "PerGB2018"
      retention_in_days   = 30
    }
  }
  
  mock_resource "azurerm_application_insights" {
    defaults = {
      id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Insights/components/test-appinsights"
      name                = "test-appinsights"
      resource_group_name = "test-rg"
      location            = "eastus"
      application_type    = "web"
      retention_in_days   = 30
      workspace_id        = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/test-appinsights-law"
      instrumentation_key = "test-instrumentation-key"
      app_id              = "test-app-id"
    }
  }
  
  mock_resource "azurerm_monitor_action_group" {
    defaults = {
      id                    = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Insights/actionGroups/test-appinsights-critical-alerts"
      name                  = "test-appinsights-critical-alerts"
      resource_group_name   = "test-rg"
      short_name            = "Critical"
      email_receiver = [
        {
          name                    = "Email-0"
          email_address           = "admin@example.com"
          use_common_alert_schema = true
        }
      ]
    }
  }
  
  mock_resource "azurerm_monitor_metric_alert" {
    defaults = {
      id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Insights/metricAlerts/test-appinsights-server-exceptions"
      name                = "test-appinsights-server-exceptions"
      resource_group_name = "test-rg"
      scopes              = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Insights/components/test-appinsights"]
      description         = "Alert when server exceptions exceed threshold"
      severity            = 1
      frequency           = "PT5M"
      window_size         = "PT15M"
      criteria = [
        {
          metric_namespace = "microsoft.insights/components"
          metric_name      = "exceptions/server"
          aggregation      = "Count"
          operator         = "GreaterThan"
          threshold        = 3
        }
      ]
      action = [
        {
          action_group_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Insights/actionGroups/test-appinsights-critical-alerts"
        }
      ]
    }
  }
  
  mock_resource "azurerm_portal_dashboard" {
    defaults = {
      id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Portal/dashboards/test-appinsights-dashboard"
      name                = "test-appinsights-dashboard"
      resource_group_name = "test-rg"
      location            = "eastus"
      dashboard_properties = "{ \"lenses\": { \"0\": { \"order\": 0, \"parts\": { \"0\": {} } } } }"
    }
  }

  # Reference the module
  module {
    source = "../../modules/monitoring"
  }

  # Assert outputs
  assert {
    condition     = output.dashboard_id != null
    error_message = "Dashboard ID should not be null."
  }
}

# Test case: Create monitoring with invalid retention period (should fail)
run "create_monitoring_invalid_retention" {
  # Override the retention days variable with an invalid value
  variables {
    log_retention_days = 20 # Less than required minimum of 30
  }

  # Reference the module
  module {
    source = "../../modules/monitoring"
  }

  # Expect this to fail because of the retention days validation
  expect_failures = [
    is_match(validation.var.log_retention_days.error_message, "Log retention days must be between 30 and 730."),
  ]
}

# Test case: Create monitoring with invalid email addresses (should fail)
run "create_monitoring_invalid_email" {
  # Override the email addresses variable with an invalid value
  variables {
    enable_basic_alerts   = true
    alert_email_addresses = ["invalid-email"] # Not a valid email format
  }

  # Reference the module
  module {
    source = "../../modules/monitoring"
  }

  # Expect this to fail because of the email validation
  expect_failures = [
    is_match(validation.var.alert_email_addresses.error_message, "All email addresses must be valid."),
  ]
}

# Test case: Verify log analytics workspace mode
run "verify_workspace_mode" {
  # Mock Application Insights without workspace mode
  mock_resource "azurerm_log_analytics_workspace" {
    defaults = {
      id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/test-appinsights-law"
      name                = "test-appinsights-law"
      resource_group_name = "test-rg"
      location            = "eastus"
      sku                 = "PerGB2018"
      retention_in_days   = 30
    }
  }
  
  mock_resource "azurerm_application_insights" {
    defaults = {
      id                  = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Insights/components/test-appinsights"
      name                = "test-appinsights"
      resource_group_name = "test-rg"
      location            = "eastus"
      application_type    = "web"
      retention_in_days   = 30
      workspace_id        = null # No workspace ID
      instrumentation_key = "test-instrumentation-key"
    }
  }

  # Reference the module
  module {
    source = "../../modules/monitoring"
  }

  # Expect this to fail because of the workspace mode check
  expect_failures = [
    is_match(check.app_insights_workspace_mode.error_message, "Application Insights must be connected to a Log Analytics workspace."),
  ]
}
