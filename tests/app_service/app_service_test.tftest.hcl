# App Service Module Tests

# Mock provider for Azure
mock_provider "azurerm" {
  source = "registry.terraform.io/hashicorp/azurerm"
}

# Variables for the test runs
variables {
  name = "testapp"
  resource_group_name = "test-rg"
  location = "eastus"
  sku_name = "B1"
  tags = {
    Environment = "test"
    Project = "openai-chat"
    Provisioner = "Terraform"
  }
  key_vault_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.KeyVault/vaults/testvault"
  application_insights_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Insights/components/testinsights"
  endpoint_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.MachineLearningServices/workspaces/testworkspace/onlineEndpoints/testendpoint"
  endpoint_key = "test-endpoint-key"
  entra_client_id = "33333333-3333-3333-3333-333333333333"
  microsoft_provider_authentication_secret = "auth-secret"
}

# Test case: Create App Service with basic configuration
run "create_app_service_basic" {
  # Define mock resources and data sources
  mock_resource "azurerm_service_plan" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/serverfarms/testapp-plan"
      name = "testapp-plan"
      resource_group_name = "test-rg"
      location = "eastus"
      os_type = "Linux"
      sku_name = "B1"
      tags = {
        Environment = "test"
        Project = "openai-chat"
        Provisioner = "Terraform"
      }
    }
  }
  
  mock_resource "azurerm_linux_web_app" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/sites/testapp"
      name = "testapp"
      resource_group_name = "test-rg"
      location = "eastus"
      service_plan_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/serverfarms/testapp-plan"
      https_only = true
      identity = [
        {
          type = "SystemAssigned"
          principal_id = "44444444-4444-4444-4444-444444444444"
          tenant_id = "22222222-2222-2222-2222-222222222222"
        }
      ]
      site_config = [
        {
          always_on = true
          ftps_state = "Disabled"
          minimum_tls_version = "1.2"
          health_check_path = "/api/health"
          health_check_interval = 30
          application_stack = [
            {
              node_version = "18-lts"
            }
          ]
        }
      ]
      app_settings = {
        "WEBSITE_RUN_FROM_PACKAGE" = "1"
        "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "true"
        "APPINSIGHTS_INSTRUMENTATIONKEY" = "test-instrumentation-key"
        "ML_ENDPOINT_URL" = "@Microsoft.KeyVault(SecretUri=https://testvault.vault.azure.net/secrets/ml-endpoint-key)"
        "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET" = "auth-secret"
      }
      auth_settings = [
        {
          enabled = true
          default_provider = "AzureActiveDirectory"
          unauthenticated_client_action = "RedirectToLoginPage"
          active_directory = [
            {
              client_id = "33333333-3333-3333-3333-333333333333"
              client_secret_setting_name = "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"
            }
          ]
        }
      ]
      default_hostname = "testapp.azurewebsites.net"
      tags = {
        Environment = "test"
        Project = "openai-chat"
        Provisioner = "Terraform"
      }
    }
  }
  
  mock_resource "azurerm_key_vault_secret" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.KeyVault/vaults/testvault/secrets/ml-endpoint-key"
      name = "ml-endpoint-key"
      value = "test-endpoint-key"
      key_vault_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.KeyVault/vaults/testvault"
      version = "1"
      versionless_id = "https://testvault.vault.azure.net/secrets/ml-endpoint-key"
    }
  }
  
  mock_data "azurerm_application_insights" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Insights/components/testinsights"
      name = "testinsights"
      resource_group_name = "test-rg"
      instrumentation_key = "test-instrumentation-key"
      app_id = "test-app-id"
      connection_string = "test-connection-string"
      workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/testworkspace"
    }
  }
  
  mock_resource "azurerm_monitor_diagnostic_setting" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/sites/testapp/providers/Microsoft.Insights/diagnosticSettings/testapp-diag"
      name = "testapp-diag"
      target_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/sites/testapp"
      log_analytics_workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.OperationalInsights/workspaces/testworkspace"
      log = [
        {
          category = "AppServiceHTTPLogs"
          enabled = true
          retention_policy = [
            {
              enabled = true
              days = 30
            }
          ]
        },
        {
          category = "AppServiceConsoleLogs"
          enabled = true
          retention_policy = [
            {
              enabled = true
              days = 30
            }
          ]
        },
        {
          category = "AppServiceAppLogs"
          enabled = true
          retention_policy = [
            {
              enabled = true
              days = 30
            }
          ]
        },
        {
          category = "AppServicePlatformLogs"
          enabled = true
          retention_policy = [
            {
              enabled = true
              days = 30
            }
          ]
        }
      ]
      metric = [
        {
          category = "AllMetrics"
          enabled = true
          retention_policy = [
            {
              enabled = true
              days = 30
            }
          ]
        }
      ]
    }
  }

  # Reference the module
  module {
    source = "../../modules/app_service"
  }

  # Assert outputs
  assert {
    condition = output.default_site_hostname == "testapp.azurewebsites.net"
    error_message = "App Service hostname does not match expected value."
  }

  assert {
    condition = output.principal_id == "44444444-4444-4444-4444-444444444444"
    error_message = "App Service principal ID does not match expected value."
  }
}

