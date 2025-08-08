# https://www.packer.io/docs/builders/googlecompute
packer {
  required_plugins {
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = "~> 1"
    }
  }
}

# you need to declare the variables here so that it knows what to look for in the .pkrvars.hcl var file
variable "project_id" {}
variable "zone" {}
variable "arch" {}
variable "machine_type" {}
variable "source_image_family" {}
variable "image_family" {}
variable "vault_version" {}


locals {
  # https://www.packer.io/docs/templates/hcl_templates/functions/datetime/formatdate
  datestamp = formatdate("YYYYMMDD", timestamp())

  # https://www.packer.io/docs/templates/hcl_templates/functions/string/replace
  # because GCP image name cannot have '.' in its name
  image_vault_version = replace(var.vault_version, ".", "-")
}

# https://www.packer.io/docs/builders/googlecompute#required
source "googlecompute" "vault-base" {
  project_id   = var.project_id
  zone         = var.zone
  machine_type = var.machine_type
  preemptible  = true

  # use custom base image that was built
  source_image_family = var.source_image_family

  image_family      = var.image_family
  image_name        = "vault-${local.image_vault_version}-${var.arch}-base-${local.datestamp}"
  image_description = "Vault base image"

  ssh_username = "packer"
  use_os_login = false
  use_iap      = true

  tags = ["packer"]
}

build {
  #hcp_packer_registry {
    #bucket_name = "gcp-gce-images-vault-base"
    #description = "Base Debian image with Vault installed"

    #bucket_labels = {
    #  "os"            = "Debian",
    #  "os-version"    = "Bookworm 12",
    #  "vault-version" = var.vault_version,
    #}

    #build_labels = {
    #  "build-time"   = timestamp()
    #  "build-source" = basename(path.cwd)
    #}
  #}

  sources = ["sources.googlecompute.vault-base"]

  # https://discuss.hashicorp.com/t/how-to-fix-debconf-unable-to-initialize-frontend-dialog-error/39201/2
  provisioner "shell" {
    expect_disconnect = "true"
    inline = [
      "echo '=============================================='",
      "echo 'APT INSTALL PACKAGES & UPDATES'",
      "echo '=============================================='",
      "echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections",
      "sudo apt-get update",
      "sudo apt-get -y install --no-install-recommends apt-utils git unzip wget",
      "sudo apt-get -y upgrade",
      "sudo apt-get -y dist-upgrade",
      "sudo apt-get -y autoremove",
      "echo 'Rebooting...'",
      "sudo reboot"
    ]
  }

  provisioner "file" {
    source      = "vault/20_services_check.sh"
    destination = "/tmp/"
    pause_before = "30s"
    max_retries = 1
  }

  provisioner "shell" {
    inline = [
      "echo '=============================================='",
      "echo 'INSTALL DYNMOTD'",
      "echo '=============================================='",
      "git clone https://github.com/Neutrollized/dynmotd.git",
      "cd dynmotd && sudo ./install.sh",
      "cd ~ && rm -Rf ./dynmotd/",
      "sudo mv /tmp/20_services_check.sh /etc/dynmotd.d/"
    ]
    max_retries = 3
  }

  provisioner "shell" {
    inline = [
      "echo '=============================================='",
      "echo 'CREATE VAULT USER & GROUP'",
      "echo '=============================================='",
      "sudo addgroup --system vault",
      "sudo adduser --system --ingroup vault vault",
      "sudo mkdir -p /etc/vault.d/tls",
      "sudo mkdir -p /opt/vault/data",
      "sudo mkdir -p /var/log/vault"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo '=============================================='",
      "echo 'DOWNLOAD VAULT'",
      "echo '=============================================='",
      "wget https://releases.hashicorp.com/vault/${var.vault_version}/vault_${var.vault_version}_linux_${var.arch}.zip",
      "unzip -o vault_${var.vault_version}_linux_${var.arch}.zip",
      "sudo mv vault /usr/local/bin/",
      "rm vault_${var.vault_version}_linux_${var.arch}.zip"
    ]
    max_retries = 3
  }

  provisioner "file" {
    source      = "vault/vault.service"
    destination = "/tmp/"
  }

  provisioner "file" {
    source      = "vault/vault_server.hcl.sample"
    destination = "/tmp/"
  }

  provisioner "file" {
    source      = "vault/vault_agent.hcl.sample"
    destination = "/tmp/"
  }

  provisioner "shell" {
    inline = [
      "echo '=============================================='",
      "echo 'SETUP VAULT'",
      "echo '=============================================='",
      "sudo mv /tmp/vault.service /etc/systemd/system/",
      "sudo systemctl daemon-reload",
      "sudo touch /etc/vault.d/vault.env",
      "sudo mv /tmp/vault_server.hcl.sample /etc/vault.d/",
      "sudo mv /tmp/vault_agent.hcl.sample /etc/vault.d/",
      "sudo chown -R vault:vault /etc/vault.d",
      "sudo chown -R vault:vault /opt/vault",
      "sudo chown -R vault:vault /var/log/vault",
      "sudo chmod 750 /etc/vault.d/tls",
      "sudo systemctl disable vault.service"
    ]
  }

  provisioner "shell" {
    expect_disconnect = "true"
    inline = [
      "which vault",
      "vault --version",
      "sudo apt-get clean",
      "/usr/local/bin/dynmotd",
      "echo '=============================================='",
      "echo 'BUILD COMPLETE'",
      "echo '=============================================='"
    ]
  }
}
