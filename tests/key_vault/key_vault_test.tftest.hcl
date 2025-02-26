# Key Vault Module Tests

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
  name = "testvault"
  resource_group_name = "test-rg"
  location = "eastus"
  sku_name = "standard"
  tags = {
    Environment = "test"
    Project = "openai-chat"
    Provisioner = "Terraform"
  }
  purge_protection_enabled = true
  soft_delete_retention_days = 7
  enable_rbac_authorization = true
  network_acls = {
    bypass = "AzureServices"
    default_action = "Allow"
    ip_rules = []
    virtual_network_subnet_ids = []
  }
}

# Test case: Create Key Vault with basic configuration
run "create_key_vault_basic" {
  # Define mock resources and data sources
  mock_resource "azurerm_key_vault" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.KeyVault/vaults/testvault"
      name = "testvault"
      location = "eastus"
      resource_group_name = "test-rg"
      tenant_id = "22222222-2222-2222-2222-222222222222"
      sku_name = "standard"
      purge_protection_enabled = true
      soft_delete_retention_days = 7
      enable_rbac_authorization = true
      vault_uri = "https://testvault.vault.azure.net/"
      network_acls = [
        {
          bypass = "AzureServices"
          default_action = "Allow"
          ip_rules = []
          virtual_network_subnet_ids = []
        }
      ]
      tags = {
        Environment = "test"
        Project = "openai-chat"
        Provisioner = "Terraform"
      }
    }
  }

  # Reference the module
  module {
    source = "../../modules/key_vault"
  }

  # Assert outputs
  assert {
    condition = output.name == "testvault"
    error_message = "Key Vault name does not match expected value."
  }

  assert {
    condition = output.vault_uri == "https://testvault.vault.azure.net/"
    error_message = "Key Vault URI does not match expected value."
  }

  assert {
    condition = output.tenant_id == "22222222-2222-2222-2222-222222222222"
    error_message = "Key Vault tenant ID does not match expected value."
  }
}

# Test case: Create Key Vault with invalid name (should fail)
run "create_key_vault_invalid_name" {
  # Override the name variable with an invalid value
  variables {
    name = "invalid_vault_name" # Contains underscore
  }

  # Reference the module
  module {
    source = "../../modules/key_vault"
  }

  # Expect this to fail because of the name validation
  expect_failures = [
    is_match(validation.var.name.error_message, "Key Vault name must use only letters, numbers, and hyphens."),
  ]
}

# Test case: Create Key Vault with invalid soft delete retention (should fail)
run "create_key_vault_invalid_soft_delete" {
  # Override the soft delete retention variable with an invalid value
  variables {
    soft_delete_retention_days = 5 # Less than 7 days
  }

  # Reference the module
  module {
    source = "../../modules/key_vault"
  }

  # Expect this to fail because of the soft delete validation
  expect_failures = [
    is_match(validation.var.soft_delete_retention_days.error_message, "Soft delete retention days must be between 7 and 90 days."),
  ]
}

# Test case: Create Key Vault with invalid SKU (should fail)
run "create_key_vault_invalid_sku" {
  # Override the SKU variable with an invalid value
  variables {
    sku_name = "basic" # Not a valid SKU
  }

  # Reference the module
  module {
    source = "../../modules/key_vault"
  }

  # Expect this to fail because of the SKU validation
  expect_failures = [
    is_match(validation.var.sku_name.error_message, "SKU name must be either 'standard' or 'premium'."),
  ]
}

# Test case: Create Key Vault with no purge protection (should work in this architecture)
run "create_key_vault_no_purge_protection" {
  # Override the purge protection variable
  variables {
    purge_protection_enabled = false
  }
  
  # Define mock resources
  mock_resource "azurerm_key_vault" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.KeyVault/vaults/testvault"
      name = "testvault"
      location = "eastus"
      resource_group_name = "test-rg"
      tenant_id = "22222222-2222-2222-2222-222222222222"
      sku_name = "standard"
      purge_protection_enabled = false
      soft_delete_retention_days = 7
      enable_rbac_authorization = true
      vault_uri = "https://testvault.vault.azure.net/"
      network_acls = [
        {
          bypass = "AzureServices"
          default_action = "Allow"
          ip_rules = []
          virtual_network_subnet_ids = []
        }
      ]
      tags = {
        Environment = "test"
        Project = "openai-chat"
        Provisioner = "Terraform"
      }
    }
  }

  # Reference the module
  module {
    source = "../../modules/key_vault"
  }

  # This should pass since we are just checking for the module operation
  # in a basic architecture. The Sentinel policy would still catch this
  # in a real deployment pipeline.
}
