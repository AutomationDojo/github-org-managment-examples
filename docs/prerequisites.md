# Prerequisites

Before using these Terraform modules, ensure you have the following prerequisites in place.

## Required Software

### Terraform

You need Terraform version 1.0 or higher.

=== "macOS"
    ```bash
    # Using Homebrew
    brew tap hashicorp/tap
    brew install hashicorp/tap/terraform
    ```

=== "Linux"
    ```bash
    # Using apt (Debian/Ubuntu)
    wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
    sudo apt update && sudo apt install terraform
    ```

=== "Windows"
    ```powershell
    # Using Chocolatey
    choco install terraform
    ```

Verify installation:
```bash
terraform version
```

### Git

Git is required for version control.

```bash
# Check if git is installed
git --version
```

## GitHub Requirements

### GitHub Account

You need a GitHub account with appropriate permissions:

- **Organization Owner** role for managing organization settings
- **Admin** access to repositories you want to manage
- Ability to create and manage teams

### GitHub Plan Requirements

Different features require different GitHub plans:

| Feature | Free | Team | Enterprise |
|---------|------|------|------------|
| Organization Settings | ✅ | ✅ | ✅ |
| Public Repositories | ✅ | ✅ | ✅ |
| Private Repositories | ✅ (limited) | ✅ | ✅ |
| Repository Rulesets | ✅ (public repos) | ✅ | ✅ |
| Organization Rulesets | ❌ | ✅ | ✅ |
| Teams | ✅ | ✅ | ✅ |

!!! warning "Organization Rulesets Limitation"
    The `rulesets/` module (organization-level rulesets) requires a GitHub Team or Enterprise plan. However, repository-level rulesets in the `repos/` module work with the free tier on public repositories.

## Authentication

You need to authenticate Terraform with GitHub using one of these methods:

### Option 1: Personal Access Token (PAT) - Recommended for Getting Started

1. Go to [GitHub Settings > Developer settings > Personal access tokens > Tokens (classic)](https://github.com/settings/tokens)
2. Click "Generate new token (classic)"
3. Give it a descriptive name (e.g., "Terraform GitHub Management")
4. Select the following scopes:
   - `repo` (Full control of private repositories)
   - `admin:org` (Full control of orgs and teams)
   - `delete_repo` (Delete repositories)
5. Click "Generate token"
6. Copy the token immediately (you won't see it again)

Set the token as an environment variable:

```bash
export GITHUB_TOKEN="your_token_here"
```

!!! tip "Persistent Token"
    Add the export command to your `~/.bashrc`, `~/.zshrc`, or equivalent shell configuration file to make it persistent across sessions.

### Option 2: GitHub App - Recommended for Production

GitHub Apps provide more granular permissions and better security:

1. Create a GitHub App in your organization settings
2. Grant necessary permissions
3. Install the app in your organization
4. Generate a private key
5. Configure Terraform to use the app credentials

For detailed instructions, see the [Authentication Guide](guides/authentication.md).

## Terraform Backend (Optional but Recommended)

For team collaboration and state management, configure a remote backend:

### Option 1: Terraform Cloud

```hcl
terraform {
  backend "remote" {
    organization = "your-org"
    workspaces {
      name = "github-management"
    }
  }
}
```

### Option 2: S3 Backend

```hcl
terraform {
  backend "s3" {
    bucket = "your-terraform-state-bucket"
    key    = "github-org/terraform.tfstate"
    region = "us-east-1"
  }
}
```

!!! warning "State File Security"
    The Terraform state file contains sensitive information including GitHub tokens. Always use encrypted remote backends for production use.

## Network Requirements

Ensure your network allows connections to:

- `api.github.com` (GitHub API)
- `github.com` (GitHub web interface)
- `registry.terraform.io` (Terraform Registry for provider downloads)

## Recommended Tools

While not required, these tools can enhance your workflow:

- **[GitHub CLI](https://cli.github.com/)** - Command-line tool for GitHub operations
- **[terraform-docs](https://terraform-docs.io/)** - Generate documentation from Terraform modules
- **[tflint](https://github.com/terraform-linters/tflint)** - Terraform linter
- **[pre-commit](https://pre-commit.com/)** - Git hooks for code quality

## Knowledge Prerequisites

Basic understanding of:

- Git and version control
- Terraform fundamentals (resources, variables, state)
- YAML syntax
- GitHub organization management concepts

## Next Steps

Once you have all prerequisites in place:

1. [Getting Started Guide](guides/getting-started.md) - Deploy your first configuration
2. [Authentication Guide](guides/authentication.md) - Detailed authentication setup
3. [Modules Documentation](modules/organization.md) - Learn about each module
