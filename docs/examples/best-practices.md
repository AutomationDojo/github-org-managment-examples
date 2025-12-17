# Best Practices

Recommendations and tips for effective GitHub organization management with Terraform.

## Repository Configuration

### Naming Conventions

Use consistent naming patterns:

```yaml
# ✅ Good: Clear, consistent naming
repositories:
  web-frontend:
    name: "web-frontend"

  api-backend:
    name: "api-backend"

  infra-terraform:
    name: "infra-terraform"

# ❌ Bad: Inconsistent naming
repositories:
  WebFrontend:
    name: "WebFrontend"

  backend_API:
    name: "backend_API"

  terraform:
    name: "terraform"
```

**Recommended patterns:**
- `{product}-{component}` - e.g., `shop-frontend`, `shop-api`
- `{environment}-{service}` - e.g., `prod-payment-service`
- `{team}-{project}` - e.g., `platform-monitoring`

### Topics

Use topics consistently for discoverability:

```yaml
topics:
  # Language/framework
  - "typescript"
  - "react"

  # Purpose
  - "frontend"
  - "web-app"

  # Team/ownership
  - "team-alpha"

  # Environment
  - "production"

  # Compliance/security
  - "soc2-compliant"
```

### Merge Strategies

Choose one merge strategy for consistency:

```yaml
# ✅ Recommended: Squash only (clean history)
allow_merge_commit: false
allow_squash_merge: true
allow_rebase_merge: false
delete_branch_on_merge: true

# Alternative: Rebase only (linear history)
allow_merge_commit: false
allow_squash_merge: false
allow_rebase_merge: true
delete_branch_on_merge: true
```

## Branch Protection

### Protection Levels

Use tiered protection based on criticality:

```yaml
# Production repositories - Strict
rulesets:
  main-protection:
    rules:
      pull_request:
        required_approving_review_count: 2
        require_code_owner_review: true
        require_last_push_approval: true
        required_review_thread_resolution: true

# Development repositories - Moderate
rulesets:
  main-protection:
    rules:
      pull_request:
        required_approving_review_count: 1
        dismiss_stale_reviews_on_push: true

# Sandbox repositories - Minimal
rulesets:
  main-protection:
    rules:
      pull_request:
        required_approving_review_count: 1
```

### Status Checks

Always require CI to pass:

```yaml
required_status_checks:
  strict_required_status_checks_policy: true
  required_checks:
    # Build and test
    - context: "build"
    - context: "test"

    # Code quality
    - context: "lint"

    # Security (recommended)
    - context: "security-scan"

    # Coverage (optional)
    # - context: "coverage"
```

### Branch Patterns

Protect all important branches:

```yaml
# Protect main
branch_patterns:
  - "main"

# Protect main and release branches
branch_patterns:
  - "main"
  - "release/*"
  - "hotfix/*"

# Exclude WIP branches
branch_patterns:
  include:
    - "main"
  exclude:
    - "*/wip"
    - "experimental-*"
```

## Team Management

### Team Structure

Organize teams by function, not project:

```yaml
# ✅ Good: Functional teams
teams:
  platform-engineering:
    # Manages infrastructure across all projects

  frontend-engineers:
    # Manages all frontend code

  backend-engineers:
    # Manages all backend services

# ❌ Bad: Project-based teams
teams:
  project-alpha:
    # Isolated to one project

  project-beta:
    # Isolated to one project
```

### Permission Levels

Use principle of least privilege:

```yaml
teams:
  developers:
    repositories:
      # ✅ Good: Appropriate permissions
      - repository: "team-owned-service"
        permission: "push"

      - repository: "shared-library"
        permission: "maintain"

      - repository: "infrastructure"
        permission: "pull"  # Read-only

      # ❌ Bad: Too much access
      # - repository: "infrastructure"
      #   permission: "admin"
```

**Permission guidelines:**
- `pull` - For dependencies, documentation
- `push` - For active development
- `maintain` - For shared libraries, tools
- `admin` - Only for team leads, platform team

### Team Roles

Assign multiple maintainers for redundancy:

```yaml
members:
  # ✅ Good: Multiple maintainers
  - username: "lead1"
    role: "maintainer"
  - username: "lead2"
    role: "maintainer"
  - username: "dev1"
    role: "member"

  # ❌ Bad: Single maintainer
  # - username: "only-lead"
  #   role: "maintainer"
```

