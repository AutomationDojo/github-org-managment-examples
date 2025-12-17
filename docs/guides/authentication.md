# Authentication Guide

This guide covers different methods for authenticating Terraform with GitHub.

## Overview

Terraform needs credentials to interact with the GitHub API. There are two main approaches:

1. **Personal Access Token (PAT)** - Simple, best for getting started
2. **GitHub App** - More secure, best for production and teams

## Option 1: Personal Access Token (PAT)

### When to Use

- Quick prototyping and testing
- Personal projects
- Learning and experimentation
- Single-user workflows

### Advantages

- ✅ Simple to set up
- ✅ Works immediately
- ✅ No additional configuration needed

### Disadvantages

- ❌ Tied to a user account
- ❌ If user leaves, automation breaks
- ❌ Broad permissions
- ❌ Difficult to rotate securely

### Creating a PAT

#### Classic Token (Recommended for Getting Started)

1. Go to [GitHub Settings → Developer settings → Personal access tokens → Tokens (classic)](https://github.com/settings/tokens)

2. Click **"Generate new token (classic)"**

3. Configure the token:
   - **Note**: `Terraform GitHub Management - Production`
   - **Expiration**: Choose appropriate expiration (90 days recommended)

4. Select scopes:

   **Required scopes:**
   - `repo` - Full control of private repositories
   - `admin:org` - Full control of orgs and teams
     - `write:org`
     - `read:org`
   - `delete_repo` - Delete repositories (if you plan to destroy resources)

   **Optional scopes (based on your needs):**
   - `workflow` - Update GitHub Actions workflows
   - `admin:org_hook` - Manage organization webhooks

5. Click **"Generate token"**

6. **Copy the token immediately** (you won't see it again!)

#### Fine-grained Token (More Secure)

1. Go to [GitHub Settings → Developer settings → Personal access tokens → Fine-grained tokens](https://github.com/settings/tokens?type=beta)

2. Click **"Generate new token"**

3. Configure:
   - **Token name**: `Terraform GitHub Management`
   - **Expiration**: 90 days
   - **Resource owner**: Your organization
   - **Repository access**: All repositories

4. Select permissions:

   **Repository permissions:**
   - Administration: Read and write
   - Contents: Read and write
   - Metadata: Read-only
   - Pull requests: Read and write

   **Organization permissions:**
   - Administration: Read and write
   - Members: Read and write
   - Organization plan: Read-only

5. Generate and copy the token

### Using the PAT

#### Environment Variable (Recommended)

```bash
export GITHUB_TOKEN="your_token_here"
```

Make it persistent by adding to your shell configuration:

=== "Bash (~/.bashrc)"
    ```bash
    echo 'export GITHUB_TOKEN="your_token_here"' >> ~/.bashrc
    source ~/.bashrc
    ```

=== "Zsh (~/.zshrc)"
    ```bash
    echo 'export GITHUB_TOKEN="your_token_here"' >> ~/.zshrc
    source ~/.zshrc
    ```

=== "Fish (~/.config/fish/config.fish)"
    ```fish
    echo 'set -x GITHUB_TOKEN "your_token_here"' >> ~/.config/fish/config.fish
    source ~/.config/fish/config.fish
    ```

#### Provider Configuration

The GitHub provider automatically reads from the `GITHUB_TOKEN` environment variable:

```hcl title="providers.tf"
provider "github" {
  owner = "your-org-name"
  # token is read from GITHUB_TOKEN env var
}
```

Alternatively, you can specify it explicitly (not recommended for security):

```hcl title="providers.tf"
provider "github" {
  owner = "your-org-name"
  token = var.github_token  # Use a variable
}
```

```hcl title="variables.tf"
variable "github_token" {
  description = "GitHub Personal Access Token"
  type        = string
  sensitive   = true
}
```

!!! danger "Never Commit Tokens"
    Never hardcode tokens in Terraform files or commit them to version control!

## Option 2: GitHub App (Recommended for Production)

### When to Use

- Production environments
- Team workflows
- Organization-wide automation
- Enhanced security requirements
- Need for audit trails

### Advantages

- ✅ Not tied to a user account
- ✅ Granular permissions
- ✅ Better audit logging
- ✅ Can be organization-owned
- ✅ Automatic token rotation
- ✅ Fine-grained access control

### Disadvantages

- ❌ More complex setup
- ❌ Requires private key management
- ❌ Additional configuration needed

### Creating a GitHub App

1. Go to your organization settings
2. Navigate to **Developer settings → GitHub Apps**
3. Click **"New GitHub App"**

4. Configure the app:

   **Basic information:**
   - **GitHub App name**: `Terraform Organization Management`
   - **Homepage URL**: `https://github.com/your-org`
   - **Webhook**: Uncheck "Active" (not needed)

   **Permissions:**

   **Repository permissions:**
   - Administration: Read and write
   - Contents: Read and write
   - Metadata: Read-only (automatically granted)
   - Pull requests: Read and write

   **Organization permissions:**
   - Administration: Read and write
   - Members: Read and write

5. Click **"Create GitHub App"**

6. **Generate a private key:**
   - Scroll to "Private keys" section
   - Click "Generate a private key"
   - Save the downloaded `.pem` file securely

7. **Note the App ID** (you'll need it for configuration)

8. **Install the app:**
   - Go to app settings → "Install App"
   - Install on your organization
   - Grant access to all repositories (or specific ones)
   - Note the **Installation ID** from the URL

### Using the GitHub App

#### Provider Configuration

```hcl title="providers.tf"
provider "github" {
  owner = "your-org-name"
  app_auth {
    id              = var.github_app_id
    installation_id = var.github_app_installation_id
    pem_file        = var.github_app_pem_file
  }
}
```

```hcl title="variables.tf"
variable "github_app_id" {
  description = "GitHub App ID"
  type        = string
}

variable "github_app_installation_id" {
  description = "GitHub App Installation ID"
  type        = string
}

variable "github_app_pem_file" {
  description = "Path to GitHub App private key PEM file"
  type        = string
  sensitive   = true
}
```

#### Setting Variables

Create a `terraform.tfvars` file (don't commit it!):

```hcl title="terraform.tfvars"
github_app_id              = "123456"
github_app_installation_id = "12345678"
github_app_pem_file        = "/path/to/your-app.private-key.pem"
```

Add to `.gitignore`:

```gitignore title=".gitignore"
*.tfvars
*.pem
.terraform/
terraform.tfstate
terraform.tfstate.backup
```

#### Using Environment Variables

Alternatively, use environment variables:

```bash
export TF_VAR_github_app_id="123456"
export TF_VAR_github_app_installation_id="12345678"
export TF_VAR_github_app_pem_file="/path/to/private-key.pem"
```

## Security Best Practices

### Token Storage

!!! warning "Secure Storage"
    Store tokens and private keys securely. Never commit them to version control.

**Options for secure storage:**

1. **Environment variables** (local development)
2. **Secrets manager** (production)
   - AWS Secrets Manager
   - HashiCorp Vault
   - Azure Key Vault
   - Google Secret Manager
3. **CI/CD secrets** (GitHub Actions, GitLab CI)

### Token Rotation

Regularly rotate your tokens:

- **PATs**: Rotate every 90 days
- **GitHub Apps**: Regenerate private keys annually

### Minimal Permissions

Only grant the permissions you need:

```hcl
# ✅ Good: Minimal scopes
# Only repo and admin:org for managing repositories and teams

# ❌ Bad: Excessive scopes
# Including workflow, packages, etc. when not needed
```

### Audit Logging

Monitor token usage:

1. Go to organization settings → Audit log
2. Filter by token or app activity
3. Review for unexpected usage

## CI/CD Integration

### GitHub Actions

Store token as a secret:

1. Go to repository settings → Secrets and variables → Actions
2. Add new secret: `TERRAFORM_GITHUB_TOKEN`
3. Use in workflow:

```yaml
- name: Terraform Apply
  env:
    GITHUB_TOKEN: ${{ secrets.TERRAFORM_GITHUB_TOKEN }}
  run: terraform apply -auto-approve
```

### GitLab CI

```yaml
variables:
  GITHUB_TOKEN: $GITHUB_TOKEN

terraform:
  script:
    - terraform init
    - terraform apply -auto-approve
```

Store `GITHUB_TOKEN` in GitLab CI/CD variables (masked).

### Other CI Systems

Consult your CI system's documentation for securely storing secrets.

## Troubleshooting

### Invalid Token

```
Error: 401 Bad credentials
```

**Solutions:**
- Verify token is set correctly: `echo $GITHUB_TOKEN`
- Check token hasn't expired
- Regenerate token if necessary

### Insufficient Permissions

```
Error: 403 Forbidden
```

**Solutions:**
- Verify token has required scopes
- Check organization permissions
- Confirm you're an organization owner/admin

### GitHub App Authentication Failed

```
Error: Could not authenticate with GitHub App
```

**Solutions:**
- Verify App ID is correct
- Check Installation ID
- Ensure PEM file path is correct and readable
- Confirm app is installed on the organization

### Token Environment Variable Not Set

```
Error: missing GitHub token
```

**Solutions:**
```bash
# Check if set
echo $GITHUB_TOKEN

# Set it
export GITHUB_TOKEN="your_token_here"

# Verify
echo $GITHUB_TOKEN
```

## Comparison

| Feature | Personal Access Token | GitHub App |
|---------|----------------------|------------|
| **Setup Complexity** | Simple | Moderate |
| **User Dependency** | Yes (tied to user) | No (organization-owned) |
| **Permissions** | Broad | Granular |
| **Audit Trail** | Limited | Comprehensive |
| **Rotation** | Manual | Automated possible |
| **Best For** | Development, Testing | Production, Teams |
| **Cost** | Free | Free |

## Recommendations

### For Development

Use a **Personal Access Token (classic)**:
- Quick to set up
- Easy to test
- Sufficient for learning

### For Production

Use a **GitHub App**:
- Not tied to user account
- Better security
- Better audit trail
- Organization-owned

## Next Steps

- [Getting Started Guide](getting-started.md) - Deploy your first configuration
- [Deployment Guide](deployment.md) - Deploy multiple modules
- [Prerequisites](../prerequisites.md) - Other requirements
