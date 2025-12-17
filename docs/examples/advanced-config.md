# Advanced Configuration Examples

Advanced patterns for complex organizational needs.

## Multi-Environment Setup

Manage different environments with separate configurations.

### Directory Structure

```
repos/
├── main.tf
├── locals.tf
├── configs/
│   ├── repositories-dev.yaml
│   ├── repositories-staging.yaml
│   └── repositories-prod.yaml
```

### Workspace-Based Configuration

```hcl title="locals.tf"
locals {
  environment = terraform.workspace

  repositories = yamldecode(
    file("${path.module}/configs/repositories-${local.environment}.yaml")
  ).repositories
}
```

### Environment-Specific Configurations

=== "Development"
    ```yaml title="configs/repositories-dev.yaml"
    repositories:
      my-app-dev:
        name: "my-app-dev"
        visibility: "private"

        rulesets:
          main-protection:
            name: "Dev Protection"
            enforcement: "evaluate"  # Dry-run mode
            branch_patterns:
              - "main"
            rules:
              update: true
              pull_request:
                required_approving_review_count: 1
    ```

=== "Staging"
    ```yaml title="configs/repositories-staging.yaml"
    repositories:
      my-app-staging:
        name: "my-app-staging"
        visibility: "private"

        rulesets:
          main-protection:
            name: "Staging Protection"
            enforcement: "active"
            branch_patterns:
              - "main"
            rules:
              update: true
              pull_request:
                required_approving_review_count: 1
                require_code_owner_review: true
    ```

=== "Production"
    ```yaml title="configs/repositories-prod.yaml"
    repositories:
      my-app-prod:
        name: "my-app-prod"
        visibility: "private"

        rulesets:
          main-protection:
            name: "Production Protection"
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
    ```

### Usage

```bash
# Deploy to development
terraform workspace select dev
terraform apply

# Deploy to staging
terraform workspace select staging
terraform apply

# Deploy to production
terraform workspace select prod
terraform apply
```

## Organization Rulesets (Team/Enterprise)

!!! warning "Requires GitHub Team/Enterprise Plan"

### Tiered Protection by Repository Pattern

```yaml title="rulesets/configs/org_rulesets.yaml"
org_rulesets:
  # Critical production services
  production-critical:
    name: "Production Critical Services"
    enforcement: "active"

    repository_name_patterns:
      include:
        - "prod-*"
        - "production-*"
      exclude:
        - "*-sandbox"
        - "*-test"

    branch_patterns:
      include:
        - "main"
        - "master"

    bypass_actors:
      - actor_id: 1234567  # SRE team
        actor_type: "Team"
        bypass_mode: "pull_request"

    rules:
      update: true
      deletion: true
      required_linear_history: true
      required_signatures: true
      non_fast_forward: true

      pull_request:
        required_approving_review_count: 3  # 3 approvals
        require_code_owner_review: true
        require_last_push_approval: true
        required_review_thread_resolution: true

      required_status_checks:
        strict_required_status_checks_policy: true
        required_checks:
          - context: "ci/build"
          - context: "ci/test"
          - context: "ci/security-scan"
          - context: "ci/compliance-check"
          - context: "ci/performance-test"

  # Standard services
  standard-services:
    name: "Standard Services"
    enforcement: "active"

    repository_name_patterns:
      include:
        - "*-service"
        - "*-api"

    branch_patterns:
      include:
        - "main"

    rules:
      update: true
      deletion: true
      non_fast_forward: true

      pull_request:
        required_approving_review_count: 2
        require_code_owner_review: true
        dismiss_stale_reviews_on_push: true

      required_status_checks:
        strict_required_status_checks_policy: true
        required_checks:
          - context: "ci/test"
          - context: "ci/lint"

  # Development repositories
  development:
    name: "Development Standards"
    enforcement: "active"

    repository_name_patterns:
      include:
        - "dev-*"
        - "*-poc"

    branch_patterns:
      include:
        - "main"
        - "develop"

    rules:
      update: true
      deletion: false  # Allow deletion
      non_fast_forward: false  # Allow force push

      pull_request:
        required_approving_review_count: 1
```

## Complex Team Hierarchies

### Multi-Level Team Structure

