# Base Configuration - Common settings for all workspaces

terraform {
  required_version = ">= 1.0"

  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

# GitHub Provider Configuration
provider "github" {
  token = var.github_token
  owner = local.environment.github.organization.name
}