# Troubleshooting

Common issues and their solutions.

## Authentication Issues

### Invalid Token Error

```
Error: 401 Bad credentials
```

**Causes:**
- Token is incorrect or expired
- Token environment variable not set
- Token has been revoked

**Solutions:**

1. Verify token is set:
```bash
echo $GITHUB_TOKEN
# Should output your token
```

2. Check token hasn't expired in GitHub settings

3. Regenerate token if needed:
   - Go to GitHub Settings → Developer settings → Personal access tokens
   - Generate new token with required scopes
   - Update environment variable

4. Ensure token is exported in current shell:
```bash
export GITHUB_TOKEN="your_token_here"
```

### Insufficient Permissions

```
Error: 403 Resource not accessible by integration
```

**Causes:**
- Token missing required scopes
- User lacks necessary organization permissions
- Resource requires higher access level

**Solutions:**

1. Verify token has required scopes:
   - `repo` - Full control of private repositories
   - `admin:org` - Full control of orgs and teams
   - `delete_repo` - Delete repositories (if destroying)

2. Check your organization role:
   - Must be Owner or Admin
   - Go to organization → People → Check your role

3. For GitHub Apps, verify app permissions match requirements

## Terraform Issues

### State Lock Error

```
Error: Error locking state: resource temporarily unavailable
```

**Causes:**
- Another Terraform process is running
- Previous process crashed without releasing lock
- Lock timeout

**Solutions:**

1. Wait for other operation to complete

2. If process crashed, force unlock:
```bash
terraform force-unlock LOCK_ID
```

!!! warning "Use Carefully"
    Only force unlock if you're certain no other process is running.

3. Check for running Terraform processes:
```bash
ps aux | grep terraform
```

### Provider Initialization Failed

```
Error: Failed to initialize providers
```

**Causes:**
- Network connectivity issues
- Invalid provider version
- Registry unavailable

**Solutions:**

1. Retry initialization:
```bash
terraform init -upgrade
```

2. Check network connectivity:
```bash
curl https://registry.terraform.io/v1/providers/integrations/github
```

3. Clear Terraform cache:
```bash
rm -rf .terraform
terraform init
```

### Plan Shows Unexpected Changes

**Causes:**
- Manual changes made in GitHub UI
- Configuration drift
- State file out of sync

**Solutions:**

1. Refresh state:
```bash
terraform refresh
```

2. Review the changes carefully:
```bash
terraform plan | less
```

3. If drift is intentional, import the changes:
```bash
terraform import github_repository.repos["repo-name"] repo-name
```

4. If drift is not desired, apply to revert:
```bash
terraform apply
```

## Repository Issues

### Repository Already Exists

```
Error: Repository already exists
```

**Causes:**
- Repository with same name already exists
- Previous Terraform run was incomplete

**Solutions:**

1. Import existing repository:
```bash
terraform import 'github_repository.repos["repo-key"]' repository-name
```

2. Use a different repository name

3. Delete existing repository (if safe to do so)

### Cannot Delete Repository

```
Error: DELETE https://api.github.com/repos/org/repo: 403
```

**Causes:**
- Token lacks `delete_repo` scope
- Repository has protection against deletion
- User lacks admin access

**Solutions:**

1. Add `delete_repo` scope to token

2. Remove lifecycle protection if configured:
```hcl
resource "github_repository" "repos" {
  # ...
  lifecycle {
    prevent_destroy = false  # Change from true
  }
}
```

3. Verify admin access to repository

### Ruleset Creation Failed

```
Error: Error creating repository ruleset
```

**Causes:**
- Invalid branch pattern
- Status check doesn't exist
- Bypass actor ID invalid
- Free tier limitation

**Solutions:**

1. Verify branch patterns are valid:
```yaml
# ✅ Good
branch_patterns:
  - "main"
  - "release/*"

# ❌ Bad
branch_patterns:
  - "main**"  # Invalid pattern
```

2. Ensure status checks exist in CI:
```yaml
required_checks:
  - context: "ci/test"  # Must match actual check name
```

3. Verify bypass actor IDs:
```bash
# Get team ID
gh api /orgs/YOUR_ORG/teams/TEAM_NAME --jq '.id'
```

4. For org rulesets, ensure you have Team/Enterprise plan

## Team Issues

### User Not Found

```
Error: User 'username' not found
```

**Causes:**
- Username is incorrect
- User hasn't accepted organization invitation
- User account doesn't exist

**Solutions:**

1. Verify username is correct (case-sensitive)

2. Check if user has accepted org invitation:
   - Go to organization → People → Invitations

3. Send invitation if needed:
```bash
gh api /orgs/YOUR_ORG/invitations -f invitee_id=username
```

### Cannot Add User to Team

```
Error: Failed to add member to team
```

**Causes:**
- User not in organization
- Insufficient permissions
- Team privacy restrictions

**Solutions:**

1. Ensure user is organization member first

2. For secret teams, verify you have appropriate access

3. Check token has `admin:org` scope

### Repository Access Not Working

```
Error: Could not grant team access to repository
```

**Causes:**
- Repository doesn't exist
- Repository name incorrect
- Team doesn't have required permissions

**Solutions:**

1. Verify repository exists:
```bash
gh repo view YOUR_ORG/REPO_NAME
```

