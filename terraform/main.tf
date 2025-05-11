#-----------------------------------------
# Firewalls
# - restrict ssh to Compute Engine SA
#-----------------------------------------
data "google_project" "main" {
  project_id = var.project_id
}

data "google_netblock_ip_ranges" "iap-forwarders" {
  range_type = "iap-forwarders"
}


resource "google_compute_firewall" "rules" {
  project     = var.project_id
  name        = "allow-packer-ssh"
  network     = "default"
  description = "Creates firewall rule targeting tagged instances"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges           = ["0.0.0.0/0"]
  target_service_accounts = ["${data.google_project.main.number}-compute@developer.gserviceaccount.com"]
}

resource "google_compute_firewall" "iap_tcp_forwarding" {
  project = var.project_id
  name    = "allow-iap-tunneling"
  network = "default"

  direction = "INGRESS"

  allow {
    protocol = "tcp"
  }

  # https://cloud.google.com/iap/docs/using-tcp-forwarding
  source_ranges = data.google_netblock_ip_ranges.iap-forwarders.cidr_blocks_ipv4
}


#------------------------------------
# Service Account
#------------------------------------
resource "google_service_account" "packer_sa" {
  account_id   = "gha-packer-sa"
  display_name = "Custom GitHub Actions Packer service account"
}

resource "google_project_iam_member" "packer_sa_iam_member" {
  project = var.project_id
  count   = length(var.packer_sa_iam_roles_list)
  role    = var.packer_sa_iam_roles_list[count.index]
  member  = "serviceAccount:${google_service_account.packer_sa.email}"
}


#-------------------------------------
# Workload Identity Federation 
# https://registry.terraform.io/modules/terraform-google-modules/github-actions-runners/google/latest/submodules/gh-oidc
#-------------------------------------
module "gh_oidc" {
  source  = "terraform-google-modules/github-actions-runners/google//modules/gh-oidc"
  version = "3.1.2"

  project_id          = var.project_id
  pool_id             = var.wif_pool_id
  provider_id         = "github"
  attribute_condition = "assertion.repository_owner=='${var.github_org}'"
  sa_mapping = {
    "packer-sa" = {
      sa_name   = google_service_account.packer_sa.id
      attribute = format("attribute.repository/%s/%s", var.github_org, var.github_repo)
    }
  }
}
