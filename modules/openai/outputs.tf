output "id" {
  description = "ID of the OpenAI service"
  value       = azurerm_cognitive_account.openai.id
}

output "endpoint" {
  description = "Endpoint of the OpenAI service"
  value       = azurerm_cognitive_account.openai.endpoint
}

output "primary_key" {
  description = "Primary key of the OpenAI service"
  value       = azurerm_cognitive_account.openai.primary_access_key
  sensitive   = true
}

output "principal_id" {
  description = "Principal ID of the OpenAI service managed identity"
  value       = azurerm_cognitive_account.openai.identity[0].principal_id
}

output "deployment_ids" {
  description = "Map of deployment names to deployment IDs"
  value       = { for name, deployment in azurerm_cognitive_deployment.model_deployments : name => deployment.id }
}