```yaml title="teams/configs/teams.yaml"
teams:
  # Executive level
  engineering-leadership:
    name: "Engineering Leadership"
    description: "Engineering executives and directors"
    privacy: "closed"

    members:
      - username: "cto"
        role: "maintainer"
      - username: "vp-engineering"
        role: "maintainer"

    repositories:
      - repository: "infrastructure"
        permission: "admin"
      - repository: "security-policies"
        permission: "admin"

  # Platform level
  platform-team:
    name: "Platform Engineering"
    description: "Platform and infrastructure team"
    privacy: "closed"

    members:
      - username: "platform-lead"
        role: "maintainer"
      - username: "sre-1"
        role: "member"
      - username: "sre-2"
        role: "member"

    repositories:
      - repository: "infrastructure"
        permission: "admin"
      - repository: "platform-tools"
        permission: "admin"
      - repository: "monitoring"
        permission: "admin"

  # Product teams
  product-team-alpha:
    name: "Product Team Alpha"
    description: "Alpha product development team"
    privacy: "closed"

    members:
      - username: "alpha-lead"
        role: "maintainer"
      - username: "alpha-frontend-dev"
        role: "member"
      - username: "alpha-backend-dev"
        role: "member"

    repositories:
      - repository: "alpha-frontend"
        permission: "push"
      - repository: "alpha-backend"
        permission: "push"
      - repository: "alpha-mobile"
        permission: "push"
      - repository: "infrastructure"
        permission: "pull"  # Read-only
      - repository: "shared-components"
        permission: "maintain"

  product-team-beta:
    name: "Product Team Beta"
    description: "Beta product development team"
    privacy: "closed"

    members:
      - username: "beta-lead"
        role: "maintainer"
      - username: "beta-fullstack-1"
        role: "member"
      - username: "beta-fullstack-2"
        role: "member"

    repositories:
      - repository: "beta-app"
        permission: "push"
      - repository: "beta-api"
        permission: "push"
      - repository: "infrastructure"
        permission: "pull"
      - repository: "shared-components"
        permission: "maintain"

  # Cross-functional teams
  security-team:
    name: "Security Team"
    description: "Application and infrastructure security"
    privacy: "secret"  # Hidden team

    members:
      - username: "security-lead"
        role: "maintainer"
      - username: "security-engineer-1"
        role: "member"
      - username: "security-engineer-2"
        role: "member"

    repositories:
      # Admin access to audit all repos
      - repository: "infrastructure"
        permission: "maintain"
      - repository: "alpha-frontend"
        permission: "maintain"
      - repository: "alpha-backend"
        permission: "maintain"
      - repository: "beta-app"
        permission: "maintain"
      - repository: "beta-api"
        permission: "maintain"
      # Exclusive access to security tools
      - repository: "security-tools"
        permission: "admin"
      - repository: "vulnerability-tracking"
        permission: "admin"

  qa-automation:
    name: "QA Automation"
    description: "Quality assurance and test automation"
    privacy: "closed"

    members:
      - username: "qa-lead"
        role: "maintainer"
      - username: "qa-engineer-1"
        role: "member"
      - username: "qa-engineer-2"
        role: "member"

    repositories:
      # Write access to test repositories
      - repository: "qa-automation-tests"
        permission: "push"
      # Read access to product repos
      - repository: "alpha-frontend"
        permission: "pull"
      - repository: "alpha-backend"
        permission: "pull"
      - repository: "beta-app"
        permission: "pull"
      - repository: "beta-api"
        permission: "pull"

  # External access
  external-partners:
    name: "External Partners"
    description: "External contractors and partners"
    privacy: "closed"

    members:
      - username: "partner-contractor-1"
        role: "member"
      - username: "partner-contractor-2"
        role: "member"

    repositories:
      - repository: "partner-integration-project"
        permission: "push"
      - repository: "shared-api-docs"
        permission: "pull"
```

## Monorepo with Rulesets

Protect different paths in a monorepo.

