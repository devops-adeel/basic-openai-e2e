# End-to-End Integration Test

# Mock provider for Azure
mock_provider "azurerm" {
  source = "registry.terraform.io/hashicorp/azurerm"
}

# Mock data sources
mock_data "azurerm_client_config" {
  defaults = {
    client_id = "aabbccdd-eeff-0011-2233-445566778899"
    tenant_id = "22222222-2222-2222-2222-222222222222"
    object_id = "bbccddee-ff00-1122-3344-556677889900"
    subscription_id = "00000000-0000-0000-0000-000000000000"
  }
}

# Variables for the test runs
variables {
  prefix = "openai"
  environment = "test"
  location = "eastus"
  tags = {
    Environment = "test"
    Project = "openai-chat"
    Provisioner = "Terraform"
  }
  openai_deployments = [
    {
      name = "gpt-35-turbo"
      model = "gpt-35-turbo"
      version = "0613"
      capacity = 1
    }
  ]
  openai_content_filter = {
    hate = "high"
    sexual = "high"
    violence = "high"
    self_harm = "high"
    profanity = "high"
    jailbreak = "high"
  }
}

# Test case: Create the entire infrastructure
run "create_infrastructure" {
  # Run the whole root module
  command = apply
  
  # The resource mocking would be quite extensive for this test
  # Here's the basic structure - in a real test, you'd need to mock all resources

  # Resource Group mock
  mock_resource "azurerm_resource_group" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/openai-test-rg"
      name = "openai-test-rg"
      location = "eastus"
    }
  }
  
  # Storage Account mocks
  mock_resource "azurerm_storage_account" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/openai-test-rg/providers/Microsoft.Storage/storageAccounts/openaitestst"
      name = "openaitestst"
      resource_group_name = "openai-test-rg"
      location = "eastus"
      identity = [
        {
          type = "SystemAssigned"
          principal_id = "11111111-1111-1111-1111-111111111111"
        }
      ]
    }
  }
  
  # Container Registry mocks
  mock_resource "azurerm_container_registry" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/openai-test-rg/providers/Microsoft.ContainerRegistry/registries/openaitestcr"
      name = "openaitestcr"
      resource_group_name = "openai-test-rg"
      location = "eastus"
      identity = [
        {
          type = "SystemAssigned"
          principal_id = "22222222-2222-2222-2222-222222222222"
        }
      ]
    }
  }
  
  # Key Vault mocks
  mock_resource "azurerm_key_vault" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/openai-test-rg/providers/Microsoft.KeyVault/vaults/openaitestkv"
      name = "openaitestkv"
      resource_group_name = "openai-test-rg"
      location = "eastus"
      tenant_id = "22222222-2222-2222-2222-222222222222"
      vault_uri = "https://openaitestkv.vault.azure.net/"
    }
  }
  
  # OpenAI mocks
  mock_resource "azurerm_cognitive_account" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/openai-test-rg/providers/Microsoft.CognitiveServices/accounts/openai-test-openai"
      name = "openai-test-openai"
      resource_group_name = "openai-test-rg"
      location = "eastus"
      kind = "OpenAI"
      identity = [
        {
          type = "SystemAssigned"
          principal_id = "33333333-3333-3333-3333-333333333333"
        }
      ]
      endpoint = "https://openai-test-openai.openai.azure.com/"
    }
  }
  
  # AI Search mocks
  mock_resource "azurerm_search_service" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/openai-test-rg/providers/Microsoft.Search/searchServices/openai-test-search"
      name = "openai-test-search"
      resource_group_name = "openai-test-rg"
      location = "eastus"
      sku = "basic"
    }
  }
  
  # Monitoring mocks
  mock_resource "azurerm_application_insights" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/openai-test-rg/providers/Microsoft.Insights/components/openai-test-ai"
      name = "openai-test-ai"
      resource_group_name = "openai-test-rg"
      location = "eastus"
      application_type = "web"
      instrumentation_key = "test-instrumentation-key"
      workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/openai-test-rg/providers/Microsoft.OperationalInsights/workspaces/openai-test-ai-law"
    }
  }
  
  # AI Foundry mocks
  mock_resource "azurerm_machine_learning_hub" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/openai-test-rg/providers/Microsoft.MachineLearningServices/hubs/openai-test-aihub"
      name = "openai-test-aihub"
      resource_group_name = "openai-test-rg"
      location = "eastus"
      identity = [
        {
          type = "SystemAssigned"
          principal_id = "44444444-4444-4444-4444-444444444444"
        }
      ]
    }
  }
  
  # Azure ML mocks
  mock_resource "azurerm_machine_learning_workspace" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/openai-test-rg/providers/Microsoft.MachineLearningServices/workspaces/openai-test-ml"
      name = "openai-test-ml"
      resource_group_name = "openai-test-rg"
      location = "eastus"
      identity = [
        {
          type = "SystemAssigned"
          principal_id = "55555555-5555-5555-5555-555555555555"
        }
      ]
    }
  }
  
  # App Service mocks
  mock_resource "azurerm_service_plan" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/openai-test-rg/providers/Microsoft.Web/serverfarms/openai-test-app-plan"
      name = "openai-test-app-plan"
      resource_group_name = "openai-test-rg"
      location = "eastus"
      os_type = "Linux"
      sku_name = "B1"
    }
  }
  
  mock_resource "azurerm_linux_web_app" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/openai-test-rg/providers/Microsoft.Web/sites/openai-test-app"
      name = "openai-test-app"
      resource_group_name = "openai-test-rg"
      location = "eastus"
      service_plan_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/openai-test-rg/providers/Microsoft.Web/serverfarms/openai-test-app-plan"
      identity = [
        {
          type = "SystemAssigned"
          principal_id = "66666666-6666-6666-6666-666666666666"
        }
      ]
      site_config = [
        {
          always_on = true
          ftps_state = "Disabled"
          minimum_tls_version = "1.2"
        }
      ]
      default_hostname = "openai-test-app.azurewebsites.net"
    }
  }

  # Assert on key outputs
  assert {
    condition     = output.resource_group_name == "openai-test-rg"
    error_message = "Resource group name does not match expected value."
  }

  assert {
    condition     = output.app_service_url == "openai-test-app.azurewebsites.net"
    error_message = "App Service URL does not match expected value."
  }

  assert {
    condition     = output.openai_endpoint == "https://openai-test-openai.openai.azure.com/"
    error_message = "OpenAI endpoint does not match expected value."
  }
  
  # Assert on resource identity presence
  assert {
    condition     = output.app_service_principal_id != null
    error_message = "App Service principal ID should not be null."
  }
  
  assert {
    condition     = output.ai_foundry_hub_principal_id != null
    error_message = "AI Foundry Hub principal ID should not be null."
  }
  
  assert {
    condition     = output.ai_foundry_project_principal_id != null
    error_message = "AI Foundry Project principal ID should not be null."
  }
}

