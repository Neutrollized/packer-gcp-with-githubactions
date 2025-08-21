# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).


## [1.4.1] - 2025-08-21
### Added
- Set `TERM='xterm-256color'` in `/etc/profile` of Python 3.12 Bookworm base image
- Install of `cloud-sql-proxy` binary to the Python 3.12 Bookworm base image
- Install of `gemini` CLI binary to the Python 3.12 Bookworm base image

## [1.4.0] - 2025-08-20
### Added
- Added `base-python3/base_python312_bookworm.pkr.hcl` which builds base Debian 12 (Bookworm) image with [Python 3.12 backport](https://github.com/pascallj/python3.12-backport)
- Install of `cloud-sql-proxy` binary in the Oracle DB client image because...why not?
### Changed
- Added `base-python3/*` to `paths-ignore` in GitHub Actions `packer.yaml`
- Added `sudo apt autoremove -y` to the end of base (Debian-based) image builds
- Updated Consul version from `1.21.3` to `1.21.4`
- Updated Nomad version from `1.10.3` to `1.10.4`

## [1.3.1] - 2025-08-12
### Added
- Added export of `ORACLE_HOME` to /etc/profile in Oracle client image
### Changed
- Explicitly setting `ORACLE_HOME` and `LD_LIBRARY_PATH` env vars when running `cpan` command to install Perl modules

## [1.3.0] - 2025-08-08
### Added
- Added `oracle-db/base_ol.pkr.hcl` which builds base Oracle Linux 8 image
- Added `oracle-db/oracle_server.pkr.hcl` which builds Oracle XE 21c server on top of the custom base OL8 image
- Added `oracle-db/oracle_ora2pg_client.pkr.hcl` which builds Oracle SQL*Plus client and [ora2pg](https://ora2pg.darold.net/) on top of the custom base OL8 image
### Changed
- Added `oracle-db/*` to `paths-ignore` in GitHub Actions `packer.yaml`
- Updated Consul version from `1.21.0` to `1.21.3`
- Updated Nomad version from `1.10.0` to `1.10.3`
- Updated Vault version from `1.19.3` to `1.20.2`

## [1.2.0] - 2025-05-11
### Added
- `dev` branch to GHA trigger
- Set up Google Cloud SDK (`google-github-actions/setup-gcloud@v2`) step to the GHA job steps
- Using IAP to connect to the VM to build, which requires Google Cloud SDK (`use_iap = true`)
- Packer variable `machine_type` (default: `n2-standard-4`)
- Using preemptible VM instance (`preemptible = true`)
- GCP firewall rule for to allow IAP tunneling
- Added `roles/iap.tunnelResourceAccessor` role to Packer service account IAM roles list
### Changed
- Updated Consul version from `1.20.5` to `1.21.0`
- Updated Nomad version from `1.9.7` to `1.10.0`
- Updated Vault version from `1.19.0` to `1.19.3`

## [1.1.0] - 2025-03-26
### Added
- Consul backend storage config example to `vault_server.hcl.sample`
### Changed
- Commented out any HCP Packer reference code blocks due to the recent pricing changes and removal of the free tier
- Updated Consul version from `1.20.1` to `1.20.5`
- Updated Nomad version from `1.9.3` to `1.9.7`
- Updated Vault version from `1.18.2` to `1.19.0`

## [1.0.0] - 2024-12-13
### Added
- [HCP Packer integration](https://github.com/Neutrollized/packer-gcp-with-githubactions/blob/main/README.md#hcp-packer-integration)!  Now image metadata is being sent and stored in HCP Packer.
### Changed
- Updated Packer version from `1.9.5` to `1.11.2`
- Updated `source_image_family` from `debian-11` to `debian-12`
- Increasing the `pause_before` time from `10s` to `30s` to ensure sufficient wait time after reboots
- Updated Consul version from `1.19.2` to `1.20.1`
- Updated Nomad version from `1.8.4` to `1.9.3`
- Updated Vault version from `1.17.6` to `1.18.2`
- fluentd [Logging agent](https://cloud.google.com/logging/docs/agent/logging) in the Nomad client image is considered legacy and has been replaced by Ops Agent
### Removed
- Packer variable, `google_fluentd_version`

## [0.11.2] - 2024-09-30
### Changed
- Updated Consul version from `1.19.1` to `1.19.2`
- Updated Nomad version from `1.8.2` to `1.8.4`
- Updated Vault version from `1.17.2` to `1.17.6`

## [0.11.1] - 2024-07-17
### Changed
- Updated Consul version from `1.18.2` to `1.19.1`
- Updated Nomad version from `1.7.7` to `1.8.2`
- Updated Vault version from `1.16.2` to `1.17.2`

## [0.11.0] - 2024-05-28
### Added
- Nomad client config for [enabling privileged Docker jobs](https://developer.hashicorp.com/nomad/tutorials/stateful-workloads/stateful-workloads-csi-volumes?in=nomad%2Fstateful-workloads#enable-privileged-docker-jobs) 
- [Host volume block](https://developer.hashicorp.com/nomad/docs/configuration/client#host_volume-block) in Nomad client config (required to use Tetragon)
- Packer variable, `google_fluentd_version`
- Installing logging & Tetragon pre-requisites on Nomad client

## [0.10.1] - 2024-05-20
### Added
- Packer build outputs installed tooling version
### Changed
- `unzip` run with `-o` (overwrite without prompting) option
- Updated Consul version from `1.18.1` to `1.18.2`
- Updated Nomad version from `1.7.6` to `1.7.7`
- Updated Vault version from `1.16.0` to `1.16.2`
### Fixed
- Added/moved `pause_before` and `max_retries` to add stability to Vault build

## [0.10.0] - 2024-04-03
### Added
- `attribute_condition = "assertion.repository_owner=='${var.github_org}'"` to Workload Identity Pool as per [recommended security practices](https://cloud.google.com/iam/docs/workload-identity-federation-with-deployment-pipelines#conditions)
### Changed
- Updated `gh_oidc` Terraform module version from `3.1.1` to `3.1.2`

## [0.9.0] - 2024-03-31
### Changed
- Updated `actions/checkout` from `v3` to `v4` (Node.js 16 actions are deprecated)
- Updated `google-github-actions/auth` from `v1` to `v2` (Node.js 16 actions are deprecated)
- Updated Consul version from `1.17.2` to `1.18.1`
- Updated Nomad version from `1.7.3` to `1.7.6`
- Updated Vault version from `1.15.5` to `1.16.0`

## [0.8.1] - 2024-02-08
### Changed
- Updated Vault version from `1.15.4` to `1.15.5`
- Updated TLS cert & key file path and filename in `hashistack/vault/vault_server.hcl.sample`

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