```yaml title="configs/repositories.yaml"
repositories:
  monorepo:
    name: "company-monorepo"
    description: "Company-wide monorepo"
    visibility: "private"

    has_issues: true
    has_projects: true

    allow_squash_merge: true
    delete_branch_on_merge: true

    rulesets:
      # Protect main branch strictly
      main-protection:
        name: "Main Branch Protection"
        enforcement: "active"
        branch_patterns:
          - "main"

        rules:
          update: true
          deletion: true
          required_linear_history: true
          non_fast_forward: true

          pull_request:
            required_approving_review_count: 2
            require_code_owner_review: true  # Use CODEOWNERS file
            required_review_thread_resolution: true

          required_status_checks:
            strict_required_status_checks_policy: true
            required_checks:
              - context: "build"
              - context: "test"
              - context: "lint"

      # Protect release branches
      release-protection:
        name: "Release Branch Protection"
        enforcement: "active"
        branch_patterns:
          - "release/*"

        rules:
          update: true
          deletion: true
          non_fast_forward: true

          pull_request:
            required_approving_review_count: 3  # Stricter for releases
            require_code_owner_review: true
            require_last_push_approval: true

          required_status_checks:
            strict_required_status_checks_policy: true
            required_checks:
              - context: "build"
              - context: "test"
              - context: "integration-test"
              - context: "security-scan"
```

With CODEOWNERS file for path-based reviews:

```text title="CODEOWNERS"
# Default owners for everything
* @company/engineering-leadership

# Frontend code
/apps/frontend/ @company/frontend-team
/packages/ui/ @company/frontend-team

# Backend code
/apps/backend/ @company/backend-team
/packages/api/ @company/backend-team

# Infrastructure
/infrastructure/ @company/platform-team
/terraform/ @company/platform-team
/kubernetes/ @company/platform-team

# Security-sensitive paths
/apps/*/auth/ @company/security-team
/packages/auth/ @company/security-team
/.github/workflows/ @company/platform-team @company/security-team
```

## Dynamic Configuration with Templating

Use external data sources to generate configurations.

### Using External Script

```hcl title="locals.tf"
locals {
  # Load from external script
  repos_json = jsondecode(
    file("${path.module}/scripts/generate-repos.json")
  )

  # Or execute a script
  repos_from_script = jsondecode(
    data.external.repos.result.repositories
  )
}

data "external" "repos" {
  program = ["python3", "${path.module}/scripts/generate-repos.py"]
}
```

```python title="scripts/generate-repos.py"
#!/usr/bin/env python3
import json
import sys

# Generate repositories dynamically
repos = {
    "repositories": json.dumps({
        f"service-{i}": {
            "name": f"service-{i}",
            "description": f"Microservice {i}",
            "visibility": "private"
        }
        for i in range(1, 11)  # Create 10 services
    })
}

print(json.dumps(repos))
```

## Compliance and Audit

Configuration for regulated environments.

```yaml title="configs/repositories.yaml"
repositories:
  financial-service:
    name: "financial-service"
    description: "Financial services application - SOC2 compliant"
    visibility: "private"

    vulnerability_alerts: true

    topics:
      - "finance"
      - "pci-compliant"
      - "soc2"

    rulesets:
      compliance-ruleset:
        name: "Compliance Enforcement"
        enforcement: "active"
        branch_patterns:
          - "main"
          - "release/*"
          - "hotfix/*"

        rules:
          # Require all commits to be signed
          required_signatures: true

          # Require linear history for audit
          required_linear_history: true

          # Strict PR requirements
          update: true
          deletion: true
          non_fast_forward: true

          pull_request:
            # Require multiple approvals
            required_approving_review_count: 2

            # Require code owner approval
            require_code_owner_review: true

            # Require approval after last push
            require_last_push_approval: true

            # All conversations must be resolved
            required_review_thread_resolution: true

            # Dismiss stale reviews
            dismiss_stale_reviews_on_push: true

          # Comprehensive CI checks
          required_status_checks:
            strict_required_status_checks_policy: true
            required_checks:
              - context: "build"
              - context: "unit-tests"
              - context: "integration-tests"
              - context: "security-scan"
              - context: "dependency-check"
              - context: "license-check"
              - context: "sast-scan"
              - context: "dast-scan"
              - context: "compliance-check"
```

## Next Steps

- [Best Practices](best-practices.md) - Optimization tips
- [Basic Setup](basic-setup.md) - Simpler examples
- [YAML Schema Reference](../reference/yaml-schema.md) - Complete schema
