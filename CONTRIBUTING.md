# Contributing to Azure OpenAI Chat Reference Architecture

Thank you for your interest in contributing to this project! This document provides guidelines and instructions for contributing to this Terraform implementation of Azure OpenAI chat architecture.

## Code of Conduct

Please review and follow our [Code of Conduct](CODE_OF_CONDUCT.md) to foster an open and welcoming environment.

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** to your local machine
3. **Install development tools**:
   - Terraform (v1.7.0 or newer)
   - pre-commit
   - Sentinel (if you want to work on policy)

4. **Set up pre-commit hooks**:
   ```bash
   pre-commit install
   ```

## Development Workflow

1. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**:
   - Follow the [Terraform Style Guide](https://www.terraform.io/docs/language/syntax/style.html)
   - Ensure modules have appropriate documentation
   - Add tests for your changes

3. **Run the test suite** to ensure your changes work:
   ```bash
   make test
   ```

4. **Run policy checks** to ensure compliance:
   ```bash
   make sentinel-test
   ```

5. **Commit your changes** with a clear commit message:
   ```bash
   git commit -m "Add feature: description of changes"
   ```

6. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

7. **Create a Pull Request** against the main repository

## Pull Request Process

1. Ensure your PR includes relevant tests and documentation
2. Update the README.md if needed to reflect changes
3. The PR will be reviewed by maintainers
4. Address any comments or requested changes
5. Once approved, a maintainer will merge your PR

## Testing

We use the Terraform testing framework for validating modules:

- **Unit tests**: Test individual modules in isolation
- **Integration tests**: Test multiple modules working together

To run tests:
```bash
# Run all tests
make test

# Run tests for a specific module
make test-MODULE_NAME
```

## Coding Standards

- Follow the HashiCorp Terraform [Style Guide](https://www.terraform.io/docs/language/syntax/style.html)
- Use meaningful variable and output names
- Document all variables with descriptions
- Include check blocks to validate resources
- Preserve backward compatibility when possible

## Module Structure

Each module should follow this standard structure:
```
modules/module_name/
├── main.tf          # Main resources
├── variables.tf     # Input variables
├── outputs.tf       # Output values
└── README.md        # Module documentation
```

## Documentation

- Each module should have a README.md with:
  - Description of purpose
  - Usage example
  - Input variables table
  - Output values table
  - Any important notes

## Policy as Code

We use Sentinel for policy as code:
- Policies are in the `sentinel/` directory
- New modules should comply with existing policies
- New policies should align with CIS benchmarks where applicable

## Release Process

Releases are managed by the maintainers following semantic versioning:
- **MAJOR** version for incompatible API changes
- **MINOR** version for backward-compatible functionality
- **PATCH** version for backward-compatible bug fixes

## Questions?

If you have questions or need help, please:
1. Check existing issues
2. Open a new issue if needed
3. Reach out to the maintainers

Thank you for contributing!
