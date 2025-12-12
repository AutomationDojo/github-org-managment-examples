# Outputs
output "organization_rulesets" {
  description = "Map of organization-level rulesets"
  value = {
    for k, v in github_organization_ruleset.rulesets : k => {
      name        = v.name
      enforcement = v.enforcement
      target      = v.target
      id          = v.id
    }
  }
}
