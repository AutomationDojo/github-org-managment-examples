# Organization-level Rulesets Configuration
# NOTE: Organization rulesets require GitHub Team or Enterprise plan
# This code is disabled for free tier organizations
# To enable: Uncomment the code below after upgrading to GitHub Team/Enterprise

# Organization-level Rulesets
resource "github_organization_ruleset" "rulesets" {
  for_each = local.org_rulesets

  name        = each.value.name
  target      = try(each.value.target, "branch")
  enforcement = try(each.value.enforcement, "active")

  # Bypass actors (optional)
  dynamic "bypass_actors" {
    for_each = try(each.value.bypass_actors, [])
    content {
      actor_id    = bypass_actors.value.actor_id
      actor_type  = bypass_actors.value.actor_type
      bypass_mode = try(bypass_actors.value.bypass_mode, "always")
    }
  }

  # Conditions
  conditions {
    ref_name {
      include = try(each.value.conditions.ref_name.include, ["~DEFAULT_BRANCH"])
      exclude = try(each.value.conditions.ref_name.exclude, [])
    }

    dynamic "repository_name" {
      for_each = try(each.value.conditions.repository_name, null) != null ? [1] : []
      content {
        include = try(each.value.conditions.repository_name.include, ["*"])
        exclude = try(each.value.conditions.repository_name.exclude, [])
      }
    }
  }

  # Rules
  rules {
    creation                = try(each.value.rules.creation, false)
    update                  = try(each.value.rules.update, true)
    deletion                = try(each.value.rules.deletion, true)
    required_linear_history = try(each.value.rules.required_linear_history, false)
    required_signatures     = try(each.value.rules.required_signatures, false)
    non_fast_forward        = try(each.value.rules.non_fast_forward, true)

    # Pull Request requirements
    dynamic "pull_request" {
      for_each = try(each.value.rules.pull_request, null) != null ? [1] : []
      content {
        required_approving_review_count   = try(each.value.rules.pull_request.required_approving_review_count, 1)
        dismiss_stale_reviews_on_push     = try(each.value.rules.pull_request.dismiss_stale_reviews_on_push, true)
        require_code_owner_review         = try(each.value.rules.pull_request.require_code_owner_review, false)
        require_last_push_approval        = try(each.value.rules.pull_request.require_last_push_approval, false)
        required_review_thread_resolution = try(each.value.rules.pull_request.required_review_thread_resolution, false)
      }
    }

    # Required status checks
    dynamic "required_status_checks" {
      for_each = try(length(each.value.rules.required_status_checks.required_checks), 0) > 0 ? [1] : []
      content {
        dynamic "required_check" {
          for_each = try(each.value.rules.required_status_checks.required_checks, [])
          content {
            context = required_check.value.context
          }
        }
        strict_required_status_checks_policy = try(each.value.rules.required_status_checks.strict_required_status_checks_policy, true)
      }
    }
  }
}