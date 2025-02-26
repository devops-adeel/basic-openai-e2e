# Container Registry Module

resource "azurerm_container_registry" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = var.admin_enabled
  tags                = var.tags

  # Enable system-assigned managed identity
  identity {
    type = "SystemAssigned"
  }

  # Enable data encryption (only available for Premium SKU)
  dynamic "encryption" {
    for_each = var.sku == "Premium" && var.encryption_key_vault_key_id != null ? [1] : []
    content {
      enabled            = true
      key_vault_key_id   = var.encryption_key_vault_key_id
      identity_client_id = var.encryption_identity_id
    }
  }

  # Geo-replication (only available for Premium SKU)
  dynamic "georeplications" {
    for_each = var.sku == "Premium" && length(var.georeplication_locations) > 0 ? var.georeplication_locations : []
    content {
      location                = georeplications.value
      zone_redundancy_enabled = var.zone_redundancy_enabled
      tags                    = var.tags
    }
  }

  # Network rules (only available for Premium SKU)
  dynamic "network_rule_set" {
    for_each = var.sku == "Premium" && var.network_rule_set != null ? [var.network_rule_set] : []
    content {
      default_action = network_rule_set.value.default_action

      dynamic "ip_rule" {
        for_each = network_rule_set.value.ip_rules
        content {
          action   = "Allow"
          ip_range = ip_rule.value
        }
      }

      dynamic "virtual_network" {
        for_each = network_rule_set.value.virtual_network_subnets
        content {
          action    = "Allow"
          subnet_id = virtual_network.value
        }
      }
    }
  }

  # For basic architecture, we use public access
  # For production, use private endpoints and network rules
  public_network_access_enabled = true
}

# Check Container Registry configuration
check "acr_naming_convention" {
  assert {
    condition     = can(regex("^[a-zA-Z0-9]{5,50}$", var.name))
    error_message = "Container registry name must be between 5 and 50 characters, containing only alphanumeric characters."
  }
}

check "acr_sku_validation" {
  assert {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "Container registry SKU must be one of: Basic, Standard, Premium."
  }
}

check "acr_managed_identity" {
  assert {
    condition     = length(azurerm_container_registry.this.identity) > 0 && azurerm_container_registry.this.identity[0].type == "SystemAssigned"
    error_message = "Container registry must have a system-assigned managed identity."
  }
}
