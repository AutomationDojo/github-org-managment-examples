# Getting Started

This guide will walk you through deploying your first GitHub organization configuration with Terraform.

## Overview

We'll deploy a simple repository with branch protection to demonstrate the workflow. This example uses the free tier and works with public repositories.

## Time Required

⏱️ Approximately **15 minutes**

## What You'll Learn

- How to configure repositories with YAML
- How to deploy with Terraform
- How to add branch protection rules
- How to verify and update configurations

## Step 1: Prerequisites

Ensure you have completed the [prerequisites](../prerequisites.md):

- ✅ Terraform installed
- ✅ GitHub account with organization access
- ✅ GitHub Personal Access Token (PAT)
- ✅ Git installed

Set your GitHub token:

```bash
export GITHUB_TOKEN="your_github_token_here"
```

## Step 2: Clone the Repository

Clone this example repository:

```bash
git clone https://github.com/yourusername/github-org-management-examples.git
cd github-org-management-examples
```

## Step 3: Configure Your First Repository

Navigate to the repositories module:

```bash
cd repos
```

Edit `configs/repositories.yaml` to add your first repository:

```yaml title="configs/repositories.yaml"
repositories:
  my-first-repo:
    name: "my-first-repo"
    description: "My first managed repository"
    visibility: "public"  # public for free tier

    # Enable useful features
    has_issues: true
    has_discussions: false
    has_projects: true
    has_wiki: false

    # Merge settings
    allow_merge_commit: false
    allow_squash_merge: true
    allow_rebase_merge: false
    delete_branch_on_merge: true

    # Topics for discoverability
    topics:
      - "terraform"
      - "github"
      - "automation"

    # Enable security alerts
    vulnerability_alerts: true

    # Branch protection with rulesets
    rulesets:
      main-protection:
        name: "Protect Main Branch"
        enforcement: "active"
        target: "branch"
        branch_patterns:
          - "main"

        rules:
          update: true  # Require PR
          deletion: true  # Prevent deletion
          non_fast_forward: true  # Prevent force push

          pull_request:
            required_approving_review_count: 1
            dismiss_stale_reviews_on_push: true
            required_review_thread_resolution: true
```

## Step 4: Update Provider Configuration

Edit `providers.tf` to set your organization name:

```hcl title="providers.tf"
terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }
}

provider "github" {
  owner = "your-org-name"  # ← Change this
  # token is read from GITHUB_TOKEN environment variable
}
```

## Step 5: Initialize Terraform

Initialize the Terraform working directory:

```bash
terraform init
```

You should see:

```
Initializing the backend...
Initializing provider plugins...
- Finding integrations/github versions matching "~> 6.0"...
- Installing integrations/github v6.x.x...

Terraform has been successfully initialized!
```

## Step 6: Plan the Changes

Review what Terraform will create:

```bash
terraform plan
```

Expected output:

```hcl
Terraform will perform the following actions:

  # github_repository.repos["my-first-repo"] will be created
  + resource "github_repository" "repos" {
      + name        = "my-first-repo"
      + description = "My first managed repository"
      + visibility  = "public"
      # ... more attributes
    }

  # github_repository_ruleset.repo_rulesets["my-first-repo-main-protection"] will be created
  + resource "github_repository_ruleset" "repo_rulesets" {
      + name        = "Protect Main Branch"
      + enforcement = "active"
      # ... more attributes
    }

Plan: 2 to add, 0 to change, 0 to destroy.
```

!!! tip "Review Carefully"
    Always review the plan output before applying. Ensure the resources match your expectations.

## Step 7: Apply the Configuration

Apply the configuration to create resources:

```bash
terraform apply
```

Terraform will show the plan again and ask for confirmation:

```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value:
```

Type `yes` and press Enter.

You should see:

```
github_repository.repos["my-first-repo"]: Creating...
github_repository.repos["my-first-repo"]: Creation complete after 2s
github_repository_ruleset.repo_rulesets["my-first-repo-main-protection"]: Creating...
github_repository_ruleset.repo_rulesets["my-first-repo-main-protection"]: Creation complete after 1s

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
```

