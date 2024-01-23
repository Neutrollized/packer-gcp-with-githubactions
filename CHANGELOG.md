# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [0.8.0] - 2024-01-23
### Added
- Vault base image, version `1.15.4`
### Changed
- Updated Packer version from `1.9.4` to `1.9.5`
- Updated Consul version from `1.17.0` to `1.17.2`
- Updated Nomad version from `1.7.0` to `1.7.3`

## [0.7.0] - 2023-12-07
### Added
- Variable `java_package` (default: `openjdk-17-jre-headless` as the Ubuntu Java runtime package name to be installed on Nomad clients
- `server.authoritative_region` and `acl.replication_token` to Nomad server config
### Changed
- Updated Consul version from `1.16.2` to `1.17.0`
- Updated Nomad version from `1.6.2` to `1.7.0`
- CNI Plugins for Nomad clients as per [post-installation steps](https://developer.hashicorp.com/nomad/docs/install#post-installation-steps)

## [0.6.0] - 2023-10-05
### Added
- CNI Plugins for Nomad clients as per [post-installation steps](https://developer.hashicorp.com/nomad/docs/install#post-installation-steps)
- Enabled additional ports in Consul config
- `connect.enabled = false` in Consul client config (you need to create CA & SSL/TLS certs if you want to use service mesh) 

## [0.5.1] - 2023-10-02
### Added
- `primary_datacenter` and `retry_join_wan` to Consul server config
### Fixed
- Added missing `consul/client.hcl` to Nomad client image

## [0.5.0] - 2023-10-02
### Added
- `client.hcl` for Consul clients [Auto-encryption](https://developer.hashicorp.com/consul/tutorials/security/tls-encryption-secure#client-certificate-distribution) TLS config
- `tls` stanza in Nomad configs
### Changed 
- `{DATACENTER}` is the new placeholder for datacenter name in Consul and Nomad configs
### Fixed
- Updated `tls` stanza in Consul configs

## [0.4.0] - 2023-09-25
### Added 
- Added `bind_addr` and `acl` stanzas to Consul `consul.hcl` config
- Added `consul` stanza to Nomad `client.hcl` config
### Fixed
- Updated `consul.hcl` config for GCP auto-join

## [0.3.1] - 2023-09-22
### Added
- Separate "services check" scripts for Nomad servers and clients
### Changed
- Updated Consul version from `1.16.1` to `1.16.2`

## [0.3.0] - 2023-09-18
### Added
- `required_plugins` added to template as [Packer plugins](https://developer.hashicorp.com/packer/docs/plugins) will be standalone in future releases of Packer 
### Changed
- Updated Packer version from `1.9.2` to `1.9.4`
- Updated Nomad version from `1.6.0` to `1.6.2`

## [0.2.2] - 2023-07-20
### Changed
- Added `terraform/**` to workflow trigger's `paths-ignore`
- Updated Packer version from `1.9.1` to `1.9.2`
- Updated Nomad version from `1.5.6` to `1.6.0`

## [0.2.1] - 2023-07-17
### Changed
- Using GitHub Action repository secrets
- Split variable files into multiple for easier management of common settings
- Updated Consul version from `1.15.3` to `1.16.0`
- Updated `zone` from `us-central1-a` to `northamerica-northeast2-c` where it's less busy for GHA to run

## [0.2.0] - 2023-06-25
### Added
- `packer validate` to GitHub Actions workflow
- Restrict SSH by packer only to Compute Engine service account

## [0.1.0] - 2023-06-20
### Added
- Initial commit
