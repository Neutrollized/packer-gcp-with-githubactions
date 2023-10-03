# /etc/consul.d/client.hcl

# https://developer.hashicorp.com/consul/docs/security/encryption
#tls {
#  defaults {
#    verify_incoming = true
#    verify_outgoing = true
#
#    ca_file = "/etc/ssl/certs/consul-agent-ca.pem"
#  }
#
#  internal_rpc {
#    verify_server_hostname = true
#  }
#}

#auto_encrypt {
#  tls = true
#}

connect {
  enabled = false
}
