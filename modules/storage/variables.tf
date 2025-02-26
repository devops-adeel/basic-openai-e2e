variable "name" {
  type        = string
  description = "Name of the storage account"
  
  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "Storage account name must be between 3 and 24 characters, contain only lowercase letters and numbers."
  }
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region for the storage account"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the storage account"
  default     = {}
}

variable "account_tier" {
  type        = string
  description = "Tier of the storage account"
  default     = "Standard"
  
  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "Account tier must be either 'Standard' or 'Premium'."
  }
}

variable "account_replication_type" {
  type        = string
  description = "Replication type of the storage account"
  default     = "LRS"
  
  validation {
    condition     = contains(["LRS", "GRS", "RAGRS", "ZRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "Account replication type must be one of: LRS, GRS, RAGRS, ZRS, GZRS, or RAGZRS."
  }
}

variable "account_kind" {
  type        = string
  description = "Kind of the storage account"
  default     = "StorageV2"
  
  validation {
    condition     = contains(["Storage", "StorageV2", "BlobStorage", "BlockBlobStorage", "FileStorage"], var.account_kind)
    error_message = "Account kind must be one of: Storage, StorageV2, BlobStorage, BlockBlobStorage, or FileStorage."
  }
}

variable "soft_delete_retention_days" {
  type        = number
  description = "Number of days to retain deleted blobs"
  default     = 7
  
  validation {
    condition     = var.soft_delete_retention_days >= 1 && var.soft_delete_retention_days <= 365
    error_message = "Soft delete retention days must be between 1 and 365."
  }
}

variable "enable_versioning" {
  type        = bool
  description = "Enable blob versioning"
  default     = true
}
