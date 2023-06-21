# Workload Identity Federation

## Pool & Provider
I recommend creating this piece either via Google Console or [`gcloud`](https://cloud.google.com/sdk/gcloud/reference/iam/workload-identity-pools).  I have to add in the disclaimer that I haven't configured WIFs that often, but as far as I can tell, once you create a pool, you can't delete it as the name persists -- which you can restore.  This makes it tricky if you're managing it from Terraform for learning purposes because once you destroy, you can't recreate it with the same name.  There are ways around this, but I think it's easier to just manage the pool via console and reference it using Terraform data resource instead.

To create a the GitHub-GCP WIF, you will need some info such as **Issuer (URL)**, and [Provider Attribute Mappings](https://token.actions.githubusercontent.com/.well-known/openid-configuration)...all of which you can find in the example Terraform resource definition below (y'know...the one I said you *shouldn't* use Terraform for):
```
resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = "my-wif-pool"
  workload_identity_pool_provider_id = "github"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  # https://token.actions.githubusercontent.com/.well-known/openid-configuration
  attribute_mapping = {
    "google.subject"  = "assertion.sub"
    "attribute.actor" = "assertion.actor"
    "attribute.aud"   = "assertion.aud"
  }
}
```
