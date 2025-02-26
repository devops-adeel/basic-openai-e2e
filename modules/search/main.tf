# AI Search Module

resource "azurerm_search_service" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  replica_count       = var.replica_count
  partition_count     = var.partition_count
  tags                = var.tags

  # Basic tier does not support private endpoints
  public_network_access_enabled = true
}

# Validate Search Service configuration
check "search_naming_convention" {
  assert {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{1,59}[a-zA-Z0-9]$", var.name))
    error_message = "Search service name must use only letters, numbers, and hyphens. It must start and end with a letter or number and be between 2 and 60 characters."
  }
}

check "search_sku" {
  assert {
    condition     = contains(["free", "basic", "standard", "standard2", "standard3", "storage_optimized_l1", "storage_optimized_l2"], lower(var.sku))
    error_message = "Search SKU must be one of: free, basic, standard, standard2, standard3, storage_optimized_l1, or storage_optimized_l2."
  }
}

check "search_replica_count" {
  assert {
    condition     = var.replica_count >= 1
    error_message = "Search replica count must be at least 1."
  }
}

check "search_partition_count" {
  assert {
    condition     = var.partition_count >= 1
    error_message = "Search partition count must be at least 1."
  }
}
