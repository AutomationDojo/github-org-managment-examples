# Organization Settings Module

The Organization Settings module manages organization-level configuration for your GitHub organization.

## Overview

This module configures:

- Organization billing email
- Organization description
- Member privileges (repository creation, pages, forks, etc.)

## Files

- `main.tf` - Organization settings resource definition
- `locals.tf` - Environment configuration loading
- `providers.tf` - GitHub provider configuration
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `backend.tf` - Terraform backend configuration

## Configuration

The module uses local configuration in `locals.tf` to define organization settings. This approach is suitable for settings that don't change frequently.

### Example Configuration

```hcl title="locals.tf"
locals {
  environment = {
    github = {
      organization = {
        billing_email = "billing@example.com"
        description   = "Example Organization for DevOps Automation"

        # Repository creation permissions
        members_can_create_repositories         = false
        members_can_create_public_repositories  = false
        members_can_create_private_repositories = false
        members_can_create_internal_repositories = false

        # Pages permissions
        members_can_create_pages         = false
        members_can_create_public_pages  = false
        members_can_create_private_pages = false

        # Fork permissions
        members_can_fork_private_repositories = false
      }
    }
  }
}
```

## Resource: github_organization_settings

The module creates a single `github_organization_settings` resource.

### Attributes

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `billing_email` | string | Yes | - | Organization billing email address |
| `description` | string | No | `null` | Organization description |
| `members_can_create_repositories` | bool | No | `false` | Allow members to create repositories |
| `members_can_create_public_repositories` | bool | No | `false` | Allow members to create public repositories |
| `members_can_create_private_repositories` | bool | No | `false` | Allow members to create private repositories |
| `members_can_create_internal_repositories` | bool | No | `false` | Allow members to create internal repositories |
| `members_can_create_pages` | bool | No | `false` | Allow members to create GitHub Pages |
| `members_can_create_public_pages` | bool | No | `false` | Allow members to create public pages |
| `members_can_create_private_pages` | bool | No | `false` | Allow members to create private pages |
| `members_can_fork_private_repositories` | bool | No | `false` | Allow members to fork private repositories |

## Usage

### Initial Setup

1. Navigate to the module directory:
```bash
cd org_configurations
```

2. Configure your organization settings in `locals.tf`

3. Initialize Terraform:
```bash
terraform init
```

4. Review the planned changes:
```bash
terraform plan
```

5. Apply the configuration:
```bash
terraform apply
```

### Updating Settings

To update organization settings:

1. Modify the values in `locals.tf`
2. Run `terraform plan` to review changes
3. Run `terraform apply` to apply changes

## Best Practices

### Security

!!! warning "Restrictive Defaults"
    Use restrictive defaults for member privileges. Only grant permissions when necessary.

```hcl
# Recommended: Restrict member permissions
members_can_create_repositories = false
members_can_fork_private_repositories = false
```

### Organization Description

Provide a clear, concise organization description:

```hcl
description = "Open source automation tools and examples for DevOps workflows"
```

### Billing Email

!!! important "Valid Email Required"
    Ensure the billing email is valid and monitored. GitHub sends important notifications to this address.

## Examples

### Restrictive Organization (Recommended for Security)

```hcl
locals {
  environment = {
    github = {
      organization = {
        billing_email = "billing@example.com"
        description   = "Secure Development Organization"

        # Deny all member creation permissions
        members_can_create_repositories          = false
        members_can_create_public_repositories   = false
        members_can_create_private_repositories  = false
        members_can_create_internal_repositories = false
        members_can_create_pages                 = false
        members_can_create_public_pages          = false
        members_can_create_private_pages         = false
        members_can_fork_private_repositories    = false
      }
    }
  }
}
```

### Open Organization (Community/Education)

```hcl
locals {
  environment = {
    github = {
      organization = {
        billing_email = "admin@opensource-project.org"
        description   = "Open Source Community Project"

        # Allow public repository creation
        members_can_create_repositories        = true
        members_can_create_public_repositories = true
        members_can_create_public_pages       = true

        # But restrict private resources
        members_can_create_private_repositories = false
        members_can_create_private_pages        = false
        members_can_fork_private_repositories   = false
      }
    }
  }
}
```

## Outputs

The module outputs the organization name and login:

```hcl
output "organization_name" {
  description = "The name of the organization"
  value       = github_organization_settings.org.name
}

output "organization_login" {
  description = "The login of the organization"
  value       = github_organization_settings.org.login
}
```

## Troubleshooting

### Permission Errors

If you encounter permission errors:

- Ensure your GitHub token has `admin:org` scope
- Verify you have Owner role in the organization
- Check that the organization is not an Enterprise Managed User (EMU) organization

### Invalid Billing Email

If Terraform reports an invalid billing email:

- Verify the email address is properly formatted
- Ensure the email domain is valid
- Check that the email can receive mail from GitHub

## Next Steps

- [Repositories Module](repositories.md) - Create and manage repositories
- [Teams Module](teams.md) - Set up teams and permissions
- [Getting Started Guide](../guides/getting-started.md) - Deploy your configuration
