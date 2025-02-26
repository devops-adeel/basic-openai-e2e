# Storage Module Tests

# Mock provider for Azure
mock_provider "azurerm" {
  source = "registry.terraform.io/hashicorp/azurerm"
}

# Variables for the test runs
variables {
  name                     = "teststorage"
  resource_group_name      = "test-rg"
  location                 = "eastus"
  tags                     = {
    Environment = "test"
    Project     = "openai-chat"
    Provisioner = "Terraform"
  }
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  soft_delete_retention_days = 7
  enable_versioning        = true
}

# Test case: Create Storage Account with basic configuration
run "create_storage_basic" {
  # Define mock resources
  mock_resource "azurerm_storage_account" {
    defaults = {
      id                      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/teststorage"
      name                    = "teststorage"
      resource_group_name     = "test-rg"
      location                = "eastus"
      account_tier            = "Standard"
      account_replication_type = "LRS"
      account_kind            = "StorageV2"
      min_tls_version         = "TLS1_2"
      enable_https_traffic_only = true
      allow_nested_items_to_be_public = false
      identity = [
        {
          type         = "SystemAssigned"
          principal_id = "11111111-1111-1111-1111-111111111111"
          tenant_id    = "22222222-2222-2222-2222-222222222222"
        }
      ]
      primary_access_key      = "test-access-key"
      primary_blob_endpoint   = "https://teststorage.blob.core.windows.net/"
      primary_connection_string = "DefaultEndpointsProtocol=https;AccountName=teststorage;AccountKey=test-access-key;EndpointSuffix=core.windows.net"
      blob_properties = [
        {
          delete_retention_policy = [
            {
              days = 7
            }
          ]
          container_delete_retention_policy = [
            {
              days = 7
            }
          ]
          versioning_enabled = true
        }
      ]
      queue_properties = [
        {
          logging = [
            {
              delete  = true
              read    = true
              write   = true
              version = "1.0"
              retention_policy_days = 7
            }
          ]
        }
      ]
      tags                     = {
        Environment = "test"
        Project     = "openai-chat"
        Provisioner = "Terraform"
      }
    }
  }
  
  mock_resource "azurerm_storage_container" {
    defaults = {
      id                  = "https://teststorage.blob.core.windows.net/prompt-flows"
      name                = "prompt-flows"
      storage_account_name = "teststorage"
      container_access_type = "private"
    }
  }

  # Reference the module
  module {
    source = "../../modules/storage"
  }

  # Assert outputs
  assert {
    condition     = output.name == "teststorage"
    error_message = "Storage account name does not match expected value."
  }

  assert {
    condition     = output.primary_blob_endpoint == "https://teststorage.blob.core.windows.net/"
    error_message = "Storage account primary blob endpoint does not match expected value."
  }

  assert {
    condition     = output.principal_id == "11111111-1111-1111-1111-111111111111"
    error_message = "Storage account principal ID does not match expected value."
  }

  assert {
    condition     = output.prompt_flows_container_name == "prompt-flows"
    error_message = "Prompt flows container name does not match expected value."
  }
}

# Test case: Create Storage Account with invalid name (should fail)
run "create_storage_invalid_name" {
  # Override the name variable with an invalid value
  variables {
    name = "Invalid_Storage_Name" # Contains uppercase and underscores
  }

  # Reference the module
  module {
    source = "../../modules/storage"
  }

  # Expect this to fail because of the name validation
  expect_failures = [
    is_match(validation.var.name.error_message, "Storage account name must be between 3 and 24 characters, contain only lowercase letters and numbers."),
  ]
}

# Test case: Verify secure transfer is required
run "verify_secure_transfer" {
  # Mock Storage account with secure transfer disabled
  mock_resource "azurerm_storage_account" {
    defaults = {
      id                      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/teststorage"
      name                    = "teststorage"
      resource_group_name     = "test-rg"
      location                = "eastus"
      account_tier            = "Standard"
      account_replication_type = "LRS"
      account_kind            = "StorageV2"
      min_tls_version         = "TLS1_2"
      enable_https_traffic_only = false # Secure transfer disabled
      identity = [
        {
          type         = "SystemAssigned"
          principal_id = "11111111-1111-1111-1111-111111111111"
          tenant_id    = "22222222-2222-2222-2222-222222222222"
        }
      ]
    }
  }

  # Reference the module
  module {
    source = "../../modules/storage"
  }

  # Expect this to fail because of the secure transfer check
  expect_failures = [
    is_match(check.storage_secure_transfer.error_message, "Storage account must have secure transfer enabled."),
  ]
}

# Test case: Verify TLS version
run "verify_tls_version" {
  # Mock Storage account with TLS 1.0
  mock_resource "azurerm_storage_account" {
    defaults = {
      id                      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/teststorage"
      name                    = "teststorage"
      resource_group_name     = "test-rg"
      location                = "eastus"
      account_tier            = "Standard"
      account_replication_type = "LRS"
      account_kind            = "StorageV2"
      min_tls_version         = "TLS1_0" # TLS 1.0 is not allowed
      enable_https_traffic_only = true
      identity = [
        {
          type         = "SystemAssigned"
          principal_id = "11111111-1111-1111-1111-111111111111"
          tenant_id    = "22222222-2222-2222-2222-222222222222"
        }
      ]
    }
  }

  # Reference the module
  module {
    source = "../../modules/storage"
  }

  # Expect this to fail because of the TLS version check
  expect_failures = [
    is_match(check.storage_minimum_tls.error_message, "Storage account must use TLS 1.2 at minimum."),
  ]
}

# Test case: Create Storage Account with non-private container access (should fail)
run "create_storage_public_container" {
  # Mock private container resources
  mock_resource "azurerm_storage_account" {
    defaults = {
      id                      = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Storage/storageAccounts/teststorage"
      name                    = "teststorage"
      resource_group_name     = "test-rg"
      location                = "eastus"
      min_tls_version         = "TLS1_2"
      enable_https_traffic_only = true
      identity = [
        {
          type         = "SystemAssigned"
          principal_id = "11111111-1111-1111-1111-111111111111"
        }
      ]
    }
  }
  
  mock_resource "azurerm_storage_container" {
    defaults = {
      id                  = "https://teststorage.blob.core.windows.net/prompt-flows"
      name                = "prompt-flows"
      storage_account_name = "teststorage"
      container_access_type = "blob" # Public access not allowed
    }
  }

  # Reference the module
  module {
    source = "../../modules/storage"
  }

  # Expect this to fail because of the container access type check
  expect_failures = [
    is_match(check.storage_private_containers.error_message, "All storage containers must have private access type."),
  ]
}
