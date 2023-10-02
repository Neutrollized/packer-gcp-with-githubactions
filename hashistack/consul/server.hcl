# /etc/consul.d/server.hcl (req only for consul servers obvs)
# https://www.consul.io/docs/agent/options.html

server = true
bootstrap_expect = {SERVER_COUNT}

advertise_addr = "{PRIVATE_IPV4}"
# https://www.consul.io/docs/agent/options#_client
client_addr = "127.0.0.1 {PRIVATE_IPV4}"

ui_config {
  enabled = true
}

# https://developer.hashicorp.com/consul/docs/agent/config/config-files#primary_datacenter
#primary_datacenter = "{PRIMARY_DC}"
# https://developer.hashicorp.com/consul/tutorials/networking/federation-gossip-wan#persist-join-with-retry-join
#retry_join_wan = ["{DC2_SERVER1}", "{DC2_SERVER2}"]

# https://developer.hashicorp.com/consul/docs/security/acl
#acl = {
#  enabled = true
#  default_policy = "deny"
#  enable_token_persistence = true
#}

# https://learn.hashicorp.com/consul/security-networking/certificates
# https://learn.hashicorp.com/consul/day-2-agent-authentication/update-certificates
# https://developer.hashicorp.com/consul/docs/security/encryption
#tls {
#  defaults {
#    verify_incoming = true
#    verify_outgoing = true
#
#    ca_file   = "/etc/ssl/certs/consul-agent-ca.pem"
#    cert_file = "/etc/consul.d/ssl/{DATACENTER}-server-consul-0.pem"
#    key_file  = "/etc/consul.d/ssl/{DATACENTER}-server-consul-0-key.pem"
#  }
#
#  internal_rpc {
#    verify_server_hostname = true
#  }
#}

#auto_encrypt {
#  allow_tls = true
#}
