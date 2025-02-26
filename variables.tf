# Input Variables

variable "prefix" {
  type        = string
  description = "Prefix for all resources"
  default     = "openai"
}

variable "environment" {
  type        = string
  description = "Environment (dev, test, prod)"
  default     = "dev"
}

variable "location" {
  type        = string
  description = "Azure region for all resources"
  default     = "eastus"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to all resources"
  default     = {}
}

variable "openai_deployments" {
  type = list(object({
    name  = string
    model = string
    version = string
    capacity = number
  }))
  description = "OpenAI model deployments to create"
  default = [
    {
      name     = "gpt-35-turbo"
      model    = "gpt-35-turbo"
      version  = "0613"
      capacity = 1
    }
  ]
}

variable "openai_content_filter" {
  type = object({
    hate = string
    sexual = string
    violence = string
    self_harm = string
    profanity = string
    jailbreak = string
  })
  description = "Content filter settings for OpenAI"
  default = {
    hate      = "high"
    sexual    = "high"
    violence  = "high"
    self_harm = "high" 
    profanity = "high"
    jailbreak = "high"
  }
}
