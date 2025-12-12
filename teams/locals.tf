# Load teams configuration
locals {
  teams_config = try(yamldecode(file("./configs/teams.yaml")), {})
  teams        = try(local.teams_config.teams, {})
}

# Flatten team repositories for easier iteration
locals {
  team_repositories = flatten([
    for team_key, team in local.teams : [
      for repo in coalesce(try(team.repositories, null), []) : {
        team_key   = team_key
        repository = repo.repository
        permission = try(repo.permission, "pull")
      }
    ]
  ])
}

# Flatten team members for easier iteration
locals {
  team_members = flatten([
    for team_key, team in local.teams : [
      for member in coalesce(try(team.members, null), []) : {
        team_key = team_key
        username = member.username
        role     = try(member.role, "member")
      }
    ]
  ])
}
