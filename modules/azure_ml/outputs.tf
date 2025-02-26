output "workspace_id" {
  description = "ID of the Azure ML workspace"
  value       = azurerm_machine_learning_workspace.this.id
}

output "workspace_name" {
  description = "Name of the Azure ML workspace"
  value       = azurerm_machine_learning_workspace.this.name
}

output "workspace_principal_id" {
  description = "Principal ID of the Azure ML workspace managed identity"
  value       = azurerm_machine_learning_workspace.this.identity[0].principal_id
}

output "endpoint_id" {
  description = "ID of the Azure ML managed online endpoint"
  value       = azurerm_machine_learning_online_endpoint.this.id
}

output "endpoint_name" {
  description = "Name of the Azure ML managed online endpoint"
  value       = azurerm_machine_learning_online_endpoint.this.name
}

output "endpoint_scoring_uri" {
  description = "Scoring URI of the Azure ML managed online endpoint"
  value       = azurerm_machine_learning_online_endpoint.this.scoring_uri
}

output "endpoint_principal_id" {
  description = "Principal ID of the Azure ML managed online endpoint managed identity"
  value       = azurerm_machine_learning_online_endpoint.this.identity[0].principal_id
}

output "endpoint_key" {
  description = "Key of the Azure ML managed online endpoint"
  value       = azurerm_machine_learning_online_endpoint.this.key
  sensitive   = true
}

output "deployment_id" {
  description = "ID of the Azure ML deployment"
  value       = azurerm_machine_learning_online_deployment.this.id
}
