# Azure ML Module

# Azure ML Workspace
resource "azurerm_machine_learning_workspace" "this" {
  name                          = var.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  application_insights_id       = var.application_insights_id
  key_vault_id                  = var.key_vault_id  # This should be passed in from the root module
  storage_account_id            = var.storage_id
  container_registry_id         = var.container_registry_id
  tags                          = var.tags
  
  # Enable system-assigned managed identity
  identity {
    type = "SystemAssigned"
  }
  
  # Public network access is enabled for this basic architecture
  public_network_access_enabled = true
}

# Azure ML Managed Online Endpoint
resource "azurerm_machine_learning_online_endpoint" "this" {
  name                         = var.endpoint_name
  location                      = var.location
  workspace_id                  = azurerm_machine_learning_workspace.this.id
  description                   = "Managed online endpoint for chat application"
  tags                          = var.tags
  
  # Enable system-assigned managed identity
  identity {
    type = "SystemAssigned"
  }
  
  # Auth mode set to key for this basic architecture
  auth_mode = "Key"
  
  # Public network access is enabled for this basic architecture
  public_network_access_enabled = true
}

# Azure ML Deployment
resource "azurerm_machine_learning_online_deployment" "this" {
  name                         = var.deployment_name
  endpoint_id                  = azurerm_machine_learning_online_endpoint.this.id
  description                  = "Deployment for prompt flow"
  tags                         = var.tags
  
  # Deployment model is set to serverless for this basic architecture
  model {
    name    = "chat-model"
    version = "1"
    path    = "azureml://MODEL-PATH"  # This would be the actual path to your model
  }
  
  # Configure the compute instance
  compute {
    instance_type = var.instance_type
    instance_count = var.instance_count
    scale_settings {
      scale_type = "Manual"  # No autoscaling for this basic architecture
    }
  }
  
  # Add environment variables
  environment_variables = {
    "OPENAI_API_TYPE"    = "azure"
    "DEPLOYMENT_TYPE"    = "PromptFlow"
    "PROJECT_ID"         = var.ai_foundry_project_id
  }
}

# Role assignments for the managed identity of the online endpoint

# Storage - allow the endpoint to access storage
resource "azurerm_role_assignment" "endpoint_storage_reader" {
  scope                = var.storage_id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_machine_learning_online_endpoint.this.identity[0].principal_id
}

# Container Registry - allow the endpoint to pull images
resource "azurerm_role_assignment" "endpoint_acr_pull" {
  scope                = var.container_registry_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_machine_learning_online_endpoint.this.identity[0].principal_id
}

# AI Foundry Hub - allow the endpoint to read configurations
resource "azurerm_role_assignment" "endpoint_ai_foundry_hub_reader" {
  scope                = var.ai_foundry_hub_id
  role_definition_name = "Reader"
  principal_id         = azurerm_machine_learning_online_endpoint.this.identity[0].principal_id
}

# AI Foundry Project - allow the endpoint to write metrics
resource "azurerm_role_assignment" "endpoint_ai_foundry_project_contributor" {
  scope                = var.ai_foundry_project_id
  role_definition_name = "Contributor"
  principal_id         = azurerm_machine_learning_online_endpoint.this.identity[0].principal_id
}

# Validate Azure ML configurations
check "azure_ml_workspace_naming_convention" {
  assert {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]$", var.name))
    error_message = "Azure ML workspace name must use only letters, numbers, and hyphens. It must start and end with a letter or number and be between 3 and 63 characters."
  }
}

check "azure_ml_endpoint_naming_convention" {
  assert {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{1,50}$", var.endpoint_name))
    error_message = "Azure ML endpoint name must use only letters, numbers, and hyphens. It must start with a letter or number and be between 2 and 52 characters."
  }
}

check "azure_ml_deployment_naming_convention" {
  assert {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{1,50}$", var.deployment_name))
    error_message = "Azure ML deployment name must use only letters, numbers, and hyphens. It must start with a letter or number and be between 2 and 52 characters."
  }
}

check "azure_ml_workspace_managed_identity" {
  assert {
    condition     = azurerm_machine_learning_workspace.this.identity[0].type == "SystemAssigned"
    error_message = "Azure ML workspace must have a system-assigned managed identity."
  }
}

check "azure_ml_endpoint_managed_identity" {
  assert {
    condition     = azurerm_machine_learning_online_endpoint.this.identity[0].type == "SystemAssigned"
    error_message = "Azure ML endpoint must have a system-assigned managed identity."
  }
}

check "azure_ml_instance_type" {
  assert {
    condition     = startswith(var.instance_type, "Standard_")
    error_message = "Azure ML instance type must be a valid Standard SKU."
  }
}
