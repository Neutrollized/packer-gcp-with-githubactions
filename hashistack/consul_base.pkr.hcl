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
source "googlecompute" "consul-base" {
  project_id   = var.project_id
  zone         = var.zone
  machine_type = var.machine_type
  preemptible  = true

  # use custom base image that was built
  source_image_family = var.source_image_family

  image_family      = var.image_family
  image_name        = "consul-${local.image_consul_version}-${var.arch}-base-${local.datestamp}"
  image_description = "Consul base image"

  ssh_username = "packer"
  use_os_login = false
  use_iap      = true

  tags = ["packer"]
}

build {
  #hcp_packer_registry {
    #bucket_name = "gcp-gce-images-consul-base"
    #description = "Base Debian image with Consul installed"

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

  sources = ["sources.googlecompute.consul-base"]

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

  provisioner "shell" {
    inline = [
      "echo '=============================================='",
      "echo 'CREATE CONSUL USER & GROUP'",
      "echo '=============================================='",
      "sudo addgroup --system consul",
      "sudo adduser --system --ingroup consul consul",
      "sudo mkdir -p /etc/consul.d/ssl",
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
      "unzip -o consul_${var.consul_version}_linux_${var.arch}.zip",
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

  provisioner "file" {
    source      = "consul/client.hcl"
    destination = "/tmp/"
  }

  provisioner "shell" {
    inline = [
      "echo '=============================================='",
      "echo 'SETUP CONSUL'",
      "echo '=============================================='",
      "sudo mv /tmp/consul.service /etc/systemd/system/",
      "sudo systemctl daemon-reload",
      "sudo mv /tmp/consul.hcl /etc/consul.d/",
      "sudo mv /tmp/client.hcl /etc/consul.d/",
      "sudo chown -R consul:consul /etc/consul.d",
      "sudo chown -R consul:consul /opt/consul",
      "sudo chown -R consul:consul /var/log/consul",
      "sudo chmod 750 /etc/consul.d/ssl",
      "sudo systemctl disable consul.service"
    ]
  }

  provisioner "shell" {
    expect_disconnect = "true"
    inline = [
      "which consul",
      "consul --version",
      "sudo apt-get clean",
      "echo '=============================================='",
      "echo 'BUILD COMPLETE'",
      "echo '=============================================='"
    ]
  }
}
