variable "name" {
  type        = string
  description = "Name of the OpenAI service"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region for the OpenAI service"
}

variable "sku_name" {
  type        = string
  description = "SKU name for the OpenAI service"
  default     = "S0"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the OpenAI service"
  default     = {}
}

variable "deployments" {
  type = list(object({
    name     = string
    model    = string
    version  = string
    capacity = number
  }))
  description = "List of model deployments to create"
  default     = []
}

variable "content_filter" {
  type = object({
    hate      = string
    sexual    = string
    violence  = string
    self_harm = string
    profanity = string
    jailbreak = string
  })
  description = "Content filter settings for the OpenAI service"
  default = {
    hate      = "medium"
    sexual    = "medium"
    violence  = "medium"
    self_harm = "medium"
    profanity = "medium"
    jailbreak = "medium"
  }
}

variable "customer_managed_key" {
  type = object({
    key_vault_key_id   = string
    identity_client_id = string
  })
  description = "Customer managed key settings for the OpenAI service"
  default     = null
}
