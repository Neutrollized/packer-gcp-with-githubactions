# /etc/consul.d/consul.hcl
log_level = "INFO"

datacenter =  "{CLOUD}-{ENV}-{REGION}"

data_dir = "/opt/consul"

# https://www.consul.io/docs/agent/encryption.html
encrypt = "{GOSSIP_KEY}"

retry_join = ["provider=aws tag_key=role tag_value={CONSUL_SERVER_TAG}"]

# https://www.consul.io/docs/install/performance.html
performance {
  raft_multiplier = 1
}

log_file = "/var/log/consul/consul.log"
log_rotate_max_files = 90
