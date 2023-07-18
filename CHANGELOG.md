# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

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
