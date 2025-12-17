# Repositories Module

The Repositories module manages GitHub repositories and repository-level rulesets for your organization.

## Overview

This module manages:

- Repository creation and configuration
- Repository features (issues, projects, wiki, etc.)
- Merge settings (merge commit, squash, rebase)
- Repository-level rulesets for branch protection
- Topics and vulnerability alerts

!!! success "Free Tier Compatible"
    Repository-level rulesets work on **public repositories** with GitHub Free tier.

## Files

- `main.tf` - Repository and ruleset resource definitions
- `locals.tf` - YAML configuration loading and data transformation
- `configs/repositories.yaml` - Repository definitions (YAML format)
- `providers.tf` - GitHub provider configuration
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `backend.tf` - Terraform backend configuration

## Configuration

Repositories are defined in `configs/repositories.yaml` using a simple YAML structure.

### Repository Structure

```yaml
repositories:
  repository-key:
    name: "repository-name"
    description: "Repository description"
    visibility: "public"  # public or private

    # Features
    has_issues: true
    has_discussions: false
    has_projects: true
    has_wiki: false
    has_downloads: true

    # Merge settings
    allow_merge_commit: true
    allow_squash_merge: true
    allow_rebase_merge: true
    allow_auto_merge: false
    delete_branch_on_merge: true

    # Other settings
    archived: false
    topics:
      - "terraform"
      - "github"
    vulnerability_alerts: true

    # Repository Rulesets (optional)
    rulesets:
      ruleset-key:
        name: "Main Branch Protection"
        enforcement: "active"  # active, evaluate, or disabled
        target: "branch"
        branch_patterns:
          - "~DEFAULT_BRANCH"

        rules:
          # ... ruleset configuration
```

## Repository Configuration

### Basic Settings

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `name` | string | Yes | - | Repository name |
| `description` | string | No | `null` | Repository description |
| `visibility` | string | No | `"private"` | `public` or `private` |

### Features

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `has_issues` | bool | `true` | Enable issues |
| `has_discussions` | bool | `false` | Enable discussions |
| `has_projects` | bool | `true` | Enable projects |
| `has_wiki` | bool | `true` | Enable wiki |
| `has_downloads` | bool | `true` | Enable downloads |

### Merge Settings

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `allow_merge_commit` | bool | `true` | Allow merge commits |
| `allow_squash_merge` | bool | `true` | Allow squash merging |
| `allow_rebase_merge` | bool | `true` | Allow rebase merging |
| `allow_auto_merge` | bool | `false` | Enable auto-merge |
| `delete_branch_on_merge` | bool | `true` | Auto-delete head branches |

### Other Settings

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `archived` | bool | `false` | Archive the repository |
| `topics` | list(string) | `[]` | Repository topics |
| `vulnerability_alerts` | bool | `true` | Enable Dependabot alerts |
| `auto_init` | bool | `true` | Initialize with README |
| `gitignore_template` | string | `null` | Gitignore template name |
| `license_template` | string | `null` | License template name |

## Repository Rulesets

Repository rulesets provide branch protection and code quality enforcement at the repository level.

### Ruleset Configuration

```yaml
rulesets:
  main-protection:
    name: "Main Branch Protection"
    enforcement: "active"
    target: "branch"

    # Branch patterns
    branch_patterns:
      - "~DEFAULT_BRANCH"  # Matches default branch
      - "main"
      - "master"

    # Bypass actors (optional)
    bypass_actors:
      - actor_id: 1234567
        actor_type: "Team"
        bypass_mode: "always"

    rules:
      # Prevent direct commits
      creation: false
      update: true
      deletion: true

      # Require linear history
      required_linear_history: true

      # Require signed commits
      required_signatures: false

      # Prevent force pushes
      non_fast_forward: true

      # Pull request requirements
      pull_request:
        required_approving_review_count: 1
        dismiss_stale_reviews_on_push: true
        require_code_owner_review: false
        require_last_push_approval: false
        required_review_thread_resolution: true

      # Required status checks
      required_status_checks:
        strict_required_status_checks_policy: true
        required_checks:
          - context: "ci/tests"
          - context: "ci/lint"
```

