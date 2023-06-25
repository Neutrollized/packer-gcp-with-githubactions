[![Packer Build](https://github.com/Neutrollized/packer-gcp-with-githubactions/actions/workflows/packer.yaml/badge.svg)](https://github.com/Neutrollized/packer-gcp-with-githubactions/actions/workflows/packer.yaml)

# HashiCorp Packer & GCP with GitHub Actions

- building Google Cloud VM images using Packer and GitHub Actions
- authentication handled by [Workload Identity Federation (WIF)](https://cloud.google.com/iam/docs/workload-identity-federation)


## Setup

### 0 - Fork this repo

### 1 - WIF Pool & GitHub Provider
Terraform code for setting up required GCP service accounts and WIF can be found [here](./terraform)

### 2 - Update GitHub Workflow YAML
You will need to update the `WIF_PROVIDER` and `WIF_SERVICE_ACCOUNT` env vars in the [packer.yaml](.github/workflow/packer.yaml) accordingly for your GCP project and WIF Pool configuration

### 3 - Push your commit!
Check the **Actions** tab and watch it go


### NOTE - Using Credentials JSON
While not the recommended method of authenticating to Google Cloud, you can generate a credentials JSON key file and paste its contents into a GitHub repo secret:
```
jobs:
    [...]

    steps:
      [...]

      - name: 'Authenticate to Google Cloud'
        id: 'auth'
        uses: 'google-github-actions/auth@v1'
        with:
          credentials_json: '${{ secrets.GCP_CREDENTIALS_JSON }}'

      [...]
```
