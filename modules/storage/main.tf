# Storage Account Module

resource "azurerm_storage_account" "this" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind             = var.account_kind
  tags                     = var.tags

  # Security settings
  min_tls_version                 = "TLS1_2"
  enable_https_traffic_only       = true
  allow_nested_items_to_be_public = false

  # Blob storage configuration
  blob_properties {
    delete_retention_policy {
      days = var.soft_delete_retention_days
    }
    container_delete_retention_policy {
      days = var.soft_delete_retention_days
    }
    versioning_enabled = var.enable_versioning
  }

  # Queue properties (for logging)
  queue_properties {
    logging {
      delete                = true
      read                  = true
      write                 = true
      version               = "1.0"
      retention_policy_days = 7
    }
  }

  # Identity
  identity {
    type = "SystemAssigned"
  }

  # For basic architecture use public access, but in production should use private endpoints
  public_network_access_enabled = true
}

# Storage Container for AI Foundry prompt flows
resource "azurerm_storage_container" "prompt_flows" {
  name                  = "prompt-flows"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

# Storage Container for AI Foundry connections
resource "azurerm_storage_container" "connections" {
  name                  = "connections"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

# Storage Container for ML deployed models
resource "azurerm_storage_container" "models" {
  name                  = "models"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

# Check storage account configuration
check "storage_secure_transfer" {
  assert {
    condition     = azurerm_storage_account.this.enable_https_traffic_only == true
    error_message = "Storage account must have secure transfer enabled."
  }
}

check "storage_minimum_tls" {
  assert {
    condition     = azurerm_storage_account.this.min_tls_version == "TLS1_2"
    error_message = "Storage account must use TLS 1.2 at minimum."
  }
}

check "storage_blob_retention" {
  assert {
    condition     = azurerm_storage_account.this.blob_properties[0].delete_retention_policy[0].days >= 7
    error_message = "Storage account blob retention must be at least 7 days."
  }
}

check "storage_private_containers" {
  assert {
    condition     = azurerm_storage_container.prompt_flows.container_access_type == "private" &&
                    azurerm_storage_container.connections.container_access_type == "private" &&
                    azurerm_storage_container.models.container_access_type == "private"
    error_message = "All storage containers must have private access type."
  }
}
