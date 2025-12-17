# Basic Setup Examples

This page provides basic, real-world examples for common use cases.

## Example 1: Simple Public Repository

A basic public repository with minimal configuration.

```yaml title="configs/repositories.yaml"
repositories:
  simple-project:
    name: "simple-project"
    description: "A simple open-source project"
    visibility: "public"

    # Basic features
    has_issues: true
    has_wiki: false
    has_projects: false

    # Clean merge strategy
    allow_merge_commit: false
    allow_squash_merge: true
    allow_rebase_merge: false
    delete_branch_on_merge: true

    topics:
      - "opensource"
      - "example"
```

**Use case:** Simple open-source project without branch protection.

## Example 2: Repository with Branch Protection

Public repository with basic branch protection.

```yaml title="configs/repositories.yaml"
repositories:
  protected-repo:
    name: "protected-repo"
    description: "Repository with branch protection"
    visibility: "public"

    has_issues: true
    has_discussions: true
    vulnerability_alerts: true

    allow_merge_commit: false
    allow_squash_merge: true
    allow_rebase_merge: false
    delete_branch_on_merge: true

    topics:
      - "protected"
      - "ci-cd"

    # Branch protection
    rulesets:
      main-protection:
        name: "Protect Main"
        enforcement: "active"
        branch_patterns:
          - "main"

        rules:
          update: true  # Require PR
          deletion: true  # Block deletion
          non_fast_forward: true  # No force push

          pull_request:
            required_approving_review_count: 1
            dismiss_stale_reviews_on_push: true
```

**Use case:** Open-source project requiring code review.

## Example 3: Private Repository with Team Access

Private repository with team-based access control.

```yaml title="repos/configs/repositories.yaml"
repositories:
  internal-tool:
    name: "internal-tool"
    description: "Internal development tool"
    visibility: "private"

    has_issues: true
    has_wiki: true

    vulnerability_alerts: true

    rulesets:
      main-protection:
        name: "Main Protection"
        enforcement: "active"
        branch_patterns:
          - "main"

        rules:
          update: true
          deletion: true
          non_fast_forward: true

          pull_request:
            required_approving_review_count: 1
            require_code_owner_review: false
```

```yaml title="teams/configs/teams.yaml"
teams:
  developers:
    name: "Developers"
    description: "Development team"
    privacy: "closed"

    members:
      - username: "alice"
        role: "maintainer"
      - username: "bob"
        role: "member"

    repositories:
      - repository: "internal-tool"
        permission: "push"
```

**Use case:** Internal tool with team access.

## Example 4: Multi-Repository Setup

Multiple related repositories with consistent settings.

```yaml title="configs/repositories.yaml"
repositories:
  # Frontend repository
  web-frontend:
    name: "web-frontend"
    description: "Web application frontend"
    visibility: "private"

    has_issues: true
    allow_squash_merge: true
    delete_branch_on_merge: true

    topics:
      - "frontend"
      - "react"
      - "typescript"

    rulesets:
      main-protection:
        name: "Main Protection"
        enforcement: "active"
        branch_patterns:
          - "main"
        rules:
          update: true
          deletion: true
          pull_request:
            required_approving_review_count: 1

  # Backend repository
  web-backend:
    name: "web-backend"
    description: "Web application backend API"
    visibility: "private"

    has_issues: true
    allow_squash_merge: true
    delete_branch_on_merge: true

    topics:
      - "backend"
      - "nodejs"
      - "api"

    rulesets:
      main-protection:
        name: "Main Protection"
        enforcement: "active"
        branch_patterns:
          - "main"
        rules:
          update: true
          deletion: true
          pull_request:
            required_approving_review_count: 1
            required_review_thread_resolution: true

  # Shared infrastructure
  infrastructure:
    name: "infrastructure"
    description: "Shared infrastructure code"
    visibility: "private"

    has_issues: true
    allow_squash_merge: true

    topics:
      - "infrastructure"
      - "terraform"
      - "aws"

    rulesets:
      main-protection:
        name: "Main Protection"
        enforcement: "active"
        branch_patterns:
          - "main"
        rules:
          update: true
          deletion: true
          pull_request:
            required_approving_review_count: 2  # Higher for infra
            require_code_owner_review: true
```

**Use case:** Full-stack application with frontend, backend, and infrastructure.

