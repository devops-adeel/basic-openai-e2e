# App Service Module

# App Service Plan
resource "azurerm_service_plan" "this" {
  name                = "${var.name}-plan"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = var.sku_name
  tags                = var.tags
}

# Validate App Service Plan configuration
check "app_service_plan_sku" {
  assert {
    condition     = startswith(var.sku_name, "B") || startswith(var.sku_name, "S") || startswith(var.sku_name, "P") || startswith(var.sku_name, "I")
    error_message = "App Service Plan must use a valid SKU (Basic, Standard, Premium, or Isolated)."
  }
}

# App Service
resource "azurerm_linux_web_app" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.this.id
  tags                = var.tags

  # Enable system-assigned managed identity
  identity {
    type = "SystemAssigned"
  }

  # Configure logging
  logs {
    application_logs {
      file_system_level = "Information"
    }

    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 35
      }
    }

    detailed_error_messages = true
    failed_request_tracing  = true
  }

  # Configure the app settings
  app_settings = {
    # Application settings
    "WEBSITE_RUN_FROM_PACKAGE"               = "1"
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE"    = "true"
    "APPINSIGHTS_INSTRUMENTATIONKEY"         = var.application_insights_id != null ? data.azurerm_application_insights.this[0].instrumentation_key : null

    # Configure the Machine Learning endpoint
    "ML_ENDPOINT_URL"                        = var.endpoint_id != null ? "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.endpoint_key[0].versionless_id})" : null

    # Enable Easy Auth (Microsoft Entra ID authentication)
    "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET" = var.microsoft_provider_authentication_secret
  }

  # Configure authentication (Easy Auth)
  auth_settings {
    enabled                       = true
    default_provider              = "AzureActiveDirectory"
    unauthenticated_client_action = "RedirectToLoginPage"

    active_directory {
      client_id                  = var.entra_client_id
      client_secret_setting_name = "MICROSOFT_PROVIDER_AUTHENTICATION_SECRET"
    }
  }

  # Configure application stack
  site_config {
    application_stack {
      node_version = "18-lts"
    }

    always_on             = true
    ftps_state            = "Disabled"
    minimum_tls_version   = "1.2"
    health_check_path     = "/api/health"
    health_check_interval = 30
  }
}

# Validate App Service configuration
check "app_service_https_only" {
  assert {
    condition     = azurerm_linux_web_app.this.https_only == true
    error_message = "App Service must have HTTPS only enabled."
  }
}

check "app_service_tls_version" {
  assert {
    condition     = azurerm_linux_web_app.this.site_config[0].minimum_tls_version == "1.2"
    error_message = "App Service must use TLS 1.2 or higher."
  }
}

check "app_service_ftps_state" {
  assert {
    condition     = azurerm_linux_web_app.this.site_config[0].ftps_state == "Disabled"
    error_message = "FTPS must be disabled for App Service."
  }
}

check "app_service_managed_identity" {
  assert {
    condition     = azurerm_linux_web_app.this.identity[0].type == "SystemAssigned"
    error_message = "App Service must use a system-assigned managed identity."
  }

}

# Store the endpoint key in Key Vault if endpoint ID is provided
resource "azurerm_key_vault_secret" "endpoint_key" {
  count        = var.endpoint_id != null && var.endpoint_key != null ? 1 : 0
  name         = "ml-endpoint-key"
  value        = var.endpoint_key
  key_vault_id = var.key_vault_id
}

# Get Application Insights details if provided
data "azurerm_application_insights" "this" {
  count               = var.application_insights_id != null ? 1 : 0
  resource_group_name = var.resource_group_name
  name                = element(split("/", var.application_insights_id), length(split("/", var.application_insights_id)) - 1)
}

# Configure App Service Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "app_service" {
  count                   = var.application_insights_id != null ? 1 : 0
  name                    = "${var.name}-diag"
  target_resource_id      = azurerm_linux_web_app.this.id
  log_analytics_workspace_id = data.azurerm_application_insights.this[0].workspace_id

  log {
    category = "AppServiceHTTPLogs"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  log {
    category = "AppServiceConsoleLogs"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  log {
    category = "AppServiceAppLogs"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  log {
    category = "AppServicePlatformLogs"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 30
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = true

    retention_policy {
      enabled = true
      days    = 30
    }
  }
}
