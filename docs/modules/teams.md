# Teams Module

The Teams module manages GitHub teams, team memberships, and repository access permissions.

## Overview

This module manages:

- Team creation with privacy settings
- Team member management with roles
- Repository access control with granular permissions
- Support for external collaborators

## Files

- `main.tf` - Team, membership, and repository access resources
- `locals.tf` - YAML configuration loading and data flattening
- `configs/teams.yaml` - Team definitions (YAML format)
- `providers.tf` - GitHub provider configuration
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `backend.tf` - Terraform backend configuration

## Configuration

Teams are defined in `configs/teams.yaml` with a nested structure for members and repository access.

### Team Structure

```yaml
teams:
  team-key:
    name: "Team Display Name"
    description: "Team description"
    privacy: "closed"  # closed or secret

    members:
      - username: "user1"
        role: "maintainer"  # maintainer or member
      - username: "user2"
        role: "member"

    repositories:
      - repository: "repo-name"
        permission: "push"  # pull, triage, push, maintain, admin
      - repository: "another-repo"
        permission: "pull"
```

## Team Configuration

### Team Settings

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `name` | string | Yes | - | Team display name |
| `description` | string | No | `null` | Team description |
| `privacy` | string | No | `"closed"` | `closed` or `secret` |

**Privacy Levels:**
- `closed` - Visible to all organization members
- `secret` - Only visible to team members and organization owners

### Members

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `username` | string | Yes | GitHub username |
| `role` | string | Yes | `maintainer` or `member` |

**Roles:**
- `maintainer` - Can add/remove members and manage team settings
- `member` - Regular team member

### Repository Access

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `repository` | string | Yes | Repository name |
| `permission` | string | Yes | Permission level |

**Permission Levels:**
- `pull` - Read-only access
- `triage` - Read + manage issues/PRs (no code changes)
- `push` - Read + write code access
- `maintain` - Push + manage repository settings (no admin)
- `admin` - Full repository access

## Complete Example

```yaml title="configs/teams.yaml"
teams:
  platform-team:
    name: "Platform Engineering"
    description: "Core platform team maintaining infrastructure and tools"
    privacy: "closed"

    members:
      - username: "alice"
        role: "maintainer"
      - username: "bob"
        role: "maintainer"
      - username: "charlie"
        role: "member"

    repositories:
      - repository: "infrastructure"
        permission: "admin"
      - repository: "platform-tools"
        permission: "admin"
      - repository: "documentation"
        permission: "push"

  frontend-team:
    name: "Frontend Engineers"
    description: "Frontend development team"
    privacy: "closed"

    members:
      - username: "david"
        role: "maintainer"
      - username: "eve"
        role: "member"
      - username: "frank"
        role: "member"

    repositories:
      - repository: "web-app"
        permission: "push"
      - repository: "mobile-app"
        permission: "push"
      - repository: "design-system"
        permission: "maintain"
      - repository: "backend-api"
        permission: "pull"  # Read-only for coordination

  security-team:
    name: "Security Team"
    description: "Security and compliance team"
    privacy: "secret"  # Secret team for security

    members:
      - username: "grace"
        role: "maintainer"
      - username: "henry"
        role: "member"

    repositories:
      - repository: "security-tools"
        permission: "admin"
      - repository: "infrastructure"
        permission: "maintain"
      - repository: "web-app"
        permission: "maintain"

  external-contractors:
    name: "External Contractors"
    description: "External collaborators with limited access"
    privacy: "closed"

    members:
      - username: "contractor1"
        role: "member"
      - username: "contractor2"
        role: "member"

    repositories:
      - repository: "project-alpha"
        permission: "push"
      - repository: "documentation"
        permission: "pull"
```

## Usage

### Deploy Teams

```bash
cd teams
terraform init
terraform plan
terraform apply
```

### Add a New Team

1. Edit `configs/teams.yaml`
2. Add your team configuration
3. Run `terraform plan` to review
4. Run `terraform apply` to create

### Add Team Members

1. Add member to team in `configs/teams.yaml`:
```yaml
members:
  - username: "newuser"
    role: "member"
```
2. Run `terraform apply`

### Grant Repository Access

1. Add repository to team in `configs/teams.yaml`:
```yaml
repositories:
  - repository: "new-repo"
    permission: "push"
```
2. Run `terraform apply`

## Resource Types

The module creates three types of resources:

### 1. github_team

Creates the team:

```hcl
resource "github_team" "teams" {
  for_each = local.teams

  name        = each.value.name
  description = try(each.value.description, null)
  privacy     = try(each.value.privacy, "closed")
}
```

### 2. github_team_membership

Adds members to teams:

```hcl
resource "github_team_membership" "members" {
  for_each = {
    for tm in local.team_members : "${tm.team_key}-${tm.username}" => tm
  }

  team_id  = github_team.teams[each.value.team_key].id
  username = each.value.username
  role     = each.value.role
}
```

### 3. github_team_repository

Grants team access to repositories:

```hcl
resource "github_team_repository" "team_repos" {
  for_each = {
    for tr in local.team_repositories : "${tr.team_key}-${tr.repository}" => tr
  }

  team_id    = github_team.teams[each.value.team_key].id
  repository = each.value.repository
  permission = each.value.permission
}
```

