# AI Search Module Tests

# Mock provider for Azure
mock_provider "azurerm" {
  source = "registry.terraform.io/hashicorp/azurerm"
}

# Variables for the test runs
variables {
  name = "testsearch"
  resource_group_name = "test-rg"
  location = "eastus"
  sku = "basic"
  replica_count = 1
  partition_count = 1
  tags = {
    Environment = "test"
    Project = "openai-chat"
    Provisioner = "Terraform"
  }
}

# Test case: Create Search service with basic configuration
run "create_search_basic" {
  # Define mock resources and data sources
  mock_resource "azurerm_search_service" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Search/searchServices/testsearch"
      name = "testsearch"
      resource_group_name = "test-rg"
      location = "eastus"
      sku = "basic"
      replica_count = 1
      partition_count = 1
      public_network_access_enabled = true
      primary_key = "primary-search-key"
      secondary_key = "secondary-search-key"
      query_keys = [
        {
          key = "query-key"
          name = "query-key-1"
          value = "query-key-value"
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
    source = "../../modules/search"
  }

  # Assert outputs
  assert {
    condition = output.name == "testsearch"
    error_message = "Search service name does not match expected value."
  }

  assert {
    condition = output.endpoint == "https://testsearch.search.windows.net"
    error_message = "Search service endpoint does not match expected value."
  }

  assert {
    condition = output.primary_key == "primary-search-key"
    error_message = "Search service primary key does not match expected value."
  }
}

# Test case: Create Search service with invalid name (should fail)
run "create_search_invalid_name" {
  # Override the name variable with an invalid value
  variables {
    name = "invalid_search_name" # Contains underscore
  }

  # Reference the module
  module {
    source = "../../modules/search"
  }

  # Expect this to fail because of the name validation
  expect_failures = [
    is_match(validation.var.name.error_message, "Search service name must use only letters, numbers, and hyphens."),
  ]
}

# Test case: Create Search service with invalid SKU (should fail)
run "create_search_invalid_sku" {
  # Override the SKU variable with an invalid value
  variables {
    sku = "invalid-sku"
  }

  # Reference the module
  module {
    source = "../../modules/search"
  }

  # Expect this to fail because of the SKU validation
  expect_failures = [
    is_match(validation.var.sku.error_message, "SKU must be one of: free, basic, standard, standard2, standard3, storage_optimized_l1, or storage_optimized_l2."),
  ]
}

# Test case: Create Search service with invalid replica count (should fail)
run "create_search_invalid_replica_count" {
  # Override the replica count variable with an invalid value
  variables {
    replica_count = 0 # Less than 1
  }

  # Reference the module
  module {
    source = "../../modules/search"
  }

  # Expect this to fail because of the replica count validation
  expect_failures = [
    is_match(validation.var.replica_count.error_message, "Replica count must be at least 1."),
  ]
}

# Test case: Create Search service with invalid partition count (should fail)
run "create_search_invalid_partition_count" {
  # Override the partition count variable with an invalid value
  variables {
    partition_count = 0 # Less than 1
  }

  # Reference the module
  module {
    source = "../../modules/search"
  }

  # Expect this to fail because of the partition count validation
  expect_failures = [
    is_match(validation.var.partition_count.error_message, "Partition count must be at least 1."),
  ]
}

# Test case: Create Search service with standard SKU and multiple replicas
run "create_search_standard_with_replicas" {
  # Override variables for a more production-like setup
  variables {
    sku = "standard"
    replica_count = 3
  }
  
  # Define mock resources for this configuration
  mock_resource "azurerm_search_service" {
    defaults = {
      id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Search/searchServices/testsearch"
      name = "testsearch"
      resource_group_name = "test-rg"
      location = "eastus"
      sku = "standard"
      replica_count = 3
      partition_count = 1
      public_network_access_enabled = true
      primary_key = "primary-search-key"
      secondary_key = "secondary-search-key"
      tags = {
        Environment = "test"
        Project = "openai-chat"
        Provisioner = "Terraform"
      }
    }
  }

  # Reference the module
  module {
    source = "../../modules/search"
  }

  # This should pass with the production-ready configuration
}
