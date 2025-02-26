# Azure ML Module Tests

# Mock provider for Azure
mock_provider "azurerm" {
  source = "registry.terraform.io/hashicorp/azurerm"
}

# Variables for the test runs
variables {
  name = "test-ml-workspace"
  resource_group_name = "test-rg"
  location = "eastus"
  tags = {
    Environment = "test"
    Project = "openai-chat"
    Provisioner = "Terraform"
  }
  storage_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/teststorage"
  container_registry_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.ContainerRegistry/registries/testregistry"
  application_insights_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Insights/components/testinsights"
  key_vault_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.KeyVault/vaults/testvault"
  ai_foundry_hub_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.MachineLearningServices/hubs/test-ai-hub"
  ai_foundry_project_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.MachineLearningServices/hubs/test-ai-hub/projects/test-ai-project"
  endpoint_name = "test-endpoint"
  deployment_name = "test-deployment"
  instance_type = "Standard_DS3_v2"
  instance_count = 1
}

# Test case: Create Azure ML resources with basic configuration
run "create_azure_ml_basic" {
  # Define mock resources and data sources
  mock_resource "azurerm_machine_learning_workspace" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.MachineLearningServices/workspaces/test-ml-workspace"
      name = "test-ml-workspace"
      location = "eastus"
      resource_group_name = "test-rg"
      application_insights_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Insights/components/testinsights"
      key_vault_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.KeyVault/vaults/testvault"
      storage_account_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/teststorage"
      container_registry_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.ContainerRegistry/registries/testregistry"
      identity = [
        {
          type = "SystemAssigned"
          principal_id = "88888888-8888-8888-8888-888888888888"
          tenant_id = "22222222-2222-2222-2222-222222222222"
        }
      ]
      public_network_access_enabled = true
      tags = {
        Environment = "test"
        Project = "openai-chat"
        Provisioner = "Terraform"
      }
    }
  }
  
  mock_resource "azurerm_machine_learning_online_endpoint" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.MachineLearningServices/workspaces/test-ml-workspace/onlineEndpoints/test-endpoint"
      name = "test-endpoint"
      location = "eastus"
      workspace_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.MachineLearningServices/workspaces/test-ml-workspace"
      description = "Managed online endpoint for chat application"
      identity = [
        {
          type = "SystemAssigned"
          principal_id = "99999999-9999-9999-9999-999999999999"
          tenant_id = "22222222-2222-2222-2222-222222222222"
        }
      ]
      auth_mode = "Key"
      key = "test-endpoint-key"
      scoring_uri = "https://test-endpoint.eastus.inference.ml.azure.com/score"
      public_network_access_enabled = true
      tags = {
        Environment = "test"
        Project = "openai-chat"
        Provisioner = "Terraform"
      }
    }
  }
  
  mock_resource "azurerm_machine_learning_online_deployment" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.MachineLearningServices/workspaces/test-ml-workspace/onlineEndpoints/test-endpoint/deployments/test-deployment"
      name = "test-deployment"
      endpoint_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.MachineLearningServices/workspaces/test-ml-workspace/onlineEndpoints/test-endpoint"
      description = "Deployment for prompt flow"
      model = [
        {
          name = "chat-model"
          version = "1"
          path = "azureml://MODEL-PATH"
        }
      ]
      compute = [
        {
          instance_type = "Standard_DS3_v2"
          instance_count = 1
          scale_settings = [
            {
              scale_type = "Manual"
            }
          ]
        }
      ]
      environment_variables = {
        "OPENAI_API_TYPE" = "azure"
        "DEPLOYMENT_TYPE" = "PromptFlow"
        "PROJECT_ID" = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.MachineLearningServices/hubs/test-ai-hub/projects/test-ai-project"
      }
      tags = {
        Environment = "test"
        Project = "openai-chat"
        Provisioner = "Terraform"
      }
    }
  }
  
  mock_resource "azurerm_role_assignment" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleAssignments/aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
      scope = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/teststorage"
      role_definition_name = "Storage Blob Data Reader"
      principal_id = "99999999-9999-9999-9999-999999999999"
    }
  }

  # Reference the module
  module {
    source = "../../modules/azure_ml"
  }

  # Assert outputs
  assert {
    condition = output.workspace_id != ""
    error_message = "Azure ML Workspace ID should not be empty."
  }

  assert {
    condition = output.workspace_name == "test-ml-workspace"
    error_message = "Azure ML Workspace name does not match expected value."
  }

  assert {
    condition = output.workspace_principal_id == "88888888-8888-8888-8888-888888888888"
    error_message = "Azure ML Workspace Principal ID does not match expected value."
  }

  assert {
    condition = output.endpoint_id != ""
    error_message = "Azure ML Endpoint ID should not be empty."
  }

  assert {
    condition = output.endpoint_name == "test-endpoint"
    error_message = "Azure ML Endpoint name does not match expected value."
  }

  assert {
    condition = output.endpoint_scoring_uri == "https://test-endpoint.eastus.inference.ml.azure.com/score"
    error_message = "Azure ML Endpoint scoring URI does not match expected value."
  }

  assert {
    condition = output.endpoint_principal_id == "99999999-9999-9999-9999-999999999999"
    error_message = "Azure ML Endpoint Principal ID does not match expected value."
  }

  assert {
    condition = output.endpoint_key == "test-endpoint-key"
    error_message = "Azure ML Endpoint key does not match expected value."
  }

  assert {
    condition = output.deployment_id != ""
    error_message = "Azure ML Deployment ID should not be empty."
  }
}

# Test case: Create Azure ML resources with invalid workspace name (should fail)
run "create_azure_ml_invalid_workspace_name" {
  # Override the workspace name with an invalid value
  variables {
    name = "invalid_workspace_name" # Contains underscore
  }

  # Reference the module
  module {
    source = "../../modules/azure_ml"
  }

  # Expect this to fail because of the workspace naming convention check
  expect_failures = [
    is_match(check.azure_ml_workspace_naming_convention.error_message, "Azure ML workspace name must use only letters, numbers, and hyphens."),
  ]
}

# Test case: Create Azure ML resources with invalid endpoint name (should fail)
run "create_azure_ml_invalid_endpoint_name" {
  # Override the endpoint name with an invalid value
  variables {
    endpoint_name = "invalid_endpoint_name" # Contains underscore
  }

  # Reference the module
  module {
    source = "../../modules/azure_ml"
  }

  # Expect this to fail because of the endpoint naming convention check
  expect_failures = [
    is_match(check.azure_ml_endpoint_naming_convention.error_message, "Azure ML endpoint name must use only letters, numbers, and hyphens."),
  ]
}

# Test case: Create Azure ML resources with invalid instance type (should fail)
run "create_azure_ml_invalid_instance_type" {
  # Override the instance type with an invalid value
  variables {
    instance_type = "Basic_A1" # Not a Standard SKU
  }

  # Reference the module
  module {
    source = "../../modules/azure_ml"
  }

  # Expect this to fail because of the instance type check
  expect_failures = [
    is_match(check.azure_ml_instance_type.error_message, "Azure ML instance type must be a valid Standard SKU."),
  ]
}

# Test case: Create Azure ML resources with zero instances (should fail)
run "create_azure_ml_zero_instances" {
  # Override the instance count with an invalid value
  variables {
    instance_count = 0 # Must be greater than 0
  }

  # Reference the module
  module {
    source = "../../modules/azure_ml"
  }

  # Expect this to fail because of the instance count validation
  expect_failures = [
    is_match(validation.var.instance_count.error_message, "Instance count must be greater than 0."),
  ]
}