## Example 5: Basic Team Structure

Simple team structure for a small organization.

```yaml title="configs/teams.yaml"
teams:
  # Admin team
  admins:
    name: "Administrators"
    description: "Organization administrators"
    privacy: "closed"

    members:
      - username: "admin1"
        role: "maintainer"
      - username: "admin2"
        role: "maintainer"

    repositories:
      - repository: "web-frontend"
        permission: "admin"
      - repository: "web-backend"
        permission: "admin"
      - repository: "infrastructure"
        permission: "admin"

  # Developer team
  developers:
    name: "Developers"
    description: "Development team"
    privacy: "closed"

    members:
      - username: "dev1"
        role: "member"
      - username: "dev2"
        role: "member"
      - username: "dev3"
        role: "member"

    repositories:
      - repository: "web-frontend"
        permission: "push"
      - repository: "web-backend"
        permission: "push"
      - repository: "infrastructure"
        permission: "pull"  # Read-only

  # External contractors
  contractors:
    name: "External Contractors"
    description: "Temporary external access"
    privacy: "closed"

    members:
      - username: "contractor1"
        role: "member"

    repositories:
      - repository: "web-frontend"
        permission: "push"
```

**Use case:** Small team with admins, developers, and contractors.

## Example 6: Organization Settings

Basic organization configuration.

```hcl title="org_configurations/locals.tf"
locals {
  environment = {
    github = {
      organization = {
        billing_email = "billing@example.com"
        description   = "Example Organization - DevOps Automation"

        # Restrict member permissions
        members_can_create_repositories         = false
        members_can_create_public_repositories  = false
        members_can_create_private_repositories = false
        members_can_create_pages                = false
        members_can_fork_private_repositories   = false
      }
    }
  }
}
```

**Use case:** Secure organization with restricted member permissions.

## Example 7: Status Checks Integration

Repository with required CI checks.

```yaml title="configs/repositories.yaml"
repositories:
  ci-integrated-app:
    name: "ci-integrated-app"
    description: "Application with CI/CD pipeline"
    visibility: "public"

    has_issues: true
    vulnerability_alerts: true

    allow_squash_merge: true
    delete_branch_on_merge: true

    topics:
      - "ci-cd"
      - "github-actions"

    rulesets:
      main-protection:
        name: "Main with CI"
        enforcement: "active"
        branch_patterns:
          - "main"

        rules:
          update: true
          deletion: true
          non_fast_forward: true

          pull_request:
            required_approving_review_count: 1
            dismiss_stale_reviews_on_push: true

          # Required status checks
          required_status_checks:
            strict_required_status_checks_policy: true
            required_checks:
              - context: "build"
              - context: "test"
              - context: "lint"
```

**Use case:** Repository with CI/CD requiring checks to pass.

## Example 8: Multiple Branch Patterns

Protecting multiple branches with different rules.

```yaml title="configs/repositories.yaml"
repositories:
  multi-branch-app:
    name: "multi-branch-app"
    description: "App with multiple protected branches"
    visibility: "private"

    rulesets:
      # Protect main branch (strict)
      main-protection:
        name: "Main Protection"
        enforcement: "active"
        branch_patterns:
          - "main"

        rules:
          update: true
          deletion: true
          non_fast_forward: true

          pull_request:
            required_approving_review_count: 2
            require_code_owner_review: true
            required_review_thread_resolution: true

      # Protect release branches (moderate)
      release-protection:
        name: "Release Protection"
        enforcement: "active"
        branch_patterns:
          - "release/*"

        rules:
          update: true
          deletion: true
          non_fast_forward: true

          pull_request:
            required_approving_review_count: 1
            dismiss_stale_reviews_on_push: true

      # Protect develop branch (relaxed)
      develop-protection:
        name: "Develop Protection"
        enforcement: "active"
        branch_patterns:
          - "develop"

        rules:
          update: true
          deletion: false  # Allow deletion
          non_fast_forward: false  # Allow force push

          pull_request:
            required_approving_review_count: 1
```

**Use case:** Git flow with different protection levels.

## Next Steps

- [Advanced Configuration](advanced-config.md) - Complex scenarios
- [Best Practices](best-practices.md) - Tips and recommendations
- [Modules Documentation](../modules/organization.md) - Detailed reference
