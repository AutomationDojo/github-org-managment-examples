# Outputs
output "repositories" {
  description = "Map of created repositories"
  value = {
    for k, v in github_repository.repos : k => {
      name           = v.name
      full_name      = v.full_name
      html_url       = v.html_url
      ssh_clone_url  = v.ssh_clone_url
      http_clone_url = v.http_clone_url
    }
  }
}

output "repository_count" {
  description = "Number of repositories managed"
  value       = length(github_repository.repos)
}

output "repository_rulesets" {
  description = "Map of repository rulesets"
  value = {
    for k, v in github_repository_ruleset.repo_rulesets : k => {
      name        = v.name
      repository  = v.repository
      enforcement = v.enforcement
      target      = v.target
    }
  }
}
