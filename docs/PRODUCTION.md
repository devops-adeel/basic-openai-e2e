# Production Deployment Guide

This document provides guidance on adapting the basic Azure OpenAI Chat Reference Architecture for production use.

## Basic vs. Production Architecture

The basic architecture is designed for learning and POC purposes, while a production deployment requires additional considerations for security, reliability, and governance.

## Key Production Enhancements

### 1. High Availability and Resilience

#### App Service
- **Upgrade to Premium tier** (P1v2 or higher)
- **Deploy at least 3 instances** across availability zones
- **Enable auto-scaling** with appropriate rules
- **Configure health checks** for proactive monitoring

```hcl
# Example App Service configuration for production
module "app_service" {
  source              = "./modules/app_service"
  name                = "${var.prefix}-${var.environment}-app"
  resource_group_name = module.resource_group.name
  location            = var.location
  sku_name            = "P1v2"  # Premium tier
  zone_redundant      = true    # Availability zone support
  autoscale_settings = {
    min_count            = 3
    max_count            = 10
    metric_name          = "CpuPercentage"
    metric_threshold     = 70
  }
}
```

#### Azure OpenAI
- **Deploy in multiple regions** for geo-redundancy
- **Use provisioned throughput** for predictable performance
- **Implement retry logic** in client applications

#### AI Search
- **Upgrade to Standard tier** or higher
- **Deploy at least 3 replicas** across availability zones
- **Configure replica count** for high availability

```hcl
# Example Search configuration for production
module "search" {
  source              = "./modules/search"
  name                = "${var.prefix}-${var.environment}-search"
  resource_group_name = module.resource_group.name
  location            = var.location
  sku                 = "standard"  # Standard tier for availability zones
  replica_count       = 3           # For high availability
  partition_count     = 2           # For improved performance
}
```

### 2. Network Security

#### Private Endpoints
- **Implement private endpoints** for all PaaS services
- **Create a hub-spoke network** architecture
- **Use Private DNS Zones** for name resolution

```hcl
# Example Private Endpoint configuration
resource "azurerm_private_endpoint" "openai" {
  name                = "${var.prefix}-${var.environment}-openai-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.prefix}-${var.environment}-openai-psc"
    private_connection_resource_id = module.openai.id
    is_manual_connection           = false
    subresource_names              = ["account"]
  }
  
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }
}
```

#### Network Security Groups
- **Implement NSGs** with appropriate rules
- **Use Application Security Groups** for logical grouping
- **Enable Azure DDoS Protection** for public endpoints

#### VNet Integration
- **Enable VNet Integration** for App Service
- **Restrict outbound traffic** with route tables
- **Use service endpoints** for Azure services

### 3. Data Protection

#### Key Vault
- **Enable purge protection** and soft-delete
- **Use customer-managed keys** for encryption
- **Restrict network access** with firewall rules

```hcl
# Example Key Vault configuration for production
module "key_vault" {
  source                  = "./modules/key_vault"
  name                    = "${var.prefix}${var.environment}kv"
  resource_group_name     = module.resource_group.name
  location                = var.location
  sku_name                = "premium"  # Premium for HSM-protected keys
  purge_protection_enabled = true
  soft_delete_retention_days = 90
  enable_rbac_authorization = true
  network_acls = {
    bypass                     = "AzureServices"
    default_action             = "Deny"
    ip_rules                   = var.trusted_ip_ranges
    virtual_network_subnet_ids = [var.subnet_id]
  }
}
```

#### Storage
- **Enable soft delete** for blobs and containers
- **Use customer-managed keys** for encryption
- **Enable versioning** for critical data
- **Configure firewall rules** to restrict access

### 4. Monitoring and Operations

#### Advanced Monitoring
- **Configure custom dashboards** in Azure Monitor
- **Set up proactive alerting** for key metrics
- **Implement Log Analytics workspaces** with proper retention
- **Use Azure Workbooks** for operational insights

