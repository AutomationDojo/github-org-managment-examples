# Load organization rulesets configuration
locals {
  org_rulesets_config = try(yamldecode(file("./configs/org_rulesets.yaml")), {})
  org_rulesets        = try(local.org_rulesets_config.organization_rulesets, {})
}
