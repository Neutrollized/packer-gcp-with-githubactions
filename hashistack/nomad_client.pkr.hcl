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
variable "source_image_family" {}
variable "image_family" {}
variable "consul_version" {}
variable "nomad_version" {}


locals {
  # https://www.packer.io/docs/templates/hcl_templates/functions/datetime/formatdate
  datestamp = formatdate("YYYYMMDD", timestamp())

  # https://www.packer.io/docs/templates/hcl_templates/functions/string/replace
  # because GCP image name cannot have '.' in its name
  image_nomad_version = replace(var.nomad_version, ".", "-")
}

# https://www.packer.io/docs/builders/googlecompute#required
source "googlecompute" "nomad-client" {
  project_id   = var.project_id
  zone         = var.zone
  machine_type = "n1-standard-2"
  ssh_username = "packer"
  use_os_login = "false"

  # use custom base image that was built
  source_image_family = var.source_image_family

  image_family      = var.image_family
  image_name        = "nomad-${local.image_nomad_version}-${var.arch}-client-${local.datestamp}"
  image_description = "Nomad client image"

  tags = ["packer"]
}

build {
  sources = ["sources.googlecompute.nomad-client"]

  provisioner "shell" {
    inline = [
      "echo '=============================================='",
      "echo 'CREATE CONSUL USER & GROUP'",
      "echo '=============================================='",
      "sudo addgroup --system consul",
      "sudo adduser --system --ingroup consul consul",
      "sudo mkdir -p /etc/consul.d",
      "sudo mkdir -p /opt/consul",
      "sudo mkdir -p /var/log/consul"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo '=============================================='",
      "echo 'DOWNLOAD CONSUL'",
      "echo '=============================================='",
      "wget https://releases.hashicorp.com/consul/${var.consul_version}/consul_${var.consul_version}_linux_${var.arch}.zip",
      "unzip consul_${var.consul_version}_linux_${var.arch}.zip",
      "sudo mv consul /usr/local/bin/",
      "rm consul_${var.consul_version}_linux_${var.arch}.zip"
    ]
    max_retries = 3
  }

  provisioner "file" {
    source      = "consul/consul.service"
    destination = "/tmp/"
  }

  provisioner "file" {
    source      = "consul/consul.hcl"
    destination = "/tmp/"
  }

  provisioner "shell" {
    inline = [
      "echo '=============================================='",
      "echo 'SETUP CONSUL CLIENT'",
      "echo '=============================================='",
      "sudo mv /tmp/consul.service /etc/systemd/system/",
      "sudo systemctl daemon-reload",
      "sudo mv /tmp/consul.hcl /etc/consul.d/",
      "sudo chown -R consul:consul /etc/consul.d",
      "sudo chown -R consul:consul /opt/consul",
      "sudo chown -R consul:consul /var/log/consul",
      "sudo systemctl disable consul.service"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo '=============================================='",
      "echo 'CREATE NOMAD USER & GROUP'",
      "echo '=============================================='",
      "sudo addgroup --system nomad",
      "sudo adduser --system --ingroup nomad nomad",
      "sudo mkdir -p /etc/nomad.d",
      "sudo mkdir -p /opt/nomad"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo '=============================================='",
      "echo 'DOWNLOAD NOMAD'",
      "echo '=============================================='",
      "wget https://releases.hashicorp.com/nomad/${var.nomad_version}/nomad_${var.nomad_version}_linux_${var.arch}.zip",
      "unzip nomad_${var.nomad_version}_linux_${var.arch}.zip",
      "sudo mv nomad /usr/local/bin/",
      "rm nomad_${var.nomad_version}_linux_${var.arch}.zip"
    ]
    max_retries = 3
  }

  provisioner "file" {
    source      = "nomad/nomad.service"
    destination = "/tmp/"
  }

  provisioner "file" {
    source      = "nomad/client.hcl"
    destination = "/tmp/"
  }

  provisioner "shell" {
    inline = [
      "echo '=============================================='",
      "echo 'SETUP NOMAD CLIENT'",
      "echo '=============================================='",
      "sudo mv /tmp/nomad.service /etc/systemd/system/",
      "sudo systemctl daemon-reload",
      "sudo mv /tmp/client.hcl /etc/nomad.d/",
      "sudo chown -R nomad:nomad /etc/nomad.d",
      "sudo chown -R nomad:nomad /opt/nomad",
      "sudo systemctl disable nomad.service"
    ]
  }

  provisioner "shell" {
    expect_disconnect = "true"
    inline = [
      "which docker",
      "which consul",
      "which nomad",
      "echo '=============================================='",
      "echo 'BUILD COMPLETE'",
      "echo '=============================================='"
    ]
  }
}