```hcl
# Example monitoring configuration for production
module "monitoring" {
  source                    = "./modules/monitoring"
  name                      = "${var.prefix}-${var.environment}-ai"
  resource_group_name       = module.resource_group.name
  location                  = var.location
  log_retention_days        = 90
  enable_basic_alerts       = true
  alert_email_addresses     = ["ops@example.com", "security@example.com"]
  server_exceptions_threshold = 3
  failed_requests_threshold = 5
  response_time_threshold   = 3000
  create_dashboard          = true
}
```

#### CI/CD Integration
- **Implement blue-green deployments** for zero downtime
- **Use deployment slots** for App Service
- **Integrate with Azure DevOps** or GitHub Actions
- **Implement approval workflows** for production changes

### 5. Cost Management

#### Cost Optimization
- **Use reserved instances** for predictable workloads
- **Implement auto-scaling** to match demand
- **Set up budget alerts** in Azure Cost Management
- **Right-size resources** based on actual usage

#### Resource Organization
- **Implement resource tagging** for cost allocation
- **Use management groups** for policy enforcement
- **Create separate environments** (dev, test, prod)
- **Delegate responsibility** with RBAC

### 6. Compliance and Governance

#### Policy Enforcement
- **Implement Azure Policy** for guardrails
- **Use Sentinel policies** in Terraform Cloud
- **Enforce resource naming conventions**
- **Require specific resource configurations**

```hcl
# Example Sentinel policy rule
import "tfplan/v2" as tfplan

# All Key Vaults must have purge protection enabled
key_vaults = filter tfplan.resource_changes as _, rc {
    rc.type == "azurerm_key_vault" and
    (rc.change.actions contains "create" or rc.change.actions contains "update")
}

purge_protection_enabled = rule {
    all key_vaults as _, kv {
        kv.change.after.purge_protection_enabled == true
    }
}

main = rule {
    purge_protection_enabled
}
```

#### Logging and Auditing
- **Enable diagnostic settings** on all resources
- **Centralize logs** in Log Analytics
- **Configure long-term retention**
- **Implement Azure Monitor alerts**

## Implementation Steps

1. **Network Infrastructure**
   - Create Virtual Network with appropriate subnets
   - Configure NSGs and route tables
   - Set up DNS zones for private endpoints

2. **Security Infrastructure**
   - Configure Key Vault with appropriate access policies
   - Set up managed identities for all services
   - Implement RBAC model for access control

3. **Core Services**
   - Deploy storage with enhanced security
   - Configure container registry with geo-replication
   - Set up App Service with VNet integration

4. **AI Services**
   - Deploy OpenAI with private endpoints
   - Configure AI Search with replicas
   - Set up ML workspace with private networks

5. **Monitoring and Operations**
   - Configure centralized monitoring
   - Set up alerting and notifications
   - Create operational dashboards


## CI/CD Pipeline Integration

Integrate with GitHub Actions:

```yaml
# GitHub Actions workflow for production deployment
name: Deploy to Production

on:
  push:
    branches: [ main ]
    paths:
      - 'environments/prod/**'

jobs:
  terraform:
    runs-on: ubuntu-latest
    environment: production
    
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v1
        
      - name: Terraform Init
        run: terraform init
        working-directory: environments/prod
        
      - name: Terraform Plan
        run: terraform plan -out=tfplan
        working-directory: environments/prod
        
      - name: Terraform Apply
        run: terraform apply -auto-approve tfplan
        working-directory: environments/prod
        if: github.ref == 'refs/heads/main' && github.event_name == 'push'
```

## Testing and Validation

Before deploying to production:

1. **Validate architecture** against requirements
2. **Load test** for performance and scaling
3. **Penetration test** for security vulnerabilities
4. **Disaster recovery test** for resilience
5. **Compliance validation** for regulatory requirements

## Monitoring and Maintenance

Once deployed:

1. **Implement regular reviews** of metrics and logs
2. **Schedule maintenance windows** for updates
3. **Create runbooks** for common operational tasks
4. **Document recovery procedures** for incidents
5. **Regular security assessments** and updates

## Conclusion

Migrating from the basic architecture to a production-ready deployment requires significant enhancements to security, reliability, and operations. Use this guide as a starting point and adapt it to your specific requirements and organizational policies.
