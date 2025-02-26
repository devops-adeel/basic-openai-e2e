# Output Values

output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.resource_group.name
}

output "app_service_url" {
  description = "URL of the App Service"
  value       = module.app_service.default_site_hostname
}

output "app_service_principal_id" {
  description = "Principal ID of the App Service managed identity"
  value       = module.app_service.principal_id
}

output "ai_foundry_hub_id" {
  description = "ID of the AI Foundry Hub"
  value       = module.ai_foundry.hub_id
}

output "ai_foundry_project_id" {
  description = "ID of the AI Foundry Project"
  value       = module.ai_foundry.project_id
}

output "ai_foundry_hub_principal_id" {
  description = "Principal ID of the AI Foundry Hub managed identity"
  value       = module.ai_foundry.hub_principal_id
}

output "ai_foundry_project_principal_id" {
  description = "Principal ID of the AI Foundry Project managed identity"
  value       = module.ai_foundry.project_principal_id
}

output "azure_ml_workspace_id" {
  description = "ID of the Azure ML workspace"
  value       = module.azure_ml.workspace_id
}

output "azure_ml_endpoint_id" {
  description = "ID of the Azure ML managed online endpoint"
  value       = module.azure_ml.endpoint_id
}

output "azure_ml_endpoint_scoring_uri" {
  description = "Scoring URI of the Azure ML managed online endpoint"
  value       = module.azure_ml.endpoint_scoring_uri
}

output "openai_endpoint" {
  description = "Endpoint of the OpenAI service"
  value       = module.openai.endpoint
}

output "search_endpoint" {
  description = "Endpoint of the AI Search service"
  value       = module.search.endpoint
}

output "application_insights_instrumentation_key" {
  description = "Instrumentation key for Application Insights"
  value       = module.monitoring.instrumentation_key
  sensitive   = true
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = module.key_vault.vault_uri
}
