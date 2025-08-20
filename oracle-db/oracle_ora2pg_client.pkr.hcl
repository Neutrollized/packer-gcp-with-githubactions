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
variable "ora2pg_version" {}
variable "cloudsqlproxy_version" {}


locals {
  # https://www.packer.io/docs/templates/hcl_templates/functions/datetime/formatdate
  datestamp = formatdate("YYYYMMDD", timestamp())
}

# https://www.packer.io/docs/builders/googlecompute#required
source "googlecompute" "oracle-ora2pg-client" {
  project_id   = var.project_id
  zone         = var.zone
  machine_type = var.machine_type
  preemptible  = true

  # gcloud compute images list
  source_image_family = var.source_image_family

  image_family      = var.image_family
  image_name        = "oracle-ora2pg-${var.arch}-client-${local.datestamp}"
  image_description = "Oracle Linux 8 image with Oracle SQLPlus client and ora2pg installed"

  ssh_username = "packer"
  use_os_login = false
  use_iap      = true

  tags = ["packer"]
}

build {
  sources = ["sources.googlecompute.oracle-ora2pg-client"]

  provisioner "shell" {
    inline = [
      "echo '=============================================='",
      "echo 'INSTALL ORACLE SQL*PLUS INSTANTCLIENT'",
      "echo '=============================================='",
      "sudo dnf install -y oracle-instantclient-release-el8",
      "sudo dnf install -y oracle-instantclient-sqlplus oracle-instantclient-tools",
      "echo 'export ORACLE_HOME=/usr/lib/oracle/21/client64' | sudo tee -a /etc/profile",
      "echo 'export LD_LIBRARY_PATH=/usr/lib/oracle/21/client64/lib' | sudo tee -a /etc/profile"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo '=============================================='",
      "echo 'INSTALL ORA2PG'",
      "echo '=============================================='",
      "sudo dnf install -y perl-CPAN perl-DBI perl-DBD-Pg perl-Time-HiRes perl-Compress-Raw-Zlib oracle-instantclient-devel libnsl libaio",
      "sudo ORACLE_HOME=/usr/lib/oracle/21/client64 LD_LIBRARY_PATH=/usr/lib/oracle/21/client64/lib cpan -i DBD::Oracle",
      "cd /usr/local/bin",
      "sudo wget -q https://github.com/darold/ora2pg/archive/refs/tags/v${var.ora2pg_version}.tar.gz",
      "sudo tar zxf v${var.ora2pg_version}.tar.gz",
      "cd ora2pg-${var.ora2pg_version}",
      "sudo perl Makefile.PL",
      "sudo make && sudo make install",
      "sudo rm -Rf /usr/local/bin/ora2pg-${var.ora2pg_version} /usr/local/bin/v${var.ora2pg_version}.tar.gz",
      "echo 'export PERL5LIB=/usr/local/share/perl5' | sudo tee -a /etc/profile"
    ]
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
    expect_disconnect = "true"
    inline = [
      "sudo dnf clean all",
      "sqlplus -V",
      "ora2pg -v",
      "cloud-sql-proxy -v",
      "/usr/local/bin/dynmotd",
      "echo '=============================================='",
      "echo 'BUILD COMPLETE'",
      "echo '=============================================='"
    ]
  }
}
