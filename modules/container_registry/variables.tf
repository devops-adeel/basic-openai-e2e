variable "name" {
  type        = string
  description = "Name of the container registry"
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9]{5,50}$", var.name))
    error_message = "Container registry name must be between 5 and 50 characters, containing only alphanumeric characters."
  }
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region for the container registry"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the container registry"
  default     = {}
}

variable "sku" {
  type        = string
  description = "SKU for the container registry"
  default     = "Basic"
  
  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "SKU must be one of: Basic, Standard, Premium."
  }
}

variable "admin_enabled" {
  type        = bool
  description = "Enable admin user for the container registry"
  default     = false
}

variable "encryption_key_vault_key_id" {
  type        = string
  description = "Key Vault key ID for encryption (Premium SKU only)"
  default     = null
}

variable "encryption_identity_id" {
  type        = string
  description = "Identity client ID for encryption (Premium SKU only)"
  default     = null
}

variable "georeplication_locations" {
  type        = list(string)
  description = "List of locations for geo-replication (Premium SKU only)"
  default     = []
}

variable "zone_redundancy_enabled" {
  type        = bool
  description = "Enable zone redundancy for geo-replicated locations (Premium SKU only)"
  default     = false
}

variable "network_rule_set" {
  type = object({
    default_action          = string
    ip_rules                = list(string)
    virtual_network_subnets = list(string)
  })
  description = "Network rule set for the container registry (Premium SKU only)"
  default     = null
  
  validation {
    condition     = var.network_rule_set == null || contains(["Allow", "Deny"], var.network_rule_set.default_action)
    error_message = "Default action must be either 'Allow' or 'Deny'."
  }
}
