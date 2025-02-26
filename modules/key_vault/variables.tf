variable "name" {
  type        = string
  description = "Name of the Key Vault"
  
  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{1,22}$", var.name))
    error_message = "Key Vault name must use only letters, numbers, and hyphens. It must start with a letter and be between 3 and 24 characters."
  }
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region for the Key Vault"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the Key Vault"
  default     = {}
}

variable "sku_name" {
  type        = string
  description = "SKU name for the Key Vault"
  default     = "standard"
  
  validation {
    condition     = contains(["standard", "premium"], lower(var.sku_name))
    error_message = "SKU name must be either 'standard' or 'premium'."
  }
}

variable "purge_protection_enabled" {
  type        = bool
  description = "Enable purge protection for the Key Vault"
  default     = false
}

variable "soft_delete_retention_days" {
  type        = number
  description = "Soft delete retention days for the Key Vault"
  default     = 7
  
  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "Soft delete retention days must be between 7 and 90 days."
  }
}

variable "enable_rbac_authorization" {
  type        = bool
  description = "Enable RBAC authorization for the Key Vault"
  default     = true
}

variable "network_acls" {
  type = object({
    bypass                     = string
    default_action             = string
    ip_rules                   = list(string)
    virtual_network_subnet_ids = list(string)
  })
  description = "Network ACLs for the Key Vault"
  default     = null
}
