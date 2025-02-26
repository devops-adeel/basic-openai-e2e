# Resource Group Module

resource "azurerm_resource_group" "this" {
  name     = var.name
  location = var.location
  tags     = var.tags
}

# Validate resource group configuration
check "resource_group_naming_convention" {
  assert {
    condition     = length(var.name) >= 3 && length(var.name) <= 63
    error_message = "Resource group name must be between 3 and 63 characters."
  }
}

check "resource_group_location" {
  assert {
    condition     = contains(["eastus", "eastus2", "westus", "westus2", "northeurope", "westeurope"], var.location)
    error_message = "Resource group must be deployed in an approved region."
  }
}

check "resource_group_required_tags" {
  assert {
    condition     = contains(keys(var.tags), "Environment")
    error_message = "Environment tag is required for all resource groups."
  }
}
