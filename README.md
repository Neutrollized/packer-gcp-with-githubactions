[![Packer Build](https://github.com/Neutrollized/packer-gcp-with-githubactions/actions/workflows/packer.yaml/badge.svg)](https://github.com/Neutrollized/packer-gcp-with-githubactions/actions/workflows/packer.yaml)

# HashiCorp Packer & GCP with GitHub Actions

- building Google Cloud VM images using Packer and GitHub Actions
- authentication handled by [Workload Identity Federation (WIF)](https://cloud.google.com/iam/docs/workload-identity-federation)

[Medium: Getting started with HashiCorp Packer on Google Cloud Platform](https://medium.com/@glen.yu/getting-started-with-hashicorp-packer-on-google-cloud-platform-a36bfeffbfa9)

I'm also using larger machine types (i.e. *n2-standard-4*), but with [preemptible VM instances](https://cloud.google.com/compute/docs/instances/preemptible) which should both speed up the build process and reduce overall cost.

**NOTE**: there are other non-HashiCorp stack images, but they will not be included in the GitHub Actions to automatically build images

## Setup

### 0 - Fork this repo


### 1 - WIF Pool & GitHub Provider
Terraform code for setting up required GCP service accounts and WIF can be found [here](./terraform)


### 2 - Update GitHub Workflow YAML
You will need to update the `WIF_PROVIDER` and `WIF_SERVICE_ACCOUNT` env vars in the [packer.yaml](.github/workflow/packer.yaml) accordingly for your GCP project and WIF Pool configuration

#### NOTE - You can get the `WIF_PROVIDER` with the following `gcloud` command (provider ID = *github* in my example): 
```sh
gcloud iam workload-identity-pools providers describe ${WIF_PROVIDER_ID} \
    --location global \
    --workload-identity-pool ${WIF_POOL_ID} \
    --format='get(name)'
```

#### NOTE - I used GitHub's CLI tool, [`gh`](https://github.com/cli/cli) to [set secrets](https://cli.github.com/manual/gh_secret_set) via command line


### 3 - Push your commit!
Check the **Actions** tab and watch it go


#### NOTE - Using Credentials JSON
While not the recommended method of authenticating to Google Cloud, you can generate a credentials JSON key file and paste its contents into a GitHub repo secret:
```
jobs:
    [...]

    steps:
      [...]

      - name: 'Authenticate to Google Cloud'
        id: 'auth'
        uses: 'google-github-actions/auth@v2'
        with:
          credentials_json: '${{ secrets.GCP_CREDENTIALS_JSON }}'

      [...]
```


## HCP Packer integration
- [What is HCP Packer?](https://developer.hashicorp.com/hcp/docs/packer)
- [Setup / Requirements](https://developer.hashicorp.com/packer/tutorials/hcp-get-started/hcp-push-artifact-metadata#create-hcp-packer-registry)

You will need to add the following secrets to GitHub:
- `HCP_ORGANIZATION_ID`
- `HCP_PROJECT_ID`
- `HCP_CLIENT_ID`
- `HCP_CLIENT_SECRET`

**NOTE**: You can track up to ~~[10 buckets (images) for free](https://www.hashicorp.com/products/packer/pricing)~~, but if you do not wish to, you can always comment out `hcp_packer_registry` block from the image build template file(s).

**UPDATE**: As of [v1.1.0](https://github.com/Neutrollized/packer-gcp-with-githubactions/blob/main/CHANGELOG.md#110---2025-03-26), due to recent HCP Packer pricing changes, there's no longer a free tier and hence I've commented out `hcp_packer_registry` references as it's always been my goal to keep my repos/deployments as cost-effective as possible for learning.


## Run Locally
If you wish to run this locally without using GitHub Actions, you can do the following:

- authenticate using user application default creds
```sh
gcloud auth application-default login
```

```sh
packer init base_docker.pkr.hcl

PKR_VAR_access_token='xxxxxxxxxxxxx' packer build -var 'project_id=myproject-123' -var-file=variables.pkrvars.hcl base_docker.pkr.hcl`
```
**NOTE**: obtain access_token with `gcloud auth print-access-token`

### TL;DR
```sh
PKR_VAR_access_token=$(gcloud auth print-access-token) packer build -var 'project_id=myproject-123' -var-file=variables.pkrvars.hcl base_docker.pkr.hcl`
```
