# Azure OpenAI End-to-End Chat Reference Architecture
# Main configuration file

# Resource Group
module "resource_group" {
  source   = "./modules/resource_group"
  name     = "${var.prefix}-${var.environment}-rg"
  location = var.location
  tags     = local.common_tags
}

# Application Insights and Azure Monitor
module "monitoring" {
  source              = "./modules/monitoring"
  name                = "${var.prefix}-${var.environment}-ai"
  resource_group_name = module.resource_group.name
  location            = var.location
  tags                = local.common_tags
}

# Key Vault
module "key_vault" {
  source              = "./modules/key_vault"
  name                = "${var.prefix}${var.environment}kv"
  resource_group_name = module.resource_group.name
  location            = var.location
  tags                = local.common_tags
  network_acls = {
    bypass                     = "AzureServices"
    default_action             = "Allow"  # Allow access from all networks for this basic architecture
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }
}

# Storage Account
module "storage" {
  source              = "./modules/storage"
  name                = "${var.prefix}${var.environment}st"
  resource_group_name = module.resource_group.name
  location            = var.location
  tags                = local.common_tags
}

# Container Registry
module "container_registry" {
  source              = "./modules/container_registry"
  name                = "${var.prefix}${var.environment}cr"
  resource_group_name = module.resource_group.name
  location            = var.location
  sku                 = "Basic"  # Basic tier as per reference architecture
  tags                = local.common_tags
}

# OpenAI Service
module "openai" {
  source              = "./modules/openai"
  name                = "${var.prefix}-${var.environment}-openai"
  resource_group_name = module.resource_group.name
  location            = var.location
  sku_name            = "S0"
  tags                = local.common_tags
  deployments         = var.openai_deployments
  content_filter      = var.openai_content_filter
}

# AI Search
module "search" {
  source              = "./modules/search"
  name                = "${var.prefix}-${var.environment}-search"
  resource_group_name = module.resource_group.name
  location            = var.location
  sku                 = "basic"  # Basic tier as per reference architecture
  tags                = local.common_tags
}

# AI Foundry Hub and Project
module "ai_foundry" {
  source              = "./modules/ai_foundry"
  hub_name            = "${var.prefix}-${var.environment}-aihub"
  project_name        = "${var.prefix}-${var.environment}-aiproject"
  resource_group_name = module.resource_group.name
  location            = var.location
  tags                = local.common_tags
  storage_id          = module.storage.id
  container_registry_id = module.container_registry.id
  key_vault_id        = module.key_vault.id
  openai_id           = module.openai.id
  search_id           = module.search.id
  application_insights_id = module.monitoring.application_insights_id
}

# Azure ML with Managed Online Endpoint
module "azure_ml" {
  source              = "./modules/azure_ml"
  name                = "${var.prefix}-${var.environment}-ml"
  resource_group_name = module.resource_group.name
  location            = var.location
  tags                = local.common_tags
  storage_id          = module.storage.id
  container_registry_id = module.container_registry.id
  application_insights_id = module.monitoring.application_insights_id
  ai_foundry_hub_id   = module.ai_foundry.hub_id
  ai_foundry_project_id = module.ai_foundry.project_id
  endpoint_name       = "${var.prefix}-${var.environment}-endpoint"
  deployment_name     = "${var.prefix}-${var.environment}-deployment"
  instance_type       = "Standard_DS3_v2"  # Appropriate instance for basic deployment
  instance_count      = 1                  # Single instance as per basic architecture
}

# App Service
module "app_service" {
  source              = "./modules/app_service"
  name                = "${var.prefix}-${var.environment}-app"
  resource_group_name = module.resource_group.name
  location            = var.location
  tags                = local.common_tags
  sku_name            = "B1"  # Basic tier as per reference architecture
  key_vault_id        = module.key_vault.id
  application_insights_id = module.monitoring.application_insights_id
  endpoint_id         = module.azure_ml.endpoint_id
  endpoint_key        = module.azure_ml.endpoint_key
}