# Test case: Create App Service with invalid SKU (should fail)
run "create_app_service_invalid_sku" {
  # Override the SKU name variable with an invalid value
  variables {
    sku_name = "invalid-sku"
  }

  # Reference the module
  module {
    source = "../../modules/app_service"
  }

  # Expect this to fail because of the "app_service_plan_sku" check block
  expect_failures = [
    is_match(check.app_service_plan_sku.error_message, "App Service Plan must use a valid SKU"),
  ]
}

# Test case: Verify HTTPS only setting
run "verify_https_only" {
  # Mock Linux web app with HTTPS only disabled
  mock_resource "azurerm_service_plan" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/serverfarms/testapp-plan"
      name = "testapp-plan"
      resource_group_name = "test-rg"
      location = "eastus"
      os_type = "Linux"
      sku_name = "B1"
    }
  }
  
  mock_resource "azurerm_linux_web_app" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/sites/testapp"
      name = "testapp"
      resource_group_name = "test-rg"
      location = "eastus"
      service_plan_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/serverfarms/testapp-plan"
      https_only = false  # HTTPS only disabled
      identity = [
        {
          type = "SystemAssigned"
          principal_id = "44444444-4444-4444-4444-444444444444"
          tenant_id = "22222222-2222-2222-2222-222222222222"
        }
      ]
      site_config = [
        {
          always_on = true
          ftps_state = "Disabled"
          minimum_tls_version = "1.2"
        }
      ]
    }
  }

  # Reference the module
  module {
    source = "../../modules/app_service"
  }

  # Expect this to fail because of the HTTPS only check
  expect_failures = [
    is_match(check.app_service_https_only.error_message, "App Service must have HTTPS only enabled."),
  ]
}

# Test case: Verify minimum TLS version
run "verify_tls_version" {
  # Mock Linux web app with TLS 1.0
  mock_resource "azurerm_service_plan" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/serverfarms/testapp-plan"
      name = "testapp-plan"
      resource_group_name = "test-rg"
      location = "eastus"
      os_type = "Linux"
      sku_name = "B1"
    }
  }
  
  mock_resource "azurerm_linux_web_app" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/sites/testapp"
      name = "testapp"
      resource_group_name = "test-rg"
      location = "eastus"
      service_plan_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Web/serverfarms/testapp-plan"
      https_only = true
      identity = [
        {
          type = "SystemAssigned"
          principal_id = "44444444-4444-4444-4444-444444444444"
          tenant_id = "22222222-2222-2222-2222-222222222222"
        }
      ]
      site_config = [
        {
          always_on = true
          ftps_state = "Disabled"
          minimum_tls_version = "1.0"  # TLS 1.0 is not allowed
        }
      ]
    }
  }

  # Reference the module
  module {
    source = "../../modules/app_service"
  }

  # Expect this to fail because of the TLS version check
  expect_failures = [
    is_match(check.app_service_tls_version.error_message, "App Service must use TLS 1.2 or higher."),
  ]
}
