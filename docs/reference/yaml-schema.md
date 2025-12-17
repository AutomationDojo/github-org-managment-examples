# YAML Schema Reference

Complete reference for YAML configuration schema.

## Repository Configuration Schema

### Top-Level Structure

```yaml
repositories:
  <repository-key>:
    # Configuration for each repository
```

### Repository Fields

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `name` | string | ✅ Yes | - | Repository name (must be unique in org) |
| `description` | string | No | `null` | Repository description |
| `visibility` | string | No | `"private"` | `"public"` or `"private"` |
| `has_issues` | boolean | No | `true` | Enable issues |
| `has_discussions` | boolean | No | `false` | Enable discussions |
| `has_projects` | boolean | No | `true` | Enable projects |
| `has_wiki` | boolean | No | `true` | Enable wiki |
| `has_downloads` | boolean | No | `true` | Enable downloads |
| `allow_merge_commit` | boolean | No | `true` | Allow merge commits |
| `allow_squash_merge` | boolean | No | `true` | Allow squash merging |
| `allow_rebase_merge` | boolean | No | `true` | Allow rebase merging |
| `allow_auto_merge` | boolean | No | `false` | Enable auto-merge |
| `delete_branch_on_merge` | boolean | No | `true` | Auto-delete head branches after merge |
| `archived` | boolean | No | `false` | Archive the repository |
| `topics` | list(string) | No | `[]` | Repository topics/tags |
| `vulnerability_alerts` | boolean | No | `true` | Enable Dependabot alerts |
| `auto_init` | boolean | No | `true` | Initialize with README |
| `gitignore_template` | string | No | `null` | Gitignore template name |
| `license_template` | string | No | `null` | License template name |
| `rulesets` | map(object) | No | `{}` | Repository rulesets |

### Ruleset Schema

```yaml
rulesets:
  <ruleset-key>:
    name: string                    # Required
    enforcement: string             # Optional: "active" | "evaluate" | "disabled"
    target: string                  # Optional: "branch" (only option currently)
    branch_patterns: list(string)   # Optional
    exclude_patterns: list(string)  # Optional
    bypass_actors: list(object)     # Optional
    rules: object                   # Required
```

#### Ruleset Fields

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `name` | string | ✅ Yes | - | Ruleset name |
| `enforcement` | string | No | `"active"` | Enforcement level: `"active"`, `"evaluate"`, or `"disabled"` |
| `target` | string | No | `"branch"` | Target type (only `"branch"` supported) |
| `branch_patterns` | list(string) | No | `["~DEFAULT_BRANCH"]` | Branch patterns to match |
| `exclude_patterns` | list(string) | No | `[]` | Branch patterns to exclude |
| `bypass_actors` | list(object) | No | `[]` | Users/teams that can bypass rules |
| `rules` | object | ✅ Yes | - | Protection rules |

#### Branch Patterns

Special patterns:

- `~DEFAULT_BRANCH` - Matches the repository's default branch
- `main` - Matches exact branch name
- `release/*` - Matches all branches starting with `release/`
- `*-wip` - Matches all branches ending with `-wip`

#### Bypass Actors Schema

```yaml
bypass_actors:
  - actor_id: number      # Required: ID of user, team, or app
    actor_type: string    # Required: "Team" | "OrganizationAdmin" | "RepositoryRole" | "Integration"
    bypass_mode: string   # Optional: "always" | "pull_request"
```

### Rules Schema

```yaml
rules:
  # Basic rules
  creation: boolean                  # Optional: Block branch creation
  update: boolean                    # Optional: Require PR for updates
  deletion: boolean                  # Optional: Block branch deletion
  required_linear_history: boolean   # Optional: Require linear history
  required_signatures: boolean       # Optional: Require signed commits
  non_fast_forward: boolean          # Optional: Prevent force pushes

  # Pull request rules
  pull_request:
    required_approving_review_count: number       # Optional: Min approvals
    dismiss_stale_reviews_on_push: boolean        # Optional: Dismiss on push
    require_code_owner_review: boolean            # Optional: Require CODEOWNERS
    require_last_push_approval: boolean           # Optional: Approval after push
    required_review_thread_resolution: boolean    # Optional: Resolve all threads

  # Status check rules
  required_status_checks:
    strict_required_status_checks_policy: boolean  # Optional: Require up-to-date
    required_checks:
      - context: string   # Required: Check context name
```

#### Rules Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `creation` | boolean | `false` | Block branch creation |
| `update` | boolean | `true` | Require pull request for updates |
| `deletion` | boolean | `true` | Block branch deletion |
| `required_linear_history` | boolean | `false` | Require linear commit history |
| `required_signatures` | boolean | `false` | Require signed commits (GPG) |
| `non_fast_forward` | boolean | `true` | Prevent force pushes |

#### Pull Request Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `required_approving_review_count` | number | `1` | Minimum approving reviews (0-6) |
| `dismiss_stale_reviews_on_push` | boolean | `true` | Dismiss approvals on new push |
| `require_code_owner_review` | boolean | `false` | Require code owner approval |
| `require_last_push_approval` | boolean | `false` | Require approval after last push |
| `required_review_thread_resolution` | boolean | `false` | All comments must be resolved |

#### Status Check Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `strict_required_status_checks_policy` | boolean | `true` | Branch must be up-to-date |
| `required_checks` | list(object) | `[]` | List of required status checks |

### Complete Repository Example