### Ruleset Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `name` | string | Yes | - | Ruleset name |
| `enforcement` | string | No | `"active"` | `active`, `evaluate`, or `disabled` |
| `target` | string | No | `"branch"` | Rule target (currently only `branch`) |
| `branch_patterns` | list(string) | No | `["~DEFAULT_BRANCH"]` | Branch patterns to match |
| `exclude_patterns` | list(string) | No | `[]` | Branch patterns to exclude |

### Rules

#### Basic Rules

| Rule | Type | Default | Description |
|------|------|---------|-------------|
| `creation` | bool | `false` | Block branch creation |
| `update` | bool | `true` | Require pull request for updates |
| `deletion` | bool | `true` | Block branch deletion |
| `required_linear_history` | bool | `false` | Require linear history |
| `required_signatures` | bool | `false` | Require signed commits |
| `non_fast_forward` | bool | `true` | Prevent force pushes |

#### Pull Request Rules

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `required_approving_review_count` | number | `1` | Minimum approvals required |
| `dismiss_stale_reviews_on_push` | bool | `true` | Dismiss stale reviews on push |
| `require_code_owner_review` | bool | `false` | Require code owner review |
| `require_last_push_approval` | bool | `false` | Require approval after last push |
| `required_review_thread_resolution` | bool | `false` | Require all threads resolved |

#### Status Check Rules

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `required_checks` | list(object) | `[]` | List of required status checks |
| `strict_required_status_checks_policy` | bool | `true` | Require branches to be up to date |

## Complete Example

```yaml title="configs/repositories.yaml"
repositories:
  my-awesome-app:
    name: "my-awesome-app"
    description: "An awesome application built with love"
    visibility: "public"

    # Enable useful features
    has_issues: true
    has_discussions: true
    has_projects: false
    has_wiki: false
    has_downloads: true

    # Require squash merging
    allow_merge_commit: false
    allow_squash_merge: true
    allow_rebase_merge: false
    delete_branch_on_merge: true

    topics:
      - "typescript"
      - "react"
      - "automation"

    vulnerability_alerts: true

    rulesets:
      main-protection:
        name: "Protect Main Branch"
        enforcement: "active"
        target: "branch"
        branch_patterns:
          - "main"

        rules:
          update: true
          deletion: true
          required_linear_history: true
          non_fast_forward: true

          pull_request:
            required_approving_review_count: 2
            dismiss_stale_reviews_on_push: true
            require_code_owner_review: true
            required_review_thread_resolution: true

          required_status_checks:
            strict_required_status_checks_policy: true
            required_checks:
              - context: "build"
              - context: "test"
              - context: "lint"
```

## Usage

### Deploy Repositories

```bash
cd repos
terraform init
terraform plan
terraform apply
```

### Add a New Repository

1. Edit `configs/repositories.yaml`
2. Add your repository configuration
3. Run `terraform plan` to review
4. Run `terraform apply` to create

### Update Rulesets

1. Edit the ruleset configuration in `configs/repositories.yaml`
2. Run `terraform plan` to review changes
3. Run `terraform apply` to update

## Best Practices

### Branch Protection

!!! tip "Always Protect Main"
    Always configure rulesets for your main/master branch to prevent accidental force pushes and require code review.

```yaml
rulesets:
  main-protection:
    name: "Main Branch Protection"
    branch_patterns:
      - "main"
    rules:
      update: true  # Require PR
      deletion: true  # Prevent deletion
      non_fast_forward: true  # Prevent force push
```

### Merge Strategy

Choose one merge strategy for consistency:

```yaml
# Squash merging (recommended for cleaner history)
allow_merge_commit: false
allow_squash_merge: true
allow_rebase_merge: false
```

### Topics

Use topics for discoverability:

```yaml
topics:
  - "language-typescript"
  - "framework-react"
  - "category-frontend"
  - "automation"
```

## Outputs

The module outputs repository information:

```hcl
output "repositories" {
  description = "Map of repository names to their full attributes"
  value = {
    for key, repo in github_repository.repos : key => {
      name     = repo.name
      html_url = repo.html_url
      ssh_url  = repo.ssh_clone_url
    }
  }
}
```

## Next Steps

- [Rulesets Module](rulesets.md) - Organization-level rulesets
- [Teams Module](teams.md) - Grant team access to repositories
- [Examples](../examples/basic-setup.md) - See practical examples
