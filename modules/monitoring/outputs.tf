output "application_insights_id" {
  description = "ID of the Application Insights instance"
  value       = azurerm_application_insights.this.id
}

output "application_insights_name" {
  description = "Name of the Application Insights instance"
  value       = azurerm_application_insights.this.name
}

output "instrumentation_key" {
  description = "Instrumentation key of the Application Insights instance"
  value       = azurerm_application_insights.this.instrumentation_key
  sensitive   = true
}

output "app_id" {
  description = "App ID of the Application Insights instance"
  value       = azurerm_application_insights.this.app_id
}

output "connection_string" {
  description = "Connection string of the Application Insights instance"
  value       = azurerm_application_insights.this.connection_string
  sensitive   = true
}

output "log_analytics_workspace_id" {
  description = "ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.this.id
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.this.name
}

output "log_analytics_workspace_primary_key" {
  description = "Primary key of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.this.primary_shared_key
  sensitive   = true
}

output "log_analytics_workspace_secondary_key" {
  description = "Secondary key of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.this.secondary_shared_key
  sensitive   = true
}

output "dashboard_id" {
  description = "ID of the dashboard (if created)"
  value       = var.create_dashboard ? azurerm_portal_dashboard.this[0].id : null
}