## Step 8: Verify the Repository

Visit your GitHub organization to verify the repository was created:

```
https://github.com/your-org-name/my-first-repo
```

Check that:

1. ✅ Repository exists and is public
2. ✅ Description is set correctly
3. ✅ Topics are applied
4. ✅ Settings match your configuration

### Verify Branch Protection

Go to repository Settings → Rules and verify:

1. ✅ "Protect Main Branch" ruleset exists
2. ✅ Status shows "Active"
3. ✅ Rules are configured correctly

## Step 9: Test Branch Protection

Let's verify the branch protection is working:

1. Clone your new repository:
```bash
git clone https://github.com/your-org-name/my-first-repo.git
cd my-first-repo
```

2. Try to push directly to main:
```bash
echo "# Test" > test.md
git add test.md
git commit -m "Test direct push"
git push origin main
```

You should see an error:

```
remote: error: GH013: Repository rule violations found
remote:
remote: - Changes must be made through a pull request.
```

✅ Success! Branch protection is working.

3. Create a pull request instead:
```bash
git checkout -b feature/test-pr
git push origin feature/test-pr
```

Then create a PR through the GitHub web interface.

## Step 10: Make Changes

Let's update the repository configuration. Edit `configs/repositories.yaml`:

```yaml
repositories:
  my-first-repo:
    # ... existing config ...

    # Add a new topic
    topics:
      - "terraform"
      - "github"
      - "automation"
      - "infrastructure-as-code"  # ← New topic

    # Update ruleset to require 2 approvals
    rulesets:
      main-protection:
        # ... existing config ...
        rules:
          pull_request:
            required_approving_review_count: 2  # ← Changed from 1
            dismiss_stale_reviews_on_push: true
            required_review_thread_resolution: true
```

Apply the changes:

```bash
terraform plan
terraform apply
```

Terraform will show:

```
github_repository.repos["my-first-repo"]: Modifying...
github_repository_ruleset.repo_rulesets["my-first-repo-main-protection"]: Modifying...

Apply complete! Resources: 0 added, 2 changed, 0 destroyed.
```

## Next Steps

Congratulations! 🎉 You've successfully:

- ✅ Created a GitHub repository with Terraform
- ✅ Configured branch protection with rulesets
- ✅ Verified the protection is working
- ✅ Updated the configuration

### Continue Learning

- [Authentication Guide](authentication.md) - Set up GitHub App authentication
- [Deployment Guide](deployment.md) - Deploy multiple modules
- [Examples](../examples/basic-setup.md) - See more practical examples
- [Teams Module](../modules/teams.md) - Add team management
- [Organization Module](../modules/organization.md) - Configure organization settings

### Common Next Actions

1. **Add More Repositories** - Add additional repositories to `configs/repositories.yaml`
2. **Configure Teams** - Set up teams and permissions with the teams module
3. **Organization Settings** - Configure organization-level settings
4. **CI/CD Integration** - Add required status checks for your CI pipeline
5. **Remote State** - Configure remote backend for team collaboration

## Troubleshooting

### Repository Already Exists

If you get an error that the repository already exists:

```
Error: Repository already exists
```

Options:
1. Choose a different repository name
2. Import the existing repository: `terraform import github_repository.repos["my-first-repo"] my-first-repo`
3. Delete the existing repository from GitHub first

### Permission Denied

If you get permission errors:

```
Error: 403 Forbidden
```

Check:
1. Your GITHUB_TOKEN is set correctly
2. The token has `repo` and `admin:org` scopes
3. You have admin access to the organization

### Plan Shows No Changes

If `terraform plan` shows no changes but you expected some:

1. Check your YAML syntax is correct
2. Verify you saved the file
3. Ensure you're in the correct directory
4. Check the repository key matches

## Clean Up

To remove the resources created in this tutorial:

```bash
terraform destroy
```

!!! warning "Destructive Action"
    This will delete the repository. Any code pushed to the repository will be lost.

Type `yes` to confirm deletion.
