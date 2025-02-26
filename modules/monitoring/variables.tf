variable "name" {
  type        = string
  description = "Name of the Application Insights instance"
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{3,63}$", var.name))
    error_message = "Application Insights name must be between 3 and 63 characters, containing only alphanumeric characters and hyphens."
  }
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  description = "Azure region for the Application Insights"
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply to the monitoring resources"
  default     = {}
}

variable "log_analytics_sku" {
  type        = string
  description = "SKU of the Log Analytics Workspace"
  default     = "PerGB2018"
  
  validation {
    condition     = contains(["Free", "PerNode", "Premium", "Standard", "Standalone", "Unlimited", "CapacityReservation", "PerGB2018"], var.log_analytics_sku)
    error_message = "Log Analytics SKU must be one of: Free, PerNode, Premium, Standard, Standalone, Unlimited, CapacityReservation, PerGB2018."
  }
}

variable "log_retention_days" {
  type        = number
  description = "Retention days for the logs"
  default     = 30
  
  validation {
    condition     = var.log_retention_days >= 30 && var.log_retention_days <= 730
    error_message = "Log retention days must be between 30 and 730."
  }
}

variable "sampling_percentage" {
  type        = number
  description = "Sampling percentage for Application Insights"
  default     = 100
  
  validation {
    condition     = var.sampling_percentage >= 0 && var.sampling_percentage <= 100
    error_message = "Sampling percentage must be between 0 and 100."
  }
}

variable "enable_basic_alerts" {
  type        = bool
  description = "Enable basic alerts for the application"
  default     = false
}

variable "alert_email_addresses" {
  type        = list(string)
  description = "Email addresses for alerts"
  default     = []
  
  validation {
    condition     = alltrue([for email in var.alert_email_addresses : can(regex("^[^@]+@[^@]+\\.[^@]+$", email))])
    error_message = "All email addresses must be valid."
  }
}

variable "server_exceptions_threshold" {
  type        = number
  description = "Threshold for server exceptions alert"
  default     = 5
}

variable "failed_requests_threshold" {
  type        = number
  description = "Threshold for failed requests alert"
  default     = 5
}

variable "response_time_threshold" {
  type        = number
  description = "Threshold for response time alert (in milliseconds)"
  default     = 5000
}

variable "create_dashboard" {
  type        = bool
  description = "Create a dashboard for the application"
  default     = false
}
