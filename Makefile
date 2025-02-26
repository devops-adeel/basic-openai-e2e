# Makefile for Terraform Azure OpenAI Infrastructure

# Variables
TERRAFORM := terraform
SENTINEL := sentinel
TFLINT := tflint
MODULE_DIR := ./modules
TEST_DIR := ./tests

.PHONY: init fmt validate test tflint sentinel-test clean docs help

# Default target when just running 'make'
.DEFAULT_GOAL := help

# Initialize Terraform
init:
	@echo "Initializing Terraform..."
	$(TERRAFORM) init -backend=false

# Format Terraform code
fmt:
	@echo "Formatting Terraform code..."
	$(TERRAFORM) fmt -recursive

# Validate Terraform code
validate: init
	@echo "Validating Terraform code..."
	$(TERRAFORM) validate

# Run Terraform tests
test: init
	@echo "Running Terraform tests..."
	$(TERRAFORM) test

# Run specific test module
test-%: init
	@echo "Running test for $*..."
	$(TERRAFORM) test $(TEST_DIR)/$*

# Run TFLint if installed
tflint:
	@if command -v $(TFLINT) >/dev/null 2>&1; then \
		echo "Running TFLint..."; \
		$(TFLINT) --recursive; \
	else \
		echo "TFLint not installed. Skipping..."; \
		echo "Install with: curl -s https://raw.githubusercontent.com/terraform-linters/tflint/master/install_linux.sh | bash"; \
	fi

# Run Sentinel tests
sentinel-test: init
	@if command -v $(SENTINEL) >/dev/null 2>&1; then \
		echo "Generating Terraform plan for Sentinel..."; \
		$(TERRAFORM) plan -out=tfplan.binary; \
		$(TERRAFORM) show -json tfplan.binary > tfplan.json; \
		echo "Running Sentinel policies..."; \
		cd sentinel && $(SENTINEL) apply -global "tfplan=$(shell cat tfplan.json)"; \
	else \
		echo "Sentinel not installed. Skipping..."; \
		echo "Install Sentinel from: https://releases.hashicorp.com/sentinel/"; \
	fi

# Clean up generated files
clean:
	@echo "Cleaning up..."
	rm -rf .terraform
	rm -f tfplan.binary tfplan.json
	rm -f test-results.xml
	find . -type f -name "*.tfstate" -delete
	find . -type f -name "*.tfstate.backup" -delete
	find . -type f -name ".terraform.lock.hcl" -delete

# Generate documentation (requires terraform-docs)
docs:
	@if command -v terraform-docs >/dev/null 2>&1; then \
		echo "Generating documentation..."; \
		for dir in $(MODULE_DIR)/*; do \
			if [ -d "$$dir" ]; then \
				echo "Generating docs for $${dir}..."; \
				terraform-docs markdown table "$$dir" > "$$dir/README.md"; \
			fi \
		done; \
	else \
		echo "terraform-docs not installed. Skipping..."; \
		echo "Install with: go install github.com/terraform-docs/terraform-docs@latest"; \
	fi

# Help target
help:
	@echo "Terraform Azure OpenAI Infrastructure Makefile"
	@echo ""
	@echo "Usage:"
	@echo "  make init           - Initialize Terraform"
	@echo "  make fmt            - Format Terraform code"
	@echo "  make validate       - Validate Terraform code"
	@echo "  make test           - Run all Terraform tests"
	@echo "  make test-MODULE    - Run tests for a specific module (e.g., make test-resource_group)"
	@echo "  make tflint         - Run TFLint for static code analysis"
	@echo "  make sentinel-test  - Run Sentinel policy checks"
	@echo "  make clean          - Clean up generated files"
	@echo "  make docs           - Generate documentation with terraform-docs"
	@echo "  make help           - Show this help message"
