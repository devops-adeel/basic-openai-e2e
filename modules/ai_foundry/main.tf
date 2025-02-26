# AI Foundry Module

# AI Foundry Hub
resource "azurerm_machine_learning_hub" "this" {
  name                = var.hub_name
  location            = var.location
  resource_group_name = var.resource_group_name
  
  # Enable system-assigned managed identity
  identity {
    type = "SystemAssigned"
  }
  
  tags = var.tags
}

# Validate AI Foundry Hub configuration
check "ai_foundry_hub_naming_convention" {
  assert {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]$", var.hub_name))
    error_message = "AI Foundry Hub name must use only letters, numbers, and hyphens. It must start and end with a letter or number and be between 3 and 63 characters."
  }
}

check "ai_foundry_hub_managed_identity" {
  assert {
    condition     = length(azurerm_machine_learning_hub.this.identity) > 0 && azurerm_machine_learning_hub.this.identity[0].type == "SystemAssigned"
    error_message = "AI Foundry Hub must have a system-assigned managed identity."
  }
}

# AI Foundry Project
resource "azurerm_machine_learning_project" "this" {
  name          = var.project_name
  hub_id        = azurerm_machine_learning_hub.this.id
  display_name  = var.project_display_name != null ? var.project_display_name : var.project_name
  description   = var.project_description
  
  # Enable system-assigned managed identity
  identity {
    type = "SystemAssigned"
  }
  
  tags = var.tags
}

# Validate AI Foundry Project configuration
check "ai_foundry_project_naming_convention" {
  assert {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{1,61}[a-zA-Z0-9]$", var.project_name))
    error_message = "AI Foundry Project name must use only letters, numbers, and hyphens. It must start and end with a letter or number and be between 3 and 63 characters."
  }
}

check "ai_foundry_project_managed_identity" {
  assert {
    condition     = length(azurerm_machine_learning_project.this.identity) > 0 && azurerm_machine_learning_project.this.identity[0].type == "SystemAssigned"
    error_message = "AI Foundry Project must have a system-assigned managed identity."
  }
}

check "ai_foundry_project_description" {
  assert {
    condition     = var.project_description != ""
    error_message = "AI Foundry Project must have a description."
  }
}

# Create role assignments for the AI Foundry Hub managed identity

# Storage Account
resource "azurerm_role_assignment" "hub_storage_contributor" {
  scope                = var.storage_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_machine_learning_hub.this.identity[0].principal_id
}

resource "azurerm_role_assignment" "hub_storage_privileged" {
  scope                = var.storage_id
  role_definition_name = "Storage File Data Privileged Contributor"
  principal_id         = azurerm_machine_learning_hub.this.identity[0].principal_id
}

# Container Registry
resource "azurerm_role_assignment" "hub_acr_pull" {
  scope                = var.container_registry_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_machine_learning_hub.this.identity[0].principal_id
}

resource "azurerm_role_assignment" "hub_acr_push" {
  scope                = var.container_registry_id
  role_definition_name = "AcrPush"
  principal_id         = azurerm_machine_learning_hub.this.identity[0].principal_id
}

# Key Vault
resource "azurerm_role_assignment" "hub_key_vault_secrets_user" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_machine_learning_hub.this.identity[0].principal_id
}

# Create role assignments for the AI Foundry Project managed identity

# Storage Account
resource "azurerm_role_assignment" "project_storage_contributor" {
  scope                = var.storage_id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_machine_learning_project.this.identity[0].principal_id
}

resource "azurerm_role_assignment" "project_storage_privileged" {
  scope                = var.storage_id
  role_definition_name = "Storage File Data Privileged Contributor"
  principal_id         = azurerm_machine_learning_project.this.identity[0].principal_id
}

# Container Registry
resource "azurerm_role_assignment" "project_acr_pull" {
  scope                = var.container_registry_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_machine_learning_project.this.identity[0].principal_id
}

resource "azurerm_role_assignment" "project_acr_push" {
  scope                = var.container_registry_id
  role_definition_name = "AcrPush"
  principal_id         = azurerm_machine_learning_project.this.identity[0].principal_id
}

# Key Vault
resource "azurerm_role_assignment" "project_key_vault_secrets_user" {
  scope                = var.key_vault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_machine_learning_project.this.identity[0].principal_id
}

# Application Insights
resource "azurerm_role_assignment" "project_app_insights_contributor" {
  count                = var.application_insights_id != null ? 1 : 0
  scope                = var.application_insights_id
  role_definition_name = "Application Insights Component Contributor"
  principal_id         = azurerm_machine_learning_project.this.identity[0].principal_id
}

# Create Hub Connections

# OpenAI Connection
resource "azurerm_machine_learning_connection" "openai" {
  count        = var.openai_id != null ? 1 : 0
  name         = "openai-connection"
  hub_id       = azurerm_machine_learning_hub.this.id
  target       = "AzureOpenAI"
  category     = "AzureResource"
  
  credentials {
    identity {
      type = "SystemAssigned"
    }
  }
  
  # Notice that we are using a more specific resource path pattern for Azure OpenAI
  resource_id_parameter_name = "resource_id"
  parameters = {
    resource_id = var.openai_id
  }
}

# AI Search Connection
resource "azurerm_machine_learning_connection" "search" {
  count        = var.search_id != null ? 1 : 0
  name         = "search-connection"
  hub_id       = azurerm_machine_learning_hub.this.id
  target       = "AzureSearch"
  category     = "AzureResource"
  
  credentials {
    identity {
      type = "SystemAssigned"
    }
  }
  
  resource_id_parameter_name = "resource_id"
  parameters = {
    resource_id = var.search_id
  }
}

# Create a sample prompt flow
# Note: In a real implementation, you would likely want to use a more dynamic approach
# to create and manage prompt flows, possibly through the Azure ML SDK or API

resource "azurerm_machine_learning_prompt_flow" "sample" {
  name        = "sample-prompt-flow"
  project_id  = azurerm_machine_learning_project.this.id
  display_name = "Sample Chat Flow"
  description = "A sample prompt flow for the chat application"
  
  # This is a simplified representation - actual prompt flow would be more complex
  yaml_content = <<-EOT
flow:
  name: chat_flow
  inputs:
    query:
      type: string
      default: "What is Azure OpenAI?"
  outputs:
    answer:
      type: string
  nodes:
  - name: search_data
    type: python
    inputs:
      query: ${{inputs.query}}
    code: |
      def search_data(query):
          # This would be replaced with actual search logic
          return f"Search results for: {query}"
    outputs:
      search_results: search_results
  - name: generate_response
    type: llm
    inputs:
      prompt: |
        Here is a query: ${{inputs.query}}
        Here are some relevant search results: ${{search_data.outputs.search_results}}
        
        Please provide a comprehensive answer to the query based on the search results.
      deployment_name: gpt-35-turbo
      temperature: 0.7
      max_tokens: 1000
    connection: openai-connection
    outputs:
      answer: answer
  outputs:
    answer: ${{generate_response.outputs.answer}}
EOT
}
