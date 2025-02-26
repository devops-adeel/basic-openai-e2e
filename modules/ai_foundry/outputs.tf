output "hub_id" {
  description = "ID of the AI Foundry Hub"
  value       = azurerm_machine_learning_hub.this.id
}

output "hub_principal_id" {
  description = "Principal ID of the AI Foundry Hub managed identity"
  value       = azurerm_machine_learning_hub.this.identity[0].principal_id
}

output "project_id" {
  description = "ID of the AI Foundry Project"
  value       = azurerm_machine_learning_project.this.id
}

output "project_principal_id" {
  description = "Principal ID of the AI Foundry Project managed identity"
  value       = azurerm_machine_learning_project.this.identity[0].principal_id
}

output "prompt_flow_id" {
  description = "ID of the sample prompt flow"
  value       = azurerm_machine_learning_prompt_flow.sample.id
}

output "openai_connection_id" {
  description = "ID of the OpenAI connection"
  value       = var.openai_id != null ? azurerm_machine_learning_connection.openai[0].id : null
}

output "search_connection_id" {
  description = "ID of the AI Search connection"
  value       = var.search_id != null ? azurerm_machine_learning_connection.search[0].id : null
}
