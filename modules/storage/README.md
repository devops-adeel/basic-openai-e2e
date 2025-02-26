# Azure Storage Account Module

This module provisions an Azure Storage Account with containers configured for AI Foundry and Azure ML workloads.

## Features

- Creates a storage account with secure defaults
- Sets up containers for prompt flows, connections, and ML models
- Configures soft delete retention policies
- Enables identity with a system-assigned managed identity
- Enforces TLS 1.2 and HTTPS-only traffic

## Usage

```hcl
module "storage" {
  source              = "./modules/storage"
  name                = "openaidevst"
  resource_group_name = module.resource_group.name
  location            = var.location
  tags                = var.tags
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.7.0 |
| azurerm | ~> 3.85.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of the storage account | `string` | n/a | yes |
| resource_group_name | Name of the resource group | `string` | n/a | yes |
| location | Azure region for the storage account | `string` | n/a | yes |
| tags | Tags to apply to the storage account | `map(string)` | `{}` | no |
| account_tier | Tier of the storage account | `string` | `"Standard"` | no |
| account_replication_type | Replication type of the storage account | `string` | `"LRS"` | no |
| account_kind | Kind of the storage account | `string` | `"StorageV2"` | no |
| soft_delete_retention_days | Number of days to retain deleted blobs | `number` | `7` | no |
| enable_versioning | Enable blob versioning | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | ID of the storage account |
| name | Name of the storage account |
| primary_access_key | Primary access key of the storage account |
| primary_blob_endpoint | Primary blob endpoint of the storage account |
| primary_connection_string | Primary connection string of the storage account |
| principal_id | Principal ID of the storage account managed identity |
| prompt_flows_container_name | Name of the prompt flows container |
| connections_container_name | Name of the connections container |
| models_container_name | Name of the models container |

## Notes

- For the basic architecture, public network access is enabled.
- In a production environment, consider:
  - Using private endpoints
  - Implementing network rules
  - Enabling advanced threat protection
  - Configuring customer-managed keys for encryption
