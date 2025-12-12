# Load repositories configuration
locals {
  repositories_config = try(yamldecode(file("./configs/repositories.yaml")), {})
  repositories        = try(local.repositories_config.repositories, {})
}

# Repository Rulesets (per-repository)
# These work on public repos with free tier
locals {
  # Flatten rulesets from all repositories
  repo_rulesets = flatten([
    for repo_key, repo in local.repositories : [
      for ruleset_key, ruleset in try(repo.rulesets, {}) : {
        key         = "${repo_key}-${ruleset_key}"
        repo_key    = repo_key
        repo_name   = repo.name
        ruleset_key = ruleset_key
        ruleset     = ruleset
      }
    ]
  ])
}