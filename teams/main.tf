# GitHub Teams Management
# This module manages GitHub teams, members, and repository access

# Create Teams
resource "github_team" "teams" {
  for_each = local.teams

  name        = each.value.name
  description = try(each.value.description, null)
  privacy     = try(each.value.privacy, "closed")
}

# Add Team Members
resource "github_team_membership" "members" {
  for_each = {
    for tm in local.team_members : "${tm.team_key}-${tm.username}" => tm
  }

  team_id  = github_team.teams[each.value.team_key].id
  username = each.value.username
  role     = each.value.role
}

# Grant Team Access to Repositories
resource "github_team_repository" "team_repos" {
  for_each = {
    for tr in local.team_repositories : "${tr.team_key}-${tr.repository}" => tr
  }

  team_id    = github_team.teams[each.value.team_key].id
  repository = each.value.repository
  permission = each.value.permission
}