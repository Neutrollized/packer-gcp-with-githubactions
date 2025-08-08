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
variable "nomad_version" {}
variable "java_package" {}


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
  machine_type = var.machine_type
  preemptible  = true

  # use custom base image that was built
  source_image_family = var.source_image_family

  image_family      = var.image_family
  image_name        = "nomad-${local.image_nomad_version}-${var.arch}-client-${local.datestamp}"
  image_description = "Nomad client image"

  ssh_username = "packer"
  use_os_login = false
  use_iap      = true

  tags = ["packer"]
}

build {
  #hcp_packer_registry {
    #bucket_name = "gcp-gce-images-nomad-client"
    #description = "Base Debian (w/Docker) image with Nomad (client config), Consul, and Java installed"

    #bucket_labels = {
    #  "os"             = "Debian",
    #  "os-version"     = "Bookworm 12",
    #  "consul-version" = var.consul_version,
    #  "nomad-version"  = var.nomad_version,
    #  "java-package"   = var.java_package,
    #}

    #build_labels = {
    #  "build-time"   = timestamp()
    #  "build-source" = basename(path.cwd)
    #}
  #}

  sources = ["sources.googlecompute.nomad-client"]

  provisioner "shell" {
    inline = [
      "echo '=============================================='",
      "echo 'APT INSTALL JAVA RUNTIME'",
      "echo '=============================================='",
      "echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections",
      "sudo apt-get update",
      "sudo apt-get -y install --no-install-recommends ${var.java_package}",
      "sudo apt-get -y autoremove"
    ]
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
      "echo 'SETUP CONSUL CLIENT'",
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
    inline = [
      "echo '=============================================='",
      "echo 'CREATE NOMAD USER & GROUP'",
      "echo '=============================================='",
      "sudo addgroup --system nomad",
      "sudo adduser --system --ingroup nomad nomad",
      "sudo mkdir -p /etc/nomad.d/ssl",
      "sudo mkdir -p /opt/nomad"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo '=============================================='",
      "echo 'DOWNLOAD NOMAD'",
      "echo '=============================================='",
      "wget https://releases.hashicorp.com/nomad/${var.nomad_version}/nomad_${var.nomad_version}_linux_${var.arch}.zip",
      "unzip -o nomad_${var.nomad_version}_linux_${var.arch}.zip",
      "sudo mv nomad /usr/local/bin/",
      "rm nomad_${var.nomad_version}_linux_${var.arch}.zip"
    ]
    max_retries = 3
  }

  provisioner "file" {
    source      = "nomad/20_client_services_check.sh"
    destination = "/tmp/"
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
      "sudo mv /tmp/20_client_services_check.sh /etc/dynmotd.d/20_services_check.sh",
      "sudo mv /tmp/nomad.service /etc/systemd/system/",
      "sudo systemctl daemon-reload",
      "sudo mv /tmp/client.hcl /etc/nomad.d/",
      "sudo chown -R nomad:nomad /etc/nomad.d",
      "sudo chown -R nomad:nomad /opt/nomad",
      "sudo chmod 750 /etc/nomad.d/ssl",
      "sudo systemctl disable nomad.service"
    ]
  }

  provisioner "file" {
    source      = "nomad/bridge.conf"
    destination = "/tmp/"
  }

  # https://developer.hashicorp.com/nomad/docs/install#post-installation-steps
  provisioner "shell" {
    inline = [
      "echo '=============================================='",
      "echo 'INSTALL CNI PLUGINS'",
      "echo '=============================================='",
      "curl -L -o /tmp/cni-plugins.tgz \"https://github.com/containernetworking/plugins/releases/download/v1.0.0/cni-plugins-linux-$( [ $(uname -m) = aarch64 ] && echo arm64 || echo amd64)\"-v1.0.0.tgz",
      "sudo mkdir -p /opt/cni/bin",
      "sudo tar -C /opt/cni/bin -xzf /tmp/cni-plugins.tgz",
      "sudo mv /tmp/bridge.conf /etc/sysctl.d/"
    ]
    max_retries = 3
  }

  # additional installs for running Tetragon
  provisioner "shell" {
    inline = [
      "echo '=============================================='",
      "echo 'INSTALL LOGGING & TETRAGON PRE-REQS'",
      "echo 'https://cloud.google.com/stackdriver/docs/solutions/agents/ops-agent/installation#optional-tasks'",
      "echo '=============================================='",
      "curl -L -o /tmp/add-google-cloud-ops-agent-repo.sh \"https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh\"",
      "sudo bash /tmp/add-google-cloud-ops-agent-repo.sh --also-install",
      "sudo mkdir -p /var/log/tetragon",
      "echo 'DefaultEnvironment=\"NO_PROXY=http://metadata.google.internal\"  # Skip proxy for the local Metadata Server.' | sudo tee -a /etc/systemd/system.conf",
      "sudo systemctl disable google-cloud-ops-agent.service",
      "sudo rm /tmp/add-google-cloud-ops-agent-repo.sh"
    ]
    max_retries = 1
  }

  provisioner "shell" {
    expect_disconnect = "true"
    inline = [
      "which docker",
      "docker --version",
      "echo ''",
      "which java",
      "java --version",
      "echo ''",
      "which consul",
      "consul --version",
      "which nomad",
      "nomad --version",
      "/usr/local/bin/dynmotd",
      "echo '=============================================='",
      "echo 'BUILD COMPLETE'",
      "echo '=============================================='"
    ]
  }
}
