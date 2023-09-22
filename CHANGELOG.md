# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

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
