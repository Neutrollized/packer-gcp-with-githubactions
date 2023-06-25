output "wif_provider" {
  value = module.gh_oidc.provider_name
}

output "wif_service_account" {
  value = google_service_account.packer_sa.email
}
