output "id" {
  description = "ID of the Search service"
  value       = azurerm_search_service.this.id
}

output "name" {
  description = "Name of the Search service"
  value       = azurerm_search_service.this.name
}

output "endpoint" {
  description = "Endpoint of the Search service"
  value       = "https://${azurerm_search_service.this.name}.search.windows.net"
}

output "primary_key" {
  description = "Primary key of the Search service"
  value       = azurerm_search_service.this.primary_key
  sensitive   = true
}
