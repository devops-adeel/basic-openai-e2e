variable "name" {
  type        = string
  description = "Name of the Search service"
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{1,59}[a-zA-Z0-9]$", var.name))
    error_message = "Search service name must use only letters, numbers, and hyphens. It must start and end with a letter or number and be between 2 and 60 characters."
  }
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region for the Search service"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the Search service"
  default     = {}
}

variable "sku" {
  type        = string
  description = "SKU for the Search service"
  default     = "basic"
  
  validation {
    condition     = contains(["free", "basic", "standard", "standard2", "standard3", "storage_optimized_l1", "storage_optimized_l2"], lower(var.sku))
    error_message = "SKU must be one of: free, basic, standard, standard2, standard3, storage_optimized_l1, or storage_optimized_l2."
  }
}

variable "replica_count" {
  type        = number
  description = "Number of replicas for the Search service"
  default     = 1
  
  validation {
    condition     = var.replica_count >= 1
    error_message = "Replica count must be at least 1."
  }
}

variable "partition_count" {
  type        = number
  description = "Number of partitions for the Search service"
  default     = 1
  
  validation {
    condition     = var.partition_count >= 1
    error_message = "Partition count must be at least 1."
  }
}
