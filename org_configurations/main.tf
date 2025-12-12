# GitHub Organization Configuration
# This module configures organization-level settings for the GitHub organization

# GitHub Organization Settings
resource "github_organization_settings" "org" {
  billing_email = local.environment.github.organization.billing_email

  # Organization Profile
  description = try(local.environment.github.organization.description, null)

  # Member Privileges
  members_can_create_internal_repositories = try(local.environment.github.organization.members_can_create_internal_repositories, false)
  members_can_create_private_repositories  = try(local.environment.github.organization.members_can_create_private_repositories, false)
  members_can_create_public_repositories   = try(local.environment.github.organization.members_can_create_public_repositories, false)
  members_can_create_repositories          = try(local.environment.github.organization.members_can_create_repositories, false)
  members_can_create_pages                 = try(local.environment.github.organization.members_can_create_pages, false)
  members_can_fork_private_repositories    = try(local.environment.github.organization.members_can_fork_private_repositories, false)
  members_can_create_public_pages          = try(local.environment.github.organization.members_can_create_public_pages, false)
  members_can_create_private_pages         = try(local.environment.github.organization.members_can_create_private_pages, false)
}