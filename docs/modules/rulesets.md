# Organization Rulesets Module

The Organization Rulesets module manages organization-level rulesets for centralized branch protection policies across multiple repositories.

!!! warning "GitHub Team/Enterprise Required"
    Organization-level rulesets require a **GitHub Team or Enterprise** plan. For free tier, use [repository-level rulesets](repositories.md#repository-rulesets) instead.

## Overview

Organization rulesets provide:

- Centralized policy enforcement across multiple repositories
- Repository name pattern matching
- Branch pattern matching
- Bypass actors configuration
- Pull request and status check requirements

## Files

- `main.tf` - Organization ruleset resource definitions
- `locals.tf` - YAML configuration loading
- `configs/org_rulesets.yaml` - Ruleset definitions (YAML format)
- `providers.tf` - GitHub provider configuration
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `backend.tf` - Terraform backend configuration

## Configuration

Organization rulesets are defined in `configs/org_rulesets.yaml`.

### Ruleset Structure

```yaml
org_rulesets:
  ruleset-key:
    name: "Ruleset Name"
    enforcement: "active"  # active, evaluate, or disabled
    target: "branch"

    # Repository targeting
    repository_name_patterns:
      include:
        - "prod-*"
        - "main-*"
      exclude:
        - "*-test"

    # Branch targeting
    branch_patterns:
      include:
        - "main"
        - "master"
      exclude:
        - "experimental-*"

    # Bypass actors (optional)
    bypass_actors:
      - actor_id: 1234567
        actor_type: "Team"
        bypass_mode: "always"

    # Rules
    rules:
      creation: false
      update: true
      deletion: true
      required_linear_history: true
      required_signatures: false
      non_fast_forward: true

      pull_request:
        required_approving_review_count: 2
        dismiss_stale_reviews_on_push: true
        require_code_owner_review: true
        require_last_push_approval: false
        required_review_thread_resolution: true

      required_status_checks:
        strict_required_status_checks_policy: true
        required_checks:
          - context: "ci/tests"
          - context: "ci/security-scan"
```

## Ruleset Configuration

### Basic Settings

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `name` | string | Yes | - | Ruleset name |
| `enforcement` | string | No | `"active"` | Enforcement level |
| `target` | string | No | `"branch"` | Target type (currently only `branch`) |

**Enforcement Levels:**
- `active` - Enforces the rules
- `evaluate` - Dry-run mode (logs violations but doesn't block)
- `disabled` - Ruleset is disabled

### Repository Targeting

Target repositories using name patterns:

```yaml
repository_name_patterns:
  include:
    - "production-*"    # All repos starting with "production-"
    - "main-services"   # Exact match
    - "*-api"          # All repos ending with "-api"
  exclude:
    - "*-test"         # Exclude test repositories
    - "sandbox-*"      # Exclude sandbox repositories
```

!!! tip "Pattern Matching"
    - Use `*` as a wildcard
    - Patterns are case-sensitive
    - Include patterns are OR'd together
    - Exclude patterns take precedence

### Branch Targeting

Target specific branches:

```yaml
branch_patterns:
  include:
    - "main"
    - "master"
    - "release/*"
    - "hotfix/*"
  exclude:
    - "*/wip"
    - "experimental-*"
```

### Bypass Actors

Allow specific users, teams, or apps to bypass rules:

```yaml
bypass_actors:
  - actor_id: 1234567
    actor_type: "Team"
    bypass_mode: "always"

  - actor_id: 7654321
    actor_type: "OrganizationAdmin"
    bypass_mode: "pull_request"
```

**Actor Types:**
- `Team` - A team ID
- `OrganizationAdmin` - Organization administrators
- `RepositoryRole` - Repository role ID
- `Integration` - GitHub App ID

**Bypass Modes:**
- `always` - Can always bypass
- `pull_request` - Can bypass via pull request

## Rules

### Basic Rules

| Rule | Type | Default | Description |
|------|------|---------|-------------|
| `creation` | bool | `false` | Block branch creation |
| `update` | bool | `true` | Require pull request for updates |
| `deletion` | bool | `true` | Block branch deletion |
| `required_linear_history` | bool | `false` | Require linear history |
| `required_signatures` | bool | `false` | Require signed commits |
| `non_fast_forward` | bool | `true` | Prevent force pushes |

### Pull Request Rules

```yaml
pull_request:
  required_approving_review_count: 2
  dismiss_stale_reviews_on_push: true
  require_code_owner_review: true
  require_last_push_approval: false
  required_review_thread_resolution: true
```

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `required_approving_review_count` | number | `1` | Minimum required approvals |
| `dismiss_stale_reviews_on_push` | bool | `true` | Dismiss reviews on new push |
| `require_code_owner_review` | bool | `false` | Require code owner approval |
| `require_last_push_approval` | bool | `false` | Require approval after last push |
| `required_review_thread_resolution` | bool | `false` | All comments must be resolved |

### Status Check Rules

```yaml
required_status_checks:
  strict_required_status_checks_policy: true
  required_checks:
    - context: "ci/tests"
    - context: "ci/lint"
    - context: "security/scan"
```

| Field | Type | Description |
|-------|------|-------------|
| `required_checks` | list(object) | List of required check contexts |
| `strict_required_status_checks_policy` | bool | Require branch to be up to date |

## Complete Example

```yaml title="configs/org_rulesets.yaml"
org_rulesets:
  production-protection:
    name: "Production Branch Protection"
    enforcement: "active"
    target: "branch"

    # Apply to all production repositories
    repository_name_patterns:
      include:
        - "prod-*"
        - "production-*"
      exclude:
        - "*-sandbox"

    # Protect main and release branches
    branch_patterns:
      include:
        - "main"
        - "master"
        - "release/*"

    # Allow platform team to bypass
    bypass_actors:
      - actor_id: 5678901
        actor_type: "Team"
        bypass_mode: "always"

    rules:
      # Prevent direct commits
      update: true
      deletion: true
      non_fast_forward: true

      # Require 2 approvals for production
      pull_request:
        required_approving_review_count: 2
        dismiss_stale_reviews_on_push: true
        require_code_owner_review: true
        required_review_thread_resolution: true

      # Require all CI checks to pass
      required_status_checks:
        strict_required_status_checks_policy: true
        required_checks:
          - context: "ci/build"
          - context: "ci/test"
          - context: "ci/security-scan"
          - context: "ci/compliance-check"

  development-standards:
    name: "Development Standards"
    enforcement: "active"
    target: "branch"

    # Apply to development repositories
    repository_name_patterns:
      include:
        - "dev-*"
        - "*-service"

    # Protect development main branches
    branch_patterns:
      include:
        - "main"
        - "develop"

    rules:
      update: true
      deletion: true
      non_fast_forward: true

      # Require 1 approval for dev
      pull_request:
        required_approving_review_count: 1
        dismiss_stale_reviews_on_push: true

      # Basic CI checks
      required_status_checks:
        strict_required_status_checks_policy: true
        required_checks:
          - context: "ci/tests"
```

## Usage

### Deploy Organization Rulesets

```bash
cd rulesets
terraform init
terraform plan
terraform apply
```

### Add a New Ruleset

1. Edit `configs/org_rulesets.yaml`
2. Add your ruleset configuration
3. Run `terraform plan` to review
4. Run `terraform apply` to create

### Evaluate Mode (Testing)

Test rulesets before enforcing:

```yaml
org_rulesets:
  new-policy:
    name: "New Policy (Testing)"
    enforcement: "evaluate"  # Won't block, just logs
    # ... rest of configuration
```

## Best Practices

### Start with Evaluate Mode

!!! tip "Test First"
    Always start new rulesets in `evaluate` mode to understand the impact before enforcing.

```yaml
enforcement: "evaluate"  # Test first
# Later change to:
# enforcement: "active"
```

### Tiered Protection

Apply different rules based on environment:

```yaml
# Strict for production
production-protection:
  repository_name_patterns:
    include: ["prod-*"]
  rules:
    pull_request:
      required_approving_review_count: 2

# Relaxed for development
development-standards:
  repository_name_patterns:
    include: ["dev-*"]
  rules:
    pull_request:
      required_approving_review_count: 1
```

### Repository Patterns

Use clear naming conventions:

```
prod-*          → Production services
dev-*           → Development services
*-api           → API services
*-frontend      → Frontend applications
infra-*         → Infrastructure repositories
```

### Bypass Actors

Limit bypass actors to essential personnel:

```yaml
bypass_actors:
  # Platform team for emergency fixes
  - actor_id: 1234567
    actor_type: "Team"
    bypass_mode: "always"

  # Release managers for hotfixes
  - actor_id: 7654321
    actor_type: "Team"
    bypass_mode: "pull_request"
```

## Differences from Repository Rulesets

| Feature | Organization Rulesets | Repository Rulesets |
|---------|----------------------|---------------------|
| **Scope** | Multiple repositories | Single repository |
| **GitHub Plan** | Team/Enterprise | Free tier (public repos) |
| **Repository Targeting** | Pattern-based | N/A |
| **Centralized Management** | Yes | No |
| **Override Priority** | Lower (can be overridden by repo rules) | Higher |

!!! info "Ruleset Precedence"
    Repository rulesets take precedence over organization rulesets. Use organization rulesets for baseline policies and repository rulesets for specific requirements.

## Troubleshooting

### Plan Requirements Error

If you don't have Team/Enterprise:

```
Error: Organization rulesets require GitHub Team or Enterprise
```

**Solution:** Use [repository-level rulesets](repositories.md#repository-rulesets) instead.

### Invalid Actor ID

If you get invalid actor ID errors:

1. Get team ID: `gh api /orgs/YOUR_ORG/teams/TEAM_NAME --jq '.id'`
2. Get app ID: `gh api /orgs/YOUR_ORG/installations --jq '.[].app_id'`

## Next Steps

- [Repository Rulesets](repositories.md#repository-rulesets) - Free tier alternative
- [Teams Module](teams.md) - Manage bypass actor teams
- [Examples](../examples/advanced-config.md) - See advanced configurations