### External Collaborators

Separate external users into dedicated teams:

```yaml
external-contractors:
  name: "External Contractors"
  description: "Temporary external access - Review quarterly"
  privacy: "closed"

  members:
    - username: "contractor-name"
      role: "member"  # Never maintainer

  repositories:
    # Grant minimal access
    - repository: "specific-project"
      permission: "push"
    # No access to infrastructure
```

## Configuration Management

### YAML Organization

Keep YAML files organized and commented:

```yaml
repositories:
  # Production Services
  # Critical path - requires 2 approvals

  payment-service:
    name: "payment-service"
    description: "Payment processing service - PCI compliant"
    # ... configuration

  # Internal Tools
  # Lower criticality - 1 approval sufficient

  internal-dashboard:
    name: "internal-dashboard"
    description: "Internal metrics dashboard"
    # ... configuration
```

### Version Control

Treat infrastructure as code:

```bash
# ✅ Good: Commit with context
git add configs/repositories.yaml
git commit -m "Add payment-service repository for PROJ-123

- Configured with 2 required approvals
- Added PCI compliance topics
- Restricted merge to squash only"
git push

# ❌ Bad: Vague commits
git commit -m "update repos"
```

### Change Management

Follow a process for changes:

1. **Create a branch**
```bash
git checkout -b add-new-service
```

2. **Make changes to YAML**
```yaml
# Edit configs/repositories.yaml
```

3. **Plan and review**
```bash
terraform plan > plan.txt
# Review plan.txt
```

4. **Open pull request**
```bash
git push origin add-new-service
# Create PR with plan output
```

5. **Get approval and merge**

6. **Apply changes**
```bash
terraform apply
```

## Security

### Token Security

Never commit tokens:

```bash
# ✅ Good: Environment variable
export GITHUB_TOKEN="ghp_..."

# ✅ Good: CI/CD secret
# Set in GitHub Actions secrets

# ❌ Bad: Hardcoded
provider "github" {
  token = "ghp_abc123..."  # NEVER DO THIS
}
```

### State File Security

Protect state files:

```hcl
# ✅ Good: Encrypted remote backend
terraform {
  backend "s3" {
    bucket  = "terraform-state"
    key     = "github/terraform.tfstate"
    encrypt = true  # Enable encryption
  }
}

# ❌ Bad: Local state in version control
# Don't commit terraform.tfstate
```

Add to `.gitignore`:

```gitignore
# Terraform
.terraform/
*.tfstate
*.tfstate.*
*.tfvars
.terraform.lock.hcl

# Sensitive files
*.pem
*.key
```

### Audit Logging

Enable and monitor audit logs:

1. Go to organization settings → Audit log
2. Review regularly for unexpected changes
3. Export logs for compliance

### Secrets Management

Use secrets manager for sensitive values:

```hcl
# ✅ Good: Load from secrets manager
data "aws_secretsmanager_secret_version" "github_token" {
  secret_id = "terraform/github-token"
}

provider "github" {
  token = data.aws_secretsmanager_secret_version.github_token.secret_string
}
```

## Terraform Practices

### State Management

Use remote state for teams:

```hcl
# ✅ Good: Remote state
terraform {
  backend "remote" {
    organization = "your-org"
    workspaces {
      name = "github-management"
    }
  }
}

# ❌ Bad: Local state for teams
# terraform {
#   backend "local" {}
# }
```

### Module Organization

Keep modules independent:

```
github-org-management/
├── org_configurations/
│   ├── backend.tf  # Independent state
│   └── ...
├── repos/
│   ├── backend.tf  # Independent state
│   └── ...
├── teams/
│   ├── backend.tf  # Independent state
│   └── ...
```

### Planning

Always plan before applying:

```bash
# ✅ Good workflow
terraform plan -out=plan.tfplan
# Review plan
terraform apply plan.tfplan

# ❌ Bad: Blind apply
terraform apply -auto-approve  # Only for CI/CD
```

### Documentation

Document your configuration:

```yaml
repositories:
  critical-service:
    name: "critical-service"
    description: "Critical service - requires 24/7 on-call"

    # SECURITY-123: Increased to 2 approvals for SOC2 compliance
    rulesets:
      main-protection:
        rules:
          pull_request:
            required_approving_review_count: 2  # Was 1, changed 2024-01-15
```

## Testing

