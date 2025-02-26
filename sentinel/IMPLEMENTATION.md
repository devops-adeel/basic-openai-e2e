# Sentinel Policy Implementation Guide

This guide provides instructions for implementing the Sentinel policies included in this repository with Terraform Cloud or Terraform Enterprise.

## Prerequisites

- HashiCorp Terraform Cloud account or Terraform Enterprise installation
- Admin access to your Terraform Cloud organization or Terraform Enterprise instance
- Version control system (GitHub, GitLab, Bitbucket, etc.) to store your policies

## Implementation Steps

### 1. Set Up a VCS Repository

1. Create a new repository in your VCS system to store the Sentinel policies
2. Copy the contents of the `sentinel` directory to the repository
3. Commit and push the changes to your VCS repository

### 2. Configure Sentinel in Terraform Cloud/Enterprise

1. Log in to your Terraform Cloud/Enterprise instance
2. Navigate to your organization settings
3. Select "Policy Sets" from the menu
4. Click "Connect a new policy set"

### 3. Create a Policy Set

1. Select your VCS provider and repository containing the Sentinel policies
2. Choose the appropriate branch (typically `main` or `master`)
3. Set the policy set name (e.g., "Azure OpenAI CIS Benchmarks")
4. Set the path to the Sentinel policies (e.g., `/sentinel`)
5. Choose enforcement mode:
   - For development environments: Select "Advisory" to report violations without blocking
   - For production environments: Select "Soft-Mandatory" or "Hard-Mandatory" to enforce policies
6. Select workspaces to apply the policy set to, or apply to all workspaces
7. Click "Connect policy set"

### 4. Test the Policies

1. Create a new run in a workspace that's connected to the policy set
2. Review the policy check results in the run
3. Adjust policies as needed based on your organization's requirements

## Policy Customization

You may need to customize the policies to fit your organization's specific requirements. Here are some common customizations:

### Tagging Requirements

Modify `enforce-resource-tagging.sentinel` to update the required tags and valid values:

```hcl
# Define required tags
required_tags = [
    "Environment",
    "Project",
    "Owner",
    "CostCenter"  # Add additional required tags
]

# Define valid environments
valid_environments = ["dev", "test", "staging", "prod", "production", "sandbox"]  # Add environments
```

### Content Filter Settings

Modify `openai-content-filter.sentinel` to adjust the minimum required filtering level:

```hcl
# Define minimum required content filter settings
required_minimum_level = "high"  # Change to high for stricter filtering
```

### Diagnostic Settings Retention

Modify `require-diagnostic-settings.sentinel` to adjust the retention period:

```hcl
# Ensure retention policy is configured with a longer retention period
ensure_retention = rule {
    all diagnosticSettings as _, ds {
        all ds.change.after.log as _, log {
            log.retention_policy[0].enabled == true and
            log.retention_policy[0].days >= 90  # Increase to 90 days
        }
    }
}
```

## Gradual Rollout Strategy

For a smoother adoption of policies, consider this phased approach:

1. **Phase 1**: Apply policies in advisory mode to all workspaces
2. **Phase 2**: After fixing violations, switch to soft-mandatory for non-production workspaces
3. **Phase 3**: Apply soft-mandatory to production workspaces
4. **Phase 4**: Apply hard-mandatory to all workspaces for critical security policies

## Monitoring and Compliance Reporting

Terraform Cloud/Enterprise provides APIs to access policy check results, which can be used to generate compliance reports. Consider integrating with a BI tool or dashboard to track compliance over time.
