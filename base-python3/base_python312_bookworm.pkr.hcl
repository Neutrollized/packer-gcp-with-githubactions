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
variable "cloudsqlproxy_version" {}


locals {
  # https://www.packer.io/docs/templates/hcl_templates/functions/datetime/formatdate
  datestamp = formatdate("YYYYMMDD", timestamp())
}

# https://www.packer.io/docs/builders/googlecompute#required
source "googlecompute" "base-python312-bookworm" {
  project_id   = var.project_id
  zone         = var.zone
  machine_type = var.machine_type
  preemptible  = true

  # gcloud compute images list
  source_image_family = var.source_image_family

  image_family      = var.image_family
  image_name        = "python312-bookworm-${var.arch}-base-${local.datestamp}"
  image_description = "Debian 12 image with Python 3.12 installed"
  
  ssh_username = "packer"
  use_os_login = false
  use_iap      = true

  tags = ["packer"]
}

build {
  sources = ["sources.googlecompute.base-python312-bookworm"]

  # https://discuss.hashicorp.com/t/how-to-fix-debconf-unable-to-initialize-frontend-dialog-error/39201/2
  provisioner "shell" {
    expect_disconnect = "true"
    inline = [
      "echo '=============================================='",
      "echo 'APT INSTALL PACKAGES & UPDATES'",
      "echo '=============================================='",
      "echo 'debconf debconf/frontend select Noninteractive' | sudo debconf-set-selections",
      "sudo apt-get update",
      "sudo apt-get -y install --no-install-recommends dialog apt-utils git unzip wget apt-transport-https ca-certificates curl gnupg lsb-release software-properties-common",
      "sudo apt-get -y upgrade",
      "sudo apt-get -y dist-upgrade",
      "sudo apt-get -y autoremove",
      "echo 'export TERM=xterm-256color' | sudo tee -a /etc/profile",
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

  provisioner "file" {
    source      = "files/pascalroeleven.sources"
    destination = "/tmp/"
  }

  provisioner "shell" {
    expect_disconnect = "true"
    inline = [
      "echo '=============================================='",
      "echo 'ADD PYTHON3.12 BACKPORT APT REPO'",
      "echo 'https://github.com/pascallj/python3.12-backport'",
      "echo '=============================================='",
      "echo 'Adding GPG key...'",
      "sudo wget -qO- https://pascalroeleven.nl/deb-pascalroeleven.gpg | sudo tee /etc/apt/keyrings/deb-pascalroeleven.gpg > /dev/null",
      "echo 'Adding Python 3.12 backports apt repo...'",
      "sudo mv /tmp/pascalroeleven.sources /etc/apt/sources.list.d/",
      "echo 'Rebooting...'",
      "sudo reboot"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo '=============================================='",
      "echo 'INSTALL PYTHON3.12'",
      "echo '=============================================='",
      "ls /etc/apt/keyrings/",
      "cat /etc/apt/sources.list.d/pascalroeleven.sources",
      "sudo apt-get update",
      "sudo apt-get install -y python3.12 python3.12-dev python3.12-venv",
      "sudo update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1",
      "sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.12 1"
    ]
    pause_before = "30s"
    max_retries  = 3
  }

  # https://cloud.google.com/sql/docs/mysql/connect-auth-proxy#install
  provisioner "shell" {
    inline = [
      "echo '=============================================='",
      "echo 'INSTALL CLOUD SQL AUTH PROXY'",
      "echo '=============================================='",
      "curl -o cloud-sql-proxy https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v${var.cloudsqlproxy_version}/cloud-sql-proxy.linux.amd64",
      "chmod +x cloud-sql-proxy",
      "sudo mv cloud-sql-proxy /usr/local/bin/cloud-sql-proxy"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo '=============================================='",
      "echo 'INSTALL GEMINI-CLI'",
      "echo '=============================================='",
      "curl -sL https://deb.nodesource.com/setup_24.x | sudo bash -",
      "sudo apt-get update",
      "sudo apt-get install -y nodejs",
      "sudo npm install -g @google/gemini-cli"
    ]
  }

  provisioner "shell" {
    expect_disconnect = "true"
    inline = [
      "sudo apt autoremove -y",
      "sudo apt-get clean",
      "sudo npm cache clean --force",
      "python --version",
      "cloud-sql-proxy --version",
      "gemini --version",
      "/usr/local/bin/dynmotd",
      "echo '=============================================='",
      "echo 'BUILD COMPLETE'",
      "echo '=============================================='"
    ]
  }
}
