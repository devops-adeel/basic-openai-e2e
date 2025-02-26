# Testing Guide

This document provides comprehensive guidance on testing the Azure OpenAI Chat Reference Architecture using Terraform's built-in testing framework and Sentinel policy checks.

## Test Structure

The testing framework is organized into several components:

```
tests/
├── resource_group/           # Tests for Resource Group module
├── app_service/              # Tests for App Service module
├── ai_foundry/               # Tests for AI Foundry module
├── azure_ml/                 # Tests for Azure ML module
├── openai/                   # Tests for OpenAI module
├── search/                   # Tests for Search module
├── key_vault/                # Tests for Key Vault module
├── storage/                  # Tests for Storage module
├── container_registry/       # Tests for Container Registry module
├── monitoring/               # Tests for Monitoring module
└── end_to_end/               # End-to-end integration tests
```

## Test Types

### Unit Tests

Each module has individual unit tests that validate:

1. **Resource Creation**: Verify resources are created with correct properties
2. **Validation Rules**: Test input validation for errors
3. **Output Values**: Confirm outputs match expected values
4. **Security Configurations**: Validate security settings

### Integration Tests

The end-to-end tests validate:

1. **Module Interactions**: Verify modules work together properly
2. **Policy Compliance**: Check that infrastructure meets policy requirements
3. **Connectivity**: Validate service connections

## Running Tests

### Running All Tests

```bash
# Using Terraform CLI
terraform test

# Using the Makefile
make test
```

### Running Tests for a Specific Module

```bash
# Using Terraform CLI
terraform test tests/openai

# Using the Makefile
make test-openai
```

### Running With Detailed Output

```bash
terraform test -verbose
```

## Test Implementation Details

### Mock Resources

Tests use mock providers to simulate Azure API responses:

```hcl
# Mock provider for Azure
mock_provider "azurerm" {
  source = "registry.terraform.io/hashicorp/azurerm"
}

# Mock a resource
mock_resource "azurerm_resource_group" {
  defaults = {
    id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg"
    name = "test-rg"
    location = "eastus"
  }
}
```

### Test Run Blocks

Each test case is defined in a `run` block:

```hcl
run "create_resource_group_basic" {
  # Mock resources...
  
  # Reference the module
  module {
    source = "../../modules/resource_group"
  }
  
  # Assert outputs
  assert {
    condition     = output.name == "test-rg"
    error_message = "Resource group name does not match expected value."
  }
}
```

### Testing Validation Failures

Tests validate error conditions using `expect_failures`:

```hcl
run "create_storage_invalid_name" {
  variables {
    name = "Invalid_Storage_Name" # Contains uppercase and underscores
  }

  module {
    source = "../../modules/storage"
  }

  expect_failures = [
    is_match(validation.var.name.error_message, "Storage account name must be between 3 and 24 characters"),
  ]
}
```

## Sentinel Policy Testing

Sentinel policies validate compliance with security standards:

```bash
# Run Sentinel policy checks
cd sentinel
sentinel apply -global "tfplan=$(cat ../tfplan.json)"
```

Key policy sets include:

1. **Identity and Access Management**: Validate identity configuration
2. **Security Configuration**: Enforce security settings
3. **Logging and Monitoring**: Ensure proper monitoring
4. **Resource Configuration**: Validate resource settings

## Test Coverage

| Module | Unit Tests | Integration Tests | Policy Checks |
|--------|------------|-------------------|--------------|
| Resource Group | ✓ | ✓ | ✓ |
| App Service | ✓ | ✓ | ✓ |
| AI Foundry | ✓ | ✓ | ✓ |
| Azure ML | ✓ | ✓ | ✓ |
| OpenAI | ✓ | ✓ | ✓ |
| Search | ✓ | ✓ | ✓ |
| Key Vault | ✓ | ✓ | ✓ |
| Storage | ✓ | ✓ | ✓ |
| Container Registry | ✓ | ✓ | ✓ |
| Monitoring | ✓ | ✓ | ✓ |

## CI/CD Integration

Tests are automatically run in CI/CD pipelines:

### GitHub Actions

```yaml
name: Terraform Tests

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  terraform-test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v3
        
      - name: Terraform Init
        run: terraform init -backend=false
      
      - name: Run Terraform Tests
        run: terraform test -junit-xml=test-results.xml
      
      - name: Publish Test Results
        uses: EnricoMi/publish-unit-test-result-action@v2
        with:
          files: test-results.xml
```

## Example Test Cases

### Resource Group Test

```hcl
run "create_resource_group_minimum" {
  variables {
    name = "test-rg"
    location = "eastus"
    tags = {
      Environment = "test"
      Project = "openai-chat"
      Provisioner = "Terraform"
    }
  }

  module {
    source = "../../modules/resource_group"
  }

  assert {
    condition = output.name == "test-rg"
    error_message = "Resource group name does not match expected value."
  }
}
```

### OpenAI Content Filter Test

```hcl
run "create_openai_invalid_content_filter" {
  variables {
    content_filter = {
      hate = "low"  # Below required minimum level
      sexual = "high"
      violence = "high"
      self_harm = "high"
      profanity = "high"
      jailbreak = "high"
    }
  }

  module {
    source = "../../modules/openai"
  }

  expect_failures = [
    is_match(check.openai_content_filter_settings.error_message, "Content filter settings must be set to 'low', 'medium', or 'high'."),
  ]
}
```

### End-to-End Test

```hcl
run "infrastructure_policy_compliance" {
  # Mock a Key Vault with valid settings
  mock_resource "azurerm_key_vault" {
    defaults = {
      purge_protection_enabled = true
      soft_delete_retention_days = 7
    }
  }
  
  # Verify Key Vault has purge protection
  assert {
    condition = mock_resource.azurerm_key_vault.defaults.purge_protection_enabled == true
    error_message = "Key Vault must have purge protection enabled."
  }
}
```

## Best Practices

1. **Mock Once, Test Many**: Create comprehensive mocks to reuse across tests
2. **Test Edge Cases**: Include tests for error conditions and validation failures
3. **Keep Tests Isolated**: Each test should be independent of others
4. **Use Descriptive Names**: Name tests to clearly indicate what they're testing
5. **Validate Outputs**: Always assert on module outputs
6. **Check Security Settings**: Test security configurations explicitly

## Adding New Tests

To add tests for a new module:

1. Create a directory in `tests/` for the module
2. Create a test file with a `.tftest.hcl` extension
3. Define variables, mock resources, and run blocks
4. Add assertions for expected outputs
5. Include tests for validation rules and error cases

## References

- [Terraform Testing Documentation](https://developer.hashicorp.com/terraform/language/tests)
- [Sentinel Policy Documentation](https://developer.hashicorp.com/terraform/cloud-docs/policy-enforcement/sentinel)
- [Azure Resource Mocking](https://developer.hashicorp.com/terraform/language/tests/mock)
