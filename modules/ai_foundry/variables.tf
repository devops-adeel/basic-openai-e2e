variable "hub_name" {
  type        = string
  description = "Name of the AI Foundry Hub"
}

variable "project_name" {
  type        = string
  description = "Name of the AI Foundry Project"
}

variable "project_display_name" {
  type        = string
  description = "Display name of the AI Foundry Project"
  default     = null
}

variable "project_description" {
  type        = string
  description = "Description of the AI Foundry Project"
  default     = "AI Foundry project for chat application"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region for the AI Foundry resources"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the AI Foundry resources"
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

variable "key_vault_id" {
  type        = string
  description = "ID of the Key Vault"
}

variable "openai_id" {
  type        = string
  description = "ID of the OpenAI service"
  default     = null
}

variable "search_id" {
  type        = string
  description = "ID of the AI Search service"
  default     = null
}

variable "application_insights_id" {
  type        = string
  description = "ID of the Application Insights instance"
  default     = null
}
