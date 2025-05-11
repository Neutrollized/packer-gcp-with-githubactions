#-----------------------
# provider variables
#-----------------------
variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "Region to deploy GCP resources"
  type        = string
  default     = "us-central1"
}


#--------------------------------
# Workload Identity Federation
#--------------------------------
variable "wif_pool_id" {
  description = "Workload Identity Federation pool ID"
  type        = string
}

variable "packer_sa_iam_roles_list" {
  description = "List of IAM roles to be assigned to Packer WIF service account"
  type        = list(string)
  default = [
    "roles/compute.instanceAdmin.v1",
    "roles/iam.serviceAccountUser",
    "roles/iap.tunnelResourceAccessor",
  ]
}

variable "github_org" {
  description = "GitHub repo owner name"
  type        = string
}

variable "github_repo" {
  description = "GitHub repo name (i.e. name of this repo)"
  type        = string
}
