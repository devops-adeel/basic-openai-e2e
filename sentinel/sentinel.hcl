# This is the main configuration file for Sentinel policies
# It defines policy sets that can be applied to workspaces

# Identity and Access Management policies
policy "require-managed-identity" {
    source            = "./identity-and-access-management/require-managed-identity.sentinel"
    enforcement_level = "hard-mandatory"
}

# Security Configuration policies
policy "enforce-resource-tagging" {
    source            = "./security-configuration/enforce-resource-tagging.sentinel"
    enforcement_level = "soft-mandatory"
}

policy "require-https-and-tls" {
    source            = "./security-configuration/require-https-and-tls.sentinel"
    enforcement_level = "hard-mandatory"
}

policy "secure-key-vault" {
    source            = "./security-configuration/secure-key-vault.sentinel"
    enforcement_level = "hard-mandatory"
}

policy "openai-content-filter" {
    source            = "./security-configuration/openai-content-filter.sentinel"
    enforcement_level = "hard-mandatory"
}

policy "storage-security" {
    source            = "./security-configuration/storage-security.sentinel"
    enforcement_level = "soft-mandatory"
}

policy "container-registry-security" {
    source            = "./security-configuration/container-registry-security.sentinel"
    enforcement_level = "soft-mandatory"
}

policy "azure-ml-security" {
    source            = "./security-configuration/azure-ml-security.sentinel"
    enforcement_level = "soft-mandatory"
}

policy "search-configuration" {
    source            = "./security-configuration/search-configuration.sentinel"
    enforcement_level = "advisory"  # Advisory for basic architecture
}

policy "network-security" {
    source            = "./security-configuration/network-security.sentinel"
    enforcement_level = "advisory"  # Advisory for basic architecture
}

policy "ai-foundry-security" {
    source            = "./security-configuration/ai-foundry-security.sentinel"
    enforcement_level = "soft-mandatory"
}

policy "app-service-security" {
    source            = "./security-configuration/app-service-security.sentinel"
    enforcement_level = "hard-mandatory"
}

# Logging and Monitoring policies
policy "require-diagnostic-settings" {
    source            = "./logging-and-monitoring/require-diagnostic-settings.sentinel"
    enforcement_level = "soft-mandatory"
}

# Define policy sets for different environments
policy_set "basic" {
    policies = [
        "require-managed-identity",
        "enforce-resource-tagging",
        "require-https-and-tls",
        "secure-key-vault",
        "openai-content-filter",
        "storage-security",
        "container-registry-security",
        "azure-ml-security",
        "ai-foundry-security",
        "app-service-security",
        "require-diagnostic-settings"
    ]
}

policy_set "production" {
    policies = [
        "require-managed-identity",
        "enforce-resource-tagging",
        "require-https-and-tls",
        "secure-key-vault",
        "openai-content-filter",
        "storage-security",
        "container-registry-security",
        "azure-ml-security",
        "search-configuration",
        "network-security",
        "ai-foundry-security",
        "app-service-security",
        "require-diagnostic-settings"
    ]
    # Override enforcement levels for production
    policy_overrides = {
        # Make all policies hard-mandatory in production
        "enforce-resource-tagging" = {
            enforcement_level = "hard-mandatory"
        },
        "storage-security" = {
            enforcement_level = "hard-mandatory"
        },
        "container-registry-security" = {
            enforcement_level = "hard-mandatory"
        },
        "azure-ml-security" = {
            enforcement_level = "hard-mandatory"
        },
        "search-configuration" = {
            enforcement_level = "soft-mandatory"
        },
        "network-security" = {
            enforcement_level = "soft-mandatory"
        },
        "ai-foundry-security" = {
            enforcement_level = "hard-mandatory"
        },
        "require-diagnostic-settings" = {
            enforcement_level = "hard-mandatory"
        }
    }
}

# Define a module for common functions
module "tfplan-functions" {
    source = "https://raw.githubusercontent.com/hashicorp/terraform-guides/master/governance/third-generation/common-functions/tfplan-functions/tfplan-functions.sentinel"
}

module "tfstate-functions" {
    source = "https://raw.githubusercontent.com/hashicorp/terraform-guides/master/governance/third-generation/common-functions/tfstate-functions/tfstate-functions.sentinel"
}

module "tfconfig-functions" {
    source = "https://raw.githubusercontent.com/hashicorp/terraform-guides/master/governance/third-generation/common-functions/tfconfig-functions/tfconfig-functions.sentinel"
}
