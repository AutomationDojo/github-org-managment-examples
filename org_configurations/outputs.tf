# Outputs
output "organization_name" {
  description = "The name of the GitHub organization"
  value       = local.environment.github.organization.name
}

output "organization_billing_email" {
  description = "The billing email of the GitHub organization"
  value       = github_organization_settings.org.billing_email
  sensitive   = true
}
