# Azure Container Registry Module

This module provisions an Azure Container Registry (ACR) for storing container images used by AI Foundry and Azure ML.

## Features

- Creates a container registry with configurable SKU
- Supports system-assigned managed identity
- Optional admin access for CI/CD integration
- Premium SKU features (when enabled):
  - Geo-replication for improved performance and availability
  - Private network access controls
  - Customer-managed keys for encryption

## Usage

```hcl
module "container_registry" {
  source              = "./modules/container_registry"
  name                = "openaidevacr"
  resource_group_name = module.resource_group.name
  location            = var.location
  sku                 = "Basic"
  tags                = var.tags
}
```

## Premium Configuration Example

```hcl
module "container_registry" {
  source                  = "./modules/container_registry"
  name                    = "openaidevacr"
  resource_group_name     = module.resource_group.name
  location                = var.location
  sku                     = "Premium"
  admin_enabled           = true
  georeplication_locations = ["eastus2", "westus2"]
  zone_redundancy_enabled = true
  network_rule_set = {
    default_action          = "Deny"
    ip_rules                = ["203.0.113.0/24"]
    virtual_network_subnets = [module.network.subnet_id]
  }
  tags                    = var.tags
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
| name | Name of the container registry | `string` | n/a | yes |
| resource_group_name | Name of the resource group | `string` | n/a | yes |
| location | Azure region for the container registry | `string` | n/a | yes |
| tags | Tags to apply to the container registry | `map(string)` | `{}` | no |
| sku | SKU for the container registry | `string` | `"Basic"` | no |
| admin_enabled | Enable admin user for the container registry | `bool` | `false` | no |
| encryption_key_vault_key_id | Key Vault key ID for encryption (Premium SKU only) | `string` | `null` | no |
| encryption_identity_id | Identity client ID for encryption (Premium SKU only) | `string` | `null` | no |
| georeplication_locations | List of locations for geo-replication (Premium SKU only) | `list(string)` | `[]` | no |
| zone_redundancy_enabled | Enable zone redundancy for geo-replicated locations (Premium SKU only) | `bool` | `false` | no |
| network_rule_set | Network rule set for the container registry (Premium SKU only) | `object` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | ID of the container registry |
| name | Name of the container registry |
| login_server | Login server of the container registry |
| admin_username | Admin username of the container registry |
| admin_password | Admin password of the container registry |
| principal_id | Principal ID of the container registry managed identity |

## Notes

- For the basic architecture, public network access is enabled.
- In a production environment, consider:
  - Using the Premium SKU for advanced security features
  - Implementing private endpoints
  - Using customer-managed keys for encryption
  - Enabling geo-replication for high availability
