# Terraform Tests for Azure OpenAI Architecture

This directory contains tests for the Terraform modules in this repository. The tests are written using the Terraform built-in testing framework.

## Test Structure

```
tests/
├── resource_group/
│   ├── resource_group_test.go          # Go test file (optional for advanced testing)
│   └── resource_group_test.tftest.hcl  # Terraform test file
├── openai/
│   └── openai_test.tftest.hcl          # OpenAI module test
├── app_service/
│   └── app_service_test.tftest.hcl     # App Service module test
├── ai_foundry/
│   └── ai_foundry_test.tftest.hcl      # AI Foundry module test
└── azure_ml/
    └── azure_ml_test.tftest.hcl        # Azure ML module test
```

## Running Tests

To run all tests:

```bash
terraform test
```

To run a specific test:

```bash
terraform test tests/resource_group
```

## Test Coverage

These tests verify that:

1. Resources are created with the expected configuration values
2. Resources comply with CIS benchmark requirements where applicable
3. Modules handle various input scenarios correctly
4. Resources are properly tagged
5. Security configurations are properly applied

## Mock Providers

The tests use mock providers to simulate Azure API responses without making actual API calls. This allows for faster and more deterministic testing.

## Test Assertions

The tests use assertions to verify the expected behavior of the modules:

- `check` blocks to verify resource configurations
- `assert` blocks to verify expected values
- `expect_failures` to test error handling

## Adding New Tests

To add tests for a new module:

1. Create a new directory under the `tests` directory
2. Create a test file with the `.tftest.hcl` extension
3. Define run blocks, variables, and assertions
4. Add mock provider configurations if needed