2. Check repository name (don't include org prefix):
```yaml
# ✅ Good
repositories:
  - repository: "my-repo"

# ❌ Bad
repositories:
  - repository: "my-org/my-repo"
```

3. Ensure repository is created before granting team access

## Organization Issues

### Cannot Modify Organization Settings

```
Error: Must be an organization owner
```

**Causes:**
- User is not organization owner
- Token lacks admin:org scope

**Solutions:**

1. Verify you're an organization owner:
   - Go to organization → People
   - Check your role

2. Ask organization owner to run Terraform

3. Or ask owner to promote you to owner role

### Organization Rulesets Not Available

```
Error: Organization rulesets require GitHub Team or Enterprise
```

**Causes:**
- Organization is on Free plan
- Feature not available on current plan

**Solutions:**

1. Use repository-level rulesets instead:
```yaml
# In repos/configs/repositories.yaml
repositories:
  my-repo:
    rulesets:
      main-protection:
        # ... configuration
```

2. Upgrade to GitHub Team or Enterprise plan

## YAML Configuration Issues

### YAML Syntax Error

```
Error: Error in function call
```

**Causes:**
- Invalid YAML syntax
- Incorrect indentation
- Missing required fields

**Solutions:**

1. Validate YAML syntax:
```bash
yamllint configs/repositories.yaml
```

2. Check indentation (use spaces, not tabs):
```yaml
# ✅ Good: 2-space indentation
repositories:
  my-repo:
    name: "my-repo"

# ❌ Bad: Mixed indentation
repositories:
    my-repo:
      name: "my-repo"
```

3. Verify required fields are present:
```yaml
repositories:
  my-repo:
    name: "my-repo"  # Required field
```

### Cannot Load Configuration

```
Error: Failed to load YAML configuration
```

**Causes:**
- File doesn't exist
- File path incorrect
- Permission denied

**Solutions:**

1. Verify file exists:
```bash
ls -la configs/repositories.yaml
```

2. Check file path in `locals.tf`:
```hcl
repositories = yamldecode(
  file("${path.module}/configs/repositories.yaml")  # Correct path?
).repositories
```

3. Ensure file is readable:
```bash
chmod 644 configs/repositories.yaml
```

## GitHub API Issues

### Rate Limit Exceeded

```
Error: 403 API rate limit exceeded
```

**Causes:**
- Too many API requests
- Using unauthenticated requests

**Solutions:**

1. Wait for rate limit to reset (usually 1 hour)

2. Ensure token is set (authenticated requests have higher limits)

3. Check rate limit status:
```bash
gh api /rate_limit
```

4. Use caching or reduce plan frequency

### Service Unavailable

```
Error: 503 Service unavailable
```

**Causes:**
- GitHub API temporarily unavailable
- Network connectivity issues

**Solutions:**

1. Check GitHub status:
   - Visit [https://www.githubstatus.com/](https://www.githubstatus.com/)

2. Retry after a few minutes

3. Check network connectivity:
```bash
curl https://api.github.com/
```

## CI/CD Issues

### GitHub Actions Token Not Set

```
Error: missing GitHub token
```

**Causes:**
- Secret not configured
- Secret name incorrect

**Solutions:**

1. Add secret to repository:
   - Settings → Secrets and variables → Actions
   - Add secret: `TERRAFORM_GITHUB_TOKEN`

2. Verify secret name in workflow:
```yaml
env:
  GITHUB_TOKEN: ${{ secrets.TERRAFORM_GITHUB_TOKEN }}  # Correct name?
```

### Workflow Fails on Apply

```
Error: Error applying plan
```

**Causes:**
- State lock held by another workflow
- Concurrent runs
- Permissions issue

**Solutions:**

1. Ensure only one workflow runs at a time:
```yaml
concurrency:
  group: terraform-${{ github.ref }}
  cancel-in-progress: false  # Don't cancel, queue instead
```

2. Use workflow locks:
```yaml
- name: Lock
  run: terraform init
```

3. Check workflow permissions:
```yaml
permissions:
  contents: read
  pull-requests: write
```

## Getting Help

### Enable Debug Logging

```bash
# Terraform debug logging
export TF_LOG=DEBUG
terraform apply

# GitHub CLI debug
gh api /repos/org/repo -H "Authorization: token $GITHUB_TOKEN" --include
```

### Collect Information

When reporting issues, include:

1. Terraform version:
```bash
terraform version
```

2. Provider version:
```bash
grep 'integrations/github' .terraform.lock.hcl
```

3. Error message (full output)

4. Relevant configuration (sanitize sensitive data)

5. Steps to reproduce

### Resources

- [Terraform GitHub Provider Documentation](https://registry.terraform.io/providers/integrations/github/latest/docs)
- [GitHub REST API Documentation](https://docs.github.com/en/rest)
- [GitHub Status](https://www.githubstatus.com/)
- [Terraform Documentation](https://www.terraform.io/docs)

### Community Support

- [GitHub Discussions](https://github.com/integrations/terraform-provider-github/discussions)
- [Terraform Community Forum](https://discuss.hashicorp.com/c/terraform-providers/)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/terraform+github)

## Next Steps

- [YAML Schema Reference](yaml-schema.md) - Complete configuration reference
- [Best Practices](../examples/best-practices.md) - Avoid common pitfalls
- [Getting Started Guide](../guides/getting-started.md) - Start fresh
