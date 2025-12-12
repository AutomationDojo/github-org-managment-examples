# GitHub Organization Management Examples

Example configurations and templates for GitHub organization management with Terraform.

This repository demonstrates how to manage GitHub organizations, repositories, and rulesets using Infrastructure as Code (IaC) with Terraform.

## Repository Structure

The repository is organized into four main Terraform modules:

### 1. Organization Configurations (`org_configurations/`)

Manages organization-level settings including:
- Billing email
- Organization description
- Member privileges (repository creation, pages, forks, etc.)

**Key files:**
- `main.tf` - Organization settings resource
- `locals.tf` - Environment configuration
- `providers.tf` - GitHub provider configuration
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `backend.tf` - Terraform backend configuration

### 2. Repositories Management (`repos/`)

Manages GitHub repositories with support for:
- Repository creation and configuration
- Visibility settings (public/private)
- Features (issues, discussions, projects, wiki, downloads)
- Merge settings (merge commit, squash, rebase, auto-merge)
- Branch protection via repository-level rulesets
- Topics and vulnerability alerts

**Key files:**
- `main.tf` - Repository and repository ruleset resources
- `locals.tf` - Configuration loading from YAML files
- `configs/repositories.yaml` - Repository definitions (YAML format)

**Features:**
- Per-repository rulesets (works on free tier for public repos)
- Configurable branch patterns and protection rules
- Pull request requirements
- Required status checks

### 3. Organization Rulesets (`rulesets/`)

Manages organization-level rulesets for centralized branch protection policies.

**Note:** Organization-level rulesets require GitHub Team or Enterprise plan.

**Key files:**
- `main.tf` - Organization ruleset resources
- `locals.tf` - Configuration loading from YAML files
- `configs/org_rulesets.yaml` - Organization ruleset definitions (YAML format)

**Features:**
- Organization-wide rule enforcement
- Repository name filtering
- Branch pattern matching
- Bypass actors configuration
- Pull request and status check requirements

### 4. Teams Management (`teams/`)

Manages GitHub teams, team memberships, and repository access permissions.

**Key files:**
- `main.tf` - Team, team membership, and team repository resources
- `locals.tf` - Configuration loading and data flattening from YAML files
- `configs/teams.yaml` - Team definitions (YAML format)

**Features:**
- Team creation with privacy settings (closed/secret)
- Team member management with roles (maintainer/member)
- Repository access control with granular permissions (pull, triage, push, maintain, admin)
- Support for external collaborators
- Simplified YAML configuration for team structure

## Prerequisites

- Terraform >= 1.0
- GitHub account with appropriate permissions
- GitHub Personal Access Token (PAT) or GitHub App credentials
- For organization rulesets: GitHub Team or Enterprise plan

## Configuration

All configurations are defined in YAML files for easier management:

- `repos/configs/repositories.yaml` - Repository definitions
- `rulesets/configs/org_rulesets.yaml` - Organization ruleset definitions
- `teams/configs/teams.yaml` - Team definitions and memberships

## Usage

Each module can be deployed independently:

```bash
# Organization settings
cd org_configurations
terraform init
terraform plan
terraform apply

# Repositories
cd repos
terraform init
terraform plan
terraform apply

# Organization rulesets (requires Team/Enterprise plan)
cd rulesets
terraform init
terraform plan
terraform apply

# Teams management
cd teams
terraform init
terraform plan
terraform apply
```

## Features

- **YAML-based configuration** - Easy to read and maintain
- **Modular architecture** - Independent modules for different aspects
- **Repository rulesets** - Per-repository branch protection (free tier compatible)
- **Organization rulesets** - Centralized policy enforcement (Team/Enterprise)
- **Team management** - Manage teams, members, and repository access
- **Flexible rules** - Support for PR requirements, status checks, and more
- **Granular permissions** - Fine-grained access control for teams and repositories
- **Safe defaults** - Sensible default values with `try()` functions

## Notes

- Repository-level rulesets work on public repositories with GitHub Free tier
- Organization-level rulesets require GitHub Team or Enterprise plan
- All configurations use `try()` functions for optional parameters
- The `locals.tf` files handle YAML configuration loading

## License

This is a template repository for educational and reference purposes.
