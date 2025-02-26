# AI Foundry Module Tests

# Mock provider for Azure
mock_provider "azurerm" {
  source = "registry.terraform.io/hashicorp/azurerm"
}

# Variables for the test runs
variables {
  hub_name = "test-ai-hub"
  project_name = "test-ai-project"
  project_display_name = "Test AI Project"
  project_description = "Test AI Foundry project for chat application"
  resource_group_name = "test-rg"
  location = "eastus"
  tags = {
    Environment = "test"
    Project = "openai-chat"
    Provisioner = "Terraform"
  }
  storage_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/teststorage"
  container_registry_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.ContainerRegistry/registries/testregistry"
  key_vault_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.KeyVault/vaults/testvault"
  openai_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.CognitiveServices/accounts/testopenai"
  search_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Search/searchServices/testsearch"
  application_insights_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Insights/components/testinsights"
}

# Test case: Create AI Foundry resources with basic configuration
run "create_ai_foundry_basic" {
  # Define mock resources and data sources
  mock_resource "azurerm_machine_learning_hub" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.MachineLearningServices/hubs/test-ai-hub"
      name = "test-ai-hub"
      location = "eastus"
      resource_group_name = "test-rg"
      identity = [
        {
          type = "SystemAssigned"
          principal_id = "55555555-5555-5555-5555-555555555555"
          tenant_id = "22222222-2222-2222-2222-222222222222"
        }
      ]
      tags = {
        Environment = "test"
        Project = "openai-chat"
        Provisioner = "Terraform"
      }
    }
  }
  
  mock_resource "azurerm_machine_learning_project" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.MachineLearningServices/hubs/test-ai-hub/projects/test-ai-project"
      name = "test-ai-project"
      hub_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.MachineLearningServices/hubs/test-ai-hub"
      display_name = "Test AI Project"
      description = "Test AI Foundry project for chat application"
      identity = [
        {
          type = "SystemAssigned"
          principal_id = "66666666-6666-6666-6666-666666666666"
          tenant_id = "22222222-2222-2222-2222-222222222222"
        }
      ]
      tags = {
        Environment = "test"
        Project = "openai-chat"
        Provisioner = "Terraform"
      }
    }
  }
  
  mock_resource "azurerm_role_assignment" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/providers/Microsoft.Authorization/roleAssignments/77777777-7777-7777-7777-777777777777"
      scope = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/teststorage"
      role_definition_name = "Storage Blob Data Contributor"
      principal_id = "55555555-5555-5555-5555-555555555555"
    }
  }
  
  mock_resource "azurerm_machine_learning_connection" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.MachineLearningServices/hubs/test-ai-hub/connections/openai-connection"
      name = "openai-connection"
      hub_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.MachineLearningServices/hubs/test-ai-hub"
      target = "AzureOpenAI"
      category = "AzureResource"
      credentials = [
        {
          identity = [
            {
              type = "SystemAssigned"
            }
          ]
        }
      ]
      resource_id_parameter_name = "resource_id"
      parameters = {
        resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.CognitiveServices/accounts/testopenai"
      }
    }
  }
  
  mock_resource "azurerm_machine_learning_prompt_flow" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.MachineLearningServices/hubs/test-ai-hub/projects/test-ai-project/promptFlows/sample-prompt-flow"
      name = "sample-prompt-flow"
      project_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.MachineLearningServices/hubs/test-ai-hub/projects/test-ai-project"
      display_name = "Sample Chat Flow"
      description = "A sample prompt flow for the chat application"
      yaml_content = "flow:\n  name: chat_flow\n  inputs:\n    query:\n      type: string\n      default: \"What is Azure OpenAI?\"\n  outputs:\n    answer:\n      type: string\n  nodes:\n  - name: search_data\n    type: python\n    inputs:\n      query: ${{inputs.query}}\n    code: |\n      def search_data(query):\n          # This would be replaced with actual search logic\n          return f\"Search results for: {query}\"\n    outputs:\n      search_results: search_results\n  - name: generate_response\n    type: llm\n    inputs:\n      prompt: |\n        Here is a query: ${{inputs.query}}\n        Here are some relevant search results: ${{search_data.outputs.search_results}}\n        \n        Please provide a comprehensive answer to the query based on the search results.\n      deployment_name: gpt-35-turbo\n      temperature: 0.7\n      max_tokens: 1000\n    connection: openai-connection\n    outputs:\n      answer: answer\n  outputs:\n    answer: ${{generate_response.outputs.answer}}"
    }
  }

  # Reference the module
  module {
    source = "../../modules/ai_foundry"
  }

  # Assert outputs
  assert {
    condition = output.hub_id != ""
    error_message = "AI Foundry Hub ID should not be empty."
  }

  assert {
    condition = output.project_id != ""
    error_message = "AI Foundry Project ID should not be empty."
  }

  assert {
    condition = output.hub_principal_id == "55555555-5555-5555-5555-555555555555"
    error_message = "AI Foundry Hub Principal ID does not match expected value."
  }

  assert {
    condition = output.project_principal_id == "66666666-6666-6666-6666-666666666666"
    error_message = "AI Foundry Project Principal ID does not match expected value."
  }

  assert {
    condition = output.prompt_flow_id != ""
    error_message = "Prompt Flow ID should not be empty."
  }
}

# Test case: Create AI Foundry resources with invalid hub name (should fail)
run "create_ai_foundry_invalid_hub_name" {
  # Override the hub name with an invalid value
  variables {
    hub_name = "invalid_hub_name" # Contains underscore
  }

  # Reference the module
  module {
    source = "../../modules/ai_foundry"
  }

  # Expect this to fail because of the hub naming convention check
  expect_failures = [
    is_match(check.ai_foundry_hub_naming_convention.error_message, "AI Foundry Hub name must use only letters, numbers, and hyphens."),
  ]
}

# Test case: Create AI Foundry resources with invalid project name (should fail)
run "create_ai_foundry_invalid_project_name" {
  # Override the project name with an invalid value
  variables {
    project_name = "invalid_project_name" # Contains underscore
  }

  # Reference the module
  module {
    source = "../../modules/ai_foundry"
  }

  # Expect this to fail because of the project naming convention check
  expect_failures = [
    is_match(check.ai_foundry_project_naming_convention.error_message, "AI Foundry Project name must use only letters, numbers, and hyphens."),
  ]
}

# Test case: Create AI Foundry resources with missing project description (should fail)
run "create_ai_foundry_missing_description" {
  # Override the project description with an empty string
  variables {
    project_description = ""
  }

  # Reference the module
  module {
    source = "../../modules/ai_foundry"
  }

  # Expect this to fail because of the project description check
  expect_failures = [
    is_match(check.ai_foundry_project_description.error_message, "AI Foundry Project must have a description."),
  ]
}
