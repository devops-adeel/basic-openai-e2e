output "id" {
  description = "ID of the storage account"
  value       = azurerm_storage_account.this.id
}

output "name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.this.name
}

output "primary_access_key" {
  description = "Primary access key of the storage account"
  value       = azurerm_storage_account.this.primary_access_key
  sensitive   = true
}

output "primary_blob_endpoint" {
  description = "Primary blob endpoint of the storage account"
  value       = azurerm_storage_account.this.primary_blob_endpoint
}

output "primary_connection_string" {
  description = "Primary connection string of the storage account"
  value       = azurerm_storage_account.this.primary_connection_string
  sensitive   = true
}

output "principal_id" {
  description = "Principal ID of the storage account managed identity"
  value       = azurerm_storage_account.this.identity[0].principal_id
}

output "prompt_flows_container_name" {
  description = "Name of the prompt flows container"
  value       = azurerm_storage_container.prompt_flows.name
}

output "connections_container_name" {
  description = "Name of the connections container"
  value       = azurerm_storage_container.connections.name
}

output "models_container_name" {
  description = "Name of the models container"
  value       = azurerm_storage_container.models.name
}
