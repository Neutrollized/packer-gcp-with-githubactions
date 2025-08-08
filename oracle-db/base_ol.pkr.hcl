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
variable "source_image_project_id" {}
variable "source_image_family" {}
variable "image_family" {}


locals {
  # https://www.packer.io/docs/templates/hcl_templates/functions/datetime/formatdate
  datestamp = formatdate("YYYYMMDD", timestamp())
}

# https://www.packer.io/docs/builders/googlecompute#required
source "googlecompute" "base-ol" {
  project_id   = var.project_id
  zone         = var.zone
  machine_type = var.machine_type
  preemptible  = true

  # gcloud compute images list
  source_image_project_id = var.source_image_project_id
  source_image_family     = var.source_image_family

  image_family      = var.image_family
  image_name        = "ol8-${var.arch}-base-${local.datestamp}"
  image_description = "Base Oracle Linux 8 image"
  
  ssh_username = "packer"
  use_os_login = false
  use_iap      = true

  tags = ["packer"]
}

build {
  sources = ["sources.googlecompute.base-ol"]

  provisioner "shell" {
    expect_disconnect = "true"
    inline = [
      "echo '=============================================='",
      "echo 'DNF INSTALL PACKAGES & UPDATES'",
      "echo '=============================================='",
      "sudo dnf install -y git",
      "sudo dnf update -y",
      "echo 'Rebooting...'",
      "sudo reboot"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo '=============================================='",
      "echo 'INSTALL DYNMOTD'",
      "echo '=============================================='",
      "git clone https://github.com/Neutrollized/dynmotd.git",
      "cd dynmotd && sudo ./install.sh",
      "cd ~ && rm -Rf ./dynmotd/"
    ]
    pause_before = "30s"
    max_retries  = 1
  }

  # fixes OL8's weird backspace issue
  provisioner "shell" {
    inline = [
      "echo '=============================================='",
      "echo 'SET XTERM'",
      "echo '=============================================='",
      "echo 'export TERM=xterm-256color' | sudo tee -a /etc/profile"
    ]
  }

  provisioner "shell" {
    expect_disconnect = "true"
    inline = [
      "sudo dnf clean all",
      "echo '=============================================='",
      "echo 'BUILD COMPLETE'",
      "echo '=============================================='"
    ]
  }
}