```yaml
repositories:
  my-app:
    # Basic settings
    name: "my-app"
    description: "My application"
    visibility: "public"

    # Features
    has_issues: true
    has_discussions: true
    has_projects: false
    has_wiki: false
    has_downloads: true

    # Merge settings
    allow_merge_commit: false
    allow_squash_merge: true
    allow_rebase_merge: false
    allow_auto_merge: false
    delete_branch_on_merge: true

    # Other
    archived: false
    topics:
      - "typescript"
      - "react"
    vulnerability_alerts: true
    auto_init: true
    gitignore_template: "Node"
    license_template: "mit"

    # Rulesets
    rulesets:
      main-protection:
        name: "Main Branch Protection"
        enforcement: "active"
        target: "branch"
        branch_patterns:
          - "main"
        exclude_patterns:
          - "experimental-*"

        bypass_actors:
          - actor_id: 1234567
            actor_type: "Team"
            bypass_mode: "always"

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
              - context: "ci/build"
              - context: "ci/test"
```

## Team Configuration Schema

### Top-Level Structure

```yaml
teams:
  <team-key>:
    # Configuration for each team
```

### Team Fields

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `name` | string | ✅ Yes | - | Team display name |
| `description` | string | No | `null` | Team description |
| `privacy` | string | No | `"closed"` | `"closed"` or `"secret"` |
| `members` | list(object) | No | `[]` | Team members |
| `repositories` | list(object) | No | `[]` | Repository access |

### Member Schema

```yaml
members:
  - username: string   # Required: GitHub username
    role: string       # Required: "maintainer" | "member"
```

#### Member Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `username` | string | ✅ Yes | GitHub username |
| `role` | string | ✅ Yes | `"maintainer"` or `"member"` |

### Repository Access Schema

```yaml
repositories:
  - repository: string   # Required: Repository name
    permission: string   # Required: Permission level
```

#### Repository Access Fields

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `repository` | string | ✅ Yes | Repository name (without org prefix) |
| `permission` | string | ✅ Yes | Permission level |

**Permission Levels:**

| Permission | Access Level |
|-----------|-------------|
| `pull` | Read-only |
| `triage` | Read + manage issues/PRs |
| `push` | Read + write code |
| `maintain` | Push + manage settings |
| `admin` | Full repository access |

### Complete Team Example

```yaml
teams:
  platform-team:
    # Team settings
    name: "Platform Engineering"
    description: "Platform and infrastructure team"
    privacy: "closed"

    # Members
    members:
      - username: "alice"
        role: "maintainer"
      - username: "bob"
        role: "maintainer"
      - username: "charlie"
        role: "member"
      - username: "diana"
        role: "member"

    # Repository access
    repositories:
      - repository: "infrastructure"
        permission: "admin"
      - repository: "platform-tools"
        permission: "admin"
      - repository: "web-app"
        permission: "maintain"
      - repository: "documentation"
        permission: "push"

  developers:
    name: "Developers"
    description: "Development team"
    privacy: "closed"

    members:
      - username: "dev1"
        role: "member"
      - username: "dev2"
        role: "member"

    repositories:
      - repository: "web-app"
        permission: "push"
      - repository: "infrastructure"
        permission: "pull"
```

## Organization Ruleset Schema

!!! warning "Requires GitHub Team/Enterprise"

### Top-Level Structure

```yaml
org_rulesets:
  <ruleset-key>:
    # Configuration for each organization ruleset
```

### Organization Ruleset Fields

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `name` | string | ✅ Yes | - | Ruleset name |
| `enforcement` | string | No | `"active"` | Enforcement level |
| `target` | string | No | `"branch"` | Target type |
| `repository_name_patterns` | object | No | `{}` | Repository targeting |
| `branch_patterns` | object | No | `{}` | Branch targeting |
| `bypass_actors` | list(object) | No | `[]` | Bypass actors |
| `rules` | object | ✅ Yes | - | Protection rules |

### Repository Name Patterns Schema

```yaml
repository_name_patterns:
  include:
    - string  # Pattern to include
  exclude:
    - string  # Pattern to exclude
```

### Branch Patterns Schema

```yaml
branch_patterns:
  include:
    - string  # Pattern to include
  exclude:
    - string  # Pattern to exclude
```

### Complete Organization Ruleset Example

```yaml
org_rulesets:
  production-protection:
    name: "Production Protection"
    enforcement: "active"
    target: "branch"

    repository_name_patterns:
      include:
        - "prod-*"
        - "production-*"
      exclude:
        - "*-test"
        - "*-sandbox"

    branch_patterns:
      include:
        - "main"
        - "master"
        - "release/*"
      exclude:
        - "*/wip"

    bypass_actors:
      - actor_id: 1234567
        actor_type: "Team"
        bypass_mode: "always"

    rules:
      update: true
      deletion: true
      non_fast_forward: true
      required_linear_history: true

      pull_request:
        required_approving_review_count: 2
        require_code_owner_review: true
        required_review_thread_resolution: true

      required_status_checks:
        strict_required_status_checks_policy: true
        required_checks:
          - context: "ci/build"
          - context: "ci/test"
```

## Validation

### YAML Validation

Use a YAML linter to validate syntax:

```bash
# Install yamllint
pip install yamllint

# Validate
yamllint configs/repositories.yaml
```

### Terraform Validation

Validate configuration with Terraform:

```bash
# Format check
terraform fmt -check

# Validate
terraform validate

# Plan
terraform plan
```

## Next Steps

- [Troubleshooting](troubleshooting.md) - Common issues and solutions
- [Examples](../examples/basic-setup.md) - See practical examples
- [Module Documentation](../modules/repositories.md) - Detailed module docs
