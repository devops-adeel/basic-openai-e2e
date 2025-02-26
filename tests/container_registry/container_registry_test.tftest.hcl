# Container Registry Module Tests

# Mock provider for Azure
mock_provider "azurerm" {
  source = "registry.terraform.io/hashicorp/azurerm"
}

# Variables for the test runs
variables {
  name                = "testacr"
  resource_group_name = "test-rg"
  location            = "eastus"
  sku                 = "Basic"
  admin_enabled       = false
  tags                = {
    Environment = "test"
    Project     = "openai-chat"
    Provisioner = "Terraform"
  }
}

# Test case: Create Container Registry with basic configuration
run "create_acr_basic" {
  # Define mock resources
  mock_resource "azurerm_container_registry" {
    defaults = {
      id                       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.ContainerRegistry/registries/testacr"
      name                     = "testacr"
      resource_group_name      = "test-rg"
      location                 = "eastus"
      sku                      = "Basic"
      admin_enabled            = false
      login_server             = "testacr.azurecr.io"
      admin_username           = null
      admin_password           = null
      identity = [
        {
          type         = "SystemAssigned"
          principal_id = "11111111-1111-1111-1111-111111111111"
          tenant_id    = "22222222-2222-2222-2222-222222222222"
        }
      ]
      public_network_access_enabled = true
      tags                     = {
        Environment = "test"
        Project     = "openai-chat"
        Provisioner = "Terraform"
      }
    }
  }

  # Reference the module
  module {
    source = "../../modules/container_registry"
  }

  # Assert outputs
  assert {
    condition     = output.name == "testacr"
    error_message = "Container registry name does not match expected value."
  }

  assert {
    condition     = output.login_server == "testacr.azurecr.io"
    error_message = "Container registry login server does not match expected value."
  }

  assert {
    condition     = output.principal_id == "11111111-1111-1111-1111-111111111111"
    error_message = "Container registry principal ID does not match expected value."
  }

  assert {
    condition     = output.admin_username == null
    error_message = "Container registry admin username should be null."
  }
}

# Test case: Create Container Registry with admin enabled
run "create_acr_with_admin" {
  # Override the admin_enabled variable
  variables {
    admin_enabled = true
  }
  
  # Define mock resources
  mock_resource "azurerm_container_registry" {
    defaults = {
      id                       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.ContainerRegistry/registries/testacr"
      name                     = "testacr"
      resource_group_name      = "test-rg"
      location                 = "eastus"
      sku                      = "Basic"
      admin_enabled            = true
      login_server             = "testacr.azurecr.io"
      admin_username           = "testacr"
      admin_password           = "test-admin-password"
      identity = [
        {
          type         = "SystemAssigned"
          principal_id = "11111111-1111-1111-1111-111111111111"
          tenant_id    = "22222222-2222-2222-2222-222222222222"
        }
      ]
      tags                     = {
        Environment = "test"
        Project     = "openai-chat"
        Provisioner = "Terraform"
      }
    }
  }

  # Reference the module
  module {
    source = "../../modules/container_registry"
  }

  # Assert outputs
  assert {
    condition     = output.admin_username == "testacr"
    error_message = "Container registry admin username does not match expected value."
  }

  assert {
    condition     = output.admin_password == "test-admin-password"
    error_message = "Container registry admin password does not match expected value."
  }
}

# Test case: Create Container Registry with Premium SKU and geo-replication
run "create_acr_premium" {
  # Override variables for Premium SKU
  variables {
    sku                      = "Premium"
    georeplication_locations = ["eastus2", "westus2"]
    zone_redundancy_enabled  = true
    network_rule_set = {
      default_action          = "Deny"
      ip_rules                = ["203.0.113.0/24"]
      virtual_network_subnets = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"]
    }
  }
  
  # Define mock resources
  mock_resource "azurerm_container_registry" {
    defaults = {
      id                       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.ContainerRegistry/registries/testacr"
      name                     = "testacr"
      resource_group_name      = "test-rg"
      location                 = "eastus"
      sku                      = "Premium"
      admin_enabled            = false
      login_server             = "testacr.azurecr.io"
      identity = [
        {
          type         = "SystemAssigned"
          principal_id = "11111111-1111-1111-1111-111111111111"
          tenant_id    = "22222222-2222-2222-2222-222222222222"
        }
      ]
      georeplications = [
        {
          location = "eastus2"
          zone_redundancy_enabled = true
          tags = {
            Environment = "test"
            Project     = "openai-chat"
            Provisioner = "Terraform"
          }
        },
        {
          location = "westus2"
          zone_redundancy_enabled = true
          tags = {
            Environment = "test"
            Project     = "openai-chat"
            Provisioner = "Terraform"
          }
        }
      ]
      network_rule_set = [
        {
          default_action = "Deny"
          ip_rule = [
            {
              action = "Allow"
              ip_range = "203.0.113.0/24"
            }
          ]
          virtual_network = [
            {
              action = "Allow"
              subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/test-vnet/subnets/test-subnet"
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

  # Reference the module
  module {
    source = "../../modules/container_registry"
  }

  # Assert outputs
  assert {
    condition     = output.login_server == "testacr.azurecr.io"
    error_message = "Container registry login server does not match expected value."
  }
}

# Test case: Create Container Registry with invalid name (should fail)
run "create_acr_invalid_name" {
  # Override the name variable with an invalid value
  variables {
    name = "invalid_acr_name" # Contains underscore
  }

  # Reference the module
  module {
    source = "../../modules/container_registry"
  }

  # Expect this to fail because of the name validation
  expect_failures = [
    is_match(validation.var.name.error_message, "Container registry name must be between 5 and 50 characters, containing only alphanumeric characters."),
  ]
}

# Test case: Create Container Registry with invalid SKU (should fail)
run "create_acr_invalid_sku" {
  # Override the SKU variable with an invalid value
  variables {
    sku = "Free" # Not a valid SKU
  }

  # Reference the module
  module {
    source = "../../modules/container_registry"
  }

  # Expect this to fail because of the SKU validation
  expect_failures = [
    is_match(validation.var.sku.error_message, "SKU must be one of: Basic, Standard, Premium."),
  ]
}

# Test case: Verify managed identity is required
run "verify_managed_identity" {
  # Mock Container Registry without managed identity
  mock_resource "azurerm_container_registry" {
    defaults = {
      id                       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.ContainerRegistry/registries/testacr"
      name                     = "testacr"
      resource_group_name      = "test-rg"
      location                 = "eastus"
      sku                      = "Basic"
      admin_enabled            = false
      login_server             = "testacr.azurecr.io"
      identity                 = []  # No managed identity
    }
  }

  # Reference the module
  module {
    source = "../../modules/container_registry"
  }

  # Expect this to fail because of the managed identity check
  expect_failures = [
    is_match(check.acr_managed_identity.error_message, "Container registry must have a system-assigned managed identity."),
  ]
}
