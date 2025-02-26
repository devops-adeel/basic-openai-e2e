output "id" {
  description = "ID of the App Service"
  value       = azurerm_linux_web_app.this.id
}

output "name" {
  description = "Name of the App Service"
  value       = azurerm_linux_web_app.this.name
}

output "default_site_hostname" {
  description = "Default hostname of the App Service"
  value       = azurerm_linux_web_app.this.default_hostname
}

output "principal_id" {
  description = "Principal ID of the App Service managed identity"
  value       = azurerm_linux_web_app.this.identity[0].principal_id
}

output "plan_id" {
  description = "ID of the App Service Plan"
  value       = azurerm_service_plan.this.id
}
