output "id" {
  description = "ID of the container registry"
  value       = azurerm_container_registry.this.id
}

output "name" {
  description = "Name of the container registry"
  value       = azurerm_container_registry.this.name
}

output "login_server" {
  description = "Login server of the container registry"
  value       = azurerm_container_registry.this.login_server
}

output "admin_username" {
  description = "Admin username of the container registry"
  value       = var.admin_enabled ? azurerm_container_registry.this.admin_username : null
}

output "admin_password" {
  description = "Admin password of the container registry"
  value       = var.admin_enabled ? azurerm_container_registry.this.admin_password : null
  sensitive   = true
}

output "principal_id" {
  description = "Principal ID of the container registry managed identity"
  value       = azurerm_container_registry.this.identity[0].principal_id
}
