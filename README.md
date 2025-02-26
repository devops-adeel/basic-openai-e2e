# Azure OpenAI End-to-End Chat Reference Architecture

This repository contains Terraform code to deploy a basic OpenAI end-to-end chat reference architecture in Azure. The architecture is designed as a learning and proof-of-concept (POC) implementation based on Microsoft's AI/ML documentation.

[![Terraform Tests](https://github.com/hashicorp/terraform-azure-openai-chat/actions/workflows/terraform-tests.yml/badge.svg)](https://github.com/hashicorp/terraform-azure-openai-chat/actions/workflows/terraform-tests.yml)
[![Sentinel Policy Check](https://github.com/hashicorp/terraform-azure-openai-chat/actions/workflows/sentinel-policy-check.yml/badge.svg)](https://github.com/hashicorp/terraform-azure-openai-chat/actions/workflows/sentinel-policy-check.yml)

## Architecture Overview

This implementation provides:

![Architecture Diagram](docs/architecture-diagram.png)

- **Azure App Service** with Easy Auth for authentication and chat UI
- **AI Foundry Hub and Project** for prompt flow development
- **Azure Machine Learning** with managed online endpoints
- **Azure Storage** for persisting prompt flow source files
- **Azure Container Registry** for storing container images
- **Azure OpenAI Service** for language model access
- **Azure AI Search** for data retrieval and indexing
- **Azure Key Vault** for secrets management
- **Application Insights** for monitoring

## Key Features

- **Modular Design**: Each component is implemented as a reusable Terraform module
- **Comprehensive Testing**: Terraform test files validate each module
- **Sentinel Policies**: CIS benchmark-aligned policies ensure security compliance
- **CI/CD Integration**: GitHub Actions workflows for automated testing
- **Developer Tools**: Makefile and pre-commit hooks for local development

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) (v1.7.0 or newer)
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (latest version recommended)
- Azure subscription with access to create all required resources
- Permissions to register Azure AD applications (for Easy Auth)

## Getting Started

1. **Clone the repository**

   ```bash
   git clone https://github.com/hashicorp/terraform-azure-openai-chat.git
   cd terraform-azure-openai-chat
   ```

2. **Login to Azure**

   ```bash
   az login
   ```

3. **Initialize Terraform**

   ```bash
   terraform init
   ```

4. **Create a terraform.tfvars file**

   Create a file named `terraform.tfvars` with your configuration:

   ```hcl
   prefix         = "openai"
   environment    = "dev"
   location       = "eastus"
   
   openai_deployments = [
     {
       name     = "gpt-35-turbo"
       model    = "gpt-35-turbo"
       version  = "0613"
       capacity = 1
     }
   ]
   
   tags = {
     Owner       = "AI Team"
     Environment = "Development"
   }
   ```

5. **Run Terraform tests** (optional but recommended)

   ```bash
   make test
   ```

6. **Plan Deployment**

   ```bash
   terraform plan -out=tfplan
   ```

7. **Apply Deployment**

   ```bash
   terraform apply tfplan
   ```

## Module Structure

The Terraform code is organized in a modular structure following HashiCorp's module composition guidelines:

```
.
├── main.tf                 # Main configuration
├── variables.tf            # Input variables
├── outputs.tf              # Output values
├── providers.tf            # Provider configuration
├── terraform.tf            # Version constraints
├── backend.tf              # State configuration
├── locals.tf               # Local values
├── modules/                # Terraform modules
│   ├── resource_group/     # Resource group module
│   ├── app_service/        # App Service with Easy Auth
│   ├── ai_foundry/         # AI Foundry Hub and Project
│   ├── azure_ml/           # ML workspace and endpoint
│   ├── storage/            # Storage Account
│   ├── container_registry/ # Container Registry
│   ├── openai/             # OpenAI service
│   ├── search/             # AI Search service
│   ├── key_vault/          # Key Vault
│   └── monitoring/         # Application Insights
├── tests/                  # Terraform tests
├── sentinel/               # Sentinel policies
└── .github/workflows/      # GitHub Actions
```

## Development Tools

This repository includes several tools to streamline development:

- **Makefile**: Run common operations like `make init`, `make test`, and `make sentinel-test`
- **Pre-commit hooks**: Ensure code quality with automated checks
- **GitHub Actions**: Automated testing and policy enforcement
- **Terraform tests**: Validate your infrastructure with `terraform test`
- **Sentinel policies**: Enforce security standards with `sentinel apply`

## Security and Compliance

This implementation includes Sentinel policies that enforce CIS Azure Foundations Benchmark recommendations including:

- Identity and Access Management controls
- Security Configuration best practices
- Logging and Monitoring requirements
- Data Protection standards

## Customization

Adjust the deployment by modifying the variables in your `terraform.tfvars` file. Key variables include:

- `prefix`: Prefix for all resource names
- `environment`: Environment name (dev, test, prod)
- `location`: Azure region
- `openai_deployments`: List of OpenAI model deployments to create
- `tags`: Tags to apply to all resources

## Security Considerations

- This implementation uses public endpoints as specified in the reference architecture
- Key Vault is configured to allow access from all networks
- Sensitive values are marked as sensitive in Terraform
- System-assigned managed identities are used for authentication between services

## Next Steps

After deployment, you can:

1. Access the AI Foundry project to develop and test your prompt flows
2. Deploy your flows to the managed online endpoint
3. Modify the App Service code to use the deployed endpoint
4. Test the end-to-end chat functionality

For production implementations, refer to the Baseline OpenAI end-to-end chat reference architecture in the Microsoft documentation, which adds production design decisions to this basic architecture.

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License

This project is licensed under the MPL 2.0 License - see the [LICENSE](LICENSE) file for details.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 2.47.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.85.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.6.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ai_foundry"></a> [ai\_foundry](#module\_ai\_foundry) | ./modules/ai_foundry | n/a |
| <a name="module_app_service"></a> [app\_service](#module\_app\_service) | ./modules/app_service | n/a |
| <a name="module_azure_ml"></a> [azure\_ml](#module\_azure\_ml) | ./modules/azure_ml | n/a |
| <a name="module_container_registry"></a> [container\_registry](#module\_container\_registry) | ./modules/container_registry | n/a |
| <a name="module_key_vault"></a> [key\_vault](#module\_key\_vault) | ./modules/key_vault | n/a |
| <a name="module_monitoring"></a> [monitoring](#module\_monitoring) | ./modules/monitoring | n/a |
| <a name="module_openai"></a> [openai](#module\_openai) | ./modules/openai | n/a |
| <a name="module_resource_group"></a> [resource\_group](#module\_resource\_group) | ./modules/resource_group | n/a |
| <a name="module_search"></a> [search](#module\_search) | ./modules/search | n/a |
| <a name="module_storage"></a> [storage](#module\_storage) | ./modules/storage | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input\_environment) | Environment (dev, test, prod) | `string` | `"dev"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for all resources | `string` | `"eastus"` | no |
| <a name="input_openai_content_filter"></a> [openai\_content\_filter](#input\_openai\_content\_filter) | Content filter settings for OpenAI | <pre>object({<br/>    hate = string<br/>    sexual = string<br/>    violence = string<br/>    self_harm = string<br/>    profanity = string<br/>    jailbreak = string<br/>  })</pre> | <pre>{<br/>  "hate": "high",<br/>  "jailbreak": "high",<br/>  "profanity": "high",<br/>  "self_harm": "high",<br/>  "sexual": "high",<br/>  "violence": "high"<br/>}</pre> | no |
| <a name="input_openai_deployments"></a> [openai\_deployments](#input\_openai\_deployments) | OpenAI model deployments to create | <pre>list(object({<br/>    name  = string<br/>    model = string<br/>    version = string<br/>    capacity = number<br/>  }))</pre> | <pre>[<br/>  {<br/>    "capacity": 1,<br/>    "model": "gpt-35-turbo",<br/>    "name": "gpt-35-turbo",<br/>    "version": "0613"<br/>  }<br/>]</pre> | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix for all resources | `string` | `"openai"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ai_foundry_hub_id"></a> [ai\_foundry\_hub\_id](#output\_ai\_foundry\_hub\_id) | ID of the AI Foundry Hub |
| <a name="output_ai_foundry_hub_principal_id"></a> [ai\_foundry\_hub\_principal\_id](#output\_ai\_foundry\_hub\_principal\_id) | Principal ID of the AI Foundry Hub managed identity |
| <a name="output_ai_foundry_project_id"></a> [ai\_foundry\_project\_id](#output\_ai\_foundry\_project\_id) | ID of the AI Foundry Project |
| <a name="output_ai_foundry_project_principal_id"></a> [ai\_foundry\_project\_principal\_id](#output\_ai\_foundry\_project\_principal\_id) | Principal ID of the AI Foundry Project managed identity |
| <a name="output_app_service_principal_id"></a> [app\_service\_principal\_id](#output\_app\_service\_principal\_id) | Principal ID of the App Service managed identity |
| <a name="output_app_service_url"></a> [app\_service\_url](#output\_app\_service\_url) | URL of the App Service |
| <a name="output_application_insights_instrumentation_key"></a> [application\_insights\_instrumentation\_key](#output\_application\_insights\_instrumentation\_key) | Instrumentation key for Application Insights |
| <a name="output_azure_ml_endpoint_id"></a> [azure\_ml\_endpoint\_id](#output\_azure\_ml\_endpoint\_id) | ID of the Azure ML managed online endpoint |
| <a name="output_azure_ml_endpoint_scoring_uri"></a> [azure\_ml\_endpoint\_scoring\_uri](#output\_azure\_ml\_endpoint\_scoring\_uri) | Scoring URI of the Azure ML managed online endpoint |
| <a name="output_azure_ml_workspace_id"></a> [azure\_ml\_workspace\_id](#output\_azure\_ml\_workspace\_id) | ID of the Azure ML workspace |
| <a name="output_key_vault_uri"></a> [key\_vault\_uri](#output\_key\_vault\_uri) | URI of the Key Vault |
| <a name="output_openai_endpoint"></a> [openai\_endpoint](#output\_openai\_endpoint) | Endpoint of the OpenAI service |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Name of the resource group |
| <a name="output_search_endpoint"></a> [search\_endpoint](#output\_search\_endpoint) | Endpoint of the AI Search service |
<!-- END_TF_DOCS -->
