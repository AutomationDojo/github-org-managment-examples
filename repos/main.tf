# GitHub Repositories Management
# This module manages GitHub repositories for the organization

# Create repositories
resource "github_repository" "repos" {
  for_each = local.repositories

  name        = each.value.name
  description = try(each.value.description, null)
  visibility  = try(each.value.visibility, "private")

  # Features
  has_issues      = try(each.value.has_issues, true)
  has_discussions = try(each.value.has_discussions, false)
  has_projects    = try(each.value.has_projects, true)
  has_wiki        = try(each.value.has_wiki, true)
  has_downloads   = try(each.value.has_downloads, true)

  # Merge settings
  allow_merge_commit     = try(each.value.allow_merge_commit, true)
  allow_squash_merge     = try(each.value.allow_squash_merge, true)
  allow_rebase_merge     = try(each.value.allow_rebase_merge, true)
  allow_auto_merge       = try(each.value.allow_auto_merge, false)
  delete_branch_on_merge = try(each.value.delete_branch_on_merge, true)

  # Other settings
  archived             = try(each.value.archived, false)
  topics               = try(each.value.topics, [])
  vulnerability_alerts = try(each.value.vulnerability_alerts, true)

  # Template
  auto_init          = try(each.value.auto_init, true)
  gitignore_template = try(each.value.gitignore_template, null)
  license_template   = try(each.value.license_template, null)

  lifecycle {
    prevent_destroy = false
  }
}


resource "github_repository_ruleset" "repo_rulesets" {
  for_each = {
    for rs in local.repo_rulesets : rs.key => rs
  }

  repository  = github_repository.repos[each.value.repo_key].name
  name        = each.value.ruleset.name
  target      = try(each.value.ruleset.target, "branch")
  enforcement = try(each.value.ruleset.enforcement, "active")

  # Bypass actors (optional)
  dynamic "bypass_actors" {
    for_each = try(each.value.ruleset.bypass_actors, [])
    content {
      actor_id    = bypass_actors.value.actor_id
      actor_type  = bypass_actors.value.actor_type
      bypass_mode = try(bypass_actors.value.bypass_mode, "always")
    }
  }

  # Conditions
  conditions {
    ref_name {
      include = try(each.value.ruleset.branch_patterns, ["~DEFAULT_BRANCH"])
      exclude = try(each.value.ruleset.exclude_patterns, [])
    }
  }

  # Rules
  rules {
    creation                = try(each.value.ruleset.rules.creation, false)
    update                  = try(each.value.ruleset.rules.update, true)
    deletion                = try(each.value.ruleset.rules.deletion, true)
    required_linear_history = try(each.value.ruleset.rules.required_linear_history, false)
    required_signatures     = try(each.value.ruleset.rules.required_signatures, false)
    non_fast_forward        = try(each.value.ruleset.rules.non_fast_forward, true)

    # Pull Request requirements
    dynamic "pull_request" {
      for_each = try(each.value.ruleset.rules.pull_request, null) != null ? [1] : []
      content {
        required_approving_review_count   = try(each.value.ruleset.rules.pull_request.required_approving_review_count, 1)
        dismiss_stale_reviews_on_push     = try(each.value.ruleset.rules.pull_request.dismiss_stale_reviews_on_push, true)
        require_code_owner_review         = try(each.value.ruleset.rules.pull_request.require_code_owner_review, false)
        require_last_push_approval        = try(each.value.ruleset.rules.pull_request.require_last_push_approval, false)
        required_review_thread_resolution = try(each.value.ruleset.rules.pull_request.required_review_thread_resolution, false)
      }
    }

    # Required status checks
    dynamic "required_status_checks" {
      for_each = try(length(each.value.ruleset.rules.required_status_checks.required_checks), 0) > 0 ? [1] : []
      content {
        dynamic "required_check" {
          for_each = try(each.value.ruleset.rules.required_status_checks.required_checks, [])
          content {
            context = required_check.value.context
          }
        }
        strict_required_status_checks_policy = try(each.value.ruleset.rules.required_status_checks.strict_required_status_checks_policy, true)
      }
    }
  }

  depends_on = [github_repository.repos]
}