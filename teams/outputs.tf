
# Outputs
output "teams" {
  description = "Map of created teams"
  value = {
    for k, v in github_team.teams : k => {
      name        = v.name
      id          = v.id
      slug        = v.slug
      description = v.description
      privacy     = v.privacy
    }
  }
}

output "team_count" {
  description = "Number of teams managed"
  value       = length(github_team.teams)
}

output "team_members_count" {
  description = "Total number of team memberships"
  value       = length(github_team_membership.members)
}

output "team_repositories_count" {
  description = "Total number of team repository assignments"
  value       = length(github_team_repository.team_repos)
}
