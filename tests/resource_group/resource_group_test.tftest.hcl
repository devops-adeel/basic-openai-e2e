# Resource Group Module Tests

# Mock provider for Azure
mock_provider "azurerm" {
  # These source definitions allow the test to reference the azurerm provider's resource schema
  # without attempting to actually connect to Azure.
  source = "registry.terraform.io/hashicorp/azurerm"
}

# Variables for the test runs
variables {
  name = "test-rg"
  location = "eastus"
  tags = {
    Environment = "test"
    Project = "openai-chat"
    Provisioner = "Terraform"
  }
}

# Test case: Create resource group with minimum required parameters
run "create_resource_group_minimum" {
  # Define mock resources and data sources
  # This simulates what the provider would return after creating resources
  mock_resource "azurerm_resource_group" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg"
      name = "test-rg"
      location = "eastus"
      tags = {
        Environment = "test"
        Project = "openai-chat"
        Provisioner = "Terraform"
      }
    }
  }

  # Reference the module
  module {
    source = "../../modules/resource_group"
  }

  # Assert outputs
  assert {
    condition = output.name == "test-rg"
    error_message = "Resource group name does not match expected value."
  }

  assert {
    condition = output.location == "eastus"
    error_message = "Resource group location does not match expected value."
  }

  # Check that the resource group has all required tags
  assert {
    condition = contains(keys(output.tags), "Environment")
    error_message = "Resource group is missing the Environment tag."
  }

  assert {
    condition = contains(keys(output.tags), "Project")
    error_message = "Resource group is missing the Project tag."
  }

  assert {
    condition = contains(keys(output.tags), "Provisioner")
    error_message = "Resource group is missing the Provisioner tag."
  }
}

# Test case: Create resource group with invalid location (should fail)
run "create_resource_group_invalid_location" {
  # Override the location variable with an invalid value
  variables {
    location = "invalid-location"
  }

  # Reference the module
  module {
    source = "../../modules/resource_group"
  }

  # Expect this to fail because of the "resource_group_location" check block
  expect_failures = [
    contains(contains, "resource_group_location"),
  ]
}

# Test case: Create resource group with invalid name length (should fail)
run "create_resource_group_invalid_name_length" {
  # Override the name variable with an invalid value
  variables {
    name = "rg" # Too short
  }

  # Reference the module
  module {
    source = "../../modules/resource_group"
  }

  # Expect this to fail because of the "resource_group_naming_convention" check block
  expect_failures = [
    contains(contains, "resource_group_naming_convention"),
  ]
}

# Test case: Create resource group with missing Environment tag (should fail)
run "create_resource_group_missing_environment_tag" {
  # Override the tags variable without the Environment tag
  variables {
    tags = {
      Project = "openai-chat"
      Provisioner = "Terraform"
    }
  }

  # Reference the module
  module {
    source = "../../modules/resource_group"
  }

  # Expect this to fail because of the "resource_group_required_tags" check block
  expect_failures = [
    contains(contains, "resource_group_required_tags"),
  ]
}
