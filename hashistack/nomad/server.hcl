# /etc/nomad.d/server.hcl

# default region is "global"
# Nomad will identify your server nodes as HOSTNAME.region
datacenter = "{DATACENTER}"
region     = "{REGION}"

advertise {
  http = "{PRIVATE_IPV4}"
  rpc  = "{PRIVATE_IPV4}"
  serf = "{PRIVATE_IPV4}"
}

# Increase log verbosity
log_level = "INFO"

# Setup data dir
data_dir = "/opt/nomad"

# https://www.nomadproject.io/guides/security/acl.html#enable-acls-on-nomad-servers
acl {
  enabled = true
}

# Enable the server
server {
  enabled = true

  # Self-elect, should be 3 or 5 for production
  bootstrap_expect = {SERVER_COUNT}

  # https://learn.hashicorp.com/nomad/transport-security/gossip-encryption
  encrypt = "{GOSSIP_KEY}"

  # https://www.nomadproject.io/docs/configuration/server#job_gc_interval
  job_gc_interval = "72h"
}

client {
  enabled = false
}

#tls {
#  http = true
#  rpc  = true
#
#  ca_file   = "/etc/ssl/certs/nomad-agent-ca.pem"
#  cert_file = "/etc/nomad.d/ssl/{REGION}-server-nomad.pem"
#  key_file  = "/etc/nomad.d/ssl/{REGION}-server-nomad-key.pem"
#
#  verify_server_hostname = true
#  verify_https_client    = false
#}

# https://www.nomadproject.io/docs/configuration/vault.html
#vault {
#  enabled = true
#  address = "{VAULT_ADDR}"
#  token   = "{VAULT_TOKEN}"
#}
