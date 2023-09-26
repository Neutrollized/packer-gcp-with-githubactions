# /etc/nomad.d/server.hcl

advertise {
  http = "{PRIVATE_IPV4}"
  rpc  = "{PRIVATE_IPV4}"
  serf = "{PRIVATE_IPV4}"
}

# default region is "global"
# Nomad will identify your server nodes as HOSTNAME.region
datacenter = "{CLOUD}-{ENV}"
region     = "{REGION}"

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

# https://www.nomadproject.io/docs/configuration/vault.html
#vault {
#  enabled = true
#  address = "{VAULT_ADDR}"
#  token   = "{VAULT_TOKEN}"
#}
