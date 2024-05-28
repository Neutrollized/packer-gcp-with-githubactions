# /etc/nomad.d/client.hcl
# this requires consul to be running as it finds the Nomad servers via service discovery

datacenter = "{DATACENTER}"
region     = "{REGION}"

# Increase log verbosity
log_level = "INFO"

# Setup data dir
data_dir = "/opt/nomad"

# you need to explicitly set bind address because of the Docker network interface
bind_addr = "{PRIVATE_IPV4}"

# https://www.nomadproject.io/guides/security/acl.html#enable-acls-on-nomad-clients
acl {
  enabled = true
}

server {
  enabled = false
}

# Enable the client
client {
  enabled = true

  # using Consul service discovery to find Nomad server
  servers = ["nomad.service.consul:4647"]

  # BTF (BPF Type Format) required for running Tetragon on Nomad
  # https://developer.hashicorp.com/nomad/docs/configuration/client#host_volume-block
  host_volume "kernel-btf" {
    path      = "/sys/kernel/btf/vmlinux"
    read_only = true
  }

  # Tetragon JSON log path
  host_volume "tetragon-logs" {
    path      = "/var/log/tetragon/"
    read_only = false
  }
}

# https://developer.hashicorp.com/nomad/tutorials/stateful-workloads/stateful-workloads-csi-volumes?in=nomad%2Fstateful-workloads#enable-privileged-docker-jobs
plugin "docker" {
  config {
    allow_privileged = {DOCKER_ALLOW_PRIVILEGED_JOBS}
  }
}

#tls {
#  http = true
#  rpc  = true
#
#  ca_file   = "/etc/ssl/certs/nomad-agent-ca.pem"
#  cert_file = "/etc/nomad.d/ssl/{REGION}-client-nomad.pem"
#  key_file  = "/etc/nomad.d/ssl/{REGION}-client-nomad-key.pem"
#
#  verify_server_hostname = true
#  verify_https_client    = false
#}

# https://developer.hashicorp.com/nomad/docs/configuration/consul
#consul {
#  address        = "http://127.0.0.1:8500"
#  ssl            = false
#  auto_advertise = true
#  token          = "{CONSUL_HTTP_TOKEN}"
#}

# https://www.nomadproject.io/docs/configuration/vault.html
#vault {
#  enabled = true
#  address = "{VAULT_ADDR}"
#}