### Test Changes in Dev First

Always test in a non-production environment:

```bash
# Test in dev workspace
terraform workspace select dev
terraform apply

# Verify in GitHub

# Then apply to prod
terraform workspace select prod
terraform apply
```

### Validate Before Deploy

Use validation tools:

```bash
# Format check
terraform fmt -check

# Validate syntax
terraform validate

# Security scan (optional)
tfsec .
```

### Dry-Run with Evaluate Mode

Test rulesets without enforcing:

```yaml
rulesets:
  new-policy:
    name: "New Policy (Testing)"
    enforcement: "evaluate"  # Test first
    # ... configuration

    # After testing, change to:
    # enforcement: "active"
```

## CI/CD Integration

### Automated Validation

Validate on every pull request:

```yaml
name: Terraform Validation
on: [pull_request]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: hashicorp/setup-terraform@v3

      - name: Terraform Format
        run: terraform fmt -check -recursive

      - name: Terraform Init
        run: terraform init

      - name: Terraform Validate
        run: terraform validate
```

### Plan on PR

Show plan output in pull requests:

```yaml
- name: Terraform Plan
  id: plan
  run: terraform plan -no-color
  continue-on-error: true

- name: Comment PR
  uses: actions/github-script@v7
  with:
    script: |
      github.rest.issues.createComment({
        issue_number: context.issue.number,
        owner: context.repo.owner,
        repo: context.repo.repo,
        body: `#### Terraform Plan\n\`\`\`\n${{ steps.plan.outputs.stdout }}\n\`\`\``
      })
```

### Automated Apply

Only on main branch:

```yaml
- name: Terraform Apply
  if: github.ref == 'refs/heads/main' && github.event_name == 'push'
  run: terraform apply -auto-approve
```

## Monitoring and Maintenance

### Regular Reviews

Schedule regular reviews:

- **Weekly**: Review new repositories and teams
- **Monthly**: Audit team memberships and permissions
- **Quarterly**: Review external collaborator access
- **Annually**: Full security audit

### Drift Detection

Check for manual changes:

```bash
# Run regularly (e.g., daily via cron/CI)
terraform plan -detailed-exitcode

# Exit code 2 = drift detected
if [ $? -eq 2 ]; then
  echo "Drift detected! Manual changes were made."
  # Send alert
fi
```

### Documentation

Keep documentation updated:

- Document the purpose of each repository
- Maintain team structure diagrams
- Keep runbooks for common operations
- Document exceptions and special cases

## Common Pitfalls

### Avoid

❌ **Committing tokens to version control**
```bash
# Add to .gitignore immediately
echo "*.tfvars" >> .gitignore
echo "*.pem" >> .gitignore
```

❌ **Ignoring plan output**
```bash
# Always review plan before apply
terraform plan | less
```

❌ **Using admin permissions everywhere**
```yaml
# Give minimal necessary permissions
permission: "pull"  # Not "admin" by default
```

❌ **No branch protection**
```yaml
# Always protect main branch
rulesets:
  main-protection:
    # ... protection rules
```

❌ **Single maintainer**
```yaml
# Have backup maintainers
members:
  - username: "lead1"
    role: "maintainer"
  - username: "lead2"
    role: "maintainer"
```

## Summary Checklist

### Repository Setup
- [ ] Clear naming convention
- [ ] Appropriate visibility (public/private)
- [ ] Useful description
- [ ] Relevant topics
- [ ] Branch protection configured
- [ ] Status checks required
- [ ] Merge strategy defined

### Team Setup
- [ ] Teams organized by function
- [ ] Multiple maintainers assigned
- [ ] Principle of least privilege applied
- [ ] External collaborators separated
- [ ] Regular access reviews scheduled

### Security
- [ ] Tokens stored securely
- [ ] State files encrypted
- [ ] `.gitignore` configured
- [ ] Audit logging enabled
- [ ] Regular security reviews

### Operations
- [ ] Remote state configured
- [ ] Changes via pull requests
- [ ] Plans reviewed before apply
- [ ] CI/CD validation configured
- [ ] Drift detection implemented
- [ ] Documentation maintained

## Next Steps

- [Basic Setup Examples](basic-setup.md) - Start with simple examples
- [Advanced Configuration](advanced-config.md) - Complex scenarios
- [Deployment Guide](../guides/deployment.md) - Deployment strategies
