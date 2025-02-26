# Architecture Guide

This document provides a detailed overview of the Azure OpenAI Chat Reference Architecture.

## Architectural Components

### Core Components

![Architecture Diagram](architecture-diagram.png)

1. **Azure App Service**
   - Hosts the chat user interface
   - Provides authentication through Easy Auth
   - Connects to ML endpoint for inference

2. **AI Foundry Hub and Project**
   - Development environment for prompt flows
   - Manages connections to resources
   - Supports prompt flow authoring and testing

3. **Azure Machine Learning**
   - Hosts ML workspace and compute
   - Provides managed online endpoints
   - Deploys and serves prompt flows

4. **Azure OpenAI Service**
   - Provides access to large language models
   - Implements content filtering
   - Handles prompt-based generation

5. **Azure AI Search**
   - Indexes and stores retrievable data
   - Provides semantic search capabilities
   - Retrieves context for grounding responses

### Supporting Infrastructure

6. **Azure Storage Account**
   - Stores prompt flow definitions
   - Maintains project files and configurations
   - Hosts data used for training or referencing

7. **Azure Container Registry**
   - Stores prompt flow container images
   - Manages versioning of deployments
   - Provides secure image distribution

8. **Azure Key Vault**
   - Securely stores connection secrets
   - Manages API keys and credentials
   - Controls access to sensitive information

9. **Application Insights**
   - Monitors application performance
   - Tracks usage patterns and errors
   - Provides diagnostics and troubleshooting

## Data Flow

1. **User Query Flow**
   - User submits a query via the chat interface
   - App Service authenticates the user
   - App Service forwards the query to the ML endpoint
   - ML endpoint processes the query using the deployed prompt flow
   - Prompt flow extracts intent and identifies relevant data
   - Prompt flow queries AI Search for grounding data
   - Prompt flow constructs a prompt with the grounding data
   - Azure OpenAI processes the prompt and generates a response
   - Response flows back through the system to the user

2. **Development Flow**
   - Developer creates prompt flows in AI Foundry
   - Flow is tested within AI Foundry environment
   - Successful flow is deployed to ML online endpoint
   - App Service is configured to use the deployed endpoint

## Authentication and Authorization

The architecture uses system-assigned managed identities for service-to-service authentication:

1. **App Service Identity**
   - Has access to Key Vault for secrets

2. **AI Foundry Hub Identity**
   - Has access to Storage, Container Registry, Key Vault, OpenAI, and Search

3. **AI Foundry Project Identity**
   - Has access to Storage, Container Registry, Key Vault, and Application Insights

4. **ML Endpoint Identity**
   - Has access to Storage, Container Registry, and AI Foundry

## Security Controls

1. **Content Filtering**
   - Azure OpenAI implements filters for harmful content
   - Filters can be configured for hate, violence, sexual content, etc.

2. **Authentication**
   - Easy Auth provides user authentication
   - Managed identities handle service authentication
   - Key Vault secures sensitive credentials

3. **Data Protection**
   - Transport-level encryption (HTTPS/TLS 1.2)
   - Azure Storage encryption at rest
   - Private containers for storage

## Monitoring and Logging

1. **Application Insights**
   - Collects telemetry from App Service
   - Monitors ML endpoint performance
   - Tracks request patterns and response times

2. **Diagnostic Settings**
   - Configured for all services
   - Captures operational logs
   - Monitors security and compliance

3. **Azure Monitor**
   - Aggregates logs from all services
   - Provides unified monitoring dashboard
   - Supports alerts and notifications

## Scaling Considerations

1. **App Service Plan**
   - Basic SKU for POC environments
   - Scale up to Premium for production workloads
   - Enable auto-scaling for production

2. **Azure OpenAI**
   - Adjust capacity based on expected throughput
   - Monitor token usage and adjust accordingly
   - Consider deploying multiple models for redundancy

3. **ML Endpoint**
   - Select appropriate instance type for workload
   - Enable auto-scaling for production
   - Monitor instance utilization

## Limitations of Basic Architecture

This reference architecture has several limitations for POC/learning purposes:

1. **High Availability**
   - Basic tier services don't have zone redundancy
   - Single instances without auto-scaling
   - No geo-redundancy for regional failures

2. **Network Security**
   - Public endpoints for all services
   - No private endpoints or VNet integration
   - Open Key Vault firewall settings

3. **Cost Optimization**
   - No controls for cost governance
   - Pay-as-you-go model without limits
   - No auto-scaling to match demand

## Production Enhancements

For production deployments, consider these enhancements:

1. **High Availability**
   - Deploy across multiple availability zones
   - Use Premium tiers with auto-scaling
   - Implement geo-redundancy for critical services

2. **Network Security**
   - Implement private endpoints
   - Use VNet integration and service endpoints
   - Restrict network access with firewalls

3. **Cost Management**
   - Implement budgets and alerts
   - Use reserved capacity for predictable workloads
   - Enable auto-scaling to match demand

4. **Monitoring**
   - Set up proactive alerting
   - Implement more extensive logging
   - Create operational dashboards

## Deployment Architecture

The infrastructure is deployed using a modular Terraform approach:

1. **Core Modules**
   - Each Azure service has a dedicated module
   - Modules follow dependency ordering
   - Outputs are used to connect dependent resources

2. **Testing Framework**
   - Unit tests validate individual modules
   - Integration tests verify end-to-end functionality
   - Mock providers simulate Azure API responses

3. **Policy Framework**
   - Sentinel policies enforce security standards
   - Policies align with CIS benchmarks
   - CI/CD integration validates compliance

## Reference Links

- [Azure OpenAI Service Documentation](https://learn.microsoft.com/en-us/azure/ai-services/openai/)
- [Azure Machine Learning Documentation](https://learn.microsoft.com/en-us/azure/machine-learning/)
- [Azure App Service Documentation](https://learn.microsoft.com/en-us/azure/app-service/)
- [Azure AI Search Documentation](https://learn.microsoft.com/en-us/azure/search/)
- [Microsoft Azure Well-Architected Framework](https://learn.microsoft.com/en-us/azure/architecture/framework/)
