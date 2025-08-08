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
variable "oracle_edition" {}
variable "oracle_version" {}
variable "disk_size" {}


locals {
  # https://www.packer.io/docs/templates/hcl_templates/functions/datetime/formatdate
  datestamp = formatdate("YYYYMMDD", timestamp())
}

# https://www.packer.io/docs/builders/googlecompute#required
source "googlecompute" "oracle-server" {
  project_id   = var.project_id
  zone         = var.zone
  machine_type = var.machine_type
  preemptible  = true

  # gcloud compute images list
  source_image_family = var.source_image_family

  image_family      = var.image_family
  image_name        = "oracle-${var.oracle_edition}-${var.oracle_version}-${var.arch}-server-${local.datestamp}"
  image_description = "Oracle Linux 8 image with Oracle XE 21c installed"

  disk_size = var.disk_size
  
  ssh_username = "packer"
  use_os_login = false
  use_iap      = true

  tags = ["packer"]
}

build {
  sources = ["sources.googlecompute.oracle-server"]

  provisioner "file" {
    source      = "oracle/30_oracledb_services_check.sh"
    destination = "/tmp/"
  }

  provisioner "shell" {
    inline = [
      "echo '=============================================='",
      "echo 'INSTALL ORACLE SERVER'",
      "echo '=============================================='",
      "sudo dnf install -y oracle-database-preinstall-${var.oracle_version}",
      "wget -q https://download.oracle.com/otn-pub/otn_software/db-express/oracle-database-${var.oracle_edition}-${var.oracle_version}-1.0-1.ol8.x86_64.rpm",
      "sudo dnf install -y ./oracle-database-${var.oracle_edition}-${var.oracle_version}-1.0-1.ol8.x86_64.rpm",
      "rm ./oracle-database-${var.oracle_edition}-${var.oracle_version}-1.0-1.ol8.x86_64.rpm"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo '=============================================='",
      "echo 'CONFIGURE ORACLE SERVER'",
      "echo '=============================================='",
      "sudo mv /tmp/30_oracledb_services_check.sh /etc/dynmotd.d/",
      "sudo dnf install -y tuned-profiles-oracle",
      "sudo tuned-adm profile oracle",
      "echo 'export ORACLE_BASE=/opt/oracle' | sudo tee -a /etc/profile",
      "echo 'export ORACLE_HOME=/opt/oracle/product/21c/dbhomeXE' | sudo tee -a /etc/profile"
    ]
  }

  provisioner "shell" {
    expect_disconnect = "true"
    inline = [
      "sudo dnf clean all",
      "/usr/local/bin/dynmotd",
      "echo '=============================================='",
      "echo 'BUILD COMPLETE'",
      "echo '=============================================='"
    ]
  }
}
