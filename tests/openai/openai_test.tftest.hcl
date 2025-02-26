# OpenAI Module Tests

# Mock provider for Azure
mock_provider "azurerm" {
  source = "registry.terraform.io/hashicorp/azurerm"
}

# Variables for the test runs
variables {
  name = "testopenai"
  resource_group_name = "test-rg"
  location = "eastus"
  sku_name = "S0"
  tags = {
    Environment = "test"
    Project = "openai-chat"
    Provisioner = "Terraform"
  }
  deployments = [
    {
      name = "gpt-35-turbo"
      model = "gpt-35-turbo"
      version = "0613"
      capacity = 1
    }
  ]
  content_filter = {
    hate = "high"
    sexual = "high"
    violence = "high"
    self_harm = "high"
    profanity = "high"
    jailbreak = "high"
  }
  customer_managed_key = null
}

# Test case: Create OpenAI service with basic configuration
run "create_openai_basic" {
  # Define mock resources and data sources
  mock_resource "azurerm_cognitive_account" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.CognitiveServices/accounts/testopenai"
      name = "testopenai"
      kind = "OpenAI"
      sku_name = "S0"
      location = "eastus"
      resource_group_name = "test-rg"
      identity = [
        {
          type = "SystemAssigned"
          principal_id = "11111111-1111-1111-1111-111111111111"
          tenant_id = "22222222-2222-2222-2222-222222222222"
        }
      ]
      endpoint = "https://testopenai.openai.azure.com/"
      primary_access_key = "sk-testopenai-key"
      tags = {
        Environment = "test"
        Project = "openai-chat"
        Provisioner = "Terraform"
      }
    }
  }
  
  mock_resource "azurerm_cognitive_deployment" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.CognitiveServices/accounts/testopenai/deployments/gpt-35-turbo"
      name = "gpt-35-turbo"
      cognitive_account_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.CognitiveServices/accounts/testopenai"
      model = [
        {
          name = "gpt-35-turbo"
          version = "0613"
          format = "OpenAI"
        }
      ]
      scale = [
        {
          type = "Standard"
          capacity = 1
        }
      ]
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
          self_harm = [
            {
              severity_level = "high"
            }
          ]
          profanity = [
            {
              severity_level = "high"
            }
          ]
          jailbreak = [
            {
              severity_level = "high"
            }
          ]
        }
      ]
    }
  }

  # Reference the module
  module {
    source = "../../modules/openai"
  }

  # Assert outputs
  assert {
    condition = output.id != ""
    error_message = "OpenAI service ID should not be empty."
  }

  assert {
    condition = output.endpoint == "https://testopenai.openai.azure.com/"
    error_message = "OpenAI endpoint does not match expected value."
  }

  assert {
    condition = output.principal_id == "11111111-1111-1111-1111-111111111111"
    error_message = "OpenAI principal ID does not match expected value."
  }

  # Check deployment IDs
  assert {
    condition = length(output.deployment_ids) == 1
    error_message = "Expected 1 deployment."
  }
  
  assert {
    condition = contains(keys(output.deployment_ids), "gpt-35-turbo")
    error_message = "Expected to find gpt-35-turbo deployment."
  }
}

# Test case: Create OpenAI service with minimum content filter settings
run "create_openai_minimum_content_filter" {
  # Override the content filter variable with minimum settings
  variables {
    content_filter = {
      hate = "medium"
      sexual = "medium"
      violence = "medium"
      self_harm = "medium"
      profanity = "medium"
      jailbreak = "medium"
    }
  }
  
  # Mock cognitive account resource
  mock_resource "azurerm_cognitive_account" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.CognitiveServices/accounts/testopenai"
      name = "testopenai"
      kind = "OpenAI"
      sku_name = "S0"
      location = "eastus"
      resource_group_name = "test-rg"
      identity = [
        {
          type = "SystemAssigned"
          principal_id = "11111111-1111-1111-1111-111111111111"
          tenant_id = "22222222-2222-2222-2222-222222222222"
        }
      ]
      endpoint = "https://testopenai.openai.azure.com/"
      primary_access_key = "sk-testopenai-key"
      tags = {
        Environment = "test"
        Project = "openai-chat"
        Provisioner = "Terraform"
      }
    }
  }
  
  # Mock cognitive deployment with medium content filtering
  mock_resource "azurerm_cognitive_deployment" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.CognitiveServices/accounts/testopenai/deployments/gpt-35-turbo"
      name = "gpt-35-turbo"
      cognitive_account_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.CognitiveServices/accounts/testopenai"
      model = [
        {
          name = "gpt-35-turbo"
          version = "0613"
          format = "OpenAI"
        }
      ]
      scale = [
        {
          type = "Standard"
          capacity = 1
        }
      ]
      content_filter = [
        {
          hate = [
            {
              severity_level = "medium"
            }
          ]
          sexual = [
            {
              severity_level = "medium"
            }
          ]
          violence = [
            {
              severity_level = "medium"
            }
          ]
          self_harm = [
            {
              severity_level = "medium"
            }
          ]
          profanity = [
            {
              severity_level = "medium"
            }
          ]
          jailbreak = [
            {
              severity_level = "medium"
            }
          ]
        }
      ]
    }
  }

  # Reference the module
  module {
    source = "../../modules/openai"
  }

  # The test should pass since medium is the minimum acceptable level
}

# Test case: Create OpenAI service with invalid content filter (should fail)
run "create_openai_invalid_content_filter" {
  # Override the content filter variable with invalid settings
  variables {
    content_filter = {
      hate = "low"  # This is below the minimum required level
      sexual = "high"
      violence = "high"
      self_harm = "high"
      profanity = "high"
      jailbreak = "high"
    }
  }

  # Reference the module
  module {
    source = "../../modules/openai"
  }

  # Expect this to fail because of the content filter validation
  expect_failures = [
    is_match(check.openai_content_filter_settings.error_message, "Content filter settings for hate, sexual, and violence must be set to 'low', 'medium', or 'high'."),
  ]
}

# Test case: Create OpenAI service with invalid name (should fail)
run "create_openai_invalid_name" {
  # Override the name variable with an invalid value
  variables {
    name = "Test_OpenAI_Invalid" # Contains uppercase and underscores
  }

  # Reference the module
  module {
    source = "../../modules/openai"
  }

  # Expect this to fail because of the name validation
  expect_failures = [
    is_match(check.openai_naming_convention.error_message, "OpenAI service name must use only lowercase letters, numbers, and hyphens."),
  ]
}
