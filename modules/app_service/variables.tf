variable "name" {
  type        = string
  description = "Name of the App Service"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region for the App Service"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the App Service"
  default     = {}
}

variable "sku_name" {
  type        = string
  description = "SKU name for the App Service Plan"
  default     = "B1"
}

variable "key_vault_id" {
  type        = string
  description = "ID of the Key Vault to store secrets"
}

variable "application_insights_id" {
  type        = string
  description = "ID of the Application Insights instance"
  default     = null
}

variable "endpoint_id" {
  type        = string
  description = "ID of the Azure ML managed online endpoint"
  default     = null
}

variable "endpoint_key" {
  type        = string
  description = "Key for the Azure ML managed online endpoint"
  default     = null
  sensitive   = true
}

variable "entra_client_id" {
  type        = string
  description = "Client ID for Microsoft Entra ID authentication"
  default     = null
}

variable "microsoft_provider_authentication_secret" {
  type        = string
  description = "Authentication secret for Microsoft Entra ID"
  default     = null
  sensitive   = true
}
