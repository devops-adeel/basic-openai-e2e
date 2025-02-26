variable "name" {
  type        = string
  description = "Name of the Azure ML workspace"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region for the Azure ML workspace"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the Azure ML workspace"
  default     = {}
}

variable "storage_id" {
  type        = string
  description = "ID of the Storage Account"
}

variable "container_registry_id" {
  type        = string
  description = "ID of the Container Registry"
}

variable "application_insights_id" {
  type        = string
  description = "ID of the Application Insights instance"
  default     = null
}

variable "key_vault_id" {
  type        = string
  description = "ID of the Key Vault"
  default     = null
}

variable "ai_foundry_hub_id" {
  type        = string
  description = "ID of the AI Foundry Hub"
}

variable "ai_foundry_project_id" {
  type        = string
  description = "ID of the AI Foundry Project"
}

variable "endpoint_name" {
  type        = string
  description = "Name of the Azure ML managed online endpoint"
}

variable "deployment_name" {
  type        = string
  description = "Name of the Azure ML deployment"
}

variable "instance_type" {
  type        = string
  description = "Azure ML compute instance type"
  default     = "Standard_DS3_v2"
  
  validation {
    condition     = startswith(var.instance_type, "Standard_")
    error_message = "Instance type must be a Standard VM size."
  }
}

variable "instance_count" {
  type        = number
  description = "Number of instances to deploy"
  default     = 1
  
  validation {
    condition     = var.instance_count > 0
    error_message = "Instance count must be greater than 0."
  }
}