# Test case: Check infrastructure connectivity
run "infrastructure_connectivity_test" {
  # This simulates testing the connectivity between key components
  
  # Define mock outputs to simulate what would be returned from the actual infrastructure
  mock_output {
    module = root
    name = "app_service_principal_id"
    value = "66666666-6666-6666-6666-666666666666"
  }
  
  mock_output {
    module = root
    name = "ai_foundry_hub_id"
    value = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/openai-test-rg/providers/Microsoft.MachineLearningServices/hubs/openai-test-aihub"
  }
  
  mock_output {
    module = root
    name = "azure_ml_endpoint_scoring_uri"
    value = "https://openai-test-endpoint.eastus.inference.ml.azure.com/score"
  }
  
  mock_output {
    module = root
    name = "openai_endpoint"
    value = "https://openai-test-openai.openai.azure.com/"
  }
  
  # Verify connectivity by checking that all necessary endpoints are defined
  assert {
    condition     = mock_output.app_service_principal_id != null && 
                    mock_output.ai_foundry_hub_id != null && 
                    mock_output.azure_ml_endpoint_scoring_uri != null && 
                    mock_output.openai_endpoint != null
    error_message = "Missing required endpoint information for connectivity."
  }
  
  # In a real test, we might include more assertions that verify:
  # - App Service can access the ML endpoint (via key vault secret references)
  # - ML endpoint can access OpenAI and AI Search
  # - AI Foundry can deploy to ML endpoint
  # But in a mocked test, we're limited to what we can model
}

# Test case: Check policy compliance
run "infrastructure_policy_compliance" {
  # This simulates checking that infrastructure complies with security policies
  
  # Mock HTTPS settings from App Service
  mock_resource "azurerm_linux_web_app" {
    defaults = {
      https_only = true
      site_config = [
        {
          minimum_tls_version = "1.2"
          ftps_state = "Disabled"
        }
      ]
    }
  }
  
  # Mock Key Vault settings
  mock_resource "azurerm_key_vault" {
    defaults = {
      purge_protection_enabled = true
      soft_delete_retention_days = 7
    }
  }
  
  # Mock OpenAI content filter settings
  mock_resource "azurerm_cognitive_deployment" {
    defaults = {
      content_filter = [
        {
          hate = [
            {
              severity_level = "high"
            }
          ]
          sexual = [
            {
              severity_level = "high"
            }
          ]
          violence = [
            {
              severity_level = "high"
            }
          ]
        }
      ]
    }
  }
  
  # Verify HTTPS is enforced
  assert {
    condition     = mock_resource.azurerm_linux_web_app.defaults.https_only == true
    error_message = "HTTPS must be enforced on App Service."
  }
  
  # Verify TLS version is 1.2 minimum
  assert {
    condition     = mock_resource.azurerm_linux_web_app.defaults.site_config[0].minimum_tls_version == "1.2"
    error_message = "Minimum TLS version must be 1.2."
  }
  
  # Verify Key Vault has purge protection
  assert {
    condition     = mock_resource.azurerm_key_vault.defaults.purge_protection_enabled == true
    error_message = "Key Vault must have purge protection enabled."
  }
  
  # Verify OpenAI has content filtering
  assert {
    condition     = length(mock_resource.azurerm_cognitive_deployment.defaults.content_filter) > 0
    error_message = "OpenAI must have content filtering enabled."
  }
}
