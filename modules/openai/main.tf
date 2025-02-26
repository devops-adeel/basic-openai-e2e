# Azure OpenAI Service Module

resource "azurerm_cognitive_account" "openai" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "OpenAI"
  sku_name            = var.sku_name
  tags                = var.tags

  # Enable system-assigned managed identity
  identity {
    type = "SystemAssigned"
  }

  # Configure content filtering
  custom_subdomain_name = lower(var.name)
  dynamic "customer_managed_key" {
    for_each = var.customer_managed_key != null ? [1] : []
    content {
      key_vault_key_id = var.customer_managed_key.key_vault_key_id
      identity_client_id = var.customer_managed_key.identity_client_id
    }
  }
}

# Validate OpenAI service configuration
check "openai_naming_convention" {
  assert {
    condition     = can(regex("^[a-z0-9]([a-z0-9-]{1,61}[a-z0-9])?$", var.name))
    error_message = "OpenAI service name must use only lowercase letters, numbers, and hyphens. It must start and end with a letter or number and be between 3 and 63 characters."
  }
}

check "openai_has_system_identity" {
  assert {
    condition     = contains(keys(azurerm_cognitive_account.openai.identity[0]), "principal_id")
    error_message = "OpenAI service must have a system-assigned managed identity."
  }
}

check "openai_content_filter_settings" {
  assert {
    condition     = contains(["low", "medium", "high"], var.content_filter.hate) &&
                    contains(["low", "medium", "high"], var.content_filter.sexual) &&
                    contains(["low", "medium", "high"], var.content_filter.violence)
    error_message = "Content filter settings for hate, sexual, and violence must be set to 'low', 'medium', or 'high'."
  }
}

# Create Azure OpenAI model deployments
resource "azurerm_cognitive_deployment" "model_deployments" {
  for_each = { for idx, deployment in var.deployments : deployment.name => deployment }

  name                 = each.value.name
  cognitive_account_id = azurerm_cognitive_account.openai.id

  model {
    name    = each.value.model
    version = each.value.version
    format  = "OpenAI"
  }

  scale {
    type     = "Standard"
    capacity = each.value.capacity
  }

  # Configure content filtering based on parameters
  content_filter {
    dynamic "hate" {
      for_each = var.content_filter.hate != null ? [1] : []
      content {
        severity_level = var.content_filter.hate
      }
    }

    dynamic "sexual" {
      for_each = var.content_filter.sexual != null ? [1] : []
      content {
        severity_level = var.content_filter.sexual
      }
    }

    dynamic "violence" {
      for_each = var.content_filter.violence != null ? [1] : []
      content {
        severity_level = var.content_filter.violence
      }
    }

    dynamic "self_harm" {
      for_each = var.content_filter.self_harm != null ? [1] : []
      content {
        severity_level = var.content_filter.self_harm
      }
    }

    dynamic "profanity" {
      for_each = var.content_filter.profanity != null ? [1] : []
      content {
        severity_level = var.content_filter.profanity
      }
    }

    dynamic "jailbreak" {
      for_each = var.content_filter.jailbreak != null ? [1] : []
      content {
        severity_level = var.content_filter.jailbreak
      }
    }
  }
}
