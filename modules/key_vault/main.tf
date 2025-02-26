# Key Vault Module

resource "azurerm_key_vault" "this" {
  name                       = var.name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = var.sku_name
  tags                       = var.tags
  purge_protection_enabled   = var.purge_protection_enabled
  soft_delete_retention_days = var.soft_delete_retention_days
  enable_rbac_authorization  = var.enable_rbac_authorization

  # Network ACLs - for the basic architecture, allow access from all networks
  dynamic "network_acls" {
    for_each = var.network_acls != null ? [var.network_acls] : []
    content {
      bypass                     = network_acls.value.bypass
      default_action             = network_acls.value.default_action
      ip_rules                   = network_acls.value.ip_rules
      virtual_network_subnet_ids = network_acls.value.virtual_network_subnet_ids
    }
  }
}

# Get current client configuration for access policies
data "azurerm_client_config" "current" {}

# Validate Key Vault configuration
check "key_vault_naming_convention" {
  assert {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{1,22}$", var.name))
    error_message = "Key Vault name must use only letters, numbers, and hyphens. It must start with a letter and be between 3 and 24 characters."
  }
}

check "key_vault_soft_delete" {
  assert {
    condition     = var.soft_delete_retention_days >= 7
    error_message = "Key Vault soft delete retention days must be at least 7 days."
  }
}

check "key_vault_sku" {
  assert {
    condition     = contains(["standard", "premium"], lower(var.sku_name))
    error_message = "Key Vault SKU must be either 'standard' or 'premium'."
  }
}
