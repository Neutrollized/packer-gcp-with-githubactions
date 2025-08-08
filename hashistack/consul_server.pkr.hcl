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
variable "consul_version" {}


locals {
  # https://www.packer.io/docs/templates/hcl_templates/functions/datetime/formatdate
  datestamp = formatdate("YYYYMMDD", timestamp())

  # https://www.packer.io/docs/templates/hcl_templates/functions/string/replace
  # because GCP image name cannot have '.' in its name
  image_consul_version = replace(var.consul_version, ".", "-")
}

# https://www.packer.io/docs/builders/googlecompute#required
source "googlecompute" "consul-server" {
  project_id   = var.project_id
  zone         = var.zone
  machine_type = var.machine_type
  preemptible  = true

  # use custom base image that was built
  source_image_family = var.source_image_family

  image_family      = var.image_family
  image_name        = "consul-${local.image_consul_version}-${var.arch}-server-${local.datestamp}"
  image_description = "Consul server image"

  ssh_username = "packer"
  use_os_login = false
  use_iap      = true

  tags = ["packer"]
}

build {
  #hcp_packer_registry {
    #bucket_name = "gcp-gce-images-consul-server"
    #description = "Base Consul image with server config"

    #bucket_labels = {
    #  "os"             = "Debian",
    #  "os-version"     = "Bookworm 12",
    #  "consul-version" = var.consul_version,
    #}

    #build_labels = {
    #  "build-time"   = timestamp()
    #  "build-source" = basename(path.cwd)
    #}
  #}

  sources = ["sources.googlecompute.consul-server"]

  provisioner "file" {
    source      = "consul/20_services_check.sh"
    destination = "/tmp/"
  }

  provisioner "file" {
    source      = "consul/server.hcl"
    destination = "/tmp/"
  }

  provisioner "shell" {
    inline = [
      "echo '=============================================='",
      "echo 'SETUP CONSUL SERVER'",
      "echo '=============================================='",
      "sudo mv /tmp/20_services_check.sh /etc/dynmotd.d/",
      "sudo mv /tmp/server.hcl /etc/consul.d/",
      "sudo chown -R consul:consul /etc/consul.d"
    ]
  }

  provisioner "shell" {
    expect_disconnect = "true"
    inline = [
      "which consul",
      "consul --version",
      "/usr/local/bin/dynmotd",
      "echo '=============================================='",
      "echo 'BUILD COMPLETE'",
      "echo '=============================================='"
    ]
  }
}
