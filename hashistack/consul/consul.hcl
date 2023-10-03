# /etc/consul.d/consul.hcl
log_level = "INFO"

datacenter = "{DATACENTER}"

data_dir = "/opt/consul"

bind_addr = "{PRIVATE_IPV4}"

# https://www.consul.io/docs/agent/encryption.html
encrypt = "{GOSSIP_KEY}"

# https://developer.hashicorp.com/consul/docs/install/cloud-auto-join#google-compute-engine
retry_join = ["provider=gce tag_value={CONSUL_SERVER_TAG}"]

# https://www.consul.io/docs/install/performance.html
performance {
  raft_multiplier = 1
}

ports {
  https    = 8501
  grpc     = 8502
  grpc_tls = 8503
}

log_file = "/var/log/consul/consul.log"
log_rotate_max_files = 90