## Data Transformation

The `locals.tf` file flattens the nested YAML structure into flat lists for Terraform:

```hcl
# Load teams from YAML
teams = yamldecode(file("${path.module}/configs/teams.yaml")).teams

# Flatten team members
team_members = flatten([
  for team_key, team in local.teams : [
    for member in try(team.members, []) : {
      team_key = team_key
      username = member.username
      role     = member.role
    }
  ]
])

# Flatten team repositories
team_repositories = flatten([
  for team_key, team in local.teams : [
    for repo in try(team.repositories, []) : {
      team_key   = team_key
      repository = repo.repository
      permission = repo.permission
    }
  ]
])
```

## Best Practices

### Team Structure

!!! tip "Organize by Function"
    Create teams based on functional areas (platform, frontend, backend) rather than projects.

```yaml
teams:
  platform-team:
    # Manages infrastructure across all projects
  frontend-team:
    # Manages all frontend codebases
  backend-team:
    # Manages all backend services
```

### Permission Levels

Use the principle of least privilege:

```yaml
# ✅ Good: Minimal permissions
repositories:
  - repository: "backend-api"
    permission: "pull"  # Frontend team only needs to read

# ❌ Bad: Excessive permissions
repositories:
  - repository: "backend-api"
    permission: "admin"  # Too much access
```

### External Collaborators

Create separate teams for external contractors:

```yaml
external-contractors:
  name: "External Contractors"
  description: "Temporary external access"
  privacy: "closed"
  members:
    - username: "contractor1"
      role: "member"  # Not maintainer
  repositories:
    - repository: "specific-project"
      permission: "push"  # Limited to specific repos
```

### Secret Teams

Use secret teams for sensitive groups:

```yaml
security-team:
  name: "Security Team"
  privacy: "secret"  # Hidden from non-members
```

### Team Maintainers

Assign multiple maintainers for redundancy:

```yaml
members:
  - username: "alice"
    role: "maintainer"
  - username: "bob"
    role: "maintainer"  # At least 2 maintainers
  - username: "charlie"
    role: "member"
```

## Common Patterns

### Cross-Functional Teams

```yaml
web-platform-team:
  name: "Web Platform Team"
  description: "Full-stack team for web platform"
  members:
    - username: "fullstack-dev-1"
      role: "maintainer"
    - username: "fullstack-dev-2"
      role: "member"
  repositories:
    - repository: "web-frontend"
      permission: "push"
    - repository: "web-backend"
      permission: "push"
    - repository: "shared-infrastructure"
      permission: "maintain"
```

### Read-Only Stakeholder Access

```yaml
stakeholders:
  name: "Product Stakeholders"
  description: "Product and business stakeholders"
  members:
    - username: "product-manager"
      role: "member"
    - username: "business-analyst"
      role: "member"
  repositories:
    - repository: "product-roadmap"
      permission: "pull"
    - repository: "technical-docs"
      permission: "pull"
```

### Tiered Access

```yaml
junior-developers:
  name: "Junior Developers"
  repositories:
    - repository: "learning-sandbox"
      permission: "push"
    - repository: "production-app"
      permission: "pull"  # Read-only

senior-developers:
  name: "Senior Developers"
  repositories:
    - repository: "learning-sandbox"
      permission: "maintain"
    - repository: "production-app"
      permission: "push"  # Write access
```

## Outputs

The module outputs team information:

```hcl
output "teams" {
  description = "Map of team keys to team details"
  value = {
    for key, team in github_team.teams : key => {
      name = team.name
      id   = team.id
      slug = team.slug
    }
  }
}
```

## Troubleshooting

### User Not Found

If Terraform reports a user doesn't exist:

```
Error: User 'username' not found
```

**Solutions:**
1. Verify the username is correct
2. Ensure the user has accepted the organization invitation
3. For external collaborators, invite them to the organization first

### Permission Denied

If you get permission errors:

```
Error: Must have admin access to repository
```

**Solutions:**
1. Ensure your GitHub token has `admin:org` scope
2. Verify you have Owner or Admin role in the organization
3. Check the repository exists and you have admin access

### Repository Not Found

If Terraform can't find a repository:

```
Error: Repository 'repo-name' not found
```

**Solutions:**
1. Verify the repository name is correct (case-sensitive)
2. Ensure the repository exists in the organization
3. Check that the repository isn't in a different organization

## Integration with Other Modules

### With Repositories Module

Grant teams access to managed repositories:

```yaml
# In repos/configs/repositories.yaml
repositories:
  my-app:
    name: "my-app"

# In teams/configs/teams.yaml
teams:
  developers:
    repositories:
      - repository: "my-app"  # Same name
        permission: "push"
```

### With Organization Rulesets

Use teams as bypass actors:

```yaml
# In rulesets/configs/org_rulesets.yaml
org_rulesets:
  production-protection:
    bypass_actors:
      - actor_id: 1234567  # Team ID from teams module output
        actor_type: "Team"
```

## Next Steps

- [Repositories Module](repositories.md) - Create repositories for teams
- [Organization Module](organization.md) - Configure organization settings
- [Examples](../examples/basic-setup.md) - See practical team configurations
